using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class MyCourses : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                lblDate.Text = DateTime.Now.ToString("dd MMMM yyyy");
                LoadStudentSidebarProfile();
                PopulateSessionDropdown();
                LoadEnrolledCourses();
            }
        }

        private string CurrentStudentId
        {
            get
            {
                string studentId = SessionHelper.GetProfileId(Session);

                if (!string.IsNullOrWhiteSpace(studentId))
                    return studentId;

                // Backward-compatible fallback for older login/session code.
                if (Session["StudentId"] != null && !string.IsNullOrWhiteSpace(Session["StudentId"].ToString()))
                    return Session["StudentId"].ToString();

                if (Session["StudentID"] != null && !string.IsNullOrWhiteSpace(Session["StudentID"].ToString()))
                    return Session["StudentID"].ToString();

                Response.Redirect("~/Login.aspx", true);
                return string.Empty;
            }
        }

        private void LoadStudentSidebarProfile()
        {
            string fullName = SessionHelper.GetFullName(Session);
            lblSidebarName.Text = string.IsNullOrWhiteSpace(fullName) ? "Student" : fullName;

            string studentId = CurrentStudentId;

            string sql = @"
                SELECT ProfilePicture
                FROM StudentDetails
                WHERE StudentId = @StudentId";

            object pic = DatabaseHelper.ExecuteScalar(sql,
                new[] { new SqlParameter("@StudentId", studentId) });

            if (pic != null && pic != DBNull.Value && !string.IsNullOrWhiteSpace(pic.ToString()))
                imgSidebarAvatar.ImageUrl = pic.ToString();
        }

        private void PopulateSessionDropdown()
        {
            ddlFilterSession.Items.Clear();
            ddlFilterSession.Items.Add(new ListItem("All Academic Sessions", ""));

            string sql = @"
                SELECT DISTINCT Session
                FROM Enrollment
                WHERE StudentId = @StudentId
                ORDER BY Session DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql,
                new[] { new SqlParameter("@StudentId", CurrentStudentId) });

            foreach (DataRow row in dt.Rows)
            {
                string session = Convert.ToString(row["Session"]);
                if (!string.IsNullOrWhiteSpace(session) && ddlFilterSession.Items.FindByValue(session) == null)
                    ddlFilterSession.Items.Add(new ListItem(session, session));
            }
        }

        private void LoadEnrolledCourses()
        {
            lblMessage.Visible = false;

            string sql = @"
                SELECT  c.CourseId,
                        c.CourseCode,
                        c.CourseName,
                        c.Credits,
                        e.Session,
                        e.Semester,
                        e.Status
                FROM Enrollment e
                INNER JOIN Courses c ON c.CourseId = e.CourseId
                WHERE e.StudentId = @StudentId
                  AND e.Status IN ('Active', 'Completed', 'Drop Pending', 'Drop Rejected')";

            if (!string.IsNullOrWhiteSpace(ddlFilterSession.SelectedValue))
                sql += " AND e.Session = @Session";

            if (!string.IsNullOrWhiteSpace(ddlFilterSemester.SelectedValue))
                sql += " AND e.Semester = @Semester";

            sql += " ORDER BY e.Session DESC, e.Semester ASC, c.CourseCode ASC";

            var parameters = new System.Collections.Generic.List<SqlParameter>
            {
                new SqlParameter("@StudentId", CurrentStudentId)
            };

            if (!string.IsNullOrWhiteSpace(ddlFilterSession.SelectedValue))
                parameters.Add(new SqlParameter("@Session", ddlFilterSession.SelectedValue));

            if (!string.IsNullOrWhiteSpace(ddlFilterSemester.SelectedValue))
                parameters.Add(new SqlParameter("@Semester", ddlFilterSemester.SelectedValue));

            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(sql, parameters.ToArray());

                lblTotal.Text = dt.Rows.Count.ToString();
                rptCourses.DataSource = dt;
                rptCourses.DataBind();

                rptCourses.Visible = dt.Rows.Count > 0;
                pnlEmpty.Visible = dt.Rows.Count == 0;
            }
            catch (Exception ex)
            {
                rptCourses.Visible = false;
                pnlEmpty.Visible = true;
                lblTotal.Text = "0";
                ShowMessage("Unable to load your courses. " + ex.Message, "alert-danger");
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

        private void ShowMessage(string msg, string cssClass)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "alert " + cssClass;
            lblMessage.Visible = true;
        }

        protected void btnConfirmLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx");
        }
    }
}
