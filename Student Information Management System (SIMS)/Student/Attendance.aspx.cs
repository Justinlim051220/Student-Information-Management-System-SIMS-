using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Student
{
    public partial class Attendance : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Assures only authenticated students view this workspace
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
                LoadStudentMetadata();
                LoadEnrolledCoursesFilter();
                LoadEnrolledSessionsFilter();
                LoadAttendanceRecords();
                CheckNotificationsBadge();
            }
        }

        private string CurrentStudentId
        {
            get
            {
                string studentId = SessionHelper.GetProfileId(Session);
                if (!string.IsNullOrWhiteSpace(studentId))
                    return studentId;

                object result = DatabaseHelper.ExecuteScalar(
                    "SELECT StudentId FROM StudentDetails WHERE UserId = @UserId",
                    new[] { new SqlParameter("@UserId", SessionHelper.GetUserId(Session)) });

                return result == null ? "" : result.ToString();
            }
        }

        private int CurrentUserId
        {
            get { return SessionHelper.GetUserId(Session); }
        }

        private void LoadStudentMetadata()
        {
            string fullName = SessionHelper.GetFullName(Session);
            lblSidebarName.Text = string.IsNullOrWhiteSpace(fullName) ? "Student Account" : fullName;

            // Set avatar initial from full name
            if (!string.IsNullOrWhiteSpace(fullName))
            {
                lblAvatarInitial.Text = fullName.Substring(0, 1).ToUpper();
            }
        }

        private void LoadEnrolledCoursesFilter()
        {
            string sql = @"
                SELECT DISTINCT c.CourseId, c.CourseCode + ' - ' + c.CourseName AS CourseDisplay
                FROM Enrollment e
                INNER JOIN Courses c ON e.CourseId = c.CourseId
                WHERE e.StudentId = @StudentId AND e.Status = 'Active'
                ORDER BY CourseDisplay";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@StudentId", CurrentStudentId) });

            ddlCourse.DataSource = dt;
            ddlCourse.DataTextField = "CourseDisplay";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("All Registered Modules", ""));
        }

        private void LoadEnrolledSessionsFilter()
        {
            string sql = @"
                SELECT DISTINCT Session 
                FROM Enrollment 
                WHERE StudentId = @StudentId AND Status = 'Active'
                ORDER BY Session DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@StudentId", CurrentStudentId) });

            ddlSession.DataSource = dt;
            ddlSession.DataTextField = "Session";
            ddlSession.DataValueField = "Session";
            ddlSession.DataBind();
            ddlSession.Items.Insert(0, new ListItem("All Academic Sessions", ""));
        }

        private void LoadAttendanceRecords()
        {
            string sql = @"
                SELECT a.AttendanceDate, a.Status, a.Session,
                       c.CourseCode + ' - ' + c.CourseName AS CourseDisplay
                FROM Attendance a
                INNER JOIN Courses c ON a.CourseId = c.CourseId
                WHERE a.StudentId = @StudentId
                  AND (@CourseId = '' OR CONVERT(VARCHAR(20), a.CourseId) = @CourseId)
                  AND (@Session = '' OR a.Session = @Session)
                ORDER BY a.AttendanceDate DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@StudentId", CurrentStudentId),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                new SqlParameter("@Session", ddlSession.SelectedValue)
            });

            rptAttendance.DataSource = dt;
            rptAttendance.DataBind();

            pnlEmpty.Visible = (dt.Rows.Count == 0);
            CalculateAttendanceMetrics(dt);
        }

        private void CalculateAttendanceMetrics(DataTable dt)
        {
            int totalSessions = dt.Rows.Count;
            int presentCount = 0;
            int absentCount = 0;

            foreach (DataRow row in dt.Rows)
            {
                if (row["Status"].ToString().Equals("Present", StringComparison.OrdinalIgnoreCase))
                    presentCount++;
                else
                    absentCount++;
            }

            lblPresentCount.Text = presentCount.ToString();
            lblAbsentCount.Text = absentCount.ToString();

            if (totalSessions > 0)
            {
                double percentage = ((double)presentCount / totalSessions) * 100;
                lblAttendancePercentage.Text = string.Format("{0:0.0}%", percentage);
            }
            else
            {
                lblAttendancePercentage.Text = "0.0%";
            }
        }

        private void CheckNotificationsBadge()
        {
            int unreadCount = 0;
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @UserId AND IsRead = 0",
                new[] { new SqlParameter("@UserId", CurrentUserId) });

            if (result != null && int.TryParse(result.ToString(), out unreadCount))
            {
                if (unreadCount > 0)
                {
                    pnlNotifBadge.Visible = true;
                    pnlSidebarNotifBadge.Visible = true;
                }
            }
        }

        protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAttendanceRecords();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadAttendanceRecords();
        }

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}
