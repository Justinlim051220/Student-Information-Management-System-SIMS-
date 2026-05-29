using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
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

                hlPostMaterial.NavigateUrl =
                    "CourseMaterials.aspx?courseId=" + courseId +
                    "&session=" + Server.UrlEncode(session);

                hlGrades.NavigateUrl =
                    "CourseGrades.aspx?courseId=" + courseId +
                    "&session=" + Server.UrlEncode(session);
            }
            else
            {
                Response.Redirect("MyCourses.aspx");
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