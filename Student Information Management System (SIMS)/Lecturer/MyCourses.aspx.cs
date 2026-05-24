using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Lecturer
{
    public partial class MyCourses : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireLecturer(Session, Response);

            if (!IsPostBack)
            {
                LoadLecturerInfo();
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadProgrammeFilter();
                LoadCourseFilter();
                LoadSessionFilter();
                LoadCourses();
                CheckUnreadNotifications();
            }
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
                    new[] { new SqlParameter("@UserId", SessionHelper.GetUserId(Session)) });

                return result == null ? "" : result.ToString();
            }
        }

        private int CurrentUserId
        {
            get { return SessionHelper.GetUserId(Session); }
        }

        private void LoadLecturerInfo()
        {
            string fullName = SessionHelper.GetFullName(Session);

            lblSidebarName.Text = string.IsNullOrWhiteSpace(fullName)
                ? "Lecturer"
                : fullName;

            lblAvatarInitial.Text = string.IsNullOrWhiteSpace(fullName)
                ? "L"
                : fullName.Substring(0, 1).ToUpper();
        }

        private void LoadCourseFilter()
        {
            string sql = @"
                SELECT DISTINCT
                    c.CourseId,
                    c.CourseCode + ' - ' + c.CourseName AS CourseDisplay
                FROM LecturerCourse lc
                INNER JOIN Courses c ON lc.CourseId = c.CourseId
                WHERE lc.LecturerId = @LecturerId
                  AND (@ProgrammeId = '' OR CONVERT(VARCHAR(20), c.ProgrammeId) = @ProgrammeId)
                ORDER BY CourseDisplay";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId),
                new SqlParameter("@ProgrammeId", ddlFilterProgramme.SelectedValue)
            });

            ddlFilterCourse.DataSource = dt;
            ddlFilterCourse.DataTextField = "CourseDisplay";
            ddlFilterCourse.DataValueField = "CourseId";
            ddlFilterCourse.DataBind();
            ddlFilterCourse.Items.Insert(0, new ListItem("All Courses", ""));
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

            ddlFilterProgramme.DataSource = dt;
            ddlFilterProgramme.DataTextField = "ProgrammeDisplay";
            ddlFilterProgramme.DataValueField = "ProgrammeId";
            ddlFilterProgramme.DataBind();
            ddlFilterProgramme.Items.Insert(0, new ListItem("All Programmes", ""));
        }
        private void LoadSessionFilter()
        {
            string sql = @"
                SELECT DISTINCT Session
                FROM LecturerCourse
                WHERE LecturerId = @LecturerId
                ORDER BY Session DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId)
            });

            ddlFilterSession.DataSource = dt;
            ddlFilterSession.DataTextField = "Session";
            ddlFilterSession.DataValueField = "Session";
            ddlFilterSession.DataBind();
            ddlFilterSession.Items.Insert(0, new ListItem("All Sessions", ""));
        }

        private void LoadCourses()
        {
            string sql = @"
                SELECT 
                    c.CourseId,
                    c.CourseCode,
                    c.CourseName,
                    lc.Session,
                    lc.Semester,
                    ISNULL(c.CourseImage, '~/Images/default-course.png') AS CourseImage
                FROM LecturerCourse lc
                INNER JOIN Courses c ON lc.CourseId = c.CourseId
                WHERE lc.LecturerId = @LecturerId
                  AND (@ProgrammeId = '' OR CONVERT(VARCHAR(20), c.ProgrammeId) = @ProgrammeId)
                  AND (@CourseId = '' OR CONVERT(VARCHAR(20), c.CourseId) = @CourseId)
                  AND (@Session = '' OR lc.Session = @Session)
                ORDER BY ISNULL(lc.SortOrder, 999999), lc.AssignedDate DESC, c.CourseName ASC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId),
                new SqlParameter("@ProgrammeId", ddlFilterProgramme.SelectedValue),
                new SqlParameter("@CourseId", ddlFilterCourse.SelectedValue),
                new SqlParameter("@Session", ddlFilterSession.SelectedValue)
            });

            rptCourses.DataSource = dt;
            rptCourses.DataBind();

            lblTotal.Text = dt.Rows.Count.ToString();
            pnlEmpty.Visible = dt.Rows.Count == 0;
        }

        protected void ddlFilterProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourseFilter();
            LoadCourses();
        }

        protected void ddlFilterCourse_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourses();
        }

        protected void ddlFilterSession_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourses();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadCourses();
        }

        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string[] parts = Convert.ToString(e.CommandArgument).Split('|');

            if (parts.Length != 2)
                return;

            string courseId = parts[0];
            string session = parts[1];

            if (e.CommandName == "MoveTop")
            {
                MoveCourse(courseId, session, "TOP");
            }
            else if (e.CommandName == "MoveUp")
            {
                MoveCourse(courseId, session, "UP");
            }
            else if (e.CommandName == "MoveDown")
            {
                MoveCourse(courseId, session, "DOWN");
            }
            else if (e.CommandName == "MoveBottom")
            {
                MoveCourse(courseId, session, "BOTTOM");
            }

            LoadCourses();
        }

        private void MoveCourse(string courseId, string session, string direction)
        {
            // Your LecturerCourse table currently has no SortOrder column.
            // So this part needs SortOrder to save custom ordering.
            EnsureSortOrderColumn();

            string lecturerId = CurrentLecturerId;

            NormalizeSortOrder(lecturerId);

            int currentSort = GetSortOrder(lecturerId, courseId, session);

            if (currentSort == -1)
                return;

            if (direction == "TOP")
            {
                DatabaseHelper.ExecuteNonQuery(@"
                    UPDATE LecturerCourse
                    SET SortOrder = SortOrder + 1
                    WHERE LecturerId = @LecturerId
                      AND SortOrder < @CurrentSort;

                    UPDATE LecturerCourse
                    SET SortOrder = 1
                    WHERE LecturerId = @LecturerId
                      AND CourseId = @CourseId
                      AND Session = @Session;",
                    new[]
                    {
                        new SqlParameter("@LecturerId", lecturerId),
                        new SqlParameter("@CourseId", courseId),
                        new SqlParameter("@Session", session),
                        new SqlParameter("@CurrentSort", currentSort)
                    });
            }
            else if (direction == "BOTTOM")
            {
                int maxSort = GetMaxSortOrder(lecturerId);

                DatabaseHelper.ExecuteNonQuery(@"
                    UPDATE LecturerCourse
                    SET SortOrder = SortOrder - 1
                    WHERE LecturerId = @LecturerId
                      AND SortOrder > @CurrentSort;

                    UPDATE LecturerCourse
                    SET SortOrder = @MaxSort
                    WHERE LecturerId = @LecturerId
                      AND CourseId = @CourseId
                      AND Session = @Session;",
                    new[]
                    {
                        new SqlParameter("@LecturerId", lecturerId),
                        new SqlParameter("@CourseId", courseId),
                        new SqlParameter("@Session", session),
                        new SqlParameter("@CurrentSort", currentSort),
                        new SqlParameter("@MaxSort", maxSort)
                    });
            }
            else if (direction == "UP")
            {
                int targetSort = currentSort - 1;

                if (targetSort < 1)
                    return;

                SwapSortOrder(lecturerId, courseId, session, currentSort, targetSort);
            }
            else if (direction == "DOWN")
            {
                int maxSort = GetMaxSortOrder(lecturerId);
                int targetSort = currentSort + 1;

                if (targetSort > maxSort)
                    return;

                SwapSortOrder(lecturerId, courseId, session, currentSort, targetSort);
            }
        }

        private void EnsureSortOrderColumn()
        {
            string checkSql = @"
                SELECT COUNT(*)
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = 'LecturerCourse'
                  AND COLUMN_NAME = 'SortOrder'";

            int exists = Convert.ToInt32(DatabaseHelper.ExecuteScalar(checkSql));

            if (exists == 0)
            {
                string alterSql = @"
                    ALTER TABLE LecturerCourse
                    ADD SortOrder INT NULL";

                DatabaseHelper.ExecuteNonQuery(alterSql);
            }
        }

        private void NormalizeSortOrder(string lecturerId)
        {
            string sql = @"
                ;WITH OrderedCourses AS
                (
                    SELECT 
                        LecturerId,
                        CourseId,
                        Session,
                        ROW_NUMBER() OVER
                        (
                            ORDER BY 
                                CASE WHEN SortOrder IS NULL THEN 999999 ELSE SortOrder END,
                                AssignedDate DESC,
                                CourseId ASC
                        ) AS NewSortOrder
                    FROM LecturerCourse
                    WHERE LecturerId = @LecturerId
                )
                UPDATE lc
                SET SortOrder = oc.NewSortOrder
                FROM LecturerCourse lc
                INNER JOIN OrderedCourses oc
                    ON lc.LecturerId = oc.LecturerId
                   AND lc.CourseId = oc.CourseId
                   AND lc.Session = oc.Session";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", lecturerId)
            });
        }

        private int GetSortOrder(string lecturerId, string courseId, string session)
        {
            object result = DatabaseHelper.ExecuteScalar(@"
                SELECT SortOrder
                FROM LecturerCourse
                WHERE LecturerId = @LecturerId
                  AND CourseId = @CourseId
                  AND Session = @Session",
                new[]
                {
                    new SqlParameter("@LecturerId", lecturerId),
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session)
                });

            return result == null || result == DBNull.Value ? -1 : Convert.ToInt32(result);
        }

        private int GetMaxSortOrder(string lecturerId)
        {
            object result = DatabaseHelper.ExecuteScalar(@"
                SELECT ISNULL(MAX(SortOrder), 0)
                FROM LecturerCourse
                WHERE LecturerId = @LecturerId",
                new[] { new SqlParameter("@LecturerId", lecturerId) });

            return result == null ? 0 : Convert.ToInt32(result);
        }

        private void SwapSortOrder(string lecturerId, string courseId, string session, int currentSort, int targetSort)
        {
            string sql = @"
                UPDATE LecturerCourse
                SET SortOrder = @CurrentSort
                WHERE LecturerId = @LecturerId
                  AND SortOrder = @TargetSort;

                UPDATE LecturerCourse
                SET SortOrder = @TargetSort
                WHERE LecturerId = @LecturerId
                  AND CourseId = @CourseId
                  AND Session = @Session;";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", lecturerId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session),
                new SqlParameter("@CurrentSort", currentSort),
                new SqlParameter("@TargetSort", targetSort)
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

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}