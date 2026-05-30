using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class Student_Enrollment : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                string fullName = SessionHelper.GetFullName(Session);
                string studentId = SessionHelper.GetProfileId(Session);
                string initial = fullName.Length > 0 ? fullName[0].ToString().ToUpper() : "S";

                lblSidebarName.Text = fullName;
                lblAvatarInitial.Text = initial;
                lblProfileInitial.Text = initial;
                lblStudentName.Text = fullName;
                lblStudentId.Text = studentId;
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadStudentInfo(studentId);
                LoadOpenSessions();
                LoadAvailableCourses();
                LoadEnrolledCourses(studentId);
            }
        }

        private void LoadStudentInfo(string studentId)
        {
            string sql = @"
                SELECT s.ProgrammeId,
                       p.ProgrammeCode + ' - ' + p.ProgrammeName AS ProgrammeDisplay,
                       ISNULL(s.CurrentSemester, 1) AS CurrentSemester
                FROM StudentDetails s
                INNER JOIN Programmes p ON p.ProgrammeId = s.ProgrammeId
                WHERE s.StudentId = @StudentId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@StudentId", studentId) });

            if (dt.Rows.Count == 0)
            {
                ShowMessage("Student profile cannot be found.", "error");
                btnEnroll.Enabled = false;
                return;
            }

            DataRow row = dt.Rows[0];
            hfProgrammeId.Value = row["ProgrammeId"].ToString();
            hfSemester.Value = row["CurrentSemester"].ToString();
            lblProgramme.Text = row["ProgrammeDisplay"].ToString();
            lblSemester.Text = row["CurrentSemester"].ToString();
            lblRule.Text = "Programme = " + row["ProgrammeDisplay"] + ", Semester = " + row["CurrentSemester"] + ", Status = Open";
        }

        private void LoadOpenSessions()
        {
            ddlSession.Items.Clear();

            string sql = @"
                SELECT DISTINCT Session
                FROM CourseOffering
                WHERE Status = 'Open'
                ORDER BY Session";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);
            ddlSession.DataSource = dt;
            ddlSession.DataTextField = "Session";
            ddlSession.DataValueField = "Session";
            ddlSession.DataBind();
            ddlSession.Items.Insert(0, new ListItem("-- Select Open Session --", ""));

            lblOpenSessionCount.Text = dt.Rows.Count.ToString();
        }

        protected void ddlSession_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAvailableCourses();
        }

        private void LoadAvailableCourses()
        {
            ddlCourse.Items.Clear();

            if (string.IsNullOrWhiteSpace(ddlSession.SelectedValue) ||
                string.IsNullOrWhiteSpace(hfProgrammeId.Value) ||
                string.IsNullOrWhiteSpace(hfSemester.Value))
            {
                ddlCourse.Items.Insert(0, new ListItem("-- Select Session First --", ""));
                return;
            }

            string studentId = SessionHelper.GetProfileId(Session);

            string sql = @"
                SELECT c.CourseId,
                       c.CourseCode + ' - ' + c.CourseName + ' (' + CAST(c.Credits AS VARCHAR(10)) + ' credit)' AS CourseDisplay
                FROM CourseOffering co
                INNER JOIN Courses c ON c.CourseId = co.CourseId
                WHERE co.Status = 'Open'
                  AND co.Session = @Session
                  AND co.ProgrammeId = @ProgrammeId
                  AND co.Semester = @Semester
                  AND NOT EXISTS (
                      SELECT 1
                      FROM Enrollment e
                      WHERE e.StudentId = @StudentId
                        AND e.CourseId = co.CourseId
                        AND e.Session = co.Session
                        AND e.Status <> 'Dropped'
                  )
                ORDER BY c.CourseCode";

            SqlParameter[] p =
            {
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@ProgrammeId", int.Parse(hfProgrammeId.Value)),
                new SqlParameter("@Semester", int.Parse(hfSemester.Value)),
                new SqlParameter("@StudentId", studentId)
            };

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, p);
            ddlCourse.DataSource = dt;
            ddlCourse.DataTextField = "CourseDisplay";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();

            ddlCourse.Items.Insert(0, dt.Rows.Count == 0
                ? new ListItem("-- No Available Course --", "")
                : new ListItem("-- Select Course --", ""));
        }

        protected void btnEnroll_Click(object sender, EventArgs e)
        {
            string studentId = SessionHelper.GetProfileId(Session);

            if (string.IsNullOrWhiteSpace(ddlSession.SelectedValue))
            {
                ShowMessage("Please select an open session.", "error");
                return;
            }

            if (string.IsNullOrWhiteSpace(ddlCourse.SelectedValue))
            {
                ShowMessage("Please select an available course.", "error");
                return;
            }

            int courseId = int.Parse(ddlCourse.SelectedValue);
            string session = ddlSession.SelectedValue;
            int semester = int.Parse(hfSemester.Value);
            int programmeId = int.Parse(hfProgrammeId.Value);

            if (!IsOfferingOpen(courseId, session, programmeId, semester))
            {
                ShowMessage("This course is not open for your programme, semester, or session.", "error");
                LoadAvailableCourses();
                return;
            }

            if (AlreadyEnrolled(studentId, courseId, session))
            {
                ShowMessage("You already enrolled in this course for the selected session.", "error");
                LoadAvailableCourses();
                return;
            }

            string sql = @"
                INSERT INTO Enrollment (StudentId, CourseId, Session, Semester, Status, EnrollmentDate)
                VALUES (@StudentId, @CourseId, @Session, @Semester, 'Active', GETDATE())";

            SqlParameter[] p =
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session),
                new SqlParameter("@Semester", semester)
            };

            DatabaseHelper.ExecuteNonQuery(sql, p);
            ShowMessage("Course enrolled successfully.", "success");
            LoadAvailableCourses();
            LoadEnrolledCourses(studentId);
        }

        private bool IsOfferingOpen(int courseId, string session, int programmeId, int semester)
        {
            string sql = @"
                SELECT COUNT(*)
                FROM CourseOffering
                WHERE CourseId = @CourseId
                  AND Session = @Session
                  AND ProgrammeId = @ProgrammeId
                  AND Semester = @Semester
                  AND Status = 'Open'";

            object result = DatabaseHelper.ExecuteScalar(sql, new[]
            {
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session),
                new SqlParameter("@ProgrammeId", programmeId),
                new SqlParameter("@Semester", semester)
            });

            return result != null && Convert.ToInt32(result) > 0;
        }

        private bool AlreadyEnrolled(string studentId, int courseId, string session)
        {
            string sql = @"
                SELECT COUNT(*)
                FROM Enrollment
                WHERE StudentId = @StudentId
                  AND CourseId = @CourseId
                  AND Session = @Session
                  AND Status <> 'Dropped'";

            object result = DatabaseHelper.ExecuteScalar(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session)
            });

            return result != null && Convert.ToInt32(result) > 0;
        }

        private void LoadEnrolledCourses(string studentId)
        {
            string sql = @"
                SELECT c.CourseCode, c.CourseName, c.Credits, e.Session, e.Semester, e.Status, e.EnrollmentDate
                FROM Enrollment e
                INNER JOIN Courses c ON c.CourseId = e.CourseId
                WHERE e.StudentId = @StudentId
                  AND e.Status <> 'Dropped'
                ORDER BY e.EnrollmentDate DESC, c.CourseCode";

            gvEnrolled.DataSource = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@StudentId", studentId) });
            gvEnrolled.DataBind();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadOpenSessions();
            LoadAvailableCourses();
            LoadEnrolledCourses(SessionHelper.GetProfileId(Session));
            ShowMessage("Enrollment list refreshed.", "info");
        }

        private void ShowMessage(string message, string type)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = "alert-box " + type;
        }

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}
