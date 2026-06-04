using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class Admin_Notification : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                BindNotifications();
                BindSummary();
            }
        }

        private int CurrentAdminUserId
        {
            get { return SessionHelper.GetUserId(Session); }
        }

        private void BindSummary()
        {
            string sql = @"
                SELECT
                    COUNT(*) AS TotalCount,
                    SUM(CASE WHEN IsRead = 0 THEN 1 ELSE 0 END) AS UnreadCount,
                    SUM(CASE WHEN Title LIKE '%Payment%' OR Message LIKE '%payment%' OR Message LIKE '%receipt%' THEN 1 ELSE 0 END) AS PaymentCount
                FROM Notifications
                WHERE UserId = @UserId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@UserId", CurrentAdminUserId) });

            if (dt.Rows.Count == 0)
            {
                lblTotal.Text = "0";
                lblUnread.Text = "0";
                lblPaymentAlerts.Text = "0";
                return;
            }

            DataRow row = dt.Rows[0];
            lblTotal.Text = row["TotalCount"] == DBNull.Value ? "0" : row["TotalCount"].ToString();
            lblUnread.Text = row["UnreadCount"] == DBNull.Value ? "0" : row["UnreadCount"].ToString();
            lblPaymentAlerts.Text = row["PaymentCount"] == DBNull.Value ? "0" : row["PaymentCount"].ToString();
        }

        private void BindNotifications()
        {
            string keyword = txtSearch == null ? "" : txtSearch.Text.Trim();

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
                        @Status = ''
                        OR (@Status = 'Unread' AND IsRead = 0)
                        OR (@Status = 'Read' AND IsRead = 1)
                      )
                  AND (
                        @Keyword = ''
                        OR Title LIKE '%' + @Keyword + '%'
                        OR CONVERT(VARCHAR(MAX), Message) LIKE '%' + @Keyword + '%'
                      )
                ORDER BY IsRead ASC, CreatedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@UserId", CurrentAdminUserId),
                new SqlParameter("@Status", ddlStatus.SelectedValue ?? ""),
                new SqlParameter("@Keyword", keyword)
            });

            gvNotifications.DataSource = dt;
            gvNotifications.DataBind();
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            BindNotifications();
            BindSummary();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedIndex = 0;
            BindNotifications();
            BindSummary();
        }

        protected void gvNotifications_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int notificationId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out notificationId))
            {
                ShowDialog("Error", "Invalid notification selected.");
                return;
            }

            if (e.CommandName == "MarkRead")
            {
                MarkNotificationAsRead(notificationId);
                return;
            }

            if (e.CommandName == "DeleteNotification")
            {
                DeleteNotification(notificationId);
                return;
            }
        }

        private void MarkNotificationAsRead(int notificationId)
        {
            string sql = @"
                UPDATE Notifications
                SET IsRead = 1
                WHERE NotificationId = @NotificationId
                  AND UserId = @UserId";

            int rows = DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@NotificationId", notificationId),
                new SqlParameter("@UserId", CurrentAdminUserId)
            });

            BindNotifications();
            BindSummary();

            ShowDialog(rows > 0 ? "Success" : "Error", rows > 0 ? "Notification marked as read." : "Notification not found or already updated.");
        }

        private void DeleteNotification(int notificationId)
        {
            string sql = @"
                DELETE FROM Notifications
                WHERE NotificationId = @NotificationId
                  AND UserId = @UserId";

            int rows = DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@NotificationId", notificationId),
                new SqlParameter("@UserId", CurrentAdminUserId)
            });

            BindNotifications();
            BindSummary();

            ShowDialog(rows > 0 ? "Success" : "Error", rows > 0 ? "Notification deleted successfully." : "Notification not found.");
        }

        private void ShowDialog(string title, string message)
        {
            string safeTitle = HttpUtility.JavaScriptStringEncode(title);
            string safeMessage = HttpUtility.JavaScriptStringEncode(message);
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"),
                "showDialog('" + safeTitle + "','" + safeMessage + "');", true);
        }
    }
}
