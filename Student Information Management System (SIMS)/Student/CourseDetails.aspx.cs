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
            // Restrict page entry to logged-in students
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                // Validate incoming parameters gracefully
                if (string.IsNullOrEmpty(GetCourseIdParam()) || string.IsNullOrEmpty(GetSessionParam()))
                {
                    Response.Redirect("MyCourses.aspx");
                    return;
                }

                LoadSidebarUserInfo();
                LoadCourseHeader();
                LoadCourseMaterials();
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
            }
        }

        // Case-Insensitive evaluation of parameter inputs from query strings
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
            get { return Session["StudentId"]?.ToString() ?? ""; }
        }

        private void LoadCourseHeader()
        {
            // Join query pulls both base course traits and assigned lecturers
            string sql = @"
                SELECT c.CourseCode, c.CourseName, c.Credits, c.Description,
                       (ld.FirstName + ' ' + ld.LastName) AS FullName
                FROM Courses c
                LEFT JOIN LecturerCourse lc ON c.CourseId = lc.CourseId AND lc.Session = @Session
                LEFT JOIN LecturerDetails ld ON lc.LecturerId = ld.LecturerId
                WHERE c.CourseId = @CourseId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] {
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
                {
                    lblLecturerName.Text = Server.HtmlEncode(row["FullName"].ToString());
                }
            }
            else
            {
                Response.Redirect("MyCourses.aspx");
            }
        }

        private void LoadCourseMaterials()
        {
            // Fetch everything relating to the module code target
            string sql = @"
                SELECT MaterialId, Title, Description, MaterialType, CreatedAt,
                       FileName, FilePath, FileType, FileSizeKB
                FROM CourseMaterials
                WHERE CourseId = @CourseId AND Session = @Session
                ORDER BY CreatedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] {
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
                pnlNoMaterials.Visible = true; // Displays placeholder message
            }
        }

        protected void rptMaterials_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                Repeater rptFiles = (Repeater)e.Item.FindControl("rptFiles");
            CRITICAL: HiddenField hfMaterialId = (HiddenField)e.Item.FindControl("hfMaterialId");

                // Legacy Column References
                HiddenField hfLegacyFileName = (HiddenField)e.Item.FindControl("hfLegacyFileName");
                HiddenField hfLegacyFilePath = (HiddenField)e.Item.FindControl("hfLegacyFilePath");
                HiddenField hfLegacyFileSize = (HiddenField)e.Item.FindControl("hfLegacyFileSize");

                if (rptFiles != null && hfMaterialId != null)
                {
                    // Check modern structural table CourseMaterialFiles
                    string sqlFiles = @"
                        SELECT FileName, FilePath, FileType, FileSizeKB 
                        FROM CourseMaterialFiles 
                        WHERE MaterialId = @MaterialId 
                        ORDER BY UploadedAt ASC";

                    DataTable dtFiles = DatabaseHelper.ExecuteQuery(sqlFiles, new[] {
                        new SqlParameter("@MaterialId", Convert.ToInt32(hfMaterialId.Value))
                    });

                    if (dtFiles != null && dtFiles.Rows.Count > 0)
                    {
                        rptFiles.DataSource = dtFiles;
                        rptFiles.DataBind();
                    }
                    else if (!string.IsNullOrEmpty(hfLegacyFilePath.Value))
                    {
                        // Fallback fallback: Check if old schema columns contain file entries
                        DataTable dtFallback = new DataTable();
                        dtFallback.Columns.Add("FileName");
                        dtFallback.Columns.Add("FilePath");
                        dtFallback.Columns.Add("FileSizeKB");

                        DataRow dr = dtFallback.NewRow();
                        dr["FileName"] = hfLegacyFileName.Value;
                        dr["FilePath"] = hfLegacyFilePath.Value;
                        dr["FileSizeKB"] = !string.IsNullOrEmpty(hfLegacyFileSize.Value) ? hfLegacyFileSize.Value : "0";
                        dtFallback.Rows.Add(dr);

                        rptFiles.DataSource = dtFallback;
                        rptFiles.DataBind();
                    }
                }
            }
        }

        // Click handler actions for Tab selection layout changes
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

            string assignmentSql = @"
                SELECT MaterialId, Title, MaterialType FROM CourseMaterials
                WHERE CourseId = @CourseId AND Session = @Session AND MaterialType IN ('Assignment', 'Final Exam')
                ORDER BY CreatedAt ASC";

            DataTable assignments = DatabaseHelper.ExecuteQuery(assignmentSql, new[] {
                new SqlParameter("@CourseId", courseId), new SqlParameter("@Session", session)
            });

            if (assignments == null || assignments.Rows.Count == 0)
            {
                pnlNoGrades.Visible = true;
                gvStudentGrades.Visible = false;
                return;
            }

            DataTable table = new DataTable();
            table.Columns.Add("Student ID");
            table.Columns.Add("Student Name");

            foreach (DataRow a in assignments.Rows)
            {
                table.Columns.Add(a["Title"].ToString());
            }

            DataRow row = table.NewRow();
            row["Student ID"] = studentId;
            row["Student Name"] = Session["StudentName"]?.ToString() ?? "Student";

            bool marksExist = false;

            foreach (DataRow a in assignments.Rows)
            {
                string gradeType = (a["MaterialType"].ToString() == "Final Exam") ? "Exam" : "Assignment";

                object mark = DatabaseHelper.ExecuteScalar(@"
                    SELECT MarksObtained FROM Grades
                    WHERE StudentId = @StudentId AND CourseId = @CourseId AND Type = @Type AND MaterialId = @MaterialId",
                    new[] {
                        new SqlParameter("@StudentId", studentId),
                        new SqlParameter("@CourseId", courseId),
                        new SqlParameter("@Type", gradeType),
                        new SqlParameter("@MaterialId", a["MaterialId"])
                    });

                if (mark != null && mark != DBNull.Value)
                {
                    row[a["Title"].ToString()] = mark.ToString();
                    marksExist = true;
                }
                else
                {
                    row[a["Title"].ToString()] = "-";
                }
            }

            if (marksExist)
            {
                table.Rows.Add(row);
                gvStudentGrades.DataSource = table;
                gvStudentGrades.DataBind();
                gvStudentGrades.Visible = true;
                pnlNoGrades.Visible = false;
            }
            else
            {
                pnlNoGrades.Visible = true;
                gvStudentGrades.Visible = false;
            }
        }

        private void LoadSidebarUserInfo()
        {
            // Get student info from session
            string studentId = Session["StudentId"]?.ToString();
            string studentName = Session["StudentName"]?.ToString();

            if (!string.IsNullOrEmpty(studentName))
            {
                lblSidebarName.Text = Server.HtmlEncode(studentName);
                lblAvatarInitial.Text = studentName.Substring(0, 1).ToUpper();
            }
        }

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx");
        }
    }
}