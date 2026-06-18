using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class Admin_Dashboard : Page
    {
        private const string CURRENT_SESSION = "April 2026";

        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                string fullName = SessionHelper.GetFullName(Session);
                if (string.IsNullOrWhiteSpace(fullName)) fullName = "Admin";

                lblWelcomeName.Text = fullName;
                lblSidebarName.Text = fullName;
                lblAvatarInitial.Text = fullName.Length > 0
                    ? fullName[0].ToString().ToUpper()
                    : "A";

                LoadAdminProfilePicture();
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadStats();
                LoadRecentStudents();
                LoadAnnouncements();
                LoadCourses();
                LoadFeeStats();
                RegisterDashboardFeeChart();
                CheckUnreadNotifications();
            }
        }

        private void LoadAdminProfilePicture()
        {
            divSidebarPhoto.Visible = false;
            divSidebarInitial.Visible = true;

            try
            {
                int userId = SessionHelper.GetUserId(Session);

                object pictureObj = DatabaseHelper.ExecuteScalar(
                    @"SELECT ProfilePicture
                      FROM HoPDetails
                      WHERE UserId = @UserId",
                    new[] { new SqlParameter("@UserId", userId) });

                string picture = pictureObj == null || pictureObj == DBNull.Value
                    ? ""
                    : pictureObj.ToString();

                if (!string.IsNullOrWhiteSpace(picture))
                {
                    imgSidebarAvatar.ImageUrl = picture;
                    divSidebarPhoto.Visible = true;
                    divSidebarInitial.Visible = false;
                }
            }
            catch
            {
                divSidebarPhoto.Visible = false;
                divSidebarInitial.Visible = true;
            }
        }

        private void LoadStats()
        {
            object stuCount = DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(*)
                FROM StudentDetails s
                INNER JOIN Users u ON u.UserId = s.UserId
                WHERE u.IsActive = 1");
            lblTotalStudents.Text = ConvertDbInt(stuCount).ToString();

            object lecCount = DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(*)
                FROM LecturerDetails l
                INNER JOIN Users u ON u.UserId = l.UserId
                WHERE u.IsActive = 1");
            lblTotalLecturers.Text = ConvertDbInt(lecCount).ToString();

            object progCount = DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM Programmes");
            lblTotalProgrammes.Text = ConvertDbInt(progCount).ToString();

            // Important fix:
            // Dashboard pending count now follows Manage Fees display logic.
            // It excludes dropped / not-active payment history, so the number will match Manage Fees Pending filter.
            lblPendingFees.Text = GetActionablePaymentCount("Pending").ToString();
        }

        private void LoadRecentStudents()
        {
            string sql = @"
                SELECT TOP 5
                       s.StudentId,
                       s.FirstName + ' ' + s.LastName AS FullName,
                       p.ProgrammeCode,
                       s.EnrollmentDate
                FROM StudentDetails s
                INNER JOIN Users u ON u.UserId = s.UserId
                INNER JOIN Programmes p ON p.ProgrammeId = s.ProgrammeId
                WHERE u.IsActive = 1
                ORDER BY s.EnrollmentDate DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);
            rptRecentStudents.DataSource = dt;
            rptRecentStudents.DataBind();
        }

        private void LoadAnnouncements()
        {
            string sql = @"
                SELECT TOP 5
                       a.Title,
                       a.TargetRole,
                       a.CreatedAt
                FROM Announcements a
                INNER JOIN Users u
                        ON u.UserId = a.PostedByUserId
                       AND u.Role = 1
                ORDER BY a.CreatedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);
            rptAnnouncements.DataSource = dt;
            rptAnnouncements.DataBind();
        }

        private void LoadCourses()
        {
            string sql = @"
                SELECT c.CourseCode,
                       c.CourseName,
                       c.Credits,
                       COUNT(e.StudentId) AS EnrolledCount
                FROM Courses c
                LEFT JOIN Enrollment e
                       ON e.CourseId = c.CourseId
                      AND e.Session = @Session
                      AND e.Status = 'Active'
                GROUP BY c.CourseCode, c.CourseName, c.Credits
                ORDER BY c.CourseName";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql,
                new[] { new SqlParameter("@Session", CURRENT_SESSION) });

            rptCourses.DataSource = dt;
            rptCourses.DataBind();
        }

        private void LoadFeeStats()
        {
            lblPaidFees.Text = GetPaymentCount("Paid", false).ToString();
            lblOverdueFees.Text = GetPaymentCount("Overdue", true).ToString();
        }

        private void RegisterDashboardFeeChart()
        {
            int paid = GetPaymentCount("Paid", false);
            int pending = GetActionablePaymentCount("Pending");
            int overdue = GetPaymentCount("Overdue", true);

            string script = string.Format(
                "window.dashboardFeeData = {{ paid: {0}, pending: {1}, overdue: {2} }}; if (window.renderDashboardFeeChart) renderDashboardFeeChart(window.dashboardFeeData);",
                paid,
                pending,
                overdue);

            ClientScript.RegisterStartupScript(
                GetType(),
                "DashboardFeeChartData",
                script,
                true);
        }

        private int GetActionablePaymentCount(string status)
        {
            return GetPaymentCount(status, true);
        }

        private int GetPaymentCount(string status, bool excludeDroppedNotActiveHistory)
        {
            string sql = @"
                SELECT COUNT(*)
                FROM Fees f
                LEFT JOIN Enrollment e ON e.EnrollmentId = f.EnrollmentId
                WHERE f.Status = @Status";

            if (excludeDroppedNotActiveHistory)
            {
                sql += @"
                  AND NOT (
                        ISNULL(f.PaymentReceiptPath, '') = ''
                        AND e.EnrollmentId IS NOT NULL
                        AND ISNULL(e.Status, '') IN ('Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                  )";
            }

            object result = DatabaseHelper.ExecuteScalar(sql,
                new[] { new SqlParameter("@Status", status) });

            return ConvertDbInt(result);
        }

        private int ConvertDbInt(object value)
        {
            if (value == null || value == DBNull.Value) return 0;
            return Convert.ToInt32(value);
        }

        private void CheckUnreadNotifications()
        {
            int userId = SessionHelper.GetUserId(Session);

            object count = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @Uid AND IsRead = 0",
                new[] { new SqlParameter("@Uid", userId) });

            pnlNotifBadge.Visible = ConvertDbInt(count) > 0;
        }

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}
