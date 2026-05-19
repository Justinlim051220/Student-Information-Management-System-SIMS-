using System;
using System.Data.SqlClient;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class SeedAdmin : Page
    {
        protected void btnSeed_Click(object sender, EventArgs e)
        {
            string firstName = txtFirst.Text.Trim();
            string lastName = txtLast.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            // Basic validation
            if (string.IsNullOrWhiteSpace(firstName) ||
                string.IsNullOrWhiteSpace(lastName) ||
                string.IsNullOrWhiteSpace(email) ||
                password.Length < 8)
            {
                pnlError.Visible = true;
                pnlSuccess.Visible = false;
                lblError.Text = "Please fill in all fields. Password must be at least 8 characters.";
                return;
            }

            try
            {
                // Check if email already exists
                object exists = DatabaseHelper.ExecuteScalar(
                    "SELECT COUNT(1) FROM Users WHERE LOWER(Email) = @Email",
                    new[] { new SqlParameter("@Email", email) });

                if (Convert.ToInt32(exists) > 0)
                {
                    pnlError.Visible = true;
                    pnlSuccess.Visible = false;
                    lblError.Text = "An account with that email already exists.";
                    return;
                }

                // Hash the password
                string hash = PasswordHelper.HashPassword(password);

                // Insert into Users table (Role 1 = Admin/HoP)
                string insertUser = @"
                    INSERT INTO Users (Email, PasswordHash, Role, IsActive)
                    VALUES (@Email, @Hash, 1, 1);
                    SELECT SCOPE_IDENTITY();";

                object newId = DatabaseHelper.ExecuteScalar(insertUser, new[]
                {
                    new SqlParameter("@Email", email),
                    new SqlParameter("@Hash",  hash)
                });

                int userId = Convert.ToInt32(newId);

                // Insert into HoPDetails table
                string insertHoP = @"
                    INSERT INTO HoPDetails (UserId, FirstName, LastName)
                    VALUES (@Uid, @First, @Last)";

                DatabaseHelper.ExecuteNonQuery(insertHoP, new[]
                {
                    new SqlParameter("@Uid",   userId),
                    new SqlParameter("@First", firstName),
                    new SqlParameter("@Last",  lastName)
                });

                pnlSuccess.Visible = true;
                pnlError.Visible = false;
                lblSuccess.Text = $"✅ Admin account created for {firstName} {lastName} ({email}). " +
                                      "You can now log in. <strong>Delete this page immediately!</strong>";
                btnSeed.Enabled = false;
            }
            catch (Exception ex)
            {
                pnlError.Visible = true;
                pnlSuccess.Visible = false;
                lblError.Text = "Error: " + ex.Message;
            }
        }
    }
}