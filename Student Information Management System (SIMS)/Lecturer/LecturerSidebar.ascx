<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="LecturerSidebar.ascx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer.LecturerSidebar" %>

<div class="sidebar">

    <div class="sidebar-brand">
        <img src="../Images/Logo_Dashboard.png" class="brand-logo" alt="SIMS Logo" />
        <div class="brand-text">
            <div class="brand-name">SIMS</div>
            <div class="brand-sub">Lecturer Portal</div>
        </div>
    </div>

    <nav class="sidebar-nav">
        <div class="sidebar-section-label">Main</div>

        <a href="Lecturer_Dashboard.aspx" class="<%= NavClass("Lecturer_Dashboard") %>">
            <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
        </a>

        <a href="MyCourses.aspx" class="<%= NavClass("MyCourses") %>">
            <i class="fa-solid fa-book-open nav-icon"></i> My Courses
        </a>

        <div class="sidebar-section-label" style="margin-top:12px;">Academic</div>

        <a href="Attendance.aspx" class="<%= NavClass("Attendance") %>">
            <i class="fa-solid fa-clipboard-check nav-icon"></i> Attendance
        </a>

        <a href="AtRiskStudents.aspx" class="<%= NavClass("AtRiskStudents") %>">
            <i class="fa-solid fa-triangle-exclamation nav-icon"></i> At-Risk Students
        </a>

        <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>

        <a href="Announcements.aspx" class="<%= NavClass("Announcements") %>">
            <i class="fa-solid fa-bullhorn nav-icon"></i> Announcements
        </a>

        <a href="Notifications.aspx" class="<%= NavClass("Notifications") %>">
            <i class="fa-solid fa-bell nav-icon"></i> Notifications
        </a>

        <div class="sidebar-section-label" style="margin-top:12px;">Account</div>

        <a href="Profile.aspx" class="<%= NavClass("Profile") %>">
            <i class="fa-solid fa-circle-user nav-icon"></i> My Profile
        </a>
    </nav>

    <div class="sidebar-footer">
        <div class="sidebar-user">

            <div class="user-avatar sidebar-photo-avatar">
                <asp:Image ID="imgSidebarAvatar"
                    runat="server"
                    ImageUrl="~/ProfilePicture/default-profile.png"
                    CssClass="sidebar-avatar-img" />
            </div>

            <div class="user-info">
                <div class="user-name">
                    <asp:Label ID="lblSidebarName" runat="server" Text="Lecturer" />
                </div>
                <div class="user-role">Lecturer</div>
            </div>

        </div>

        <asp:LinkButton ID="lbLogout"
            runat="server"
            CssClass="sidebar-link"
            OnClientClick="showLogoutModal(); return false;">
            <i class="fa-solid fa-right-from-bracket"></i> Log Out
        </asp:LinkButton>
    </div>

</div>

<div id="logoutModal" class="logout-modal-overlay" onclick="hideLogoutModalOnBackdrop(event)">
    <div class="logout-modal-card" role="dialog" aria-modal="true" aria-labelledby="logoutTitle">
        <div class="logout-modal-top">
            <div class="logout-warning-icon">
                <i class="fa-solid fa-triangle-exclamation"></i>
            </div>
            <h3 id="logoutTitle" class="logout-title">Log Out</h3>
        </div>

        <p class="logout-message">Are you sure you want to log out?</p>

        <div class="logout-actions">
            <button type="button" class="logout-btn logout-btn-cancel" onclick="hideLogoutModal()">Cancel</button>

            <asp:LinkButton ID="btnConfirmLogout"
                runat="server"
                CssClass="logout-btn logout-btn-confirm"
                OnClick="btnConfirmLogout_Click">
                Log Out
            </asp:LinkButton>
        </div>
    </div>
</div>