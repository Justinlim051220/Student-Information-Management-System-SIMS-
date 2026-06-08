using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
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
                lblStudentNameTop.Text = fullName;
                lblStudentIdTop.Text = studentId;
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
                LoadNotificationBadge();

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
            lblProgrammeTop.Text = row["ProgrammeDisplay"].ToString();
            lblSemesterTop.Text = row["CurrentSemester"].ToString();
            lblRule.Text = "Programme = " + row["ProgrammeDisplay"] + ", Semester = " + row["CurrentSemester"] + ", Status = Open";
        }

        private void LoadOpenSessions()
        {
            ddlSession.Items.Clear();

            if (string.IsNullOrWhiteSpace(hfProgrammeId.Value))
            {
                ddlSession.Items.Insert(0, new ListItem("-- Programme Not Found --", ""));
                lblOpenSessionCount.Text = "0";
                return;
            }

            string sql = @"
                SELECT DISTINCT Session
                FROM CourseOffering
                WHERE Status = 'Open'
                  AND ProgrammeId = @ProgrammeId
                ORDER BY Session";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@ProgrammeId", int.Parse(hfProgrammeId.Value))
            });

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
                string.IsNullOrWhiteSpace(hfProgrammeId.Value))
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
                  AND NOT EXISTS (
                      SELECT 1
                      FROM Enrollment e
                      WHERE e.StudentId = @StudentId
                        AND e.CourseId = co.CourseId
                        AND e.Session = co.Session
                        AND e.Status NOT IN ('Dropped', 'Drop Rejected', 'Enrollment Rejected')
                  )
                ORDER BY c.CourseCode";

            SqlParameter[] p =
            {
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@ProgrammeId", int.Parse(hfProgrammeId.Value)),
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
            int programmeId = int.Parse(hfProgrammeId.Value);
            int semester = GetSemesterForSelectedSession(studentId, session);

            if (!IsOfferingOpen(courseId, session, programmeId))
            {
                ShowMessage("This course is not open for your programme or selected session.", "error");
                LoadAvailableCourses();
                return;
            }

            int enrollmentId;
            string saveResult = SaveOrReactivateEnrollment(studentId, courseId, session, semester, out enrollmentId);

            if (saveResult == "Inserted")
            {
                MarkPreviousSessionsCompleted(studentId, session);
                decimal pendingAmount = CreatePendingPaymentForEnrollment(enrollmentId, studentId, courseId, session);
                UpdateStudentCurrentSemester(studentId, semester);
                LoadStudentInfo(studentId);
                NotifyAdminsStudentEnrollment(studentId, courseId, session, semester, "New Student Enrollment");
                ShowPaymentMessage("Enrollment completed successfully. Your tuition fee for this subject is RM " + pendingAmount.ToString("N2") + ". Please go to the Payment page to upload your receipt.");
            }
            else if (saveResult == "Drop Pending")
            {
                ShowMessage("Your drop request for this course is still pending admin review.", "error");
            }
            else
            {
                ShowMessage("You already enrolled in this course for the selected session.", "error");
            }

            LoadAvailableCourses();
            LoadEnrolledCourses(studentId);
        }

        private bool IsOfferingOpen(int courseId, string session, int programmeId)
        {
            string sql = @"
                SELECT COUNT(*)
                FROM CourseOffering
                WHERE CourseId = @CourseId
                  AND Session = @Session
                  AND ProgrammeId = @ProgrammeId
                  AND Status = 'Open'";

            object result = DatabaseHelper.ExecuteScalar(sql, new[]
            {
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session),
                new SqlParameter("@ProgrammeId", programmeId)
            });

            return result != null && Convert.ToInt32(result) > 0;
        }

        private int GetSemesterForSelectedSession(string studentId, string session)
        {
            // If the student has already enrolled anything in this same session, reuse that session semester.
            // This prevents Semester from increasing for every course added within the same session.
            string existingSessionSemesterSql = @"
                SELECT TOP 1 Semester
                FROM Enrollment
                WHERE StudentId = @StudentId
                  AND Session = @Session
                  AND Status NOT IN ('Dropped', 'Drop Rejected', 'Enrollment Rejected')
                ORDER BY EnrollmentId DESC";

            object existingSemester = DatabaseHelper.ExecuteScalar(existingSessionSemesterSql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session)
            });

            if (existingSemester != null && existingSemester != DBNull.Value)
            {
                return Convert.ToInt32(existingSemester);
            }

            // For a new session, move to the next semester only once.
            int currentSemester = 1;
            int.TryParse(hfSemester.Value, out currentSemester);
            if (currentSemester < 1) currentSemester = 1;

            string previousDifferentSessionSql = @"
                SELECT COUNT(DISTINCT Session)
                FROM Enrollment
                WHERE StudentId = @StudentId
                  AND Session <> @Session
                  AND Status NOT IN ('Dropped', 'Drop Rejected', 'Enrollment Rejected')";

            int previousSessionCount = Convert.ToInt32(DatabaseHelper.ExecuteScalar(previousDifferentSessionSql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session)
            }));

            if (previousSessionCount > 0)
            {
                currentSemester = Math.Min(currentSemester + 1, 6);
            }

            return currentSemester;
        }

        private void UpdateStudentCurrentSemester(string studentId, int semester)
        {
            string sql = @"
                UPDATE StudentDetails
                SET CurrentSemester = @Semester
                WHERE StudentId = @StudentId
                  AND ISNULL(CurrentSemester, 1) < @Semester";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@Semester", semester),
                new SqlParameter("@StudentId", studentId)
            });
        }

        private void MarkPreviousSessionsCompleted(string studentId, string currentSession)
        {
            // Once a student successfully enrolls into a newer/different session,
            // older still-current enrollment records are moved to Completed.
            // This keeps only the latest enrolled session as the student's current enrollment.
            string sql = @"
                UPDATE Enrollment
                SET Status = 'Completed'
                WHERE StudentId = @StudentId
                  AND Session <> @CurrentSession
                  AND Status IN ('Active', 'Pending', 'Enrollment Pending', 'Drop Pending')";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CurrentSession", currentSession)
            });
        }

        private decimal CreatePendingPaymentForEnrollment(int enrollmentId, string studentId, int courseId, string session)
        {
            string amountSql = @"
                SELECT ISNULL(cf.Amount, 0)
                FROM Courses c
                LEFT JOIN CourseFees cf ON cf.CourseId = c.CourseId AND cf.Session = @Session
                WHERE c.CourseId = @CourseId";

            decimal amount = Convert.ToDecimal(DatabaseHelper.ExecuteScalar(amountSql, new[]
            {
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session)
            }));

            string insertSql = @"
                INSERT INTO Fees (EnrollmentId, StudentId, Session, FeeType, Amount, Status, PaymentDate)
                VALUES (@EnrollmentId, @StudentId, @Session, 'Tuition', @Amount, 'Pending', NULL)";

            DatabaseHelper.ExecuteNonQuery(insertSql, new[]
            {
                new SqlParameter("@EnrollmentId", enrollmentId),
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session),
                new SqlParameter("@Amount", amount)
            });

            return amount;
        }

        private string SaveOrReactivateEnrollment(string studentId, int courseId, string session, int semester, out int enrollmentId)
        {
            enrollmentId = 0;

            string activeSql = @"
                SELECT TOP 1 Status
                FROM Enrollment
                WHERE StudentId = @StudentId
                  AND CourseId = @CourseId
                  AND Session = @Session
                  AND Status NOT IN ('Dropped', 'Drop Rejected', 'Enrollment Rejected')
                ORDER BY EnrollmentId DESC";

            object statusObj = DatabaseHelper.ExecuteScalar(activeSql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session)
            });

            if (statusObj != null && statusObj != DBNull.Value)
            {
                return statusObj.ToString();
            }

            string insertSql = @"
                INSERT INTO Enrollment (StudentId, CourseId, Session, Semester, Status, EnrollmentDate)
                VALUES (@StudentId, @CourseId, @Session, @Semester, 'Active', GETDATE());
                SELECT CAST(SCOPE_IDENTITY() AS INT);";

            enrollmentId = Convert.ToInt32(DatabaseHelper.ExecuteScalar(insertSql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session),
                new SqlParameter("@Semester", semester)
            }));

            return "Inserted";
        }

        private void LoadEnrolledCourses(string studentId)
        {
            string view = GetEnrollmentViewFilter();

            string statusCondition;
            switch (view)
            {
                case "Active":
                    statusCondition = " AND e.Session = @LatestSession AND e.Status = 'Active' ";
                    break;

                case "Pending":
                    statusCondition = " AND e.Session = @LatestSession AND e.Status = 'Pending' ";
                    break;

                case "Drop Pending":
                    statusCondition = " AND e.Session = @LatestSession AND e.Status = 'Drop Pending' ";
                    break;

                case "Dropped":
                    statusCondition = " AND e.Status = 'Dropped' ";
                    break;

                case "Rejected":
                    statusCondition = " AND e.Status IN ('Drop Rejected', 'Enrollment Rejected', 'Rejected') ";
                    break;

                case "History":
                    statusCondition = " AND (e.Status = 'Completed' OR (@LatestSession IS NOT NULL AND e.Session <> @LatestSession)) ";
                    break;

                case "All":
                    statusCondition = "";
                    break;

                case "Current":
                default:
                    statusCondition = " AND e.Session = @LatestSession AND e.Status IN ('Active', 'Pending', 'Drop Pending') ";
                    break;
            }

            string sql = @"
                DECLARE @LatestSession VARCHAR(50);

                SELECT TOP 1 @LatestSession = Session
                FROM Enrollment
                WHERE StudentId = @StudentId
                  AND Status IN ('Active', 'Pending', 'Drop Pending')
                ORDER BY EnrollmentDate DESC, EnrollmentId DESC;

                IF @LatestSession IS NULL
                BEGIN
                    SELECT TOP 1 @LatestSession = Session
                    FROM Enrollment
                    WHERE StudentId = @StudentId
                    ORDER BY EnrollmentDate DESC, EnrollmentId DESC;
                END;

                SELECT 
                    e.EnrollmentId,
                    e.CourseId,
                    c.CourseCode,
                    c.CourseName,
                    c.Credits,
                    e.Session,
                    e.Semester,
                    e.Status,
                    CASE
                        WHEN e.Status = 'Completed' THEN 'Completed'
                        WHEN @LatestSession IS NOT NULL
                             AND e.Session <> @LatestSession
                             AND e.Status IN ('Active', 'Pending', 'Drop Pending') THEN 'Completed'
                        ELSE e.Status
                    END AS DisplayStatus,
                    e.EnrollmentDate
                FROM Enrollment e
                INNER JOIN Courses c ON c.CourseId = e.CourseId
                WHERE e.StudentId = @StudentId "
                + statusCondition + @"
                ORDER BY 
                    CASE WHEN e.Session = @LatestSession THEN 0 ELSE 1 END,
                    e.EnrollmentDate DESC,
                    CASE 
                        WHEN e.Status = 'Active' THEN 1
                        WHEN e.Status = 'Pending' THEN 2
                        WHEN e.Status = 'Drop Pending' THEN 3
                        WHEN e.Status = 'Completed' THEN 4
                        WHEN e.Status = 'Dropped' THEN 5
                        ELSE 6
                    END,
                    c.CourseCode";

            gvEnrolled.DataSource = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@StudentId", studentId) });
            gvEnrolled.DataBind();
        }

        protected string GetEnrollmentViewSelected(string value)
        {
            return string.Equals(GetEnrollmentViewFilter(), value, StringComparison.OrdinalIgnoreCase)
                ? "selected=\"selected\""
                : "";
        }

        private string GetEnrollmentViewFilter()
        {
            string view = Request.Form["enrollmentView"];

            if (string.IsNullOrWhiteSpace(view))
            {
                return "Current";
            }

            switch (view)
            {
                case "Current":
                case "History":
                case "Active":
                case "Pending":
                case "Drop Pending":
                case "Dropped":
                case "Rejected":
                case "All":
                    return view;

                default:
                    return "Current";
            }
        }


        protected string GetDropClientClick(object enrollmentIdObj, object courseIdObj, object sessionObj, object courseCodeObj, object courseNameObj)
        {
            if (enrollmentIdObj == null || courseIdObj == null || sessionObj == null)
            {
                return "return false;";
            }

            string enrollmentId = enrollmentIdObj.ToString();
            string courseId = courseIdObj.ToString();
            string session = sessionObj.ToString();
            string courseCode = courseCodeObj == null ? "" : courseCodeObj.ToString();
            string courseName = courseNameObj == null ? "" : courseNameObj.ToString();
            string courseText = (courseCode + " - " + courseName).Trim(' ', '-');

            return "return openDropModal('"
                + HttpUtility.JavaScriptStringEncode(enrollmentId) + "','"
                + HttpUtility.JavaScriptStringEncode(courseId) + "','"
                + HttpUtility.JavaScriptStringEncode(session) + "','"
                + HttpUtility.JavaScriptStringEncode(courseText) + "');";
        }

        protected void btnSubmitDrop_Click(object sender, EventArgs e)
        {
            int enrollmentId;
            int courseId;
            if (!int.TryParse(hfDropEnrollmentId.Value, out enrollmentId) || !int.TryParse(hfDropCourseId.Value, out courseId) || string.IsNullOrWhiteSpace(hfDropSession.Value))
            {
                ShowMessage("Unable to read the selected course. Please refresh and try again.", "error");
                return;
            }

            RequestDrop(enrollmentId, courseId, hfDropSession.Value.Trim(), txtDropReason.Text.Trim());
            txtDropReason.Text = string.Empty;
            hfDropEnrollmentId.Value = string.Empty;
            hfDropCourseId.Value = string.Empty;
            hfDropSession.Value = string.Empty;
        }

        private void RequestDrop(int enrollmentId, int courseId, string session, string dropReason)
        {
            string studentId = SessionHelper.GetProfileId(Session);

            if (string.IsNullOrWhiteSpace(dropReason))
            {
                ShowMessage("Please enter a reason before submitting your drop request.", "error");
                LoadEnrolledCourses(studentId);
                return;
            }

            if (dropReason.Length > 255)
            {
                dropReason = dropReason.Substring(0, 255);
            }

            string checkSql = @"
                SELECT Status
                FROM Enrollment
                WHERE StudentId = @StudentId
                  AND CourseId = @CourseId
                  AND Session = @Session";

            DataTable dt = DatabaseHelper.ExecuteQuery(checkSql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session)
            });

            if (dt.Rows.Count == 0)
            {
                ShowMessage("Enrollment record cannot be found.", "error");
                LoadEnrolledCourses(studentId);
                return;
            }

            string currentStatus = dt.Rows[0]["Status"].ToString();

            if (currentStatus != "Active")
            {
                ShowMessage("Only active enrollments can request subject drop.", "error");
                LoadEnrolledCourses(studentId);
                return;
            }

            string updateSql = @"
                UPDATE Enrollment
                SET Status = 'Drop Pending',
                    DropReason = @DropReason,
                    DropRequestedAt = GETDATE()
                WHERE StudentId = @StudentId
                  AND CourseId = @CourseId
                  AND Session = @Session
                  AND Status = 'Active'";

            int affected = DatabaseHelper.ExecuteNonQuery(updateSql, new[]
            {
                new SqlParameter("@EnrollmentId", enrollmentId),
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session),
                new SqlParameter("@DropReason", dropReason)
            });

            if (affected > 0)
            {
                NotifyAdminsDropRequest(studentId, courseId, session, dropReason);
                ShowMessage("Drop request submitted. Please wait for admin approval.", "success");
            }
            else
            {
                ShowMessage("Drop request was not submitted. Please refresh and try again.", "error");
            }

            LoadAvailableCourses();
            LoadEnrolledCourses(studentId);
        }

        private void NotifyAdminsStudentEnrollment(string studentId, int courseId, string session, int semester, string title)
        {
            string sql = @"
                INSERT INTO Notifications (UserId, Title, Message, IsRead, CreatedAt)
                SELECT
                    h.UserId,
                    @Title,
                    'A student has enrolled in a course from the Student Portal.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                    'Student ID: ' + s.StudentId + CHAR(13) + CHAR(10) +
                    'Student Name: ' + s.FirstName + ' ' + s.LastName + CHAR(13) + CHAR(10) +
                    'Course: ' + c.CourseCode + ' - ' + c.CourseName + CHAR(13) + CHAR(10) +
                    'Session: ' + @Session + CHAR(13) + CHAR(10) +
                    'Semester: ' + CAST(@Semester AS VARCHAR(10)),
                    0,
                    GETDATE()
                FROM HoPDetails h
                INNER JOIN Users u ON u.UserId = h.UserId
                CROSS JOIN StudentDetails s
                INNER JOIN Courses c ON c.CourseId = @CourseId
                WHERE s.StudentId = @StudentId
                  AND u.Role = 1
                  AND u.IsActive = 1";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@Title", title),
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session),
                new SqlParameter("@Semester", semester)
            });
        }

        private void NotifyAdminsDropRequest(string studentId, int courseId, string session, string dropReason)
        {
            string sql = @"
                INSERT INTO Notifications (UserId, Title, Message, IsRead, CreatedAt)
                SELECT
                    h.UserId,
                    'New Course Drop Request',
                    'A student has submitted a course drop request.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                    'Student ID: ' + s.StudentId + CHAR(13) + CHAR(10) +
                    'Student Name: ' + s.FirstName + ' ' + s.LastName + CHAR(13) + CHAR(10) +
                    'Course: ' + c.CourseCode + ' - ' + c.CourseName + CHAR(13) + CHAR(10) +
                    'Session: ' + @Session + CHAR(13) + CHAR(10) +
                    'Drop Reason: ' + @DropReason,
                    0,
                    GETDATE()
                FROM HoPDetails h
                INNER JOIN Users u ON u.UserId = h.UserId
                CROSS JOIN StudentDetails s
                INNER JOIN Courses c ON c.CourseId = @CourseId
                WHERE s.StudentId = @StudentId
                  AND u.Role = 1
                  AND u.IsActive = 1";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session),
                new SqlParameter("@DropReason", dropReason)
            });
        }

        protected string GetStatusCss(object statusObj)
        {
            string status = statusObj == null ? "" : statusObj.ToString();

            switch (status)
            {
                case "Active":
                    return "status-active";
                case "Completed":
                    return "status-completed";
                case "Enrollment Pending":
                case "Drop Pending":
                    return "status-pending";
                case "Dropped":
                    return "status-dropped";
                case "Enrollment Rejected":
                case "Drop Rejected":
                    return "status-rejected";
                default:
                    return "status-dropped";
            }
        }

        protected bool CanRequestDrop(object statusObj)
        {
            string status = statusObj == null ? "" : statusObj.ToString();
            return status == "Active";
        }

        protected void gvEnrolled_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // No server-side row command is required because the Request Drop button opens the drop modal using JavaScript.
            // This method is kept here to prevent compile errors if the ASPX still references OnRowCommand.
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadOpenSessions();
            LoadAvailableCourses();
            LoadEnrolledCourses(SessionHelper.GetProfileId(Session));
            ShowMessage("Enrollment list refreshed successfully.", "success");
        }


        private int CurrentUserId
        {
            get { return SessionHelper.GetUserId(Session); }
        }

        private void LoadNotificationBadge()
        {
            object count = DatabaseHelper.ExecuteScalar(
                @"SELECT COUNT(*)
                  FROM Notifications
                  WHERE UserId = @UserId
                    AND IsRead = 0",
                new[] { new SqlParameter("@UserId", CurrentUserId) });

            bool hasUnread = count != null && Convert.ToInt32(count) > 0;

            // Sidebar badge and topbar badge are optional controls.
            if (pnlSidebarNotifBadge != null)
            {
                pnlSidebarNotifBadge.Visible = hasUnread;
            }

            if (pnlNotifBadge != null)
            {
                pnlNotifBadge.Visible = hasUnread;
            }
        }

        private void ShowPaymentMessage(string message)
        {
            pnlMessage.Visible = false;
            lblMessage.Text = string.Empty;

            string safeMessage = HttpUtility.JavaScriptStringEncode(message);
            ClientScript.RegisterStartupScript(
                GetType(),
                "paymentDialog" + Guid.NewGuid().ToString("N"),
                "setTimeout(function(){ showPaymentDialog('" + safeMessage + "'); }, 120);",
                true);
        }

        private void ShowMessage(string message, string type)
        {
            // Message is shown using the modal prompt only.
            // The old top notification panel is intentionally hidden for UI consistency.
            pnlMessage.Visible = false;
            lblMessage.Text = string.Empty;

            string safeMessage = HttpUtility.JavaScriptStringEncode(message);
            string safeType = HttpUtility.JavaScriptStringEncode(type);
            ClientScript.RegisterStartupScript(
                GetType(),
                "systemDialog" + Guid.NewGuid().ToString("N"),
                "setTimeout(function(){ showSystemDialog('" + safeMessage + "','" + safeType + "'); }, 120);",
                true);
        }

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}
