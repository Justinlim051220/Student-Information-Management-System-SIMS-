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
            string pendingSql = @"
                SELECT ISNULL(SUM(
                    CASE 
                        WHEN f.Status = 'Pending'
                             AND ISNULL(f.PaymentReceiptPath, '') = ''
                             AND e.EnrollmentId IS NOT NULL
                             AND ISNULL(e.Status, '') IN ('Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                        THEN 0
                        ELSE f.Amount
                    END), 0)
                FROM Fees f
                LEFT JOIN Enrollment e ON e.EnrollmentId = f.EnrollmentId
                WHERE f.Status = 'Pending'
                  AND NOT (
                        ISNULL(f.PaymentReceiptPath, '') = ''
                        AND e.EnrollmentId IS NOT NULL
                        AND ISNULL(e.Status, '') IN ('Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                  )";

            object pending = DatabaseHelper.ExecuteScalar(pendingSql);
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
            string selectedStatus = ddlStatus.SelectedValue ?? "";

            string sql = @"
                SELECT *
                FROM
                (
                    SELECT f.FeeId,
                           ISNULL(f.EnrollmentId, 0) AS EnrollmentId,
                           ('PAY-' + RIGHT('000000' + CAST(f.FeeId AS VARCHAR(6)), 6)) AS PaymentRef,
                           f.StudentId,
                           s.FirstName + ' ' + s.LastName AS StudentName,
                           p.ProgrammeCode,
                           f.Session,
                           f.FeeType,
                           f.Amount,
                           CASE 
                               WHEN f.Status = 'Pending'
                                    AND ISNULL(f.PaymentReceiptPath, '') = ''
                                    AND e.EnrollmentId IS NOT NULL
                                    AND ISNULL(e.Status, '') IN ('Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                               THEN CAST(0 AS DECIMAL(18,2))
                               ELSE f.Amount
                           END AS DisplayAmount,
                           f.Status,
                           ISNULL(s.IsSuspended, 0) AS IsSuspended,
                           ISNULL(s.SuspensionReason, '') AS SuspensionReason,
                           CASE 
                               WHEN f.Status = 'Pending'
                                    AND ISNULL(f.PaymentReceiptPath, '') = ''
                                    AND e.EnrollmentId IS NOT NULL
                                    AND ISNULL(e.Status, '') IN ('Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                               THEN 'Not Active'
                               ELSE f.Status
                           END AS DisplayStatus,
                           ISNULL(e.Status, '') AS EnrollmentStatus,
                           f.PaymentDate,
                           ISNULL(f.PaymentReceiptPath, '') AS PaymentReceiptPath,
                           CASE 
                               WHEN f.Status = 'Pending'
                                    AND ISNULL(f.PaymentReceiptPath, '') = ''
                                    AND e.EnrollmentId IS NOT NULL
                                    AND ISNULL(e.Status, '') IN ('Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                               THEN '<span class=""receipt-empty"">Dropped before payment</span>'
                               ELSE ISNULL(
                                   STUFF((
                                       SELECT '<div class=""course-line""><span class=""course-code"">' + c.CourseCode + '</span><span class=""course-name"">' + c.CourseName + '</span><span class=""course-fee"">RM ' + FORMAT(ISNULL(cf.Amount, 0), 'N2') + '</span></div>'
                                       FROM Enrollment e2
                                       INNER JOIN Courses c ON e2.CourseId = c.CourseId
                                       LEFT JOIN CourseFees cf ON cf.CourseId = c.CourseId AND cf.Session = e2.Session
                                       WHERE e2.EnrollmentId = f.EnrollmentId
                                       ORDER BY c.CourseCode
                                       FOR XML PATH(''), TYPE
                                   ).value('.', 'NVARCHAR(MAX)'), 1, 0, ''),
                                   '<span class=""receipt-empty"">No active enrolled course found</span>'
                               )
                           END AS CoursePaymentList
                    FROM Fees f
                    INNER JOIN StudentDetails s ON f.StudentId = s.StudentId
                    INNER JOIN Programmes p ON s.ProgrammeId = p.ProgrammeId
                    LEFT JOIN Enrollment e ON e.EnrollmentId = f.EnrollmentId
                    WHERE (@Session = '' OR f.Session = @Session)
                ) x
                WHERE (@Status = '' OR x.DisplayStatus = @Status)
                ORDER BY 
                    CASE 
                        WHEN x.DisplayStatus = 'Pending' THEN 0
                        WHEN x.DisplayStatus = 'Not Active' THEN 2
                        ELSE 1
                    END,
                    x.Session DESC,
                    x.StudentName";

            SqlParameter[] pms =
            {
                new SqlParameter("@Session", ddlPaymentSession.SelectedValue ?? ""),
                new SqlParameter("@Status", selectedStatus)
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
                hfDeleteCourseFeeId.Value = courseFeeId.ToString();
                ShowMessage("Confirm Delete", "Please confirm delete from the popup.");
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
            ShowMessage("Edit Mode", "Course fee loaded. You may now update the amount, course, or session.");
        }

        protected void btnConfirmDeleteCourseFee_Click(object sender, EventArgs e)
        {
            int courseFeeId;
            if (!int.TryParse(hfDeleteCourseFeeId.Value, out courseFeeId))
            {
                ShowMessage("Error", "Invalid course fee selected for delete.");
                return;
            }

            try
            {
                SqlParameter[] p = { new SqlParameter("@CourseFeeId", courseFeeId) };
                DatabaseHelper.ExecuteNonQuery("DELETE FROM CourseFees WHERE CourseFeeId = @CourseFeeId", p);
                hfDeleteCourseFeeId.Value = "";
                ClearCourseFeeForm();
                LoadCourseFees();
                ShowMessage("Success", "Course fee deleted successfully.");
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Error: " + ex.Message);
            }
        }

        protected void btnClearCourseFee_Click(object sender, EventArgs e)
        {
            ClearCourseFeeForm();
            ShowMessage("Cleared", "Course fee form has been cleared.");
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
            if (e.CommandName == "SuspendStudent")
            {
                string studentId = e.CommandArgument.ToString();
                SuspendStudent(studentId, "Payment not completed");
                LoadStats();
                LoadPayments();
                ShowMessage("Success", "Student account suspended successfully. The student can still login to complete payment.");
                return;
            }

            if (e.CommandName == "UnsuspendStudent")
            {
                string studentId = e.CommandArgument.ToString();
                UnsuspendStudent(studentId);
                LoadStats();
                LoadPayments();
                ShowMessage("Success", "Student account unsuspended successfully.");
                return;
            }

            int feeId;
            if (!int.TryParse(e.CommandArgument.ToString(), out feeId)) return;

            if (e.CommandName == "ApprovePayment")
            {
                UpdatePaymentStatus(feeId, "Paid");
                ShowMessage("Success", "Payment approved successfully. Student suspension has been removed if the account was suspended.");
            }
            else if (e.CommandName == "RejectPayment")
            {
                UpdatePaymentStatus(feeId, "Rejected");
                ShowMessage("Success", "Payment rejected successfully.");
            }

            LoadStats();
            LoadPayments();
        }

        private void UpdatePaymentStatus(int feeId, string status)
        {
            string readSql = "SELECT StudentId, Session, FeeType FROM Fees WHERE FeeId = @FeeId";
            DataTable dt = DatabaseHelper.ExecuteQuery(readSql, new[] { new SqlParameter("@FeeId", feeId) });
            if (dt.Rows.Count == 0) return;

            string studentId = dt.Rows[0]["StudentId"].ToString();
            string session = dt.Rows[0]["Session"].ToString();
            string feeType = dt.Rows[0]["FeeType"].ToString();

            string sql = @"
                UPDATE Fees
                SET Status = @Status,
                    PaymentDate = CASE WHEN @Status = 'Paid' THEN GETDATE() ELSE NULL END,
                    PaymentReceiptPath = CASE WHEN @Status = 'Rejected' THEN NULL ELSE PaymentReceiptPath END,
                    PaymentReceiptUploadedAt = CASE WHEN @Status = 'Rejected' THEN NULL ELSE PaymentReceiptUploadedAt END
                WHERE FeeId = @FeeId";

            SqlParameter[] p =
            {
                new SqlParameter("@Status", status),
                new SqlParameter("@FeeId", feeId)
            };

            int rows = DatabaseHelper.ExecuteNonQuery(sql, p);

            if (rows > 0)
            {
                if (status == "Paid")
                {
                    UnsuspendStudent(studentId, false);
                }

                SendPaymentStatusNotificationToStudent(studentId, session, feeType, "PAY-" + feeId.ToString("D6"), status);
            }
        }

        private void SuspendStudent(string studentId, string reason)
        {
            string sql = @"
                UPDATE StudentDetails
                SET IsSuspended = 1,
                    SuspensionReason = @Reason,
                    SuspendedAt = GETDATE(),
                    SuspendedBy = @AdminId
                WHERE StudentId = @StudentId";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Reason", reason),
                new SqlParameter("@AdminId", GetCurrentAdminId())
            });

            SendSuspensionNotificationToStudent(studentId, true, reason);
        }

        private void UnsuspendStudent(string studentId, bool sendNotification = true)
        {
            string sql = @"
                UPDATE StudentDetails
                SET IsSuspended = 0,
                    SuspensionReason = NULL,
                    SuspendedAt = NULL,
                    SuspendedBy = NULL
                WHERE StudentId = @StudentId";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId)
            });

            if (sendNotification)
            {
                SendSuspensionNotificationToStudent(studentId, false, "Payment completed / account reactivated");
            }
        }

        private void SendSuspensionNotificationToStudent(string studentId, bool isSuspended, string reason)
        {
            string title = isSuspended ? "Account Suspended" : "Account Reactivated";
            string message = isSuspended
                ? "Your student account has been suspended because payment has not been completed. You can still login to upload your payment receipt."
                : "Your student account has been reactivated. You may now access your courses, attendance, enrollment and results again.";

            string sql = @"
                INSERT INTO Notifications (UserId, Title, Message, IsRead, CreatedAt)
                SELECT
                    s.UserId,
                    @Title,
                    @Message + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'Reason: ' + @Reason,
                    0,
                    GETDATE()
                FROM StudentDetails s
                INNER JOIN Users u ON u.UserId = s.UserId
                WHERE s.StudentId = @StudentId
                  AND u.IsActive = 1";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Title", title),
                new SqlParameter("@Message", message),
                new SqlParameter("@Reason", reason)
            });
        }

        private string GetCurrentAdminId()
        {
            if (Session["UserId"] != null) return Session["UserId"].ToString();
            if (Session["HoPId"] != null) return Session["HoPId"].ToString();
            if (Session["AdminId"] != null) return Session["AdminId"].ToString();
            if (Session["Username"] != null) return Session["Username"].ToString();

            return "Admin";
        }

        private void SendPaymentStatusNotificationToStudent(string studentId, string session, string feeType, string paymentRef, string status)
        {
            string title = status == "Paid" ? "Payment Approved" : "Payment Rejected";
            string statusText = status == "Paid" ? "approved" : "rejected";

            string sql = @"
                INSERT INTO Notifications (UserId, Title, Message, IsRead, CreatedAt)
                SELECT
                    s.UserId,
                    @Title,
                    'Your payment has been ' + @StatusText + ' by admin.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                    'Payment Ref: ' + @PaymentRef + CHAR(13) + CHAR(10) +
                    'Session: ' + @Session + CHAR(13) + CHAR(10) +
                    'Fee Type: ' + @FeeType + CHAR(13) + CHAR(10) +
                    CASE WHEN @Status = 'Paid'
                         THEN 'Payment Status: Paid'
                         ELSE 'Payment Status: Rejected. Please upload a new valid receipt if required.'
                    END,
                    0,
                    GETDATE()
                FROM StudentDetails s
                INNER JOIN Users u ON u.UserId = s.UserId
                WHERE s.StudentId = @StudentId
                  AND u.IsActive = 1";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session),
                new SqlParameter("@FeeType", feeType),
                new SqlParameter("@PaymentRef", paymentRef),
                new SqlParameter("@Status", status),
                new SqlParameter("@Title", title),
                new SqlParameter("@StatusText", statusText)
            });
        }

        protected void gvPayments_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

            string status = DataBinder.Eval(e.Row.DataItem, "DisplayStatus").ToString();
            string receiptPath = DataBinder.Eval(e.Row.DataItem, "PaymentReceiptPath").ToString();

            bool isSuspended = Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "IsSuspended"));

            LinkButton approve = e.Row.FindControl("btnApprove") as LinkButton;
            LinkButton reject = e.Row.FindControl("btnReject") as LinkButton;
            LinkButton suspend = e.Row.FindControl("btnSuspend") as LinkButton;
            LinkButton unsuspend = e.Row.FindControl("btnUnsuspend") as LinkButton;

            // Dropped-before-payment rows are displayed as Not Active history, so no admin payment action is needed.
            if (status == "Not Active" && e.Row.Cells.Count > 0)
            {
                TableCell actionCell = e.Row.Cells[e.Row.Cells.Count - 1];
                actionCell.Controls.Clear();
                actionCell.Controls.Add(new LiteralControl("<span class='no-admin-action'>No payment action required</span>"));
                return;
            }

            // Offline payment support:
            // Admin can approve Pending / Overdue / Rejected records even if no receipt was uploaded.
            bool canApprovePayment = status == "Pending" || status == "Overdue" || status == "Rejected";

            // Reject is only useful when a receipt has been uploaded and needs to be rejected.
            bool canRejectPayment = (status == "Pending" || status == "Overdue") && !string.IsNullOrWhiteSpace(receiptPath);

            if (approve != null)
                approve.Visible = canApprovePayment;

            if (reject != null)
                reject.Visible = canRejectPayment;

            bool canSuspendForPayment = status == "Pending" || status == "Rejected" || status == "Overdue";

            if (suspend != null)
                suspend.Visible = canSuspendForPayment && !isSuspended;

            if (unsuspend != null)
                unsuspend.Visible = isSuspended;
        }


        protected string GetAccountStatusText(object isSuspendedObj)
        {
            bool isSuspended = isSuspendedObj != null && isSuspendedObj != DBNull.Value && Convert.ToBoolean(isSuspendedObj);
            return isSuspended ? "Suspended" : "Active";
        }

        protected string GetAccountStatusCss(object isSuspendedObj)
        {
            bool isSuspended = isSuspendedObj != null && isSuspendedObj != DBNull.Value && Convert.ToBoolean(isSuspendedObj);
            return isSuspended ? "status-suspended" : "status-active-account";
        }

        protected string GetSuspensionReason(object isSuspendedObj, object reasonObj)
        {
            bool isSuspended = isSuspendedObj != null && isSuspendedObj != DBNull.Value && Convert.ToBoolean(isSuspendedObj);
            string reason = reasonObj == null || reasonObj == DBNull.Value ? "" : reasonObj.ToString();

            if (!isSuspended || string.IsNullOrWhiteSpace(reason))
                return "";

            return "<span class='suspension-reason'>Reason: " + HttpUtility.HtmlEncode(reason) + "</span>";
        }

        protected string GetReceiptLink(object receiptPathObj)
        {
            string receiptPath = receiptPathObj == null ? "" : receiptPathObj.ToString().Trim();

            if (string.IsNullOrWhiteSpace(receiptPath))
            {
                return "<span class='receipt-empty'>No receipt uploaded</span>";
            }

            string safeUrl = ResolveUrl(receiptPath);
            return "<a class='receipt-link' href='" + HttpUtility.HtmlAttributeEncode(safeUrl) + "' target='_blank'><i class='fa-solid fa-eye'></i> View Receipt</a>";
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

                case "Not Active":
                    return "status-not-active";

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
