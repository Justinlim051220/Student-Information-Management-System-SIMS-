using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using SIMS.Helpers;

/// <summary>
/// Code-behind for Admin/Dashboard.aspx
///
/// Responsibilities:
///   - Enforce Admin-only access via SessionHelper.
///   - Load dashboard statistics from the DB.
///   - Bind the recent students and announcements repeaters.
/// </summary>
/// 

namespace Student_Information_Management_System__SIMS_
{
    public partial class Admin_Dashboard : Page
    {
        // ---------------------------------------------------------------
        // Page_Load
        // ---------------------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            // ── Guard: Admin only ──────────────────────────────────────
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                // Personalise the UI
                string fullName = SessionHelper.GetFullName(Session);
                lblWelcomeName.Text = fullName;
                lblSidebarName.Text = fullName;
                lblAvatarInitial.Text = fullName.Length > 0
                                        ? fullName[0].ToString().ToUpper()
                                        : "A";

                // Load admin profile picture for the sidebar footer.
                LoadAdminProfilePicture();

                // Today's date
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                // Load all dashboard data
                LoadStats();
                LoadRecentStudents();
                LoadAnnouncements();
                LoadCourses();
                LoadFeeStats();
                CheckUnreadNotifications();
            }
        }

        // ---------------------------------------------------------------
        // Load admin profile picture in the sidebar footer.
        // Shows uploaded photo if available, otherwise keeps the first-letter icon.
        // ---------------------------------------------------------------
        private void LoadAdminProfilePicture()
        {
            divSidebarPhoto.Visible = false;
            divSidebarInitial.Visible = true;

            try
            {
                int userId = SessionHelper.GetUserId(Session);

                object pictureObj = DatabaseHelper.ExecuteScalar(
                    @"SELECT ProfilePicture
                      FROM   HoPDetails
                      WHERE  UserId = @UserId",
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
                // If the ProfilePicture column has not been added yet,
                // dashboard still works using the first-letter avatar.
                divSidebarPhoto.Visible = false;
                divSidebarInitial.Visible = true;
            }
        }

        // ---------------------------------------------------------------
        // Load headline statistics.
        // ---------------------------------------------------------------
        private void LoadStats()
        {
            // Total active students
            object stuCount = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM StudentDetails s " +
                "INNER JOIN Users u ON u.UserId = s.UserId WHERE u.IsActive = 1");
            lblTotalStudents.Text = stuCount?.ToString() ?? "0";

            // Total active lecturers
            object lecCount = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM LecturerDetails l " +
                "INNER JOIN Users u ON u.UserId = l.UserId WHERE u.IsActive = 1");
            lblTotalLecturers.Text = lecCount?.ToString() ?? "0";

            // Total programmes
            object progCount = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Programmes");
            lblTotalProgrammes.Text = progCount?.ToString() ?? "0";

            // Pending fee records
            object pendingCount = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Fees WHERE Status IN ('Pending', 'Overdue')");
            lblPendingFees.Text = pendingCount?.ToString() ?? "0";
        }

        // ---------------------------------------------------------------
        // Load the 5 most recently enrolled students.
        // ---------------------------------------------------------------
        private void LoadRecentStudents()
        {
            string sql = @"
                SELECT TOP 5
                       s.StudentId,
                       s.FirstName + ' ' + s.LastName AS FullName,
                       p.ProgrammeCode,
                       s.EnrollmentDate
                FROM   StudentDetails s
                INNER JOIN Programmes p ON p.ProgrammeId = s.ProgrammeId
                ORDER BY s.EnrollmentDate DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);
            rptRecentStudents.DataSource = dt;
            rptRecentStudents.DataBind();
        }

        // ---------------------------------------------------------------
        // Load the 5 most recent announcements.
        // ---------------------------------------------------------------
        private void LoadAnnouncements()
        {
            // Admin Dashboard should only show announcements posted by Admin users.
            // Lecturer announcements use the same Announcements table, but they should
            // stay on the Lecturer side and must not appear in the Admin dashboard.
            string sql = @"
                SELECT TOP 5
                       a.Title,
                       a.TargetRole,
                       a.CreatedAt
                FROM   Announcements a
                INNER JOIN Users u
                        ON u.UserId = a.PostedByUserId
                       AND u.Role = 1
                ORDER BY a.CreatedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);
            rptAnnouncements.DataSource = dt;
            rptAnnouncements.DataBind();
        }

        // ---------------------------------------------------------------
        // Load courses with enrollment counts for the current session.
        // ---------------------------------------------------------------
        private void LoadCourses()
        {
            string sql = @"
                SELECT   c.CourseCode,
                         c.CourseName,
                         c.Credits,
                         COUNT(e.StudentId) AS EnrolledCount
                FROM     Courses c
                LEFT JOIN Enrollment e
                       ON e.CourseId = c.CourseId
                      AND e.Session  = 'April 2026'
                GROUP BY c.CourseCode, c.CourseName, c.Credits
                ORDER BY c.CourseName";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);
            rptCourses.DataSource = dt;
            rptCourses.DataBind();
        }

        // ---------------------------------------------------------------
        // Load fee status counts.
        // ---------------------------------------------------------------
        private void LoadFeeStats()
        {
            object paid = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Fees WHERE Status = 'Paid'");
            lblPaidFees.Text = paid?.ToString() ?? "0";

            object overdue = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Fees WHERE Status = 'Overdue'");
            lblOverdueFees.Text = overdue?.ToString() ?? "0";
        }

        // ---------------------------------------------------------------
        // Show notification dot if there are unread notifications.
        // ---------------------------------------------------------------
        private void CheckUnreadNotifications()
        {
            int userId = SessionHelper.GetUserId(Session);
            object count = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @Uid AND IsRead = 0",
                new[] { new System.Data.SqlClient.SqlParameter("@Uid", userId) });

            pnlNotifBadge.Visible = (count != null && Convert.ToInt32(count) > 0);
        }

        // ---------------------------------------------------------------
        // Logout button
        // ---------------------------------------------------------------
        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}
