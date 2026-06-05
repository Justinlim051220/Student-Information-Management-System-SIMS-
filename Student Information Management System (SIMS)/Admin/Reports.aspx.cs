using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Admin
{
    public partial class Reports : Page
    {
        private const string MainReportSessionKey = "SIMS_CurrentReportData";
        private const string DateSummarySessionKey = "SIMS_CurrentDateSummaryData";
        private const string ReportTitleSessionKey = "SIMS_CurrentReportTitle";

        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                LoadSessions();
                LoadProgrammes();
                LoadCourses();
                UpdateFilterVisibility();
                ClearReportPanels();
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
                    SELECT Session FROM Fees
                    UNION
                    SELECT Session FROM CourseOffering
                ) x
                WHERE Session IS NOT NULL AND LTRIM(RTRIM(Session)) <> ''
                ORDER BY Session DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);
            foreach (DataRow row in dt.Rows)
            {
                string session = Convert.ToString(row["Session"]);
                ddlSession.Items.Add(new ListItem(session, session));
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

        protected void ddlReportType_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateFilterVisibility();
            ClearReportPanels();
        }

        private void UpdateFilterVisibility()
        {
            pnlCourseFilter.Visible = ddlReportType.SelectedValue == "Attendance";
            pnlAcademicSoon.Visible = ddlReportType.SelectedValue == "Academic";
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            UpdateFilterVisibility();
            ClearReportPanels();

            if (string.IsNullOrWhiteSpace(ddlReportType.SelectedValue))
            {
                ShowMessage("Filter Required", "Please select the report type first.");
                return;
            }

            if (ddlReportType.SelectedValue == "Academic")
            {
                ShowMessage("Coming Soon", "Academic Report is not available yet.");
                return;
            }

            if (string.IsNullOrWhiteSpace(ddlSession.SelectedValue) ||
                string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue))
            {
                ShowMessage("Filter Required", "Please select session and programme before generating the report.");
                return;
            }

            if (ddlReportType.SelectedValue == "Attendance")
            {
                if (string.IsNullOrWhiteSpace(ddlCourse.SelectedValue))
                {
                    ShowMessage("Filter Required", "Please select course code and name before generating the attendance report.");
                    return;
                }

                GenerateAttendanceReport();
                return;
            }

            if (ddlReportType.SelectedValue == "FeePayment")
            {
                GenerateFeePaymentReport();
                return;
            }

            if (ddlReportType.SelectedValue == "Enrollment")
            {
                GenerateEnrollmentReport();
            }
        }

        private void GenerateFeePaymentReport()
        {
            DataTable dt = GetFeePaymentData(ddlSession.SelectedValue, ddlProgramme.SelectedValue);
            BindCommonReport("Fee Payment Report", dt, null, false);

            decimal total = 0, paid = 0, pending = 0;
            foreach (DataRow row in dt.Rows)
            {
                decimal amount = row["Amount"] == DBNull.Value ? 0 : Convert.ToDecimal(row["Amount"]);
                string status = Convert.ToString(row["Status"]);
                total += amount;
                if (status.Equals("Paid", StringComparison.OrdinalIgnoreCase)) paid += amount;
                if (status.Equals("Pending", StringComparison.OrdinalIgnoreCase) || status.Equals("Overdue", StringComparison.OrdinalIgnoreCase)) pending += amount;
            }

            SetSummary("Total Records", dt.Rows.Count.ToString(), "Total Amount", "RM " + total.ToString("N2"), "Paid Amount", "RM " + paid.ToString("N2"), "Pending / Overdue", "RM " + pending.ToString("N2"));
        }

        private DataTable GetFeePaymentData(string session, string programmeId)
        {
            string sql = @"
                SELECT f.StudentId AS [Student ID],
                       sd.FirstName + ' ' + sd.LastName AS [Student Name],
                       f.Session,
                       f.FeeType AS [Fee Type],
                       f.Amount,
                       f.Status,
                       ISNULL(CONVERT(VARCHAR(11), f.PaymentDate, 106), '-') AS [Payment Date]
                FROM Fees f
                INNER JOIN StudentDetails sd ON f.StudentId = sd.StudentId
                WHERE f.Session = @Session
                  AND sd.ProgrammeId = @ProgrammeId
                ORDER BY sd.FirstName, sd.LastName, f.FeeType";

            return DatabaseHelper.ExecuteQuery(sql, new SqlParameter[]
            {
                new SqlParameter("@Session", session),
                new SqlParameter("@ProgrammeId", programmeId)
            });
        }

        private void GenerateEnrollmentReport()
        {
            DataTable dt = GetEnrollmentData(ddlSession.SelectedValue, ddlProgramme.SelectedValue);
            BindCommonReport("Enrollment Statistics Report", dt, null, false);

            int total = 0, active = 0, pending = 0, dropped = 0;
            foreach (DataRow row in dt.Rows)
            {
                total += Convert.ToInt32(row["Total Enrollments"]);
                active += Convert.ToInt32(row["Active"]);
                pending += Convert.ToInt32(row["Pending"]);
                dropped += Convert.ToInt32(row["Dropped"]);
            }

            SetSummary("Total Enrollments", total.ToString(), "Active", active.ToString(), "Pending", pending.ToString(), "Dropped", dropped.ToString());
        }

        private DataTable GetEnrollmentData(string session, string programmeId)
        {
            string sql = @"
                SELECT c.CourseCode AS [Course Code],
                       c.CourseName AS [Course Name],
                       e.Semester,
                       COUNT(e.StudentId) AS [Total Enrollments],
                       SUM(CASE WHEN e.Status = 'Active' THEN 1 ELSE 0 END) AS [Active],
                       SUM(CASE WHEN e.Status LIKE '%Pending%' THEN 1 ELSE 0 END) AS [Pending],
                       SUM(CASE WHEN e.Status = 'Dropped' THEN 1 ELSE 0 END) AS [Dropped],
                       SUM(CASE WHEN e.Status LIKE '%Rejected%' THEN 1 ELSE 0 END) AS [Rejected]
                FROM Enrollment e
                INNER JOIN Courses c ON e.CourseId = c.CourseId
                WHERE e.Session = @Session
                  AND c.ProgrammeId = @ProgrammeId
                GROUP BY c.CourseCode, c.CourseName, e.Semester
                ORDER BY e.Semester, c.CourseCode";

            return DatabaseHelper.ExecuteQuery(sql, new SqlParameter[]
            {
                new SqlParameter("@Session", session),
                new SqlParameter("@ProgrammeId", programmeId)
            });
        }

        private void GenerateAttendanceReport()
        {
            string session = ddlSession.SelectedValue;
            string programmeId = ddlProgramme.SelectedValue;
            int courseId = Convert.ToInt32(ddlCourse.SelectedValue);

            DataTable dates = GetAttendanceDates(session, courseId);
            DataTable matrix = BuildAttendanceMatrix(session, programmeId, courseId, dates);
            DataTable dateSummary = BuildDateSummary(session, courseId, dates);

            BindCommonReport("Attendance Report", matrix, dateSummary, true);
            pnlCourseInfo.Visible = true;
            lblCourse.Text = HttpUtility.HtmlEncode(GetCourseName(courseId.ToString()));

            int totalStudents = matrix.Rows.Count;
            int totalClasses = dates.Rows.Count;
            decimal avgAttendance = 0;
            if (totalStudents > 0 && totalClasses > 0)
            {
                int totalPresentLate = 0;
                foreach (DataRow row in matrix.Rows)
                {
                    totalPresentLate += Convert.ToInt32(row["Total Attended"]);
                }
                avgAttendance = Math.Round((decimal)totalPresentLate * 100 / (totalStudents * totalClasses), 2);
            }

            SetSummary("Total Students", totalStudents.ToString(), "Total Classes", totalClasses.ToString(), "Average Attendance", avgAttendance.ToString("N2") + "%", "Course", GetCourseCode(courseId.ToString()));
        }

        private DataTable GetAttendanceDates(string session, int courseId)
        {
            string sql = @"
                SELECT DISTINCT AttendanceDate
                FROM Attendance
                WHERE Session = @Session AND CourseId = @CourseId
                ORDER BY AttendanceDate";

            return DatabaseHelper.ExecuteQuery(sql, new SqlParameter[]
            {
                new SqlParameter("@Session", session),
                new SqlParameter("@CourseId", courseId)
            });
        }

        private DataTable BuildAttendanceMatrix(string session, string programmeId, int courseId, DataTable dates)
        {
            DataTable matrix = new DataTable();
            matrix.Columns.Add("Student ID");
            matrix.Columns.Add("Student Name");

            foreach (DataRow dateRow in dates.Rows)
            {
                DateTime date = Convert.ToDateTime(dateRow["AttendanceDate"]);
                matrix.Columns.Add(date.ToString("dd/MM"));
            }

            matrix.Columns.Add("Total Attended", typeof(int));
            matrix.Columns.Add("Attendance %");

            DataTable students = GetEnrolledStudents(session, programmeId, courseId);
            DataTable attendance = GetAttendanceRecords(session, courseId);

            foreach (DataRow student in students.Rows)
            {
                string studentId = Convert.ToString(student["StudentId"]);
                DataRow row = matrix.NewRow();
                row["Student ID"] = studentId;
                row["Student Name"] = Convert.ToString(student["StudentName"]);

                int attended = 0;
                foreach (DataRow dateRow in dates.Rows)
                {
                    DateTime date = Convert.ToDateTime(dateRow["AttendanceDate"]);
                    string colName = date.ToString("dd/MM");
                    string status = GetAttendanceStatus(attendance, studentId, date);
                    string display = GetStatusDisplay(status);
                    row[colName] = display;
                    if (status.Equals("Present", StringComparison.OrdinalIgnoreCase) || status.Equals("Late", StringComparison.OrdinalIgnoreCase)) attended++;
                }

                int totalClass = dates.Rows.Count;
                decimal percent = totalClass == 0 ? 0 : Math.Round((decimal)attended * 100 / totalClass, 2);
                row["Total Attended"] = attended;
                row["Attendance %"] = percent.ToString("N2") + "%";
                matrix.Rows.Add(row);
            }

            return matrix;
        }

        private DataTable GetEnrolledStudents(string session, string programmeId, int courseId)
        {
            string sql = @"
                SELECT sd.StudentId,
                       sd.FirstName + ' ' + sd.LastName AS StudentName
                FROM Enrollment e
                INNER JOIN StudentDetails sd ON e.StudentId = sd.StudentId
                WHERE e.Session = @Session
                  AND e.CourseId = @CourseId
                  AND sd.ProgrammeId = @ProgrammeId
                  AND e.Status IN ('Active', 'Completed', 'Enrollment Pending')
                ORDER BY sd.FirstName, sd.LastName";

            return DatabaseHelper.ExecuteQuery(sql, new SqlParameter[]
            {
                new SqlParameter("@Session", session),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@ProgrammeId", programmeId)
            });
        }

        private DataTable GetAttendanceRecords(string session, int courseId)
        {
            string sql = @"
                SELECT StudentId, AttendanceDate, Status
                FROM Attendance
                WHERE Session = @Session AND CourseId = @CourseId";

            return DatabaseHelper.ExecuteQuery(sql, new SqlParameter[]
            {
                new SqlParameter("@Session", session),
                new SqlParameter("@CourseId", courseId)
            });
        }

        private string GetAttendanceStatus(DataTable attendance, string studentId, DateTime date)
        {
            string filter = "StudentId = '" + studentId.Replace("'", "''") + "' AND AttendanceDate = #" + date.ToString("MM/dd/yyyy") + "#";
            DataRow[] rows = attendance.Select(filter);
            return rows.Length > 0 ? Convert.ToString(rows[0]["Status"]) : "";
        }

        private string GetStatusDisplay(string status)
        {
            if (status.Equals("Present", StringComparison.OrdinalIgnoreCase)) return "✓";
            if (status.Equals("Absent", StringComparison.OrdinalIgnoreCase)) return "✗";
            if (status.Equals("Late", StringComparison.OrdinalIgnoreCase)) return "L";
            return "-";
        }

        private DataTable BuildDateSummary(string session, int courseId, DataTable dates)
        {
            DataTable summary = new DataTable();
            summary.Columns.Add("Class Date");
            summary.Columns.Add("Present", typeof(int));
            summary.Columns.Add("Absent", typeof(int));
            summary.Columns.Add("Late", typeof(int));
            summary.Columns.Add("Rate");

            foreach (DataRow dateRow in dates.Rows)
            {
                DateTime date = Convert.ToDateTime(dateRow["AttendanceDate"]);
                DataTable counts = DatabaseHelper.ExecuteQuery(@"
                    SELECT
                        SUM(CASE WHEN Status = 'Present' THEN 1 ELSE 0 END) AS PresentCount,
                        SUM(CASE WHEN Status = 'Absent' THEN 1 ELSE 0 END) AS AbsentCount,
                        SUM(CASE WHEN Status = 'Late' THEN 1 ELSE 0 END) AS LateCount,
                        COUNT(*) AS TotalCount
                    FROM Attendance
                    WHERE Session = @Session AND CourseId = @CourseId AND AttendanceDate = @AttendanceDate", new SqlParameter[]
                {
                    new SqlParameter("@Session", session),
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@AttendanceDate", date)
                });

                int present = counts.Rows[0]["PresentCount"] == DBNull.Value ? 0 : Convert.ToInt32(counts.Rows[0]["PresentCount"]);
                int absent = counts.Rows[0]["AbsentCount"] == DBNull.Value ? 0 : Convert.ToInt32(counts.Rows[0]["AbsentCount"]);
                int late = counts.Rows[0]["LateCount"] == DBNull.Value ? 0 : Convert.ToInt32(counts.Rows[0]["LateCount"]);
                int total = counts.Rows[0]["TotalCount"] == DBNull.Value ? 0 : Convert.ToInt32(counts.Rows[0]["TotalCount"]);
                decimal rate = total == 0 ? 0 : Math.Round((decimal)(present + late) * 100 / total, 2);

                DataRow row = summary.NewRow();
                row["Class Date"] = date.ToString("dd/MM/yyyy");
                row["Present"] = present;
                row["Absent"] = absent;
                row["Late"] = late;
                row["Rate"] = rate.ToString("N2") + "%";
                summary.Rows.Add(row);
            }

            return summary;
        }

        private void BindCommonReport(string title, DataTable mainData, DataTable dateSummary, bool showDateSummary)
        {
            Session[MainReportSessionKey] = mainData;
            Session[DateSummarySessionKey] = dateSummary;
            Session[ReportTitleSessionKey] = title;

            lblReportTitle.Text = title;
            lblSession.Text = HttpUtility.HtmlEncode(ddlSession.SelectedValue);
            lblProgramme.Text = HttpUtility.HtmlEncode(GetProgrammeName(ddlProgramme.SelectedValue));
            pnlCourseInfo.Visible = false;

            pnlReport.Visible = mainData.Rows.Count > 0;
            pnlEmpty.Visible = mainData.Rows.Count == 0;

            gvReport.DataSource = mainData;
            gvReport.DataBind();

            pnlDateSummary.Visible = showDateSummary && dateSummary != null && dateSummary.Rows.Count > 0;
            gvDateSummary.DataSource = dateSummary;
            gvDateSummary.DataBind();
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

        protected void gvReport_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

            foreach (TableCell cell in e.Row.Cells)
            {
                string text = HttpUtility.HtmlDecode(cell.Text).Trim();
                if (text == "✓") cell.Text = "<span class='status-pill status-present'>✓</span>";
                else if (text == "✗") cell.Text = "<span class='status-pill status-absent'>✗</span>";
                else if (text == "L") cell.Text = "<span class='status-pill status-late'>L</span>";
                else if (text == "-") cell.Text = "<span class='status-pill status-empty'>-</span>";
            }
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
            DataTable mainData = Session[MainReportSessionKey] as DataTable;
            if (mainData == null || mainData.Rows.Count == 0)
            {
                ShowMessage("Export Failed", "Please generate a report before exporting.");
                return;
            }

            string title = Convert.ToString(Session[ReportTitleSessionKey]);
            DataTable dateSummary = Session[DateSummarySessionKey] as DataTable;
            DataTable pdfMainData = BuildPdfMainTable(title, mainData);
            DataTable summaryTable = BuildPdfSummaryTable();
            DataTable filterTable = BuildPdfFilterTable();

            byte[] pdf = SimplePdfHelper.CreateProfessionalReportPdf(
                title,
                filterTable,
                summaryTable,
                dateSummary,
                pdfMainData,
                GetPdfMainSectionTitle(title));

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
            AddPdfInfoRow(dt, "Session", ddlSession.SelectedValue);
            AddPdfInfoRow(dt, "Programme", GetProgrammeName(ddlProgramme.SelectedValue));
            if (ddlReportType.SelectedValue == "Attendance" && !string.IsNullOrWhiteSpace(ddlCourse.SelectedValue))
            {
                AddPdfInfoRow(dt, "Course", GetCourseName(ddlCourse.SelectedValue));
            }
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
            if (string.IsNullOrWhiteSpace(label)) return;
            DataRow row = dt.NewRow();
            row[0] = label;
            row[1] = string.IsNullOrWhiteSpace(value) ? "-" : HttpUtility.HtmlDecode(value);
            dt.Rows.Add(row);
        }

        private DataTable BuildPdfMainTable(string title, DataTable source)
        {
            if (title.Equals("Attendance Report", StringComparison.OrdinalIgnoreCase))
            {
                DataTable dt = new DataTable();
                dt.Columns.Add("No");
                dt.Columns.Add("Student ID");
                dt.Columns.Add("Student Name");
                dt.Columns.Add("Total Attended");
                dt.Columns.Add("Attendance %");

                int no = 1;
                foreach (DataRow src in source.Rows)
                {
                    DataRow row = dt.NewRow();
                    row["No"] = no.ToString();
                    row["Student ID"] = Convert.ToString(src["Student ID"]);
                    row["Student Name"] = Convert.ToString(src["Student Name"]);
                    row["Total Attended"] = Convert.ToString(src["Total Attended"]);
                    row["Attendance %"] = Convert.ToString(src["Attendance %"]);
                    dt.Rows.Add(row);
                    no++;
                }
                return dt;
            }

            return source;
        }

        private string GetPdfMainSectionTitle(string title)
        {
            if (title.Equals("Attendance Report", StringComparison.OrdinalIgnoreCase))
            {
                return "Student Attendance Summary";
            }
            return "Report Details";
        }

        private void ExportText(string type)
        {
            DataTable dt = Session[MainReportSessionKey] as DataTable;
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
            if (string.IsNullOrWhiteSpace(title)) title = "SIMS_Report";
            foreach (char c in System.IO.Path.GetInvalidFileNameChars()) title = title.Replace(c, '_');
            return title.Replace(" ", "_");
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlReportType.SelectedIndex = 0;
            ddlSession.SelectedIndex = 0;
            ddlProgramme.SelectedIndex = 0;
            ddlCourse.SelectedIndex = 0;
            UpdateFilterVisibility();
            ClearReportPanels();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        private void ClearReportPanels()
        {
            pnlReport.Visible = false;
            pnlEmpty.Visible = false;
            pnlDateSummary.Visible = false;
            pnlCourseInfo.Visible = false;
            gvReport.DataSource = null;
            gvReport.DataBind();
            gvDateSummary.DataSource = null;
            gvDateSummary.DataBind();
        }

        private string GetProgrammeName(string programmeId)
        {
            object result = DatabaseHelper.ExecuteScalar("SELECT ProgrammeCode + ' - ' + ProgrammeName FROM Programmes WHERE ProgrammeId = @ProgrammeId", new SqlParameter[]
            {
                new SqlParameter("@ProgrammeId", programmeId)
            });
            return Convert.ToString(result);
        }

        private string GetCourseName(string courseId)
        {
            object result = DatabaseHelper.ExecuteScalar("SELECT CourseCode + ' - ' + CourseName FROM Courses WHERE CourseId = @CourseId", new SqlParameter[]
            {
                new SqlParameter("@CourseId", courseId)
            });
            return Convert.ToString(result);
        }

        private string GetCourseCode(string courseId)
        {
            object result = DatabaseHelper.ExecuteScalar("SELECT CourseCode FROM Courses WHERE CourseId = @CourseId", new SqlParameter[]
            {
                new SqlParameter("@CourseId", courseId)
            });
            return Convert.ToString(result);
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
