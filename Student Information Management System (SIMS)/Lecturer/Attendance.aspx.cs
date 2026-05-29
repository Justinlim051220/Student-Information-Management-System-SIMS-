using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Lecturer
{
    public partial class Attendance : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireLecturer(Session, Response);

            if (!IsPostBack)
            {
                LoadLecturerInfo();
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
                txtAttendanceDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

                LoadProgrammeFilter();
                LoadCourseFilter();
                LoadSessionFilter();
                CheckUnreadNotifications();
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
        private void LoadProgrammeFilter()
        {
            string sql = @"
                SELECT DISTINCT 
                    p.ProgrammeId,
                    p.ProgrammeCode + ' - ' + p.ProgrammeName AS ProgrammeDisplay
                FROM LecturerCourse lc
                INNER JOIN Courses c ON lc.CourseId = c.CourseId
                INNER JOIN Programmes p ON c.ProgrammeId = p.ProgrammeId
                WHERE lc.LecturerId = @LecturerId
                ORDER BY ProgrammeDisplay";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId)
            });

            ddlProgramme.DataSource = dt;
            ddlProgramme.DataTextField = "ProgrammeDisplay";
            ddlProgramme.DataValueField = "ProgrammeId";
            ddlProgramme.DataBind();
            ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
        }

        private void LoadCourseFilter()
        {
            ddlCourse.Items.Clear();
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));

            if (string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue))
                return;

            string sql = @"
                SELECT DISTINCT
                    c.CourseId,
                    c.CourseCode + ' - ' + c.CourseName AS CourseDisplay
                FROM LecturerCourse lc
                INNER JOIN Courses c ON lc.CourseId = c.CourseId
                WHERE lc.LecturerId = @LecturerId
                  AND c.ProgrammeId = @ProgrammeId
                ORDER BY CourseDisplay";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId),
                new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue)
            });

            ddlCourse.DataSource = dt;
            ddlCourse.DataTextField = "CourseDisplay";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));
        }

        private void LoadSessionFilter()
        {
            ddlSession.Items.Clear();
            ddlSession.Items.Insert(0, new ListItem("-- Select Session --", ""));

            if (string.IsNullOrWhiteSpace(ddlCourse.SelectedValue))
                return;

            string sql = @"
                SELECT DISTINCT Session
                FROM LecturerCourse
                WHERE LecturerId = @LecturerId
                  AND CourseId = @CourseId
                ORDER BY Session DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue)
            });

            ddlSession.DataSource = dt;
            ddlSession.DataTextField = "Session";
            ddlSession.DataValueField = "Session";
            ddlSession.DataBind();
            ddlSession.Items.Insert(0, new ListItem("-- Select Session --", ""));
        }

        protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourseFilter();
            LoadSessionFilter();
            pnlAttendanceList.Visible = false;
        }

        protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSessionFilter();
            pnlAttendanceList.Visible = false;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            if (!ValidateFilters())
                return;

            LoadStudents(false);
        }

        private bool ValidateFilters()
        {
            if (string.IsNullOrWhiteSpace(txtAttendanceDate.Text))
            {
                ShowMessage("Validation Error", "Please select attendance date.", false);
                return false;
            }

            if (string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue))
            {
                ShowMessage("Validation Error", "Please select programme.", false);
                return false;
            }

            if (string.IsNullOrWhiteSpace(ddlCourse.SelectedValue))
            {
                ShowMessage("Validation Error", "Please select course.", false);
                return false;
            }

            if (string.IsNullOrWhiteSpace(ddlSession.SelectedValue))
            {
                ShowMessage("Validation Error", "Please select session.", false);
                return false;
            }

            return true;
        }

        private void LoadStudents(bool editMode)
        {
            bool submitted = AttendanceAlreadySubmitted();

            string sql = @"
                SELECT 
                    sd.StudentId,
                    sd.FirstName + ' ' + sd.LastName AS StudentName,
                    ISNULL(a.Status, 'Present') AS Status,
                    @CanEdit AS CanEdit
                FROM Enrollment e
                INNER JOIN StudentDetails sd ON e.StudentId = sd.StudentId
                LEFT JOIN Attendance a
                    ON a.StudentId = sd.StudentId
                   AND a.CourseId = e.CourseId
                   AND a.Session = e.Session
                   AND a.AttendanceDate = @AttendanceDate
                WHERE e.CourseId = @CourseId
                  AND e.Session = @Session
                  AND e.Status = 'Active'
                ORDER BY sd.StudentId";

            string canEdit = (!submitted || editMode) ? "1" : "0";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@AttendanceDate", txtAttendanceDate.Text),
                new SqlParameter("@CanEdit", canEdit)
            });

            rptStudents.DataSource = dt;
            rptStudents.DataBind();

            lblStudentCount.Text = dt.Rows.Count.ToString();
            lblTotalStudents.Text = dt.Rows.Count.ToString();

            pnlAttendanceList.Visible = true;
            pnlEmpty.Visible = dt.Rows.Count == 0;

            hfIsSubmitted.Value = submitted ? "1" : "0";

            btnEditAttendance.Visible = submitted && !editMode;
            btnSubmitAttendance.Visible = !submitted || editMode;
            btnSubmitAttendance.Text = submitted ? "Update Attendance" : "Submit Attendance";
        }

        private bool AttendanceAlreadySubmitted()
        {
            object count = DatabaseHelper.ExecuteScalar(@"
                SELECT COUNT(*)
                FROM Attendance
                WHERE CourseId = @CourseId
                  AND AttendanceDate = @AttendanceDate
                  AND LecturerId = @LecturerId
                  AND Session = @Session",
                new[]
                {
                    new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                    new SqlParameter("@AttendanceDate", txtAttendanceDate.Text),
                    new SqlParameter("@LecturerId", CurrentLecturerId),
                    new SqlParameter("@Session", ddlSession.SelectedValue)
                });

            return Convert.ToInt32(count) > 0;
        }

        protected void btnEditAttendance_Click(object sender, EventArgs e)
        {
            LoadStudents(true);

            ShowMessage(
                "Edit Mode Enabled",
                "You can now edit and update the attendance record.",
                true);
        }

        protected void btnSubmitAttendance_Click(object sender, EventArgs e)
        {
            if (!ValidateFilters())
                return;

            bool wasSubmitted = AttendanceAlreadySubmitted();

            foreach (RepeaterItem item in rptStudents.Items)
            {
                HiddenField hfStudentId = (HiddenField)item.FindControl("hfStudentId");
                CheckBox chkPresent = (CheckBox)item.FindControl("chkPresent");

                string status = chkPresent.Checked ? "Present" : "Absent"; ;

                SaveAttendance(hfStudentId.Value, status);
            }

            LoadStudents(false);

            ShowMessage(
                "Success",
                wasSubmitted ? "Attendance updated successfully." : "Attendance submitted successfully.",
                true);
        }

        private void SaveAttendance(string studentId, string status)
        {
            string sql = @"
                IF EXISTS (
                    SELECT 1
                    FROM Attendance
                    WHERE CourseId = @CourseId
                      AND AttendanceDate = @AttendanceDate
                      AND StudentId = @StudentId
                      AND Session = @Session
                )
                BEGIN
                    UPDATE Attendance
                    SET Status = @Status,
                        LecturerId = @LecturerId
                    WHERE CourseId = @CourseId
                      AND AttendanceDate = @AttendanceDate
                      AND StudentId = @StudentId
                      AND Session = @Session
                END
                ELSE
                BEGIN
                    INSERT INTO Attendance
                    (
                        CourseId,
                        AttendanceDate,
                        StudentId,
                        LecturerId,
                        Session,
                        Status
                    )
                    VALUES
                    (
                        @CourseId,
                        @AttendanceDate,
                        @StudentId,
                        @LecturerId,
                        @Session,
                        @Status
                    )
                END";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                new SqlParameter("@AttendanceDate", txtAttendanceDate.Text),
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@LecturerId", CurrentLecturerId),
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@Status", status)
            });
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

        private void ShowMessage(string title, string message, bool isSuccess)
        {
            lblMessage.Visible = false;

            string safeTitle = HttpUtility.JavaScriptStringEncode(title);
            string safeMessage = HttpUtility.JavaScriptStringEncode(message)
                .Replace("\r\n", "<br/>")
                .Replace("\n", "<br/>");

            string script = string.Format(
                "showMessageModal('{0}', '{1}', {2});",
                safeTitle,
                safeMessage,
                isSuccess.ToString().ToLower());

            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                Guid.NewGuid().ToString(),
                script,
                true);
        }

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}