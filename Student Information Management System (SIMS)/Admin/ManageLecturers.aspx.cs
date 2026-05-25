using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Admin
{
    public partial class ManageLecturers : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                LoadProgrammes();
                GenerateNextLecturerId();
                LoadLecturers();
            }
        }

        private void LoadProgrammes()
        {
            string sql = "SELECT ProgrammeId, ProgrammeName FROM Programmes ORDER BY ProgrammeName";
            DataTable programmes = DatabaseHelper.ExecuteQuery(sql);

            cblProgrammes.DataSource = programmes;
            cblProgrammes.DataTextField = "ProgrammeName";
            cblProgrammes.DataValueField = "ProgrammeId";
            cblProgrammes.DataBind();

            ddlFilterProgramme.DataSource = programmes.Copy();
            ddlFilterProgramme.DataTextField = "ProgrammeName";
            ddlFilterProgramme.DataValueField = "ProgrammeId";
            ddlFilterProgramme.DataBind();
            ddlFilterProgramme.Items.Insert(0, new ListItem("All Programmes", ""));
        }

        private void GenerateNextLecturerId()
        {
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT TOP 1 LecturerId FROM LecturerDetails ORDER BY LecturerId DESC");

            if (result == null)
                txtLecturerId.Text = "LEC001";
            else
            {
                string lastId = result.ToString();
                if (lastId.StartsWith("LEC") && int.TryParse(lastId.Substring(3), out int num))
                    txtLecturerId.Text = $"LEC{(num + 1):D3}";
                else
                    txtLecturerId.Text = "LEC001";
            }
        }

        private void LoadLecturers()
        {
            string keyword = txtSearchLecturer.Text.Trim();
            string programmeId = ddlFilterProgramme.SelectedValue;

            string sql = @"
                SELECT ld.LecturerId,
                       ld.FirstName + ' ' + ld.LastName AS FullName,
                       u.Email,
                       ld.Phone,
                       ISNULL(STUFF((
                           SELECT ', ' + p2.ProgrammeName
                           FROM LecturerProgramme lp2
                           INNER JOIN Programmes p2 ON lp2.ProgrammeId = p2.ProgrammeId
                           WHERE lp2.LecturerId = ld.LecturerId
                           ORDER BY p2.ProgrammeName
                           FOR XML PATH(''), TYPE
                       ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''), '-') AS ProgrammeNames,
                       ld.Specialization
                FROM LecturerDetails ld
                INNER JOIN Users u ON ld.UserId = u.UserId
                WHERE (@ProgrammeId = '' OR EXISTS (
                           SELECT 1
                           FROM LecturerProgramme lpFilter
                           WHERE lpFilter.LecturerId = ld.LecturerId
                           AND lpFilter.ProgrammeId = @ProgrammeId
                       ))
                  AND (@Keyword = ''
                       OR ld.LecturerId LIKE '%' + @Keyword + '%'
                       OR ld.FirstName LIKE '%' + @Keyword + '%'
                       OR ld.LastName LIKE '%' + @Keyword + '%'
                       OR (ld.FirstName + ' ' + ld.LastName) LIKE '%' + @Keyword + '%'
                       OR u.Email LIKE '%' + @Keyword + '%'
                       OR ld.Phone LIKE '%' + @Keyword + '%'
                       OR ld.Specialization LIKE '%' + @Keyword + '%'
                       OR EXISTS (
                           SELECT 1
                           FROM LecturerProgramme lpSearch
                           INNER JOIN Programmes pSearch ON lpSearch.ProgrammeId = pSearch.ProgrammeId
                           WHERE lpSearch.LecturerId = ld.LecturerId
                           AND pSearch.ProgrammeName LIKE '%' + @Keyword + '%'
                       ))
                ORDER BY ld.FirstName, ld.LastName";

            gvLecturers.DataSource = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@Keyword", keyword),
                new SqlParameter("@ProgrammeId", programmeId)
            });
            gvLecturers.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFirstName.Text) ||
                string.IsNullOrWhiteSpace(txtLastName.Text) ||
                string.IsNullOrWhiteSpace(txtEmail.Text) ||
                !HasSelectedProgramme())
            {
                ShowMessage("Please fill in all required fields.", "error", false, null, "Validation Error");
                return;
            }

            try
            {
                if (string.IsNullOrEmpty(hfLecturerId.Value)) // === ADD NEW ===
                {
                    string passwordHash = PasswordHelper.HashPassword("Lecturer@123");

                    // 1. Create User
                    string userSql = @"
                INSERT INTO Users (Email, PasswordHash, Role, IsActive)
                VALUES (@Email, @Hash, 2, 1);
                SELECT SCOPE_IDENTITY();";

                    int userId = Convert.ToInt32(DatabaseHelper.ExecuteScalar(userSql, new[]
                    {
                new SqlParameter("@Email", txtEmail.Text.Trim().ToLower()),
                new SqlParameter("@Hash", passwordHash)
            }));

                    // 2. Create Lecturer
                    string lecSql = @"
                INSERT INTO LecturerDetails 
                (LecturerId, UserId, FirstName, LastName, Phone, 
                 ProgrammeId, Specialization, JoinDate)
                VALUES 
                (@LecId, @UserId, @FName, @LName, @Phone, 
                 @ProgrammeId, @Spec, GETDATE())";

                    DatabaseHelper.ExecuteNonQuery(lecSql, new[]
                    {
                new SqlParameter("@LecId", txtLecturerId.Text.Trim()),
                new SqlParameter("@UserId", userId),
                new SqlParameter("@FName", txtFirstName.Text.Trim()),
                new SqlParameter("@LName", txtLastName.Text.Trim()),
                new SqlParameter("@Phone", txtPhone.Text.Trim()),
                new SqlParameter("@ProgrammeId", GetFirstSelectedProgrammeId()),
                new SqlParameter("@Spec", string.IsNullOrWhiteSpace(txtSpecialization.Text)
                    ? (object)DBNull.Value : txtSpecialization.Text.Trim())
            });

                    SaveLecturerProgrammes(txtLecturerId.Text.Trim());

                    ShowMessage("Lecturer added successfully!<br><br>" +
                               "<strong>Default Password:</strong> Lecturer@123<br><br>" +
                               "The lecturer can use <strong>Forgot Password</strong> to change it.",
                               "success", false, null, "Lecturer Added");
                }
                else // === UPDATE ===
                {
                    string updateSql = @"
                UPDATE LecturerDetails 
                SET FirstName = @FName,
                    LastName = @LName,
                    Phone = @Phone,
                    ProgrammeId = @ProgrammeId,
                    Specialization = @Spec
                WHERE LecturerId = @LecId";

                    DatabaseHelper.ExecuteNonQuery(updateSql, new[]
                    {
                new SqlParameter("@FName", txtFirstName.Text.Trim()),
                new SqlParameter("@LName", txtLastName.Text.Trim()),
                new SqlParameter("@Phone", txtPhone.Text.Trim()),
                new SqlParameter("@ProgrammeId", GetFirstSelectedProgrammeId()),
                new SqlParameter("@Spec", string.IsNullOrWhiteSpace(txtSpecialization.Text)
                    ? (object)DBNull.Value : txtSpecialization.Text.Trim()),
                new SqlParameter("@LecId", hfLecturerId.Value)
            });

                    SaveLecturerProgrammes(hfLecturerId.Value);

                    DatabaseHelper.ExecuteNonQuery(
                        "UPDATE Users SET Email = @Email WHERE UserId = @UserId",
                        new[]
                        {
                    new SqlParameter("@Email", txtEmail.Text.Trim().ToLower()),
                    new SqlParameter("@UserId", hfUserId.Value)
                        });

                    ShowMessage("Lecturer updated successfully!", "success", false, null, "Lecturer Updated");
                }

                ClearForm();
                LoadLecturers();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "error", false, null, "Error");
            }
        }

        protected void gvLecturers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string lecturerId = e.CommandArgument.ToString();

            if (e.CommandName == "EditLecturer")
            {
                LoadLecturerForEdit(lecturerId);
            }
            else if (e.CommandName == "DeleteLecturer")
            {
                ShowMessage(
                    $"Are you sure you want to delete Lecturer <strong>{lecturerId}</strong>?<br><br>This action cannot be undone.",
                    "delete",
                    true,
                    lecturerId,
                    "Delete Lecturer?");
            }
        }

        protected void DeleteLecturerConfirmed(string lecturerId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery(
                    "DELETE FROM LecturerProgramme WHERE LecturerId = @Id",
                    new[] { new SqlParameter("@Id", lecturerId) });

                DatabaseHelper.ExecuteNonQuery(
                    "DELETE FROM LecturerDetails WHERE LecturerId = @Id",
                    new[] { new SqlParameter("@Id", lecturerId) });

                ShowMessage("Lecturer deleted successfully!", "success", false, null, "Lecturer Deleted");
                LoadLecturers();
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting lecturer: " + ex.Message, "error", false, null, "Delete Error");
            }
        }

        private void LoadLecturerForEdit(string lecturerId)
        {
            string sql = @"
                SELECT ld.*, u.Email, u.UserId 
                FROM LecturerDetails ld
                INNER JOIN Users u ON ld.UserId = u.UserId
                WHERE ld.LecturerId = @Id";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@Id", lecturerId) });

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                hfLecturerId.Value = row["LecturerId"].ToString();
                hfUserId.Value = row["UserId"].ToString();

                txtFirstName.Text = row["FirstName"].ToString();
                txtLastName.Text = row["LastName"].ToString();
                txtLecturerId.Text = row["LecturerId"].ToString();
                txtEmail.Text = row["Email"].ToString();
                txtPhone.Text = row["Phone"]?.ToString() ?? "";
                txtSpecialization.Text = row["Specialization"]?.ToString() ?? "";

                LoadLecturerProgrammeSelections(lecturerId);

                lblFormTitle.Text = "Edit Lecturer";
                ShowMessage("You are now editing the selected lecturer record.", "warning", false, null, "Edit Mode");
            }
        }

        private bool HasSelectedProgramme()
        {
            foreach (ListItem item in cblProgrammes.Items)
            {
                if (item.Selected)
                    return true;
            }
            return false;
        }

        private object GetFirstSelectedProgrammeId()
        {
            foreach (ListItem item in cblProgrammes.Items)
            {
                if (item.Selected)
                    return item.Value;
            }
            return DBNull.Value;
        }

        private void SaveLecturerProgrammes(string lecturerId)
        {
            DatabaseHelper.ExecuteNonQuery(
                "DELETE FROM LecturerProgramme WHERE LecturerId = @LecturerId",
                new[] { new SqlParameter("@LecturerId", lecturerId) });

            foreach (ListItem item in cblProgrammes.Items)
            {
                if (!item.Selected)
                    continue;

                DatabaseHelper.ExecuteNonQuery(
                    @"INSERT INTO LecturerProgramme (LecturerId, ProgrammeId)
                      VALUES (@LecturerId, @ProgrammeId)",
                    new[]
                    {
                        new SqlParameter("@LecturerId", lecturerId),
                        new SqlParameter("@ProgrammeId", item.Value)
                    });
            }
        }

        private void LoadLecturerProgrammeSelections(string lecturerId)
        {
            cblProgrammes.ClearSelection();

            DataTable dt = DatabaseHelper.ExecuteQuery(
                "SELECT ProgrammeId FROM LecturerProgramme WHERE LecturerId = @LecturerId",
                new[] { new SqlParameter("@LecturerId", lecturerId) });

            foreach (DataRow row in dt.Rows)
            {
                ListItem item = cblProgrammes.Items.FindByValue(row["ProgrammeId"].ToString());
                if (item != null)
                    item.Selected = true;
            }
        }

        private void ClearForm()
        {
            hfLecturerId.Value = "";
            hfUserId.Value = "";
            txtFirstName.Text = "";
            txtLastName.Text = "";
            txtEmail.Text = "";
            txtPhone.Text = "";
            txtSpecialization.Text = "";
            cblProgrammes.ClearSelection();
            lblFormTitle.Text = "Add New Lecturer";

            GenerateNextLecturerId();
        }
        private void ShowMessage(string message, string type,
                                 bool isConfirmDelete = false, string lecturerId = null,
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

            string safeLecturerId = (lecturerId ?? "")
                .Replace("\\", "\\\\")
                .Replace("'", "\\'");

            string script = $"showMessageModal('{safeType}', '{safeTitle}', `{safeMessage}`, {isConfirmDelete.ToString().ToLower()}, '{safeLecturerId}');";
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
            string lecturerId = hfDeleteTarget.Value;
            if (!string.IsNullOrEmpty(lecturerId))
                DeleteLecturerConfirmed(lecturerId);
        }


        protected void btnSearchLecturer_Click(object sender, EventArgs e)
        {
            gvLecturers.PageIndex = 0;
            LoadLecturers();
        }

        protected void btnClearLecturerSearch_Click(object sender, EventArgs e)
        {
            txtSearchLecturer.Text = "";
            ddlFilterProgramme.SelectedIndex = 0;
            gvLecturers.PageIndex = 0;
            LoadLecturers();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowMessage("The lecturer form has been cleared.", "success", false, null, "Form Cleared");
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        protected void gvLecturers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvLecturers.PageIndex = e.NewPageIndex;
            LoadLecturers();
        }
    }
}