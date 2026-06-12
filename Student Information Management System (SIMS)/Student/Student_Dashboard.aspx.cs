using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class Student_Dashboard : Page
    {
        private const string CURRENT_SESSION = "April 2026";

        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                string fullName = SessionHelper.GetFullName(Session);
                string studentId = SessionHelper.GetProfileId(Session);

                string initial = !string.IsNullOrWhiteSpace(fullName)
                    ? fullName.Substring(0, 1).ToUpper()
                    : "S";

                lblTopbarInitial.Text = initial;
                lblStudentName.Text = string.IsNullOrWhiteSpace(fullName) ? "Student" : fullName;
                lblStudentId.Text = studentId;
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadProgramme(studentId);
                LoadGPA(studentId);
                LoadCGPA(studentId);
                LoadAttendance(studentId);
                LoadEnrolledCourseBadges(studentId);
                LoadOutstandingFees(studentId);
                LoadAnnouncements();
                BuildAttendanceTrendData(studentId);
                BuildGpaTrendData(studentId);
                CheckUnreadNotifications();
            }
        }

        private void LoadProgramme(string studentId)
        {
            string sql = @"
                SELECT p.ProgrammeName
                FROM StudentDetails s
                INNER JOIN Programmes p ON p.ProgrammeId = s.ProgrammeId
                WHERE s.StudentId = @Sid";

            object result = DatabaseHelper.ExecuteScalar(sql,
                new[] { new SqlParameter("@Sid", studentId) });

            lblProgramme.Text = result == null || result == DBNull.Value ? "" : result.ToString();
        }

        private void LoadGPA(string studentId)
        {
            string checkSql = "SELECT CASE WHEN OBJECT_ID('dbo.Results', 'U') IS NULL THEN 0 ELSE 1 END";
            object exists = DatabaseHelper.ExecuteScalar(checkSql);

            if (exists != null && exists != DBNull.Value && Convert.ToInt32(exists) == 1)
            {
                string resultSql = @"
                    SELECT TOP 1 CAST(GPA AS DECIMAL(4,2))
                    FROM Results
                    WHERE StudentId = @Sid
                    ORDER BY PublishedAt DESC, ResultId DESC";

                object storedGpa = DatabaseHelper.ExecuteScalar(resultSql,
                    new[] { new SqlParameter("@Sid", studentId) });

                if (storedGpa != null && storedGpa != DBNull.Value)
                {
                    lblGPA.Text = Convert.ToDecimal(storedGpa).ToString("0.00");
                    return;
                }
            }

            string sql = @"
                SELECT ISNULL(
                    CAST(
                        SUM((g.MarksObtained / NULLIF(g.MaxMarks, 0)) * g.WeightPercentage)
                        / NULLIF(SUM(g.WeightPercentage), 0)
                    AS DECIMAL(5,2)), NULL)
                FROM Grades g
                WHERE g.StudentId = @Sid
                  AND g.MarksObtained IS NOT NULL
                  AND g.MaxMarks > 0
                  AND g.WeightPercentage IS NOT NULL";

            object result = DatabaseHelper.ExecuteScalar(sql,
                new[] { new SqlParameter("@Sid", studentId) });

            lblGPA.Text = result == null || result == DBNull.Value
                ? "N/A"
                : Convert.ToDecimal(result).ToString("0.00");
        }

        private void LoadCGPA(string studentId)
        {
            string checkSql = "SELECT CASE WHEN OBJECT_ID('dbo.Results', 'U') IS NULL THEN 0 ELSE 1 END";
            object exists = DatabaseHelper.ExecuteScalar(checkSql);

            if (exists == null || exists == DBNull.Value || Convert.ToInt32(exists) == 0)
            {
                lblCGPA.Text = "N/A";
                return;
            }

            string sql = @"
                SELECT TOP 1 CAST(CGPA AS DECIMAL(4,2))
                FROM Results
                WHERE StudentId = @Sid
                ORDER BY PublishedAt DESC, ResultId DESC";

            object result = DatabaseHelper.ExecuteScalar(sql,
                new[] { new SqlParameter("@Sid", studentId) });

            lblCGPA.Text = result == null || result == DBNull.Value
                ? "N/A"
                : Convert.ToDecimal(result).ToString("0.00");
        }

        private void LoadAttendance(string studentId)
        {
            string sql = @"
                SELECT ISNULL(
                    CAST(
                        SUM(CASE WHEN a.Status = 'Present' THEN 1.0 ELSE 0 END)
                        * 100.0 / NULLIF(COUNT(a.AttendanceDate), 0)
                    AS DECIMAL(5,2)), 0.00)
                FROM Attendance a
                WHERE a.StudentId = @Sid";

            object result = DatabaseHelper.ExecuteScalar(sql,
                new[] { new SqlParameter("@Sid", studentId) });

            lblAttendance.Text = result == null || result == DBNull.Value
                ? "0.00"
                : Convert.ToDecimal(result).ToString("0.00");
        }

        private void LoadEnrolledCourseBadges(string studentId)
        {
            string sql = @"
                SELECT c.CourseCode
                FROM Enrollment e
                INNER JOIN Courses c ON c.CourseId = e.CourseId
                WHERE e.StudentId = @Sid
                  AND e.Session = @Sess
                  AND e.Status != 'Dropped'
                ORDER BY c.CourseCode";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@Sid", studentId),
                new SqlParameter("@Sess", CURRENT_SESSION)
            });

            if (dt.Rows.Count == 0)
            {
                lblNoCourses.Visible = true;
                rptEnrolledCourses.DataSource = null;
                rptEnrolledCourses.DataBind();
            }
            else
            {
                lblNoCourses.Visible = false;
                rptEnrolledCourses.DataSource = dt;
                rptEnrolledCourses.DataBind();
            }
        }

        private void LoadOutstandingFees(string studentId)
        {
            string sql = @"
                SELECT ISNULL(SUM(f.Amount), 0.00)
                FROM Fees f
                WHERE f.StudentId = @Sid
                  AND f.Status IN ('Pending', 'Overdue')";

            object result = DatabaseHelper.ExecuteScalar(sql,
                new[] { new SqlParameter("@Sid", studentId) });

            decimal fees = result != null && result != DBNull.Value
                ? Convert.ToDecimal(result)
                : 0m;

            lblFees.Text = fees.ToString("N2");
        }

        private void LoadAnnouncements()
        {
            string sql = @"
                SELECT TOP 4 Title, CreatedAt
                FROM Announcements
                WHERE TargetRole IN ('Student', 'All')
                ORDER BY CreatedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);

            if (dt.Rows.Count == 0)
            {
                lblNoAnnouncements.Visible = true;
                rptAnnouncements.DataSource = null;
                rptAnnouncements.DataBind();
            }
            else
            {
                lblNoAnnouncements.Visible = false;
                rptAnnouncements.DataSource = dt;
                rptAnnouncements.DataBind();
            }
        }

        private void BuildAttendanceTrendData(string studentId)
        {
            string sql = @"
                SELECT c.CourseCode,
                       ISNULL(CAST(
                           SUM(CASE WHEN a.Status = 'Present' THEN 1.0 ELSE 0 END)
                           * 100.0 / NULLIF(COUNT(a.AttendanceDate), 0)
                       AS DECIMAL(5,1)), 0) AS AttPct
                FROM Enrollment e
                INNER JOIN Courses c ON c.CourseId = e.CourseId
                LEFT JOIN Attendance a ON a.CourseId = e.CourseId
                                      AND a.StudentId = e.StudentId
                WHERE e.StudentId = @Sid
                  AND e.Session = @Sess
                  AND e.Status != 'Dropped'
                GROUP BY c.CourseCode
                ORDER BY c.CourseCode";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@Sid", studentId),
                new SqlParameter("@Sess", CURRENT_SESSION)
            });

            StringBuilder labels = new StringBuilder();
            StringBuilder values = new StringBuilder();

            foreach (DataRow row in dt.Rows)
            {
                if (labels.Length > 0)
                {
                    labels.Append('|');
                    values.Append('|');
                }

                labels.Append(row["CourseCode"]);
                values.Append(row["AttPct"]);
            }

            if (dt.Rows.Count == 0)
            {
                labels.Append("No Data");
                values.Append("0");
            }

            hdnAttendanceLabels.Value = labels.ToString();
            hdnAttendanceData.Value = values.ToString();
        }

        private void BuildGpaTrendData(string studentId)
        {
            string checkSql = "SELECT CASE WHEN OBJECT_ID('dbo.Results', 'U') IS NULL THEN 0 ELSE 1 END";
            object exists = DatabaseHelper.ExecuteScalar(checkSql);

            if (exists == null || exists == DBNull.Value || Convert.ToInt32(exists) == 0)
            {
                hdnGpaLabels.Value = "No Data";
                hdnGpaData.Value = "0";
                return;
            }

            string sql = @"
                SELECT Session,
                       CAST(AVG(GPA) AS DECIMAL(4,2)) AS GPA
                FROM Results
                WHERE StudentId = @Sid
                GROUP BY Session
                ORDER BY MIN(PublishedAt)";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql,
                new[] { new SqlParameter("@Sid", studentId) });

            StringBuilder labels = new StringBuilder();
            StringBuilder values = new StringBuilder();

            foreach (DataRow row in dt.Rows)
            {
                if (labels.Length > 0)
                {
                    labels.Append('|');
                    values.Append('|');
                }

                labels.Append(row["Session"]);
                values.Append(row["GPA"]);
            }

            if (dt.Rows.Count == 0)
            {
                labels.Append("No Data");
                values.Append("0");
            }

            hdnGpaLabels.Value = labels.ToString();
            hdnGpaData.Value = values.ToString();
        }

        private void CheckUnreadNotifications()
        {
            int userId = SessionHelper.GetUserId(Session);

            object count = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @Uid AND IsRead = 0",
                new[] { new SqlParameter("@Uid", userId) });

            bool hasUnread = count != null && count != DBNull.Value && Convert.ToInt32(count) > 0;
            pnlNotifBadge.Visible = hasUnread;
        }
    }
}