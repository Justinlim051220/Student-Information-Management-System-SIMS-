using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;
using System.Linq;

namespace Student_Information_Management_System__SIMS_.Lecturer
{
    public partial class CourseStudents : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireLecturer(Session, Response);

            if (!IsPostBack)
            {
                LoadLecturerInfo();
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadStudents();
                CheckUnreadNotifications();
                ShowStudentsSection();
            }
        }
        protected void Page_Init(object sender, EventArgs e)
        {
            bool gradePostBack =
                IsPostBack &&
                (Request.Form[btnSaveGrades.UniqueID] != null ||
                 Request.Form[btnPublishGrades.UniqueID] != null);

            if (gradePostBack)
            {
                EnsureGradeRecords();
                LoadGrades(true);
            }
        }

        private int CurrentUserId
        {
            get { return SessionHelper.GetUserId(Session); }
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
                    new[] { new SqlParameter("@UserId", CurrentUserId) });

                return result == null ? "" : result.ToString();
            }
        }

        private void LoadLecturerInfo()
        {
            string fullName = SessionHelper.GetFullName(Session);

            lblSidebarName.Text = string.IsNullOrWhiteSpace(fullName)
                ? "Lecturer"
                : fullName;

            LoadSidebarProfilePicture();
        }

        private void LoadSidebarProfilePicture()
        {
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT ProfilePicture FROM LecturerDetails WHERE UserId = @UserId",
                new[]
                {
                    new SqlParameter("@UserId", CurrentUserId)
                });

            string picture = result == null || result == DBNull.Value
                ? ""
                : result.ToString();

            if (!string.IsNullOrWhiteSpace(picture))
            {
                imgSidebarAvatar.ImageUrl = picture;
            }
            else
            {
                imgSidebarAvatar.ImageUrl = "~/ProfilePicture/default-profile.png";
            }
        }

        private void LoadStudents()
        {
            string courseId = Request.QueryString["courseId"];
            string session = Request.QueryString["session"];

            if (string.IsNullOrWhiteSpace(courseId) || string.IsNullOrWhiteSpace(session))
            {
                Response.Redirect("MyCourses.aspx", false);
                return;
            }

            string verifySql = @"
                SELECT COUNT(*)
                FROM LecturerCourse
                WHERE LecturerId = @LecturerId
                  AND CourseId = @CourseId
                  AND Session = @Session";

            int allowed = Convert.ToInt32(DatabaseHelper.ExecuteScalar(verifySql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session)
            }));

            if (allowed == 0)
            {
                Response.Redirect("MyCourses.aspx", false);
                return;
            }

            string infoSql = @"
                SELECT CourseCode, CourseName
                FROM Courses
                WHERE CourseId = @CourseId";

            DataTable infoDt = DatabaseHelper.ExecuteQuery(infoSql, new[]
            {
                new SqlParameter("@CourseId", courseId)
            });

            if (infoDt.Rows.Count > 0)
            {
                lblCourseTitle.Text =
                    infoDt.Rows[0]["CourseCode"] + " - " +
                    infoDt.Rows[0]["CourseName"];

                lblCourseInfo.Text = "Session: " + session;
            }
            else
            {
                Response.Redirect("MyCourses.aspx", false);
                return;
            }

            string sql = @"
                SELECT
                    sd.StudentId,
                    sd.FirstName + ' ' + sd.LastName AS StudentName
                FROM Enrollment e
                INNER JOIN StudentDetails sd
                    ON e.StudentId = sd.StudentId
                WHERE e.CourseId = @CourseId
                  AND e.Session = @Session
                  AND e.Status = 'Active'
                ORDER BY sd.StudentId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session)
            });

            rptStudents.DataSource = dt;
            rptStudents.DataBind();

            lblTotal.Text = dt.Rows.Count.ToString();
            pnlEmpty.Visible = dt.Rows.Count == 0;
        }

        private void LoadMaterials()
        {
            string courseId = Request.QueryString["courseId"];
            string session = Request.QueryString["session"];

            string sql = @"
                SELECT 
                    MaterialId,
                    Title,
                    Description,
                    MaterialType,
                    CreatedAt
                FROM CourseMaterials
                WHERE CourseId = @CourseId
                  AND Session = @Session
                  AND LecturerId = @LecturerId
                ORDER BY CreatedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session),
                new SqlParameter("@LecturerId", CurrentLecturerId)
            });

            rptMaterials.DataSource = dt;
            rptMaterials.DataBind();

            lblMaterialTotal.Text = dt.Rows.Count.ToString();
            pnlNoMaterials.Visible = dt.Rows.Count == 0;
        }
        private void LoadGrades(bool editMode)
        {
            string courseId = Request.QueryString["courseId"];
            string session = Request.QueryString["session"];

            bool published = GradesAlreadyPublished();
            bool hasUnpublishedChanges = HasUnpublishedGradeChanges();
            IsGradeEditMode = !published || editMode;
            bool showDraftMarks = IsGradeEditMode || hasUnpublishedChanges;

            string assignmentSql = @"
        SELECT MaterialId, Title, MaterialType
        FROM CourseMaterials
        WHERE CourseId = @CourseId
          AND Session = @Session
          AND LecturerId = @LecturerId
          AND MaterialType IN ('Assignment', 'Final Exam')
        ORDER BY CreatedAt ASC";

            DataTable assignments = DatabaseHelper.ExecuteQuery(assignmentSql, new[]
            {
        new SqlParameter("@CourseId", courseId),
        new SqlParameter("@Session", session),
        new SqlParameter("@LecturerId", CurrentLecturerId)
    });

            AssignmentMaterials = assignments;

            string studentSql = @"
        SELECT 
            sd.StudentId,
            sd.FirstName + ' ' + sd.LastName AS StudentName
        FROM Enrollment e
        INNER JOIN StudentDetails sd ON e.StudentId = sd.StudentId
        WHERE e.CourseId = @CourseId
          AND e.Session = @Session
          AND e.Status = 'Active'
        ORDER BY sd.StudentId";

            DataTable students = DatabaseHelper.ExecuteQuery(studentSql, new[]
            {
        new SqlParameter("@CourseId", courseId),
        new SqlParameter("@Session", session)
    });

            DataTable table = new DataTable();
            table.Columns.Add("No");
            table.Columns.Add("Student ID");
            table.Columns.Add("Student Name");

            foreach (DataRow a in assignments.Rows)
            {
                table.Columns.Add(a["Title"].ToString());
            }

            table.Columns.Add("GPA");

            int no = 1;

            foreach (DataRow s in students.Rows)
            {
                DataRow row = table.NewRow();
                string studentId = s["StudentId"].ToString();

                row["No"] = no++;
                row["Student ID"] = studentId;
                row["Student Name"] = s["StudentName"].ToString();

                foreach (DataRow a in assignments.Rows)
                {
                    string gradeType = GetGradeTypeForMaterial(a["MaterialType"].ToString());
                    object mark = DatabaseHelper.ExecuteScalar(@"
                SELECT " + (showDraftMarks ? "COALESCE(DraftMarksObtained, MarksObtained)" : "MarksObtained") + @"
                FROM Grades
                WHERE StudentId = @StudentId
                  AND CourseId = @CourseId
                  AND Type = @Type
                  AND MaterialId = @MaterialId",
                        new[]
                        {
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Type", gradeType),
                    new SqlParameter("@MaterialId", a["MaterialId"])
                        });

                    row[a["Title"].ToString()] = mark == null || mark == DBNull.Value ? "" : mark.ToString();
                }

                row["GPA"] = CalculateStudentGpa(studentId, courseId, showDraftMarks);

                table.Rows.Add(row);
            }

            gvGrades.DataSource = table;
            gvGrades.DataBind();

            lblGradeTotal.Text = students.Rows.Count.ToString();
            pnlNoGrades.Visible = students.Rows.Count == 0;

            SetGradePublishStatus(published, editMode, hasUnpublishedChanges);

            btnEditGrades.Visible = published && !editMode && !hasUnpublishedChanges;
            btnSaveGrades.Visible = !published || editMode || hasUnpublishedChanges;
            btnSaveGrades.Text = GradesHaveDraftMarks() || GradesHavePublishedMarks() ? "Update Marks" : "Save Marks";
            btnPublishGrades.Visible = (!published || editMode || hasUnpublishedChanges) && students.Rows.Count > 0;
        }
        private void SetGradePublishStatus(bool published, bool editMode, bool hasUnpublishedChanges)
        {
            if (published && !editMode && !hasUnpublishedChanges)
            {
                lblGradePublishStatus.Text = "Published";
                lblGradePublishStatus.CssClass = "grade-status published";
                return;
            }

            if (published && editMode)
            {
                lblGradePublishStatus.Text = "Not Published - Editing";
            }
            else if (hasUnpublishedChanges)
            {
                lblGradePublishStatus.Text = "Not Published - Draft Saved";
            }
            else
            {
                lblGradePublishStatus.Text = GradesHaveDraftMarks()
                ? "Not Published - Draft Saved"
                : "Not Published";
            }

            lblGradePublishStatus.CssClass = "grade-status unpublished";
        }

        protected void rptMaterials_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            DataRowView row = e.Item.DataItem as DataRowView;
            if (row == null)
                return;

            int materialId = Convert.ToInt32(row["MaterialId"]);

            Repeater rptMaterialFiles = e.Item.FindControl("rptMaterialFiles") as Repeater;
            if (rptMaterialFiles == null)
                return;

            string sql = @"
                SELECT FileId, FileName, FilePath, UploadedAt
                FROM CourseMaterialFiles
                WHERE MaterialId = @MaterialId
                ORDER BY UploadedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@MaterialId", materialId)
            });

            rptMaterialFiles.DataSource = dt;
            rptMaterialFiles.DataBind();
        }

        private void EnsureGradeRecords()
        {
            string courseId = Request.QueryString["courseId"];
            string session = Request.QueryString["session"];

            // Create grade records for posted Assignment and Final Exam materials
            string assignmentSql = @"
                INSERT INTO Grades
                (
                    StudentId,
                    CourseId,
                    MaterialId,
                    Type,
                    Title,
                    MaxMarks,
                    MarksObtained,
                    WeightPercentage,
                    Grade,
                    SubmittedAt
                )
                SELECT
                    e.StudentId,
                    e.CourseId,
                    cm.MaterialId,
                    CASE WHEN cm.MaterialType = 'Final Exam' THEN 'Exam' ELSE 'Assignment' END,
                    cm.Title,
                    100,
                    NULL,
                    NULL,
                    NULL,
                    NULL
                FROM Enrollment e
                CROSS JOIN CourseMaterials cm
                WHERE e.CourseId = @CourseId
                  AND e.Session = @Session
                  AND e.Status = 'Active'
                  AND cm.CourseId = @CourseId
                  AND cm.Session = @Session
                  AND cm.LecturerId = @LecturerId
                  AND cm.MaterialType IN ('Assignment', 'Final Exam')
                  AND NOT EXISTS
                  (
                      SELECT 1
                      FROM Grades g
                      WHERE g.StudentId = e.StudentId
                        AND g.CourseId = e.CourseId
                        AND g.MaterialId = cm.MaterialId
                        AND g.Type = CASE WHEN cm.MaterialType = 'Final Exam' THEN 'Exam' ELSE 'Assignment' END
                  )";

            DatabaseHelper.ExecuteNonQuery(
                assignmentSql,
                new[]
                {
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@LecturerId", CurrentLecturerId)
                });
        }

        private void EnsureDefaultAssignmentColumn(string courseId, string session)
        {
            object count = DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(*)
                FROM CourseMaterials
                WHERE CourseId = @CourseId
                  AND Session = @Session
                  AND LecturerId = @LecturerId
                  AND MaterialType = 'Assignment'",
                new[]
                {
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@LecturerId", CurrentLecturerId)
                });

            if (Convert.ToInt32(count) > 0)
                return;

            DatabaseHelper.ExecuteNonQuery(@"
                INSERT INTO CourseMaterials
                (
                    CourseId,
                    Session,
                    LecturerId,
                    Title,
                    Description,
                    MaterialType
                )
                VALUES
                (
                    @CourseId,
                    @Session,
                    @LecturerId,
                    'Assignment 1',
                    'Default grade column',
                    'Assignment'
                )",
                new[]
                {
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@LecturerId", CurrentLecturerId)
                });
        }

        private bool GradesAlreadyPublished()
        {
            string courseId = Request.QueryString["courseId"];
            string session = Request.QueryString["session"];

            object count = DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(*)
                FROM Grades g
                INNER JOIN Enrollment e
                    ON e.StudentId = g.StudentId
                   AND e.CourseId = g.CourseId
                WHERE g.CourseId = @CourseId
                  AND e.Session = @Session
                  AND e.Status = 'Active'
                  AND g.SubmittedAt IS NOT NULL",
                new[]
                {
            new SqlParameter("@CourseId", courseId),
            new SqlParameter("@Session", session)
                });

            return Convert.ToInt32(count) > 0;
        }

        private bool GradesHavePublishedMarks()
        {
            string courseId = Request.QueryString["courseId"];
            string session = Request.QueryString["session"];

            object count = DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(*)
                FROM Grades g
                INNER JOIN Enrollment e
                    ON e.StudentId = g.StudentId
                   AND e.CourseId = g.CourseId
                WHERE g.CourseId = @CourseId
                  AND e.Session = @Session
                  AND e.Status = 'Active'
                  AND g.MarksObtained IS NOT NULL",
                new[]
                {
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session)
                });

            return Convert.ToInt32(count) > 0;
        }

        private bool GradesHaveDraftMarks()
        {
            string courseId = Request.QueryString["courseId"];
            string session = Request.QueryString["session"];

            object count = DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(*)
                FROM Grades g
                INNER JOIN Enrollment e
                    ON e.StudentId = g.StudentId
                   AND e.CourseId = g.CourseId
                WHERE g.CourseId = @CourseId
                  AND e.Session = @Session
                  AND e.Status = 'Active'
                  AND g.DraftMarksObtained IS NOT NULL",
                new[]
                {
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session)
                });

            return Convert.ToInt32(count) > 0;
        }
        protected void lbShowStudents_Click(object sender, EventArgs e)
        {
            ShowStudentsSection();
        }

        protected void lbPostMaterial_Click(object sender, EventArgs e)
        {
            ShowMaterialsSection();
        }

        protected void lbGrades_Click(object sender, EventArgs e)
        {
            ShowGradesSection(false);
        }

        private void ShowStudentsSection()
        {
            pnlStudentsSection.Visible = true;
            pnlMaterialsSection.Visible = false;
            pnlGradesSection.Visible = false;

            lbShowStudents.CssClass = "course-action-btn active";
            lbPostMaterial.CssClass = "course-action-btn";
            lbGrades.CssClass = "course-action-btn";

            lblTopbarTitle.Text = "Registered Students";
        }

        private void ShowMaterialsSection()
        {
            pnlStudentsSection.Visible = false;
            pnlMaterialsSection.Visible = true;
            pnlGradesSection.Visible = false;

            lbShowStudents.CssClass = "course-action-btn";
            lbPostMaterial.CssClass = "course-action-btn active";
            lbGrades.CssClass = "course-action-btn";

            lblTopbarTitle.Text = "Post Material";

            LoadMaterials();
        }

        private void ShowGradesSection(bool editMode)
        {
            pnlStudentsSection.Visible = false;
            pnlMaterialsSection.Visible = false;
            pnlGradesSection.Visible = true;

            lbShowStudents.CssClass = "course-action-btn";
            lbPostMaterial.CssClass = "course-action-btn";
            lbGrades.CssClass = "course-action-btn active";

            lblTopbarTitle.Text = "Grades";

            LoadAssignmentMaterialInfo();
            EnsureGradeRecords();
            LoadGrades(editMode);
        }

        protected void lbBackToCourses_Click(object sender, EventArgs e)
        {
            Response.Redirect("MyCourses.aspx");
        }

        protected void btnUploadMaterial_Click(object sender, EventArgs e)
        {
            string courseId = Request.QueryString["courseId"];
            string session = Request.QueryString["session"];
            int editId = Convert.ToInt32(hfEditMaterialId.Value);

            if (string.IsNullOrWhiteSpace(txtMaterialTitle.Text))
            {
                ShowMessage("Please enter material title.", "danger");
                ShowMaterialsSection();
                return;
            }

            if (string.IsNullOrWhiteSpace(ddlMaterialType.SelectedValue))
            {
                ShowMessage("Please select material type.", "danger");
                ShowMaterialsSection();
                return;
            }
            if (editId == 0)
            {
                string insertSql = @"
                    INSERT INTO CourseMaterials
                    (
                        CourseId,
                        Session,
                        LecturerId,
                        Title,
                        Description,
                        MaterialType
                    )
                    OUTPUT INSERTED.MaterialId
                    VALUES
                    (
                        @CourseId,
                        @Session,
                        @LecturerId,
                        @Title,
                        @Description,
                        @MaterialType
                    )";

                int materialId = Convert.ToInt32(DatabaseHelper.ExecuteScalar(insertSql, new[]
                {
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@LecturerId", CurrentLecturerId),
                    new SqlParameter("@Title", txtMaterialTitle.Text.Trim()),
                    new SqlParameter("@Description", txtMaterialDescription.Text.Trim()),
                    new SqlParameter("@MaterialType", ddlMaterialType.SelectedValue)
                }));

                SaveMaterialFiles(materialId, courseId, session);

                ShowMessage("Course material posted successfully.", "success");
            }
            else
            {
                string updateSql = @"
                    UPDATE CourseMaterials
                    SET Title = @Title,
                        Description = @Description,
                        MaterialType = @MaterialType
                    WHERE MaterialId = @MaterialId
                      AND LecturerId = @LecturerId";

                DatabaseHelper.ExecuteNonQuery(updateSql, new[]
                {
                    new SqlParameter("@Title", txtMaterialTitle.Text.Trim()),
                    new SqlParameter("@Description", txtMaterialDescription.Text.Trim()),
                    new SqlParameter("@MaterialType", ddlMaterialType.SelectedValue),
                    new SqlParameter("@MaterialId", editId),
                    new SqlParameter("@LecturerId", CurrentLecturerId)
                });

                if (fuMaterial.HasFiles)
                {
                    SaveMaterialFiles(editId, courseId, session);
                }

                ShowMessage("Course material updated successfully.", "success");
            }

            ClearMaterialForm();
            ShowMaterialsSection();
        }

        private void SaveMaterialFiles(int materialId, string courseId, string session)
        {
            if (!fuMaterial.HasFiles)
                return;

            string rootFolder = Server.MapPath("~/CourseMaterials/");
            string safeSession = session.Replace(" ", "_").Replace("/", "_").Replace("\\", "_");
            string courseFolder = Path.Combine(rootFolder, courseId + "_" + safeSession);

            if (!Directory.Exists(courseFolder))
            {
                Directory.CreateDirectory(courseFolder);
            }

            foreach (HttpPostedFile file in fuMaterial.PostedFiles)
            {
                if (file == null || file.ContentLength <= 0)
                    continue;

                string originalFileName = Path.GetFileName(file.FileName);
                string extension = Path.GetExtension(originalFileName);
                string savedFileName = Guid.NewGuid().ToString("N") + extension;
                string fullPath = Path.Combine(courseFolder, savedFileName);

                file.SaveAs(fullPath);

                string dbFilePath = "~/CourseMaterials/" + courseId + "_" + safeSession + "/" + savedFileName;

                string insertFileSql = @"
                    INSERT INTO CourseMaterialFiles
                    (
                        MaterialId,
                        FileName,
                        FilePath,
                        FileType,
                        FileSizeKB
                    )
                    VALUES
                    (
                        @MaterialId,
                        @FileName,
                        @FilePath,
                        @FileType,
                        @FileSizeKB
                    )";

                DatabaseHelper.ExecuteNonQuery(insertFileSql, new[]
                {
                    new SqlParameter("@MaterialId", materialId),
                    new SqlParameter("@FileName", originalFileName),
                    new SqlParameter("@FilePath", dbFilePath),
                    new SqlParameter("@FileType", file.ContentType),
                    new SqlParameter("@FileSizeKB", file.ContentLength / 1024)
                });
            }
        }

        protected void rptMaterials_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int materialId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditMaterial")
            {
                LoadMaterialForEdit(materialId);
            }
        }

        private void LoadMaterialForEdit(int materialId)
        {
            string sql = @"
                SELECT MaterialId, Title, Description, MaterialType
                FROM CourseMaterials
                WHERE MaterialId = @MaterialId
                  AND LecturerId = @LecturerId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@MaterialId", materialId),
                new SqlParameter("@LecturerId", CurrentLecturerId)
            });

            if (dt.Rows.Count > 0)
            {
                hfEditMaterialId.Value = dt.Rows[0]["MaterialId"].ToString();
                txtMaterialTitle.Text = dt.Rows[0]["Title"].ToString();
                txtMaterialDescription.Text = dt.Rows[0]["Description"].ToString();

                string materialType = dt.Rows[0]["MaterialType"].ToString();

                if (ddlMaterialType.Items.FindByValue(materialType) != null)
                {
                    ddlMaterialType.SelectedValue = materialType;
                }
                else
                {
                    ddlMaterialType.SelectedIndex = 0;
                }

                btnUploadMaterial.Text = "Update Material";
                btnCancelEditMaterial.Visible = true;

                LoadExistingMaterialFiles(materialId);
                pnlExistingFiles.Visible = true;

                ShowMessage("You are now editing this course material. You can keep existing files, delete selected files, or upload more files.", "warning");
            }

            ShowMaterialsSection();
            LoadExistingMaterialFiles(materialId);
            pnlExistingFiles.Visible = true;
        }

        private void LoadExistingMaterialFiles(int materialId)
        {
            string sql = @"
                SELECT FileId, FileName, FilePath, UploadedAt
                FROM CourseMaterialFiles
                WHERE MaterialId = @MaterialId
                ORDER BY UploadedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@MaterialId", materialId)
            });

            rptExistingFiles.DataSource = dt;
            rptExistingFiles.DataBind();

            pnlExistingFiles.Visible = dt.Rows.Count > 0;
        }

        protected void btnDeleteMaterialConfirmed_Click(object sender, EventArgs e)
        {
            int materialId;

            if (int.TryParse(hfDeleteMaterialId.Value, out materialId))
            {
                DeleteMaterial(materialId);
            }
            else
            {
                ShowMessage("Invalid material selected.", "danger");
            }
        }

        private void DeleteMaterial(int materialId)
        {
            DeleteAllMaterialFiles(materialId);

            string deleteSql = @"
                DELETE FROM CourseMaterials
                WHERE MaterialId = @MaterialId
                  AND LecturerId = @LecturerId";

            DatabaseHelper.ExecuteNonQuery(deleteSql, new[]
            {
                new SqlParameter("@MaterialId", materialId),
                new SqlParameter("@LecturerId", CurrentLecturerId)
            });

            ClearMaterialForm();
            ShowMessage("Course material deleted successfully.", "success");
            ShowMaterialsSection();
        }

        private void DeleteAllMaterialFiles(int materialId)
        {
            string getFilesSql = @"
                SELECT FilePath
                FROM CourseMaterialFiles
                WHERE MaterialId = @MaterialId";

            DataTable dt = DatabaseHelper.ExecuteQuery(getFilesSql, new[]
            {
                new SqlParameter("@MaterialId", materialId)
            });

            foreach (DataRow row in dt.Rows)
            {
                string filePath = row["FilePath"].ToString();

                if (!string.IsNullOrWhiteSpace(filePath))
                {
                    string physicalPath = Server.MapPath(filePath);

                    if (File.Exists(physicalPath))
                    {
                        File.Delete(physicalPath);
                    }
                }
            }

            string deleteFilesSql = @"
                DELETE FROM CourseMaterialFiles
                WHERE MaterialId = @MaterialId";

            DatabaseHelper.ExecuteNonQuery(deleteFilesSql, new[]
            {
                new SqlParameter("@MaterialId", materialId)
            });
        }

        protected void btnDeleteFileConfirmed_Click(object sender, EventArgs e)
        {
            int fileId;

            if (int.TryParse(hfDeleteFileId.Value, out fileId))
            {
                DeleteMaterialFile(fileId);

                int materialId;
                if (int.TryParse(hfEditMaterialId.Value, out materialId) && materialId > 0)
                {
                    LoadExistingMaterialFiles(materialId);
                    pnlExistingFiles.Visible = true;
                }

                ShowMessage("File deleted successfully.", "success");
                ShowMaterialsSection();

                if (materialId > 0)
                {
                    LoadExistingMaterialFiles(materialId);
                    pnlExistingFiles.Visible = true;
                }
            }
            else
            {
                ShowMessage("Invalid file selected.", "danger");
            }
        }

        private void DeleteMaterialFile(int fileId)
        {
            string getSql = @"
                SELECT FilePath
                FROM CourseMaterialFiles
                WHERE FileId = @FileId";

            object filePathObj = DatabaseHelper.ExecuteScalar(getSql, new[]
            {
                new SqlParameter("@FileId", fileId)
            });

            if (filePathObj != null && filePathObj != DBNull.Value)
            {
                string filePath = filePathObj.ToString();

                if (!string.IsNullOrWhiteSpace(filePath))
                {
                    string physicalPath = Server.MapPath(filePath);

                    if (File.Exists(physicalPath))
                    {
                        File.Delete(physicalPath);
                    }
                }
            }

            string deleteSql = @"
                DELETE FROM CourseMaterialFiles
                WHERE FileId = @FileId";

            DatabaseHelper.ExecuteNonQuery(deleteSql, new[]
            {
                new SqlParameter("@FileId", fileId)
            });
        }

        protected void btnCancelEditMaterial_Click(object sender, EventArgs e)
        {
            ClearMaterialForm();
            ShowMaterialsSection();
        }

        private void ClearMaterialForm()
        {
            hfEditMaterialId.Value = "0";
            hfDeleteMaterialId.Value = "0";
            hfDeleteFileId.Value = "0";

            txtMaterialTitle.Text = "";
            txtMaterialDescription.Text = "";

            if (ddlMaterialType.Items.Count > 0)
            {
                ddlMaterialType.SelectedIndex = 0;
            }

            btnUploadMaterial.Text = "Post Material";
            btnCancelEditMaterial.Visible = false;

            pnlExistingFiles.Visible = false;
            rptExistingFiles.DataSource = null;
            rptExistingFiles.DataBind();
        }

        protected void btnEditGrades_Click(object sender, EventArgs e)
        {
            ShowGradesSection(true);
            ShowMessage("You can now edit student marks.", "warning");
        }

        protected void gvGrades_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow)
                return;

            string studentId = e.Row.Cells[1].Text.Trim();
            int lastEditableCell = e.Row.Cells.Count - 2; // GPA is the final read-only column.

            for (int i = 3; i <= lastEditableCell; i++)
            {
                string value = e.Row.Cells[i].Text.Replace("&nbsp;", "").Trim();

                if (!IsGradeEditMode)
                {
                    e.Row.Cells[i].CssClass = "grade-readonly";
                    continue;
                }

                TextBox txt = new TextBox();
                txt.ID = "txt_" + studentId + "_" + i;
                txt.CssClass = "form-control";
                txt.Style["width"] = "100px";
                txt.Text = value;

                e.Row.Cells[i].Controls.Clear();
                e.Row.Cells[i].Controls.Add(txt);
            }

            e.Row.Cells[e.Row.Cells.Count - 1].CssClass = "grade-readonly";
        }
        protected void btnSaveGrades_Click(object sender, EventArgs e)
        {
            string courseId = Request.QueryString["courseId"];
            bool hadSavedMarks = GradesHaveDraftMarks() || GradesHavePublishedMarks();

            DataTable assignments = AssignmentMaterials;

            if (assignments == null)
            {
                ShowMessage("Grade data expired. Please click Grades again and try saving.", "danger");
                ShowGradesSection(true);
                return;
            }

            bool savedAnyMark = false;

            foreach (GridViewRow row in gvGrades.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow)
                    continue;

                string studentId = row.Cells[1].Text.Trim();

                int cellIndex = 3;

                if (assignments != null)
                {
                    foreach (DataRow a in assignments.Rows)
                    {
                        if (cellIndex >= row.Cells.Count)
                        {
                            ShowMessage("Grade column mismatch. Please refresh and try again.", "danger");
                            ShowGradesSection(true);
                            return;
                        }

                        if (row.Cells[cellIndex].Controls.Count == 0)
                        {
                            ShowMessage(
                                 "Column: " + cellIndex +
                                 " Controls: " + row.Cells[cellIndex].Controls.Count,
                                 "danger");
                            ShowGradesSection(true);
                            return;
                        }

                        string inputName = "txt_" + studentId + "_" + cellIndex;
                        string postedValue = Request.Form.AllKeys
                            .Where(k => k != null && k.EndsWith(inputName))
                            .Select(k => Request.Form[k])
                            .FirstOrDefault();

                        if (postedValue == null)
                        {
                            ShowMessage("Cannot find grade mark input.", "danger");
                            ShowGradesSection(true);
                            return;
                        }

                        postedValue = postedValue.Trim();
                        if (string.IsNullOrWhiteSpace(postedValue))
                        {
                            cellIndex++;
                            continue;
                        }

                        decimal mark;
                        if (!decimal.TryParse(postedValue, out mark) || mark < 0 || mark > 100)
                        {
                            ShowMessage("Marks must be between 0 and 100.", "danger");
                            ShowGradesSection(true);
                            return;
                        }

                        SaveDraftGrade(
                            studentId,
                            Convert.ToInt32(a["MaterialId"]),
                            GetGradeTypeForMaterial(a["MaterialType"].ToString()),
                            a["Title"].ToString(),
                            mark);

                        savedAnyMark = true;
                        cellIndex++;
                    }
                }
            }

            if (!savedAnyMark)
            {
                ShowMessage("Please enter at least one mark to save.", "danger");
                ShowGradesSection(true);
                return;
            }

            ShowGradesSection(false);

            ShowMessage(
                hadSavedMarks ? "Student grades updated successfully." : "Student grades saved successfully.",
                "success");
        }

        protected void btnPublishGrades_Click(object sender, EventArgs e)
        {
            string validationMessage;
            if (!SavePostedGrades(out validationMessage))
            {
                ShowMessage(validationMessage, "danger");
                ShowGradesSection(true);
                return;
            }

            string courseId = Request.QueryString["courseId"];
            string session = Request.QueryString["session"];

            if (!GradesHaveDraftMarks())
            {
                ShowMessage("Please save at least one mark before publishing.", "danger");
                ShowGradesSection(true);
                return;
            }

            DatabaseHelper.ExecuteNonQuery(@"
                UPDATE g
                SET MarksObtained = g.DraftMarksObtained,
                    DraftMarksObtained = NULL,
                    SubmittedAt = GETDATE()
                FROM Grades g
                INNER JOIN Enrollment e
                    ON e.StudentId = g.StudentId
                   AND e.CourseId = g.CourseId
                WHERE g.CourseId = @CourseId
                  AND e.Session = @Session
                  AND e.Status = 'Active'
                  AND g.DraftMarksObtained IS NOT NULL",
                new[]
                {
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session)
                });

            ShowGradesSection(false);
            ShowMessage("Student grades published successfully.", "success");
        }

        private bool SavePostedGrades(out string validationMessage)
        {
            validationMessage = "";
            string courseId = Request.QueryString["courseId"];
            DataTable assignments = AssignmentMaterials;

            if (assignments == null)
                return true;

            foreach (GridViewRow row in gvGrades.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow)
                    continue;

                string studentId = row.Cells[1].Text.Trim();
                int cellIndex = 3;

                foreach (DataRow a in assignments.Rows)
                {
                    string postedValue = GetPostedGradeValue(studentId, cellIndex);
                    if (!string.IsNullOrWhiteSpace(postedValue))
                    {
                        decimal mark;
                        if (!decimal.TryParse(postedValue.Trim(), out mark) || mark < 0 || mark > 100)
                        {
                            validationMessage = "Marks must be between 0 and 100.";
                            return false;
                        }

                        SaveDraftGrade(studentId, Convert.ToInt32(a["MaterialId"]), GetGradeTypeForMaterial(a["MaterialType"].ToString()), a["Title"].ToString(), mark);
                    }

                    cellIndex++;
                }
            }

            return true;
        }

        private string GetGradeTypeForMaterial(string materialType)
        {
            return materialType == "Final Exam" ? "Exam" : "Assignment";
        }

        private void SaveDraftGrade(string studentId, int materialId, string type, string title, decimal marks)
        {
            string courseId = Request.QueryString["courseId"];

            string sql = @"
                UPDATE Grades
                SET Title = @Title,
                    MaxMarks = 100,
                    DraftMarksObtained = @DraftMarksObtained
                WHERE StudentId = @StudentId
                  AND CourseId = @CourseId
                  AND Type = @Type
                  AND MaterialId = @MaterialId";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@MaterialId", materialId),
                new SqlParameter("@Type", type),
                new SqlParameter("@Title", title),
                new SqlParameter("@DraftMarksObtained", marks)
            });
        }

        private string GetPostedGradeValue(string studentId, int cellIndex)
        {
            string inputName = "txt_" + studentId + "_" + cellIndex;

            return Request.Form.AllKeys
                .Where(k => k != null && k.EndsWith(inputName))
                .Select(k => Request.Form[k])
                .FirstOrDefault();
        }

        private string CalculateStudentGpa(string studentId, string courseId, bool showDraftMarks)
        {
            DataTable marks = DatabaseHelper.ExecuteQuery(@"
                SELECT " + (showDraftMarks ? "COALESCE(DraftMarksObtained, MarksObtained)" : "MarksObtained") + @" AS MarksForGpa
                FROM Grades
                WHERE StudentId = @StudentId
                  AND CourseId = @CourseId
                  AND " + (showDraftMarks ? "COALESCE(DraftMarksObtained, MarksObtained)" : "MarksObtained") + @" IS NOT NULL",
                new[]
                {
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@CourseId", courseId)
                });

            if (marks.Rows.Count == 0)
                return "";

            decimal total = 0;
            foreach (DataRow row in marks.Rows)
            {
                total += Convert.ToDecimal(row["MarksForGpa"]);
            }

            decimal average = total / marks.Rows.Count;
            decimal gpa = Math.Round(Math.Min(4m, average / 25m), 2);

            return gpa.ToString("0.00");
        }

        private bool HasUnpublishedGradeChanges()
        {
            return GradesHaveDraftMarks();
        }

        private void LoadAssignmentMaterialInfo()
        {
            string courseId = Request.QueryString["courseId"];
            string session = Request.QueryString["session"];

            string sql = @"
                SELECT MaterialId, Title
                FROM CourseMaterials
                WHERE CourseId = @CourseId
                  AND Session = @Session
                  AND LecturerId = @LecturerId
                  AND MaterialType = 'Assignment'
                ORDER BY CreatedAt DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session),
                new SqlParameter("@LecturerId", CurrentLecturerId)
            });

            if (dt.Rows.Count > 0)
            {
                HasAssignmentMaterial = true;
                AssignmentMaterialId = Convert.ToInt32(dt.Rows[0]["MaterialId"]);
                AssignmentColumnTitle = dt.Rows[0]["Title"].ToString() + " /100";
            }
            else
            {
                HasAssignmentMaterial = false;
                AssignmentMaterialId = 0;
                AssignmentColumnTitle = "";
            }
        }
        private string CalculateGrade(decimal average)
        {
            if (average >= 80) return "A";
            if (average >= 70) return "B";
            if (average >= 60) return "C";
            if (average >= 50) return "D";
            return "F";
        }
        private void ShowMessage(string message, string type)
        {
            string safeMessage = message.Replace("'", "\\'")
                                        .Replace(Environment.NewLine, "<br/>");

            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                Guid.NewGuid().ToString(),
                $"showMessageModal('', '{safeMessage}', '{type}');",
                true
            );
        }

        private void CheckUnreadNotifications()
        {
            object count = DatabaseHelper.ExecuteScalar(
                @"SELECT COUNT(*) 
                  FROM Notifications 
                  WHERE UserId = @UserId 
                    AND IsRead = 0",
                new[] { new SqlParameter("@UserId", CurrentUserId) });

            pnlNotifBadge.Visible = count != null && Convert.ToInt32(count) > 0;
        }

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }

        public bool HasAssignmentMaterial { get; set; }
        public string AssignmentColumnTitle { get; set; }
        private int AssignmentMaterialId { get; set; }
        private bool IsGradeEditMode
        {
            get { return ViewState["IsGradeEditMode"] != null && (bool)ViewState["IsGradeEditMode"]; }
            set { ViewState["IsGradeEditMode"] = value; }
        }

        private bool HasExamGradeColumn
        {
            get { return ViewState["HasExamGradeColumn"] != null && (bool)ViewState["HasExamGradeColumn"]; }
            set { ViewState["HasExamGradeColumn"] = value; }
        }

        private string ExamGradeTitle
        {
            get { return ViewState["ExamGradeTitle"] == null ? "Final Exam" : ViewState["ExamGradeTitle"].ToString(); }
            set { ViewState["ExamGradeTitle"] = value; }
        }

        private DataTable AssignmentMaterials
        {
            get { return Session["AssignmentMaterials"] as DataTable; }
            set { Session["AssignmentMaterials"] = value; }
        }
    }
}


