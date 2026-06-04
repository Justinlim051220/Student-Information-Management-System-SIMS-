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

                lblSidebarName.Text = fullName;
                lblAvatarInitial.Text = initial;
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
            string countSql = @"
                SELECT COUNT(*)
                FROM Fees
                WHERE StudentId = @StudentId
                  AND Status = 'Pending'";

            string amountSql = @"
                SELECT ISNULL(SUM(Amount), 0)
                FROM Fees
                WHERE StudentId = @StudentId
                  AND Status = 'Pending'";

            lblPendingCount.Text = Convert.ToInt32(DatabaseHelper.ExecuteScalar(countSql, new[] { new SqlParameter("@StudentId", studentId) })).ToString();
            lblPendingAmount.Text = Convert.ToDecimal(DatabaseHelper.ExecuteScalar(amountSql, new[] { new SqlParameter("@StudentId", studentId) })).ToString("N2");
        }

        private void LoadPayments(string studentId)
        {
            string sql = @"
                SELECT (f.Session + ' - ' + f.FeeType) AS PaymentId,
                       f.StudentId,
                       f.Session,
                       f.FeeType,
                       f.Amount,
                       f.Status,
                       f.PaymentDate,
                       ISNULL(f.PaymentReceiptPath, '') AS PaymentReceiptPath,
                       ISNULL(
                           STUFF((
                               SELECT '<div class=""payment-course-line""><span class=""payment-course-code"">' + c.CourseCode + '</span><span class=""payment-course-name"">' + c.CourseName + '</span><span class=""payment-course-fee"">RM ' + FORMAT(ISNULL(cf.Amount, 0), 'N2') + '</span></div>'
                               FROM Enrollment e
                               INNER JOIN Courses c ON e.CourseId = c.CourseId
                               LEFT JOIN CourseFees cf ON cf.CourseId = c.CourseId AND cf.Session = e.Session
                               WHERE e.StudentId = f.StudentId
                                 AND e.Session = f.Session
                                 AND e.Status = 'Active'
                               ORDER BY c.CourseCode
                               FOR XML PATH(''), TYPE
                           ).value('.', 'NVARCHAR(MAX)'), 1, 0, ''),
                           '<span class=""receipt-empty"">No active enrolled course found</span>'
                       ) AS CoursePaymentList
                FROM Fees f
                WHERE f.StudentId = @StudentId
                  AND (@Session = '' OR f.Session = @Session)
                ORDER BY CASE WHEN f.Status = 'Pending' THEN 0 WHEN f.Status = 'Rejected' THEN 1 WHEN f.Status = 'Overdue' THEN 2 ELSE 3 END,
                         f.Session DESC,
                         f.FeeType ASC";

            SqlParameter[] p =
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", ddlSession.SelectedValue ?? "")
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

            string session = Convert.ToString(gvPayments.DataKeys[rowIndex].Values["Session"]);
            string feeType = Convert.ToString(gvPayments.DataKeys[rowIndex].Values["FeeType"]);

            if (e.CommandName == "ViewPayment")
            {
                LoadPaymentDetail(session, feeType);
            }
            else if (e.CommandName == "UploadReceipt")
            {
                GridViewRow row = gvPayments.Rows[rowIndex];
                FileUpload fu = row.FindControl("fuReceipt") as FileUpload;
                UploadReceipt(session, feeType, fu);
            }
        }

        protected void gvPayments_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

            string status = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "Status"));
            string receiptPath = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "PaymentReceiptPath"));

            Label lblStatusBadge = e.Row.FindControl("lblStatusBadge") as Label;
            Literal litReceipt = e.Row.FindControl("litReceipt") as Literal;
            LinkButton btnUpload = e.Row.FindControl("btnUpload") as LinkButton;
            FileUpload fuReceipt = e.Row.FindControl("fuReceipt") as FileUpload;
            Label lblActionNote = e.Row.FindControl("lblActionNote") as Label;
            HtmlGenericControl uploadBox = e.Row.FindControl("uploadBox") as HtmlGenericControl;

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
            bool canUpload = !hasReceipt && status != "Paid";

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
                else
                {
                    lblActionNote.Text = "Upload one receipt only.";
                }
            }
        }

        private void LoadPaymentDetail(string session, string feeType)
        {
            string studentId = SessionHelper.GetProfileId(Session);

            string sql = @"
                SELECT (Session + ' - ' + FeeType) AS PaymentId, Session, FeeType, Amount, Status
                FROM Fees
                WHERE StudentId = @StudentId
                  AND Session = @Session
                  AND FeeType = @FeeType";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session),
                new SqlParameter("@FeeType", feeType)
            });

            if (dt.Rows.Count == 0)
            {
                ShowMessage("Payment record cannot be found.", "error");
                return;
            }

            DataRow row = dt.Rows[0];
            txtDetailPaymentId.Text = row["PaymentId"].ToString();
            txtDetailSession.Text = row["Session"].ToString();
            txtDetailStatus.Text = row["Status"].ToString();
            txtDetailAmount.Text = "RM " + Convert.ToDecimal(row["Amount"]).ToString("N2");
            litDetailCourses.Text = GetCoursePaymentHtml(studentId, row["Session"].ToString());
            pnlDetail.Visible = true;
        }

        private string GetCoursePaymentHtml(string studentId, string session)
        {
            string sql = @"
                SELECT c.CourseCode, c.CourseName, ISNULL(cf.Amount, 0) AS Amount
                FROM Enrollment e
                INNER JOIN Courses c ON e.CourseId = c.CourseId
                LEFT JOIN CourseFees cf ON cf.CourseId = c.CourseId AND cf.Session = e.Session
                WHERE e.StudentId = @StudentId
                  AND e.Session = @Session
                  AND e.Status = 'Active'
                ORDER BY c.CourseCode";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session)
            });

            if (dt.Rows.Count == 0)
            {
                return "<span class='receipt-empty'>No active course found for this payment.</span>";
            }

            string html = "<div class='payment-course-list'>";
            foreach (DataRow r in dt.Rows)
            {
                html += "<div class='payment-course-line'><span class='payment-course-code'>" + HttpUtility.HtmlEncode(r["CourseCode"].ToString()) + "</span>" +
                        "<span class='payment-course-name'>" + HttpUtility.HtmlEncode(r["CourseName"].ToString()) + "</span>" +
                        "<span class='payment-course-fee'>RM " + Convert.ToDecimal(r["Amount"]).ToString("N2") + "</span></div>";
            }
            html += "</div>";
            return html;
        }

        private void UploadReceipt(string session, string feeType, FileUpload fu)
        {
            string studentId = SessionHelper.GetProfileId(Session);

            if (fu == null || !fu.HasFile)
            {
                ShowMessage("Please choose a receipt file before uploading.", "error");
                return;
            }

            if (!IsStudentPayment(session, feeType, studentId))
            {
                ShowMessage("Invalid payment selected.", "error");
                return;
            }

            string existingReceipt = GetExistingReceipt(session, feeType, studentId);
            if (!string.IsNullOrWhiteSpace(existingReceipt))
            {
                ShowMessage("Receipt already uploaded. You cannot upload another receipt for this payment.", "error");
                return;
            }

            string status = GetPaymentStatus(session, feeType, studentId);
            if (status == "Paid")
            {
                ShowMessage("This payment has already been approved. Receipt cannot be uploaded.", "error");
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

            string folderRelative = "~/Student/PaymentReceipt/" + MakeSafeFolderName(session + "_" + feeType) + "/";
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
                WHERE StudentId = @StudentId
                  AND Session = @Session
                  AND FeeType = @FeeType
                  AND (PaymentReceiptPath IS NULL OR LTRIM(RTRIM(PaymentReceiptPath)) = '')";

            int affected = DatabaseHelper.ExecuteNonQuery(updateSql, new[]
            {
                new SqlParameter("@PaymentReceiptPath", dbPath),
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session),
                new SqlParameter("@FeeType", feeType)
            });

            if (affected == 0)
            {
                ShowMessage("Receipt already uploaded. You cannot upload another receipt for this payment.", "error");
                return;
            }

            LoadSessionFilter(studentId);
            LoadStats(studentId);
            LoadPayments(studentId);
            ShowMessage("Receipt uploaded successfully. Please wait for admin verification.", "success");
        }

        private bool IsStudentPayment(string session, string feeType, string studentId)
        {
            string sql = "SELECT COUNT(*) FROM Fees WHERE StudentId = @StudentId AND Session = @Session AND FeeType = @FeeType";
            object result = DatabaseHelper.ExecuteScalar(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session),
                new SqlParameter("@FeeType", feeType)
            });
            return result != null && Convert.ToInt32(result) > 0;
        }

        private string GetPaymentStatus(string session, string feeType, string studentId)
        {
            string sql = "SELECT Status FROM Fees WHERE StudentId = @StudentId AND Session = @Session AND FeeType = @FeeType";
            object result = DatabaseHelper.ExecuteScalar(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session),
                new SqlParameter("@FeeType", feeType)
            });
            return result == null || result == DBNull.Value ? "" : result.ToString();
        }

        private string GetExistingReceipt(string session, string feeType, string studentId)
        {
            string sql = "SELECT ISNULL(PaymentReceiptPath, '') FROM Fees WHERE StudentId = @StudentId AND Session = @Session AND FeeType = @FeeType";
            object result = DatabaseHelper.ExecuteScalar(sql, new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Session", session),
                new SqlParameter("@FeeType", feeType)
            });
            return result == null || result == DBNull.Value ? "" : result.ToString();
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
                default: return "status-pending";
            }
        }

        protected void btnCloseDetail_Click(object sender, EventArgs e)
        {
            pnlDetail.Visible = false;
        }

        private void ShowMessage(string message, string type)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = "alert alert-" + (type == "error" ? "danger" : type);

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


        protected void btnConfirmLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx");
        }

    }
}