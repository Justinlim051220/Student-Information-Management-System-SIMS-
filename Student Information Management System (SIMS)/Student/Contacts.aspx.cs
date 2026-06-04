using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class Student_Contacts : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
                LoadStudentInfo();
                LoadLecturerContacts();
            }
        }

        private int CurrentUserId
        {
            get { return SessionHelper.GetUserId(Session); }
        }

        private string CurrentStudentId
        {
            get { return SessionHelper.GetProfileId(Session); }
        }

        private void LoadStudentInfo()
        {
            string sql = @"
                SELECT FirstName, LastName, ProfilePicture
                FROM StudentDetails
                WHERE UserId = @UserId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@UserId", CurrentUserId)
            });

            if (dt.Rows.Count == 0)
                return;

            DataRow row = dt.Rows[0];
            string fullName = (row["FirstName"] + " " + row["LastName"]).Trim();
            lblSidebarName.Text = string.IsNullOrWhiteSpace(fullName) ? "Student" : fullName;

            string picture = row["ProfilePicture"].ToString();
            imgSidebarAvatar.ImageUrl = string.IsNullOrWhiteSpace(picture)
                ? "~/ProfilePicture/default-profile.png"
                : picture;
        }

        private void LoadLecturerContacts()
        {
            string sql = @"
                SELECT
                    l.LecturerId,
                    l.FirstName + ' ' + l.LastName AS LecturerName,
                    ISNULL(u.Email, '-') AS Email,
                    ISNULL(l.Phone, '-') AS Phone,
                    ISNULL(NULLIF(l.ProfilePicture, ''), '~/ProfilePicture/default-profile.png') AS ProfilePicture,
                    STUFF((
                        SELECT DISTINCT
                            '<span class=""course-tag"">' + c2.CourseCode + ' - ' + c2.CourseName + '</span>'
                        FROM Enrollment e2
                        INNER JOIN Courses c2
                            ON c2.CourseId = e2.CourseId
                        INNER JOIN LecturerCourse lc2
                            ON lc2.CourseId = e2.CourseId
                           AND lc2.Session = e2.Session
                        WHERE e2.StudentId = @StudentId
                          AND e2.Status <> 'Dropped'
                          AND lc2.LecturerId = l.LecturerId
                        FOR XML PATH(''), TYPE
                    ).value('.', 'NVARCHAR(MAX)'), 1, 0, '') AS CourseList
                FROM Enrollment e
                INNER JOIN LecturerCourse lc
                    ON lc.CourseId = e.CourseId
                   AND lc.Session = e.Session
                INNER JOIN LecturerDetails l
                    ON l.LecturerId = lc.LecturerId
                INNER JOIN Users u
                    ON u.UserId = l.UserId
                WHERE e.StudentId = @StudentId
                  AND e.Status <> 'Dropped'
                GROUP BY
                    l.LecturerId,
                    l.FirstName,
                    l.LastName,
                    u.Email,
                    l.Phone,
                    l.ProfilePicture
                ORDER BY l.FirstName, l.LastName";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@StudentId", CurrentStudentId)
            });

            pnlEmpty.Visible = dt.Rows.Count == 0;
            rptLecturerContacts.DataSource = dt;
            rptLecturerContacts.DataBind();
        }

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}
