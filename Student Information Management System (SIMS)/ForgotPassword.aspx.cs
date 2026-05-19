using SIMS.Helpers;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

/// <summary>
/// Code-behind for ForgotPassword.aspx
///
/// Flow:
///   1. User enters email and clicks "Send Reset Link".
///   2. Check if the email exists in the Users table AND IsActive = 1.
///   3. If found: generate a secure token, store it + expiry in DB,
///      then send the reset email.
///   4. If NOT found: show a generic success message anyway
///      (security best practice — don't reveal whether email exists).
///
/// NOTE:
///   The DB needs a PasswordResets table to store tokens.
///   Add the following to SIMS.sql and run it once:
///
///   CREATE TABLE PasswordResets (
///       ResetId    INT          NOT NULL IDENTITY(1,1),
///       Email      VARCHAR(100) NOT NULL,
///       Token      VARCHAR(200) NOT NULL,
///       ExpiresAt  DATETIME     NOT NULL,
///       IsUsed     BIT          NOT NULL DEFAULT 0,
///       CreatedAt  DATETIME     NOT NULL DEFAULT GETDATE(),
///       CONSTRAINT PK_PasswordResets PRIMARY KEY (ResetId),
///       CONSTRAINT UQ_PasswordResets_Token UNIQUE (Token)
///   );
/// </summary>
/// 

namespace Student_Information_Management_System__SIMS_
{
    public partial class ForgotPassword : Page
    {
        // ---------------------------------------------------------------
        // Page_Load
        // ---------------------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if redirected back from ResetPassword with success flag
            if (!IsPostBack && Request.QueryString["sent"] == "1")
            {
                pnlStep1.Visible = false;
                pnlStep2.Visible = true;
                lblSuccess.Text = "Password reset email sent successfully.";
                pnlSuccess.Visible = true;
            }
        }

        // ---------------------------------------------------------------
        // btnSendLink_Click — process the forgot-password request.
        // ---------------------------------------------------------------
        protected void btnSendLink_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim().ToLower();

            try
            {
                string sql = @"
            SELECT u.UserId, u.Email, u.IsActive,
                   COALESCE(h.FirstName, l.FirstName, s.FirstName, '') 
                 + ' ' 
                 + COALESCE(h.LastName, l.LastName, s.LastName, '') AS FullName
            FROM   Users u
            LEFT JOIN HoPDetails     h ON h.UserId = u.UserId
            LEFT JOIN LecturerDetails l ON l.UserId = u.UserId
            LEFT JOIN StudentDetails  s ON s.UserId = u.UserId
            WHERE  LOWER(u.Email) = @Email";

                SqlParameter[] p = { new SqlParameter("@Email", email) };
                DataTable dt = DatabaseHelper.ExecuteQuery(sql, p);

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    bool isActive = Convert.ToBoolean(row["IsActive"]);

                    if (isActive)
                    {
                        string fullName = row["FullName"].ToString().Trim();
                        if (string.IsNullOrWhiteSpace(fullName)) fullName = "User";

                        string token = PasswordHelper.GenerateResetToken();
                        StoreResetToken(email, token);
                        EmailHelper.SendPasswordResetEmail(email, fullName, token);

                        // Success message
                        ShowSuccess();
                    }
                    else
                    {
                        // Inactive account
                        ShowError("Your account is inactive. Please contact administrator.");
                    }
                }
                else
                {
                    // Email not found
                    ShowError("No account found with this email address.");
                    // OR keep security: ShowSuccess();  ← Uncomment if you want to hide existence
                }
            }
            catch (Exception ex)
            {
                ShowError("A system error occurred. Please try again later.");
                System.Diagnostics.Debug.WriteLine("[ForgotPassword Error] " + ex.Message);
            }
        }

        private void ShowSuccess()
        {
            pnlStep1.Visible = false;
            pnlStep2.Visible = true;
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
            lblSuccess.Text = "Password reset email sent successfully. Please check your inbox.";
        }

        // ---------------------------------------------------------------
        // lbResend_Click — resend the email (same logic as send).
        // ---------------------------------------------------------------
        protected void lbResend_Click(object sender, EventArgs e)
        {
            // Go back to step 1 so user can re-enter their email
            pnlStep1.Visible = true;
            pnlStep2.Visible = false;
        }

        // ---------------------------------------------------------------
        // StoreResetToken — save token + 30-minute expiry to the DB.
        // ---------------------------------------------------------------
        private void StoreResetToken(string email, string token)
        {
            int expiryMinutes = 30;
            try
            {
                expiryMinutes = int.Parse(
                    System.Configuration.ConfigurationManager.AppSettings["ResetTokenExpiryMinutes"] ?? "30");
            }
            catch { /* use default */ }

            // Invalidate any previous unused tokens for this email first
            DatabaseHelper.ExecuteNonQuery(
            "UPDATE PasswordResets SET IsUsed = 1 WHERE Email = @Email AND IsUsed = 0",
            new[] { new SqlParameter("@Email", email) }
            );

            // Insert the new token
            string insertSql = @"
                INSERT INTO PasswordResets (Email, Token, ExpiresAt)
                VALUES (@Email, @Token, @Expiry)";

            SqlParameter[] p = {
                new SqlParameter("@Email",  email),
                new SqlParameter("@Token",  token),
                new SqlParameter("@Expiry", DateTime.Now.AddMinutes(expiryMinutes))
            };

            DatabaseHelper.ExecuteNonQuery(insertSql, p);
        }

        // ---------------------------------------------------------------
        // UI helpers
        // ---------------------------------------------------------------
        private void ShowError(string msg)
        {
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
            lblError.Text = msg;
        }
    }
}
