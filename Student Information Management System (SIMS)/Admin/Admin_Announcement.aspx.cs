using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Admin
{
    public partial class Admin_Announcement : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);
            if (!IsPostBack)
            {
                LoadProgrammes();
                LoadCourses(ddlProgramme, ddlCourse);
                LoadCourses(ddlFilterProgramme, ddlFilterCourse);
                LoadSessions(ddlSession, "Select Session / General");
                LoadSessions(ddlFilterSession, "All Sessions");
                LoadAnnouncements();
            }
        }

        private int CurrentUserId => SessionHelper.GetUserId(Session);

        private void LoadProgrammes()
        {
            string sql = "SELECT ProgrammeId, ProgrammeCode + ' - ' + ProgrammeName AS ProgrammeDisplay FROM Programmes ORDER BY ProgrammeName";
            DataTable dt = DatabaseHelper.ExecuteQuery(sql);
            ddlProgramme.DataSource = dt; ddlProgramme.DataTextField = "ProgrammeDisplay"; ddlProgramme.DataValueField = "ProgrammeId"; ddlProgramme.DataBind(); ddlProgramme.Items.Insert(0, new ListItem("General / All Programmes", ""));
            ddlFilterProgramme.DataSource = dt; ddlFilterProgramme.DataTextField = "ProgrammeDisplay"; ddlFilterProgramme.DataValueField = "ProgrammeId"; ddlFilterProgramme.DataBind(); ddlFilterProgramme.Items.Insert(0, new ListItem("All Programmes", ""));
        }

        private void LoadCourses(DropDownList programmeList, DropDownList courseList)
        {
            string sql = @"SELECT CourseId, CourseCode + ' - ' + CourseName AS CourseDisplay FROM Courses WHERE (@ProgrammeId IS NULL OR ProgrammeId = @ProgrammeId) ORDER BY CourseName";
            SqlParameter p = string.IsNullOrEmpty(programmeList.SelectedValue) ? new SqlParameter("@ProgrammeId", DBNull.Value) : new SqlParameter("@ProgrammeId", programmeList.SelectedValue);
            courseList.DataSource = DatabaseHelper.ExecuteQuery(sql, new[] { p });
            courseList.DataTextField = "CourseDisplay"; courseList.DataValueField = "CourseId"; courseList.DataBind(); courseList.Items.Insert(0, new ListItem("General / All Courses", ""));
        }

        private void LoadSessions(DropDownList list, string firstText)
        {
            list.Items.Clear(); list.Items.Add(new ListItem(firstText, ""));
            string[] sessions = { "April 2026", "August 2026", "January 2027", "April 2027", "August 2027" };
            foreach (string s in sessions) list.Items.Add(new ListItem(s, s));
        }

        protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e) { LoadCourses(ddlProgramme, ddlCourse); }

        private void LoadAnnouncements()
        {
            string sql = @"
                SELECT a.AnnouncementId, a.Title, CONVERT(VARCHAR(MAX), a.Content) AS Content, a.TargetRole, a.CreatedAt,
                       ISNULL(p.ProgrammeCode + ' - ' + p.ProgrammeName, 'General / All Programmes') AS ProgrammeDisplay,
                       ISNULL(c.CourseCode + ' - ' + c.CourseName, 'General / All Courses') AS CourseDisplay,
                       ISNULL(a.Session, 'General') AS SessionDisplay
                FROM Announcements a
                INNER JOIN Users u ON u.UserId = a.PostedByUserId AND u.Role = 1
                LEFT JOIN Programmes p ON p.ProgrammeId = a.ProgrammeId
                LEFT JOIN Courses c ON c.CourseId = a.CourseId
                WHERE (@Search = '' OR a.Title LIKE '%' + @Search + '%' OR CONVERT(VARCHAR(MAX), a.Content) LIKE '%' + @Search + '%')
                  AND (@ProgrammeId IS NULL OR a.ProgrammeId = @ProgrammeId)
                  AND (@CourseId IS NULL OR a.CourseId = @CourseId)
                  AND (@Session IS NULL OR a.Session = @Session)
                ORDER BY a.CreatedAt DESC";
            SqlParameter programme = string.IsNullOrEmpty(ddlFilterProgramme.SelectedValue) ? new SqlParameter("@ProgrammeId", DBNull.Value) : new SqlParameter("@ProgrammeId", ddlFilterProgramme.SelectedValue);
            SqlParameter course = string.IsNullOrEmpty(ddlFilterCourse.SelectedValue) ? new SqlParameter("@CourseId", DBNull.Value) : new SqlParameter("@CourseId", ddlFilterCourse.SelectedValue);
            SqlParameter session = string.IsNullOrEmpty(ddlFilterSession.SelectedValue) ? new SqlParameter("@Session", DBNull.Value) : new SqlParameter("@Session", ddlFilterSession.SelectedValue);
            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@Search", txtSearch.Text.Trim()), programme, course, session });
            rptAnnouncements.DataSource = dt;
            rptAnnouncements.DataBind();
            lblTotal.Text = dt.Rows.Count.ToString();
            pnlEmpty.Visible = dt.Rows.Count == 0;
        }

        protected void ddlFilterProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourses(ddlFilterProgramme, ddlFilterCourse);
            LoadAnnouncements();
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            LoadAnnouncements();
        }

        protected void btnShowAdd_Click(object sender, EventArgs e)
        {
            ClearForm();
            pnlForm.Visible = true;
            if (!string.IsNullOrEmpty(ddlFilterProgramme.SelectedValue))
            {
                ddlProgramme.SelectedValue = ddlFilterProgramme.SelectedValue;
                LoadCourses(ddlProgramme, ddlCourse);
            }
            if (!string.IsNullOrEmpty(ddlFilterCourse.SelectedValue)) ddlCourse.SelectedValue = ddlFilterCourse.SelectedValue;
            if (!string.IsNullOrEmpty(ddlFilterSession.SelectedValue)) ddlSession.SelectedValue = ddlFilterSession.SelectedValue;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTitle.Text) || string.IsNullOrWhiteSpace(txtContent.Text)) { ShowMessage("Please fill in title and content.", "error", false, "Validation Error"); return; }
            try
            {
                SqlParameter programme = string.IsNullOrEmpty(ddlProgramme.SelectedValue) ? new SqlParameter("@ProgrammeId", DBNull.Value) : new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue);
                SqlParameter course = string.IsNullOrEmpty(ddlCourse.SelectedValue) ? new SqlParameter("@CourseId", DBNull.Value) : new SqlParameter("@CourseId", ddlCourse.SelectedValue);
                SqlParameter session = string.IsNullOrEmpty(ddlSession.SelectedValue) ? new SqlParameter("@Session", DBNull.Value) : new SqlParameter("@Session", ddlSession.SelectedValue);
                if (string.IsNullOrEmpty(hfAnnouncementId.Value))
                {
                    string sql = @"INSERT INTO Announcements (Title, Content, PostedByUserId, TargetRole, ProgrammeId, CourseId, Session) VALUES (@Title, @Content, @UserId, @TargetRole, @ProgrammeId, @CourseId, @Session)";
                    DatabaseHelper.ExecuteNonQuery(sql, new[] { new SqlParameter("@Title", txtTitle.Text.Trim()), new SqlParameter("@Content", txtContent.Text.Trim()), new SqlParameter("@UserId", CurrentUserId), new SqlParameter("@TargetRole", ddlTargetRole.SelectedValue), programme, course, session });
                    CreateRoleNotifications(txtTitle.Text.Trim(), txtContent.Text.Trim(), ddlTargetRole.SelectedValue);
                    ShowMessage("Announcement saved successfully and notification sent to the selected role(s).", "success", false, "Announcement Saved");
                }
                else
                {
                    string sql = @"
                        UPDATE a
                        SET Title=@Title, Content=@Content, TargetRole=@TargetRole, ProgrammeId=@ProgrammeId, CourseId=@CourseId, Session=@Session
                        FROM Announcements a
                        INNER JOIN Users u ON u.UserId = a.PostedByUserId AND u.Role = 1
                        WHERE a.AnnouncementId=@AnnouncementId";
                    DatabaseHelper.ExecuteNonQuery(sql, new[] { new SqlParameter("@Title", txtTitle.Text.Trim()), new SqlParameter("@Content", txtContent.Text.Trim()), new SqlParameter("@TargetRole", ddlTargetRole.SelectedValue), programme, course, session, new SqlParameter("@AnnouncementId", hfAnnouncementId.Value) });
                    ShowMessage("Announcement updated successfully.", "success", false, "Announcement Updated");
                }
                ClearForm(); LoadAnnouncements();
            }
            catch (Exception ex) { ShowMessage("Error: " + ex.Message, "error", false, "Error"); }
        }

        protected void rptAnnouncements_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string id = e.CommandArgument.ToString();
            if (e.CommandName == "EditAnnouncement") LoadForEdit(id);
        }

        private void LoadForEdit(string id)
        {
            DataTable dt = DatabaseHelper.ExecuteQuery(@"
                SELECT a.*
                FROM Announcements a
                INNER JOIN Users u ON u.UserId = a.PostedByUserId AND u.Role = 1
                WHERE a.AnnouncementId=@Id", new[] { new SqlParameter("@Id", id) });
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0]; hfAnnouncementId.Value = id; txtTitle.Text = r["Title"].ToString(); txtContent.Text = r["Content"].ToString(); ddlTargetRole.SelectedValue = r["TargetRole"].ToString();
            ddlProgramme.SelectedValue = r["ProgrammeId"] == DBNull.Value ? "" : r["ProgrammeId"].ToString(); LoadCourses(ddlProgramme, ddlCourse); ddlCourse.SelectedValue = r["CourseId"] == DBNull.Value ? "" : r["CourseId"].ToString(); ddlSession.SelectedValue = r["Session"] == DBNull.Value ? "" : r["Session"].ToString();
            lblFormTitle.Text = "Edit Announcement"; btnSave.Text = "Update Announcement"; pnlForm.Visible = true; ShowMessage("Edit mode activated. You may update the announcement details now.", "edit", false, "Edit Mode");
        }

        protected void btnDeleteConfirmed_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfDeleteTarget.Value)) return;
            DatabaseHelper.ExecuteNonQuery(@"
                DELETE a
                FROM Announcements a
                INNER JOIN Users u ON u.UserId = a.PostedByUserId AND u.Role = 1
                WHERE a.AnnouncementId=@Id", new[] { new SqlParameter("@Id", hfDeleteTarget.Value) });
            hfDeleteTarget.Value = ""; LoadAnnouncements(); ShowMessage("Announcement deleted successfully.", "success", false, "Deleted");
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadAnnouncements(); }
        protected void btnReset_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlFilterProgramme.SelectedIndex = 0; LoadCourses(ddlFilterProgramme, ddlFilterCourse); ddlFilterSession.SelectedIndex = 0; LoadAnnouncements(); }
        protected void btnClear_Click(object sender, EventArgs e) { ClearForm(); pnlForm.Visible = true; }
        protected void btnBack_Click(object sender, EventArgs e) { Response.Redirect("~/Admin/Dashboard.aspx"); }

        private void ClearForm() { hfAnnouncementId.Value = ""; txtTitle.Text = ""; txtContent.Text = ""; ddlTargetRole.SelectedIndex = 0; ddlProgramme.SelectedIndex = 0; LoadCourses(ddlProgramme, ddlCourse); ddlSession.SelectedIndex = 0; lblFormTitle.Text = "Add Announcement"; btnSave.Text = "Save Announcement"; pnlForm.Visible = false; }

        private void CreateRoleNotifications(string title, string content, string targetRole)
        {
            string notifySql = @"
                INSERT INTO Notifications (UserId, Title, Message, IsRead, CreatedAt)
                SELECT UserId, @Title, @Message, 0, GETDATE()
                FROM Users
                WHERE IsActive = 1
                  AND (
                        (@TargetRole = 'All' AND Role IN (2, 3))
                     OR (@TargetRole = 'Lecturer' AND Role = 2)
                     OR (@TargetRole = 'Student' AND Role = 3)
                  )";

            DatabaseHelper.ExecuteNonQuery(notifySql, new[]
            {
                new SqlParameter("@Title", title),
                new SqlParameter("@Message", content),
                new SqlParameter("@TargetRole", targetRole)
            });
        }

        private void ShowMessage(string message, string type, bool isConfirmDelete, string title)
        {
            string safeMessage = message.Replace("\\", "\\\\").Replace("`", "\\`").Replace("${", "\\${").Replace("'", "\\'");
            string safeTitle = title.Replace("\\", "\\\\").Replace("`", "\\`").Replace("${", "\\${").Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(), $"showCustomModal('{safeMessage}', '{type}', {(isConfirmDelete ? "true" : "false")}, '{safeTitle}');", true);
        }
    }
}
