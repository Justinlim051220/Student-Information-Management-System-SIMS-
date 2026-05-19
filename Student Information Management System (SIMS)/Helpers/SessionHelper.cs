using System;
using System.Web;
using System.Web.SessionState;

namespace SIMS.Helpers
{
    /// <summary>
    /// Centralised session management.
    /// Stores user data after login and provides role-guard helpers
    /// for every protected page.
    ///
    /// Session keys used:
    ///   SIMS_UserId    (int)
    ///   SIMS_Email     (string)
    ///   SIMS_Role      (int)  1=Admin/HoP | 2=Lecturer | 3=Student
    ///   SIMS_ProfileId (string) HoPId / LecturerId / StudentId
    ///   SIMS_FullName  (string)
    /// </summary>
    public static class SessionHelper
    {
        // ------- Role enum matching the DB CHECK constraint -------
        public const int ROLE_ADMIN = 1;
        public const int ROLE_LECTURER = 2;
        public const int ROLE_STUDENT = 3;

        // ------- Session keys (internal constants) -------
        private const string KEY_USERID = "SIMS_UserId";
        private const string KEY_EMAIL = "SIMS_Email";
        private const string KEY_ROLE = "SIMS_Role";
        private const string KEY_PROFILEID = "SIMS_ProfileId";
        private const string KEY_FULLNAME = "SIMS_FullName";

        // ---------------------------------------------------------------
        // Store login data in session after successful authentication.
        // ---------------------------------------------------------------
        public static void SetLogin(HttpSessionState session,
                                     int userId,
                                     string email,
                                     int role,
                                     string profileId,
                                     string fullName)
        {
            session[KEY_USERID] = userId;
            session[KEY_EMAIL] = email;
            session[KEY_ROLE] = role;
            session[KEY_PROFILEID] = profileId;
            session[KEY_FULLNAME] = fullName;
        }

        // ---------------------------------------------------------------
        // Getters
        // ---------------------------------------------------------------
        public static int GetUserId(HttpSessionState s) => s[KEY_USERID] is int v ? v : 0;
        public static string GetEmail(HttpSessionState s) => s[KEY_EMAIL] as string ?? "";
        public static int GetRole(HttpSessionState s) => s[KEY_ROLE] is int r ? r : 0;
        public static string GetProfileId(HttpSessionState s) => s[KEY_PROFILEID] as string ?? "";
        public static string GetFullName(HttpSessionState s) => s[KEY_FULLNAME] as string ?? "";

        // ---------------------------------------------------------------
        // Is the user currently logged in?
        // ---------------------------------------------------------------
        public static bool IsLoggedIn(HttpSessionState s) =>
            s[KEY_USERID] != null && GetUserId(s) > 0;

        // ---------------------------------------------------------------
        // Role guards — call at top of Page_Load on every protected page.
        // Redirects to Login if the role doesn't match.
        // ---------------------------------------------------------------
        public static void RequireAdmin(HttpSessionState s, HttpResponse response)
        {
            if (!IsLoggedIn(s) || GetRole(s) != ROLE_ADMIN)
                response.Redirect("~/Login.aspx", true);
        }

        public static void RequireLecturer(HttpSessionState s, HttpResponse response)
        {
            if (!IsLoggedIn(s) || GetRole(s) != ROLE_LECTURER)
                response.Redirect("~/Login.aspx", true);
        }

        public static void RequireStudent(HttpSessionState s, HttpResponse response)
        {
            if (!IsLoggedIn(s) || GetRole(s) != ROLE_STUDENT)
                response.Redirect("~/Login.aspx", true);
        }

        public static void RequireAnyLogin(HttpSessionState s, HttpResponse response)
        {
            if (!IsLoggedIn(s))
                response.Redirect("~/Login.aspx", true);
        }

        // ---------------------------------------------------------------
        // Clear session on logout.
        // ---------------------------------------------------------------
        public static void Logout(HttpSessionState session)
        {
            session.Clear();
            session.Abandon();
        }
    }
}