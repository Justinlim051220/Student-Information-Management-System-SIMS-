using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Admin
{
    public partial class ManageProgrammes : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                LoadCurrentHoP();
                LoadProgrammes();
            }
        }

        private void LoadCurrentHoP()
        {
            int userId = SessionHelper.GetUserId(Session);
            string sql = "SELECT FirstName + ' ' + LastName FROM HoPDetails WHERE UserId = @UserId";
            object name = DatabaseHelper.ExecuteScalar(sql, new[] { new SqlParameter("@UserId", userId) });
            lblCurrentHoP.Text = name?.ToString() ?? "Current Admin";
        }

        private void LoadProgrammes()
        {
            string keyword = txtSearchProgramme.Text.Trim();
            string duration = ddlFilterDuration.SelectedValue;

            string sql = @"
                SELECT p.ProgrammeId, p.ProgrammeName, p.ProgrammeCode, p.Duration, p.Description
                FROM Programmes p
                WHERE (@Duration = '' OR CAST(p.Duration AS VARCHAR(10)) = @Duration)
                  AND (@Keyword = ''
                       OR p.ProgrammeName LIKE '%' + @Keyword + '%'
                       OR p.ProgrammeCode LIKE '%' + @Keyword + '%'
                       OR CAST(p.Duration AS VARCHAR(10)) LIKE '%' + @Keyword + '%'
                       OR p.Description LIKE '%' + @Keyword + '%')
                ORDER BY p.ProgrammeName";

            gvProgrammes.DataSource = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@Keyword", keyword),
                new SqlParameter("@Duration", duration)
            });
            gvProgrammes.DataBind();
        }

        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            ClearForm();
            lblFormTitle.Text = "Add New Programme";
            hfProgrammeId.Value = "";
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtProgrammeName.Text) ||
                string.IsNullOrWhiteSpace(txtProgrammeCode.Text) ||
                string.IsNullOrWhiteSpace(txtDuration.Text))
            {
                ShowMessage("Please fill in all required fields.", "error", false, null, "Validation Error");
                return;
            }

            try
            {
                int hopUserId = SessionHelper.GetUserId(Session);
                object hopIdObj = DatabaseHelper.ExecuteScalar(
                    "SELECT HoPId FROM HoPDetails WHERE UserId = @Uid",
                    new[] { new SqlParameter("@Uid", hopUserId) });

                string hopId = hopIdObj?.ToString() ?? "HOP001";

                if (string.IsNullOrEmpty(hfProgrammeId.Value)) // ADD NEW
                {
                    string sql = @"
                        INSERT INTO Programmes (ProgrammeName, ProgrammeCode, Duration, Description, HoPId)
                        VALUES (@Name, @Code, @Duration, @Desc, @HoPId)";

                    DatabaseHelper.ExecuteNonQuery(sql, new[]
                    {
                        new SqlParameter("@Name", txtProgrammeName.Text.Trim()),
                        new SqlParameter("@Code", txtProgrammeCode.Text.Trim().ToUpper()),
                        new SqlParameter("@Duration", int.Parse(txtDuration.Text)),
                        new SqlParameter("@Desc", txtDescription.Text.Trim()),
                        new SqlParameter("@HoPId", hopId)
                    });

                    ShowMessage("Programme added successfully!", "success", false, null, "Programme Added");
                }
                else // UPDATE
                {
                    string sql = @"
                        UPDATE Programmes 
                        SET ProgrammeName = @Name,
                            ProgrammeCode = @Code,
                            Duration = @Duration,
                            Description = @Desc
                        WHERE ProgrammeId = @Id";

                    DatabaseHelper.ExecuteNonQuery(sql, new[]
                    {
                        new SqlParameter("@Name", txtProgrammeName.Text.Trim()),
                        new SqlParameter("@Code", txtProgrammeCode.Text.Trim().ToUpper()),
                        new SqlParameter("@Duration", int.Parse(txtDuration.Text)),
                        new SqlParameter("@Desc", txtDescription.Text.Trim()),
                        new SqlParameter("@Id", int.Parse(hfProgrammeId.Value))
                    });

                    ShowMessage("Programme updated successfully!", "success", false, null, "Programme Updated");
                }

                ClearForm();
                LoadProgrammes();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "error", false, null, "Error");
            }
        }

        protected void gvProgrammes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int programmeId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditProgramme")        // ← Changed here
            {
                LoadProgrammeForEdit(programmeId);
            }
            else if (e.CommandName == "DeleteProgramme")
            {
                ShowMessage(
                    $"Are you sure you want to delete Programme <strong>{programmeId}</strong>?<br><br>This action cannot be undone.",
                    "delete",
                    true,
                    programmeId.ToString(),
                    "Delete Programme?");
            }
        }

        private void LoadProgrammeForEdit(int programmeId)
        {
            string sql = "SELECT * FROM Programmes WHERE ProgrammeId = @Id";
            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@Id", programmeId) });

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                hfProgrammeId.Value = row["ProgrammeId"].ToString();
                txtProgrammeName.Text = row["ProgrammeName"].ToString();
                txtProgrammeCode.Text = row["ProgrammeCode"].ToString();
                txtDuration.Text = row["Duration"].ToString();
                txtDescription.Text = row["Description"].ToString();

                lblFormTitle.Text = "Edit Programme";
                ShowMessage("You are now editing the selected programme record.", "warning", false, null, "Edit Mode");
            }
        }

        private void DeleteProgramme(int programmeId)
        {
            try
            {
                // Check if programme has students
                object count = DatabaseHelper.ExecuteScalar(
                    "SELECT COUNT(*) FROM StudentDetails WHERE ProgrammeId = @Id",
                    new[] { new SqlParameter("@Id", programmeId) });

                if (Convert.ToInt32(count) > 0)
                {
                    ShowMessage("Cannot delete this programme because it has enrolled students.", "error", false, null, "Delete Blocked");
                    return;
                }

                DatabaseHelper.ExecuteNonQuery(
                    "DELETE FROM Programmes WHERE ProgrammeId = @Id",
                    new[] { new SqlParameter("@Id", programmeId) });

                ShowMessage("Programme deleted successfully!", "success", false, null, "Programme Deleted");
                LoadProgrammes();
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting programme: " + ex.Message, "error", false, null, "Delete Error");
            }
        }

        private void ClearForm()
        {
            hfProgrammeId.Value = "";
            txtProgrammeName.Text = "";
            txtProgrammeCode.Text = "";
            txtDuration.Text = "";
            txtDescription.Text = "";
            lblFormTitle.Text = "Add New Programme";
        }
        private void ShowMessage(string message, string type,
                                 bool isConfirmDelete = false, string programmeId = null,
                                 string modalTitle = null)
        {
            string safeType = NormalizeMessageType(type);
            string safeTitle = (modalTitle ?? GetDefaultModalTitle(safeType, isConfirmDelete))
                .Replace("\\", "\\\\")
                .Replace("'", "\\'");

            string safeMessage = message
                .Replace("\\", "\\\\")
                .Replace("`", "\\`")
                .Replace("${", "\\${");

            string safeProgrammeId = (programmeId ?? "")
                .Replace("\\", "\\\\")
                .Replace("'", "\\'");

            string script = $"showMessageModal('{safeType}', '{safeTitle}', `{safeMessage}`, {isConfirmDelete.ToString().ToLower()}, '{safeProgrammeId}');";
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(), script, true);
        }

        private string NormalizeMessageType(string type)
        {
            string value = (type ?? "info").ToLower();
            if (value == "danger") return "error";
            return value;
        }

        private string GetDefaultModalTitle(string type, bool isConfirmDelete)
        {
            if (isConfirmDelete) return "Confirm Delete";

            switch (type)
            {
                case "success": return "Success";
                case "error": return "Error";
                case "warning": return "Warning";
                case "delete": return "Delete";
                default: return "Message";
            }
        }

        protected void btnDeleteConfirmed_Click(object sender, EventArgs e)
        {
            if (int.TryParse(hfDeleteTarget.Value, out int programmeId))
            {
                DeleteProgramme(programmeId);
            }
        }


        protected void btnSearchProgramme_Click(object sender, EventArgs e)
        {
            gvProgrammes.PageIndex = 0;
            LoadProgrammes();
        }

        protected void btnClearProgrammeSearch_Click(object sender, EventArgs e)
        {
            txtSearchProgramme.Text = "";
            ddlFilterDuration.SelectedIndex = 0;
            gvProgrammes.PageIndex = 0;
            LoadProgrammes();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowMessage("The programme form has been cleared.", "success", false, null, "Form Cleared");
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        protected void gvProgrammes_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvProgrammes.PageIndex = e.NewPageIndex;
            LoadProgrammes();
        }
    }
}