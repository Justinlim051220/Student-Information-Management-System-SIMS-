using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Student
{
    public partial class CourseDetails : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                if (string.IsNullOrEmpty(GetCourseIdParam()) || string.IsNullOrEmpty(GetSessionParam()))
                {
                    Response.Redirect("MyCourses.aspx");
                    return;
                }

                LoadCourseHeader();
                LoadCourseMaterials();
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
                CheckUnreadNotifications();
            }
        }

        private string GetCourseIdParam()
        {
            return Request.QueryString["CourseId"] ?? Request.QueryString["courseId"];
        }

        private string GetSessionParam()
        {
            return Request.QueryString["Session"] ?? Request.QueryString["session"];
        }

        private string CurrentStudentId
        {
            get { return SessionHelper.GetProfileId(Session); }
        }

        private void LoadCourseHeader()
        {
            string sql = @"
                SELECT c.CourseCode, c.CourseName, c.Credits, c.Description,
                       (ld.FirstName + ' ' + ld.LastName) AS FullName
                FROM Courses c
                LEFT JOIN LecturerCourse lc ON c.CourseId = lc.CourseId AND lc.Session = @Session
                LEFT JOIN LecturerDetails ld ON lc.LecturerId = ld.LecturerId
                WHERE c.CourseId = @CourseId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@CourseId", Convert.ToInt32(GetCourseIdParam())),
                new SqlParameter("@Session", GetSessionParam())
            });

            if (dt != null && dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];

                lblCourseCode.Text = Server.HtmlEncode(row["CourseCode"].ToString());
                lblCourseName.Text = Server.HtmlEncode(row["CourseName"].ToString());
                lblCredits.Text = Server.HtmlEncode(row["Credits"].ToString());
                lblDescription.Text = Server.HtmlEncode(row["Description"].ToString());

                if (row["FullName"] != DBNull.Value)
                    lblLecturerName.Text = Server.HtmlEncode(row["FullName"].ToString());
            }
            else
            {
                Response.Redirect("MyCourses.aspx");
            }
        }

        private void LoadCourseMaterials()
        {
            string sql = @"
                SELECT MaterialId, Title, Description, MaterialType, CreatedAt,
                       FileName, FilePath, FileType, FileSizeKB
                FROM CourseMaterials
                WHERE CourseId = @CourseId AND Session = @Session
                ORDER BY CreatedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@CourseId", Convert.ToInt32(GetCourseIdParam())),
                new SqlParameter("@Session", GetSessionParam())
            });

            if (dt != null && dt.Rows.Count > 0)
            {
                rptMaterials.DataSource = dt;
                rptMaterials.DataBind();

                rptMaterials.Visible = true;
                pnlNoMaterials.Visible = false;
            }
            else
            {
                rptMaterials.Visible = false;
                pnlNoMaterials.Visible = true;
            }
        }

        protected void rptMaterials_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
                return;

            Repeater rptFiles = (Repeater)e.Item.FindControl("rptFiles");
            HiddenField hfMaterialId = (HiddenField)e.Item.FindControl("hfMaterialId");
            HiddenField hfLegacyFileName = (HiddenField)e.Item.FindControl("hfLegacyFileName");
            HiddenField hfLegacyFilePath = (HiddenField)e.Item.FindControl("hfLegacyFilePath");
            HiddenField hfLegacyFileSize = (HiddenField)e.Item.FindControl("hfLegacyFileSize");

            if (rptFiles == null || hfMaterialId == null)
                return;

            string sqlFiles = @"
                SELECT FileId, FileName, FilePath, FileType, FileSizeKB
                FROM CourseMaterialFiles
                WHERE MaterialId = @MaterialId
                ORDER BY UploadedAt ASC";

            DataTable dtFiles = DatabaseHelper.ExecuteQuery(sqlFiles, new[]
            {
                new SqlParameter("@MaterialId", Convert.ToInt32(hfMaterialId.Value))
            });

            if (dtFiles != null && dtFiles.Rows.Count > 0)
            {
                rptFiles.DataSource = dtFiles;
                rptFiles.DataBind();
            }
            else if (hfLegacyFilePath != null && !string.IsNullOrEmpty(hfLegacyFilePath.Value))
            {
                DataTable dtFallback = new DataTable();
                dtFallback.Columns.Add("FileId");
                dtFallback.Columns.Add("FileName");
                dtFallback.Columns.Add("FilePath");
                dtFallback.Columns.Add("FileSizeKB");

                DataRow dr = dtFallback.NewRow();
                dr["FileId"] = "";
                dr["FileName"] = hfLegacyFileName == null ? "" : hfLegacyFileName.Value;
                dr["FilePath"] = hfLegacyFilePath.Value;
                dr["FileSizeKB"] = hfLegacyFileSize != null && !string.IsNullOrEmpty(hfLegacyFileSize.Value)
                    ? hfLegacyFileSize.Value
                    : "0";

                dtFallback.Rows.Add(dr);

                rptFiles.DataSource = dtFallback;
                rptFiles.DataBind();
            }
        }

        protected string GetDownloadUrl(object fileId, object filePath)
        {
            string id = Convert.ToString(fileId);

            if (!string.IsNullOrWhiteSpace(id))
                return "DownloadCourseMaterial.aspx?fileId=" + Server.UrlEncode(id);

            string path = Convert.ToString(filePath);
            return string.IsNullOrWhiteSpace(path) ? "#" : ResolveUrl(path);
        }

        protected void btnModulesTab_Click(object sender, EventArgs e)
        {
            pnlModulesSection.Visible = true;
            pnlGradesSection.Visible = false;

            btnModulesTab.CssClass = "tab-btn active";
            btnGradesTab.CssClass = "tab-btn";
        }

        protected void btnGradesTab_Click(object sender, EventArgs e)
        {
            pnlModulesSection.Visible = false;
            pnlGradesSection.Visible = true;

            btnModulesTab.CssClass = "tab-btn";
            btnGradesTab.CssClass = "tab-btn active";

            LoadStudentGrades();
        }

        private void LoadStudentGrades()
        {
            string courseId = GetCourseIdParam();
            string session = GetSessionParam();
            string studentId = CurrentStudentId;

            string sql = @"
                SELECT
                    COALESCE(NULLIF(g.Title, ''), cm.Title, g.Type) AS Assessment,
                    g.Type,
                    COALESCE(g.MarksObtained, g.DraftMarksObtained) AS Marks,
                    g.MaxMarks,
                    g.WeightPercentage
                FROM Grades g
                LEFT JOIN CourseMaterials cm
                    ON cm.CourseId = g.CourseId
                   AND cm.MaterialId = g.MaterialId
                   AND cm.Session = @Session
                WHERE g.StudentId = @StudentId
                  AND g.CourseId = @CourseId
                ORDER BY ISNULL(cm.CreatedAt, g.SubmittedAt) ASC, g.Type ASC";

            DataTable grades = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session)
            });

            if (grades == null || grades.Rows.Count == 0)
            {
                pnlNoGrades.Visible = true;
                gvStudentGrades.Visible = false;
                return;
            }

            DataTable table = new DataTable();
            table.Columns.Add("Assessment");
            table.Columns.Add("Type");
            table.Columns.Add("Marks");
            table.Columns.Add("Max Marks");
            table.Columns.Add("Weight");
            table.Columns.Add("Final Mark");

            decimal totalFinalMark = 0m;
            bool hasFinalMark = false;

            foreach (DataRow gradeRow in grades.Rows)
            {
                decimal? finalMark = CalculateWeightedFinalMark(
                    gradeRow["Marks"],
                    gradeRow["MaxMarks"],
                    gradeRow["WeightPercentage"]);

                DataRow row = table.NewRow();
                row["Assessment"] = gradeRow["Assessment"].ToString();
                row["Type"] = gradeRow["Type"].ToString();
                row["Marks"] = FormatGradeValue(gradeRow["Marks"]);
                row["Max Marks"] = FormatGradeValue(gradeRow["MaxMarks"]);
                row["Weight"] = FormatWeight(gradeRow["WeightPercentage"]);
                row["Final Mark"] = FormatFinalMark(finalMark);
                table.Rows.Add(row);

                if (finalMark.HasValue)
                {
                    totalFinalMark += finalMark.Value;
                    hasFinalMark = true;
                }
            }

            DataRow finalRow = table.NewRow();
            finalRow["Assessment"] = "Final Mark";
            finalRow["Type"] = "";
            finalRow["Marks"] = "";
            finalRow["Max Marks"] = "";
            finalRow["Weight"] = "";
            finalRow["Final Mark"] = hasFinalMark ? totalFinalMark.ToString("0.##") + "%" : "-";
            table.Rows.Add(finalRow);

            gvStudentGrades.DataSource = table;
            gvStudentGrades.DataBind();

            gvStudentGrades.Visible = true;
            pnlNoGrades.Visible = false;
        }

        private string FormatGradeValue(object value)
        {
            if (value == null || value == DBNull.Value)
                return "-";

            return Convert.ToDecimal(value).ToString("0.##");
        }

        private string FormatWeight(object value)
        {
            if (value == null || value == DBNull.Value)
                return "-";

            return Convert.ToDecimal(value).ToString("0.##") + "%";
        }

        private decimal? CalculateWeightedFinalMark(object marks, object maxMarks, object weight)
        {
            if (marks == null || marks == DBNull.Value ||
                maxMarks == null || maxMarks == DBNull.Value ||
                weight == null || weight == DBNull.Value)
                return null;

            decimal max = Convert.ToDecimal(maxMarks);
            if (max <= 0)
                return null;

            return Convert.ToDecimal(marks) / max * Convert.ToDecimal(weight);
        }

        private string FormatFinalMark(decimal? value)
        {
            return value.HasValue ? value.Value.ToString("0.##") + "%" : "-";
        }

        protected void gvStudentGrades_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow || e.Row.Cells.Count == 0)
                return;

            if (e.Row.Cells[0].Text != "Final Mark")
                return;

            e.Row.Font.Bold = true;
            e.Row.Style["background"] = "#fff8e1";

            foreach (TableCell cell in e.Row.Cells)
            {
                cell.Style["border-top"] = "2px solid #e8a838";
            }
        }

        private void CheckUnreadNotifications()
        {
            int userId = SessionHelper.GetUserId(Session);

            object count = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @Uid AND IsRead = 0",
                new[] { new SqlParameter("@Uid", userId) });

            pnlNotifBadge.Visible = count != null && count != DBNull.Value && Convert.ToInt32(count) > 0;
        }
    }
}