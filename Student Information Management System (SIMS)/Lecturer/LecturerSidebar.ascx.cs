using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Lecturer
{
    public partial class LecturerSidebar : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RefreshSidebar();
            }
        }

        public string NavClass(string pageName)
        {
            string currentPage = Path.GetFileNameWithoutExtension(Page.AppRelativeVirtualPath);

            return string.Equals(currentPage, pageName, StringComparison.OrdinalIgnoreCase)
                ? "sidebar-link active"
                : "sidebar-link";
        }

        public void RefreshSidebar()
        {
            string sql = @"
                SELECT 
                    FirstName,
                    LastName,
                    ProfilePicture
                FROM LecturerDetails
                WHERE UserId = @UserId";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[]
            {
                new SqlParameter("@UserId", SessionHelper.GetUserId(Session))
            });

            if (dt.Rows.Count == 0)
            {
                lblSidebarName.Text = "Lecturer";
                imgSidebarAvatar.ImageUrl = "~/ProfilePicture/default-profile.png";
                return;
            }

            DataRow row = dt.Rows[0];

            string fullName = (row["FirstName"].ToString() + " " + row["LastName"].ToString()).Trim();

            lblSidebarName.Text = string.IsNullOrWhiteSpace(fullName)
                ? "Lecturer"
                : fullName;

            string picture = row["ProfilePicture"] == DBNull.Value
                ? ""
                : row["ProfilePicture"].ToString();

            imgSidebarAvatar.ImageUrl = string.IsNullOrWhiteSpace(picture)
                ? "~/ProfilePicture/default-profile.png"
                : picture;
        }

        protected void btnConfirmLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.Logout(Session);
            Response.Redirect("~/Login.aspx", false);
        }
    }
}