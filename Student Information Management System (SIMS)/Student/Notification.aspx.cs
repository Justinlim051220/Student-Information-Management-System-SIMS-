using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class Notification : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                LoadStudentInfo();
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
                LoadNotifications();
                CheckUnreadNotifications();
            }
        }

        private int CurrentUserId
        {
            get { return SessionHelper.GetUserId(Session); }
        }

        private void LoadStudentInfo()
        {
            string fullName = SessionHelper.GetFullName(Session);
            lblSidebarName.Text = string.IsNullOrWhiteSpace(fullName) ? "Student" : fullName;
            lblTopbarInitial.Text = string.IsNullOrWhiteSpace(fullName) ? "S" : fullName.Trim()[0].ToString().ToUpper();
            LoadSidebarProfilePicture();
        }

        private void LoadSidebarProfilePicture()
        {
            // Student profile picture is not required for this page yet.
            // The default profile picture keeps the sidebar consistent.
            imgSidebarAvatar.ImageUrl = "~/ProfilePicture/default-profile.png";
        }

        private void LoadNotifications()
        {
            string sql = @"
                SELECT 
                    NotificationId,
                    Title,
                    CONVERT(VARCHAR(MAX), Message) AS Message,
                    IsRead,
                    CreatedAt
                FROM Notifications
                WHERE UserId = @UserId
                  AND (
                        @Search = ''
                        OR Title LIKE '%' + @Search + '%'
                        OR CONVERT(VARCHAR(MAX), Message) LIKE '%' + @Search + '%'
                      )
                  AND (
                        @Status = ''
                        OR (@Status = 'Unread' AND IsRead = 0)
                        OR (@Status = 'Read' AND IsRead = 1)
                      )
                ORDER BY IsRead ASC, CreatedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@UserId", CurrentUserId),
                new SqlParameter("@Search", txtSearch.Text.Trim()),
                new SqlParameter("@Status", ddlStatusFilter.SelectedValue)
            });

            rptNotifications.DataSource = dt;
            rptNotifications.DataBind();

            lblTotal.Text = dt.Rows.Count.ToString();
            pnlEmpty.Visible = dt.Rows.Count == 0;

            object unread = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @UserId AND IsRead = 0",
                new[] { new SqlParameter("@UserId", CurrentUserId) });

            lblUnread.Text = unread == null ? "0" : unread.ToString();
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            LoadNotifications();
            CheckUnreadNotifications();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadNotifications();
            CheckUnreadNotifications();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatusFilter.SelectedIndex = 0;
            LoadNotifications();
            CheckUnreadNotifications();
        }

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            try
            {
                int rows = DatabaseHelper.ExecuteNonQuery(
                    @"UPDATE Notifications
                      SET IsRead = 1
                      WHERE UserId = @UserId AND IsRead = 0",
                    new[] { new SqlParameter("@UserId", CurrentUserId) });

                LoadNotifications();
                CheckUnreadNotifications();

                if (rows > 0)
                    ShowMessage("Success", "All notifications marked as read.");
                else
                    ShowMessage("Warning", "No unread notifications found.");
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Error marking notifications as read: " + ex.Message);
            }
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int notificationId;

            if (!int.TryParse(e.CommandArgument.ToString(), out notificationId))
            {
                ShowMessage("Error", "Invalid notification selected.");
                return;
            }

            if (e.CommandName == "MarkRead")
            {
                ShowReadConfirmation(notificationId);
                return;
            }

            if (e.CommandName == "MarkUnread")
            {
                MarkNotificationReadStatus(notificationId, false);
            }
            else if (e.CommandName == "DeleteNotification")
            {
                ShowDeleteConfirmation(notificationId);
                return;
            }

            LoadNotifications();
            CheckUnreadNotifications();
        }

        private void ShowReadConfirmation(int notificationId)
        {
            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                "confirmReadNotification" + notificationId,
                "showReadConfirm(" + notificationId + ");",
                true);
        }

        private void ShowDeleteConfirmation(int notificationId)
        {
            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                "confirmDeleteNotification" + notificationId,
                "showDeleteConfirm(" + notificationId + ");",
                true);
        }

        protected void btnReadConfirmed_Click(object sender, EventArgs e)
        {
            int notificationId;

            if (!int.TryParse(hfReadTarget.Value, out notificationId))
            {
                ShowMessage("Error", "Invalid notification selected.");
                return;
            }

            MarkNotificationReadStatus(notificationId, true);
            hfReadTarget.Value = "";

            LoadNotifications();
            CheckUnreadNotifications();
        }

        protected void btnDeleteConfirmed_Click(object sender, EventArgs e)
        {
            int notificationId;

            if (!int.TryParse(hfDeleteTarget.Value, out notificationId))
            {
                ShowMessage("Error", "Invalid notification selected for deletion.");
                return;
            }

            DeleteNotification(notificationId);
            hfDeleteTarget.Value = "";

            LoadNotifications();
            CheckUnreadNotifications();
        }

        private void MarkNotificationReadStatus(int notificationId, bool isRead)
        {
            try
            {
                int rows = DatabaseHelper.ExecuteNonQuery(
                    @"UPDATE Notifications
                      SET IsRead = @IsRead
                      WHERE NotificationId = @NotificationId
                        AND UserId = @UserId",
                    new[]
                    {
                        new SqlParameter("@IsRead", isRead),
                        new SqlParameter("@NotificationId", notificationId),
                        new SqlParameter("@UserId", CurrentUserId)
                    });

                if (rows > 0)
                    ShowMessage("Success", isRead ? "Notification marked as read." : "Notification marked as unread.");
                else
                    ShowMessage("Error", "Notification not found or you do not have permission.");
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Error updating notification: " + ex.Message);
            }
        }

        private void DeleteNotification(int notificationId)
        {
            try
            {
                int rows = DatabaseHelper.ExecuteNonQuery(
                    @"DELETE FROM Notifications
                      WHERE NotificationId = @NotificationId
                        AND UserId = @UserId",
                    new[]
                    {
                        new SqlParameter("@NotificationId", notificationId),
                        new SqlParameter("@UserId", CurrentUserId)
                    });

                if (rows > 0)
                    ShowMessage("Success", "Notification deleted successfully.");
                else
                    ShowMessage("Error", "Notification not found or you do not have permission.");
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Error deleting notification: " + ex.Message);
            }
        }

        private void CheckUnreadNotifications()
        {
            object count = DatabaseHelper.ExecuteScalar(
                @"SELECT COUNT(*) FROM Notifications WHERE UserId = @UserId AND IsRead = 0",
                new[] { new SqlParameter("@UserId", CurrentUserId) });

            pnlNotifBadge.Visible = count != null && Convert.ToInt32(count) > 0;
        }

        private void ShowMessage(string title, string message)
        {
            string safeTitle = HttpUtility.JavaScriptStringEncode(title);
            string safeMessage = HttpUtility.JavaScriptStringEncode(message)
                .Replace("\r\n", "<br/>")
                .Replace("\n", "<br/>");

            string script = string.Format("showMessageModal('{0}', '{1}');", safeTitle, safeMessage);

            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                Guid.NewGuid().ToString("N"),
                script,
                true);
        }

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}