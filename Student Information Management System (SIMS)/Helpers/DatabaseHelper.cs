using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace SIMS.Helpers
{
    /// <summary>
    /// Central database helper — all pages use this for connections and queries.
    /// Connection string is pulled from Web.config (key: "SIMSConnection").
    /// </summary>
    public static class DatabaseHelper
    {
        // ---------------------------------------------------------------
        // Grab the connection string from Web.config
        // ---------------------------------------------------------------
        private static string ConnectionString =>
            ConfigurationManager.ConnectionStrings["SIMSConnection"].ConnectionString;

        // ---------------------------------------------------------------
        // Open a new SqlConnection (caller must close/dispose it)
        // ---------------------------------------------------------------
        public static SqlConnection GetConnection()
        {
            return new SqlConnection(ConnectionString);
        }

        // ---------------------------------------------------------------
        // Execute a non-query (INSERT / UPDATE / DELETE)
        // Returns the number of rows affected.
        // ---------------------------------------------------------------
        public static int ExecuteNonQuery(string sql,
                                          SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.CommandType = CommandType.Text;
                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                conn.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        // ---------------------------------------------------------------
        // Execute a scalar query — returns the first column of first row.
        // ---------------------------------------------------------------
        public static object ExecuteScalar(string sql,
                                            SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.CommandType = CommandType.Text;
                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                conn.Open();
                return cmd.ExecuteScalar();
            }
        }

        // ---------------------------------------------------------------
        // Execute a SELECT and return a filled DataTable.
        // ---------------------------------------------------------------
        public static DataTable ExecuteQuery(string sql,
                                              SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.CommandType = CommandType.Text;
                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                conn.Open();
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }

        // ---------------------------------------------------------------
        // Execute a stored procedure and return a DataTable.
        // ---------------------------------------------------------------
        public static DataTable ExecuteStoredProcedure(string procName,
                                                        SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = GetConnection())
            using (SqlCommand cmd = new SqlCommand(procName, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                conn.Open();
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }
}