using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

/// <summary>
/// Code-behind for Student/Student_Dashboard.aspx
///
/// Schema reference:
///   Enrollment  : StudentId, CourseId, Session, Semester, Status, EnrollmentDate
///   Attendance  : CourseId, AttendanceDate, StudentId, LecturerId, Status
///   Grades      : StudentId, CourseId, Type, MarksObtained, MaxMarks, WeightPercentage, Grade
///   Fees        : StudentId, Session, FeeType, Amount, Status
///   LecturerCourse : LecturerId, CourseId, Session
/// </summary>

namespace Student_Information_Management_System__SIMS_
{
    public partial class Student_Dashboard : Page
    {
        private const string CURRENT_SESSION = "April 2026";

        // ---------------------------------------------------------------
        // Page_Load
        // ---------------------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                string fullName = SessionHelper.GetFullName(Session);
                string studentId = SessionHelper.GetProfileId(Session);

                lblSidebarName.Text = fullName;
                lblAvatarInitial.Text = fullName.Length > 0 ? fullName[0].ToString().ToUpper() : "S";
                lblTopbarInitial.Text = lblAvatarInitial.Text;
                lblStudentName.Text = fullName;
                lblStudentId.Text = studentId;
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadProgramme(studentId);
                LoadGPA(studentId);
                LoadAttendance(studentId);
                LoadEnrolledCourseBadges(studentId);
                LoadOutstandingFees(studentId);
                LoadAnnouncements();
                BuildAttendanceTrendData(studentId);
                BuildGpaTrendData(studentId);
                CheckUnreadNotifications();
            }
        }

        // ---------------------------------------------------------------
        // Programme name for profile bar.
        // ---------------------------------------------------------------
        private void LoadProgramme(string studentId)
        {
            string sql = @"
                SELECT p.ProgrammeName
                FROM   StudentDetails s
                INNER JOIN Programmes p ON p.ProgrammeId = s.ProgrammeId
                WHERE  s.StudentId = @Sid";

            object result = DatabaseHelper.ExecuteScalar(sql,
                new[] { new SqlParameter("@Sid", studentId) });

            lblProgramme.Text = result?.ToString() ?? "";
        }

        // ---------------------------------------------------------------
        // GPA from Grades table (weighted).
        // ---------------------------------------------------------------
        private void LoadGPA(string studentId)
        {
            string sql = @"
                SELECT ISNULL(
                    CAST(
                        SUM((g.MarksObtained / g.MaxMarks) * g.WeightPercentage)
                        / NULLIF(SUM(g.WeightPercentage), 0)
                    AS DECIMAL(5,2)), NULL)
                FROM   Grades g
                WHERE  g.StudentId         = @Sid
                  AND  g.MarksObtained     IS NOT NULL
                  AND  g.MaxMarks          > 0
                  AND  g.WeightPercentage  IS NOT NULL";

            object result = DatabaseHelper.ExecuteScalar(sql,
                new[] { new SqlParameter("@Sid", studentId) });

            lblGPA.Text = (result == null || result == DBNull.Value) ? "N/A" : result.ToString();
        }

        // ---------------------------------------------------------------
        // Attendance % across all courses.
        // ---------------------------------------------------------------
        private void LoadAttendance(string studentId)
        {
            string sql = @"
                SELECT ISNULL(
                    CAST(
                        SUM(CASE WHEN a.Status = 'Present' THEN 1.0 ELSE 0 END)
                        * 100.0 / NULLIF(COUNT(a.AttendanceDate), 0)
                    AS DECIMAL(5,2)), 0.00)
                FROM   Attendance a
                WHERE  a.StudentId = @Sid";

            object result = DatabaseHelper.ExecuteScalar(sql,
                new[] { new SqlParameter("@Sid", studentId) });

            lblAttendance.Text = result?.ToString() ?? "0.00";
        }

        // ---------------------------------------------------------------
        // Small badge list in the stat card (top row).
        // ---------------------------------------------------------------
        private void LoadEnrolledCourseBadges(string studentId)
        {
            string sql = @"
                SELECT c.CourseCode
                FROM   Enrollment e
                INNER JOIN Courses c ON c.CourseId = e.CourseId
                WHERE  e.StudentId = @Sid
                  AND  e.Session   = @Sess
                  AND  e.Status   != 'Dropped'
                ORDER BY c.CourseCode";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] {
                new SqlParameter("@Sid",  studentId),
                new SqlParameter("@Sess", CURRENT_SESSION)
            });

            if (dt.Rows.Count == 0)
                lblNoCourses.Visible = true;
            else
            {
                rptEnrolledCourses.DataSource = dt;
                rptEnrolledCourses.DataBind();
            }
        }

        // ---------------------------------------------------------------
        // Outstanding fees.
        // ---------------------------------------------------------------
        private void LoadOutstandingFees(string studentId)
        {
            string sql = @"
                SELECT ISNULL(SUM(f.Amount), 0.00)
                FROM   Fees f
                WHERE  f.StudentId = @Sid
                  AND  f.Status IN ('Pending', 'Overdue')";

            object result = DatabaseHelper.ExecuteScalar(sql,
                new[] { new SqlParameter("@Sid", studentId) });

            decimal fees = (result != null && result != DBNull.Value)
                           ? Convert.ToDecimal(result) : 0m;
            lblFees.Text = fees.ToString("N2");
        }

        // ---------------------------------------------------------------
        // Announcements.
        // ---------------------------------------------------------------
        private void LoadAnnouncements()
        {
            string sql = @"
                SELECT TOP 4 Title, CreatedAt
                FROM   Announcements
                WHERE  TargetRole IN ('Student', 'All')
                ORDER BY CreatedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);

            if (dt.Rows.Count == 0)
                lblNoAnnouncements.Visible = true;
            else
            {
                rptAnnouncements.DataSource = dt;
                rptAnnouncements.DataBind();
            }
        }

        // ---------------------------------------------------------------
        // Attendance trend chart data (per course, current session).
        // ---------------------------------------------------------------
        private void BuildAttendanceTrendData(string studentId)
        {
            string sql = @"
                SELECT c.CourseCode,
                       ISNULL(CAST(
                           SUM(CASE WHEN a.Status = 'Present' THEN 1.0 ELSE 0 END)
                           * 100.0 / NULLIF(COUNT(a.AttendanceDate), 0)
                       AS DECIMAL(5,1)), 0) AS AttPct
                FROM   Enrollment e
                INNER JOIN Courses c    ON c.CourseId  = e.CourseId
                LEFT  JOIN Attendance a ON a.CourseId  = e.CourseId
                                      AND a.StudentId  = e.StudentId
                WHERE  e.StudentId = @Sid
                  AND  e.Session   = @Sess
                  AND  e.Status   != 'Dropped'
                GROUP BY c.CourseCode
                ORDER BY c.CourseCode";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] {
                new SqlParameter("@Sid",  studentId),
                new SqlParameter("@Sess", CURRENT_SESSION)
            });

            var labels = new StringBuilder();
            var values = new StringBuilder();

            foreach (DataRow row in dt.Rows)
            {
                if (labels.Length > 0) { labels.Append('|'); values.Append('|'); }
                labels.Append(row["CourseCode"]);
                values.Append(row["AttPct"]);
            }

            if (dt.Rows.Count == 0)
            {
                labels.Append("5022CMD|5023CMD|5024CMD");
                values.Append("75|90|95");
            }

            hdnAttendanceLabels.Value = labels.ToString();
            hdnAttendanceData.Value = values.ToString();
        }

        // ---------------------------------------------------------------
        // GPA trend chart data (per session).
        // ---------------------------------------------------------------
        private void BuildGpaTrendData(string studentId)
        {
            string sql = @"
                SELECT e.Session,
                       ISNULL(CAST(
                           SUM((g.MarksObtained / g.MaxMarks) * g.WeightPercentage)
                           / NULLIF(SUM(g.WeightPercentage), 0)
                       AS DECIMAL(5,2)), 0) AS SessionScore
                FROM   Enrollment e
                INNER JOIN Grades g ON g.StudentId = e.StudentId
                                   AND g.CourseId  = e.CourseId
                WHERE  e.StudentId        = @Sid
                  AND  g.MarksObtained    IS NOT NULL
                  AND  g.MaxMarks         > 0
                  AND  g.WeightPercentage IS NOT NULL
                GROUP BY e.Session
                ORDER BY MIN(e.EnrollmentDate)";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql,
                new[] { new SqlParameter("@Sid", studentId) });

            var labels = new StringBuilder();
            var values = new StringBuilder();

            foreach (DataRow row in dt.Rows)
            {
                if (labels.Length > 0) { labels.Append('|'); values.Append('|'); }
                labels.Append(row["Session"]);
                values.Append(row["SessionScore"]);
            }

            if (dt.Rows.Count == 0)
            {
                labels.Append("Oct 2025|Apr 2026");
                values.Append("65|80");
            }

            hdnGpaLabels.Value = labels.ToString();
            hdnGpaData.Value = values.ToString();
        }

        // ---------------------------------------------------------------
        // Notification badge.
        // ---------------------------------------------------------------
        private void CheckUnreadNotifications()
        {
            int userId = SessionHelper.GetUserId(Session);
            object count = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @Uid AND IsRead = 0",
                new[] { new SqlParameter("@Uid", userId) });

            bool hasUnread = (count != null && Convert.ToInt32(count) > 0);
            pnlNotifBadge.Visible = hasUnread;
            pnlSidebarNotifBadge.Visible = hasUnread;
        }



        // ---------------------------------------------------------------
        // Show success/error feedback above the enrollment table.
        // ---------------------------------------------------------------
        

        // ---------------------------------------------------------------
        // Logout.
        // ---------------------------------------------------------------
        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}