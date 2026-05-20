using System;
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
                GenerateStudentId();
                LoadProgrammes();
            }
        }

        private void GenerateStudentId()
        {
            try
            {
                string sql = "SELECT TOP 1 StudentId FROM StudentDetails ORDER BY StudentId DESC";
                object lastId = DatabaseHelper.ExecuteScalar(sql);

                string newId = "M1000001";

                if (lastId != null)
                {
                    string last = lastId.ToString();
                    if (last.StartsWith("M") && int.TryParse(last.Substring(1), out int num))
                    {
                        newId = "M" + (num + 1).ToString("D7");
                    }
                }

                txtStudentId.Text = newId;
            }
            catch
            {
                txtStudentId.Text = "M1000001"; // fallback
            }
        }

        private void LoadProgrammes()
        {
            try
            {
                string sql = @"
                    SELECT ProgrammeId, 
                           ProgrammeName + ' (' + ProgrammeCode + ')' AS Display 
                    FROM Programmes 
                    ORDER BY ProgrammeName";

                var dt = DatabaseHelper.ExecuteQuery(sql);

                ddlProgramme.DataSource = dt;
                ddlProgramme.DataTextField = "Display";
                ddlProgramme.DataValueField = "ProgrammeId";
                ddlProgramme.DataBind();

                ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
            }
            catch (Exception ex)
            {
                // If table is empty or doesn't exist yet
                ddlProgramme.Items.Clear();
                ddlProgramme.Items.Insert(0, new ListItem("No programmes found - Please create one first", ""));
                System.Diagnostics.Debug.WriteLine("LoadProgrammes Error: " + ex.Message);
            }
        }

        protected void btnAddStudent_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFirstName.Text) ||
                string.IsNullOrWhiteSpace(txtLastName.Text) ||
                string.IsNullOrWhiteSpace(txtEmail.Text) ||
                string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue))
            {
                ShowMessage("Please fill in all required fields and select a programme.", "danger");
                return;
            }

            try
            {
                string passwordHash = PasswordHelper.HashPassword(txtPassword.Text.Trim());

                // Create User
                string insertUser = @"
                    INSERT INTO Users (Email, PasswordHash, Role, IsActive) 
                    OUTPUT INSERTED.UserId 
                    VALUES (@Email, @Hash, 3, 1)";

                int userId = Convert.ToInt32(DatabaseHelper.ExecuteScalar(insertUser, new[]
                {
                    new SqlParameter("@Email", txtEmail.Text.Trim().ToLower()),
                    new SqlParameter("@Hash", passwordHash)
                }));

                // Create Student
                string insertStudent = @"
                    INSERT INTO StudentDetails 
                    (StudentId, UserId, FirstName, LastName, DateOfBirth, Gender, 
                     Phone, Address, EnrollmentDate, ProgrammeId)
                    VALUES 
                    (@StudentId, @UserId, @FirstName, @LastName, @Dob, @Gender, 
                     @Phone, @Address, GETDATE(), @ProgrammeId)";

                DatabaseHelper.ExecuteNonQuery(insertStudent, new[]
                {
                    new SqlParameter("@StudentId", txtStudentId.Text),
                    new SqlParameter("@UserId", userId),
                    new SqlParameter("@FirstName", txtFirstName.Text.Trim()),
                    new SqlParameter("@LastName", txtLastName.Text.Trim()),
                    new SqlParameter("@Dob", string.IsNullOrEmpty(txtDob.Text) ? DBNull.Value : (object)DateTime.Parse(txtDob.Text)),
                    new SqlParameter("@Gender", ddlGender.SelectedValue),
                    new SqlParameter("@Phone", txtPhone.Text.Trim()),
                    new SqlParameter("@Address", txtAddress.Text.Trim()),
                    new SqlParameter("@ProgrammeId", int.Parse(ddlProgramme.SelectedValue))
                });

                ShowMessage($"✅ Student {txtStudentId.Text} added successfully!", "success");

                ClearForm();
                GenerateStudentId();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "danger");
            }
        }

        private void ClearForm()
        {
            txtFirstName.Text = txtLastName.Text = txtEmail.Text = txtPassword.Text =
            txtDob.Text = txtPhone.Text = txtAddress.Text = "";
            ddlGender.SelectedIndex = 0;
            ddlProgramme.SelectedIndex = 0;
        }

        private void ShowMessage(string text, string type)
        {
            lblMessage.Text = text;
            lblMessage.CssClass = $"alert alert-{type}";
            lblMessage.Visible = true;
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Admin/Dashboard.aspx");
        }
    }
}