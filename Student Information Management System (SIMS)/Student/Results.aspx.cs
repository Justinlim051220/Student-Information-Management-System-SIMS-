using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Student
{
    public partial class Results : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
                LoadStudentMetadata();
                LoadSessionFilter();
                ResetResultDisplay("Please select an academic session and semester, then click View Results.");
                CheckNotificationsBadge();
            }
        }

        private string CurrentStudentId
        {
            get
            {
                string studentId = SessionHelper.GetProfileId(Session);
                if (!string.IsNullOrWhiteSpace(studentId))
                    return studentId;

                object result = DatabaseHelper.ExecuteScalar(
                    "SELECT StudentId FROM StudentDetails WHERE UserId = @UserId",
                    new[] { new SqlParameter("@UserId", CurrentUserId) });

                return result == null || result == DBNull.Value ? "" : result.ToString();
            }
        }

        private int CurrentUserId
        {
            get { return SessionHelper.GetUserId(Session); }
        }

        private void LoadStudentMetadata()
        {
            string fullName = SessionHelper.GetFullName(Session);
            lblSidebarName.Text = string.IsNullOrWhiteSpace(fullName) ? "Student Account" : fullName;

            if (!string.IsNullOrWhiteSpace(fullName))
                lblAvatarInitial.Text = fullName.Substring(0, 1).ToUpper();
        }

        private void LoadSessionFilter()
        {
            string sql = @"
                SELECT DISTINCT Session
                FROM Enrollment
                WHERE StudentId = @StudentId
                  AND Status IN ('Active', 'Completed')
                ORDER BY Session DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@StudentId", CurrentStudentId)
            });

            ddlSession.DataSource = dt;
            ddlSession.DataTextField = "Session";
            ddlSession.DataValueField = "Session";
            ddlSession.DataBind();
            ddlSession.Items.Insert(0, new ListItem("-- Select Academic Session --", ""));
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(ddlSession.SelectedValue) || string.IsNullOrWhiteSpace(ddlSemester.SelectedValue))
            {
                ResetResultDisplay("Please select both academic session and semester before viewing results.");
                return;
            }

            GenerateResultIfReady();
            LoadStoredResults();
            CheckNotificationsBadge();
        }

        private void GenerateResultIfReady()
        {
            string studentId = CurrentStudentId;
            string session = ddlSession.SelectedValue;
            int semester = Convert.ToInt32(ddlSemester.SelectedValue);

            int enrolledCourseCount = Convert.ToInt32(DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(*)
                FROM Enrollment
                WHERE StudentId = @StudentId
                  AND Session = @Session
                  AND Semester = @Semester
                  AND Status IN ('Active', 'Completed')",
                new[]
                {
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@Semester", semester)
                }));

            if (enrolledCourseCount == 0)
                return;

            int incompleteCourseCount = Convert.ToInt32(DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(*)
                FROM Enrollment e
                WHERE e.StudentId = @StudentId
                  AND e.Session = @Session
                  AND e.Semester = @Semester
                  AND e.Status IN ('Active', 'Completed')
                  AND (
                        NOT EXISTS (
                            SELECT 1
                            FROM Grades g
                            WHERE g.StudentId = e.StudentId
                              AND g.CourseId = e.CourseId
                        )
                        OR EXISTS (
                            SELECT 1
                            FROM Grades g
                            WHERE g.StudentId = e.StudentId
                              AND g.CourseId = e.CourseId
                              AND g.MarksObtained IS NULL
                        )
                        OR (
                            SELECT ISNULL(SUM(ISNULL(g.WeightPercentage, 0)), 0)
                            FROM Grades g
                            WHERE g.StudentId = e.StudentId
                              AND g.CourseId = e.CourseId
                        ) < 100
                      )",
                new[]
                {
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@Semester", semester)
                }));

            if (incompleteCourseCount > 0)
                return;

            DataTable courseDt = DatabaseHelper.ExecuteQuery(@"
                SELECT
                    e.CourseId,
                    c.CourseCode + ' - ' + c.CourseName AS CourseDisplay,
                    c.Credits,
                    CAST((SUM((CAST(g.MarksObtained AS DECIMAL(10,2)) / NULLIF(CAST(g.MaxMarks AS DECIMAL(10,2)), 0)) * ISNULL(g.WeightPercentage, 0))
                          / NULLIF(SUM(ISNULL(g.WeightPercentage, 0)), 0)) * 100 AS DECIMAL(5,2)) AS FinalMark
                FROM Enrollment e
                INNER JOIN Courses c ON c.CourseId = e.CourseId
                INNER JOIN Grades g ON g.StudentId = e.StudentId AND g.CourseId = e.CourseId
                WHERE e.StudentId = @StudentId
                  AND e.Session = @Session
                  AND e.Semester = @Semester
                  AND e.Status IN ('Active', 'Completed')
                GROUP BY e.CourseId, c.CourseCode, c.CourseName, c.Credits
                ORDER BY c.CourseCode",
                new[]
                {
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@Semester", semester)
                });

            if (courseDt.Rows.Count == 0)
                return;

            decimal totalQualityPoints = 0;
            int totalCredits = 0;

            foreach (DataRow row in courseDt.Rows)
            {
                decimal mark = Convert.ToDecimal(row["FinalMark"]);
                int credits = Convert.ToInt32(row["Credits"]);
                decimal gradePoint = GetGradePoints(GetLetterGrade(mark));

                totalQualityPoints += gradePoint * credits;
                totalCredits += credits;
            }

            decimal gpa = totalCredits > 0 ? Math.Round(totalQualityPoints / totalCredits, 2) : 0;

            // Replace the selected semester result only. This keeps the table clean when lecturers edit marks later.
            DatabaseHelper.ExecuteNonQuery(@"
                DELETE FROM Results
                WHERE StudentId = @StudentId
                  AND Session = @Session
                  AND Semester = @Semester",
                new[]
                {
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@Semester", semester)
                });

            decimal previousQualityPoints = 0;
            int previousCredits = 0;

            DataTable previousDt = DatabaseHelper.ExecuteQuery(@"
                SELECT DISTINCT Session, Semester, CourseId, GradePoint, Credits
                FROM Results
                WHERE StudentId = @StudentId",
                new[] { new SqlParameter("@StudentId", studentId) });

            foreach (DataRow row in previousDt.Rows)
            {
                int credits = Convert.ToInt32(row["Credits"]);
                decimal gradePoint = Convert.ToDecimal(row["GradePoint"]);
                previousQualityPoints += gradePoint * credits;
                previousCredits += credits;
            }

            decimal cgpa = (previousCredits + totalCredits) > 0
                ? Math.Round((previousQualityPoints + totalQualityPoints) / (previousCredits + totalCredits), 2)
                : gpa;

            foreach (DataRow row in courseDt.Rows)
            {
                decimal mark = Convert.ToDecimal(row["FinalMark"]);
                string grade = GetLetterGrade(mark);
                decimal gradePoint = GetGradePoints(grade);

                DatabaseHelper.ExecuteNonQuery(@"
                    INSERT INTO Results
                    (StudentId, Session, Semester, CourseId, FinalMark, Grade, GradePoint, Credits, GPA, CGPA, ResultStatus, PublishedAt)
                    VALUES
                    (@StudentId, @Session, @Semester, @CourseId, @FinalMark, @Grade, @GradePoint, @Credits, @GPA, @CGPA, 'Published', GETDATE())",
                    new[]
                    {
                        new SqlParameter("@StudentId", studentId),
                        new SqlParameter("@Session", session),
                        new SqlParameter("@Semester", semester),
                        new SqlParameter("@CourseId", Convert.ToInt32(row["CourseId"])),
                        new SqlParameter("@FinalMark", mark),
                        new SqlParameter("@Grade", grade),
                        new SqlParameter("@GradePoint", gradePoint),
                        new SqlParameter("@Credits", Convert.ToInt32(row["Credits"])),
                        new SqlParameter("@GPA", gpa),
                        new SqlParameter("@CGPA", cgpa)
                    });
            }
        }

        private void LoadStoredResults()
        {
            string studentId = CurrentStudentId;
            string session = ddlSession.SelectedValue;
            int semester = Convert.ToInt32(ddlSemester.SelectedValue);

            DataTable dt = DatabaseHelper.ExecuteQuery(@"
                SELECT
                    r.ResultId,
                    c.CourseCode + ' - ' + c.CourseName AS CourseDisplay,
                    r.Credits,
                    r.FinalMark,
                    r.Grade,
                    r.GradePoint,
                    r.GPA,
                    r.CGPA,
                    r.ResultStatus,
                    r.PublishedAt
                FROM Results r
                INNER JOIN Courses c ON c.CourseId = r.CourseId
                WHERE r.StudentId = @StudentId
                  AND r.Session = @Session
                  AND r.Semester = @Semester
                ORDER BY c.CourseCode",
                new[]
                {
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@Semester", semester)
                });

            if (dt.Rows.Count == 0)
            {
                ResetResultDisplay("Results Not Available Yet. Some course marks have not been finalized by lecturers, or no active course was found for this selection.");
                return;
            }

            rptGrades.DataSource = dt;
            rptGrades.DataBind();

            pnlResults.Visible = true;
            pnlEmpty.Visible = false;

            int totalCredits = 0;
            foreach (DataRow row in dt.Rows)
                totalCredits += Convert.ToInt32(row["Credits"]);

            lblTotalCredits.Text = totalCredits.ToString();
            lblGPA.Text = Convert.ToDecimal(dt.Rows[0]["GPA"]).ToString("0.00");
            lblCGPA.Text = Convert.ToDecimal(dt.Rows[0]["CGPA"]).ToString("0.00");
        }

        private void ResetResultDisplay(string message)
        {
            DataTable empty = new DataTable();
            rptGrades.DataSource = empty;
            rptGrades.DataBind();

            pnlResults.Visible = true;
            pnlEmpty.Visible = true;
            lblGPA.Text = "0.00";
            lblCGPA.Text = "0.00";
            lblTotalCredits.Text = "0";

            // The panel already contains a general empty-state message in the ASPX.
            // Keeping the custom detail through tooltip avoids adding a new designer control.
            pnlEmpty.ToolTip = message;
        }

        private string GetLetterGrade(decimal score)
        {
            if (score >= 80) return "A";
            if (score >= 75) return "A-";
            if (score >= 70) return "B+";
            if (score >= 65) return "B";
            if (score >= 60) return "B-";
            if (score >= 55) return "C+";
            if (score >= 50) return "C";
            return "F";
        }

        private decimal GetGradePoints(string grade)
        {
            switch (grade)
            {
                case "A": return 4.00m;
                case "A-": return 3.67m;
                case "B+": return 3.33m;
                case "B": return 3.00m;
                case "B-": return 2.67m;
                case "C+": return 2.33m;
                case "C": return 2.00m;
                default: return 0.00m;
            }
        }

        private void CheckNotificationsBadge()
        {
            int unreadCount = 0;
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @UserId AND IsRead = 0",
                new[] { new SqlParameter("@UserId", CurrentUserId) });

            if (result != null && int.TryParse(result.ToString(), out unreadCount))
            {
                pnlNotifBadge.Visible = unreadCount > 0;
                pnlSidebarNotifBadge.Visible = unreadCount > 0;
            }
        }

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}
