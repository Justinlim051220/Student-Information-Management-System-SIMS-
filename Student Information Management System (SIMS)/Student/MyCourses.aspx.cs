using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Student
{
    public partial class MyCourses : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadFilters();
                LoadEnrolledCourses();
                CheckUnreadNotifications();
            }
        }

        private void CheckUnreadNotifications()
        {
            int userId = SessionHelper.GetUserId(Session);

            object count = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @Uid AND IsRead = 0",
                new[] { new SqlParameter("@Uid", userId) });

            bool hasUnread = count != null && count != DBNull.Value && Convert.ToInt32(count) > 0;
            pnlNotifBadge.Visible = hasUnread;
        }

        private void LoadFilters()
        {
            ddlFilterSession.Items.Clear();
            ddlFilterSession.Items.Add(new ListItem("All Sessions", ""));

            ddlFilterSemester.Items.Clear();
            ddlFilterSemester.Items.Add(new ListItem("All Semesters", ""));

            try
            {
                string studentId = SessionHelper.GetProfileId(Session);

                string sessionSql = @"
                    SELECT DISTINCT Session
                    FROM Enrollment
                    WHERE StudentId = @StudentId
                    ORDER BY Session DESC";

                DataTable sessionDt = DatabaseHelper.ExecuteQuery(
                    sessionSql,
                    new[] { new SqlParameter("@StudentId", studentId) });

                foreach (DataRow row in sessionDt.Rows)
                {
                    ddlFilterSession.Items.Add(new ListItem(row["Session"].ToString(), row["Session"].ToString()));
                }

                string semesterSql = @"
                    SELECT DISTINCT Semester
                    FROM Enrollment
                    WHERE StudentId = @StudentId
                    ORDER BY Semester";

                DataTable semesterDt = DatabaseHelper.ExecuteQuery(
                    semesterSql,
                    new[] { new SqlParameter("@StudentId", studentId) });

                foreach (DataRow row in semesterDt.Rows)
                {
                    string semester = row["Semester"].ToString();
                    ddlFilterSemester.Items.Add(new ListItem("Semester " + semester, semester));
                }
            }
            catch
            {
                lblMessage.Text = "Unable to load course filters.";
                lblMessage.Visible = true;
            }
        }

        private void LoadEnrolledCourses()
        {
            string studentId = SessionHelper.GetProfileId(Session);

            string sql = @"
                SELECT
                    c.CourseId,
                    c.CourseCode,
                    c.CourseName,
                    e.Session,
                    e.Semester
                FROM Enrollment e
                INNER JOIN Courses c ON c.CourseId = e.CourseId
                WHERE e.StudentId = @StudentId
                  AND e.Status <> 'Dropped'";

            if (!string.IsNullOrEmpty(ddlFilterSession.SelectedValue))
                sql += " AND e.Session = @Session";

            if (!string.IsNullOrEmpty(ddlFilterSemester.SelectedValue))
                sql += " AND e.Semester = @Semester";

            sql += " ORDER BY e.Session DESC, e.Semester ASC, c.CourseCode ASC";

            var parameters = new System.Collections.Generic.List<SqlParameter>
            {
                new SqlParameter("@StudentId", studentId)
            };

            if (!string.IsNullOrEmpty(ddlFilterSession.SelectedValue))
                parameters.Add(new SqlParameter("@Session", ddlFilterSession.SelectedValue));

            if (!string.IsNullOrEmpty(ddlFilterSemester.SelectedValue))
                parameters.Add(new SqlParameter("@Semester", ddlFilterSemester.SelectedValue));

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, parameters.ToArray());

            if (dt.Rows.Count > 0)
            {
                rptCourses.DataSource = dt;
                rptCourses.DataBind();

                rptCourses.Visible = true;
                pnlEmpty.Visible = false;

                lblTotal.Text = dt.Rows.Count.ToString();
            }
            else
            {
                rptCourses.DataSource = null;
                rptCourses.DataBind();

                rptCourses.Visible = false;
                pnlEmpty.Visible = true;

                lblTotal.Text = "0";
            }
        }

        protected void ddlFilterSession_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadEnrolledCourses();
        }

        protected void ddlFilterSemester_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadEnrolledCourses();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadEnrolledCourses();
        }
    }
}