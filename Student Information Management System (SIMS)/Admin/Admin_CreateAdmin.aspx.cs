using System;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Admin
{
    public partial class Admin_CreateAdmin : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);
        }

        protected void btnSeed_Click(object sender, EventArgs e)
        {
            string firstName = txtFirst.Text.Trim();
            string lastName = txtLast.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            pnlSuccess.Visible = false;
            pnlError.Visible = false;

            if (string.IsNullOrWhiteSpace(firstName) ||
                string.IsNullOrWhiteSpace(lastName) ||
                string.IsNullOrWhiteSpace(email) ||
                string.IsNullOrWhiteSpace(password))
            {
                ShowError("Please fill in all fields.");
                return;
            }

            if (!email.Contains("@") || !email.Contains("."))
            {
                ShowError("Please enter a valid email address.");
                return;
            }

            if (password.Length < 8)
            {
                ShowError("Password must be at least 8 characters.");
                return;
            }

            try
            {
                object exists = DatabaseHelper.ExecuteScalar(
                    "SELECT COUNT(1) FROM Users WHERE LOWER(Email) = @Email",
                    new[] { new SqlParameter("@Email", email) });

                if (Convert.ToInt32(exists) > 0)
                {
                    ShowError("An account with this email already exists.");
                    return;
                }

                string hash = PasswordHelper.HashPassword(password);

                string insertUser = @"
                    INSERT INTO Users (Email, PasswordHash, Role, IsActive)
                    VALUES (@Email, @Hash, 1, 1);
                    SELECT CAST(SCOPE_IDENTITY() AS INT);";

                int userId = Convert.ToInt32(DatabaseHelper.ExecuteScalar(insertUser, new[]
                {
                    new SqlParameter("@Email", email),
                    new SqlParameter("@Hash", hash)
                }));

                string hopId = "HOP" + userId.ToString("D3");

                string insertHoP = @"
                    INSERT INTO HoPDetails (HoPId, UserId, FirstName, LastName)
                    VALUES (@HoPId, @UserId, @FirstName, @LastName)";

                DatabaseHelper.ExecuteNonQuery(insertHoP, new[]
                {
                    new SqlParameter("@HoPId", hopId),
                    new SqlParameter("@UserId", userId),
                    new SqlParameter("@FirstName", firstName),
                    new SqlParameter("@LastName", lastName)
                });

                ClearForm();

                pnlSuccess.Visible = true;
                lblSuccess.Text = "Admin account created successfully for <strong>"
                    + HttpUtility.HtmlEncode(firstName + " " + lastName)
                    + "</strong> (" + HttpUtility.HtmlEncode(email) + ").";
            }
            catch (Exception ex)
            {
                ShowError("Error creating admin account: " + ex.Message);
            }
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
            lblError.Text = HttpUtility.HtmlEncode(message);
        }

        private void ClearForm()
        {
            txtFirst.Text = "";
            txtLast.Text = "";
            txtEmail.Text = "";
            txtPassword.Text = "";
        }
    }
}
