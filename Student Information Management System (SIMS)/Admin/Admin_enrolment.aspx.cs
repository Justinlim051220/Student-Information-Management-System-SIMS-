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
            object totalEnrollments = DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM Enrollment WHERE Status = 'Active'");
            object pendingFees = DatabaseHelper.ExecuteScalar("SELECT ISNULL(SUM(Amount), 0) FROM Fees WHERE Status = 'Pending'");

            lblTotalEnrollments.Text = totalEnrollments?.ToString() ?? "0";
            lblPendingFees.Text = Convert.ToDecimal(pendingFees).ToString("N2");
        }

        private void LoadSummary()
        {
            string sql = @"
                SELECT e.StudentId,
                       s.FirstName + ' ' + s.LastName AS StudentName,
                       c.CourseCode,
                       c.CourseName,
                       e.Session,
                       e.Semester,
                       ISNULL(cf.Amount, 0) AS Amount,
                       e.Status
                FROM Enrollment e
                INNER JOIN StudentDetails s ON e.StudentId = s.StudentId
                INNER JOIN Courses c ON e.CourseId = c.CourseId
                LEFT JOIN CourseFees cf ON e.CourseId = cf.CourseId AND e.Session = cf.Session
                WHERE (@StudentId = '' OR e.StudentId = @StudentId)
                  AND (@Session = '' OR e.Session = @Session)
                ORDER BY e.EnrollmentDate DESC, c.CourseCode";

            SqlParameter[] p =
            {
                new SqlParameter("@StudentId", ddlStudent.SelectedValue ?? ""),
                new SqlParameter("@Session", ddlSession.SelectedValue)
            };

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, p);
            gvSummary.DataSource = dt;
            gvSummary.DataBind();

            decimal total = 0;
            foreach (DataRow row in dt.Rows)
            {
                total += Convert.ToDecimal(row["Amount"]);
            }
            lblSelectedTotal.Text = total.ToString("N2");
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

            try
            {
                int inserted = 0;
                foreach (ListItem item in cblCourses.Items)
                {
                    if (!item.Selected) continue;

                    if (!EnrollmentExists(ddlStudent.SelectedValue, int.Parse(item.Value), ddlSession.SelectedValue))
                    {
                        InsertEnrollment(ddlStudent.SelectedValue, int.Parse(item.Value), ddlSession.SelectedValue, int.Parse(txtSemester.Text.Trim()));
                        inserted++;
                    }
                }

                UpdateStudentTuitionFee(ddlStudent.SelectedValue, ddlSession.SelectedValue);
                LoadStats();
                LoadCourses();
                LoadSummary();

                if (inserted == 0)
                    ShowMessage("Warning", "The selected student is already enrolled in the selected course(s) for this session.");
                else
                    ShowMessage("Success", "Student enrolled successfully. Fee summary has been updated.");
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

        private bool EnrollmentExists(string studentId, int courseId, string session)
        {
            string sql = @"
                SELECT COUNT(*)
                FROM Enrollment
                WHERE StudentId = @StudentId
                  AND CourseId = @CourseId
                  AND Session = @Session";

            SqlParameter[] p =
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session)
            };

            return Convert.ToInt32(DatabaseHelper.ExecuteScalar(sql, p)) > 0;
        }

        private void InsertEnrollment(string studentId, int courseId, string session, int semester)
        {
            string sql = @"
                INSERT INTO Enrollment (StudentId, CourseId, Session, Semester, Status, EnrollmentDate)
                VALUES (@StudentId, @CourseId, @Session, @Semester, 'Active', GETDATE())";

            SqlParameter[] p =
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Session", session),
                new SqlParameter("@Semester", semester)
            };

            DatabaseHelper.ExecuteNonQuery(sql, p);
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

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlProgramme.SelectedIndex = 0;
            ddlStudent.Items.Clear();
            ddlStudent.Items.Insert(0, new ListItem("-- Select Student --", ""));
            ddlSession.SelectedIndex = 0;
            txtSemester.Text = "1";
            cblCourses.Items.Clear();
            lblSelectedTotal.Text = "0.00";
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
