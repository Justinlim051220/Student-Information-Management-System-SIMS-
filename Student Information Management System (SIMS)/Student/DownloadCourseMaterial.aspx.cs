using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Student
{
    public partial class DownloadCourseMaterial : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireStudent(Session, Response);

            int fileId;
            if (!int.TryParse(Request.QueryString["fileId"], out fileId))
            {
                Response.StatusCode = 400;
                Response.End();
                return;
            }

            string studentId = SessionHelper.GetProfileId(Session);
            DataTable dt = DatabaseHelper.ExecuteQuery(@"
                SELECT TOP 1
                    cmf.FileName,
                    cmf.FilePath,
                    cmf.FileType
                FROM CourseMaterialFiles cmf
                INNER JOIN CourseMaterials cm ON cm.MaterialId = cmf.MaterialId
                INNER JOIN Enrollment e ON e.CourseId = cm.CourseId
                    AND e.Session = cm.Session
                    AND e.StudentId = @StudentId
                    AND e.Status <> 'Dropped'
                WHERE cmf.FileId = @FileId",
                new[]
                {
                    new SqlParameter("@FileId", fileId),
                    new SqlParameter("@StudentId", studentId)
                });

            if (dt == null || dt.Rows.Count == 0)
            {
                Response.StatusCode = 404;
                Response.End();
                return;
            }

            DataRow row = dt.Rows[0];
            string fileName = Convert.ToString(row["FileName"]);
            string virtualPath = Convert.ToString(row["FilePath"]);
            string contentType = Convert.ToString(row["FileType"]);

            if (string.IsNullOrWhiteSpace(fileName))
                fileName = Path.GetFileName(virtualPath);

            string physicalPath = Server.MapPath(virtualPath);
            if (!File.Exists(physicalPath))
            {
                Response.StatusCode = 404;
                Response.End();
                return;
            }

            Response.Clear();
            Response.ContentType = string.IsNullOrWhiteSpace(contentType)
                ? "application/octet-stream"
                : contentType;
            Response.AddHeader("Content-Disposition", BuildContentDisposition(fileName));
            Response.AddHeader("Content-Length", new FileInfo(physicalPath).Length.ToString());
            Response.TransmitFile(physicalPath);
            Response.End();
        }

        private static string BuildContentDisposition(string fileName)
        {
            string fallback = BuildAsciiFallback(fileName);
            string encoded = Uri.EscapeDataString(fileName);
            return "attachment; filename=\"" + fallback + "\"; filename*=UTF-8''" + encoded;
        }

        private static string BuildAsciiFallback(string fileName)
        {
            string clean = Path.GetFileName(fileName);
            var builder = new StringBuilder(clean.Length);

            foreach (char c in clean)
            {
                bool invalid = Array.IndexOf(Path.GetInvalidFileNameChars(), c) >= 0;
                builder.Append(c >= 32 && c <= 126 && !invalid && c != '"' ? c : '_');
            }

            string fallback = builder.ToString().Trim();
            return string.IsNullOrWhiteSpace(fallback) ? "course-material" : fallback;
        }
    }
}
