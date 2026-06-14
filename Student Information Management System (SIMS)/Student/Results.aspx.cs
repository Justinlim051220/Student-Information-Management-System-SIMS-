using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Student
{
    public partial class Results : Page
    {
        private const string ResultsSessionKey = "SIMS_StudentResultsData";
        private const string ResultsSessionTitleKey = "SIMS_StudentResultsTitle";

        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
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

            // Check if this is the first time results are being generated for this session/semester
            bool isFirstTimeGeneration = previousDt.Rows.Count == 0;

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

            // Send notification to student when results are generated
            if (courseDt.Rows.Count > 0)
            {
                SendResultsNotification(studentId, session, semester);
            }
        }

        private void SendResultsNotification(string studentId, string session, int semester)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery(@"
                    INSERT INTO Notifications
                    (UserId, Title, Message, IsRead, CreatedAt)
                    VALUES
                    (@UserId, @Title, @Message, 0, GETDATE())",
                    new[]
                    {
                        new SqlParameter("@UserId", CurrentUserId),
                        new SqlParameter("@Title", "Results Published"),
                        new SqlParameter("@Message", "Your results for " + session + " Semester " + semester + " are now available. You may visit the Results Section to view.")
                    });
            }
            catch
            {
                // Silently catch errors to not interfere with result generation
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

            pnlEmpty.ToolTip = message;
        }

        private string GetLetterGrade(decimal score)
        {
            if (score >= 90) return "A+";
            if (score >= 80) return "A";
            if (score >= 75) return "A-";
            if (score >= 70) return "B+";
            if (score >= 65) return "B";
            if (score >= 60) return "B-";
            if (score >= 55) return "C+";
            if (score >= 50) return "C";
            if (score >= 45) return "C-";
            if (score >= 40) return "D";
            return "F";
        }

        private decimal GetGradePoints(string grade)
        {
            switch (grade)
            {
                case "A+":
                case "A":
                    return 4.00m;
                case "A-":
                    return 3.67m;
                case "B+":
                    return 3.33m;
                case "B":
                    return 3.00m;
                case "B-":
                    return 2.67m;
                case "C+":
                    return 2.33m;
                case "C":
                    return 2.00m;
                case "C-":
                    return 1.50m;
                case "D":
                    return 1.00m;
                case "F":
                default:
                    return 0.00m;
            }
        }

        private void CheckNotificationsBadge()
        {
            int unreadCount = 0;

            object result = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @UserId AND IsRead = 0",
                new[] { new SqlParameter("@UserId", CurrentUserId) });

            if (result != null && int.TryParse(result.ToString(), out unreadCount))
                pnlNotifBadge.Visible = unreadCount > 0;
        }

        protected void btnExportResultSlip_Click(object sender, EventArgs e)
        {
            // Validate selections before attempting to retrieve results
            if (string.IsNullOrWhiteSpace(ddlSession.SelectedValue) ||
                string.IsNullOrWhiteSpace(ddlSemester.SelectedValue) ||
                !int.TryParse(ddlSemester.SelectedValue, out int semester))
            {
                ShowNoResultsModal();
                return;
            }

            // Validate that results are available before exporting
            DataTable resultsData = GetResultsDataTable();
            if (resultsData == null || resultsData.Rows.Count == 0)
            {
                ShowNoResultsModal();
                return;
            }

            StoreResultsForExport();
            ExportPdf();
        }

        private void StoreResultsForExport()
        {
            DataTable dt = GetResultsDataTable();
            if (dt == null || dt.Rows.Count == 0)
                return;

            Session[ResultsSessionKey] = dt;
            Session[ResultsSessionTitleKey] = "Student Result Slip";
        }

        private DataTable GetResultsDataTable()
        {
            string studentId = CurrentStudentId;
            string session = ddlSession.SelectedValue;

            // Parse semester (already validated in btnExportResultSlip_Click)
            if (!int.TryParse(ddlSemester.SelectedValue, out int semester))
            {
                return null;
            }

            DataTable dt = DatabaseHelper.ExecuteQuery(@"
                SELECT
                    r.ResultId,
                    r.CourseId,
                    c.CourseCode + ' - ' + c.CourseName AS CourseDisplay,
                    r.Credits,
                    CAST(r.FinalMark AS DECIMAL(5,2)) AS FinalMark,
                    r.Grade,
                    CAST(r.GradePoint AS DECIMAL(4,2)) AS GradePoint,
                    r.GPA,
                    r.CGPA
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

            return dt;
        }

        private void ExportPdf()
        {
            DataTable dt = Session[ResultsSessionKey] as DataTable;
            if (dt == null || dt.Rows.Count == 0)
            {
                ShowExportMessage("Export Failed", "Please generate a report before exporting.");
                return;
            }

            string studentId = CurrentStudentId;
            string session = ddlSession.SelectedValue;
            int semester = Convert.ToInt32(ddlSemester.SelectedValue);

            DataTable filterTable = BuildPdfFilterTable(studentId, session, semester);
            DataTable summaryTable = BuildPdfSummaryTable(dt);

            DataTable exportTable = new DataTable();
            exportTable.Columns.Add("Course Code & Name");
            exportTable.Columns.Add("Credits");
            exportTable.Columns.Add("Final Mark (%)");
            exportTable.Columns.Add("Grade");
            exportTable.Columns.Add("Grade Point");

            foreach (DataRow row in dt.Rows)
            {
                DataRow newRow = exportTable.NewRow();
                newRow[0] = row["CourseDisplay"];
                newRow[1] = row["Credits"];
                newRow[2] = string.Format("{0:0.00}%", row["FinalMark"]);
                newRow[3] = row["Grade"];
                newRow[4] = row["GradePoint"];
                exportTable.Rows.Add(newRow);
            }

            string title = "Student Result Slip - " + session + " Semester " + semester;
            byte[] pdfBytes = SimplePdfHelper.CreateProfessionalReportPdf(
                title,
                filterTable,
                summaryTable,
                null,
                exportTable,
                "Result Details");

            SendFileToClient(pdfBytes, GetSafeFileName(title) + ".pdf", "application/pdf");
        }

        private DataTable BuildPdfFilterTable(string studentId, string session, int semester)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Field");
            dt.Columns.Add("Value");

            string studentName = "Unknown Student";
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT FirstName + ' ' + LastName FROM StudentDetails WHERE StudentId = @StudentId",
                new[] { new SqlParameter("@StudentId", studentId) });
            if (result != null)
                studentName = result.ToString();

            AddPdfInfoRow(dt, "Student ID", studentId);
            AddPdfInfoRow(dt, "Student Name", studentName);
            AddPdfInfoRow(dt, "Academic Session", session);
            AddPdfInfoRow(dt, "Semester", "Semester " + semester);
            AddPdfInfoRow(dt, "Generated On", DateTime.Now.ToString("dd MMM yyyy, hh:mm tt"));

            return dt;
        }

        private DataTable BuildPdfSummaryTable(DataTable resultsTable)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Metric");
            dt.Columns.Add("Value");

            if (resultsTable.Rows.Count > 0)
            {
                decimal gpa = Convert.ToDecimal(resultsTable.Rows[0]["GPA"]);
                decimal cgpa = Convert.ToDecimal(resultsTable.Rows[0]["CGPA"]);
                int totalCredits = 0;
                int courseCount = resultsTable.Rows.Count;

                foreach (DataRow row in resultsTable.Rows)
                    totalCredits += Convert.ToInt32(row["Credits"]);

                AddPdfInfoRow(dt, "Total Courses", courseCount.ToString());
                AddPdfInfoRow(dt, "Total Credits", totalCredits.ToString());
                AddPdfInfoRow(dt, "GPA (Current Semester)", gpa.ToString("0.00"));
                AddPdfInfoRow(dt, "CGPA (All Time)", cgpa.ToString("0.00"));
            }

            return dt;
        }

        private void AddPdfInfoRow(DataTable dt, string label, string value)
        {
            if (string.IsNullOrWhiteSpace(label))
                return;

            DataRow row = dt.NewRow();
            row[0] = label;
            row[1] = string.IsNullOrWhiteSpace(value) ? "-" : value;
            dt.Rows.Add(row);
        }

        private string GetSafeFileName(string title)
        {
            if (string.IsNullOrWhiteSpace(title))
                title = "SIMS_Result_Slip";

            foreach (char c in System.IO.Path.GetInvalidFileNameChars())
                title = title.Replace(c, '_');

            return title.Replace(" ", "_");
        }

        private void SendFileToClient(byte[] fileBytes, string fileName, string contentType)
        {
            try
            {
                Response.Clear();
                Response.Buffer = true;
                Response.ContentType = contentType;
                Response.AddHeader("Content-Disposition", "attachment;filename=" + fileName);
                Response.Charset = "";
                Response.BinaryWrite(fileBytes);
                Response.End();
            }
            catch (HttpRequestValidationException)
            {
            }
            catch (Exception)
            {
            }
        }

        private void ShowExportMessage(string title, string message)
        {
            string script = string.Format(
                "alert('{0}: {1}');",
                HttpUtility.JavaScriptStringEncode(title),
                HttpUtility.JavaScriptStringEncode(message));

            ClientScript.RegisterStartupScript(GetType(), Guid.NewGuid().ToString("N"), script, true);
        }

        private void ShowNoResultsModal()
        {
            const string script = "showNoResultsModal();";
            ClientScript.RegisterStartupScript(GetType(), Guid.NewGuid().ToString("N"), script, true);
        }
    }}