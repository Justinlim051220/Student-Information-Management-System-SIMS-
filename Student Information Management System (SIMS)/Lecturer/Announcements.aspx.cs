using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Lecturer
{
    public partial class Announcements : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireLecturer(Session, Response);

            if (!IsPostBack)
            {
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadProgrammeFilter();
                LoadCourseFilter();
                LoadSessionFilter();
                LoadFormProgrammes();
                LoadFormCourses();
                LoadFormSessions();
                LoadAnnouncements();
                CheckUnreadNotifications();

                if ((Request.QueryString["action"] ?? "").Equals("add", StringComparison.OrdinalIgnoreCase))
                    ShowAddForm();
            }
        }

        private int CurrentUserId => SessionHelper.GetUserId(Session);

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

                return result?.ToString() ?? "";
            }
        }

        private void LoadProgrammeFilter()
        {
            string sql = @"
                SELECT DISTINCT p.ProgrammeId, p.ProgrammeCode + ' - ' + p.ProgrammeName AS ProgrammeDisplay
                FROM LecturerCourse lc
                INNER JOIN Courses c ON c.CourseId = lc.CourseId
                INNER JOIN Programmes p ON p.ProgrammeId = c.ProgrammeId
                WHERE lc.LecturerId = @LecturerId
                ORDER BY ProgrammeDisplay";

            ddlFilterProgramme.DataSource = DatabaseHelper.ExecuteQuery(sql,
                new[] { new SqlParameter("@LecturerId", CurrentLecturerId) });
            ddlFilterProgramme.DataTextField = "ProgrammeDisplay";
            ddlFilterProgramme.DataValueField = "ProgrammeId";
            ddlFilterProgramme.DataBind();
            ddlFilterProgramme.Items.Insert(0, new ListItem("All Programmes", ""));
        }

        private void LoadCourseFilter()
        {
            string sql = @"
                SELECT DISTINCT c.CourseId, c.CourseCode + ' - ' + c.CourseName AS CourseDisplay
                FROM LecturerCourse lc
                INNER JOIN Courses c ON c.CourseId = lc.CourseId
                WHERE lc.LecturerId = @LecturerId
                  AND (@ProgrammeId IS NULL OR c.ProgrammeId = @ProgrammeId)
                ORDER BY CourseDisplay";

            SqlParameter programmeParam = string.IsNullOrEmpty(ddlFilterProgramme.SelectedValue)
                ? new SqlParameter("@ProgrammeId", DBNull.Value)
                : new SqlParameter("@ProgrammeId", ddlFilterProgramme.SelectedValue);

            ddlFilterCourse.DataSource = DatabaseHelper.ExecuteQuery(sql,
                new[] { new SqlParameter("@LecturerId", CurrentLecturerId), programmeParam });
            ddlFilterCourse.DataTextField = "CourseDisplay";
            ddlFilterCourse.DataValueField = "CourseId";
            ddlFilterCourse.DataBind();
            ddlFilterCourse.Items.Insert(0, new ListItem("All Courses", ""));
        }

        private void LoadSessionFilter()
        {
            string sql = @"
                SELECT DISTINCT Session
                FROM LecturerCourse
                WHERE LecturerId = @LecturerId
                ORDER BY Session DESC";

            ddlFilterSession.DataSource = DatabaseHelper.ExecuteQuery(sql,
                new[] { new SqlParameter("@LecturerId", CurrentLecturerId) });
            ddlFilterSession.DataTextField = "Session";
            ddlFilterSession.DataValueField = "Session";
            ddlFilterSession.DataBind();
            ddlFilterSession.Items.Insert(0, new ListItem("All Sessions", ""));
        }

        private void LoadFormProgrammes()
        {
            string sql = @"
                SELECT DISTINCT p.ProgrammeId, p.ProgrammeCode + ' - ' + p.ProgrammeName AS ProgrammeDisplay
                FROM LecturerCourse lc
                INNER JOIN Courses c ON c.CourseId = lc.CourseId
                INNER JOIN Programmes p ON p.ProgrammeId = c.ProgrammeId
                WHERE lc.LecturerId = @LecturerId
                ORDER BY ProgrammeDisplay";

            ddlFormProgramme.DataSource = DatabaseHelper.ExecuteQuery(sql,
                new[] { new SqlParameter("@LecturerId", CurrentLecturerId) });
            ddlFormProgramme.DataTextField = "ProgrammeDisplay";
            ddlFormProgramme.DataValueField = "ProgrammeId";
            ddlFormProgramme.DataBind();
            ddlFormProgramme.Items.Insert(0, new ListItem("Select Programme", ""));
        }

        private void LoadFormCourses()
        {
            string sql = @"
                SELECT DISTINCT c.CourseId, c.CourseCode + ' - ' + c.CourseName AS CourseDisplay
                FROM LecturerCourse lc
                INNER JOIN Courses c ON c.CourseId = lc.CourseId
                WHERE lc.LecturerId = @LecturerId
                  AND (@ProgrammeId IS NULL OR c.ProgrammeId = @ProgrammeId)
                ORDER BY CourseDisplay";

            SqlParameter programmeParam = string.IsNullOrEmpty(ddlFormProgramme.SelectedValue)
                ? new SqlParameter("@ProgrammeId", DBNull.Value)
                : new SqlParameter("@ProgrammeId", ddlFormProgramme.SelectedValue);

            ddlFormCourse.DataSource = DatabaseHelper.ExecuteQuery(sql,
                new[] { new SqlParameter("@LecturerId", CurrentLecturerId), programmeParam });
            ddlFormCourse.DataTextField = "CourseDisplay";
            ddlFormCourse.DataValueField = "CourseId";
            ddlFormCourse.DataBind();
            ddlFormCourse.Items.Insert(0, new ListItem("General / All Courses in Selected Programme", ""));
        }

        private void LoadFormSessions()
        {
            string sql = @"
                SELECT DISTINCT Session
                FROM LecturerCourse
                WHERE LecturerId = @LecturerId
                ORDER BY Session DESC";

            ddlFormSession.DataSource = DatabaseHelper.ExecuteQuery(sql,
                new[] { new SqlParameter("@LecturerId", CurrentLecturerId) });
            ddlFormSession.DataTextField = "Session";
            ddlFormSession.DataValueField = "Session";
            ddlFormSession.DataBind();
        }

        private void LoadAnnouncements()
        {
            string sql = @"
                SELECT a.AnnouncementId,
                       a.Title,
                       a.Content,
                       ISNULL(a.Session, '-') AS Session,
                       a.CreatedAt,
                       ISNULL(p.ProgrammeCode, 'General') AS ProgrammeCode,
                       CASE
                           WHEN c.CourseId IS NULL THEN 'General / All Courses'
                           ELSE c.CourseCode + ' - ' + c.CourseName
                       END AS CourseDisplay
                FROM Announcements a
                LEFT JOIN Courses c ON c.CourseId = a.CourseId
                LEFT JOIN Programmes p ON p.ProgrammeId = COALESCE(a.ProgrammeId, c.ProgrammeId)
                WHERE a.PostedByUserId = @UserId
                  AND (@ProgrammeId IS NULL OR COALESCE(a.ProgrammeId, c.ProgrammeId) = @ProgrammeId)
                  AND (@CourseId IS NULL OR a.CourseId = @CourseId)
                  AND (@Session IS NULL OR a.Session = @Session)
                  AND (
                        @Search = ''
                        OR a.Title LIKE '%' + @Search + '%'
                        OR CONVERT(VARCHAR(MAX), a.Content) LIKE '%' + @Search + '%'
                      )
                ORDER BY a.CreatedAt DESC";

            SqlParameter programmeParam = string.IsNullOrEmpty(ddlFilterProgramme.SelectedValue)
                ? new SqlParameter("@ProgrammeId", DBNull.Value)
                : new SqlParameter("@ProgrammeId", ddlFilterProgramme.SelectedValue);

            SqlParameter courseParam = string.IsNullOrEmpty(ddlFilterCourse.SelectedValue)
                ? new SqlParameter("@CourseId", DBNull.Value)
                : new SqlParameter("@CourseId", ddlFilterCourse.SelectedValue);

            SqlParameter sessionParam = string.IsNullOrEmpty(ddlFilterSession.SelectedValue)
                ? new SqlParameter("@Session", DBNull.Value)
                : new SqlParameter("@Session", ddlFilterSession.SelectedValue);

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@UserId", CurrentUserId),
                programmeParam,
                courseParam,
                sessionParam,
                new SqlParameter("@Search", txtSearch.Text.Trim())
            });

            rptAnnouncements.DataSource = dt;
            rptAnnouncements.DataBind();
            lblTotal.Text = dt.Rows.Count.ToString();
            pnlEmpty.Visible = dt.Rows.Count == 0;
        }

        protected void ddlFilterProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourseFilter();
            LoadAnnouncements();
        }

        protected void ddlFormProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadFormCourses();
            pnlForm.Visible = true;
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            LoadAnnouncements();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadAnnouncements();
        }

        protected void btnShowAdd_Click(object sender, EventArgs e)
        {
            ShowAddForm();
        }

        private void ShowAddForm()
        {
            ClearForm();
            pnlForm.Visible = true;
            lblFormTitle.Text = "Add Announcement";
            btnSave.Text = "Save Announcement";
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTitle.Text) || string.IsNullOrWhiteSpace(txtContent.Text))
            {
                ShowMessage("Please fill in title and content.", "danger");
                pnlForm.Visible = true;
                return;
            }

            if (ddlFormProgramme.Items.Count == 0 || string.IsNullOrWhiteSpace(ddlFormProgramme.SelectedValue))
            {
                ShowMessage("Please select a programme.", "danger");
                pnlForm.Visible = true;
                return;
            }

            if (ddlFormSession.Items.Count == 0 || string.IsNullOrWhiteSpace(ddlFormSession.SelectedValue))
            {
                ShowMessage("No teaching session found. Please assign this lecturer to a course/session first.", "danger");
                pnlForm.Visible = true;
                return;
            }

            try
            {
                object programmeIdValue = ddlFormProgramme.SelectedValue;

                object courseIdValue = string.IsNullOrEmpty(ddlFormCourse.SelectedValue)
                    ? (object)DBNull.Value
                    : ddlFormCourse.SelectedValue;

                if (string.IsNullOrEmpty(hfAnnouncementId.Value))
                {
                    string insertSql = @"
                        INSERT INTO Announcements
                            (Title, Content, PostedByUserId, TargetRole, ProgrammeId, CourseId, Session, CreatedAt)
                        VALUES
                            (@Title, @Content, @UserId, 'Student', @ProgrammeId, @CourseId, @Session, GETDATE())";

                    DatabaseHelper.ExecuteNonQuery(insertSql, new[]
                    {
                        new SqlParameter("@Title", txtTitle.Text.Trim()),
                        new SqlParameter("@Content", txtContent.Text.Trim()),
                        new SqlParameter("@UserId", CurrentUserId),
                        new SqlParameter("@ProgrammeId", programmeIdValue),
                        new SqlParameter("@CourseId", courseIdValue),
                        new SqlParameter("@Session", ddlFormSession.SelectedValue)
                    });

                    ShowMessage("Announcement added successfully.", "success");
                }
                else
                {
                    string updateSql = @"
                        UPDATE Announcements
                        SET Title = @Title,
                            Content = @Content,
                            ProgrammeId = @ProgrammeId,
                            CourseId = @CourseId,
                            Session = @Session
                        WHERE AnnouncementId = @AnnouncementId
                          AND PostedByUserId = @UserId";

                    DatabaseHelper.ExecuteNonQuery(updateSql, new[]
                    {
                        new SqlParameter("@Title", txtTitle.Text.Trim()),
                        new SqlParameter("@Content", txtContent.Text.Trim()),
                        new SqlParameter("@ProgrammeId", programmeIdValue),
                        new SqlParameter("@CourseId", courseIdValue),
                        new SqlParameter("@Session", ddlFormSession.SelectedValue),
                        new SqlParameter("@AnnouncementId", hfAnnouncementId.Value),
                        new SqlParameter("@UserId", CurrentUserId)
                    });

                    ShowMessage("Announcement updated successfully.", "success");
                }

                ClearForm();
                pnlForm.Visible = false;
                LoadAnnouncements();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "danger");
                pnlForm.Visible = true;
            }
        }

        protected void rptAnnouncements_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int announcementId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditAnnouncement")
            {
                LoadAnnouncementForEdit(announcementId);
            }
        }

        private void LoadAnnouncementForEdit(int announcementId)
        {
            string sql = @"
                SELECT AnnouncementId, Title, Content, ProgrammeId, CourseId, Session
                FROM Announcements
                WHERE AnnouncementId = @AnnouncementId
                  AND PostedByUserId = @UserId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@AnnouncementId", announcementId),
                new SqlParameter("@UserId", CurrentUserId)
            });

            if (dt.Rows.Count == 0)
            {
                ShowMessage("Announcement not found or you do not have permission to edit it.", "danger");
                return;
            }

            DataRow row = dt.Rows[0];
            hfAnnouncementId.Value = row["AnnouncementId"].ToString();
            txtTitle.Text = row["Title"].ToString();
            txtContent.Text = row["Content"].ToString();

            SetDropDownValue(ddlFormProgramme, row["ProgrammeId"] == DBNull.Value ? "" : row["ProgrammeId"].ToString());
            LoadFormCourses();
            SetDropDownValue(ddlFormCourse, row["CourseId"] == DBNull.Value ? "" : row["CourseId"].ToString());
            SetDropDownValue(ddlFormSession, row["Session"].ToString());

            lblFormTitle.Text = "Edit Announcement";
            btnSave.Text = "Update Announcement";
            pnlForm.Visible = true;

            ShowEditModeMessage("You are now editing this announcement.");
        }

        private void DeleteAnnouncement(int announcementId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery(@"
                    DELETE FROM Announcements
                    WHERE AnnouncementId = @AnnouncementId
                      AND PostedByUserId = @UserId",
                    new[]
                    {
                        new SqlParameter("@AnnouncementId", announcementId),
                        new SqlParameter("@UserId", CurrentUserId)
                    });

                LoadAnnouncements();
                ShowMessage("Announcement deleted successfully.", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting announcement: " + ex.Message, "danger");
            }
        }

        protected void btnDeleteConfirmed_Click(object sender, EventArgs e)
        {
            int announcementId;

            if (int.TryParse(hfDeleteTarget.Value, out announcementId))
            {
                DeleteAnnouncement(announcementId);
            }
            else
            {
                ShowMessage("Invalid announcement selected.", "danger");
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearForm();
            pnlForm.Visible = false;
        }

        private void ClearForm()
        {
            hfAnnouncementId.Value = "";
            txtTitle.Text = "";
            txtContent.Text = "";

            if (ddlFormProgramme.Items.Count > 0)
                ddlFormProgramme.SelectedIndex = 0;

            LoadFormCourses();

            if (ddlFormCourse.Items.Count > 0)
                ddlFormCourse.SelectedIndex = 0;

            if (ddlFormSession.Items.Count > 0)
                ddlFormSession.SelectedIndex = 0;
        }

        private void SetDropDownValue(DropDownList ddl, string value)
        {
            if (ddl.Items.FindByValue(value) != null)
                ddl.SelectedValue = value;
        }

        private void CheckUnreadNotifications()
        {
            object count = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @UserId AND IsRead = 0",
                new[] { new SqlParameter("@UserId", CurrentUserId) });

            pnlNotifBadge.Visible = count != null && Convert.ToInt32(count) > 0;
        }

        private void ShowMessage(string message, string type)
        {
            string title;

            switch (type.ToLower())
            {
                case "success":
                    title = "Success";
                    break;

                case "danger":
                    title = "❌ Error";
                    break;

                case "warning":
                    title = "⚠ Warning";
                    break;

                default:
                    title = "Message";
                    break;
            }

            string safeTitle = title.Replace("'", "\\'");
            string safeMessage = message.Replace("'", "\\'").Replace(Environment.NewLine, "<br/>");

            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                Guid.NewGuid().ToString(),
                $"showMessageModal('{safeTitle}', '{safeMessage}', false, '');",
                true
            );
        }

        private void ShowEditModeMessage(string message)
        {
            string safeMessage = message.Replace("'", "\\'").Replace(Environment.NewLine, "<br/>");

            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                Guid.NewGuid().ToString(),
                $"showMessageModal('Edit Mode', '{safeMessage}', false, '');",
                true
            );
        }

        
    }
}