using System;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class StudentSidebar : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                RefreshSidebar();
        }

        public string NavClass(string pageName)
        {
            string currentPage = Path.GetFileNameWithoutExtension(Page.AppRelativeVirtualPath);

            return string.Equals(currentPage, pageName, StringComparison.OrdinalIgnoreCase)
                ? "sidebar-link active"
                : "sidebar-link";
        }

        public void RefreshSidebar()
        {
            string fullName = SessionHelper.GetFullName(Session);
            lblSidebarName.Text = string.IsNullOrWhiteSpace(fullName) ? "Student" : fullName;

            object result = DatabaseHelper.ExecuteScalar(
                "SELECT ProfilePicture FROM StudentDetails WHERE UserId = @UserId",
                new[] { new SqlParameter("@UserId", SessionHelper.GetUserId(Session)) });

            string picture = result == null || result == DBNull.Value ? "" : result.ToString();

            imgSidebarAvatar.ImageUrl = string.IsNullOrWhiteSpace(picture)
                ? "~/ProfilePicture/default-profile.png"
                : picture;

            RegisterSuspensionAccessState();
        }



        private void RegisterSuspensionAccessState()
        {
            bool isSuspended = false;
            string reason = "Payment not completed";

            try
            {
                object columnExists = DatabaseHelper.ExecuteScalar(@"
                    SELECT CASE
                        WHEN COL_LENGTH('dbo.StudentDetails', 'IsSuspended') IS NULL THEN 0
                        ELSE 1
                    END");

                if (columnExists != null && columnExists != DBNull.Value && Convert.ToInt32(columnExists) == 1)
                {
                    string studentId = SessionHelper.GetProfileId(Session);

                    if (!string.IsNullOrWhiteSpace(studentId))
                    {
                        object suspendedObj = DatabaseHelper.ExecuteScalar(@"
                            SELECT TOP 1 IsSuspended
                            FROM StudentDetails
                            WHERE StudentId = @StudentId",
                            new[] { new SqlParameter("@StudentId", studentId) });

                        isSuspended = suspendedObj != null && suspendedObj != DBNull.Value && Convert.ToBoolean(suspendedObj);

                        if (isSuspended)
                        {
                            object reasonObj = DatabaseHelper.ExecuteScalar(@"
                                SELECT TOP 1 ISNULL(NULLIF(LTRIM(RTRIM(SuspensionReason)), ''), 'Payment not completed')
                                FROM StudentDetails
                                WHERE StudentId = @StudentId",
                                new[] { new SqlParameter("@StudentId", studentId) });

                            if (reasonObj != null && reasonObj != DBNull.Value && !string.IsNullOrWhiteSpace(reasonObj.ToString()))
                                reason = reasonObj.ToString();
                        }
                    }
                }
            }
            catch
            {
                isSuspended = false;
                reason = "Payment not completed";
            }

            string script =
                "window.SIMS_STUDENT_SUSPENDED = " + (isSuspended ? "true" : "false") + ";" +
                "window.SIMS_SUSPENSION_REASON = '" + HttpUtility.JavaScriptStringEncode(reason) + "';";

            Page.ClientScript.RegisterStartupScript(
                GetType(),
                "SIMSStudentSuspensionState",
                script,
                true);
        }

        protected void btnConfirmLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}