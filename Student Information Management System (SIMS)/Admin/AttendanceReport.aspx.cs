using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Admin
{
    public partial class AttendanceReport : Page
    {
        private const string MatrixSessionKey = "DetailedAttendanceMatrix";
        private const string DateSummarySessionKey = "DetailedAttendanceDateSummary";

        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                LoadSessions();
                LoadProgrammes();
                LoadCourses();
                ApplyQueryStringFilterAndGenerate();
            }
        }


        private void ApplyQueryStringFilterAndGenerate()
        {
            string session = Request.QueryString["session"];
            string programmeId = Request.QueryString["programmeId"];
            string courseId = Request.QueryString["courseId"];

            if (!string.IsNullOrWhiteSpace(session) && ddlSession.Items.FindByValue(session) != null)
                ddlSession.SelectedValue = session;

            if (!string.IsNullOrWhiteSpace(programmeId) && ddlProgramme.Items.FindByValue(programmeId) != null)
                ddlProgramme.SelectedValue = programmeId;

            if (!string.IsNullOrWhiteSpace(courseId) && ddlCourse.Items.FindByValue(courseId) != null)
                ddlCourse.SelectedValue = courseId;

            if (!string.IsNullOrWhiteSpace(ddlSession.SelectedValue) &&
                !string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue) &&
                !string.IsNullOrWhiteSpace(ddlCourse.SelectedValue))
            {
                GenerateAttendanceReport();
            }
            else
            {
                pnlReport.Visible = false;
                pnlEmpty.Visible = true;
            }
        }

        private void LoadSessions()
        {
            ddlSession.Items.Clear();
            ddlSession.Items.Add(new ListItem("-- Select Session --", ""));

            string sql = @"
                SELECT DISTINCT Session
                FROM (
                    SELECT Session FROM Attendance
                    UNION
                    SELECT Session FROM Enrollment
                    UNION
                    SELECT Session FROM CourseOffering
                ) x
                WHERE Session IS NOT NULL AND LTRIM(RTRIM(Session)) <> ''
                ORDER BY Session DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);
            foreach (DataRow row in dt.Rows)
            {
                ddlSession.Items.Add(new ListItem(Convert.ToString(row["Session"]), Convert.ToString(row["Session"])));
            }
        }

        private void LoadProgrammes()
        {
            string sql = @"
                SELECT ProgrammeId,
                       ProgrammeCode + ' - ' + ProgrammeName AS ProgrammeDisplay
                FROM Programmes
                ORDER BY ProgrammeName";

            ddlProgramme.DataSource = DatabaseHelper.ExecuteQuery(sql);
            ddlProgramme.DataTextField = "ProgrammeDisplay";
            ddlProgramme.DataValueField = "ProgrammeId";
            ddlProgramme.DataBind();
            ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
        }

        private void LoadCourses()
        {
            string sql = @"
                SELECT CourseId,
                       CourseCode + ' - ' + CourseName AS CourseDisplay
                FROM Courses
                ORDER BY CourseCode";

            ddlCourse.DataSource = DatabaseHelper.ExecuteQuery(sql);
            ddlCourse.DataTextField = "CourseDisplay";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(ddlSession.SelectedValue) ||
                string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue) ||
                string.IsNullOrWhiteSpace(ddlCourse.SelectedValue))
            {
                pnlReport.Visible = false;
                pnlEmpty.Visible = true;
                ShowMessage("Filter Required", "Please select the session, programme, and course before generating the attendance report.");
                return;
            }

            GenerateAttendanceReport();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlSession.SelectedIndex = 0;
            ddlProgramme.SelectedIndex = 0;
            ddlCourse.SelectedIndex = 0;
            pnlReport.Visible = false;
            pnlEmpty.Visible = true;
            Session.Remove(MatrixSessionKey);
            Session.Remove(DateSummarySessionKey);
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("Reports.aspx");
        }

        private void GenerateAttendanceReport()
        {
            DataTable courseInfo = GetCourseInformation();
            if (courseInfo.Rows.Count == 0)
            {
                pnlReport.Visible = false;
                pnlEmpty.Visible = true;
                ShowMessage("No Course Found", "The selected course and programme combination could not be found.");
                return;
            }

            DataRow info = courseInfo.Rows[0];
            lblCourseCode.Text = Convert.ToString(info["CourseCode"]);
            lblCourseName.Text = Convert.ToString(info["CourseName"]);
            lblProgramme.Text = Convert.ToString(info["ProgrammeDisplay"]);
            lblSession.Text = ddlSession.SelectedValue;
            lblGeneratedAt.Text = "Generated: " + DateTime.Now.ToString("dd MMM yyyy, hh:mm tt");

            DataTable dateSummary = GetDateSummary();
            DataTable matrix = BuildAttendanceMatrix();

            gvDateSummary.DataSource = dateSummary;
            gvDateSummary.DataBind();

            gvMatrix.DataSource = matrix;
            gvMatrix.DataBind();

            int totalStudents = matrix.Rows.Count;
            int totalClasses = Math.Max(0, matrix.Columns.Count - 5); // Student ID, Name, date columns, Attended Total, Attendance %, Status
            decimal averageAttendance = CalculateAverageAttendance(matrix);

            lblTotalStudents.Text = totalStudents.ToString();
            lblTotalClasses.Text = totalClasses.ToString();
            lblAverageAttendance.Text = averageAttendance.ToString("0.##") + "%";

            Session[DateSummarySessionKey] = dateSummary;
            Session[MatrixSessionKey] = matrix;

            pnlReport.Visible = true;
            pnlEmpty.Visible = false;
        }

        private DataTable GetCourseInformation()
        {
            string sql = @"
                SELECT c.CourseCode,
                       c.CourseName,
                       p.ProgrammeCode + ' - ' + p.ProgrammeName AS ProgrammeDisplay
                FROM Courses c
                INNER JOIN Programmes p ON c.ProgrammeId = p.ProgrammeId
                WHERE c.CourseId = @CourseId
                  AND p.ProgrammeId = @ProgrammeId";

            return DatabaseHelper.ExecuteQuery(sql, GetRequiredParameters());
        }

        private DataTable GetDateSummary()
        {
            string sql = @"
                SELECT CONVERT(VARCHAR(10), a.AttendanceDate, 103) AS [Class Date],
                       SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) AS Present,
                       SUM(CASE WHEN a.Status = 'Absent' THEN 1 ELSE 0 END) AS Absent,
                       SUM(CASE WHEN a.Status = 'Late' THEN 1 ELSE 0 END) AS Late,
                       CAST(
                           CASE WHEN COUNT(*) = 0 THEN 0
                                ELSE (SUM(CASE WHEN a.Status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0 / COUNT(*))
                           END AS DECIMAL(5,2)
                       ) AS [Attendance Rate %]
                FROM Attendance a
                INNER JOIN StudentDetails s ON a.StudentId = s.StudentId
                WHERE a.Session = @Session
                  AND a.CourseId = @CourseId
                  AND s.ProgrammeId = @ProgrammeId
                GROUP BY a.AttendanceDate
                ORDER BY a.AttendanceDate";

            return DatabaseHelper.ExecuteQuery(sql, GetRequiredParameters());
        }

        private DataTable BuildAttendanceMatrix()
        {
            DataTable students = GetEnrolledStudents();
            DataTable dates = GetAttendanceDates();
            DataTable records = GetAttendanceRecords();

            DataTable matrix = new DataTable();
            matrix.Columns.Add("Student ID");
            matrix.Columns.Add("Student Name");

            List<DateTime> dateList = new List<DateTime>();
            foreach (DataRow row in dates.Rows)
            {
                DateTime date = Convert.ToDateTime(row["AttendanceDate"]);
                dateList.Add(date);
                matrix.Columns.Add(date.ToString("dd/MM"));
            }

            matrix.Columns.Add("Attended Total");
            matrix.Columns.Add("Attendance %");
            matrix.Columns.Add("Status");

            Dictionary<string, string> statusLookup = new Dictionary<string, string>();
            foreach (DataRow row in records.Rows)
            {
                string key = Convert.ToString(row["StudentId"]) + "|" + Convert.ToDateTime(row["AttendanceDate"]).ToString("yyyy-MM-dd");
                statusLookup[key] = Convert.ToString(row["Status"]);
            }

            foreach (DataRow student in students.Rows)
            {
                string studentId = Convert.ToString(student["StudentId"]);
                DataRow newRow = matrix.NewRow();
                newRow["Student ID"] = studentId;
                newRow["Student Name"] = Convert.ToString(student["StudentName"]);

                int attended = 0;
                int totalClasses = dateList.Count;

                foreach (DateTime date in dateList)
                {
                    string columnName = date.ToString("dd/MM");
                    string key = studentId + "|" + date.ToString("yyyy-MM-dd");
                    string status = statusLookup.ContainsKey(key) ? statusLookup[key] : "-";

                    if (status == "Present")
                    {
                        newRow[columnName] = "✓";
                        attended++;
                    }
                    else if (status == "Late")
                    {
                        newRow[columnName] = "L";
                        attended++;
                    }
                    else if (status == "Absent")
                    {
                        newRow[columnName] = "✗";
                    }
                    else
                    {
                        newRow[columnName] = "-";
                    }
                }

                decimal percentage = totalClasses == 0 ? 0 : Math.Round((attended * 100m) / totalClasses, 2);
                newRow["Attended Total"] = attended + "/" + totalClasses;
                newRow["Attendance %"] = percentage.ToString("0.##") + "%";
                newRow["Status"] = percentage < 80 ? "Warning" : "Good";
                matrix.Rows.Add(newRow);
            }

            return matrix;
        }

        private DataTable GetEnrolledStudents()
        {
            string sql = @"
                SELECT DISTINCT s.StudentId,
                       s.FirstName + ' ' + s.LastName AS StudentName
                FROM Enrollment e
                INNER JOIN StudentDetails s ON e.StudentId = s.StudentId
                WHERE e.Session = @Session
                  AND e.CourseId = @CourseId
                  AND s.ProgrammeId = @ProgrammeId
                  AND e.Status IN ('Active', 'Completed', 'Drop Pending', 'Drop Rejected')
                ORDER BY s.StudentId";

            return DatabaseHelper.ExecuteQuery(sql, GetRequiredParameters());
        }

        private DataTable GetAttendanceDates()
        {
            string sql = @"
                SELECT DISTINCT AttendanceDate
                FROM Attendance
                WHERE Session = @Session
                  AND CourseId = @CourseId
                ORDER BY AttendanceDate";

            return DatabaseHelper.ExecuteQuery(sql, GetRequiredParameters());
        }

        private DataTable GetAttendanceRecords()
        {
            string sql = @"
                SELECT a.StudentId, a.AttendanceDate, a.Status
                FROM Attendance a
                INNER JOIN StudentDetails s ON a.StudentId = s.StudentId
                WHERE a.Session = @Session
                  AND a.CourseId = @CourseId
                  AND s.ProgrammeId = @ProgrammeId";

            return DatabaseHelper.ExecuteQuery(sql, GetRequiredParameters());
        }

        private decimal CalculateAverageAttendance(DataTable matrix)
        {
            if (matrix.Rows.Count == 0) return 0;

            decimal total = 0;
            foreach (DataRow row in matrix.Rows)
            {
                total += ParsePercentage(Convert.ToString(row["Attendance %"]));
            }

            return Math.Round(total / matrix.Rows.Count, 2);
        }

        private decimal ParsePercentage(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return 0;
            value = value.Replace("%", "").Trim();
            decimal result;
            return decimal.TryParse(value, out result) ? result : 0;
        }

        private SqlParameter[] GetRequiredParameters()
        {
            return new SqlParameter[]
            {
                new SqlParameter("@Session", ddlSession.SelectedValue ?? ""),
                new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue ?? ""),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue ?? "")
            };
        }

        protected void gvMatrix_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

            for (int i = 2; i < e.Row.Cells.Count - 3; i++)
            {
                string value = HttpUtility.HtmlDecode(e.Row.Cells[i].Text).Trim();
                if (value == "✓") e.Row.Cells[i].Text = "<span class='status-pill status-present'>✓</span>";
                else if (value == "✗") e.Row.Cells[i].Text = "<span class='status-pill status-absent'>✗</span>";
                else if (value == "L") e.Row.Cells[i].Text = "<span class='status-pill status-late'>L</span>";
                else e.Row.Cells[i].Text = "<span class='status-pill status-empty'>-</span>";
            }

            string status = HttpUtility.HtmlDecode(e.Row.Cells[e.Row.Cells.Count - 1].Text).Trim();
            if (status == "Warning") e.Row.Cells[e.Row.Cells.Count - 1].Text = "<span class='risk-badge'>Warning</span>";
            else e.Row.Cells[e.Row.Cells.Count - 1].Text = "<span class='safe-badge'>Good</span>";
        }

        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            DataTable matrix = Session[MatrixSessionKey] as DataTable;
            if (matrix == null || matrix.Rows.Count == 0)
            {
                ShowMessage("No Data", "Please generate the attendance report before exporting.");
                return;
            }

            ExportTextFile(BuildCsv(BuildFullExportTable()), "text/csv", GetExportFileName("csv"));
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            DataTable matrix = Session[MatrixSessionKey] as DataTable;
            if (matrix == null || matrix.Rows.Count == 0)
            {
                ShowMessage("No Data", "Please generate the attendance report before exporting.");
                return;
            }

            string html = BuildExcelHtml(BuildFullExportTable());
            ExportTextFile(html, "application/vnd.ms-excel", GetExportFileName("xls"));
        }

        protected void btnExportPdf_Click(object sender, EventArgs e)
        {
            DataTable matrix = Session[MatrixSessionKey] as DataTable;
            if (matrix == null || matrix.Rows.Count == 0)
            {
                ShowMessage("No Data", "Please generate the attendance report before exporting.");
                return;
            }

            byte[] pdfBytes = SimplePdfHelper.CreatePdf("Detailed Attendance Report", BuildFullExportTable());
            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "application/pdf";
            Response.AddHeader("content-disposition", "attachment;filename=" + GetExportFileName("pdf"));
            Response.BinaryWrite(pdfBytes);
            Response.Flush();
            Response.End();
        }

        private DataTable BuildFullExportTable()
        {
            DataTable export = new DataTable();
            export.Columns.Add("Section");
            export.Columns.Add("Item");
            export.Columns.Add("Value");

            AddExportRow(export, "Course Information", "Course Code", lblCourseCode.Text);
            AddExportRow(export, "Course Information", "Course Name", lblCourseName.Text);
            AddExportRow(export, "Course Information", "Programme", lblProgramme.Text);
            AddExportRow(export, "Course Information", "Session", lblSession.Text);
            AddExportRow(export, "Summary", "Total Students", lblTotalStudents.Text);
            AddExportRow(export, "Summary", "Total Classes", lblTotalClasses.Text);
            AddExportRow(export, "Summary", "Average Attendance", lblAverageAttendance.Text);
            AddExportRow(export, "Summary", "Generated At", DateTime.Now.ToString("dd MMM yyyy, hh:mm tt"));

            DataTable dateSummary = Session[DateSummarySessionKey] as DataTable;
            if (dateSummary != null)
            {
                foreach (DataRow row in dateSummary.Rows)
                {
                    string value = "Present: " + row["Present"] + ", Absent: " + row["Absent"] + ", Late: " + row["Late"] + ", Rate: " + row["Attendance Rate %"] + "%";
                    AddExportRow(export, "Attendance Date Summary", Convert.ToString(row["Class Date"]), value);
                }
            }

            DataTable matrix = Session[MatrixSessionKey] as DataTable;
            if (matrix != null)
            {
                foreach (DataRow row in matrix.Rows)
                {
                    StringBuilder value = new StringBuilder();
                    for (int i = 2; i < matrix.Columns.Count; i++)
                    {
                        if (i > 2) value.Append(" | ");
                        value.Append(matrix.Columns[i].ColumnName).Append(": ").Append(Convert.ToString(row[i]));
                    }

                    AddExportRow(export, "Student Attendance Matrix", Convert.ToString(row["Student ID"]) + " - " + Convert.ToString(row["Student Name"]), value.ToString());
                }
            }

            return export;
        }

        private void AddExportRow(DataTable table, string section, string item, string value)
        {
            DataRow row = table.NewRow();
            row["Section"] = section;
            row["Item"] = item;
            row["Value"] = value;
            table.Rows.Add(row);
        }

        private string BuildCsv(DataTable dt)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                if (i > 0) sb.Append(",");
                sb.Append(EscapeCsv(dt.Columns[i].ColumnName));
            }
            sb.AppendLine();

            foreach (DataRow row in dt.Rows)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    if (i > 0) sb.Append(",");
                    sb.Append(EscapeCsv(Convert.ToString(row[i])));
                }
                sb.AppendLine();
            }

            return sb.ToString();
        }

        private string EscapeCsv(string value)
        {
            if (value == null) return "";
            value = value.Replace("\"", "\"\"");
            if (value.Contains(",") || value.Contains("\n") || value.Contains("\r") || value.Contains("\""))
            {
                return "\"" + value + "\"";
            }
            return value;
        }

        private string BuildExcelHtml(DataTable dt)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><meta charset='utf-8'></head><body>");
            sb.Append("<h2>Detailed Attendance Report</h2>");
            sb.Append("<p>Session: ").Append(HttpUtility.HtmlEncode(ddlSession.SelectedValue)).Append("</p>");
            sb.Append("<p>Programme: ").Append(HttpUtility.HtmlEncode(lblProgramme.Text)).Append("</p>");
            sb.Append("<p>Course: ").Append(HttpUtility.HtmlEncode(lblCourseCode.Text + " - " + lblCourseName.Text)).Append("</p>");
            sb.Append("<p>Generated: ").Append(DateTime.Now.ToString("dd MMM yyyy, hh:mm tt")).Append("</p>");
            sb.Append("<table border='1' cellspacing='0' cellpadding='5'><tr>");

            foreach (DataColumn col in dt.Columns)
            {
                sb.Append("<th>").Append(HttpUtility.HtmlEncode(col.ColumnName)).Append("</th>");
            }
            sb.Append("</tr>");

            foreach (DataRow row in dt.Rows)
            {
                sb.Append("<tr>");
                foreach (object value in row.ItemArray)
                {
                    sb.Append("<td>").Append(HttpUtility.HtmlEncode(Convert.ToString(value))).Append("</td>");
                }
                sb.Append("</tr>");
            }

            sb.Append("</table></body></html>");
            return sb.ToString();
        }

        private string GetExportFileName(string extension)
        {
            string name = "Detailed_Attendance_Report_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + "." + extension;
            foreach (char c in Path.GetInvalidFileNameChars())
            {
                name = name.Replace(c, '_');
            }
            return name;
        }

        private void ExportTextFile(string content, string contentType, string fileName)
        {
            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = contentType;
            Response.AddHeader("content-disposition", "attachment;filename=" + fileName);
            Response.Charset = "";
            Response.Output.Write(content);
            Response.Flush();
            Response.End();
        }

        private void ShowMessage(string title, string message)
        {
            string safeTitle = HttpUtility.JavaScriptStringEncode(title);
            string safeMessage = HttpUtility.JavaScriptStringEncode(message).Replace("\r\n", "<br/>").Replace("\n", "<br/>");
            string script = string.Format("showMessageModal('{0}', '{1}');", safeTitle, safeMessage);
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"), script, true);
        }
    }
}
