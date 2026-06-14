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
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
                SyncVisibleAnnouncementsToInbox();
                LoadNotifications();
                CheckUnreadNotifications();
            }
        }

        private int CurrentUserId
        {
            get { return SessionHelper.GetUserId(Session); }
        }

        private void LoadNotifications()
        {
            string sql = @"
                ;WITH InboxItems AS
                (
                SELECT
                    NotificationId,
                    'Notification' AS ItemType,
                    Title,
                    CONVERT(VARCHAR(MAX), Message) AS Message,
                    IsRead,
                    CreatedAt,
                    CASE 
                        WHEN Title LIKE '%announcement%' THEN 'Admin'
                        WHEN Title LIKE '%payment%' OR CONVERT(VARCHAR(MAX), Message) LIKE '%payment%' THEN 'Admin'
                        WHEN Title LIKE '%approved%' OR Title LIKE '%rejected%' THEN 'Admin'
                        WHEN Title LIKE '%enrol%' OR Title LIKE '%enroll%' THEN 'System'
                        ELSE 'System'
                    END AS SenderDisplay
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
                )
                SELECT
                    NotificationId,
                    ItemType,
                    Title,
                    Message,
                    IsRead,
                    CreatedAt,
                    SenderDisplay
                FROM InboxItems
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

        private void SyncVisibleAnnouncementsToInbox()
        {
            string sql = @"
                ;WITH StudentProfile AS
                (
                    SELECT StudentId, ProgrammeId
                    FROM StudentDetails
                    WHERE UserId = @UserId
                )
                INSERT INTO Notifications (UserId, Title, Message, IsRead, CreatedAt)
                SELECT
                    @UserId,
                    a.Title,
                    CONVERT(VARCHAR(MAX), a.Content),
                    0,
                    a.CreatedAt
                FROM Announcements a
                CROSS JOIN StudentProfile sp
                WHERE a.TargetRole IN ('Student', 'All')
                  AND (a.ProgrammeId IS NULL OR a.ProgrammeId = sp.ProgrammeId)
                  AND (
                        a.CourseId IS NULL
                        OR EXISTS (
                            SELECT 1
                            FROM Enrollment e
                            WHERE e.StudentId = sp.StudentId
                              AND e.CourseId = a.CourseId
                              AND e.Status = 'Active'
                              AND (a.Session IS NULL OR e.Session = a.Session)
                        )
                      )
                  AND (
                        a.Session IS NULL
                        OR a.CourseId IS NOT NULL
                        OR EXISTS (
                            SELECT 1
                            FROM Enrollment e
                            WHERE e.StudentId = sp.StudentId
                              AND e.Session = a.Session
                              AND e.Status = 'Active'
                        )
                      )
                  AND NOT EXISTS (
                        SELECT 1
                        FROM Notifications n
                        WHERE n.UserId = @UserId
                          AND n.Title = a.Title
                          AND CONVERT(VARCHAR(MAX), n.Message) = CONVERT(VARCHAR(MAX), a.Content)
                      )";

            DatabaseHelper.ExecuteNonQuery(sql, new[] { new SqlParameter("@UserId", CurrentUserId) });
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
                ShowUnreadConfirmation(notificationId);
                return;
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

        private void ShowUnreadConfirmation(int notificationId)
        {
            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                "confirmUnreadNotification" + notificationId,
                "showUnreadConfirm(" + notificationId + ");",
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

        protected void btnUnreadConfirmed_Click(object sender, EventArgs e)
        {
            int notificationId;

            if (!int.TryParse(hfUnreadTarget.Value, out notificationId))
            {
                ShowMessage("Error", "Invalid notification selected.");
                return;
            }

            MarkNotificationReadStatus(notificationId, false);
            hfUnreadTarget.Value = "";

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
    }
}
