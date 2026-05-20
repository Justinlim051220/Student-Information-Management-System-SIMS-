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
            ddlProgramme.DataSource = DatabaseHelper.ExecuteQuery(sql);
            ddlProgramme.DataTextField = "ProgrammeName";
            ddlProgramme.DataValueField = "ProgrammeId";
            ddlProgramme.DataBind();
        }

        private void GenerateNextLecturerId()
        {
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT TOP 1 LecturerId FROM LecturerDetails ORDER BY LecturerId DESC");

            if (result == null)
            {
                txtLecturerId.Text = "LEC001";
            }
            else
            {
                string lastId = result.ToString();
                if (lastId.StartsWith("LEC") && int.TryParse(lastId.Substring(3), out int num))
                {
                    txtLecturerId.Text = $"LEC{(num + 1):D3}";
                }
                else
                {
                    txtLecturerId.Text = "LEC001";
                }
            }
        }

        private void LoadLecturers()
        {
            string sql = @"
        SELECT ld.LecturerId, 
               ld.FirstName + ' ' + ld.LastName AS FullName,
               u.Email, 
               ld.Phone, 
               p.ProgrammeName,
               ld.Specialization
        FROM LecturerDetails ld
        INNER JOIN Users u ON ld.UserId = u.UserId
        LEFT JOIN Programmes p ON ld.ProgrammeId = p.ProgrammeId
        ORDER BY ld.FirstName, ld.LastName";

            gvLecturers.DataSource = DatabaseHelper.ExecuteQuery(sql);
            gvLecturers.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFirstName.Text) ||
                string.IsNullOrWhiteSpace(txtLastName.Text) ||
                string.IsNullOrWhiteSpace(txtEmail.Text) ||
                string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            {
                ShowMessage("Please fill in all required fields.", "danger");
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

                    // 2. Create LecturerDetails
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
                        new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue),
                        new SqlParameter("@Spec", txtSpecialization.Text.Trim())
                    });

                    ShowMessage("✅ Lecturer added successfully!<br><strong>Default Password:</strong> Lecturer@123", "success");
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
                        new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue),
                        new SqlParameter("@Spec", txtSpecialization.Text.Trim()),
                        new SqlParameter("@LecId", hfLecturerId.Value)
                    });

                    // Update email
                    DatabaseHelper.ExecuteNonQuery(
                        "UPDATE Users SET Email = @Email WHERE UserId = @UserId",
                        new[]
                        {
                            new SqlParameter("@Email", txtEmail.Text.Trim().ToLower()),
                            new SqlParameter("@UserId", hfUserId.Value)
                        });

                    ShowMessage("✅ Lecturer updated successfully!", "success");
                }

                ClearForm();
                LoadLecturers();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "danger");
            }
        }

        protected void gvLecturers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string lecturerId = e.CommandArgument.ToString();

            if (e.CommandName == "Edit")
            {
                LoadLecturerForEdit(lecturerId);
            }
            else if (e.CommandName == "Delete")
            {
                DeleteLecturer(lecturerId);
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

                if (row["ProgrammeId"] != DBNull.Value)
                {
                    ddlProgramme.SelectedValue = row["ProgrammeId"].ToString();
                }

                lblFormTitle.Text = "Edit Lecturer";
            }
        }

        private void DeleteLecturer(string lecturerId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery(
                    "DELETE FROM LecturerDetails WHERE LecturerId = @Id",
                    new[] { new SqlParameter("@Id", lecturerId) });

                ShowMessage("✅ Lecturer deleted successfully.", "success");
                LoadLecturers();
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting lecturer: " + ex.Message, "danger");
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
            ddlProgramme.ClearSelection();
            lblFormTitle.Text = "Add New Lecturer";

            GenerateNextLecturerId();
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

        protected void gvLecturers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvLecturers.PageIndex = e.NewPageIndex;
            LoadLecturers();
        }
    }
}