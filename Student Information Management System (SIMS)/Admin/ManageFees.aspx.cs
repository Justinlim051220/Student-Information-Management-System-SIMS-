using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class Admin_ManageFees : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                LoadSessions();
                LoadProgrammes();
                LoadCourses();
                LoadStats();
                LoadCourseFees();
                LoadPayments();
            }
        }

        private void LoadSessions()
        {
            string[] sessions = { "April 2026", "August 2026", "January 2027", "April 2027", "August 2027" };

            ddlFeeSession.Items.Clear();
            ddlPaymentSession.Items.Clear();

            foreach (string session in sessions)
            {
                ddlFeeSession.Items.Add(new ListItem(session, session));
                ddlPaymentSession.Items.Add(new ListItem(session, session));
            }

            ddlPaymentSession.Items.Insert(0, new ListItem("All Sessions", ""));
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

        private void LoadCourses()
        {
            ddlCourse.Items.Clear();
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));

            if (string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue)) return;

            string sql = @"
                SELECT CourseId, CourseCode + ' - ' + CourseName AS CourseDisplay
                FROM Courses
                WHERE ProgrammeId = @ProgrammeId
                ORDER BY CourseCode";

            SqlParameter[] p = { new SqlParameter("@ProgrammeId", int.Parse(ddlProgramme.SelectedValue)) };
            ddlCourse.DataSource = DatabaseHelper.ExecuteQuery(sql, p);
            ddlCourse.DataTextField = "CourseDisplay";
            ddlCourse.DataValueField = "CourseId";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));
        }

        private void LoadStats()
        {
            object pending = DatabaseHelper.ExecuteScalar("SELECT ISNULL(SUM(Amount), 0) FROM Fees WHERE Status = 'Pending'");
            object paid = DatabaseHelper.ExecuteScalar("SELECT ISNULL(SUM(Amount), 0) FROM Fees WHERE Status = 'Paid'");

            lblPendingAmount.Text = Convert.ToDecimal(pending).ToString("N2");
            lblPaidAmount.Text = Convert.ToDecimal(paid).ToString("N2");
        }

        private void LoadCourseFees()
        {
            string sql = @"
                SELECT cf.CourseFeeId, p.ProgrammeCode, c.CourseCode, c.CourseName, cf.Session, cf.Amount
                FROM CourseFees cf
                INNER JOIN Courses c ON cf.CourseId = c.CourseId
                INNER JOIN Programmes p ON c.ProgrammeId = p.ProgrammeId
                ORDER BY cf.Session DESC, p.ProgrammeCode, c.CourseCode";

            gvCourseFees.DataSource = DatabaseHelper.ExecuteQuery(sql);
            gvCourseFees.DataBind();
        }

        private void LoadPayments()
        {
            string sql = @"
                SELECT f.StudentId,
                       s.FirstName + ' ' + s.LastName AS StudentName,
                       p.ProgrammeCode,
                       f.Session,
                       f.FeeType,
                       f.Amount,
                       f.Status,
                       f.PaymentDate
                FROM Fees f
                INNER JOIN StudentDetails s ON f.StudentId = s.StudentId
                INNER JOIN Programmes p ON s.ProgrammeId = p.ProgrammeId
                WHERE (@Session = '' OR f.Session = @Session)
                  AND (@Status = '' OR f.Status = @Status)
                ORDER BY CASE WHEN f.Status = 'Pending' THEN 0 ELSE 1 END, f.Session DESC, s.FirstName";

            SqlParameter[] pms =
            {
                new SqlParameter("@Session", ddlPaymentSession.SelectedValue ?? ""),
                new SqlParameter("@Status", ddlStatus.SelectedValue ?? "")
            };

            gvPayments.DataSource = DatabaseHelper.ExecuteQuery(sql, pms);
            gvPayments.DataBind();
        }

        protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourses();
        }

        protected void ddlPaymentSession_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadPayments();
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadPayments();
        }

        protected void btnSaveCourseFee_Click(object sender, EventArgs e)
        {
            if (!ValidateCourseFee()) return;

            try
            {
                decimal amount = decimal.Parse(txtAmount.Text.Trim());

                if (string.IsNullOrWhiteSpace(hfCourseFeeId.Value))
                {
                    string sql = @"
                        IF EXISTS (SELECT 1 FROM CourseFees WHERE CourseId = @CourseId AND Session = @Session)
                        BEGIN
                            UPDATE CourseFees SET Amount = @Amount WHERE CourseId = @CourseId AND Session = @Session
                        END
                        ELSE
                        BEGIN
                            INSERT INTO CourseFees (CourseId, Session, Amount) VALUES (@CourseId, @Session, @Amount)
                        END";

                    SqlParameter[] p =
                    {
                        new SqlParameter("@CourseId", int.Parse(ddlCourse.SelectedValue)),
                        new SqlParameter("@Session", ddlFeeSession.SelectedValue),
                        new SqlParameter("@Amount", amount)
                    };
                    DatabaseHelper.ExecuteNonQuery(sql, p);
                    ShowMessage("Success", "Course fee saved successfully.");
                }
                else
                {
                    string sql = @"
                        UPDATE CourseFees
                        SET CourseId = @CourseId, Session = @Session, Amount = @Amount
                        WHERE CourseFeeId = @CourseFeeId";

                    SqlParameter[] p =
                    {
                        new SqlParameter("@CourseFeeId", int.Parse(hfCourseFeeId.Value)),
                        new SqlParameter("@CourseId", int.Parse(ddlCourse.SelectedValue)),
                        new SqlParameter("@Session", ddlFeeSession.SelectedValue),
                        new SqlParameter("@Amount", amount)
                    };
                    DatabaseHelper.ExecuteNonQuery(sql, p);
                    ShowMessage("Success", "Course fee updated successfully.");
                }

                ClearCourseFeeForm();
                LoadCourseFees();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Error: " + ex.Message);
            }
        }

        private bool ValidateCourseFee()
        {
            if (string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue) || string.IsNullOrWhiteSpace(ddlCourse.SelectedValue) || string.IsNullOrWhiteSpace(txtAmount.Text))
            {
                ShowMessage("Warning", "Please select programme, course, session, and enter amount.");
                return false;
            }

            decimal amount;
            if (!decimal.TryParse(txtAmount.Text.Trim(), out amount) || amount < 0)
            {
                ShowMessage("Warning", "Amount must be a valid number and cannot be negative.");
                return false;
            }

            return true;
        }

        protected void gvCourseFees_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int courseFeeId = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "EditFee")
            {
                LoadCourseFeeForEdit(courseFeeId);
            }
            else if (e.CommandName == "DeleteFee")
            {
                SqlParameter[] p = { new SqlParameter("@CourseFeeId", courseFeeId) };
                DatabaseHelper.ExecuteNonQuery("DELETE FROM CourseFees WHERE CourseFeeId = @CourseFeeId", p);
                LoadCourseFees();
                ShowMessage("Success", "Course fee deleted successfully.");
            }
        }

        private void LoadCourseFeeForEdit(int courseFeeId)
        {
            string sql = @"
                SELECT cf.CourseFeeId, cf.CourseId, cf.Session, cf.Amount, c.ProgrammeId
                FROM CourseFees cf
                INNER JOIN Courses c ON cf.CourseId = c.CourseId
                WHERE cf.CourseFeeId = @CourseFeeId";

            SqlParameter[] p = { new SqlParameter("@CourseFeeId", courseFeeId) };
            DataTable dt = DatabaseHelper.ExecuteQuery(sql, p);
            if (dt.Rows.Count == 0) return;

            DataRow row = dt.Rows[0];
            hfCourseFeeId.Value = row["CourseFeeId"].ToString();
            ddlProgramme.SelectedValue = row["ProgrammeId"].ToString();
            LoadCourses();
            ddlCourse.SelectedValue = row["CourseId"].ToString();
            ddlFeeSession.SelectedValue = row["Session"].ToString();
            txtAmount.Text = Convert.ToDecimal(row["Amount"]).ToString("0.00");
        }

        protected void btnClearCourseFee_Click(object sender, EventArgs e)
        {
            ClearCourseFeeForm();
        }

        private void ClearCourseFeeForm()
        {
            hfCourseFeeId.Value = "";
            ddlProgramme.SelectedIndex = 0;
            ddlCourse.Items.Clear();
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));
            ddlFeeSession.SelectedIndex = 0;
            txtAmount.Text = "";
        }

        protected void gvPayments_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string[] parts = e.CommandArgument.ToString().Split('|');
            if (parts.Length != 3) return;

            string studentId = parts[0];
            string session = parts[1];
            string feeType = parts[2];

            if (e.CommandName == "ApprovePayment")
            {
                UpdatePaymentStatus(studentId, session, feeType, "Paid");
                ShowMessage("Success", "Payment approved successfully.");
            }
            else if (e.CommandName == "RejectPayment")
            {
                UpdatePaymentStatus(studentId, session, feeType, "Rejected");
                ShowMessage("Success", "Payment rejected successfully.");
            }

            LoadStats();
            LoadPayments();
        }

        private void UpdatePaymentStatus(string studentId, string session, string feeType, string status)
        {
            string sql = @"
                UPDATE Fees
                SET Status = @Status,
                    PaymentDate = CASE WHEN @Status = 'Paid' THEN GETDATE() ELSE NULL END
                WHERE StudentId = @StudentId AND Session = @Session AND FeeType = @FeeType";

            SqlParameter[] p =
            {
                new SqlParameter("@Status", status),
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session),
                new SqlParameter("@FeeType", feeType)
            };

            DatabaseHelper.ExecuteNonQuery(sql, p);
        }

        protected void gvPayments_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

            string status = DataBinder.Eval(e.Row.DataItem, "Status").ToString();
            LinkButton approve = e.Row.FindControl("btnApprove") as LinkButton;
            LinkButton reject = e.Row.FindControl("btnReject") as LinkButton;

            if (status != "Pending")
            {
                if (approve != null) approve.Visible = false;
                if (reject != null) reject.Visible = false;
            }
        }

        protected string GetStatusCss(object statusObj)
        {
            string status = statusObj == null ? "" : statusObj.ToString();

            switch (status)
            {
                case "Paid":
                    return "status-paid";

                case "Pending":
                    return "status-pending";

                case "Overdue":
                    return "status-overdue";

                case "Rejected":
                    return "status-rejected";

                default:
                    return "status-pending";
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        private void ShowMessage(string title, string message)
        {
            string safeTitle = HttpUtility.JavaScriptStringEncode(title);
            string safeMessage = HttpUtility.JavaScriptStringEncode(message).Replace("\r\n", "<br/>").Replace("\n", "<br/>");
            string script = string.Format("showMessageModal('{0}', '{1}');", safeTitle, safeMessage);
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"), script, true);
        }
    }
}
