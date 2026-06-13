using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class SystemSetup : Page
    {
        private const string VerificationSessionKey = "SIMS_SystemSetup_AdminVerified";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ConfigurePageMode();
            }
        }

        private void ConfigurePageMode()
        {
            int adminCount = GetAdminCount();
            bool noAdminExists = adminCount == 0;
            bool adminVerified = IsAdminVerifiedForSetup();

            pnlSuccess.Visible = false;
            pnlError.Visible = false;
            pnlLocked.Visible = false;

            if (noAdminExists)
            {
                lblModeTitle.Text = "First Admin Setup";
                lblModeSubtitle.Text = "No administrator account exists yet. Create the first Head of Programme / Administrator account.";
                pnlVerifyAdmin.Visible = false;
                pnlSetupForm.Visible = true;
                return;
            }

            if (adminVerified)
            {
                lblModeTitle.Text = "Create Additional Admin";
                lblModeSubtitle.Text = "Admin verification completed. You may now create another administrator account.";
                pnlVerifyAdmin.Visible = false;
                pnlSetupForm.Visible = true;
                return;
            }

            lblModeTitle.Text = "Admin Verification";
            lblModeSubtitle.Text = "An administrator already exists. Verify an existing admin before creating another admin account.";
            pnlVerifyAdmin.Visible = true;
            pnlSetupForm.Visible = false;
        }

        protected void btnVerifyAdmin_Click(object sender, EventArgs e)
        {
            string email = txtVerifyEmail.Text.Trim().ToLower();
            string password = txtVerifyPassword.Text; // Do not Trim password because it changes the hash.

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
            {
                ShowError("Please enter existing admin email and password for verification.");
                return;
            }

            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT TOP 1 UserId, Email, PasswordHash, Role, IsActive
                    FROM Users
                    WHERE LOWER(Email) = @Email
                      AND Role = 1
                      AND IsActive = 1",
                    new[] { new SqlParameter("@Email", email) });

                if (dt.Rows.Count == 0)
                {
                    ShowError("Admin verification failed. No active admin account was found for this email.");
                    return;
                }

                string storedHash = Convert.ToString(dt.Rows[0]["PasswordHash"]);

                if (!IsPasswordValid(password, storedHash))
                {
                    ShowError("Admin verification failed. Please check the admin email and password.");
                    return;
                }

                Session[VerificationSessionKey] = true;

                txtVerifyPassword.Text = string.Empty;
                txtVerifyEmail.Text = string.Empty;

                ConfigurePageMode();

                pnlSuccess.Visible = true;
                pnlError.Visible = false;
                lblSuccess.Text = "<strong>Verification successful.</strong><br/>You may now create another administrator account.";
            }
            catch (Exception ex)
            {
                ShowError("Verification failed: " + ex.Message);
            }
        }

        private bool IsPasswordValid(string inputPassword, string storedPasswordHash)
        {
            if (string.IsNullOrEmpty(inputPassword) || string.IsNullOrWhiteSpace(storedPasswordHash))
            {
                return false;
            }

            storedPasswordHash = storedPasswordHash.Trim();

            string inputHash = PasswordHelper.HashPassword(inputPassword);

            if (string.Equals(inputHash, storedPasswordHash, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            try
            {
                var verifyMethod = typeof(PasswordHelper).GetMethod(
                    "VerifyPassword",
                    new Type[] { typeof(string), typeof(string) });

                if (verifyMethod != null)
                {
                    object verified = verifyMethod.Invoke(null, new object[] { inputPassword, storedPasswordHash });
                    if (verified is bool && (bool)verified)
                    {
                        return true;
                    }

                    verified = verifyMethod.Invoke(null, new object[] { storedPasswordHash, inputPassword });
                    if (verified is bool && (bool)verified)
                    {
                        return true;
                    }
                }
            }
            catch
            {
                // If reflection fails, the normal hash check above is still used.
            }

            return false;
        }

        protected void btnSeed_Click(object sender, EventArgs e)
        {
            int adminCount = GetAdminCount();
            bool noAdminExists = adminCount == 0;
            bool adminVerified = IsAdminVerifiedForSetup();

            if (!noAdminExists && !adminVerified)
            {
                ConfigurePageMode();
                ShowError("Please verify an existing admin account before creating another administrator.");
                return;
            }

            string firstName = txtFirst.Text.Trim();
            string lastName = txtLast.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            if (string.IsNullOrWhiteSpace(firstName) ||
                string.IsNullOrWhiteSpace(lastName) ||
                string.IsNullOrWhiteSpace(email) ||
                string.IsNullOrWhiteSpace(password))
            {
                ShowError("Please fill in all required fields.");
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

                ClearCreateForm();
                ConfigurePageMode();

                pnlError.Visible = false;
                pnlSuccess.Visible = true;
                lblSuccess.Text =
                    "<strong>Admin account created successfully.</strong><br/>" +
                    "Name: " + HttpUtility.HtmlEncode(firstName + " " + lastName) + "<br/>" +
                    "Email: " + HttpUtility.HtmlEncode(email) + "<br/><br/>" +
                    "The administrator can now login to SIMS.";
            }
            catch (Exception ex)
            {
                ShowError("Setup failed: " + ex.Message);
            }
        }

        private int GetAdminCount()
        {
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(1) FROM Users WHERE Role = 1 AND IsActive = 1");

            return result == null || result == DBNull.Value ? 0 : Convert.ToInt32(result);
        }

        private bool IsAdminVerifiedForSetup()
        {
            object value = Session[VerificationSessionKey];
            return value != null && value is bool && (bool)value;
        }

        private void ClearCreateForm()
        {
            txtFirst.Text = string.Empty;
            txtLast.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtPassword.Text = string.Empty;
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
            lblError.Text = HttpUtility.HtmlEncode(message);
        }
    }
}
