using System;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SIMS.Helpers;

namespace Student_Information_Management_System__SIMS_.Admin
{
    public partial class CourseOffering : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SessionHelper.RequireAdmin(Session, Response);

            if (!IsPostBack)
            {
                LoadProgrammes();
                LoadCoursesByProgramme();
                LoadStats();
                LoadOfferings();
            }
        }

        private void LoadProgrammes()
        {
            string sql = @"SELECT ProgrammeId, ProgrammeCode + ' - ' + ProgrammeName AS ProgrammeDisplay
                           FROM Programmes ORDER BY ProgrammeName";

            DataTable dt = DatabaseHelper.ExecuteQuery(sql);
            ddlProgramme.DataSource = dt;
            ddlProgramme.DataTextField = "ProgrammeDisplay";
            ddlProgramme.DataValueField = "ProgrammeId";
            ddlProgramme.DataBind();
            ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
        }

        private void LoadCoursesByProgramme()
        {
            cblCourses.Items.Clear();

            if (string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue))
            {
                cblCourses.Items.Add(new ListItem("Please select a programme first", ""));
                cblCourses.Items[0].Enabled = false;
                return;
            }

            string sql = @"SELECT CourseId, CourseCode + ' - ' + CourseName AS CourseDisplay
                           FROM Courses
                           WHERE ProgrammeId = @ProgrammeId
                           ORDER BY CourseCode";

            SqlParameter[] p = { new SqlParameter("@ProgrammeId", int.Parse(ddlProgramme.SelectedValue)) };
            DataTable dt = DatabaseHelper.ExecuteQuery(sql, p);

            cblCourses.DataSource = dt;
            cblCourses.DataTextField = "CourseDisplay";
            cblCourses.DataValueField = "CourseId";
            cblCourses.DataBind();

            if (cblCourses.Items.Count == 0)
            {
                cblCourses.Items.Add(new ListItem("No courses found for this programme", ""));
                cblCourses.Items[0].Enabled = false;
            }
        }

        protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCoursesByProgramme();
        }

        private void LoadStats()
        {
            // Count the same grouped records that are shown in the table.
            // Example: April 2026 + DCS + Semester 1 + Open with 3 courses = 1 offering group.
            string totalSql = @"
                SELECT COUNT(*)
                FROM (
                    SELECT Session, ProgrammeId, Status
                    FROM CourseOffering
                    GROUP BY Session, ProgrammeId, Status
                ) groupedOfferings";

            string openSql = @"
                SELECT COUNT(*)
                FROM (
                    SELECT Session, ProgrammeId, Status
                    FROM CourseOffering
                    WHERE Status = 'Open'
                    GROUP BY Session, ProgrammeId, Status
                ) groupedOfferings";

            lblTotalOfferings.Text = Convert.ToString(DatabaseHelper.ExecuteScalar(totalSql)) ?? "0";
            lblOpenOfferings.Text = Convert.ToString(DatabaseHelper.ExecuteScalar(openSql)) ?? "0";
        }

        private void LoadOfferings()
        {
            string sql = @"
                SELECT
                    co.Session,
                    co.ProgrammeId,
                    co.Status,
                    p.ProgrammeCode,
                    p.ProgrammeName,
                    COUNT(*) AS CourseCount,
                    co.Session + '||' + CAST(co.ProgrammeId AS VARCHAR(20)) + '||' + co.Status AS GroupKey,
                    STUFF((
                        SELECT '<br />' + c2.CourseCode + ' - ' + c2.CourseName
                        FROM CourseOffering co2
                        INNER JOIN Courses c2 ON co2.CourseId = c2.CourseId
                        WHERE co2.Session = co.Session
                          AND co2.ProgrammeId = co.ProgrammeId
                          AND co2.Status = co.Status
                        ORDER BY c2.CourseCode
                        FOR XML PATH(''), TYPE
                    ).value('.', 'NVARCHAR(MAX)'), 1, 6, '') AS Courses
                FROM CourseOffering co
                INNER JOIN Programmes p ON co.ProgrammeId = p.ProgrammeId
                INNER JOIN Courses c ON co.CourseId = c.CourseId
                WHERE (@Search = '' OR c.CourseCode LIKE '%' + @Search + '%' OR c.CourseName LIKE '%' + @Search + '%' OR p.ProgrammeCode LIKE '%' + @Search + '%' OR co.Session LIKE '%' + @Search + '%')
                  AND (@Status = '' OR co.Status = @Status)
                GROUP BY co.Session, co.ProgrammeId, co.Status, p.ProgrammeCode, p.ProgrammeName
                ORDER BY co.Session, p.ProgrammeCode, co.Status";

            SqlParameter[] p =
            {
                new SqlParameter("@Search", txtSearch.Text.Trim()),
                new SqlParameter("@Status", ddlFilterStatus.SelectedValue)
            };

            gvOfferings.DataSource = DatabaseHelper.ExecuteQuery(sql, p);
            gvOfferings.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!ValidateForm()) return;

            try
            {
                if (string.IsNullOrWhiteSpace(hfOfferingId.Value))
                {
                    int added = AddSelectedOfferings();
                    int skipped = GetSelectedCourseIds().Length - added;

                    ClearForm();
                    LoadStats();
                    LoadOfferings();

                    if (skipped > 0)
                        ShowMessage("✅ Success", added + " course offering(s) added. " + skipped + " duplicate course(s) were skipped.");
                    else
                        ShowMessage("✅ Success", added + " course offering(s) added successfully.");
                }
                else
                {
                    if (!UpdateOfferingGroup()) return;
                    ClearForm();
                    LoadStats();
                    LoadOfferings();
                    ShowMessage("✅ Success", "Course offering group updated successfully.");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("❌ Error", "Error: " + ex.Message);
            }
        }

        private bool ValidateForm()
        {
            if (string.IsNullOrWhiteSpace(ddlSession.SelectedValue) ||
                string.IsNullOrWhiteSpace(ddlProgramme.SelectedValue) ||
                string.IsNullOrWhiteSpace(ddlStatus.SelectedValue))
            {
                ShowMessage("⚠ Warning", "Please fill in all required fields.");
                return false;
            }

            if (GetSelectedCourseIds().Length == 0)
            {
                ShowMessage("⚠ Warning", "Please select at least one course.");
                return false;
            }

            return true;
        }

        private int[] GetSelectedCourseIds()
        {
            return cblCourses.Items.Cast<ListItem>()
                .Where(i => i.Selected && i.Enabled && !string.IsNullOrWhiteSpace(i.Value))
                .Select(i => int.Parse(i.Value))
                .ToArray();
        }

        private bool OfferingExists(int currentOfferingId, int courseId)
        {
            string sql = @"
                SELECT COUNT(*) FROM CourseOffering
                WHERE Session = @Session
                  AND ProgrammeId = @ProgrammeId
                  AND CourseId = @CourseId
                  AND OfferingId <> @OfferingId";

            SqlParameter[] p = BuildParameters(currentOfferingId, courseId);
            int count = Convert.ToInt32(DatabaseHelper.ExecuteScalar(sql, p));
            return count > 0;
        }

        private int AddSelectedOfferings()
        {
            int added = 0;
            foreach (int courseId in GetSelectedCourseIds())
            {
                if (OfferingExists(0, courseId))
                    continue;

                string sql = @"INSERT INTO CourseOffering (Session, ProgrammeId, CourseId, Semester, Status)
                               VALUES (@Session, @ProgrammeId, @CourseId, @Semester, @Status)";
                DatabaseHelper.ExecuteNonQuery(sql, BuildParameters(0, courseId));
                added++;
            }
            return added;
        }

        private bool UpdateOfferingGroup()
        {
            string[] oldKey = ParseGroupKey(hfOfferingId.Value);
            if (oldKey == null)
            {
                ShowMessage("❌ Error", "Invalid course offering group selected for edit.");
                return false;
            }

            string oldSession = oldKey[0];
            int oldProgrammeId = int.Parse(oldKey[1]);
            string oldStatus = oldKey[2];

            // Remove the old grouped offering first, then insert the selected courses as the new group.
            string deleteSql = @"DELETE FROM CourseOffering
                                 WHERE Session = @OldSession
                                   AND ProgrammeId = @OldProgrammeId
                                   AND Status = @OldStatus";
            SqlParameter[] deleteParams =
            {
                new SqlParameter("@OldSession", oldSession),
                new SqlParameter("@OldProgrammeId", oldProgrammeId),
                new SqlParameter("@OldStatus", oldStatus)
            };
            DatabaseHelper.ExecuteNonQuery(deleteSql, deleteParams);

            AddSelectedOfferings();
            return true;
        }

        private SqlParameter[] BuildParameters(int offeringId, int courseId)
        {
            return new[]
            {
                new SqlParameter("@Session", ddlSession.SelectedValue),
                new SqlParameter("@ProgrammeId", int.Parse(ddlProgramme.SelectedValue)),
                new SqlParameter("@CourseId", courseId),
                new SqlParameter("@Semester", 1),
                new SqlParameter("@Status", ddlStatus.SelectedValue),
                new SqlParameter("@OfferingId", offeringId)
            };
        }

        protected void gvOfferings_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string groupKey = Convert.ToString(e.CommandArgument);

            if (e.CommandName == "EditOffering")
                LoadOfferingGroupForEdit(groupKey);
            else if (e.CommandName == "DeleteOffering")
                ShowDeleteConfirmation(groupKey);
        }

        private void LoadOfferingGroupForEdit(string groupKey)
        {
            string[] key = ParseGroupKey(groupKey);
            if (key == null)
            {
                ShowMessage("❌ Error", "Invalid course offering group selected.");
                return;
            }

            string sql = @"SELECT * FROM CourseOffering
                           WHERE Session = @Session
                             AND ProgrammeId = @ProgrammeId
                             AND Status = @Status";
            SqlParameter[] p =
            {
                new SqlParameter("@Session", key[0]),
                new SqlParameter("@ProgrammeId", int.Parse(key[1])),
                new SqlParameter("@Status", key[2])
            };

            DataTable dt = DatabaseHelper.ExecuteQuery(sql, p);
            if (dt.Rows.Count == 0)
            {
                ShowMessage("❌ Error", "Course offering group not found.");
                return;
            }

            hfOfferingId.Value = groupKey;
            ddlSession.SelectedValue = key[0];
            ddlProgramme.SelectedValue = key[1];
            LoadCoursesByProgramme();

            foreach (ListItem item in cblCourses.Items)
                item.Selected = dt.AsEnumerable().Any(r => r["CourseId"].ToString() == item.Value);

            ddlStatus.SelectedValue = key[2];

            lblFormTitle.Text = "Edit Course Offering Group";
            btnSave.Text = "Update Selected Courses";
            lblCourseHint.Text = "Edit mode: tick all courses that should be open for this session/programme.";
            ShowMessage("Edit Mode", "Course offering group loaded. You can update the selected courses now.");
        }

        private string[] ParseGroupKey(string groupKey)
        {
            if (string.IsNullOrWhiteSpace(groupKey)) return null;
            string[] parts = groupKey.Split(new[] { "||" }, StringSplitOptions.None);
            return parts.Length == 3 ? parts : null;
        }

        private void ShowDeleteConfirmation(string groupKey)
        {
            string message = "Are you sure you want to delete this course offering group? This will delete all courses under the same session/programme/status group.";
            string script = string.Format("showMessageModal('⚠ Confirm Delete', '{0}', true, '{1}');",
                HttpUtility.JavaScriptStringEncode(message),
                HttpUtility.JavaScriptStringEncode(groupKey));
            ScriptManager.RegisterStartupScript(this, GetType(), "confirmDeleteOffering", script, true);
        }

        protected void btnDeleteConfirmed_Click(object sender, EventArgs e)
        {
            string[] key = ParseGroupKey(hfDeleteTarget.Value);
            if (key == null)
            {
                ShowMessage("❌ Error", "Invalid course offering group selected for deletion.");
                return;
            }

            try
            {
                string sql = @"DELETE FROM CourseOffering
                               WHERE Session = @Session
                                 AND ProgrammeId = @ProgrammeId
                                 AND Status = @Status";
                SqlParameter[] p =
                {
                    new SqlParameter("@Session", key[0]),
                    new SqlParameter("@ProgrammeId", int.Parse(key[1])),
                    new SqlParameter("@Status", key[2])
                };
                DatabaseHelper.ExecuteNonQuery(sql, p);

                ClearForm();
                LoadStats();
                LoadOfferings();
                ShowMessage("✅ Success", "Course offering group deleted successfully.");
            }
            catch (Exception ex)
            {
                ShowMessage("❌ Error", "Error: " + ex.Message);
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            hfOfferingId.Value = "";
            ddlSession.SelectedIndex = 0;
            ddlProgramme.SelectedIndex = 0;
            LoadCoursesByProgramme();
            ddlStatus.SelectedValue = "Open";
            lblFormTitle.Text = "Add Course Offering";
            btnSave.Text = "Save Selected Courses";
            lblCourseHint.Text = "Open the dropdown and tick one or more courses for the selected session.";
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            gvOfferings.PageIndex = 0;
            LoadOfferings();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlFilterStatus.SelectedValue = "";
            gvOfferings.PageIndex = 0;
            LoadOfferings();
        }

        protected void gvOfferings_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvOfferings.PageIndex = e.NewPageIndex;
            LoadOfferings();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        public string GetStatusCss(object status)
        {
            string value = Convert.ToString(status);
            return value == "Open" ? "status-open" : "status-closed";
        }

        private void ShowMessage(string title, string message)
        {
            string script = string.Format("showMessageModal('{0}', '{1}', false, 0);",
                HttpUtility.JavaScriptStringEncode(title),
                HttpUtility.JavaScriptStringEncode(message));
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"), script, true);
        }
    }
}
