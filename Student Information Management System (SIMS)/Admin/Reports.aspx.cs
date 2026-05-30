using System;
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
    public partial class Reports : Page
    {
        private const string ReportDataSessionKey = "AdminReportData";
        private const string ReportTitleSessionKey = "AdminReportTitle";

        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                LoadStats();
                LoadSessions();
                LoadProgrammes();
                LoadCourses();
                GenerateReport();
            }
        }

        private void LoadStats()
        {
            lblTotalStudents.Text = Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM StudentDetails"));
            lblActiveEnrollments.Text = Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM Enrollment WHERE Status = 'Active'"));
            lblAttendanceRecords.Text = Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM Attendance"));
        }

        private void LoadSessions()
        {
            ddlSession.Items.Clear();
            ddlSession.Items.Add(new ListItem("All Sessions", ""));

            string sql = @"
                SELECT DISTINCT Session
                FROM (
                    SELECT Session FROM Enrollment
                    UNION
                    SELECT Session FROM CourseOffering
                    UNION
                    SELECT Session FROM Attendance
                ) x
                WHERE Session IS NOT NULL AND LTRIM(RTRIM(Session)) <> ''
                ORDER BY Session DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);
            foreach (DataRow row in dt.Rows)
            {
                ddlSession.Items.Add(new ListItem(row["Session"].ToString(), row["Session"].ToString()));
            }
        }

        private void LoadProgrammes()
        {
            string sql = @"
                SELECT ProgrammeId, ProgrammeCode + ' - ' + ProgrammeName AS ProgrammeDisplay
                FROM Programmes
                ORDER BY ProgrammeName";

            ddlProgramme.DataSource = DatabaseHelper.ExecuteQuery(sql);
            ddlProgramme.DataTextField = "ProgrammeDisplay";
            ddlProgramme.DataValueField = "ProgrammeId";
            ddlProgramme.DataBind();
            ddlProgramme.Items.Insert(0, new ListItem("All Programmes", ""));
        }

        private void LoadCourses()
        {
            string sql = @"
                SELECT CourseId, CourseCode + ' - ' + CourseName AS CourseDisplay
                FROM Courses
                ORDER BY CourseCode";

            ddlCourse.DataSource = DatabaseHelper.ExecuteQuery(sql);
            ddlCourse.DataTextField = "CourseDisplay";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("All Courses", ""));
        }

        protected void ddlReportType_SelectedIndexChanged(object sender, EventArgs e)
        {
            GenerateReport();
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            GenerateReport();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlReportType.SelectedValue = "Enrollment";
            ddlSession.SelectedIndex = 0;
            ddlProgramme.SelectedIndex = 0;
            ddlCourse.SelectedIndex = 0;
            GenerateReport();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        private void GenerateReport()
        {
            pnlPerformanceComingSoon.Visible = false;
            pnlExport.Visible = false;

            DataTable dt;
            string title;

            if (ddlReportType.SelectedValue == "Attendance")
            {
                title = "Attendance Summary";
                dt = GetAttendanceSummary();
            }
            else if (ddlReportType.SelectedValue == "Performance")
            {
                title = "Student Performance Report";
                dt = new DataTable();
                pnlPerformanceComingSoon.Visible = true;
            }
            else
            {
                title = "Enrolment Statistics";
                dt = GetEnrollmentStatistics();
            }

            lblReportTitle.Text = title;
            lblGeneratedAt.Text = "Generated: " + DateTime.Now.ToString("dd MMM yyyy, hh:mm tt");

            gvReport.DataSource = dt;
            gvReport.DataBind();

            Session[ReportDataSessionKey] = dt;
            Session[ReportTitleSessionKey] = title;
            pnlExport.Visible = dt.Rows.Count > 0;
        }

        private DataTable GetEnrollmentStatistics()
        {
            string sql = @"
                SELECT e.Session,
                       p.ProgrammeCode AS Programme,
                       p.ProgrammeName,
                       e.Semester,
                       COUNT(DISTINCT e.StudentId) AS TotalStudents,
                       COUNT(e.CourseId) AS TotalCourseEnrollments,
                       SUM(CASE WHEN e.Status = 'Active' THEN 1 ELSE 0 END) AS Active,
                       SUM(CASE WHEN e.Status = 'Dropped' THEN 1 ELSE 0 END) AS Dropped,
                       SUM(CASE WHEN e.Status = 'Completed' THEN 1 ELSE 0 END) AS Completed
                FROM Enrollment e
                INNER JOIN StudentDetails s ON e.StudentId = s.StudentId
                INNER JOIN Programmes p ON s.ProgrammeId = p.ProgrammeId
                INNER JOIN Courses c ON e.CourseId = c.CourseId
                WHERE (@Session = '' OR e.Session = @Session)
                  AND (@ProgrammeId = '' OR CONVERT(VARCHAR(20), p.ProgrammeId) = @ProgrammeId)
                  AND (@CourseId = '' OR CONVERT(VARCHAR(20), c.CourseId) = @CourseId)
                GROUP BY e.Session, p.ProgrammeCode, p.ProgrammeName, e.Semester
                ORDER BY e.Session DESC, p.ProgrammeCode, e.Semester";

            return DatabaseHelper.ExecuteQuery(sql, GetFilterParameters());
        }

        private DataTable GetAttendanceSummary()
        {
            string sql = @"
                SELECT a.Session,
                       p.ProgrammeCode AS Programme,
                       c.CourseCode,
                       c.CourseName,
                       COUNT(*) AS TotalRecords,
                       SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) AS Present,
                       SUM(CASE WHEN a.Status = 'Absent' THEN 1 ELSE 0 END) AS Absent,
                       SUM(CASE WHEN a.Status = 'Late' THEN 1 ELSE 0 END) AS Late,
                       CAST(
                            CASE WHEN COUNT(*) = 0 THEN 0
                                 ELSE (SUM(CASE WHEN a.Status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0 / COUNT(*))
                            END AS DECIMAL(5,2)
                       ) AS AttendanceRatePercent
                FROM Attendance a
                INNER JOIN StudentDetails s ON a.StudentId = s.StudentId
                INNER JOIN Programmes p ON s.ProgrammeId = p.ProgrammeId
                INNER JOIN Courses c ON a.CourseId = c.CourseId
                WHERE (@Session = '' OR a.Session = @Session)
                  AND (@ProgrammeId = '' OR CONVERT(VARCHAR(20), p.ProgrammeId) = @ProgrammeId)
                  AND (@CourseId = '' OR CONVERT(VARCHAR(20), c.CourseId) = @CourseId)
                GROUP BY a.Session, p.ProgrammeCode, c.CourseCode, c.CourseName
                ORDER BY a.Session DESC, p.ProgrammeCode, c.CourseCode";

            return DatabaseHelper.ExecuteQuery(sql, GetFilterParameters());
        }

        private SqlParameter[] GetFilterParameters()
        {
            return new SqlParameter[]
            {
                new SqlParameter("@Session", ddlSession.SelectedValue ?? ""),
                new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue ?? ""),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue ?? "")
            };
        }

        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            DataTable dt = GetCurrentReportData();
            if (dt.Rows.Count == 0)
            {
                ShowMessage("No Data", "Please generate a report with data before exporting.");
                return;
            }

            string fileName = GetExportFileName("csv");
            string csv = BuildCsv(dt);

            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "text/csv";
            Response.AddHeader("content-disposition", "attachment;filename=" + fileName);
            Response.Charset = "";
            Response.Output.Write(csv);
            Response.Flush();
            Response.End();
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            DataTable dt = GetCurrentReportData();
            if (dt.Rows.Count == 0)
            {
                ShowMessage("No Data", "Please generate a report with data before exporting.");
                return;
            }

            string fileName = GetExportFileName("xls");
            string html = BuildExcelHtml(dt, Convert.ToString(Session[ReportTitleSessionKey]));

            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("content-disposition", "attachment;filename=" + fileName);
            Response.Charset = "";
            Response.Output.Write(html);
            Response.Flush();
            Response.End();
        }

        protected void btnExportPdf_Click(object sender, EventArgs e)
        {
            DataTable dt = GetCurrentReportData();
            if (dt.Rows.Count == 0)
            {
                ShowMessage("No Data", "Please generate a report with data before exporting.");
                return;
            }

            string title = Convert.ToString(Session[ReportTitleSessionKey]);
            byte[] pdfBytes = SimplePdfHelper.CreatePdf(title, dt);
            string fileName = GetExportFileName("pdf");

            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "application/pdf";
            Response.AddHeader("content-disposition", "attachment;filename=" + fileName);
            Response.BinaryWrite(pdfBytes);
            Response.Flush();
            Response.End();
        }

        private DataTable GetCurrentReportData()
        {
            DataTable dt = Session[ReportDataSessionKey] as DataTable;
            if (dt == null)
            {
                GenerateReport();
                dt = Session[ReportDataSessionKey] as DataTable;
            }
            return dt ?? new DataTable();
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

        private string BuildExcelHtml(DataTable dt, string title)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><meta charset='utf-8'></head><body>");
            sb.Append("<h2>").Append(HttpUtility.HtmlEncode(title)).Append("</h2>");
            sb.Append("<p>Generated: ").Append(DateTime.Now.ToString("dd MMM yyyy, hh:mm tt")).Append("</p>");
            sb.Append("<table border='1' cellspacing='0' cellpadding='5'>");
            sb.Append("<tr>");
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
            string title = Convert.ToString(Session[ReportTitleSessionKey] ?? "SIMS_Report");
            foreach (char c in Path.GetInvalidFileNameChars())
            {
                title = title.Replace(c, '_');
            }
            title = title.Replace(" ", "_");
            return title + "_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + "." + extension;
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
