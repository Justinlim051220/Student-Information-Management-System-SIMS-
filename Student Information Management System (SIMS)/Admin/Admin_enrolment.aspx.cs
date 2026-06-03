using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Admin
{
    public partial class Admin_enrolment : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                LoadProgrammes();
                LoadFilterProgrammes();
                LoadSessions();
                LoadStats();
                LoadStudents();
                LoadCourses();
                LoadSummary();
            }
        }

        private void LoadProgrammes()
        {
            string sql = @"
                SELECT ProgrammeId, ProgrammeCode + ' - ' + ProgrammeName AS ProgrammeDisplay
                FROM Programmes
                ORDER BY ProgrammeName";

            ddlProgramme.DataSource = DatabaseHelper.ExecuteQuery(sql);
            ddlProgramme.DataTextField = "ProgrammeDisplay";
            ddlProgramme.DataValueField = "ProgrammeId";
            ddlProgramme.DataBind();
            ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
        }

        private void LoadFilterProgrammes()
        {
            string sql = @"
                SELECT ProgrammeId, ProgrammeCode + ' - ' + ProgrammeName AS ProgrammeDisplay
                FROM Programmes
                ORDER BY ProgrammeName";

            ddlFilterProgramme.DataSource = DatabaseHelper.ExecuteQuery(sql);
            ddlFilterProgramme.DataTextField = "ProgrammeDisplay";
            ddlFilterProgramme.DataValueField = "ProgrammeId";
            ddlFilterProgramme.DataBind();
            ddlFilterProgramme.Items.Insert(0, new ListItem("-- All Programmes --", ""));
        }

        private void LoadStudents()
        {
            ddlStudent.Items.Clear();
            ddlStudent.Items.Insert(0, new ListItem("-- Select Student --", ""));

            if (string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue)) return;

            string sql = @"
                SELECT StudentId,
                       StudentId + ' - ' + FirstName + ' ' + LastName AS StudentDisplay
                FROM StudentDetails
                WHERE ProgrammeId = @ProgrammeId
                ORDER BY FirstName, LastName";

            SqlParameter[] p = { new SqlParameter("@ProgrammeId", int.Parse(ddlProgramme.SelectedValue)) };
            ddlStudent.DataSource = DatabaseHelper.ExecuteQuery(sql, p);
            ddlStudent.DataTextField = "StudentDisplay";
            ddlStudent.DataValueField = "StudentId";
            ddlStudent.DataBind();
            ddlStudent.Items.Insert(0, new ListItem("-- Select Student --", ""));
        }

        private void LoadCourses()
        {
            cblCourses.Items.Clear();

            if (string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue)) return;

            string sql = @"
                SELECT c.CourseId,
                       c.CourseCode + ' - ' + c.CourseName + ' | RM ' +
                       CONVERT(VARCHAR(20), CAST(ISNULL(cf.Amount, 0) AS DECIMAL(10,2))) AS CourseDisplay
                FROM Courses c
                LEFT JOIN CourseFees cf
                       ON c.CourseId = cf.CourseId
                      AND cf.Session = @Session
                WHERE c.ProgrammeId = @ProgrammeId
                ORDER BY c.CourseCode";

            SqlParameter[] p =
            {
                new SqlParameter("@ProgrammeId", int.Parse(ddlProgramme.SelectedValue)),
                new SqlParameter("@Session", ddlSession.SelectedValue)
            };

            cblCourses.DataSource = DatabaseHelper.ExecuteQuery(sql, p);
            cblCourses.DataTextField = "CourseDisplay";
            cblCourses.DataValueField = "CourseId";
            cblCourses.DataBind();
        }

        private void LoadStats()
        {
            object totalEnrollments = DatabaseHelper.ExecuteScalar("SELECT COUNT(DISTINCT StudentId) FROM Enrollment WHERE Status = 'Active'");
            object pendingFees = DatabaseHelper.ExecuteScalar("SELECT ISNULL(SUM(Amount), 0) FROM Fees WHERE Status = 'Pending'");

            lblTotalEnrollments.Text = totalEnrollments?.ToString() ?? "0";
            lblPendingFees.Text = Convert.ToDecimal(pendingFees).ToString("N2");
        }

        private void LoadSummary()
        {
            string sql = @"
                ;WITH ActiveGrouped AS
                (
                    SELECT
                        e.StudentId,
                        s.FirstName + ' ' + s.LastName AS StudentName,
                        p.ProgrammeCode,
                        e.Session,
                        e.Semester,
                        CAST(NULL AS INT) AS CourseId,
                        COUNT(e.CourseId) AS CourseCount,
                        SUM(ISNULL(cf.Amount, 0)) AS TotalAmount,
                        'Active' AS Status,
                        STUFF((
                            SELECT
                                '<div class=''course-line''>' +
                                '<span class=''course-code''>' + c2.CourseCode + '</span>' +
                                '<span class=''course-name''>' + c2.CourseName + '</span>' +
                                '<span class=''course-fee''>RM ' +
                                CONVERT(VARCHAR(20), CAST(ISNULL(cf2.Amount, 0) AS DECIMAL(10,2))) +
                                '</span></div>'
                            FROM Enrollment e2
                            INNER JOIN Courses c2 ON e2.CourseId = c2.CourseId
                            LEFT JOIN CourseFees cf2
                                   ON e2.CourseId = cf2.CourseId
                                  AND e2.Session = cf2.Session
                            WHERE e2.StudentId = e.StudentId
                              AND e2.Session = e.Session
                              AND e2.Semester = e.Semester
                              AND e2.Status = 'Active'
                            ORDER BY c2.CourseCode
                            FOR XML PATH(''), TYPE
                        ).value('.', 'NVARCHAR(MAX)'), 1, 0, '') AS CourseList,
                        MAX(e.EnrollmentDate) AS SortDate
                    FROM Enrollment e
                    INNER JOIN StudentDetails s ON e.StudentId = s.StudentId
                    INNER JOIN Programmes p ON s.ProgrammeId = p.ProgrammeId
                    LEFT JOIN CourseFees cf ON e.CourseId = cf.CourseId AND e.Session = cf.Session
                    WHERE e.Status = 'Active'
                      AND (@ProgrammeId = '' OR CONVERT(VARCHAR(20), s.ProgrammeId) = @ProgrammeId)
                      AND (@Status = '' OR e.Status = @Status)
                    GROUP BY e.StudentId, s.FirstName, s.LastName, p.ProgrammeCode, e.Session, e.Semester
                ),
                NonActiveSingle AS
                (
                    SELECT
                        e.StudentId,
                        s.FirstName + ' ' + s.LastName AS StudentName,
                        p.ProgrammeCode,
                        e.Session,
                        e.Semester,
                        e.CourseId,
                        1 AS CourseCount,
                        ISNULL(cf.Amount, 0) AS TotalAmount,
                        e.Status,
                        '<div class=''course-line''>' +
                        '<span class=''course-code''>' + c.CourseCode + '</span>' +
                        '<span class=''course-name''>' + c.CourseName + '</span>' +
                        '<span class=''course-fee''>RM ' +
                        CONVERT(VARCHAR(20), CAST(ISNULL(cf.Amount, 0) AS DECIMAL(10,2))) +
                        '</span></div>' AS CourseList,
                        e.EnrollmentDate AS SortDate
                    FROM Enrollment e
                    INNER JOIN StudentDetails s ON e.StudentId = s.StudentId
                    INNER JOIN Programmes p ON s.ProgrammeId = p.ProgrammeId
                    INNER JOIN Courses c ON e.CourseId = c.CourseId
                    LEFT JOIN CourseFees cf ON e.CourseId = cf.CourseId AND e.Session = cf.Session
                    WHERE e.Status <> 'Active'
                      AND (@ProgrammeId = '' OR CONVERT(VARCHAR(20), s.ProgrammeId) = @ProgrammeId)
                      AND (@Status = '' OR e.Status = @Status)
                )
                SELECT *
                FROM ActiveGrouped
                UNION ALL
                SELECT *
                FROM NonActiveSingle
                ORDER BY SortDate DESC, StudentId, Session, Semester, Status";

            SqlParameter[] p =
            {
                new SqlParameter("@ProgrammeId", ddlFilterProgramme.SelectedValue ?? ""),
                new SqlParameter("@Status", ddlFilterStatus.SelectedValue ?? "")
            };

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, p);
            gvSummary.DataSource = dt;
            gvSummary.DataBind();
        }
        protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadStudents();
            LoadCourses();
            LoadSummary();
        }

        protected void ddlStudent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSummary();
        }

        private void LoadSessions()
        {
            ddlSession.Items.Clear();
            ddlSession.Items.Add(new ListItem("-- Select Session --", ""));
            ddlSession.Items.Add(new ListItem("April 2026", "April 2026"));
            ddlSession.Items.Add(new ListItem("August 2026", "August 2026"));
            ddlSession.Items.Add(new ListItem("January 2027", "January 2027"));
            ddlSession.Items.Add(new ListItem("April 2027", "April 2027"));
            ddlSession.Items.Add(new ListItem("August 2027", "August 2027"));
        }

        protected void ddlSession_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourses();
            LoadSummary();
        }

        protected void btnEnroll_Click(object sender, EventArgs e)
        {
            if (!ValidateForm()) return;

            string duplicateMessage;
            if (HasActiveOrPendingSelectedCourse(out duplicateMessage))
            {
                ShowMessage("Warning", duplicateMessage);
                return;
            }

            try
            {
                int inserted = 0;
                int reactivated = 0;

                foreach (ListItem item in cblCourses.Items)
                {
                    if (!item.Selected) continue;

                    string result = SaveOrReactivateEnrollment(
                        ddlStudent.SelectedValue,
                        int.Parse(item.Value),
                        ddlSession.SelectedValue,
                        int.Parse(txtSemester.Text.Trim())
                    );

                    if (result == "Inserted") inserted++;
                    else if (result == "Reactivated") reactivated++;
                }

                UpdateStudentTuitionFee(ddlStudent.SelectedValue, ddlSession.SelectedValue);
                LoadStats();
                LoadCourses();
                LoadSummary();

                ShowMessage("Success", "Enrolment updated successfully. New: " + inserted + ", Reactivated: " + reactivated + ". Tuition fee has been sent to Manage Fees as Pending.");
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Error: " + ex.Message);
            }
        }

        private bool ValidateForm()
        {
            if (string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue) ||
                string.IsNullOrWhiteSpace(ddlStudent.SelectedValue) ||
                string.IsNullOrWhiteSpace(ddlSession.SelectedValue) ||
                string.IsNullOrWhiteSpace(txtSemester.Text))
            {
                ShowMessage("Warning", "Please select programme, student, session, and semester.");
                return false;
            }

            int semester;
            if (!int.TryParse(txtSemester.Text.Trim(), out semester) || semester < 1)
            {
                ShowMessage("Warning", "Semester must be a positive number.");
                return false;
            }

            bool hasCourse = false;
            foreach (ListItem item in cblCourses.Items)
            {
                if (item.Selected)
                {
                    hasCourse = true;
                    break;
                }
            }

            if (!hasCourse)
            {
                ShowMessage("Warning", "Please select at least one course.");
                return false;
            }

            return true;
        }


        private bool HasActiveOrPendingSelectedCourse(out string message)
        {
            message = "";
            string blockedCourses = "";

            foreach (ListItem item in cblCourses.Items)
            {
                if (!item.Selected) continue;

                string sql = @"
                    SELECT TOP 1 c.CourseCode + ' - ' + c.CourseName + ' (' + e.Status + ')' AS CourseInfo
                    FROM Enrollment e
                    INNER JOIN Courses c ON e.CourseId = c.CourseId
                    WHERE e.StudentId = @StudentId
                      AND e.CourseId = @CourseId
                      AND e.Session = @Session
                      AND e.Status IN ('Active', 'Drop Pending')";

                SqlParameter[] p =
                {
                    new SqlParameter("@StudentId", ddlStudent.SelectedValue),
                    new SqlParameter("@CourseId", int.Parse(item.Value)),
                    new SqlParameter("@Session", ddlSession.SelectedValue)
                };

                object result = DatabaseHelper.ExecuteScalar(sql, p);
                if (result != null && result != DBNull.Value)
                {
                    blockedCourses += "<br/>• " + result.ToString();
                }
            }

            if (!string.IsNullOrWhiteSpace(blockedCourses))
            {
                message = "The selected course list contains course(s) that are already enrolled or waiting for drop approval:" + blockedCourses + "<br/><br/>Please untick these course(s) before enrolling.";
                return true;
            }

            return false;
        }

        private string SaveOrReactivateEnrollment(string studentId, int courseId, string session, int semester)
        {
            string statusSql = @"
                SELECT Status
                FROM Enrollment
                WHERE StudentId = @StudentId
                  AND CourseId = @CourseId
                  AND Session = @Session";

            SqlParameter[] statusParams =
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session)
            };

            object statusObj = DatabaseHelper.ExecuteScalar(statusSql, statusParams);

            if (statusObj == null || statusObj == DBNull.Value)
            {
                string insertSql = @"
                    INSERT INTO Enrollment (StudentId, CourseId, Session, Semester, Status, EnrollmentDate)
                    VALUES (@StudentId, @CourseId, @Session, @Semester, 'Active', GETDATE())";

                SqlParameter[] insertParams =
                {
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@Semester", semester)
                };

                DatabaseHelper.ExecuteNonQuery(insertSql, insertParams);
                return "Inserted";
            }

            string currentStatus = statusObj.ToString();

            if (currentStatus == "Dropped" || currentStatus == "Drop Rejected" || currentStatus == "Enrollment Rejected")
            {
                string updateSql = @"
                    UPDATE Enrollment
                    SET Status = 'Active',
                        Semester = @Semester,
                        EnrollmentDate = GETDATE(),
                        DropReason = NULL,
                        DropRequestedAt = NULL,
                        DropReviewedAt = NULL,
                        DropReviewedBy = NULL
                    WHERE StudentId = @StudentId
                      AND CourseId = @CourseId
                      AND Session = @Session
                      AND Status IN ('Dropped', 'Drop Rejected', 'Enrollment Rejected')";

                SqlParameter[] updateParams =
                {
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@CourseId", courseId),
                    new SqlParameter("@Session", session),
                    new SqlParameter("@Semester", semester)
                };

                DatabaseHelper.ExecuteNonQuery(updateSql, updateParams);
                return "Reactivated";
            }

            return "Skipped";
        }

        private void UpdateStudentTuitionFee(string studentId, string session)
        {
            string totalSql = @"
                SELECT ISNULL(SUM(ISNULL(cf.Amount, 0)), 0)
                FROM Enrollment e
                LEFT JOIN CourseFees cf ON e.CourseId = cf.CourseId AND e.Session = cf.Session
                WHERE e.StudentId = @StudentId
                  AND e.Session = @Session
                  AND e.Status = 'Active'";

            SqlParameter[] p =
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session)
            };

            decimal total = Convert.ToDecimal(DatabaseHelper.ExecuteScalar(totalSql, p));

            string upsertSql = @"
                IF EXISTS (SELECT 1 FROM Fees WHERE StudentId = @StudentId AND Session = @Session AND FeeType = 'Tuition')
                BEGIN
                    UPDATE Fees
                    SET Amount = @Amount,
                        Status = CASE WHEN Status = 'Paid' THEN 'Paid' ELSE 'Pending' END
                    WHERE StudentId = @StudentId AND Session = @Session AND FeeType = 'Tuition'
                END
                ELSE
                BEGIN
                    INSERT INTO Fees (StudentId, Session, FeeType, Amount, Status, PaymentDate)
                    VALUES (@StudentId, @Session, 'Tuition', @Amount, 'Pending', NULL)
                END";

            SqlParameter[] p2 =
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session),
                new SqlParameter("@Amount", total)
            };

            DatabaseHelper.ExecuteNonQuery(upsertSql, p2);
        }


        protected void gvSummary_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "ApproveDrop" && e.CommandName != "RejectDrop")
                return;

            string[] parts = e.CommandArgument.ToString().Split('|');
            if (parts.Length != 4)
            {
                ShowMessage("Error", "Invalid enrollment record selected.");
                return;
            }

            string studentId = parts[0];
            int courseId;
            if (!int.TryParse(parts[1], out courseId))
            {
                ShowMessage("Error", "Invalid course selected.");
                return;
            }

            string session = parts[2];

            int semester;
            if (!int.TryParse(parts[3], out semester))
            {
                ShowMessage("Error", "Invalid semester selected.");
                return;
            }
            if (e.CommandName == "ApproveDrop")
            {
                UpdateDropRequest(studentId, courseId, session, semester, "Dropped");
                UpdateStudentTuitionFee(studentId, session);
                ShowMessage("Success", "Drop request approved successfully.");
            }
            else if (e.CommandName == "RejectDrop")
            {
                UpdateDropRequest(studentId, courseId, session, semester, "Drop Rejected");
                ShowMessage("Success", "Drop request rejected successfully.");
            }

            LoadStats();
            LoadSummary();
        }

        private void UpdateEnrollmentRequest(string studentId, string session, int semester, string newStatus)
        {
            string sql = @"
                UPDATE Enrollment
                SET Status = @Status
                WHERE StudentId = @StudentId
                  AND Session = @Session
                  AND Semester = @Semester
                  AND Status = 'Enrollment Pending'";

            SqlParameter[] p =
            {
                new SqlParameter("@Status", newStatus),
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session),
                new SqlParameter("@Semester", semester)
            };

            DatabaseHelper.ExecuteNonQuery(sql, p);
        }

        private void UpdateDropRequest(string studentId, int courseId, string session, int semester, string newStatus)
        {
            string sql = @"
                UPDATE Enrollment
                SET Status = @Status,
                    DropReviewedAt = GETDATE(),
                    DropReviewedBy = @ReviewedBy
                WHERE StudentId = @StudentId
                  AND CourseId = @CourseId
                  AND Session = @Session
                  AND Semester = @Semester
                  AND Status = 'Drop Pending'";

            SqlParameter[] p =
            {
                new SqlParameter("@Status", newStatus),
                new SqlParameter("@ReviewedBy", GetCurrentAdminId()),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session),
                new SqlParameter("@Semester", semester)
            };

            DatabaseHelper.ExecuteNonQuery(sql, p);
        }

        private string GetCurrentAdminId()
        {
            if (Session["UserId"] != null) return Session["UserId"].ToString();
            if (Session["HoPId"] != null) return Session["HoPId"].ToString();
            if (Session["AdminId"] != null) return Session["AdminId"].ToString();
            if (Session["Username"] != null) return Session["Username"].ToString();

            return "Admin";
        }

        protected bool IsEnrollmentPending(object status)
        {
            return status != null &&
                   status.ToString().Equals("Enrollment Pending", StringComparison.OrdinalIgnoreCase);
        }

        protected bool IsDropPending(object status)
        {
            return status != null &&
                   status.ToString().Equals("Drop Pending", StringComparison.OrdinalIgnoreCase);
        }

        protected void ddlFilterProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSummary();
        }

        protected void ddlFilterStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSummary();
        }

        protected void btnResetSummaryFilter_Click(object sender, EventArgs e)
        {
            ddlFilterProgramme.SelectedIndex = 0;
            ddlFilterStatus.SelectedIndex = 0;
            LoadSummary();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlProgramme.SelectedIndex = 0;
            ddlStudent.Items.Clear();
            ddlStudent.Items.Insert(0, new ListItem("-- Select Student --", ""));
            ddlSession.SelectedIndex = 0;
            txtSemester.Text = "";
            cblCourses.Items.Clear();
            LoadSummary();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        private void ShowMessage(string title, string message)
        {
            lblMessage.Visible = false;
            string safeTitle = HttpUtility.JavaScriptStringEncode(title);
            string safeMessage = HttpUtility.JavaScriptStringEncode(message).Replace("\r\n", "<br/>").Replace("\n", "<br/>");
            string script = string.Format("showMessageModal('{0}', '{1}');", safeTitle, safeMessage);
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"), script, true);
        }
    }
}
