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
                SyncAnnouncementNotifications();
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
                SELECT
                    n.NotificationId,
                    'Notification' AS ItemType,
                    n.Title,
                    CASE
                        WHEN LEFT(msg.RawMessage, 5) = '[ANN:' AND CHARINDEX(CHAR(10), msg.RawMessage) > 0
                            THEN LTRIM(SUBSTRING(msg.RawMessage, CHARINDEX(CHAR(10), msg.RawMessage) + 1, LEN(msg.RawMessage)))
                        ELSE msg.RawMessage
                    END AS Message,
                    n.IsRead,
                    n.CreatedAt,
                    CASE 
                        WHEN a.AnnouncementId IS NOT NULL AND postedUser.Role = 2 THEN ISNULL('Lecturer ' + ld.FirstName + ' ' + ld.LastName, postedUser.Email)
                        WHEN a.AnnouncementId IS NOT NULL AND postedUser.Role = 1 THEN ISNULL('Admin ' + hd.FirstName + ' ' + hd.LastName, postedUser.Email)
                        WHEN n.Title LIKE '%announcement%' THEN 'Admin'
                        WHEN n.Title LIKE '%payment%' OR msg.RawMessage LIKE '%payment%' THEN 'Admin'
                        WHEN n.Title LIKE '%approved%' OR n.Title LIKE '%rejected%' THEN 'Admin'
                        WHEN n.Title LIKE '%enrol%' OR n.Title LIKE '%enroll%' THEN 'System'
                        ELSE 'System'
                    END AS SenderDisplay
                FROM Notifications n
                OUTER APPLY (SELECT CONVERT(VARCHAR(MAX), n.Message) AS RawMessage) msg
                OUTER APPLY (
                    SELECT CASE
                        WHEN LEFT(msg.RawMessage, 5) = '[ANN:' AND CHARINDEX(']', msg.RawMessage) > 6
                            THEN SUBSTRING(msg.RawMessage, 6, CHARINDEX(']', msg.RawMessage) - 6)
                        ELSE NULL
                    END AS AnnouncementKey
                ) annRef
                LEFT JOIN Announcements a
                    ON annRef.AnnouncementKey IS NOT NULL
                   AND CAST(a.AnnouncementId AS VARCHAR(20)) = annRef.AnnouncementKey
                LEFT JOIN Users postedUser ON postedUser.UserId = a.PostedByUserId
                LEFT JOIN LecturerDetails ld ON ld.UserId = postedUser.UserId
                LEFT JOIN HoPDetails hd ON hd.UserId = postedUser.UserId
                WHERE n.UserId = @UserId
                  AND (
                        @Search = ''
                        OR n.Title LIKE '%' + @Search + '%'
                        OR msg.RawMessage LIKE '%' + @Search + '%'
                        OR ld.FirstName + ' ' + ld.LastName LIKE '%' + @Search + '%'
                        OR hd.FirstName + ' ' + hd.LastName LIKE '%' + @Search + '%'
                      )
                  AND (
                        @Status = ''
                        OR (@Status = 'Unread' AND n.IsRead = 0)
                        OR (@Status = 'Read' AND n.IsRead = 1)
                      )
                ORDER BY n.IsRead ASC, n.CreatedAt DESC";

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

        private void SyncAnnouncementNotifications()
        {
            string sql = @"
                ;WITH StudentProfile AS
                (
                    SELECT StudentId, ProgrammeId
                    FROM StudentDetails
                    WHERE UserId = @UserId
                ),
                VisibleAnnouncements AS
                (
                    SELECT
                        a.AnnouncementId,
                        a.Title,
                        CONVERT(VARCHAR(MAX), a.Content) AS Message,
                        a.PostedByUserId,
                        '[' + 'ANN:' + CAST(a.AnnouncementId AS VARCHAR(20)) + ']' AS AnnouncementTag
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
                )
                UPDATE n
                SET n.Title = va.Title,
                    n.Message = va.AnnouncementTag + CHAR(10) + va.Message,
                    n.CreatedAt = CASE
                        WHEN n.Title <> va.Title OR CONVERT(VARCHAR(MAX), n.Message) <> va.AnnouncementTag + CHAR(10) + va.Message
                            THEN GETDATE()
                        ELSE n.CreatedAt
                    END,
                    n.IsRead = CASE
                        WHEN n.Title <> va.Title OR CONVERT(VARCHAR(MAX), n.Message) <> va.AnnouncementTag + CHAR(10) + va.Message
                            THEN 0
                        ELSE n.IsRead
                    END
                FROM Notifications n
                INNER JOIN VisibleAnnouncements va
                    ON n.UserId = @UserId
                   AND (
                        LEFT(CONVERT(VARCHAR(MAX), n.Message), LEN(va.AnnouncementTag)) = va.AnnouncementTag
                        OR (
                            LEFT(CONVERT(VARCHAR(MAX), n.Message), 5) <> '[ANN:'
                            AND (
                                n.Title = va.Title
                                OR CONVERT(VARCHAR(MAX), n.Message) = va.Message
                            )
                            AND NOT EXISTS (
                                SELECT 1
                                FROM Notifications existing
                                WHERE existing.UserId = @UserId
                                  AND LEFT(CONVERT(VARCHAR(MAX), existing.Message), LEN(va.AnnouncementTag)) = va.AnnouncementTag
                            )
                        )
                   );

                ;WITH TaggedNotifications AS
                (
                    SELECT
                        n.NotificationId,
                        ROW_NUMBER() OVER (
                            PARTITION BY n.UserId, SUBSTRING(msg.RawMessage, 6, CHARINDEX(']', msg.RawMessage) - 6)
                            ORDER BY n.NotificationId ASC
                        ) AS RowNumber
                    FROM Notifications n
                    OUTER APPLY (SELECT CONVERT(VARCHAR(MAX), n.Message) AS RawMessage) msg
                    WHERE n.UserId = @UserId
                      AND LEFT(msg.RawMessage, 5) = '[ANN:'
                      AND CHARINDEX(']', msg.RawMessage) > 6
                )
                DELETE FROM Notifications
                WHERE NotificationId IN (
                    SELECT NotificationId
                    FROM TaggedNotifications
                    WHERE RowNumber > 1
                );

                ;WITH StudentProfile AS
                (
                    SELECT StudentId, ProgrammeId
                    FROM StudentDetails
                    WHERE UserId = @UserId
                ),
                VisibleAnnouncements AS
                (
                    SELECT
                        a.AnnouncementId,
                        a.Title,
                        CONVERT(VARCHAR(MAX), a.Content) AS Message,
                        '[' + 'ANN:' + CAST(a.AnnouncementId AS VARCHAR(20)) + ']' AS AnnouncementTag
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
                )
                INSERT INTO Notifications (UserId, Title, Message, IsRead, CreatedAt)
                SELECT @UserId, va.Title, va.AnnouncementTag + CHAR(10) + va.Message, 0, GETDATE()
                FROM VisibleAnnouncements va
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM Notifications n
                    WHERE n.UserId = @UserId
                      AND LEFT(CONVERT(VARCHAR(MAX), n.Message), LEN(va.AnnouncementTag)) = va.AnnouncementTag
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
    }
}
