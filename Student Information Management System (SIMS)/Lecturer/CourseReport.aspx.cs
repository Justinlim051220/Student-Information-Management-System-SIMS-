using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Lecturer
{
    public partial class CourseReport : Page
    {
        private const string ReportSessionKey = "SIMS_LecturerCourseReportData";
        private const string ReportTitleSessionKey = "SIMS_LecturerCourseReportTitle";

        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireLecturer(Session, Response);

            if (!IsPostBack)
            {
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
                LoadProgrammes();
                LoadSessions();
                LoadCourses();
                CheckUnreadNotifications();
                ClearReport();
            }
        }

        private string CurrentLecturerId
        {
            get
            {
                string lecturerId = SessionHelper.GetProfileId(Session);
                if (!string.IsNullOrWhiteSpace(lecturerId))
                    return lecturerId;

                object result = DatabaseHelper.ExecuteScalar(
                    "SELECT LecturerId FROM LecturerDetails WHERE UserId = @UserId",
                    new[] { new SqlParameter("@UserId", SessionHelper.GetUserId(Session)) });

                return result == null ? "" : result.ToString();
            }
        }

        private void LoadProgrammes()
        {
            string sql = @"
                SELECT DISTINCT p.ProgrammeId,
                       p.ProgrammeCode + ' - ' + p.ProgrammeName AS ProgrammeDisplay
                FROM LecturerCourse lc
                INNER JOIN Courses c ON lc.CourseId = c.CourseId
                INNER JOIN Programmes p ON c.ProgrammeId = p.ProgrammeId
                WHERE lc.LecturerId = @LecturerId
                ORDER BY ProgrammeDisplay";

            ddlProgramme.DataSource = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId)
            });
            ddlProgramme.DataTextField = "ProgrammeDisplay";
            ddlProgramme.DataValueField = "ProgrammeId";
            ddlProgramme.DataBind();
            ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
        }

        private void LoadSessions()
        {
            string sql = @"
                SELECT DISTINCT lc.Session
                FROM LecturerCourse lc
                INNER JOIN Courses c ON lc.CourseId = c.CourseId
                WHERE lc.LecturerId = @LecturerId
                  AND (@ProgrammeId = '' OR CONVERT(VARCHAR(20), c.ProgrammeId) = @ProgrammeId)
                ORDER BY lc.Session DESC";

            ddlSession.DataSource = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId),
                new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue)
            });
            ddlSession.DataTextField = "Session";
            ddlSession.DataValueField = "Session";
            ddlSession.DataBind();
            ddlSession.Items.Insert(0, new ListItem("-- Select Session --", ""));
        }

        private void LoadCourses()
        {
            string sql = @"
                SELECT DISTINCT c.CourseId,
                       c.CourseCode + ' - ' + c.CourseName AS CourseDisplay
                FROM LecturerCourse lc
                INNER JOIN Courses c ON lc.CourseId = c.CourseId
                WHERE lc.LecturerId = @LecturerId
                  AND (@ProgrammeId = '' OR CONVERT(VARCHAR(20), c.ProgrammeId) = @ProgrammeId)
                  AND (@Session = '' OR lc.Session = @Session)
                ORDER BY CourseDisplay";

            ddlCourse.DataSource = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId),
                new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue),
                new SqlParameter("@Session", ddlSession.SelectedValue)
            });
            ddlCourse.DataTextField = "CourseDisplay";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));
        }

        protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSessions();
            LoadCourses();
            ClearReport();
        }

        protected void ddlSession_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourses();
            ClearReport();
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            ClearReport();

            if (string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue) ||
                string.IsNullOrWhiteSpace(ddlSession.SelectedValue) ||
                string.IsNullOrWhiteSpace(ddlCourse.SelectedValue))
            {
                ShowMessage("Filter Required", "Please select programme, session, and course before generating the report.");
                return;
            }

            DataTable report = BuildCourseReport();
            Session[ReportSessionKey] = report;
            Session[ReportTitleSessionKey] = "Course Report";

            gvReport.DataSource = report;
            gvReport.DataBind();

            lblReportTitle.Text = "Course Report";
            lblProgramme.Text = HttpUtility.HtmlEncode(ddlProgramme.SelectedItem.Text);
            lblSession.Text = HttpUtility.HtmlEncode(ddlSession.SelectedValue);
            lblCourse.Text = HttpUtility.HtmlEncode(ddlCourse.SelectedItem.Text);

            SetSummary(
                "Total Students", report.Rows.Count.ToString(),
                "Assessments", Math.Max(report.Columns.Count - 4, 0).ToString(),
                "Average Final", GetAverageFinalMark(report),
                "Course", GetCourseCode(ddlCourse.SelectedValue));

            pnlReport.Visible = report.Rows.Count > 0;
            pnlEmpty.Visible = report.Rows.Count == 0;
        }

        private DataTable BuildCourseReport()
        {
            DataTable students = GetStudents();
            DataTable grades = GetGrades();
            DataTable results = GetPublishedResults();

            DataTable report = new DataTable();
            report.Columns.Add("No");
            report.Columns.Add("Student ID");
            report.Columns.Add("Student Name");

            List<AssessmentColumn> assessments = BuildAssessmentColumns(grades);
            foreach (AssessmentColumn assessment in assessments)
            {
                report.Columns.Add(assessment.ColumnName);
            }

            report.Columns.Add("Final Mark");

            int no = 1;
            foreach (DataRow student in students.Rows)
            {
                string studentId = Convert.ToString(student["StudentId"]);
                DataRow output = report.NewRow();
                output["No"] = no.ToString();
                output["Student ID"] = studentId;
                output["Student Name"] = Convert.ToString(student["StudentName"]);

                DataRow[] studentGrades = grades.Select("StudentId = '" + studentId.Replace("'", "''") + "'");
                foreach (AssessmentColumn assessment in assessments)
                {
                    DataRow grade = studentGrades.FirstOrDefault(row =>
                        Convert.ToString(row["AssessmentKey"]) == assessment.Key);
                    output[assessment.ColumnName] = FormatAssessmentMark(grade);
                }

                output["Final Mark"] = GetFinalMark(studentId, results, studentGrades);
                report.Rows.Add(output);
                no++;
            }

            return report;
        }

        private DataTable GetStudents()
        {
            string sql = @"
                SELECT DISTINCT sd.StudentId,
                       sd.FirstName + ' ' + sd.LastName AS StudentName
                FROM Enrollment e
                INNER JOIN StudentDetails sd ON sd.StudentId = e.StudentId
                INNER JOIN LecturerCourse lc
                    ON lc.CourseId = e.CourseId
                   AND lc.Session = e.Session
                   AND lc.LecturerId = @LecturerId
                WHERE e.Session = @Session
                  AND e.CourseId = @CourseId
                  AND sd.ProgrammeId = @ProgrammeId
                  AND e.Status IN ('Active', 'Completed', 'Enrollment Pending')
                ORDER BY StudentName";

            return DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId),
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue)
            });
        }

        private DataTable GetGrades()
        {
            string sql = @"
                SELECT g.StudentId,
                       g.Type,
                       g.Title,
                       g.MaterialId,
                       g.MaxMarks,
                       g.MarksObtained,
                       g.WeightPercentage,
                       g.Type + ':' + CONVERT(VARCHAR(20), g.MaterialId) + ':' + g.Title AS AssessmentKey
                FROM Grades g
                INNER JOIN Enrollment e
                    ON e.StudentId = g.StudentId
                   AND e.CourseId = g.CourseId
                   AND e.Session = @Session
                INNER JOIN StudentDetails sd ON sd.StudentId = e.StudentId
                INNER JOIN LecturerCourse lc
                    ON lc.CourseId = e.CourseId
                   AND lc.Session = e.Session
                   AND lc.LecturerId = @LecturerId
                WHERE g.CourseId = @CourseId
                  AND sd.ProgrammeId = @ProgrammeId
                  AND e.Status IN ('Active', 'Completed', 'Enrollment Pending')
                ORDER BY
                    CASE g.Type WHEN 'Assignment' THEN 1 WHEN 'Quiz' THEN 2 WHEN 'Exam' THEN 3 ELSE 4 END,
                    g.Title,
                    g.MaterialId,
                    g.StudentId";

            return DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId),
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue)
            });
        }

        private DataTable GetPublishedResults()
        {
            string sql = @"
                SELECT StudentId, FinalMark
                FROM Results
                WHERE [Session] = @Session
                  AND CourseId = @CourseId
                  AND ResultStatus = 'Published'";

            return DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue)
            });
        }

        private List<AssessmentColumn> BuildAssessmentColumns(DataTable grades)
        {
            List<AssessmentColumn> assessments = new List<AssessmentColumn>();
            HashSet<string> usedNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (DataRow row in grades.Rows)
            {
                string key = Convert.ToString(row["AssessmentKey"]);
                if (assessments.Any(item => item.Key == key))
                    continue;

                string type = Convert.ToString(row["Type"]);
                string title = Convert.ToString(row["Title"]);
                string baseName = string.IsNullOrWhiteSpace(title) ? type : type + " - " + title;
                string columnName = baseName;
                int duplicate = 2;

                while (usedNames.Contains(columnName))
                {
                    columnName = baseName + " (" + duplicate + ")";
                    duplicate++;
                }

                usedNames.Add(columnName);
                assessments.Add(new AssessmentColumn { Key = key, ColumnName = columnName });
            }

            return assessments;
        }

        private string FormatAssessmentMark(DataRow grade)
        {
            if (grade == null || grade["MarksObtained"] == DBNull.Value)
                return "-";

            decimal marks = Convert.ToDecimal(grade["MarksObtained"]);
            decimal maxMarks = grade["MaxMarks"] == DBNull.Value ? 0 : Convert.ToDecimal(grade["MaxMarks"]);
            if (maxMarks <= 0)
                return marks.ToString("N2");

            return marks.ToString("N2") + " / " + maxMarks.ToString("N2");
        }

        private string GetFinalMark(string studentId, DataTable results, DataRow[] grades)
        {
            DataRow result = results.Select("StudentId = '" + studentId.Replace("'", "''") + "'").FirstOrDefault();
            if (result != null && result["FinalMark"] != DBNull.Value)
                return Convert.ToDecimal(result["FinalMark"]).ToString("N2");

            decimal weightedTotal = 0;
            bool hasWeight = false;
            decimal percentageTotal = 0;
            int percentageCount = 0;

            foreach (DataRow grade in grades)
            {
                if (grade["MarksObtained"] == DBNull.Value || grade["MaxMarks"] == DBNull.Value)
                    continue;

                decimal maxMarks = Convert.ToDecimal(grade["MaxMarks"]);
                if (maxMarks <= 0)
                    continue;

                decimal percent = Convert.ToDecimal(grade["MarksObtained"]) * 100 / maxMarks;

                if (grade["WeightPercentage"] != DBNull.Value)
                {
                    decimal weight = Convert.ToDecimal(grade["WeightPercentage"]);
                    if (weight > 0)
                    {
                        weightedTotal += percent * weight / 100;
                        hasWeight = true;
                    }
                }

                percentageTotal += percent;
                percentageCount++;
            }

            if (hasWeight)
                return weightedTotal.ToString("N2");

            if (percentageCount > 0)
                return (percentageTotal / percentageCount).ToString("N2");

            return "-";
        }

        private string GetAverageFinalMark(DataTable report)
        {
            decimal total = 0;
            int count = 0;

            foreach (DataRow row in report.Rows)
            {
                decimal value;
                if (decimal.TryParse(Convert.ToString(row["Final Mark"]), out value))
                {
                    total += value;
                    count++;
                }
            }

            return count == 0 ? "-" : (total / count).ToString("N2");
        }

        private string GetCourseCode(string courseId)
        {
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT CourseCode FROM Courses WHERE CourseId = @CourseId",
                new[] { new SqlParameter("@CourseId", courseId) });

            return result == null ? "-" : Convert.ToString(result);
        }

        private void SetSummary(string label1, string value1, string label2, string value2, string label3, string value3, string label4, string value4)
        {
            lblSummaryLabel1.Text = label1;
            lblSummaryValue1.Text = value1;
            lblSummaryLabel2.Text = label2;
            lblSummaryValue2.Text = value2;
            lblSummaryLabel3.Text = label3;
            lblSummaryValue3.Text = value3;
            lblSummaryLabel4.Text = label4;
            lblSummaryValue4.Text = value4;
        }

        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            ExportText("csv");
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            ExportText("xls");
        }

        protected void btnExportPdf_Click(object sender, EventArgs e)
        {
            DataTable report = Session[ReportSessionKey] as DataTable;
            if (report == null || report.Rows.Count == 0)
            {
                ShowMessage("Export Failed", "Please generate a report before exporting.");
                return;
            }

            string title = Convert.ToString(Session[ReportTitleSessionKey]);
            byte[] pdf = SimplePdfHelper.CreateProfessionalReportPdf(
                string.IsNullOrWhiteSpace(title) ? "Course Report" : title,
                BuildPdfFilterTable(),
                BuildPdfSummaryTable(),
                null,
                report,
                "Student Assessment Summary");

            Response.Clear();
            Response.ContentType = "application/pdf";
            Response.AddHeader("Content-Disposition", "attachment;filename=" + GetSafeFileName(title) + ".pdf");
            Response.BinaryWrite(pdf);
            Response.End();
        }

        private DataTable BuildPdfFilterTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Field");
            dt.Columns.Add("Value");
            AddPdfInfoRow(dt, "Programme", ddlProgramme.SelectedItem == null ? "" : ddlProgramme.SelectedItem.Text);
            AddPdfInfoRow(dt, "Session", ddlSession.SelectedValue);
            AddPdfInfoRow(dt, "Course", ddlCourse.SelectedItem == null ? "" : ddlCourse.SelectedItem.Text);
            AddPdfInfoRow(dt, "Generated On", DateTime.Now.ToString("dd MMM yyyy, hh:mm tt"));
            return dt;
        }

        private DataTable BuildPdfSummaryTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Metric");
            dt.Columns.Add("Value");
            AddPdfInfoRow(dt, lblSummaryLabel1.Text, lblSummaryValue1.Text);
            AddPdfInfoRow(dt, lblSummaryLabel2.Text, lblSummaryValue2.Text);
            AddPdfInfoRow(dt, lblSummaryLabel3.Text, lblSummaryValue3.Text);
            AddPdfInfoRow(dt, lblSummaryLabel4.Text, lblSummaryValue4.Text);
            return dt;
        }

        private void AddPdfInfoRow(DataTable dt, string label, string value)
        {
            if (string.IsNullOrWhiteSpace(label))
                return;

            DataRow row = dt.NewRow();
            row[0] = HttpUtility.HtmlDecode(label);
            row[1] = string.IsNullOrWhiteSpace(value) ? "-" : HttpUtility.HtmlDecode(value);
            dt.Rows.Add(row);
        }

        private void ExportText(string type)
        {
            DataTable dt = Session[ReportSessionKey] as DataTable;
            if (dt == null || dt.Rows.Count == 0)
            {
                ShowMessage("Export Failed", "Please generate a report before exporting.");
                return;
            }

            string title = Convert.ToString(Session[ReportTitleSessionKey]);
            string content = type == "xls" ? BuildExcelHtml(title, dt) : BuildCsv(dt);
            string extension = type == "xls" ? ".xls" : ".csv";
            string contentType = type == "xls" ? "application/vnd.ms-excel" : "text/csv";

            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = contentType;
            Response.AddHeader("Content-Disposition", "attachment;filename=" + GetSafeFileName(title) + extension);
            Response.Charset = "";
            Response.Write(content);
            Response.End();
        }

        private string BuildCsv(DataTable dt)
        {
            StringBuilder sb = new StringBuilder();

            for (int i = 0; i < dt.Columns.Count; i++)
            {
                if (i > 0) sb.Append(',');
                sb.Append(EscapeCsv(dt.Columns[i].ColumnName));
            }
            sb.AppendLine();

            foreach (DataRow row in dt.Rows)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    if (i > 0) sb.Append(',');
                    sb.Append(EscapeCsv(Convert.ToString(row[i])));
                }
                sb.AppendLine();
            }

            return sb.ToString();
        }

        private string EscapeCsv(string value)
        {
            value = value ?? "";
            value = value.Replace("\"", "\"\"");
            return "\"" + value + "\"";
        }

        private string BuildExcelHtml(string title, DataTable dt)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><meta charset='utf-8'></head><body>");
            sb.Append("<h2>").Append(HttpUtility.HtmlEncode(title)).Append("</h2>");
            sb.Append("<table border='1'><tr>");

            foreach (DataColumn col in dt.Columns)
                sb.Append("<th>").Append(HttpUtility.HtmlEncode(col.ColumnName)).Append("</th>");

            sb.Append("</tr>");

            foreach (DataRow row in dt.Rows)
            {
                sb.Append("<tr>");
                foreach (DataColumn col in dt.Columns)
                    sb.Append("<td>").Append(HttpUtility.HtmlEncode(Convert.ToString(row[col]))).Append("</td>");
                sb.Append("</tr>");
            }

            sb.Append("</table></body></html>");
            return sb.ToString();
        }

        private string GetSafeFileName(string title)
        {
            if (string.IsNullOrWhiteSpace(title))
                title = "SIMS_Report";

            foreach (char c in System.IO.Path.GetInvalidFileNameChars())
                title = title.Replace(c, '_');

            return title.Replace(" ", "_");
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlProgramme.SelectedIndex = 0;
            LoadSessions();
            LoadCourses();
            ClearReport();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("Report.aspx");
        }

        private void ClearReport()
        {
            pnlReport.Visible = false;
            pnlEmpty.Visible = false;
            gvReport.DataSource = null;
            gvReport.DataBind();
            Session.Remove(ReportSessionKey);
            Session.Remove(ReportTitleSessionKey);
        }

        private void CheckUnreadNotifications()
        {
            object result = DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(*)
                FROM Notifications n
                WHERE n.UserId = @UserId
                  AND ISNULL(n.IsRead, 0) = 0",
                new[] { new SqlParameter("@UserId", SessionHelper.GetUserId(Session)) });

            int unread = result == null ? 0 : Convert.ToInt32(result);
            pnlNotifBadge.Visible = unread > 0;
        }

        private void ShowMessage(string title, string message)
        {
            string script = string.Format(
                "showMessageModal('{0}', '{1}');",
                HttpUtility.JavaScriptStringEncode(title),
                HttpUtility.JavaScriptStringEncode(message));

            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"), script, true);
        }

        private class AssessmentColumn
        {
            public string Key { get; set; }
            public string ColumnName { get; set; }
        }
    }
}
