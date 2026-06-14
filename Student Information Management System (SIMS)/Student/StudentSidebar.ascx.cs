using System;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_
{
    public partial class StudentSidebar : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                RefreshSidebar();
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
            string fullName = SessionHelper.GetFullName(Session);
            lblSidebarName.Text = string.IsNullOrWhiteSpace(fullName) ? "Student" : fullName;

            object result = DatabaseHelper.ExecuteScalar(
                "SELECT ProfilePicture FROM StudentDetails WHERE UserId = @UserId",
                new[] { new SqlParameter("@UserId", SessionHelper.GetUserId(Session)) });

            string picture = result == null || result == DBNull.Value ? "" : result.ToString();

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