using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Student_Information_Management_System__SIMS_.Student
{
    public partial class Contacts : Page
    {
        string connectionString =
            @"Data Source=(localdb)\MSSQLLocalDB;
              Initial Catalog=SIMS;
              Integrated Security=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadContacts();
            }
        }

        private void LoadContacts()
        {
            using (SqlConnection con =
                new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT *
                    FROM Contacts
                    ORDER BY Name";

                SqlCommand cmd =
                    new SqlCommand(query, con);

                SqlDataAdapter da =
                    new SqlDataAdapter(cmd);

                DataTable dt = new DataTable();

                da.Fill(dt);

                rptContacts.DataSource = dt;
                rptContacts.DataBind();

                lblEmpty.Visible = dt.Rows.Count == 0;
            }
        }
    }
}