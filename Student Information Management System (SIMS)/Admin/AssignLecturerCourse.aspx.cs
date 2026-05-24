using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Admin
{
    public partial class AssignLecturerCourse : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                LoadProgrammes();
                LoadFilterProgrammes();
                LoadLecturersAndCourses();
                LoadStats();
                LoadAssignments();
            }
        }

        private void LoadProgrammes()
        {
            string sql = @"
                SELECT ProgrammeId,
                       ProgrammeCode + ' - ' + ProgrammeName AS ProgrammeDisplay
                FROM Programmes
                ORDER BY ProgrammeName";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);

            ddlProgramme.DataSource = dt;
            ddlProgramme.DataTextField = "ProgrammeDisplay";
            ddlProgramme.DataValueField = "ProgrammeId";
            ddlProgramme.DataBind();
            ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
        }

        private void LoadFilterProgrammes()
        {
            string sql = @"
                SELECT ProgrammeId,
                       ProgrammeCode + ' - ' + ProgrammeName AS ProgrammeDisplay
                FROM Programmes
                ORDER BY ProgrammeName";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);

            ddlFilterProgramme.DataSource = dt;
            ddlFilterProgramme.DataTextField = "ProgrammeDisplay";
            ddlFilterProgramme.DataValueField = "ProgrammeId";
            ddlFilterProgramme.DataBind();
            ddlFilterProgramme.Items.Insert(0, new ListItem("All Programmes", ""));
        }

        private void LoadLecturersAndCourses()
        {
            ddlLecturer.Items.Clear();
            ddlCourse.Items.Clear();
            ddlLecturer.Items.Insert(0, new ListItem("-- Select Lecturer --", ""));
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));

            if (string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue))
                return;

            string lecturerSql = @"
                SELECT DISTINCT ld.LecturerId,
                       ld.LecturerId + ' - ' + ld.FirstName + ' ' + ld.LastName AS LecturerDisplay
                FROM LecturerDetails ld
                INNER JOIN LecturerProgramme lp ON ld.LecturerId = lp.LecturerId
                WHERE lp.ProgrammeId = @ProgrammeId
                ORDER BY LecturerDisplay";

            SqlParameter[] lecturerParams = {
                new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue)
            };

            DataTable lecturers = DatabaseHelper.ExecuteQuery(lecturerSql, lecturerParams);
            ddlLecturer.DataSource = lecturers;
            ddlLecturer.DataTextField = "LecturerDisplay";
            ddlLecturer.DataValueField = "LecturerId";
            ddlLecturer.DataBind();
            ddlLecturer.Items.Insert(0, new ListItem("-- Select Lecturer --", ""));

            string courseSql = @"
                SELECT CourseId,
                       CourseCode + ' - ' + CourseName AS CourseDisplay
                FROM Courses
                WHERE ProgrammeId = @ProgrammeId
                ORDER BY CourseName";

            SqlParameter[] courseParams = {
                new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue)
            };

            DataTable courses = DatabaseHelper.ExecuteQuery(courseSql, courseParams);
            ddlCourse.DataSource = courses;
            ddlCourse.DataTextField = "CourseDisplay";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));
        }

        private void LoadStats()
        {
            lblTotalAssignments.Text = Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM LecturerCourse"));
            lblAssignedLecturers.Text = Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(DISTINCT LecturerId) FROM LecturerCourse"));
        }

        private void LoadAssignments()
        {
            string sql = @"
                SELECT lc.LecturerId,
                       lc.CourseId,
                       lc.Session,
                       lc.Semester,
                       lc.AssignedDate,
                       ld.FirstName + ' ' + ld.LastName AS LecturerName,
                       c.CourseCode,
                       c.CourseName,
                       p.ProgrammeName
                FROM LecturerCourse lc
                INNER JOIN LecturerDetails ld ON lc.LecturerId = ld.LecturerId
                INNER JOIN Courses c ON lc.CourseId = c.CourseId
                INNER JOIN Programmes p ON c.ProgrammeId = p.ProgrammeId
                WHERE 1 = 1";

            var parameters = new System.Collections.Generic.List<SqlParameter>();

            if (!string.IsNullOrWhiteSpace(txtSearch.Text))
            {
                sql += @"
                    AND (
                        lc.LecturerId LIKE @Search OR
                        ld.FirstName + ' ' + ld.LastName LIKE @Search OR
                        c.CourseCode LIKE @Search OR
                        c.CourseName LIKE @Search OR
                        lc.Session LIKE @Search
                    )";
                parameters.Add(new SqlParameter("@Search", "%" + txtSearch.Text.Trim() + "%"));
            }

            if (!string.IsNullOrWhiteSpace(ddlFilterProgramme.SelectedValue))
            {
                sql += " AND c.ProgrammeId = @FilterProgrammeId";
                parameters.Add(new SqlParameter("@FilterProgrammeId", ddlFilterProgramme.SelectedValue));
            }

            sql += " ORDER BY lc.AssignedDate DESC, lc.Session DESC, c.CourseName";

            gvAssignments.DataSource = DatabaseHelper.ExecuteQuery(sql, parameters.ToArray());
            gvAssignments.DataBind();
        }

        protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadLecturersAndCourses();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!ValidateForm())
                return;

            if (!LecturerAndCourseBelongToProgramme())
            {
                ShowModal("error", "Programme Mismatch", "The selected lecturer and course must belong to the selected programme.");
                return;
            }

            bool isEdit = !string.IsNullOrWhiteSpace(hfOriginalLecturerId.Value);

            if (AssignmentExists(isEdit))
            {
                ShowModal("warning", "Duplicate Assignment", "This lecturer is already assigned to this course for the selected session.");
                return;
            }

            if (isEdit)
            {
                UpdateAssignment();
                CreateAssignmentUpdatedNotification();
            }
            else
            {
                InsertAssignment();
                CreateAssignmentCreatedNotification();
            }

            ClearForm();
            LoadStats();
            LoadAssignments();

            ShowModal("success", isEdit ? "Assignment Updated" : "Course Assigned",
                isEdit ? "The lecturer course assignment has been updated successfully." : "The course has been assigned to the lecturer successfully.");
        }

        private bool ValidateForm()
        {
            if (string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue))
            {
                ShowModal("warning", "Missing Programme", "Please select a programme first.");
                return false;
            }

            if (string.IsNullOrWhiteSpace(ddlLecturer.SelectedValue))
            {
                ShowModal("warning", "Missing Lecturer", "Please select a lecturer.");
                return false;
            }

            if (string.IsNullOrWhiteSpace(ddlCourse.SelectedValue))
            {
                ShowModal("warning", "Missing Course", "Please select a course.");
                return false;
            }

            if (string.IsNullOrWhiteSpace(ddlSession.SelectedValue))
            {
                ShowModal("warning", "Missing Session", "Please select a session.");
                return false;
            }

            int semester;
            if (!int.TryParse(txtSemester.Text.Trim(), out semester) || semester < 1)
            {
                ShowModal("warning", "Invalid Semester", "Semester must be a number greater than or equal to 1.");
                return false;
            }

            return true;
        }

        private bool LecturerAndCourseBelongToProgramme()
        {
            string sql = @"
                SELECT COUNT(*)
                FROM LecturerProgramme lp
                INNER JOIN Courses c ON c.ProgrammeId = lp.ProgrammeId
                WHERE lp.LecturerId = @LecturerId
                  AND c.CourseId = @CourseId
                  AND lp.ProgrammeId = @ProgrammeId
                  AND c.ProgrammeId = @ProgrammeId";

            SqlParameter[] p = {
                new SqlParameter("@LecturerId", ddlLecturer.SelectedValue),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue)
            };

            return Convert.ToInt32(DatabaseHelper.ExecuteScalar(sql, p)) > 0;
        }

        private bool AssignmentExists(bool isEdit)
        {
            string sql = @"
                SELECT COUNT(*)
                FROM LecturerCourse
                WHERE LecturerId = @LecturerId
                  AND CourseId = @CourseId
                  AND Session = @Session";

            var parameters = new System.Collections.Generic.List<SqlParameter>
            {
                new SqlParameter("@LecturerId", ddlLecturer.SelectedValue),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                new SqlParameter("@Session", ddlSession.SelectedValue)
            };

            if (isEdit)
            {
                sql += @"
                    AND NOT (
                        LecturerId = @OriginalLecturerId
                        AND CourseId = @OriginalCourseId
                        AND Session = @OriginalSession
                    )";
                parameters.Add(new SqlParameter("@OriginalLecturerId", hfOriginalLecturerId.Value));
                parameters.Add(new SqlParameter("@OriginalCourseId", hfOriginalCourseId.Value));
                parameters.Add(new SqlParameter("@OriginalSession", hfOriginalSession.Value));
            }

            return Convert.ToInt32(DatabaseHelper.ExecuteScalar(sql, parameters.ToArray())) > 0;
        }

        private void InsertAssignment()
        {
            string sql = @"
                INSERT INTO LecturerCourse (LecturerId, CourseId, Session, Semester, AssignedDate)
                VALUES (@LecturerId, @CourseId, @Session, @Semester, GETDATE())";

            SqlParameter[] p = {
                new SqlParameter("@LecturerId", ddlLecturer.SelectedValue),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@Semester", txtSemester.Text.Trim())
            };

            DatabaseHelper.ExecuteNonQuery(sql, p);
        }

        private void CreateAssignmentCreatedNotification()
        {
            string sql = @"
                INSERT INTO Notifications
                (
                    UserId,
                    Title,
                    Message,
                    IsRead,
                    CreatedAt
                )
                SELECT
                    ld.UserId,
                    'New Teaching Assignment',
                    'You have been assigned to a new teaching course.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                    'Programme: ' + p.ProgrammeCode + ' - ' + p.ProgrammeName + CHAR(13) + CHAR(10) +
                    'Course: ' + c.CourseCode + ' - ' + c.CourseName + CHAR(13) + CHAR(10) +
                    'Session: ' + @Session + CHAR(13) + CHAR(10) +
                    'Semester: ' + @Semester + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                    'Please check your Lecturer Portal for more details.',
                    0,
                    GETDATE()
                FROM LecturerDetails ld
                INNER JOIN Courses c ON c.CourseId = @CourseId
                INNER JOIN Programmes p ON p.ProgrammeId = c.ProgrammeId
                WHERE ld.LecturerId = @LecturerId";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", ddlLecturer.SelectedValue),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@Semester", txtSemester.Text.Trim())
                    });
        }
        private void UpdateAssignment()
        {
            string sql = @"
                UPDATE LecturerCourse
                SET LecturerId = @LecturerId,
                    CourseId = @CourseId,
                    Session = @Session,
                    Semester = @Semester
                WHERE LecturerId = @OriginalLecturerId
                  AND CourseId = @OriginalCourseId
                  AND Session = @OriginalSession";

            SqlParameter[] p = {
                new SqlParameter("@LecturerId", ddlLecturer.SelectedValue),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@Semester", txtSemester.Text.Trim()),
                new SqlParameter("@OriginalLecturerId", hfOriginalLecturerId.Value),
                new SqlParameter("@OriginalCourseId", hfOriginalCourseId.Value),
                new SqlParameter("@OriginalSession", hfOriginalSession.Value)
            };

            DatabaseHelper.ExecuteNonQuery(sql, p);
        }

        private void CreateAssignmentUpdatedNotification()
        {
            string sql = @"
                INSERT INTO Notifications
                (
                    UserId,
                    Title,
                    Message,
                    IsRead,
                    CreatedAt
                )
                SELECT
                    ld.UserId,
                    'Teaching Assignment Updated',
                    'Your teaching assignment has been updated by the admin.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                    'Programme: ' + p.ProgrammeCode + ' - ' + p.ProgrammeName + CHAR(13) + CHAR(10) +
                    'Course: ' + c.CourseCode + ' - ' + c.CourseName + CHAR(13) + CHAR(10) +
                    'Session: ' + @Session + CHAR(13) + CHAR(10) +
                    'Semester: ' + @Semester + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                    'Please check your Lecturer Portal for more details.',
                    0,
                    GETDATE()
                FROM LecturerDetails ld
                INNER JOIN Courses c ON c.CourseId = @CourseId
                INNER JOIN Programmes p ON p.ProgrammeId = c.ProgrammeId
                WHERE ld.LecturerId = @LecturerId";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", ddlLecturer.SelectedValue),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@Semester", txtSemester.Text.Trim())
                    });
        }
        protected void gvAssignments_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string[] keys = Convert.ToString(e.CommandArgument).Split('|');
            if (keys.Length != 3)
                return;

            string lecturerId = keys[0];
            string courseId = keys[1];
            string session = keys[2];

            if (e.CommandName == "EditAssignment")
            {
                LoadAssignmentForEdit(lecturerId, courseId, session);
            }
            else if (e.CommandName == "DeleteAssignment")
            {
                CreateAssignmentDeletedNotification(lecturerId, courseId, session);
                DeleteAssignment(lecturerId, courseId, session);
                LoadStats();
                LoadAssignments();
                ClearForm();
                ShowModal("success", "Assignment Deleted", "The lecturer course assignment has been deleted successfully.");
            }
        }

        private void LoadAssignmentForEdit(string lecturerId, string courseId, string session)
        {
            string sql = @"
                SELECT lc.LecturerId,
                       lc.CourseId,
                       lc.Session,
                       lc.Semester,
                       c.ProgrammeId
                FROM LecturerCourse lc
                INNER JOIN Courses c ON lc.CourseId = c.CourseId
                WHERE lc.LecturerId = @LecturerId
                  AND lc.CourseId = @CourseId
                  AND lc.Session = @Session";

            SqlParameter[] p = {
                new SqlParameter("@LecturerId", lecturerId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session)
            };

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, p);
            if (dt.Rows.Count == 0)
            {
                ShowModal("error", "Not Found", "The selected assignment could not be found.");
                return;
            }

            DataRow row = dt.Rows[0];

            hfOriginalLecturerId.Value = lecturerId;
            hfOriginalCourseId.Value = courseId;
            hfOriginalSession.Value = session;

            ddlProgramme.SelectedValue = Convert.ToString(row["ProgrammeId"]);
            LoadLecturersAndCourses();

            ddlLecturer.SelectedValue = lecturerId;
            ddlCourse.SelectedValue = courseId;

            ListItem sessionItem = ddlSession.Items.FindByValue(session);
            if (sessionItem == null)
                ddlSession.Items.Add(new ListItem(session, session));
            ddlSession.SelectedValue = session;

            txtSemester.Text = Convert.ToString(row["Semester"]);
            lblFormTitle.Text = "Edit Course Assignment";
            btnSave.Text = "Update Assignment";

            ShowModal("warning", "Edit Mode", "You are now editing the selected course assignment.");
        }

        private void DeleteAssignment(string lecturerId, string courseId, string session)
        {
            string sql = @"
                DELETE FROM LecturerCourse
                WHERE LecturerId = @LecturerId
                  AND CourseId = @CourseId
                  AND Session = @Session";

            SqlParameter[] p = {
                new SqlParameter("@LecturerId", lecturerId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session)
            };

            DatabaseHelper.ExecuteNonQuery(sql, p);
        }

        private void CreateAssignmentDeletedNotification(string lecturerId, string courseId, string session)
        {
            string sql = @"
                INSERT INTO Notifications
                (
                    UserId,
                    Title,
                    Message,
                    IsRead,
                    CreatedAt
                )
                SELECT
                    ld.UserId,
                    'Teaching Assignment Removed',
                    'One of your teaching assignments has been removed by the admin.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                    'Programme: ' + p.ProgrammeCode + ' - ' + p.ProgrammeName + CHAR(13) + CHAR(10) +
                    'Course: ' + c.CourseCode + ' - ' + c.CourseName + CHAR(13) + CHAR(10) +
                    'Session: ' + @Session + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                    'Please check your Lecturer Portal for more details.',
                    0,
                    GETDATE()
                FROM LecturerDetails ld
                INNER JOIN Courses c ON c.CourseId = @CourseId
                INNER JOIN Programmes p ON p.ProgrammeId = c.ProgrammeId
                WHERE ld.LecturerId = @LecturerId";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", lecturerId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session)
                    });
        }
        protected void gvAssignments_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvAssignments.PageIndex = e.NewPageIndex;
            LoadAssignments();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            gvAssignments.PageIndex = 0;
            LoadAssignments();
        }

        protected void btnResetSearch_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            ddlFilterProgramme.SelectedIndex = 0;
            gvAssignments.PageIndex = 0;
            LoadAssignments();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        private void ClearForm()
        {
            hfOriginalLecturerId.Value = string.Empty;
            hfOriginalCourseId.Value = string.Empty;
            hfOriginalSession.Value = string.Empty;

            ddlProgramme.SelectedIndex = 0;
            ddlSession.SelectedIndex = 0;
            txtSemester.Text = "1";
            lblFormTitle.Text = "New Course Assignment";
            btnSave.Text = "Assign Course";
            LoadLecturersAndCourses();
        }

        private void ShowModal(string type, string title, string message)
        {
            string safeTitle = HttpUtility.JavaScriptStringEncode(title);
            string safeMessage = HttpUtility.JavaScriptStringEncode(message);
            string script = $"showCustomModal('{type}', '{safeTitle}', '{safeMessage}');";
            ClientScript.RegisterStartupScript(this.GetType(), Guid.NewGuid().ToString(), script, true);
        }
    }
}
