using System;
using System.Net;
using System.Net.Mail;
using System.Configuration;

namespace SIMS.Helpers
{
    /// <summary>
    /// Sends emails via the SMTP settings configured in Web.config.
    /// Used for password reset links.
    ///
    /// Web.config keys required (inside <appSettings>):
    ///   SmtpHost        — e.g. smtp.gmail.com
    ///   SmtpPort        — e.g. 587
    ///   SmtpUser        — sender email address
    ///   SmtpPass        — sender password / app-password
    ///   SmtpDisplayName — e.g. SIMS – ONTI University
    ///   AppBaseUrl      — e.g. https://localhost:44300 (no trailing slash)
    /// </summary>
    public static class EmailHelper
    {
        // ---------------------------------------------------------------
        // Send a password-reset link to the given email address.
        // token  — the reset token stored in the DB
        // ---------------------------------------------------------------
        public static void SendPasswordResetEmail(string toEmail,
                                                   string recipientName,
                                                   string token)
        {
            string baseUrl = ConfigurationManager.AppSettings["AppBaseUrl"];
            string resetUrl = $"{baseUrl}/ResetPassword.aspx?token={Uri.EscapeDataString(token)}&email={Uri.EscapeDataString(toEmail)}";

            string subject = "SIMS – Password Reset Request";
            string body = BuildResetEmailBody(recipientName, resetUrl);

            SendEmail(toEmail, subject, body);
        }

        // ---------------------------------------------------------------
        // Core send method — reads SMTP settings from Web.config.
        // ---------------------------------------------------------------
        private static void SendEmail(string to, string subject, string htmlBody)
        {
            string host = ConfigurationManager.AppSettings["SmtpHost"];
            int port = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
            string user = ConfigurationManager.AppSettings["SmtpUser"];
            string pass = ConfigurationManager.AppSettings["SmtpPass"];
            string displayName = ConfigurationManager.AppSettings["SmtpDisplayName"] ?? "SIMS ONTI";

            using (var client = new SmtpClient(host, port))
            {
                client.EnableSsl = true;
                client.DeliveryMethod = SmtpDeliveryMethod.Network;
                client.UseDefaultCredentials = false;
                client.Credentials = new NetworkCredential(user, pass);

                var msg = new MailMessage
                {
                    From = new MailAddress(user, displayName),
                    Subject = subject,
                    Body = htmlBody,
                    IsBodyHtml = true
                };
                msg.To.Add(to);

                client.Send(msg);
            }
        }

        // ---------------------------------------------------------------
        // Build a styled HTML email body for the reset link.
        // ---------------------------------------------------------------
        private static string BuildResetEmailBody(string name, string resetUrl)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
  <meta charset='utf-8'>
  <style>
    body {{ font-family: 'Segoe UI', Arial, sans-serif; background: #f5f5f5; margin: 0; padding: 0; }}
    .container {{ max-width: 560px; margin: 40px auto; background: #fff;
                  border-radius: 12px; overflow: hidden;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.08); }}
    .header {{ background: linear-gradient(135deg, #f5a623, #e8890a);
               padding: 32px 40px; }}
    .header h1 {{ color: #fff; margin: 0; font-size: 22px; letter-spacing: 0.5px; }}
    .header p  {{ color: rgba(255,255,255,0.85); margin: 4px 0 0; font-size: 13px; }}
    .body   {{ padding: 36px 40px; color: #333; line-height: 1.6; }}
    .body p {{ margin: 0 0 16px; }}
    .btn    {{ display: inline-block; padding: 14px 36px;
               background: linear-gradient(135deg, #f5a623, #e8890a);
               color: #fff !important; text-decoration: none;
               border-radius: 50px; font-weight: 700; font-size: 15px;
               letter-spacing: 0.3px; margin: 8px 0 24px; }}
    .note   {{ font-size: 12px; color: #888; border-top: 1px solid #eee;
               padding-top: 16px; margin-top: 8px; }}
    .footer {{ background: #fafafa; padding: 16px 40px;
               font-size: 12px; color: #aaa; text-align: center; }}
  </style>
</head>
<body>
  <div class='container'>
    <div class='header'>
      <h1>π ONTI International University</h1>
      <p>Student Information Management System</p>
    </div>
    <div class='body'>
      <p>Hello <strong>{name}</strong>,</p>
      <p>We received a request to reset the password for your SIMS account.
         Click the button below to set a new password:</p>
      <p><a class='btn' href='{resetUrl}'>Reset My Password</a></p>
      <p>This link will expire in <strong>30 minutes</strong>.
         If you did not request a password reset, please ignore this email —
         your account remains secure.</p>
      <p class='note'>
        If the button above doesn't work, copy and paste this URL into your browser:<br>
        <a href='{resetUrl}' style='color:#f5a623;word-break:break-all;'>{resetUrl}</a>
      </p>
    </div>
    <div class='footer'>
      © {DateTime.Now.Year} ONTI International University Malaysia. All rights reserved.
    </div>
  </div>
</body>
</html>";
        }
    }
}