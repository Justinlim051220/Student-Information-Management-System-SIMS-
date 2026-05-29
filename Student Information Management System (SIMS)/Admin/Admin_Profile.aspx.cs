using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class Admin_Profile : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");
                LoadProfile();
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
                    h.HoPId,
                    h.FirstName,
                    h.LastName,
                    h.Phone,
                    h.Department,
                    h.ProfilePicture,
                    u.Email,
                    u.CreatedAt
                FROM HoPDetails h
                INNER JOIN Users u ON u.UserId = h.UserId
                WHERE h.UserId = @UserId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@UserId", CurrentUserId)
            });

            if (dt.Rows.Count == 0)
            {
                ShowMessage("Validation Error", "Admin profile not found.", false);
                return;
            }

            DataRow row = dt.Rows[0];

            txtHoPId.Text = row["HoPId"].ToString();
            txtEmail.Text = row["Email"].ToString();
            txtFirstName.Text = row["FirstName"].ToString();
            txtLastName.Text = row["LastName"].ToString();
            txtPhone.Text = row["Phone"].ToString();
            txtDepartment.Text = row["Department"].ToString();

            txtCreatedAt.Text = row["CreatedAt"] == DBNull.Value
                ? "-"
                : Convert.ToDateTime(row["CreatedAt"]).ToString("dd MMM yyyy");

            string fullName = (txtFirstName.Text + " " + txtLastName.Text).Trim();
            if (string.IsNullOrWhiteSpace(fullName))
                fullName = "Admin";

            lblFullName.Text = fullName;
            lblSidebarName.Text = fullName;

            string initial = fullName.Length > 0 ? fullName[0].ToString().ToUpper() : "A";
            lblAvatarInitial.Text = initial;
            lblProfileInitial.Text = initial;

            string picture = row["ProfilePicture"] == DBNull.Value ? "" : row["ProfilePicture"].ToString();
            SetProfilePictureDisplay(picture);
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFirstName.Text))
            {
                ShowMessage("Validation Error", "First name is required.", false);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtLastName.Text))
            {
                ShowMessage("Validation Error", "Last name is required.", false);
                return;
            }

            string profilePicturePath = GetCurrentProfilePicture();

            if (fuProfilePicture.HasFile)
            {
                string uploadResult = SaveProfilePicture();

                if (uploadResult.StartsWith("ERROR:"))
                {
                    ShowMessage("Upload Error", uploadResult.Replace("ERROR:", ""), false);
                    return;
                }

                profilePicturePath = uploadResult;
            }

            string sql = @"
                UPDATE HoPDetails
                SET
                    FirstName = @FirstName,
                    LastName = @LastName,
                    Phone = @Phone,
                    Department = @Department,
                    ProfilePicture = @ProfilePicture
                WHERE UserId = @UserId";

            DatabaseHelper.ExecuteNonQuery(sql, new[]
            {
                new SqlParameter("@FirstName", txtFirstName.Text.Trim()),
                new SqlParameter("@LastName", txtLastName.Text.Trim()),
                new SqlParameter("@Phone", string.IsNullOrWhiteSpace(txtPhone.Text) ? (object)DBNull.Value : txtPhone.Text.Trim()),
                new SqlParameter("@Department", string.IsNullOrWhiteSpace(txtDepartment.Text) ? (object)DBNull.Value : txtDepartment.Text.Trim()),
                new SqlParameter("@ProfilePicture", string.IsNullOrWhiteSpace(profilePicturePath) ? (object)DBNull.Value : profilePicturePath),
                new SqlParameter("@UserId", CurrentUserId)
            });

            LoadProfile();
            ShowMessage("Success", "Profile updated successfully.", true);
        }

        private string GetCurrentProfilePicture()
        {
            object result = DatabaseHelper.ExecuteScalar(
                "SELECT ProfilePicture FROM HoPDetails WHERE UserId = @UserId",
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

            string folderPath = Server.MapPath("~/AdminProfilePic/");

            if (!Directory.Exists(folderPath))
                Directory.CreateDirectory(folderPath);

            string fileName =
                txtHoPId.Text + "_" +
                DateTime.Now.ToString("yyyyMMddHHmmss") +
                extension;

            string fullPath = Path.Combine(folderPath, fileName);
            fuProfilePicture.SaveAs(fullPath);

            return "~/AdminProfilePic/" + fileName;
        }

        private void SetProfilePictureDisplay(string picture)
        {
            bool hasPicture = !string.IsNullOrWhiteSpace(picture);

            imgProfile.Visible = hasPicture;
            divProfileInitial.Visible = !hasPicture;

            divSidebarPhoto.Visible = hasPicture;
            divSidebarInitial.Visible = !hasPicture;

            if (hasPicture)
            {
                imgProfile.ImageUrl = picture;
                imgSidebarAvatar.ImageUrl = picture;
            }
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

        protected void lbLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}
