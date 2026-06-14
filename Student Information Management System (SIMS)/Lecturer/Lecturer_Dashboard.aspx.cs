using System;
using System.Data;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class Lecturer_Dashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireLecturer(Session, Response);

            if (!IsPostBack)
            {
                string fullName = SessionHelper.GetFullName(Session);

                lblWelcomeName.Text = string.IsNullOrWhiteSpace(fullName)
                    ? "Lecturer"
                    : fullName;

                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadStats();
                LoadMyCourses();
                LoadAnnouncements();
                LoadAttendanceSummary();
                LoadAtRiskStudents();
                CheckUnreadNotifications();
            }
        }

        private string GetLecturerId()
        {
            int userId = SessionHelper.GetUserId(Session);

            object lecId = DatabaseHelper.ExecuteScalar(
                "SELECT LecturerId FROM LecturerDetails WHERE UserId = @Uid",
                new[] { new System.Data.SqlClient.SqlParameter("@Uid", userId) });

            return lecId == null ? string.Empty : lecId.ToString();
        }

        private void LoadStats()
        {
            string lecturerId = GetLecturerId();

            object courseCount = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM LecturerCourse WHERE LecturerId = @Lid AND Session = 'April 2026'",
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });

            lblTotalCourses.Text = courseCount == null ? "0" : courseCount.ToString();

            object stuCount = DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(DISTINCT e.StudentId)
                FROM Enrollment e
                INNER JOIN LecturerCourse lc
                    ON lc.CourseId = e.CourseId
                    AND lc.Session = e.Session
                WHERE lc.LecturerId = @Lid
                    AND lc.Session = 'April 2026'",
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });

            lblTotalStudents.Text = stuCount == null ? "0" : stuCount.ToString();

            object avgAtt = DatabaseHelper.ExecuteScalar(@"
                SELECT ISNULL(
                    CAST(
                        100.0 * SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END)
                        / NULLIF(COUNT(a.StudentId), 0)
                    AS DECIMAL(5,1)), 0)
                FROM Attendance a
                WHERE a.LecturerId = @Lid",
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });

            lblAvgAttendance.Text = (avgAtt == null ? "0" : avgAtt.ToString()) + "%";

            object atRisk = DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(*)
                FROM (
                    SELECT 
                        a.StudentId,
                        a.CourseId,
                        a.Session,
                        COUNT(*) AS RollCallCount,
                        CAST(
                            100.0 * SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END)
                            / NULLIF(COUNT(*), 0)
                        AS DECIMAL(5,1)) AS AttPct
                    FROM Attendance a
                    WHERE a.LecturerId = @Lid
                        AND a.Session = 'April 2026'
                    GROUP BY a.StudentId, a.CourseId, a.Session
                ) sub
                WHERE sub.RollCallCount >= 14
                    AND sub.AttPct < 80",
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });

            lblAtRiskCount.Text = atRisk == null ? "0" : atRisk.ToString();
        }

        private void LoadMyCourses()
        {
            string lecturerId = GetLecturerId();

            string sql = @"
                SELECT 
                    c.CourseCode,
                    c.CourseName,
                    c.Credits,
                    COUNT(e.StudentId) AS EnrolledCount
                FROM LecturerCourse lc
                INNER JOIN Courses c ON c.CourseId = lc.CourseId
                LEFT JOIN Enrollment e 
                    ON e.CourseId = c.CourseId
                    AND e.Session = lc.Session
                WHERE lc.LecturerId = @Lid
                    AND lc.Session = 'April 2026'
                GROUP BY c.CourseCode, c.CourseName, c.Credits
                ORDER BY c.CourseName";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql,
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });

            rptMyCourses.DataSource = dt;
            rptMyCourses.DataBind();
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
                    AND u.Role = 2
                ORDER BY a.CreatedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);

            rptAnnouncements.DataSource = dt;
            rptAnnouncements.DataBind();
        }

        private void LoadAttendanceSummary()
        {
            string lecturerId = GetLecturerId();

            string sql = @"
                SELECT 
                    c.CourseCode,
                    COUNT(DISTINCT a.AttendanceDate) AS TotalClasses,
                    CAST(
                        100.0 * SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END)
                        / NULLIF(COUNT(a.StudentId), 0)
                    AS DECIMAL(5,1)) AS AttendancePct
                FROM Attendance a
                INNER JOIN Courses c ON c.CourseId = a.CourseId
                WHERE a.LecturerId = @Lid
                GROUP BY c.CourseCode
                ORDER BY c.CourseCode";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql,
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });

            rptAttendanceSummary.DataSource = dt;
            rptAttendanceSummary.DataBind();
        }

        private void LoadAtRiskStudents()
        {
            string lecturerId = GetLecturerId();

            string sql = @"
                SELECT TOP 8
                    sub.FullName,
                    sub.CourseCode,
                    sub.AttendancePct
                FROM (
                    SELECT 
                        s.FirstName + ' ' + s.LastName AS FullName,
                        c.CourseCode,
                        COUNT(*) AS RollCallCount,
                        CAST(
                            100.0 * SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END)
                            / NULLIF(COUNT(a.StudentId), 0)
                        AS DECIMAL(5,1)) AS AttendancePct
                    FROM Attendance a
                    INNER JOIN StudentDetails s ON s.StudentId = a.StudentId
                    INNER JOIN Courses c ON c.CourseId = a.CourseId
                    WHERE a.LecturerId = @Lid
                        AND a.Session = 'April 2026'
                    GROUP BY s.FirstName, s.LastName, c.CourseCode
                ) sub
                WHERE sub.RollCallCount >= 14
                    AND sub.AttendancePct < 80
                ORDER BY sub.AttendancePct ASC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql,
                new[] { new System.Data.SqlClient.SqlParameter("@Lid", lecturerId) });

            rptAtRiskStudents.DataSource = dt;
            rptAtRiskStudents.DataBind();
        }
        private void CheckUnreadNotifications()
        {
            int userId = SessionHelper.GetUserId(Session);

            object count = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @Uid AND IsRead = 0",
                new[] { new System.Data.SqlClient.SqlParameter("@Uid", userId) });

            pnlNotifBadge.Visible = count != null && Convert.ToInt32(count) > 0;
        }
    }
}