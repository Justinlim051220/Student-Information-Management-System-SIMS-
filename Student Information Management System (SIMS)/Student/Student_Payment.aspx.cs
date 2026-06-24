using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class Student_Payment : Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["SIMSConnection"].ConnectionString;
        private const int MaxReceiptBytes = 5 * 1024 * 1024;

        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            string studentId = SessionHelper.GetProfileId(Session);

            if (string.IsNullOrWhiteSpace(studentId))
                studentId = GetCurrentStudentId();

            // Keep the suspension warning visible after Refresh / filter postbacks.
            LoadSuspensionPaymentWarning(studentId);

            if (!IsPostBack)
            {
                string fullName = SessionHelper.GetFullName(Session);

                lblStudentName.Text = string.IsNullOrWhiteSpace(fullName) ? "Student" : fullName;
                lblStudentId.Text = studentId;
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadStudentInfo(studentId);
                LoadSessionFilter(studentId);
                LoadStats(studentId);
                LoadPayments(studentId);
            }
        }



        private void LoadSuspensionPaymentWarning(string studentId)
        {
            bool isSuspended = false;
            string reason = "Payment not completed";

            try
            {
                object columnExists = DatabaseHelper.ExecuteScalar(@"
                    SELECT CASE
                        WHEN COL_LENGTH('dbo.StudentDetails', 'IsSuspended') IS NULL THEN 0
                        ELSE 1
                    END");

                if (columnExists != null && columnExists != DBNull.Value && Convert.ToInt32(columnExists) == 1)
                {
                    DataTable dt = DatabaseHelper.ExecuteQuery(@"
                        SELECT TOP 1
                               IsSuspended,
                               ISNULL(NULLIF(LTRIM(RTRIM(SuspensionReason)), ''), 'Payment not completed') AS SuspensionReason
                        FROM StudentDetails
                        WHERE StudentId = @StudentId",
                        new[] { new SqlParameter("@StudentId", studentId) });

                    if (dt.Rows.Count > 0)
                    {
                        isSuspended = dt.Rows[0]["IsSuspended"] != DBNull.Value && Convert.ToBoolean(dt.Rows[0]["IsSuspended"]);
                        reason = Convert.ToString(dt.Rows[0]["SuspensionReason"]);
                    }
                }
            }
            catch
            {
                isSuspended = false;
            }

            bool redirectedForSuspension = string.Equals(Request.QueryString["suspended"], "1", StringComparison.OrdinalIgnoreCase);

            if (!isSuspended && !redirectedForSuspension)
                return;

            if (string.IsNullOrWhiteSpace(reason))
                reason = "Payment not completed";

            string safeReason = HttpUtility.JavaScriptStringEncode(reason);

            string script = @"
                (function () {
                    function showPaymentSuspensionWarning() {
                        var pageHeader = document.querySelector('.page-header');
                        if (!pageHeader || document.getElementById('paymentSuspensionWarning')) return;

                        var warning = document.createElement('div');
                        warning.id = 'paymentSuspensionWarning';
                        warning.className = 'payment-suspension-warning';
                        warning.innerHTML =
                            '<div class=""payment-suspension-warning-icon""><i class=""fa-solid fa-triangle-exclamation""></i></div>' +
                            '<div>' +
                                '<div class=""payment-suspension-warning-title"">Account temporarily suspended</div>' +
                                '<div class=""payment-suspension-warning-text"">Your account access is limited because there is an unpaid or pending fee. Please upload your payment receipt and wait for admin approval to restore access.</div>' +
                                '<div class=""payment-suspension-warning-reason"">Reason: " + safeReason + @"</div>' +
                            '</div>';

                        pageHeader.parentNode.insertBefore(warning, pageHeader.nextSibling);
                    }

                    if (document.readyState === 'loading') {
                        document.addEventListener('DOMContentLoaded', showPaymentSuspensionWarning);
                    } else {
                        showPaymentSuspensionWarning();
                    }
                })();";

            ClientScript.RegisterStartupScript(
                GetType(),
                "ShowPaymentSuspensionWarning",
                script,
                true);
        }

        private void LoadStudentInfo(string studentId)
        {
            string sql = @"
                SELECT p.ProgrammeCode + ' - ' + p.ProgrammeName AS ProgrammeDisplay
                FROM StudentDetails s
                INNER JOIN Programmes p ON p.ProgrammeId = s.ProgrammeId
                WHERE s.StudentId = @StudentId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@StudentId", studentId) });
            lblProgramme.Text = dt.Rows.Count > 0 ? dt.Rows[0]["ProgrammeDisplay"].ToString() : "-";
        }

        private void LoadSessionFilter(string studentId)
        {
            string selected = ddlSession.SelectedValue;

            ddlSession.Items.Clear();
            ddlSession.Items.Add(new ListItem("-- All Sessions --", ""));

            string sql = @"
                SELECT DISTINCT Session
                FROM Fees
                WHERE StudentId = @StudentId
                ORDER BY Session DESC";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@StudentId", studentId) });

            foreach (DataRow row in dt.Rows)
                ddlSession.Items.Add(new ListItem(row["Session"].ToString(), row["Session"].ToString()));

            if (!string.IsNullOrWhiteSpace(selected) && ddlSession.Items.FindByValue(selected) != null)
                ddlSession.SelectedValue = selected;
        }

        private void LoadStats(string studentId)
        {
            string baseWhere = @"
                FROM Fees f
                LEFT JOIN Enrollment e ON e.EnrollmentId = f.EnrollmentId
                WHERE f.StudentId = @StudentId
                  AND f.Status = 'Pending'
                  AND NOT (
                      ISNULL(e.Status, '') IN ('Drop Pending', 'Dropped')
                      AND ISNULL(f.PaymentReceiptPath, '') = ''
                  )";

            string countSql = "SELECT COUNT(DISTINCT f.PaymentGroupId) " + baseWhere;
            string amountSql = "SELECT ISNULL(SUM(f.Amount), 0) " + baseWhere;

            lblPendingCount.Text = Convert.ToInt32(DatabaseHelper.ExecuteScalar(
                countSql,
                new[] { new SqlParameter("@StudentId", studentId) })).ToString();

            lblPendingAmount.Text = Convert.ToDecimal(DatabaseHelper.ExecuteScalar(
                amountSql,
                new[] { new SqlParameter("@StudentId", studentId) })).ToString("N2");
        }

        private void LoadPayments(string studentId)
        {
            string sql = @"
                WITH FeeRows AS
                (
                    SELECT f.PaymentGroupId,
                           f.FeeId,
                           ISNULL(f.EnrollmentId, 0) AS EnrollmentId,
                           f.StudentId,
                           f.Session,
                           f.FeeType,
                           f.Amount,
                           CASE
                               WHEN ISNULL(e.Status, '') IN ('Drop Pending', 'Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                                    AND f.Status = 'Pending'
                                    AND ISNULL(f.PaymentReceiptPath, '') = ''
                               THEN CAST(0 AS DECIMAL(18,2))
                               ELSE f.Amount
                           END AS DisplayAmountRow,
                           CASE
                               WHEN ISNULL(e.Status, '') IN ('Drop Pending', 'Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                                    AND f.Status = 'Pending'
                                    AND ISNULL(f.PaymentReceiptPath, '') = ''
                               THEN 'Not Active'
                               ELSE f.Status
                           END AS DisplayStatusRow,
                           f.PaymentDate,
                           ISNULL(f.PaymentReceiptPath, '') AS PaymentReceiptPath,
                           c.CourseCode,
                           c.CourseName
                    FROM Fees f
                    LEFT JOIN Enrollment e ON e.EnrollmentId = f.EnrollmentId
                    LEFT JOIN Courses c ON c.CourseId = e.CourseId
                    WHERE f.StudentId = @StudentId
                      AND (@Session = '' OR f.Session = @Session)
                ),
                PaymentGroups AS
                (
                    SELECT PaymentGroupId,
                           MIN(FeeId) AS FeeId,
                           MIN(EnrollmentId) AS EnrollmentId,
                           StudentId,
                           Session,
                           MIN(FeeType) AS FeeType,
                           SUM(DisplayAmountRow) AS DisplayAmount,
                           CASE
                               WHEN SUM(CASE WHEN DisplayStatusRow <> 'Not Active' THEN 1 ELSE 0 END) = 0 THEN 'Not Active'
                               WHEN SUM(CASE WHEN DisplayStatusRow = 'Rejected' THEN 1 ELSE 0 END) > 0 THEN 'Rejected'
                               WHEN SUM(CASE WHEN DisplayStatusRow = 'Overdue' THEN 1 ELSE 0 END) > 0 THEN 'Overdue'
                               WHEN SUM(CASE WHEN DisplayStatusRow <> 'Paid' THEN 1 ELSE 0 END) = 0 THEN 'Paid'
                               ELSE 'Pending'
                           END AS DisplayStatus,
                           MAX(PaymentDate) AS PaymentDate,
                           MAX(PaymentReceiptPath) AS PaymentReceiptPath
                    FROM FeeRows
                    GROUP BY PaymentGroupId, StudentId, Session
                )
                SELECT CAST(g.PaymentGroupId AS VARCHAR(36)) AS PaymentGroupId,
                       g.FeeId,
                       g.EnrollmentId,
                       ('PAY-' + RIGHT('000000' + CAST(g.FeeId AS VARCHAR(6)), 6)) AS PaymentId,
                       g.StudentId,
                       g.Session,
                       g.FeeType,
                       g.DisplayAmount,
                       g.DisplayStatus,
                       g.PaymentDate,
                       g.PaymentReceiptPath,
                       ISNULL(NULLIF((
                           SELECT '<div class=""payment-course-line""><span class=""payment-course-code"">' + ISNULL(fr.CourseCode, 'N/A') + '</span><span class=""payment-course-name"">' + ISNULL(fr.CourseName, 'Legacy payment record') + '</span><span class=""payment-course-fee"">RM ' + FORMAT(fr.DisplayAmountRow, 'N2') + '</span></div>'
                           FROM FeeRows fr
                           WHERE fr.PaymentGroupId = g.PaymentGroupId
                           ORDER BY ISNULL(fr.CourseCode, 'ZZZ')
                           FOR XML PATH(''), TYPE
                       ).value('.', 'NVARCHAR(MAX)'), ''), '<span class=""receipt-empty"">Legacy payment record</span>') AS CoursePaymentList
                FROM PaymentGroups g
                WHERE (@Status = '' OR g.DisplayStatus = @Status)
                ORDER BY CASE g.DisplayStatus
                            WHEN 'Pending' THEN 0
                            WHEN 'Rejected' THEN 1
                            WHEN 'Overdue' THEN 2
                            WHEN 'Paid' THEN 3
                            WHEN 'Not Active' THEN 4
                            ELSE 5
                         END,
                         g.FeeId DESC";

            SqlParameter[] p =
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", ddlSession.SelectedValue ?? ""),
                new SqlParameter("@Status", ddlStatus.SelectedValue ?? "")
            };

            gvPayments.DataSource = DatabaseHelper.ExecuteQuery(sql, p);
            gvPayments.DataBind();
        }

        protected void ddlSession_SelectedIndexChanged(object sender, EventArgs e)
        {
            string studentId = SessionHelper.GetProfileId(Session);
            LoadStats(studentId);
            LoadPayments(studentId);
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            string studentId = SessionHelper.GetProfileId(Session);
            LoadStats(studentId);
            LoadPayments(studentId);
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            string studentId = SessionHelper.GetProfileId(Session);

            if (string.IsNullOrWhiteSpace(studentId))
                studentId = GetCurrentStudentId();

            LoadSessionFilter(studentId);
            LoadStats(studentId);
            LoadPayments(studentId);
        }

        protected void gvPayments_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int rowIndex;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out rowIndex))
                return;

            if (rowIndex < 0 || rowIndex >= gvPayments.Rows.Count)
                return;

            string paymentGroupId = Convert.ToString(gvPayments.DataKeys[rowIndex].Values["PaymentGroupId"]);

            if (string.IsNullOrWhiteSpace(paymentGroupId))
                return;

            if (e.CommandName == "ViewPayment")
            {
                LoadPaymentDetail(paymentGroupId);
            }
            else if (e.CommandName == "UploadReceipt")
            {
                GridViewRow row = gvPayments.Rows[rowIndex];
                FileUpload fu = FindControlRecursive(row, "fuReceipt") as FileUpload;
                UploadReceipt(paymentGroupId, fu);
            }
        }

        protected void gvPayments_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow)
                return;

            string status = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "DisplayStatus"));
            string receiptPath = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "PaymentReceiptPath"));

            Label lblStatusBadge = FindControlRecursive(e.Row, "lblStatusBadge") as Label;
            Literal litReceipt = FindControlRecursive(e.Row, "litReceipt") as Literal;
            LinkButton btnUpload = FindControlRecursive(e.Row, "btnUpload") as LinkButton;
            FileUpload fuReceipt = FindControlRecursive(e.Row, "fuReceipt") as FileUpload;
            Label lblActionNote = FindControlRecursive(e.Row, "lblActionNote") as Label;
            HtmlGenericControl uploadBox = FindControlRecursive(e.Row, "uploadBox") as HtmlGenericControl;

            if (lblStatusBadge != null)
            {
                lblStatusBadge.Text = HttpUtility.HtmlEncode(status);
                lblStatusBadge.CssClass = "status-badge " + GetStatusCss(status);
            }

            if (litReceipt != null)
                litReceipt.Text = BuildReceiptLink(receiptPath);

            bool hasReceipt = !string.IsNullOrWhiteSpace(receiptPath);
            bool canUpload = !hasReceipt && (status == "Pending" || status == "Rejected");

            if (uploadBox != null) uploadBox.Visible = canUpload;
            if (btnUpload != null) btnUpload.Visible = canUpload;
            if (fuReceipt != null) fuReceipt.Visible = canUpload;

            if (lblActionNote != null)
            {
                if (hasReceipt)
                {
                    lblActionNote.CssClass = "receipt-uploaded";
                    lblActionNote.Text = "Receipt uploaded successfully.";
                }
                else if (status == "Paid")
                {
                    lblActionNote.CssClass = "receipt-uploaded";
                    lblActionNote.Text = "Payment approved.";
                }
                else if (status == "Not Active")
                {
                    lblActionNote.CssClass = "not-active-note";
                    lblActionNote.Text = "No payment action required.";
                }
                else
                {
                    lblActionNote.Text = string.Empty;
                    lblActionNote.CssClass = "receipt-empty";
                }
            }
        }

        private Control FindControlRecursive(Control root, string id)
        {
            if (root == null)
                return null;

            if (root.ID == id)
                return root;

            foreach (Control child in root.Controls)
            {
                Control found = FindControlRecursive(child, id);
                if (found != null)
                    return found;
            }

            return null;
        }

        private void LoadPaymentDetail(string paymentGroupId)
        {
            string studentId = SessionHelper.GetProfileId(Session);

            string sql = @"
                WITH FeeRows AS
                (
                    SELECT f.PaymentGroupId,
                           f.FeeId,
                           f.StudentId,
                           f.Session,
                           f.FeeType,
                           f.Amount,
                           CASE
                               WHEN ISNULL(e.Status, '') IN ('Drop Pending', 'Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                                    AND f.Status = 'Pending'
                                    AND ISNULL(f.PaymentReceiptPath, '') = ''
                               THEN CAST(0 AS DECIMAL(18,2))
                               ELSE f.Amount
                           END AS DisplayAmountRow,
                           CASE
                               WHEN ISNULL(e.Status, '') IN ('Drop Pending', 'Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                                    AND f.Status = 'Pending'
                                    AND ISNULL(f.PaymentReceiptPath, '') = ''
                               THEN 'Not Active'
                               ELSE f.Status
                           END AS DisplayStatusRow
                    FROM Fees f
                    LEFT JOIN Enrollment e ON e.EnrollmentId = f.EnrollmentId
                    WHERE f.StudentId = @StudentId
                      AND f.PaymentGroupId = @PaymentGroupId
                )
                SELECT ('PAY-' + RIGHT('000000' + CAST(MIN(FeeId) AS VARCHAR(6)), 6)) AS PaymentId,
                       CAST(PaymentGroupId AS VARCHAR(36)) AS PaymentGroupId,
                       Session,
                       MIN(FeeType) AS FeeType,
                       SUM(DisplayAmountRow) AS DisplayAmount,
                       CASE
                           WHEN SUM(CASE WHEN DisplayStatusRow <> 'Not Active' THEN 1 ELSE 0 END) = 0 THEN 'Not Active'
                           WHEN SUM(CASE WHEN DisplayStatusRow = 'Rejected' THEN 1 ELSE 0 END) > 0 THEN 'Rejected'
                           WHEN SUM(CASE WHEN DisplayStatusRow = 'Overdue' THEN 1 ELSE 0 END) > 0 THEN 'Overdue'
                           WHEN SUM(CASE WHEN DisplayStatusRow <> 'Paid' THEN 1 ELSE 0 END) = 0 THEN 'Paid'
                           ELSE 'Pending'
                       END AS DisplayStatus
                FROM FeeRows
                GROUP BY PaymentGroupId, Session";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@PaymentGroupId", Guid.Parse(paymentGroupId))
            });

            if (dt.Rows.Count == 0)
            {
                ShowMessage("Payment record cannot be found.", "error");
                return;
            }

            DataRow row = dt.Rows[0];

            txtDetailPaymentId.Text = row["PaymentId"].ToString();
            txtDetailSession.Text = row["Session"].ToString();
            txtDetailStatus.Text = row["DisplayStatus"].ToString();
            txtDetailAmount.Text = "RM " + Convert.ToDecimal(row["DisplayAmount"]).ToString("N2");
            litDetailCourses.Text = GetCoursePaymentHtml(paymentGroupId);

            pnlDetail.Visible = true;
        }

        private string GetCoursePaymentHtml(string paymentGroupId)
        {
            string studentId = SessionHelper.GetProfileId(Session);

            string sql = @"
                SELECT c.CourseCode,
                       c.CourseName,
                       CASE
                           WHEN ISNULL(e.Status, '') IN ('Drop Pending', 'Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                                AND f.Status = 'Pending'
                                AND ISNULL(f.PaymentReceiptPath, '') = ''
                           THEN CAST(0 AS DECIMAL(18,2))
                           ELSE f.Amount
                       END AS DisplayAmount
                FROM Fees f
                LEFT JOIN Enrollment e ON e.EnrollmentId = f.EnrollmentId
                LEFT JOIN Courses c ON e.CourseId = c.CourseId
                WHERE f.StudentId = @StudentId
                  AND f.PaymentGroupId = @PaymentGroupId
                ORDER BY c.CourseCode";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@PaymentGroupId", Guid.Parse(paymentGroupId))
            });

            if (dt.Rows.Count == 0)
                return "<span class='receipt-empty'>Payment group not found.</span>";

            string html = "<div class='payment-course-list'>";

            foreach (DataRow r in dt.Rows)
            {
                string code = r["CourseCode"] == DBNull.Value ? "N/A" : r["CourseCode"].ToString();
                string name = r["CourseName"] == DBNull.Value ? "Legacy payment record" : r["CourseName"].ToString();
                decimal amount = Convert.ToDecimal(r["DisplayAmount"]);

                html += "<div class='payment-course-line'><span class='payment-course-code'>"
                    + HttpUtility.HtmlEncode(code)
                    + "</span><span class='payment-course-name'>"
                    + HttpUtility.HtmlEncode(name)
                    + "</span><span class='payment-course-fee'>RM "
                    + amount.ToString("N2")
                    + "</span></div>";
            }

            html += "</div>";
            return html;
        }

        private void UploadReceipt(string paymentGroupId, FileUpload fu)
        {
            string studentId = SessionHelper.GetProfileId(Session);

            if (fu == null || !fu.HasFile)
            {
                ShowMessage("Please choose a receipt file before uploading.", "error");
                return;
            }

            DataTable payment = GetStudentPayment(paymentGroupId, studentId);

            if (payment.Rows.Count == 0)
            {
                ShowMessage("Invalid payment selected.", "error");
                return;
            }

            DataRow paymentRow = payment.Rows[0];
            int firstFeeId = Convert.ToInt32(paymentRow["FeeId"]);
            string session = paymentRow["Session"].ToString();
            string feeType = paymentRow["FeeType"].ToString();
            string existingReceipt = paymentRow["PaymentReceiptPath"].ToString();
            string status = paymentRow["Status"].ToString();
            int payableRowCount = Convert.ToInt32(paymentRow["PayableRowCount"]);
            string paymentRef = "PAY-" + firstFeeId.ToString("D6");

            if (!string.IsNullOrWhiteSpace(existingReceipt))
            {
                ShowMessage("Receipt already uploaded. You cannot upload another receipt for this payment.", "error");
                return;
            }

            if (status == "Paid")
            {
                ShowMessage("This payment has already been approved. Receipt cannot be uploaded.", "error");
                return;
            }

            if (payableRowCount == 0 || status == "Not Active")
            {
                ShowMessage("This enrollment is not active. No payment action is required.", "error");
                return;
            }

            if (fu.PostedFile.ContentLength > MaxReceiptBytes)
            {
                ShowMessage("Receipt file size cannot be more than 5 MB.", "error");
                return;
            }

            string ext = Path.GetExtension(fu.FileName).ToLowerInvariant();

            if (ext != ".pdf" && ext != ".jpg" && ext != ".jpeg" && ext != ".png")
            {
                ShowMessage("Only PDF, JPG, JPEG, or PNG receipt files are allowed.", "error");
                return;
            }

            string folderRelative = "~/Student/PaymentReceipt/" + MakeSafeFolderName("PAY_" + firstFeeId.ToString()) + "/";
            string folderPhysical = Server.MapPath(folderRelative);

            if (!Directory.Exists(folderPhysical))
                Directory.CreateDirectory(folderPhysical);

            string safeFileName = "receipt_" + DateTime.Now.ToString("yyyyMMddHHmmss") + ext;
            string physicalPath = Path.Combine(folderPhysical, safeFileName);
            fu.SaveAs(physicalPath);

            string dbPath = folderRelative + safeFileName;

            string updateSql = @"
                UPDATE Fees
                SET PaymentReceiptPath = @PaymentReceiptPath,
                    PaymentReceiptUploadedAt = GETDATE(),
                    Status = 'Pending'
                WHERE PaymentGroupId = @PaymentGroupId
                  AND StudentId = @StudentId
                  AND (PaymentReceiptPath IS NULL OR LTRIM(RTRIM(PaymentReceiptPath)) = '')";

            int affected = DatabaseHelper.ExecuteNonQuery(updateSql, new[]
            {
                new SqlParameter("@PaymentReceiptPath", dbPath),
                new SqlParameter("@PaymentGroupId", Guid.Parse(paymentGroupId)),
                new SqlParameter("@StudentId", studentId)
            });

            if (affected == 0)
            {
                ShowMessage("Receipt already uploaded. You cannot upload another receipt for this payment.", "error");
                return;
            }

            NotifyAdminsPaymentReceiptUploaded(studentId, session, feeType, paymentRef, dbPath);

            LoadSessionFilter(studentId);
            LoadStats(studentId);
            LoadPayments(studentId);

            ShowMessage("Receipt uploaded successfully for all course(s) in this payment. Please wait for admin verification.", "success");
        }

        private DataTable GetStudentPayment(string paymentGroupId, string studentId)
        {
            string sql = @"
                WITH FeeRows AS
                (
                    SELECT f.PaymentGroupId,
                           f.FeeId,
                           f.StudentId,
                           f.Session,
                           f.FeeType,
                           f.Status,
                           ISNULL(f.PaymentReceiptPath, '') AS PaymentReceiptPath,
                           CASE
                               WHEN ISNULL(e.Status, '') IN ('Drop Pending', 'Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                                    AND f.Status = 'Pending'
                                    AND ISNULL(f.PaymentReceiptPath, '') = ''
                               THEN 0
                               ELSE 1
                           END AS IsPayable,
                           CASE
                               WHEN ISNULL(e.Status, '') IN ('Drop Pending', 'Dropped', 'Drop Approved', 'Not Active', 'Inactive')
                                    AND f.Status = 'Pending'
                                    AND ISNULL(f.PaymentReceiptPath, '') = ''
                               THEN 'Not Active'
                               ELSE f.Status
                           END AS DisplayStatusRow
                    FROM Fees f
                    LEFT JOIN Enrollment e ON e.EnrollmentId = f.EnrollmentId
                    WHERE f.PaymentGroupId = @PaymentGroupId
                      AND f.StudentId = @StudentId
                )
                SELECT MIN(FeeId) AS FeeId,
                       CAST(PaymentGroupId AS VARCHAR(36)) AS PaymentGroupId,
                       StudentId,
                       Session,
                       MIN(FeeType) AS FeeType,
                       CASE
                           WHEN SUM(CASE WHEN DisplayStatusRow <> 'Not Active' THEN 1 ELSE 0 END) = 0 THEN 'Not Active'
                           WHEN SUM(CASE WHEN DisplayStatusRow = 'Rejected' THEN 1 ELSE 0 END) > 0 THEN 'Rejected'
                           WHEN SUM(CASE WHEN DisplayStatusRow = 'Overdue' THEN 1 ELSE 0 END) > 0 THEN 'Overdue'
                           WHEN SUM(CASE WHEN DisplayStatusRow <> 'Paid' THEN 1 ELSE 0 END) = 0 THEN 'Paid'
                           ELSE 'Pending'
                       END AS Status,
                       MAX(PaymentReceiptPath) AS PaymentReceiptPath,
                       SUM(IsPayable) AS PayableRowCount
                FROM FeeRows
                GROUP BY PaymentGroupId, StudentId, Session";

            return DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@PaymentGroupId", Guid.Parse(paymentGroupId)),
                new SqlParameter("@StudentId", studentId)
            });
        }

        private void NotifyAdminsPaymentReceiptUploaded(string studentId, string session, string feeType, string paymentRef, string receiptPath)
        {
            string sql = @"
                INSERT INTO Notifications (UserId, Title, Message, IsRead, CreatedAt)
                SELECT
                    h.UserId,
                    'New Payment Receipt Uploaded',
                    'A student has uploaded a payment receipt for admin verification.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                    'Payment Ref: ' + @PaymentRef + CHAR(13) + CHAR(10) +
                    'Student ID: ' + s.StudentId + CHAR(13) + CHAR(10) +
                    'Student Name: ' + s.FirstName + ' ' + s.LastName + CHAR(13) + CHAR(10) +
                    'Session: ' + @Session + CHAR(13) + CHAR(10) +
                    'Fee Type: ' + @FeeType + CHAR(13) + CHAR(10) +
                    'Receipt: ' + @ReceiptPath,
                    0,
                    GETDATE()
                FROM HoPDetails h
                INNER JOIN Users u ON u.UserId = h.UserId
                CROSS JOIN StudentDetails s
                WHERE s.StudentId = @StudentId
                  AND u.IsActive = 1";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session),
                new SqlParameter("@FeeType", feeType),
                new SqlParameter("@PaymentRef", paymentRef),
                new SqlParameter("@ReceiptPath", receiptPath)
            });
        }

        private string MakeSafeFolderName(string value)
        {
            foreach (char c in Path.GetInvalidFileNameChars())
                value = value.Replace(c, '_');

            return value.Replace(" ", "_").Replace("/", "_").Replace("\\", "_");
        }

        private string BuildReceiptLink(string receiptPath)
        {
            if (string.IsNullOrWhiteSpace(receiptPath))
                return "<span class='receipt-empty'>No receipt uploaded</span>";

            string safeUrl = ResolveUrl(receiptPath);

            return "<a class='receipt-link' href='"
                + HttpUtility.HtmlAttributeEncode(safeUrl)
                + "' target='_blank'><i class='fa-solid fa-eye'></i> View Receipt</a>";
        }

        private string GetStatusCss(string status)
        {
            switch (status)
            {
                case "Paid":
                    return "status-paid";
                case "Pending":
                    return "status-pending";
                case "Rejected":
                    return "status-rejected";
                case "Overdue":
                    return "status-overdue";
                case "Not Active":
                    return "status-not-active";
                default:
                    return "status-pending";
            }
        }

        protected void btnCloseDetail_Click(object sender, EventArgs e)
        {
            pnlDetail.Visible = false;
        }

        private void ShowMessage(string message, string type)
        {
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

        private string GetCurrentStudentId()
        {
            string studentId = SessionHelper.GetProfileId(Session);

            if (!string.IsNullOrWhiteSpace(studentId))
                return studentId;

            if (Session["StudentId"] != null && !string.IsNullOrWhiteSpace(Session["StudentId"].ToString()))
                return Session["StudentId"].ToString();

            Response.Redirect("~/Login.aspx", true);
            return string.Empty;
        }
    }
}