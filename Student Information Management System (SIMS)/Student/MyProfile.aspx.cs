using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class Student_MyProfile : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            if (!IsPostBack)
            {
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
                LoadProfile();
                CheckUnreadNotifications();
            }
        }

        private int CurrentUserId
        {
            get { return SessionHelper.GetUserId(Session); }
        }

        private void LoadProfile()
        {
            string sql = @"
                SELECT
                    StudentId,
                    FirstName,
                    LastName,
                    DateOfBirth,
                    Gender,
                    Phone,
                    Address,
                    ProfilePicture
                FROM StudentDetails
                WHERE UserId = @UserId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@UserId", CurrentUserId)
            });

            if (dt.Rows.Count == 0)
            {
                ShowMessage(
                    "Validation Error",
                    "Profile not found.",
                    false);

                return;
            }

            DataRow row = dt.Rows[0];

            txtStudentId.Text = row["StudentId"].ToString();
            txtFirstName.Text = row["FirstName"].ToString();
            txtLastName.Text = row["LastName"].ToString();
            txtPhone.Text = row["Phone"].ToString();
            txtAddress.Text = row["Address"].ToString();

            txtDateOfBirth.Text = row["DateOfBirth"] == DBNull.Value
                ? ""
                : Convert.ToDateTime(row["DateOfBirth"]).ToString("yyyy-MM-dd");

            string gender = row["Gender"].ToString();

            if (ddlGender.Items.FindByValue(gender) != null)
                ddlGender.SelectedValue = gender;

            lblFullName.Text = txtFirstName.Text + " " + txtLastName.Text;

            string picture = row["ProfilePicture"].ToString();

            if (!string.IsNullOrWhiteSpace(picture))
            {
                imgProfile.ImageUrl = picture;
            }
            else
            {
                imgProfile.ImageUrl = "~/ProfilePicture/default-profile.png";
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFirstName.Text))
            {
                ShowMessage(
                    "Validation Error",
                    "First name is required.",
                    false);

                return;
            }

            if (string.IsNullOrWhiteSpace(txtLastName.Text))
            {
                ShowMessage(
                    "Validation Error",
                    "Last name is required.",
                    false);

                return;
            }

            string profilePicturePath = GetCurrentProfilePicture();

            if (fuProfilePicture.HasFile)
            {
                string uploadResult = SaveProfilePicture();

                if (uploadResult.StartsWith("ERROR:"))
                {
                    ShowMessage(
                        "Upload Error",
                        uploadResult.Replace("ERROR:", ""),
                        false);

                    return;
                }

                profilePicturePath = uploadResult;
            }

            DateTime dob;
            object dateOfBirth = DateTime.TryParse(txtDateOfBirth.Text, out dob)
                ? (object)dob.Date
                : DBNull.Value;

            string sql = @"
                UPDATE StudentDetails
                SET
                    FirstName = @FirstName,
                    LastName = @LastName,
                    DateOfBirth = @DateOfBirth,
                    Gender = @Gender,
                    Phone = @Phone,
                    Address = @Address,
                    ProfilePicture = @ProfilePicture
                WHERE UserId = @UserId";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@FirstName", txtFirstName.Text.Trim()),
                new SqlParameter("@LastName", txtLastName.Text.Trim()),
                new SqlParameter("@DateOfBirth", dateOfBirth),
                new SqlParameter("@Gender", string.IsNullOrWhiteSpace(ddlGender.SelectedValue) ? (object)DBNull.Value : ddlGender.SelectedValue),
                new SqlParameter("@Phone", string.IsNullOrWhiteSpace(txtPhone.Text) ? (object)DBNull.Value : txtPhone.Text.Trim()),
                new SqlParameter("@Address", string.IsNullOrWhiteSpace(txtAddress.Text) ? (object)DBNull.Value : txtAddress.Text.Trim()),
                new SqlParameter("@ProfilePicture", string.IsNullOrWhiteSpace(profilePicturePath) ? (object)DBNull.Value : profilePicturePath),
                new SqlParameter("@UserId", CurrentUserId)
            });

            LoadProfile();
            StudentSidebar1.RefreshSidebar();

            ShowMessage(
                "Success",
                "Profile updated successfully.",
                true);
        }

        private string GetCurrentProfilePicture()
        {
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT ProfilePicture FROM StudentDetails WHERE UserId = @UserId",
                new[]
                {
                    new SqlParameter("@UserId", CurrentUserId)
                });

            return result == null || result == DBNull.Value
                ? ""
                : result.ToString();
        }

        private string SaveProfilePicture()
        {
            string extension = Path.GetExtension(fuProfilePicture.FileName).ToLower();

            if (extension != ".jpg" && extension != ".jpeg" && extension != ".png")
                return "ERROR:Only JPG, JPEG, and PNG images are allowed.";

            int maxSize = 2 * 1024 * 1024;

            if (fuProfilePicture.PostedFile.ContentLength > maxSize)
                return "ERROR:Image size must not exceed 2MB.";

            string folderPath = Server.MapPath("~/ProfilePicture/");

            if (!Directory.Exists(folderPath))
                Directory.CreateDirectory(folderPath);

            string fileName =
                txtStudentId.Text + "_" +
                DateTime.Now.ToString("yyyyMMddHHmmss") +
                extension;

            string fullPath = Path.Combine(folderPath, fileName);

            fuProfilePicture.SaveAs(fullPath);

            return "~/ProfilePicture/" + fileName;
        }

        private void ShowMessage(string title, string message, bool isSuccess)
        {
            string safeTitle = HttpUtility.JavaScriptStringEncode(title);

            string safeMessage = HttpUtility.JavaScriptStringEncode(message)
                .Replace("\r\n", "<br/>")
                .Replace("\n", "<br/>");

            string script = string.Format(
                "showMessageModal('{0}', '{1}', {2});",
                safeTitle,
                safeMessage,
                isSuccess.ToString().ToLower());

            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                Guid.NewGuid().ToString(),
                script,
                true);
        }

        private void CheckUnreadNotifications()
        {
            object count = DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Notifications WHERE UserId = @Uid AND IsRead = 0",
                new[] { new SqlParameter("@Uid", CurrentUserId) });

            pnlNotifBadge.Visible = (count != null && Convert.ToInt32(count) > 0);
        }
    }
}
