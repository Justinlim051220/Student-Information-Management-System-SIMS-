using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Admin
{
    public partial class ManageCourses : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                LoadProgrammes();
                LoadStats();
                LoadCourses();
            }
        }

        private void LoadProgrammes()
        {
            string sql = @"
                SELECT ProgrammeId,
                       ProgrammeCode + ' - ' + ProgrammeName AS ProgrammeDisplay
                FROM Programmes
                ORDER BY ProgrammeName";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);

            ddlProgramme.DataSource = dt;
            ddlProgramme.DataTextField = "ProgrammeDisplay";
            ddlProgramme.DataValueField = "ProgrammeId";
            ddlProgramme.DataBind();
            ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));

            ddlFilterProgramme.DataSource = dt.Copy();
            ddlFilterProgramme.DataTextField = "ProgrammeDisplay";
            ddlFilterProgramme.DataValueField = "ProgrammeId";
            ddlFilterProgramme.DataBind();
            ddlFilterProgramme.Items.Insert(0, new ListItem("All Programmes", ""));
        }

        private void LoadStats()
        {
            object courseCount = DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM Courses");
            object programmeCount = DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM Programmes");

            lblTotalCourses.Text = courseCount?.ToString() ?? "0";
            lblTotalProgrammes.Text = programmeCount?.ToString() ?? "0";
        }

        private void LoadCourses()
        {
            string sql = @"
                SELECT c.CourseId,
                       c.CourseCode,
                       c.CourseName,
                       c.Credits,
                       c.Description,
                       p.ProgrammeCode,
                       p.ProgrammeName
                FROM Courses c
                INNER JOIN Programmes p ON c.ProgrammeId = p.ProgrammeId
                WHERE (@Search = '' OR c.CourseCode LIKE '%' + @Search + '%' OR c.CourseName LIKE '%' + @Search + '%')
                  AND (@ProgrammeId = 0 OR c.ProgrammeId = @ProgrammeId)
                ORDER BY p.ProgrammeName, c.CourseCode";

            int programmeId = 0;
            if (!string.IsNullOrWhiteSpace(ddlFilterProgramme.SelectedValue))
            {
                int.TryParse(ddlFilterProgramme.SelectedValue, out programmeId);
            }

            SqlParameter[] parameters =
            {
                new SqlParameter("@Search", txtSearch.Text.Trim()),
                new SqlParameter("@ProgrammeId", programmeId)
            };

            gvCourses.DataSource = DatabaseHelper.ExecuteQuery(sql, parameters);
            gvCourses.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!ValidateForm())
            {
                return;
            }

            try
            {
                if (string.IsNullOrEmpty(hfCourseId.Value))
                {
                    AddCourse();
                    ShowMessage("✅ Success", "Course added successfully.");
                }
                else
                {
                    UpdateCourse();
                    ShowMessage("✅ Success", "Course updated successfully.");
                }

                ClearForm();
                LoadStats();
                LoadCourses();
            }
            catch (Exception ex)
            {
                ShowMessage("❌ Error", "Error: " + ex.Message);
            }
        }

        private bool ValidateForm()
        {
            if (string.IsNullOrWhiteSpace(txtCourseCode.Text) ||
                string.IsNullOrWhiteSpace(txtCourseName.Text) ||
                string.IsNullOrWhiteSpace(txtCredits.Text) ||
                string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue))
            {
                ShowMessage("⚠ Warning", "Please fill in all required fields.");
                return false;
            }

            int credits;
            if (!int.TryParse(txtCredits.Text.Trim(), out credits) || credits <= 0)
            {
                ShowMessage("⚠ Warning", "Credits must be a positive number.");
                return false;
            }

            return true;
        }

        private void AddCourse()
        {
            string sql = @"
                INSERT INTO Courses (CourseCode, CourseName, Credits, ProgrammeId, Description)
                VALUES (@Code, @Name, @Credits, @ProgrammeId, @Description)";

            DatabaseHelper.ExecuteNonQuery(sql, BuildCourseParameters(false));
        }

        private void UpdateCourse()
        {
            string sql = @"
                UPDATE Courses
                SET CourseCode = @Code,
                    CourseName = @Name,
                    Credits = @Credits,
                    ProgrammeId = @ProgrammeId,
                    Description = @Description
                WHERE CourseId = @CourseId";

            DatabaseHelper.ExecuteNonQuery(sql, BuildCourseParameters(true));
        }

        private SqlParameter[] BuildCourseParameters(bool includeCourseId)
        {
            if (includeCourseId)
            {
                return new[]
                {
                    new SqlParameter("@Code", txtCourseCode.Text.Trim().ToUpper()),
                    new SqlParameter("@Name", txtCourseName.Text.Trim()),
                    new SqlParameter("@Credits", int.Parse(txtCredits.Text.Trim())),
                    new SqlParameter("@ProgrammeId", int.Parse(ddlProgramme.SelectedValue)),
                    new SqlParameter("@Description", txtDescription.Text.Trim()),
                    new SqlParameter("@CourseId", int.Parse(hfCourseId.Value))
                };
            }

            return new[]
            {
                new SqlParameter("@Code", txtCourseCode.Text.Trim().ToUpper()),
                new SqlParameter("@Name", txtCourseName.Text.Trim()),
                new SqlParameter("@Credits", int.Parse(txtCredits.Text.Trim())),
                new SqlParameter("@ProgrammeId", int.Parse(ddlProgramme.SelectedValue)),
                new SqlParameter("@Description", txtDescription.Text.Trim())
            };
        }

        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int courseId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditCourse")
            {
                LoadCourseForEdit(courseId);
            }
            else if (e.CommandName == "DeleteCourse")
            {
                ShowDeleteConfirmation(courseId);
            }
        }

        private void LoadCourseForEdit(int courseId)
        {
            string sql = "SELECT * FROM Courses WHERE CourseId = @CourseId";
            DataTable dt = DatabaseHelper.ExecuteQuery(sql, new[] { new SqlParameter("@CourseId", courseId) });

            if (dt.Rows.Count == 0)
            {
                ShowMessage("❌ Error", "Course record not found.");
                return;
            }

            DataRow row = dt.Rows[0];

            hfCourseId.Value = row["CourseId"].ToString();
            txtCourseCode.Text = row["CourseCode"].ToString();
            txtCourseName.Text = row["CourseName"].ToString();
            txtCredits.Text = row["Credits"].ToString();
            txtDescription.Text = row["Description"].ToString();
            ddlProgramme.SelectedValue = row["ProgrammeId"].ToString();

            lblFormTitle.Text = "Edit Course";
            btnSave.Text = "Update Course";

            ShowMessage("Edit Mode", "Course details loaded. You can now update this course record.");
        }


        private void ShowDeleteConfirmation(int courseId)
        {
            string message = "Are you sure you want to delete this course? This action cannot be undone.";
            string script = string.Format(
                "showMessageModal('⚠ Confirm Delete', '{0}', true, {1});",
                HttpUtility.JavaScriptStringEncode(message),
                courseId);

            ScriptManager.RegisterStartupScript(this, GetType(), "confirmDeleteCourse", script, true);
        }

        protected void btnDeleteConfirmed_Click(object sender, EventArgs e)
        {
            int courseId;
            if (!int.TryParse(hfDeleteTarget.Value, out courseId))
            {
                ShowMessage("❌ Error", "Invalid course selected for deletion.");
                return;
            }

            DeleteCourse(courseId);
        }

        private void DeleteCourse(int courseId)
        {
            try
            {
                if (CourseIsUsed(courseId))
                {
                    ShowMessage("⚠ Warning", "Cannot delete this course because it is already used in enrollment, lecturer assignment, attendance, or grades.");
                    return;
                }

                DatabaseHelper.ExecuteNonQuery(
                    "DELETE FROM Courses WHERE CourseId = @CourseId",
                    new[] { new SqlParameter("@CourseId", courseId) });

                ShowMessage("✅ Success", "Course deleted successfully.");
                ClearForm();
                LoadStats();
                LoadCourses();
            }
            catch (Exception ex)
            {
                ShowMessage("❌ Error", "Error deleting course: " + ex.Message);
            }
        }

        private bool CourseIsUsed(int courseId)
        {
            string sql = @"
                SELECT
                    (SELECT COUNT(*) FROM Enrollment WHERE CourseId = @CourseId) +
                    (SELECT COUNT(*) FROM LecturerCourse WHERE CourseId = @CourseId) +
                    (SELECT COUNT(*) FROM Attendance WHERE CourseId = @CourseId) +
                    (SELECT COUNT(*) FROM Grades WHERE CourseId = @CourseId)";

            object count = DatabaseHelper.ExecuteScalar(sql, new[] { new SqlParameter("@CourseId", courseId) });
            return Convert.ToInt32(count) > 0;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            gvCourses.PageIndex = 0;
            LoadCourses();
        }

        protected void btnResetSearch_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlFilterProgramme.SelectedIndex = 0;
            gvCourses.PageIndex = 0;
            LoadCourses();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        protected void gvCourses_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvCourses.PageIndex = e.NewPageIndex;
            LoadCourses();
        }

        private void ClearForm()
        {
            hfCourseId.Value = "";
            txtCourseCode.Text = "";
            txtCourseName.Text = "";
            txtCredits.Text = "";
            txtDescription.Text = "";

            if (ddlProgramme.Items.Count > 0)
            {
                ddlProgramme.SelectedIndex = 0;
            }

            lblFormTitle.Text = "Add New Course";
            btnSave.Text = "Save Course";
        }

        private void ShowMessage(string title, string message)
        {
            lblMessage.Visible = false;

            string safeTitle = HttpUtility.JavaScriptStringEncode(title);
            string safeMessage = HttpUtility.JavaScriptStringEncode(message).Replace("\r\n", "<br/>").Replace("\n", "<br/>");

            string script = string.Format(
                "showMessageModal('{0}', '{1}', false, 0);",
                safeTitle,
                safeMessage);

            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"), script, true);
        }
    }
}
