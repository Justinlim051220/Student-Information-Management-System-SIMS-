using SIMS.Helpers;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

/// <summary>
/// Code-behind for ResetPassword.aspx
///
/// Flow:
///   1. On Page_Load: read ?token=&email= from query string.
///   2. Look up the token in PasswordResets — must be unused and not expired.
///   3. If valid: show the new-password form.
///   4. If invalid/expired: show the "link expired" panel.
///   5. On submit: hash the new password and UPDATE Users.PasswordHash,
///      then mark the token as used.
/// </summary>
/// 
namespace Student_Information_Management_System__SIMS_
{
    public partial class ResetPassword : Page
    {
        // ---------------------------------------------------------------
        // Page_Load
        // ---------------------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string token = Request.QueryString["token"];
                string email = Request.QueryString["email"];

                if (string.IsNullOrWhiteSpace(token) ||
                    string.IsNullOrWhiteSpace(email))
                {
                    ShowInvalid();
                    return;
                }

                // Validate token
                if (!ValidateToken(token, email))
                {
                    ShowInvalid();
                    return;
                }

                // Store in hidden fields for the postback
                hfToken.Value = token;
                hfEmail.Value = email;
                pnlForm.Visible = true;
            }
        }

        // ---------------------------------------------------------------
        // btnReset_Click — update the password.
        // ---------------------------------------------------------------
        protected void btnReset_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string token = hfToken.Value;
            string email = hfEmail.Value;
            string newPassword = txtNewPassword.Text;

            // Minimum length guard (validator handles required, but length is business rule)
            if (newPassword.Length < 8)
            {
                ShowError("Password must be at least 8 characters long.");
                return;
            }

            try
            {
                // Re-validate token (in case it expired between page load and submit)
                if (!ValidateToken(token, email))
                {
                    ShowInvalid();
                    return;
                }

                // Hash the new password
                string newHash = PasswordHelper.HashPassword(newPassword);

                // Update the Users table
                string updateSql = @"
                    UPDATE Users
                    SET    PasswordHash = @Hash
                    WHERE  LOWER(Email) = LOWER(@Email)";

                SqlParameter[] pUpdate = {
                    new SqlParameter("@Hash",  newHash),
                    new SqlParameter("@Email", email)
                };
                int rows = DatabaseHelper.ExecuteNonQuery(updateSql, pUpdate);

                if (rows == 0)
                {
                    ShowError("Could not update password. Please try again.");
                    return;
                }

                // Mark token as used
                DatabaseHelper.ExecuteNonQuery(
                    "UPDATE PasswordResets SET IsUsed = 1 WHERE Token = @Token",
                    new[] { new SqlParameter("@Token", token) });

                // Redirect to login with success flag
                Response.Redirect("~/Login.aspx?reset=1", false);
            }
            catch (Exception ex)
            {
                ShowError("A system error occurred. Please try again later.");
                System.Diagnostics.Debug.WriteLine("[ResetPassword Error] " + ex.Message);
            }
        }

        // ---------------------------------------------------------------
        // ValidateToken — returns true if the token is valid, unused, and
        // not expired.
        // ---------------------------------------------------------------
        private bool ValidateToken(string token, string email)
        {
            string sql = @"
                SELECT COUNT(1)
                FROM   PasswordResets
                WHERE  Token    = @Token
                  AND  LOWER(Email) = LOWER(@Email)
                  AND  IsUsed   = 0
                  AND  ExpiresAt > GETDATE()";

            SqlParameter[] p = {
                new SqlParameter("@Token", token),
                new SqlParameter("@Email", email)
            };

            object result = DatabaseHelper.ExecuteScalar(sql, p);
            return result != null && Convert.ToInt32(result) > 0;
        }

        // ---------------------------------------------------------------
        // UI helpers
        // ---------------------------------------------------------------
        private void ShowInvalid()
        {
            pnlForm.Visible = false;
            pnlInvalid.Visible = true;
        }

        private void ShowError(string msg)
        {
            pnlError.Visible = true;
            lblError.Text = msg;
        }
    }
}
