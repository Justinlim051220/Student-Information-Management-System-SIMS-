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

            EnsureSortOrderColumn();
            NormalizeSortOrder(studentId);

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

            sql += " ORDER BY ISNULL(e.SortOrder, 999999), e.Session DESC, e.Semester ASC, c.CourseCode ASC";

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

        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string[] parts = Convert.ToString(e.CommandArgument).Split('|');

            if (parts.Length != 3)
                return;

            string courseId = parts[0];
            string session = parts[1];
            string semester = parts[2];

            if (e.CommandName == "MoveTop")
                MoveCourse(courseId, session, semester, "TOP");
            else if (e.CommandName == "MoveUp")
                MoveCourse(courseId, session, semester, "UP");
            else if (e.CommandName == "MoveDown")
                MoveCourse(courseId, session, semester, "DOWN");
            else if (e.CommandName == "MoveBottom")
                MoveCourse(courseId, session, semester, "BOTTOM");

            LoadEnrolledCourses();
        }

        private void MoveCourse(string courseId, string session, string semester, string direction)
        {
            EnsureSortOrderColumn();

            string studentId = SessionHelper.GetProfileId(Session);
            NormalizeSortOrder(studentId);

            int currentSort = GetSortOrder(studentId, courseId, session, semester);

            if (currentSort == -1)
                return;

            if (direction == "TOP")
            {
                if (currentSort == 1)
                    return;

                string sql = @"
                    UPDATE Enrollment
                    SET SortOrder = SortOrder + 1
                    WHERE StudentId = @StudentId
                      AND Status <> 'Dropped'
                      AND SortOrder < @CurrentSort;

                    UPDATE Enrollment
                    SET SortOrder = 1
                    WHERE StudentId = @StudentId
                      AND CourseId = @CourseId
                      AND Session = @Session
                      AND Semester = @Semester
                      AND Status <> 'Dropped';";

                DatabaseHelper.ExecuteNonQuery(sql, new[]
                {
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@Semester", semester),
                    new SqlParameter("@CurrentSort", currentSort)
                });
            }
            else if (direction == "BOTTOM")
            {
                int maxSort = GetMaxSortOrder(studentId);

                if (currentSort == maxSort)
                    return;

                string sql = @"
                    UPDATE Enrollment
                    SET SortOrder = SortOrder - 1
                    WHERE StudentId = @StudentId
                      AND Status <> 'Dropped'
                      AND SortOrder > @CurrentSort;

                    UPDATE Enrollment
                    SET SortOrder = @MaxSort
                    WHERE StudentId = @StudentId
                      AND CourseId = @CourseId
                      AND Session = @Session
                      AND Semester = @Semester
                      AND Status <> 'Dropped';";

                DatabaseHelper.ExecuteNonQuery(sql, new[]
                {
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@Semester", semester),
                    new SqlParameter("@CurrentSort", currentSort),
                    new SqlParameter("@MaxSort", maxSort)
                });
            }
            else if (direction == "UP")
            {
                int targetSort = currentSort - 1;

                if (targetSort < 1)
                    return;

                SwapSortOrder(studentId, courseId, session, semester, currentSort, targetSort);
            }
            else if (direction == "DOWN")
            {
                int maxSort = GetMaxSortOrder(studentId);
                int targetSort = currentSort + 1;

                if (targetSort > maxSort)
                    return;

                SwapSortOrder(studentId, courseId, session, semester, currentSort, targetSort);
            }
        }

        private void EnsureSortOrderColumn()
        {
            string checkSql = @"
                SELECT COUNT(*)
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = 'Enrollment'
                  AND COLUMN_NAME = 'SortOrder'";

            int exists = Convert.ToInt32(DatabaseHelper.ExecuteScalar(checkSql));

            if (exists == 0)
            {
                DatabaseHelper.ExecuteNonQuery(@"
                    ALTER TABLE Enrollment
                    ADD SortOrder INT NULL");
            }
        }

        private void NormalizeSortOrder(string studentId)
        {
            string sql = @"
                ;WITH OrderedCourses AS
                (
                    SELECT
                        EnrollmentId,
                        ROW_NUMBER() OVER
                        (
                            ORDER BY
                                CASE WHEN SortOrder IS NULL THEN 999999 ELSE SortOrder END,
                                Session DESC,
                                Semester ASC,
                                CourseId ASC
                        ) AS NewSortOrder
                    FROM Enrollment
                    WHERE StudentId = @StudentId
                      AND Status <> 'Dropped'
                )
                UPDATE e
                SET SortOrder = oc.NewSortOrder
                FROM Enrollment e
                INNER JOIN OrderedCourses oc
                    ON e.EnrollmentId = oc.EnrollmentId";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId)
            });
        }

        private int GetSortOrder(string studentId, string courseId, string session, string semester)
        {
            object result = DatabaseHelper.ExecuteScalar(@"
                SELECT SortOrder
                FROM Enrollment
                WHERE StudentId = @StudentId
                  AND CourseId = @CourseId
                  AND Session = @Session
                  AND Semester = @Semester
                  AND Status <> 'Dropped'",
                new[]
                {
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@Semester", semester)
                });

            return result == null || result == DBNull.Value ? -1 : Convert.ToInt32(result);
        }

        private int GetMaxSortOrder(string studentId)
        {
            object result = DatabaseHelper.ExecuteScalar(@"
                SELECT ISNULL(MAX(SortOrder), 0)
                FROM Enrollment
                WHERE StudentId = @StudentId
                  AND Status <> 'Dropped'",
                new[] { new SqlParameter("@StudentId", studentId) });

            return result == null ? 0 : Convert.ToInt32(result);
        }

        private void SwapSortOrder(string studentId, string courseId, string session, string semester, int currentSort, int targetSort)
        {
            string sql = @"
                UPDATE Enrollment
                SET SortOrder = @CurrentSort
                WHERE StudentId = @StudentId
                  AND Status <> 'Dropped'
                  AND SortOrder = @TargetSort;

                UPDATE Enrollment
                SET SortOrder = @TargetSort
                WHERE StudentId = @StudentId
                  AND CourseId = @CourseId
                  AND Session = @Session
                  AND Semester = @Semester
                  AND Status <> 'Dropped';";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session),
                new SqlParameter("@Semester", semester),
                new SqlParameter("@CurrentSort", currentSort),
                new SqlParameter("@TargetSort", targetSort)
            });
        }

    }
}