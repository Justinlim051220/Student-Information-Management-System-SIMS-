using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Lecturer
{
    public partial class Notifications : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireLecturer(Session, Response);

            if (!IsPostBack)
            {
                LoadLecturerInfo();
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadNotifications();
                CheckUnreadNotifications();
            }
        }

        private int CurrentUserId
        {
            get { return SessionHelper.GetUserId(Session); }
        }

        private void LoadLecturerInfo()
        {
            string fullName = SessionHelper.GetFullName(Session);

            lblSidebarName.Text = string.IsNullOrWhiteSpace(fullName)
                ? "Lecturer"
                : fullName;

            lblAvatarInitial.Text = string.IsNullOrWhiteSpace(fullName)
                ? "L"
                : fullName.Substring(0, 1).ToUpper();
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

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            try
            {
                string sql = @"
                    UPDATE Notifications
                    SET IsRead = 1
                    WHERE UserId = @UserId
                      AND IsRead = 0";

                int rows = DatabaseHelper.ExecuteNonQuery(sql, new[]
                {
                    new SqlParameter("@UserId", CurrentUserId)
                });

                LoadNotifications();
                CheckUnreadNotifications();

                if (rows > 0)
                    ShowMessage("All notifications marked as read.", "success");
                else
                    ShowMessage("No unread notifications found.", "warning");
            }
            catch (Exception ex)
            {
                ShowMessage("Error marking all notifications as read: " + ex.Message, "danger");
            }
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int notificationId;

            if (!int.TryParse(e.CommandArgument.ToString(), out notificationId))
            {
                ShowMessage("Invalid notification selected.", "danger");
                return;
            }

            if (e.CommandName == "MarkRead")
            {
                MarkNotificationReadStatus(notificationId, true);
            }
            else if (e.CommandName == "MarkUnread")
            {
                MarkNotificationReadStatus(notificationId, false);
            }
            else if (e.CommandName == "DeleteNotification")
            {
                DeleteNotification(notificationId);
            }

            LoadNotifications();
            CheckUnreadNotifications();
        }

        private void MarkNotificationReadStatus(int notificationId, bool isRead)
        {
            try
            {
                string sql = @"
                    UPDATE Notifications
                    SET IsRead = @IsRead
                    WHERE NotificationId = @NotificationId
                      AND UserId = @UserId";

                int rows = DatabaseHelper.ExecuteNonQuery(sql, new[]
                {
                    new SqlParameter("@IsRead", isRead),
                    new SqlParameter("@NotificationId", notificationId),
                    new SqlParameter("@UserId", CurrentUserId)
                });

                if (rows > 0)
                {
                    ShowMessage(
                        isRead ? "Notification marked as read." : "Notification marked as unread.",
                        "success"
                    );
                }
                else
                {
                    ShowMessage("Notification not found or you do not have permission.", "danger");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error updating notification: " + ex.Message, "danger");
            }
        }

        private void DeleteNotification(int notificationId)
        {
            try
            {
                string sql = @"
                    DELETE FROM Notifications
                    WHERE NotificationId = @NotificationId
                      AND UserId = @UserId";

                int rows = DatabaseHelper.ExecuteNonQuery(sql, new[]
                {
                    new SqlParameter("@NotificationId", notificationId),
                    new SqlParameter("@UserId", CurrentUserId)
                });

                if (rows > 0)
                    ShowMessage("Notification deleted successfully.", "success");
                else
                    ShowMessage("Notification not found or you do not have permission.", "danger");
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting notification: " + ex.Message, "danger");
            }
        }

        private void CheckUnreadNotifications()
        {
            object count = DatabaseHelper.ExecuteScalar(
                @"SELECT COUNT(*) 
                  FROM Notifications 
                  WHERE UserId = @UserId 
                    AND IsRead = 0",
                new[] { new SqlParameter("@UserId", CurrentUserId) });

            pnlNotifBadge.Visible = count != null && Convert.ToInt32(count) > 0;
        }

        private void ShowMessage(string message, string type)
        {
            lblMessage.Visible = true;
            lblMessage.Text = message;

            switch (type.ToLower())
            {
                case "success":
                    lblMessage.CssClass = "alert alert-success";
                    break;

                case "warning":
                    lblMessage.CssClass = "alert alert-warning";
                    break;

                case "danger":
                    lblMessage.CssClass = "alert alert-danger";
                    break;

                default:
                    lblMessage.CssClass = "alert";
                    break;
            }
        }

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}