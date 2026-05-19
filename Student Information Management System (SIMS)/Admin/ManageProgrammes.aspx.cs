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
            string sql = @"
                SELECT p.ProgrammeId, p.ProgrammeName, p.ProgrammeCode, p.Duration, p.Description
                FROM Programmes p
                ORDER BY p.ProgrammeName";

            gvProgrammes.DataSource = DatabaseHelper.ExecuteQuery(sql);
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
                ShowMessage("Please fill in all required fields.", "danger");
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

                    ShowMessage("✅ Programme added successfully!", "success");
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

                    ShowMessage("✅ Programme updated successfully!", "success");
                }

                ClearForm();
                LoadProgrammes();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "danger");
            }
        }

        protected void gvProgrammes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int programmeId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Edit")
            {
                LoadProgrammeForEdit(programmeId);
            }
            else if (e.CommandName == "Delete")
            {
                DeleteProgramme(programmeId);
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
                    ShowMessage("Cannot delete: This programme has enrolled students.", "danger");
                    return;
                }

                DatabaseHelper.ExecuteNonQuery(
                    "DELETE FROM Programmes WHERE ProgrammeId = @Id",
                    new[] { new SqlParameter("@Id", programmeId) });

                ShowMessage("✅ Programme deleted successfully.", "success");
                LoadProgrammes();
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting programme: " + ex.Message, "danger");
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

        private void ShowMessage(string text, string type)
        {
            lblMessage.Text = text;
            lblMessage.CssClass = $"alert alert-{type}";
            lblMessage.Visible = true;
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