using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Admin
{
    public partial class ManageStudents : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                LoadProgrammes();
                GenerateStudentId();
                LoadStudents();
            }
        }

        // ── Helpers ────────────────────────────────────────────────────────────

        private void LoadProgrammes()
        {
            try
            {
                string sql = @"
                    SELECT ProgrammeId,
                           ProgrammeName + ' (' + ProgrammeCode + ')' AS Display
                    FROM Programmes
                    ORDER BY ProgrammeName";

                ddlProgramme.DataSource = DatabaseHelper.ExecuteQuery(sql);
                ddlProgramme.DataTextField = "Display";
                ddlProgramme.DataValueField = "ProgrammeId";
                ddlProgramme.DataBind();
                ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
            }
            catch
            {
                ddlProgramme.Items.Clear();
                ddlProgramme.Items.Insert(0, new ListItem("No programmes found", ""));
            }
        }

        private void GenerateStudentId()
        {
            try
            {
                object lastId = DatabaseHelper.ExecuteScalar(
                    "SELECT TOP 1 StudentId FROM StudentDetails ORDER BY StudentId DESC");

                string newId = "M1000001";
                if (lastId != null)
                {
                    string last = lastId.ToString();
                    if (last.StartsWith("M") && int.TryParse(last.Substring(1), out int num))
                        newId = "M" + (num + 1).ToString("D7");
                }
                txtStudentId.Text = newId;
            }
            catch
            {
                txtStudentId.Text = "M1000001";
            }
        }

        private void LoadStudents()
        {
            string sql = @"
                SELECT sd.StudentId,
                       sd.FirstName + ' ' + sd.LastName AS FullName,
                       u.Email,
                       sd.Phone,
                       p.ProgrammeName,
                       sd.Gender
                FROM StudentDetails sd
                INNER JOIN Users u  ON sd.UserId    = u.UserId
                LEFT  JOIN Programmes p ON sd.ProgrammeId = p.ProgrammeId
                ORDER BY sd.FirstName, sd.LastName";

            gvStudents.DataSource = DatabaseHelper.ExecuteQuery(sql);
            gvStudents.DataBind();
        }

        // ── Save (Add / Edit) ──────────────────────────────────────────────────

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFirstName.Text) ||
                string.IsNullOrWhiteSpace(txtLastName.Text) ||
                string.IsNullOrWhiteSpace(txtEmail.Text) ||
                string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            {
                ShowMessage("Please fill in all required fields.", "error");
                return;
            }

            try
            {
                if (string.IsNullOrEmpty(hfStudentId.Value))   // ── ADD NEW ──
                {
                    string passwordHash = PasswordHelper.HashPassword("Student@123");

                    // 1. Create User
                    string userSql = @"
                        INSERT INTO Users (Email, PasswordHash, Role, IsActive)
                        OUTPUT INSERTED.UserId
                        VALUES (@Email, @Hash, 3, 1)";

                    int userId = Convert.ToInt32(DatabaseHelper.ExecuteScalar(userSql, new[]
                    {
                        new SqlParameter("@Email", txtEmail.Text.Trim().ToLower()),
                        new SqlParameter("@Hash",  passwordHash)
                    }));

                    // 2. Create Student
                    string stuSql = @"
                        INSERT INTO StudentDetails
                            (StudentId, UserId, FirstName, LastName, DateOfBirth,
                             Gender, Phone, Address, EnrollmentDate, ProgrammeId)
                        VALUES
                            (@StudentId, @UserId, @FName, @LName, @Dob,
                             @Gender, @Phone, @Address, GETDATE(), @ProgrammeId)";

                    DatabaseHelper.ExecuteNonQuery(stuSql, new[]
                    {
                        new SqlParameter("@StudentId", txtStudentId.Text.Trim()),
                        new SqlParameter("@UserId",    userId),
                        new SqlParameter("@FName",     txtFirstName.Text.Trim()),
                        new SqlParameter("@LName",     txtLastName.Text.Trim()),
                        new SqlParameter("@Dob",       string.IsNullOrEmpty(txtDob.Text)
                                                           ? (object)DBNull.Value
                                                           : DateTime.Parse(txtDob.Text)),
                        new SqlParameter("@Gender",    ddlGender.SelectedValue),
                        new SqlParameter("@Phone",     txtPhone.Text.Trim()),
                        new SqlParameter("@Address",   txtAddress.Text.Trim()),
                        new SqlParameter("@ProgrammeId", int.Parse(ddlProgramme.SelectedValue))
                    });

                    ShowMessage("Student added successfully!<br><br>" +
                                "<strong>Default Password:</strong> Student@123<br><br>" +
                                "The student can use <strong>Forgot Password</strong> to change it.",
                                "success");
                }
                else   // ── UPDATE ──
                {
                    string updateSql = @"
                        UPDATE StudentDetails
                        SET FirstName   = @FName,
                            LastName    = @LName,
                            DateOfBirth = @Dob,
                            Gender      = @Gender,
                            Phone       = @Phone,
                            Address     = @Address,
                            ProgrammeId = @ProgrammeId
                        WHERE StudentId = @StudentId";

                    DatabaseHelper.ExecuteNonQuery(updateSql, new[]
                    {
                        new SqlParameter("@FName",     txtFirstName.Text.Trim()),
                        new SqlParameter("@LName",     txtLastName.Text.Trim()),
                        new SqlParameter("@Dob",       string.IsNullOrEmpty(txtDob.Text)
                                                           ? (object)DBNull.Value
                                                           : DateTime.Parse(txtDob.Text)),
                        new SqlParameter("@Gender",    ddlGender.SelectedValue),
                        new SqlParameter("@Phone",     txtPhone.Text.Trim()),
                        new SqlParameter("@Address",   txtAddress.Text.Trim()),
                        new SqlParameter("@ProgrammeId", int.Parse(ddlProgramme.SelectedValue)),
                        new SqlParameter("@StudentId", hfStudentId.Value)
                    });

                    DatabaseHelper.ExecuteNonQuery(
                        "UPDATE Users SET Email = @Email WHERE UserId = @UserId",
                        new[]
                        {
                            new SqlParameter("@Email",  txtEmail.Text.Trim().ToLower()),
                            new SqlParameter("@UserId", hfUserId.Value)
                        });

                    ShowMessage("Student updated successfully!", "success");
                }

                ClearForm();
                LoadStudents();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "error");
            }
        }

        // ── GridView events ────────────────────────────────────────────────────

        protected void gvStudents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string studentId = e.CommandArgument.ToString();

            if (e.CommandName == "EditStudent")
            {
                LoadStudentForEdit(studentId);
            }
            else if (e.CommandName == "DeleteStudent")
            {
                ShowMessage(
                    $"Are you sure you want to delete Student {studentId}? This action cannot be undone.",
                    "warning",
                    true,
                    studentId);
            }
        }

        protected void gvStudents_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvStudents.PageIndex = e.NewPageIndex;
            LoadStudents();
        }

        protected void btnDeleteConfirmed_Click(object sender, EventArgs e)
        {
            string studentId = hfDeleteTarget.Value;
            if (!string.IsNullOrEmpty(studentId))
                DeleteStudentConfirmed(studentId);
        }

        private void DeleteStudentConfirmed(string studentId)
        {
            try
            {
                // Delete student record (cascade or delete user after)
                object userId = DatabaseHelper.ExecuteScalar(
                    "SELECT UserId FROM StudentDetails WHERE StudentId = @Id",
                    new[] { new SqlParameter("@Id", studentId) });

                DatabaseHelper.ExecuteNonQuery(
                    "DELETE FROM StudentDetails WHERE StudentId = @Id",
                    new[] { new SqlParameter("@Id", studentId) });

                if (userId != null)
                    DatabaseHelper.ExecuteNonQuery(
                        "DELETE FROM Users WHERE UserId = @UserId",
                        new[] { new SqlParameter("@UserId", userId) });

                ShowMessage("Student deleted successfully!", "success");
                LoadStudents();
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting student: " + ex.Message, "error");
            }
        }

        // ── Edit ────────────────────────────────────────────────────────────────

        private void LoadStudentForEdit(string studentId)
        {
            string sql = @"
                SELECT sd.*, u.Email, u.UserId
                FROM StudentDetails sd
                INNER JOIN Users u ON sd.UserId = u.UserId
                WHERE sd.StudentId = @Id";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql,
                new[] { new SqlParameter("@Id", studentId) });

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];

                hfStudentId.Value = row["StudentId"].ToString();
                hfUserId.Value = row["UserId"].ToString();

                txtStudentId.Text = row["StudentId"].ToString();
                txtFirstName.Text = row["FirstName"].ToString();
                txtLastName.Text = row["LastName"].ToString();
                txtEmail.Text = row["Email"].ToString();
                txtPhone.Text = row["Phone"]?.ToString() ?? "";
                txtAddress.Text = row["Address"]?.ToString() ?? "";

                if (row["DateOfBirth"] != DBNull.Value)
                    txtDob.Text = Convert.ToDateTime(row["DateOfBirth"]).ToString("yyyy-MM-dd");
                else
                    txtDob.Text = "";

                ddlGender.SelectedValue = row["Gender"]?.ToString() ?? "";

                if (row["ProgrammeId"] != DBNull.Value)
                    ddlProgramme.SelectedValue = row["ProgrammeId"].ToString();

                lblFormTitle.Text = "Edit Student";
            }
        }

        // ── Form helpers ────────────────────────────────────────────────────────

        private void ClearForm()
        {
            hfStudentId.Value = "";
            hfUserId.Value = "";

            txtFirstName.Text = "";
            txtLastName.Text = "";
            txtEmail.Text = "";
            txtPhone.Text = "";
            txtAddress.Text = "";
            txtDob.Text = "";

            ddlGender.SelectedIndex = 0;
            ddlProgramme.SelectedIndex = 0;

            lblFormTitle.Text = "Add New Student";
            GenerateStudentId();
        }

        private void ShowMessage(string message, string type,
                                 bool isConfirmDelete = false, string studentId = null)
        {
            string safeMessage = message.Replace("\\", "\\\\").Replace("`", "\\`");
            string safeStudentId = (studentId ?? "").Replace("'", "\\'");

            string script = $"showMessageModal('{type}', `{safeMessage}`, {isConfirmDelete.ToString().ToLower()}, '{safeStudentId}');";

            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "CustomModal" + Guid.NewGuid().ToString("N"), script, true);
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Admin/Dashboard.aspx");
        }
    }
}