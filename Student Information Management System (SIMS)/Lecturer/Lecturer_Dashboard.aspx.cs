using System;
using System.Data;
using System.Web.UI;
using SIMS.Helpers;

/// <summary>
/// Code-behind for Lecturer/Lecturer_Dashboard.aspx
///
/// Responsibilities:
///   - Enforce Lecturer-only access via SessionHelper.
///   - Load lecturer-specific dashboard statistics from the DB.
///   - Bind repeaters: My Courses, Attendance Summary, At-Risk Students,
///     Recent Grades, Announcements.
/// </summary>

namespace Student_Information_Management_System__SIMS_
{
    public partial class Lecturer_Dashboard : Page
    {
        // ---------------------------------------------------------------
        // Page_Load
        // ---------------------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            // ── Guard: Lecturer only ───────────────────────────────────
            SessionHelper.RequireLecturer(Session, Response);

            if (!IsPostBack)
            {
                // Personalise the UI
                string fullName = SessionHelper.GetFullName(Session);
                lblWelcomeName.Text = fullName;
                lblSidebarName.Text = fullName;
                lblAvatarInitial.Text = fullName.Length > 0
                                        ? fullName[0].ToString().ToUpper()
                                        : "L";

                // Today's date
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                // Load all dashboard data
                LoadStats();
                LoadMyCourses();
                LoadAnnouncements();
                LoadAttendanceSummary();
                LoadAtRiskStudents();
                LoadRecentGrades();
                CheckUnreadNotifications();
            }
        }

        // ---------------------------------------------------------------
        // Retrieve the current lecturer's ID from the session.
        // ---------------------------------------------------------------
        private string GetLecturerId()
        {
            int userId = SessionHelper.GetUserId(Session);
            object lecId = DatabaseHelper.ExecuteScalar(
                "SELECT LecturerId FROM LecturerDetails WHERE UserId = @Uid",
                new[] { new System.Data.SqlClient.SqlParameter("@Uid", userId) });
            return lecId?.ToString() ?? string.Empty;
        }

        // ---------------------------------------------------------------
        // Load headline statistics for this lecturer.
        // ---------------------------------------------------------------
        private void LoadStats()
        {
            string lecturerId = GetLecturerId();

            // Number of courses assigned this session
            object courseCount = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM LecturerCourse " +
                "WHERE LecturerId = @Lid AND Session = 'April 2026'",
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });
            lblTotalCourses.Text = courseCount?.ToString() ?? "0";

            // Total distinct students across all assigned courses this session
            object stuCount = DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(DISTINCT e.StudentId)
                FROM   Enrollment e
                INNER JOIN LecturerCourse lc
                       ON lc.CourseId = e.CourseId
                      AND lc.Session  = e.Session
                WHERE  lc.LecturerId = @Lid
                  AND  lc.Session    = 'April 2026'",
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });
            lblTotalStudents.Text = stuCount?.ToString() ?? "0";

            // Average attendance % across all this lecturer's courses
            object avgAtt = DatabaseHelper.ExecuteScalar(@"
                SELECT ISNULL(
                    CAST(
                        100.0 * SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END)
                        / NULLIF(COUNT(a.StudentId), 0)
                    AS DECIMAL(5,1)), 0)
                FROM   Attendance a
                WHERE  a.LecturerId = @Lid",
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });
            lblAvgAttendance.Text = (avgAtt?.ToString() ?? "0") + "%";

            // Count of at-risk students (attendance < 80%) across this lecturer's courses
            object atRisk = DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(*)
                FROM (
                    SELECT a.StudentId, a.CourseId,
                           CAST(100.0 * SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END)
                                / NULLIF(COUNT(*), 0) AS DECIMAL(5,1)) AS AttPct
                    FROM   Attendance a
                    WHERE  a.LecturerId = @Lid
                    GROUP BY a.StudentId, a.CourseId
                ) sub
                WHERE sub.AttPct < 80",
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });
            lblAtRiskCount.Text = atRisk?.ToString() ?? "0";
        }

        // ---------------------------------------------------------------
        // Load courses assigned to this lecturer for the current session.
        // ---------------------------------------------------------------
        private void LoadMyCourses()
        {
            string lecturerId = GetLecturerId();

            string sql = @"
                SELECT   c.CourseCode,
                         c.CourseName,
                         c.Credits,
                         COUNT(e.StudentId) AS EnrolledCount
                FROM     LecturerCourse lc
                INNER JOIN Courses c    ON c.CourseId  = lc.CourseId
                LEFT  JOIN Enrollment e ON e.CourseId  = c.CourseId
                                      AND e.Session    = lc.Session
                WHERE    lc.LecturerId = @Lid
                  AND    lc.Session    = 'April 2026'
                GROUP BY c.CourseCode, c.CourseName, c.Credits
                ORDER BY c.CourseName";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql,
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });
            rptMyCourses.DataSource = dt;
            rptMyCourses.DataBind();
        }

        // ---------------------------------------------------------------
        // Load the 5 most recent lecturer-created announcements only.
        // Admin-created announcements are separated from lecturer announcements
        // because both roles share the same Announcements table.
        // ---------------------------------------------------------------
        private void LoadAnnouncements()
        {
            string sql = @"
                SELECT TOP 5
                       a.Title,
                       a.TargetRole,
                       a.CreatedAt
                FROM   Announcements a
                INNER JOIN Users u
                        ON u.UserId = a.PostedByUserId
                       AND u.Role = 2
                ORDER BY a.CreatedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);
            rptAnnouncements.DataSource = dt;
            rptAnnouncements.DataBind();
        }

        // ---------------------------------------------------------------
        // Load per-course attendance summary for this lecturer.
        // ---------------------------------------------------------------
        private void LoadAttendanceSummary()
        {
            string lecturerId = GetLecturerId();

            string sql = @"
                SELECT   c.CourseCode,
                         COUNT(DISTINCT a.AttendanceDate) AS TotalClasses,
                         CAST(
                             100.0 * SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END)
                             / NULLIF(COUNT(a.StudentId), 0)
                         AS DECIMAL(5,1)) AS AttendancePct
                FROM     Attendance a
                INNER JOIN Courses c ON c.CourseId = a.CourseId
                WHERE    a.LecturerId = @Lid
                GROUP BY c.CourseCode
                ORDER BY c.CourseCode";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql,
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });
            rptAttendanceSummary.DataSource = dt;
            rptAttendanceSummary.DataBind();
        }

        // ---------------------------------------------------------------
        // Load students with attendance below 80% (at-risk).
        // ---------------------------------------------------------------
        private void LoadAtRiskStudents()
        {
            string lecturerId = GetLecturerId();

            string sql = @"
                SELECT TOP 8
                       sub.FullName,
                       sub.CourseCode,
                       sub.AttendancePct
                FROM (
                    SELECT s.FirstName + ' ' + s.LastName AS FullName,
                           c.CourseCode,
                           CAST(
                               100.0 * SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END)
                               / NULLIF(COUNT(a.StudentId), 0)
                           AS DECIMAL(5,1)) AS AttendancePct
                    FROM   Attendance a
                    INNER JOIN StudentDetails s ON s.StudentId = a.StudentId
                    INNER JOIN Courses        c ON c.CourseId  = a.CourseId
                    WHERE  a.LecturerId = @Lid
                    GROUP BY s.FirstName, s.LastName, c.CourseCode
                ) sub
                WHERE  sub.AttendancePct < 80
                ORDER BY sub.AttendancePct ASC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql,
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });
            rptAtRiskStudents.DataSource = dt;
            rptAtRiskStudents.DataBind();
        }

        // ---------------------------------------------------------------
        // Load the 8 most recently submitted grades entered by this lecturer
        // (matched via the courses this lecturer teaches).
        // ---------------------------------------------------------------
        private void LoadRecentGrades()
        {
            string lecturerId = GetLecturerId();

            string sql = @"
                SELECT TOP 8
                       s.FirstName + ' ' + s.LastName AS FullName,
                       c.CourseCode,
                       g.Type,
                       g.Title,
                       g.MarksObtained,
                       g.MaxMarks,
                       g.Grade,
                       g.SubmittedAt
                FROM   Grades g
                INNER JOIN StudentDetails s ON s.StudentId = g.StudentId
                INNER JOIN Courses        c ON c.CourseId  = g.CourseId
                INNER JOIN LecturerCourse lc
                       ON lc.CourseId    = g.CourseId
                      AND lc.LecturerId  = @Lid
                      AND lc.Session     = 'April 2026'
                WHERE  g.SubmittedAt IS NOT NULL
                ORDER BY g.SubmittedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql,
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });
            rptRecentGrades.DataSource = dt;
            rptRecentGrades.DataBind();
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