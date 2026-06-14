using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Lecturer
{
    public partial class AtRiskStudents : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireLecturer(Session, Response);

            if (!IsPostBack)
            {
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadProgrammeFilter();
                LoadCourseFilter();
                LoadSessionFilter();
                LoadRiskStudents();
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
            ddlProgramme.Items.Insert(0, new ListItem("All Programmes", ""));
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
                new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue)
            });

            ddlCourse.DataSource = dt;
            ddlCourse.DataTextField = "CourseDisplay";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("All Courses", ""));
        }

        private void LoadSessionFilter()
        {
            string sql = @"
                SELECT DISTINCT Session
                FROM LecturerCourse
                WHERE LecturerId = @LecturerId
                  AND (@CourseId = '' OR CONVERT(VARCHAR(20), CourseId) = @CourseId)
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
            ddlSession.Items.Insert(0, new ListItem("All Sessions", ""));
        }

        protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourseFilter();
            LoadSessionFilter();
            LoadRiskStudents();
        }

        protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSessionFilter();
            LoadRiskStudents();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadRiskStudents();
        }

        private void LoadRiskStudents()
        {
            string sql = @"
                ;WITH AttendanceSummary AS
                (
                    SELECT
                        a.StudentId,
                        a.CourseId,
                        a.Session,
                        COUNT(*) AS TotalAttendance,
                        SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) AS PresentCount,
                        SUM(CASE WHEN a.Status = 'Absent' THEN 1 ELSE 0 END) AS AbsentCount
                    FROM Attendance a
                    GROUP BY a.StudentId, a.CourseId, a.Session
                ),
                GradeSummary AS
                (
                    SELECT
                        g.StudentId,
                        g.CourseId,
                        AVG(
                            CASE 
                                WHEN g.MarksObtained IS NOT NULL AND g.MaxMarks > 0
                                THEN (g.MarksObtained / g.MaxMarks) * 100
                                ELSE NULL
                            END
                        ) AS AverageMarks
                    FROM Grades g
                    GROUP BY g.StudentId, g.CourseId
                ),
                RiskData AS
                (
                    SELECT
                        sd.StudentId,
                        sd.FirstName + ' ' + sd.LastName AS StudentName,
                        c.CourseId,
                        c.CourseCode + ' - ' + c.CourseName AS CourseDisplay,
                        e.Session,
                        ISNULL(ats.TotalAttendance, 0) AS RollCallCount,
                        ISNULL(ats.PresentCount, 0) AS PresentCount,

                        CAST(
                            ISNULL(
                                CASE 
                                    WHEN ats.TotalAttendance > 0
                                    THEN (ats.PresentCount * 100.0 / ats.TotalAttendance)
                                    ELSE 100
                                END, 100
                            ) AS DECIMAL(5,2)
                        ) AS AttendanceRate,


                        CAST(ISNULL(gs.AverageMarks, 100) AS DECIMAL(5,2)) AS AverageMarks,

                        CASE 
                            WHEN ISNULL(ats.TotalAttendance, 0) >= 14
                                 AND ISNULL(
                                    CASE 
                                        WHEN ats.TotalAttendance > 0
                                        THEN (ats.PresentCount * 100.0 / ats.TotalAttendance)
                                        ELSE 100
                                    END, 100
                                 ) < 80
                            THEN 1 ELSE 0
                        END AS IsAttendanceRisk,

                        CASE 
                            WHEN ISNULL(gs.AverageMarks, 100) < 50
                            THEN 1 ELSE 0
                        END AS IsAcademicRisk
                    FROM Enrollment e
                    INNER JOIN StudentDetails sd ON e.StudentId = sd.StudentId
                    INNER JOIN Courses c ON e.CourseId = c.CourseId
                    INNER JOIN LecturerCourse lc
                        ON lc.CourseId = e.CourseId
                       AND lc.Session = e.Session
                    LEFT JOIN AttendanceSummary ats
                        ON ats.StudentId = e.StudentId
                       AND ats.CourseId = e.CourseId
                       AND ats.Session = e.Session
                    LEFT JOIN GradeSummary gs
                        ON gs.StudentId = e.StudentId
                       AND gs.CourseId = e.CourseId
                    WHERE e.Status = 'Active'
                      AND lc.LecturerId = @LecturerId
                      AND (@ProgrammeId = '' OR CONVERT(VARCHAR(20), c.ProgrammeId) = @ProgrammeId)
                      AND (@CourseId = '' OR CONVERT(VARCHAR(20), c.CourseId) = @CourseId)
                      AND (@Session = '' OR e.Session = @Session)
                      AND (
                            @Search = ''
                            OR sd.StudentId LIKE '%' + @Search + '%'
                            OR sd.FirstName + ' ' + sd.LastName LIKE '%' + @Search + '%'
                          )
                )
                SELECT
                    StudentId,
                    StudentName,
                    CourseDisplay,
                    Session,
                    RollCallCount,
                    PresentCount,
                    AttendanceRate,
                    AverageMarks,
                    IsAttendanceRisk,
                    IsAcademicRisk,
                    (
                        CASE WHEN IsAttendanceRisk = 1 
                            THEN '<span class=""risk-badge risk-high"">Poor Attendance</span>' 
                            ELSE '' END
                        
                        +
                        CASE WHEN IsAcademicRisk = 1 
                            THEN '<span class=""risk-badge risk-high"">Low Marks</span>' 
                            ELSE '' END
                    ) AS RiskReason
                FROM RiskData
                WHERE 
                    (IsAttendanceRisk = 1 OR IsAcademicRisk = 1)
                    AND (
                        @RiskType = ''
                        OR (@RiskType = 'Attendance' AND IsAttendanceRisk = 1)
                        OR (@RiskType = 'Academic' AND IsAcademicRisk = 1)
                    )
                ORDER BY 
                    IsAcademicRisk DESC,
                    IsAttendanceRisk DESC,
                    AttendanceRate ASC,
                    AverageMarks ASC,
                    StudentName ASC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@LecturerId", CurrentLecturerId),
                new SqlParameter("@ProgrammeId", ddlProgramme.SelectedValue),
                new SqlParameter("@CourseId", ddlCourse.SelectedValue),
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@RiskType", ddlRiskType.SelectedValue),
                new SqlParameter("@Search", txtSearch.Text.Trim())
            });

            rptRiskStudents.DataSource = dt;
            rptRiskStudents.DataBind();

            lblTotal.Text = dt.Rows.Count.ToString();
            lblTotalRisk.Text = dt.Rows.Count.ToString();
            pnlEmpty.Visible = dt.Rows.Count == 0;

            int attendanceRisk = 0;
            int academicRisk = 0;

            foreach (DataRow row in dt.Rows)
            {
                if (Convert.ToInt32(row["IsAttendanceRisk"]) == 1)
                    attendanceRisk++;

                if (Convert.ToInt32(row["IsAcademicRisk"]) == 1)
                    academicRisk++;
            }

            lblAttendanceRisk.Text = attendanceRisk.ToString();
            lblAcademicRisk.Text = academicRisk.ToString();
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
    }
}
