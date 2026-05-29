using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

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

                hlGrades.NavigateUrl =
                    "CourseGrades.aspx?courseId=" + courseId +
                    "&session=" + Server.UrlEncode(session);
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

        protected void lbShowStudents_Click(object sender, EventArgs e)
        {
            ShowStudentsSection();
        }

        protected void lbPostMaterial_Click(object sender, EventArgs e)
        {
            ShowMaterialsSection();
        }

        private void ShowStudentsSection()
        {
            pnlStudentsSection.Visible = true;
            pnlMaterialsSection.Visible = false;

            lbShowStudents.CssClass = "course-action-btn active";
            lbPostMaterial.CssClass = "course-action-btn";
        }

        private void ShowMaterialsSection()
        {
            pnlStudentsSection.Visible = false;
            pnlMaterialsSection.Visible = true;

            lbShowStudents.CssClass = "course-action-btn";
            lbPostMaterial.CssClass = "course-action-btn active";

            LoadMaterials();
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

            if (editId == 0 && !fuMaterial.HasFiles)
            {
                ShowMessage("Please select at least one file to upload.", "danger");
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
    }
}