using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Lecturer
{
    public partial class AttendanceReport : Page
    {
        private const string ReportSessionKey = "SIMS_AttendanceReportData";
        private const string DateSummarySessionKey = "SIMS_AttendanceReportDateSummaryData";
        private const string ReportTitleSessionKey = "SIMS_AttendanceReportTitle";

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
            ddlProgramme.Items.Clear();
            ddlProgramme.Items.Add(new ListItem("-- Select Programme --", ""));

            DataTable dt = DatabaseHelper.ExecuteQuery(@"
                SELECT DISTINCT p.ProgrammeId,
                       p.ProgrammeCode + ' - ' + p.ProgrammeName AS ProgrammeDisplay
                FROM LecturerCourse lc
                INNER JOIN Courses c ON c.CourseId = lc.CourseId
                INNER JOIN Programmes p ON p.ProgrammeId = c.ProgrammeId
                WHERE lc.LecturerId = @LecturerId
                ORDER BY ProgrammeDisplay",
                new[] { new SqlParameter("@LecturerId", CurrentLecturerId) });

            foreach (DataRow row in dt.Rows)
                ddlProgramme.Items.Add(new ListItem(row["ProgrammeDisplay"].ToString(), row["ProgrammeId"].ToString()));
        }

        private void LoadSessions()
        {
            ddlSession.Items.Clear();
            ddlSession.Items.Add(new ListItem("-- Select Session --", ""));

            DataTable dt = DatabaseHelper.ExecuteQuery(@"
                SELECT DISTINCT lc.Session
                FROM LecturerCourse lc
                INNER JOIN Courses c ON c.CourseId = lc.CourseId
                WHERE lc.LecturerId = @LecturerId
                  AND (@ProgrammeId = '' OR CONVERT(VARCHAR(20), c.ProgrammeId) = @ProgrammeId)
                ORDER BY lc.Session DESC",
                new[]
                {
                    new SqlParameter("@LecturerId", CurrentLecturerId),
                    new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue)
                });

            foreach (DataRow row in dt.Rows)
                ddlSession.Items.Add(new ListItem(row["Session"].ToString(), row["Session"].ToString()));
        }

        private void LoadCourses()
        {
            ddlCourse.Items.Clear();
            ddlCourse.Items.Add(new ListItem("-- Select Course --", ""));

            DataTable dt = DatabaseHelper.ExecuteQuery(@"
                SELECT DISTINCT c.CourseId,
                       c.CourseCode + ' - ' + c.CourseName AS CourseDisplay
                FROM LecturerCourse lc
                INNER JOIN Courses c ON c.CourseId = lc.CourseId
                WHERE lc.LecturerId = @LecturerId
                  AND (@ProgrammeId = '' OR CONVERT(VARCHAR(20), c.ProgrammeId) = @ProgrammeId)
                  AND (@Session = '' OR lc.Session = @Session)
                ORDER BY CourseDisplay",
                new[]
                {
                    new SqlParameter("@LecturerId", CurrentLecturerId),
                    new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue),
                    new SqlParameter("@Session", ddlSession.SelectedValue)
                });

            foreach (DataRow row in dt.Rows)
                ddlCourse.Items.Add(new ListItem(row["CourseDisplay"].ToString(), row["CourseId"].ToString()));
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
                pnlEmpty.Visible = true;
                return;
            }

            DataTable dates = GetAttendanceDates();
            DataTable matrix = BuildAttendanceMatrix(dates);
            DataTable dateSummary = BuildDateSummary(dates);

            Session[ReportSessionKey] = matrix;
            Session[DateSummarySessionKey] = dateSummary;
            Session[ReportTitleSessionKey] = "Attendance Report";

            lblProgramme.Text = ddlProgramme.SelectedItem.Text;
            lblSession.Text = ddlSession.SelectedValue;
            lblCourse.Text = GetCourseName(ddlCourse.SelectedValue);
            lblCourseCode.Text = GetCourseCode(ddlCourse.SelectedValue);

            gvReport.DataSource = matrix;
            gvReport.DataBind();

            gvDateSummary.DataSource = dateSummary;
            gvDateSummary.DataBind();

            int totalStudents = matrix.Rows.Count;
            int totalClasses = dates.Rows.Count;
            decimal avgAttendance = 0;

            if (totalStudents > 0 && totalClasses > 0)
            {
                int totalAttended = 0;

                foreach (DataRow row in matrix.Rows)
                    totalAttended += Convert.ToInt32(row["Total Attended"]);

                avgAttendance = Math.Round((decimal)totalAttended * 100 / (totalStudents * totalClasses), 2);
            }

            lblTotalStudents.Text = totalStudents.ToString();
            lblTotalClasses.Text = totalClasses.ToString();
            lblAverageAttendance.Text = avgAttendance.ToString("N2") + "%";

            pnlReport.Visible = matrix.Rows.Count > 0;
            pnlEmpty.Visible = matrix.Rows.Count == 0;
        }

        private DataTable GetAttendanceDates()
        {
            return DatabaseHelper.ExecuteQuery(@"
                SELECT DISTINCT AttendanceDate
                FROM Attendance
                WHERE Session = @Session
                  AND CourseId = @CourseId
                  AND LecturerId = @LecturerId
                ORDER BY AttendanceDate",
                new[]
                {
                    new SqlParameter("@Session", ddlSession.SelectedValue),
                    new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                    new SqlParameter("@LecturerId", CurrentLecturerId)
                });
        }

        private DataTable BuildAttendanceMatrix(DataTable dates)
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

            DataTable students = GetEnrolledStudents();
            DataTable attendance = GetAttendanceRecords();

            foreach (DataRow student in students.Rows)
            {
                string studentId = student["StudentId"].ToString();
                DataRow row = matrix.NewRow();

                row["Student ID"] = studentId;
                row["Student Name"] = student["StudentName"].ToString();

                int attended = 0;

                foreach (DataRow dateRow in dates.Rows)
                {
                    DateTime date = Convert.ToDateTime(dateRow["AttendanceDate"]);
                    string status = GetAttendanceStatus(attendance, studentId, date);
                    string display = GetStatusDisplay(status);

                    row[date.ToString("dd/MM")] = display;

                    if (status.Equals("Present", StringComparison.OrdinalIgnoreCase) ||
                        status.Equals("Late", StringComparison.OrdinalIgnoreCase))
                        attended++;
                }

                decimal percent = dates.Rows.Count == 0 ? 0 : Math.Round((decimal)attended * 100 / dates.Rows.Count, 2);

                row["Total Attended"] = attended;
                row["Attendance %"] = percent.ToString("N2") + "%";

                matrix.Rows.Add(row);
            }

            return matrix;
        }

        private DataTable GetEnrolledStudents()
        {
            return DatabaseHelper.ExecuteQuery(@"
                SELECT sd.StudentId,
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
                ORDER BY sd.FirstName, sd.LastName",
                new[]
                {
                    new SqlParameter("@LecturerId", CurrentLecturerId),
                    new SqlParameter("@Session", ddlSession.SelectedValue),
                    new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                    new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue)
                });
        }

        private DataTable GetAttendanceRecords()
        {
            return DatabaseHelper.ExecuteQuery(@"
                SELECT StudentId, AttendanceDate, Status
                FROM Attendance
                WHERE Session = @Session
                  AND CourseId = @CourseId
                  AND LecturerId = @LecturerId",
                new[]
                {
                    new SqlParameter("@Session", ddlSession.SelectedValue),
                    new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                    new SqlParameter("@LecturerId", CurrentLecturerId)
                });
        }

        private DataTable BuildDateSummary(DataTable dates)
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
                    WHERE Session = @Session
                      AND CourseId = @CourseId
                      AND LecturerId = @LecturerId
                      AND AttendanceDate = @AttendanceDate",
                    new[]
                    {
                        new SqlParameter("@Session", ddlSession.SelectedValue),
                        new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                        new SqlParameter("@LecturerId", CurrentLecturerId),
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

        private string GetAttendanceStatus(DataTable attendance, string studentId, DateTime date)
        {
            string filter = "StudentId = '" + studentId.Replace("'", "''") + "' AND AttendanceDate = #" + date.ToString("MM/dd/yyyy") + "#";
            DataRow[] rows = attendance.Select(filter);

            return rows.Length > 0 ? rows[0]["Status"].ToString() : "";
        }

        private string GetStatusDisplay(string status)
        {
            if (status.Equals("Present", StringComparison.OrdinalIgnoreCase)) return "P";
            if (status.Equals("Absent", StringComparison.OrdinalIgnoreCase)) return "A";
            if (status.Equals("Late", StringComparison.OrdinalIgnoreCase)) return "L";
            return "-";
        }

        protected void gvReport_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

            foreach (TableCell cell in e.Row.Cells)
            {
                string text = HttpUtility.HtmlDecode(cell.Text).Trim();

                if (text == "P") cell.Text = "<span class='status-pill status-present'>P</span>";
                else if (text == "A") cell.Text = "<span class='status-pill status-absent'>A</span>";
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
            DataTable mainData = Session[ReportSessionKey] as DataTable;
            if (mainData == null || mainData.Rows.Count == 0)
                return;

            string title = Convert.ToString(Session[ReportTitleSessionKey]);
            DataTable dateSummary = Session[DateSummarySessionKey] as DataTable;

            byte[] pdf = SimplePdfHelper.CreateProfessionalReportPdf(
                string.IsNullOrWhiteSpace(title) ? "Attendance Report" : title,
                BuildPdfFilterTable(),
                BuildPdfSummaryTable(),
                dateSummary,
                BuildPdfMainTable(mainData),
                "Student Attendance Summary");

            Response.Clear();
            Response.ContentType = "application/pdf";
            Response.AddHeader("Content-Disposition", "attachment;filename=Attendance_Report.pdf");
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
            AddPdfInfoRow(dt, "Total Students", lblTotalStudents.Text);
            AddPdfInfoRow(dt, "Total Classes", lblTotalClasses.Text);
            AddPdfInfoRow(dt, "Average Attendance", lblAverageAttendance.Text);
            AddPdfInfoRow(dt, "Course", lblCourseCode.Text);
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

        private DataTable BuildPdfMainTable(DataTable source)
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

        private void ExportText(string type)
        {
            DataTable dt = Session[ReportSessionKey] as DataTable;

            if (dt == null || dt.Rows.Count == 0)
                return;

            string title = "Attendance Report";
            string content = type == "xls" ? BuildExcelHtml(title, dt) : BuildCsv(dt);
            string extension = type == "xls" ? ".xls" : ".csv";
            string contentType = type == "xls" ? "application/vnd.ms-excel" : "text/csv";

            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = contentType;
            Response.AddHeader("Content-Disposition", "attachment;filename=" + title.Replace(" ", "_") + extension);
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
                sb.Append("\"" + dt.Columns[i].ColumnName + "\"");
            }

            sb.AppendLine();

            foreach (DataRow row in dt.Rows)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    if (i > 0) sb.Append(',');
                    sb.Append("\"" + Convert.ToString(row[i]).Replace("\"", "\"\"") + "\"");
                }

                sb.AppendLine();
            }

            return sb.ToString();
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

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlProgramme.SelectedIndex = 0;
            LoadSessions();
            ddlSession.SelectedIndex = 0;
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
            gvDateSummary.DataSource = null;
            gvDateSummary.DataBind();
            Session.Remove(ReportSessionKey);
            Session.Remove(DateSummarySessionKey);
            Session.Remove(ReportTitleSessionKey);
        }

        private string GetCourseName(string courseId)
        {
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT CourseCode + ' - ' + CourseName FROM Courses WHERE CourseId = @CourseId",
                new[] { new SqlParameter("@CourseId", courseId) });

            return result == null ? "" : result.ToString();
        }

        private string GetCourseCode(string courseId)
        {
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT CourseCode FROM Courses WHERE CourseId = @CourseId",
                new[] { new SqlParameter("@CourseId", courseId) });

            return result == null ? "" : result.ToString();
        }

        private void CheckUnreadNotifications()
        {
            object count = DatabaseHelper.ExecuteScalar(
                @"SELECT COUNT(*) 
                  FROM Notifications 
                  WHERE UserId = @UserId 
                    AND IsRead = 0",
                new[] { new SqlParameter("@UserId", SessionHelper.GetUserId(Session)) });

            pnlNotifBadge.Visible = count != null && Convert.ToInt32(count) > 0;
        }
    }
}
