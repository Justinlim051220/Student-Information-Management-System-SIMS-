using System.Configuration;
using System;
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

        private const int MaxReceiptBytes = 5 * 1024 * 1024; // 5 MB

        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                string fullName = SessionHelper.GetFullName(Session);
                string studentId = SessionHelper.GetProfileId(Session);
                string initial = !string.IsNullOrWhiteSpace(fullName) ? fullName.Trim()[0].ToString().ToUpper() : "S";
                lblStudentName.Text = fullName;
                lblStudentId.Text = studentId;
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

                LoadStudentInfo(studentId);
                LoadSessionFilter(studentId);
                LoadStats(studentId);
                LoadPayments(studentId);
            }
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
            {
                ddlSession.Items.Add(new ListItem(row["Session"].ToString(), row["Session"].ToString()));
            }

            if (!string.IsNullOrWhiteSpace(selected) && ddlSession.Items.FindByValue(selected) != null)
            {
                ddlSession.SelectedValue = selected;
            }
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

            string countSql = "SELECT COUNT(*) " + baseWhere;
            string amountSql = "SELECT ISNULL(SUM(f.Amount), 0) " + baseWhere;

            lblPendingCount.Text = Convert.ToInt32(DatabaseHelper.ExecuteScalar(countSql, new[] { new SqlParameter("@StudentId", studentId) })).ToString();
            lblPendingAmount.Text = Convert.ToDecimal(DatabaseHelper.ExecuteScalar(amountSql, new[] { new SqlParameter("@StudentId", studentId) })).ToString("N2");
        }

        private void LoadPayments(string studentId)
        {
            string sql = @"
                SELECT x.FeeId,
                       x.EnrollmentId,
                       ('PAY-' + RIGHT('000000' + CAST(x.FeeId AS VARCHAR(6)), 6)) AS PaymentId,
                       x.StudentId,
                       x.Session,
                       x.FeeType,
                       x.DisplayAmount,
                       x.DisplayStatus,
                       x.PaymentDate,
                       x.PaymentReceiptPath,
                       ISNULL('<div class=""payment-course-line""><span class=""payment-course-code"">' + x.CourseCode + '</span><span class=""payment-course-name"">' + x.CourseName + '</span><span class=""payment-course-fee"">RM ' + FORMAT(x.DisplayAmount, 'N2') + '</span></div>',
                           '<span class=""receipt-empty"">Legacy payment record</span>') AS CoursePaymentList
                FROM
                (
                    SELECT f.FeeId,
                           ISNULL(f.EnrollmentId, 0) AS EnrollmentId,
                           f.StudentId,
                           f.Session,
                           f.FeeType,
                           f.Amount,
                           CASE
                               WHEN ISNULL(e.Status, '') IN ('Drop Pending', 'Dropped')
                                    AND f.Status = 'Pending'
                                    AND ISNULL(f.PaymentReceiptPath, '') = ''
                               THEN CAST(0 AS DECIMAL(18,2))
                               ELSE f.Amount
                           END AS DisplayAmount,
                           CASE
                               WHEN ISNULL(e.Status, '') IN ('Drop Pending', 'Dropped')
                                    AND f.Status = 'Pending'
                                    AND ISNULL(f.PaymentReceiptPath, '') = ''
                               THEN 'Not Active'
                               ELSE f.Status
                           END AS DisplayStatus,
                           f.PaymentDate,
                           ISNULL(f.PaymentReceiptPath, '') AS PaymentReceiptPath,
                           c.CourseCode,
                           c.CourseName
                    FROM Fees f
                    LEFT JOIN Enrollment e ON e.EnrollmentId = f.EnrollmentId
                    LEFT JOIN Courses c ON c.CourseId = e.CourseId
                    WHERE f.StudentId = @StudentId
                      AND (@Session = '' OR f.Session = @Session)
                ) x
                WHERE (@Status = '' OR x.DisplayStatus = @Status)
                ORDER BY CASE x.DisplayStatus
                            WHEN 'Pending' THEN 0
                            WHEN 'Rejected' THEN 1
                            WHEN 'Overdue' THEN 2
                            WHEN 'Paid' THEN 3
                            WHEN 'Not Active' THEN 4
                            ELSE 5
                         END,
                         x.FeeId DESC";

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
            {
                studentId = GetCurrentStudentId();
            }

            LoadSessionFilter(studentId);
            LoadStats(studentId);
            LoadPayments(studentId);
        }

        private void BindPayments()
        {
            string studentId = SessionHelper.GetProfileId(Session);

            if (string.IsNullOrWhiteSpace(studentId))
            {
                studentId = GetCurrentStudentId();
            }

            LoadSessionFilter(studentId);
            LoadStats(studentId);
            LoadPayments(studentId);
        }

        protected void gvPayments_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int rowIndex;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out rowIndex)) return;
            if (rowIndex < 0 || rowIndex >= gvPayments.Rows.Count) return;

            int feeId = Convert.ToInt32(gvPayments.DataKeys[rowIndex].Values["FeeId"]);

            if (e.CommandName == "ViewPayment")
            {
                LoadPaymentDetail(feeId);
            }
            else if (e.CommandName == "UploadReceipt")
            {
                GridViewRow row = gvPayments.Rows[rowIndex];
                FileUpload fu = FindControlRecursive(row, "fuReceipt") as FileUpload;
                UploadReceipt(feeId, fu);
            }
        }

        protected void gvPayments_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

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
            {
                litReceipt.Text = BuildReceiptLink(receiptPath);
            }

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
            if (root == null) return null;
            if (root.ID == id) return root;

            foreach (Control child in root.Controls)
            {
                Control found = FindControlRecursive(child, id);
                if (found != null) return found;
            }

            return null;
        }

        private void LoadPaymentDetail(int feeId)
        {
            string studentId = SessionHelper.GetProfileId(Session);

            string sql = @"
                SELECT ('PAY-' + RIGHT('000000' + CAST(f.FeeId AS VARCHAR(6)), 6)) AS PaymentId,
                       f.FeeId,
                       f.EnrollmentId,
                       f.Session,
                       f.FeeType,
                       CASE
                           WHEN ISNULL(e.Status, '') IN ('Drop Pending', 'Dropped')
                                AND f.Status = 'Pending'
                                AND ISNULL(f.PaymentReceiptPath, '') = ''
                           THEN CAST(0 AS DECIMAL(18,2))
                           ELSE f.Amount
                       END AS DisplayAmount,
                       CASE
                           WHEN ISNULL(e.Status, '') IN ('Drop Pending', 'Dropped')
                                AND f.Status = 'Pending'
                                AND ISNULL(f.PaymentReceiptPath, '') = ''
                           THEN 'Not Active'
                           ELSE f.Status
                       END AS DisplayStatus
                FROM Fees f
                LEFT JOIN Enrollment e ON e.EnrollmentId = f.EnrollmentId
                WHERE f.StudentId = @StudentId
                  AND f.FeeId = @FeeId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@FeeId", feeId)
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
            int enrollmentId = row["EnrollmentId"] == DBNull.Value ? 0 : Convert.ToInt32(row["EnrollmentId"]);
            litDetailCourses.Text = GetCoursePaymentHtml(enrollmentId, row["DisplayAmount"]);
            pnlDetail.Visible = true;
        }

        private string GetCoursePaymentHtml(int enrollmentId, object amountObj)
        {
            if (enrollmentId <= 0)
            {
                return "<span class='receipt-empty'>Legacy payment record. Course was not linked to an enrollment ID.</span>";
            }

            string sql = @"
                SELECT c.CourseCode, c.CourseName
                FROM Enrollment e
                INNER JOIN Courses c ON e.CourseId = c.CourseId
                WHERE e.EnrollmentId = @EnrollmentId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@EnrollmentId", enrollmentId)
            });

            if (dt.Rows.Count == 0)
            {
                return "<span class='receipt-empty'>Enrollment course not found for this payment.</span>";
            }

            decimal amount = Convert.ToDecimal(amountObj);
            DataRow r = dt.Rows[0];
            return "<div class='payment-course-list'><div class='payment-course-line'><span class='payment-course-code'>" + HttpUtility.HtmlEncode(r["CourseCode"].ToString()) + "</span>" +
                   "<span class='payment-course-name'>" + HttpUtility.HtmlEncode(r["CourseName"].ToString()) + "</span>" +
                   "<span class='payment-course-fee'>RM " + amount.ToString("N2") + "</span></div></div>";
        }

        private void UploadReceipt(int feeId, FileUpload fu)
        {
            string studentId = SessionHelper.GetProfileId(Session);

            if (fu == null || !fu.HasFile)
            {
                ShowMessage("Please choose a receipt file before uploading.", "error");
                return;
            }

            DataTable payment = GetStudentPayment(feeId, studentId);
            if (payment.Rows.Count == 0)
            {
                ShowMessage("Invalid payment selected.", "error");
                return;
            }

            DataRow paymentRow = payment.Rows[0];
            string session = paymentRow["Session"].ToString();
            string feeType = paymentRow["FeeType"].ToString();
            string existingReceipt = paymentRow["PaymentReceiptPath"].ToString();
            string status = paymentRow["Status"].ToString();

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

            string enrollmentStatus = paymentRow.Table.Columns.Contains("EnrollmentStatus") ? paymentRow["EnrollmentStatus"].ToString() : string.Empty;
            if ((enrollmentStatus == "Drop Pending" || enrollmentStatus == "Dropped") && status == "Pending")
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

            string folderRelative = "~/Student/PaymentReceipt/" + MakeSafeFolderName("PAY_" + feeId.ToString()) + "/";
            string folderPhysical = Server.MapPath(folderRelative);
            if (!Directory.Exists(folderPhysical)) Directory.CreateDirectory(folderPhysical);

            string safeFileName = "receipt_" + DateTime.Now.ToString("yyyyMMddHHmmss") + ext;
            string physicalPath = Path.Combine(folderPhysical, safeFileName);
            fu.SaveAs(physicalPath);

            string dbPath = folderRelative + safeFileName;

            string updateSql = @"
                UPDATE Fees
                SET PaymentReceiptPath = @PaymentReceiptPath,
                    PaymentReceiptUploadedAt = GETDATE(),
                    Status = 'Pending'
                WHERE FeeId = @FeeId
                  AND StudentId = @StudentId
                  AND (PaymentReceiptPath IS NULL OR LTRIM(RTRIM(PaymentReceiptPath)) = '')";

            int affected = DatabaseHelper.ExecuteNonQuery(updateSql, new[]
            {
                new SqlParameter("@PaymentReceiptPath", dbPath),
                new SqlParameter("@FeeId", feeId),
                new SqlParameter("@StudentId", studentId)
            });

            if (affected == 0)
            {
                ShowMessage("Receipt already uploaded. You cannot upload another receipt for this payment.", "error");
                return;
            }

            NotifyAdminsPaymentReceiptUploaded(studentId, session, feeType, "PAY-" + feeId.ToString("D6"), dbPath);

            LoadSessionFilter(studentId);
            LoadStats(studentId);
            LoadPayments(studentId);
            ShowMessage("Receipt uploaded successfully. Please wait for admin verification.", "success");
        }

        private DataTable GetStudentPayment(int feeId, string studentId)
        {
            string sql = @"
                SELECT f.FeeId,
                       f.Session,
                       f.FeeType,
                       f.Status,
                       ISNULL(f.PaymentReceiptPath, '') AS PaymentReceiptPath,
                       ISNULL(e.Status, '') AS EnrollmentStatus
                FROM Fees f
                LEFT JOIN Enrollment e ON e.EnrollmentId = f.EnrollmentId
                WHERE f.FeeId = @FeeId
                  AND f.StudentId = @StudentId";
            return DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@FeeId", feeId),
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
            {
                value = value.Replace(c, '_');
            }
            return value.Replace(" ", "_").Replace("/", "_").Replace("\\", "_");
        }

        private string BuildReceiptLink(string receiptPath)
        {
            if (string.IsNullOrWhiteSpace(receiptPath))
            {
                return "<span class='receipt-empty'>No receipt uploaded</span>";
            }

            string safeUrl = ResolveUrl(receiptPath);
            return "<a class='receipt-link' href='" + HttpUtility.HtmlAttributeEncode(safeUrl) + "' target='_blank'><i class='fa-solid fa-eye'></i> View Receipt</a>";
        }

        private string GetStatusCss(string status)
        {
            switch (status)
            {
                case "Paid": return "status-paid";
                case "Pending": return "status-pending";
                case "Rejected": return "status-rejected";
                case "Overdue": return "status-overdue";
                case "Not Active": return "status-not-active";
                default: return "status-pending";
            }
        }

        protected void btnCloseDetail_Click(object sender, EventArgs e)
        {
            pnlDetail.Visible = false;
        }

        private void ShowMessage(string message, string type)
        {
            // Do not show the old top alert text above the page.
            // Only show the clean modal dialog.
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
        private void BindSessionFilter()
        {
            if (ddlSession == null) return;

            string current = ddlSession.SelectedValue;

            ddlSession.Items.Clear();
            ddlSession.Items.Add(new ListItem("All Sessions", ""));

            string studentId = GetCurrentStudentId();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string sql = @"
                    SELECT DISTINCT Session
                    FROM Fees
                    WHERE StudentId = @StudentId
                    ORDER BY Session";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@StudentId", studentId);

                    con.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string session = Convert.ToString(dr["Session"]);
                            if (!string.IsNullOrWhiteSpace(session))
                            {
                                ddlSession.Items.Add(new ListItem(session, session));
                            }
                        }
                    }
                }
            }

            if (!string.IsNullOrEmpty(current) && ddlSession.Items.FindByValue(current) != null)
            {
                ddlSession.SelectedValue = current;
            }
        }


        private string GetCurrentStudentId()
        {
            // Student login uses SessionHelper.SetLogin(), which stores the student ID
            // in SIMS_ProfileId. The old Session["StudentId"] / Session["UserId"] keys
            // are not created during login, so using only those keys caused the Payment
            // page to redirect away immediately after clicking the sidebar link.
            string studentId = SessionHelper.GetProfileId(Session);

            if (!string.IsNullOrWhiteSpace(studentId))
                return studentId;

            // Backward-compatible fallback, only for older pages that may still set this key.
            if (Session["StudentId"] != null && !string.IsNullOrWhiteSpace(Session["StudentId"].ToString()))
                return Session["StudentId"].ToString();

            Response.Redirect("~/Login.aspx", true);
            return string.Empty;
        }
    }
}