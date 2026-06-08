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
                LoadGradeRecords();
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

                return result == null ? "" : result.ToString();
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
            {
                lblAvatarInitial.Text = fullName.Substring(0, 1).ToUpper();
            }
        }

        private void LoadSessionFilter()
        {
            string sql = @"
                SELECT DISTINCT Session 
                FROM Enrollment 
                WHERE StudentId = @StudentId AND Status != 'Dropped'
                ORDER BY Session DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@StudentId", CurrentStudentId) });

            ddlSession.DataSource = dt;
            ddlSession.DataTextField = "Session";
            ddlSession.DataValueField = "Session";
            ddlSession.DataBind();
            ddlSession.Items.Insert(0, new ListItem("All Academic Sessions", ""));
        }

        private void LoadGradeRecords()
        {
            // -------------------------------------------------------------------------
            // 1. CALCULATE FILTERED GPA & BIND TO REPEATER
            // -------------------------------------------------------------------------
            string sqlFiltered = @"
                SELECT 
                    c.CourseId,
                    c.CourseCode + ' - ' + c.CourseName AS CourseDisplay,
                    c.Credits,
                    (SUM((CAST(g.MarksObtained AS DECIMAL(5,2)) / NULLIF(CAST(g.MaxMarks AS DECIMAL(5,2)), 0)) * g.WeightPercentage) / NULLIF(SUM(g.WeightPercentage), 0)) * 100 AS FinalPercentage,
                    SUM(g.WeightPercentage) AS TotalWeightGraded
                FROM Grades g
                INNER JOIN Courses c ON g.CourseId = c.CourseId
                INNER JOIN Enrollment e ON e.StudentId = g.StudentId AND e.CourseId = g.CourseId
                WHERE g.StudentId = @StudentId
                  AND g.MarksObtained IS NOT NULL
                  AND e.Status != 'Dropped'
                  AND (@Session = '' OR e.Session = @Session)
                  AND (@Semester = '' OR CONVERT(VARCHAR(5), e.Semester) = @Semester)
                GROUP BY c.CourseId, c.CourseCode, c.CourseName, c.Credits";

            DataTable rawDt = DatabaseHelper.ExecuteQuery(sqlFiltered, new[]
            {
                new SqlParameter("@StudentId", CurrentStudentId),
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@Semester", ddlSemester.SelectedValue)
            });

            DataTable displayDt = new DataTable();
            displayDt.Columns.Add("CourseDisplay", typeof(string));
            displayDt.Columns.Add("Credits", typeof(int));
            displayDt.Columns.Add("FinalPercentage", typeof(object));
            displayDt.Columns.Add("CalculatedGrade", typeof(string));

            double filteredQualityPoints = 0;
            int filteredAttemptedCredits = 0;
            int totalEarnedCredits = 0;

            foreach (DataRow row in rawDt.Rows)
            {
                double totalWeightGraded = row["TotalWeightGraded"] != DBNull.Value ? Convert.ToDouble(row["TotalWeightGraded"]) : 0;
                int credits = Convert.ToInt32(row["Credits"]);

                DataRow newRow = displayDt.NewRow();
                newRow["CourseDisplay"] = row["CourseDisplay"];
                newRow["Credits"] = credits;

                // BACKEND WORKAROUND GATE: Check if the total assessment marks add up to 100%
                if (totalWeightGraded < 100.0)
                {
                    // Skip calculating into GPA, mark as "In Progress"
                    newRow["FinalPercentage"] = DBNull.Value;
                    newRow["CalculatedGrade"] = "In Progress (IP)";
                }
                else
                {
                    double score = Convert.ToDouble(row["FinalPercentage"]);
                    string grade = GetLetterGrade(score);
                    double points = GetGradePoints(grade);

                    if (grade != "F")
                    {
                        totalEarnedCredits += credits;
                    }

                    filteredAttemptedCredits += credits;
                    filteredQualityPoints += (points * credits);

                    newRow["FinalPercentage"] = Math.Round(score, 2);
                    newRow["CalculatedGrade"] = grade;
                }

                displayDt.Rows.Add(newRow);
            }

            rptGrades.DataSource = displayDt;
            rptGrades.DataBind();

            pnlEmpty.Visible = (displayDt.Rows.Count == 0);

            lblTotalCredits.Text = totalEarnedCredits.ToString();
            lblGPA.Text = filteredAttemptedCredits > 0 ? string.Format("{0:0.00}", filteredQualityPoints / filteredAttemptedCredits) : "0.00";

            // -------------------------------------------------------------------------
            // 2. CALCULATE CUMULATIVE ALL-TIME CGPA (UNFILTERED)
            // -------------------------------------------------------------------------
            CalculateCumulativeGpa();
        }

        private void CalculateCumulativeGpa()
        {
            string sqlAllTime = @"
                SELECT 
                    c.Credits,
                    (SUM((CAST(g.MarksObtained AS DECIMAL(5,2)) / NULLIF(CAST(g.MaxMarks AS DECIMAL(5,2)), 0)) * g.WeightPercentage) / NULLIF(SUM(g.WeightPercentage), 0)) * 100 AS FinalPercentage,
                    SUM(g.WeightPercentage) AS TotalWeightGraded
                FROM Grades g
                INNER JOIN Courses c ON g.CourseId = c.CourseId
                INNER JOIN Enrollment e ON e.StudentId = g.StudentId AND e.CourseId = g.CourseId
                WHERE g.StudentId = @StudentId
                  AND g.MarksObtained IS NOT NULL
                  AND e.Status != 'Dropped'
                GROUP BY c.CourseId, c.Credits";

            DataTable cumulativeDt = DatabaseHelper.ExecuteQuery(sqlAllTime, new[] { new SqlParameter("@StudentId", CurrentStudentId) });

            double cumulativeQualityPoints = 0;
            int cumulativeAttemptedCredits = 0;

            foreach (DataRow row in cumulativeDt.Rows)
            {
                double totalWeightGraded = row["TotalWeightGraded"] != DBNull.Value ? Convert.ToDouble(row["TotalWeightGraded"]) : 0;

                // BACKEND WORKAROUND GATE: Ignore this course entirely for CGPA if it is less than 100% total weight
                if (totalWeightGraded < 100.0)
                {
                    continue;
                }

                double score = Convert.ToDouble(row["FinalPercentage"]);
                int credits = Convert.ToInt32(row["Credits"]);

                string grade = GetLetterGrade(score);
                double points = GetGradePoints(grade);

                cumulativeAttemptedCredits += credits;
                cumulativeQualityPoints += (points * credits);
            }

            if (lblCGPA != null)
            {
                lblCGPA.Text = cumulativeAttemptedCredits > 0 ? string.Format("{0:0.00}", cumulativeQualityPoints / cumulativeAttemptedCredits) : "0.00";
            }
        }

        private string GetLetterGrade(double score)
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

        private double GetGradePoints(string grade)
        {
            switch (grade)
            {
                case "A": return 4.00;
                case "A-": return 3.67;
                case "B+": return 3.33;
                case "B": return 3.00;
                case "B-": return 2.67;
                case "C+": return 2.33;
                case "C": return 2.00;
                default: return 0.00;
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadGradeRecords();
        }

        private void CheckNotificationsBadge()
        {
            int unreadCount = 0;
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @UserId AND IsRead = 0",
                new[] { new SqlParameter("@UserId", CurrentUserId) });

            if (result != null && int.TryParse(result.ToString(), out unreadCount))
            {
                if (unreadCount > 0)
                {
                    pnlNotifBadge.Visible = true;
                    pnlSidebarNotifBadge.Visible = true;
                }
            }
        }

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}