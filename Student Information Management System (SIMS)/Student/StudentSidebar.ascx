<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="StudentSidebar.ascx.cs" Inherits="Student_Information_Management_System__SIMS_.StudentSidebar" %>

<style>
    .sidebar-photo-avatar {
        width: 42px;
        height: 42px;
        border-radius: 50%;
        overflow: hidden;
        padding: 0 !important;
        flex-shrink: 0;
        background: #ffffff;
    }

    .sidebar-avatar-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 50%;
        display: block;
    }

    #logoutModal.logout-modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(17, 24, 39, 0.62);
        z-index: 9999;
        align-items: center;
        justify-content: center;
        padding: 20px;
    }

    #logoutModal .logout-modal-card {
        width: 100%;
        max-width: 400px;
        background: #ffffff;
        border-radius: 14px;
        overflow: hidden;
        box-shadow: 0 22px 60px rgba(15, 23, 42, 0.28);
        text-align: center;
        font-family: var(--font-primary);
        animation: logoutPop 0.18s ease-out;
    }

    @keyframes logoutPop {
        from { transform: translateY(8px) scale(0.98); opacity: 0; }
        to { transform: translateY(0) scale(1); opacity: 1; }
    }

    #logoutModal .logout-modal-top {
        padding: 36px 32px 20px;
    }

    #logoutModal .logout-warning-icon {
        width: 72px;
        height: 72px;
        margin: 0 auto 18px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: transparent;
        color: #f59e0b;
        font-size: 56px;
        line-height: 1;
    }

    #logoutModal .logout-warning-icon i {
        color: #f59e0b;
    }

    #logoutModal .logout-title {
        margin: 0;
        color: var(--text-primary);
        font-size: 20px;
        font-weight: 800;
        line-height: 1.25;
    }

    #logoutModal .logout-message {
        margin: 0;
        padding: 20px 32px;
        border-top: 1px solid var(--border-light);
        color: var(--text-secondary);
        font-size: 15px;
        font-weight: 500;
        line-height: 1.5;
    }

    #logoutModal .logout-actions {
        display: flex;
        justify-content: center;
        gap: 12px;
        padding: 18px 28px 28px;
    }

    #logoutModal .logout-btn {
        min-width: 118px;
        height: 44px;
        border-radius: 999px;
        font-family: var(--font-primary);
        font-size: 14px;
        font-weight: 800;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        text-decoration: none;
        transition: var(--transition);
    }

    #logoutModal .logout-btn-cancel {
        border: 2px solid var(--orange-main);
        background: #ffffff;
        color: var(--orange-main);
    }

    #logoutModal .logout-btn-cancel:hover {
        background: #fff7ed;
        transform: translateY(-1px);
    }

    #logoutModal .logout-btn-confirm {
        border: 2px solid transparent;
        background: var(--orange-gradient);
        color: #ffffff !important;
        box-shadow: var(--shadow-orange);
    }

    #logoutModal .logout-btn-confirm:hover {
        transform: translateY(-1px);
        color: #ffffff !important;
    }
</style>

<div class="sidebar" id="sidebar">

    <div class="sidebar-brand">
        <img src="../Images/Logo_Dashboard.png" alt="ONTI SIMS" class="brand-logo" />
        <div class="brand-text">
            <div class="brand-name">SIMS</div>
            <div class="brand-sub">Student Portal</div>
        </div>
    </div>

    <nav class="sidebar-nav">
        <div class="sidebar-section-label">Main</div>

        <a href="Student_Dashboard.aspx" class="<%= NavClass("Student_Dashboard") %>">
            <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
        </a>

        <div class="sidebar-section-label" style="margin-top:12px;">Academic</div>

        <a href="MyCourses.aspx" class="<%= NavClass("MyCourses") %>">
            <i class="fa-solid fa-book-open nav-icon"></i> My Courses
        </a>

        <a href="Attendance.aspx" class="<%= NavClass("Attendance") %>">
            <i class="fa-solid fa-calendar-check nav-icon"></i> Attendance
        </a>

        <a href="Student_Enrollment.aspx" class="<%= NavClass("Student_Enrollment") %>">
            <i class="fa-solid fa-clipboard-list nav-icon"></i> Enrollment
        </a>

        <a href="Results.aspx" class="<%= NavClass("Results") %>">
            <i class="fa-solid fa-chart-line nav-icon"></i> Results
        </a>

        <div class="sidebar-section-label" style="margin-top:12px;">Finance</div>

        <a href="Student_Payment.aspx" class="<%= NavClass("Student_Payment") %>">
            <i class="fa-solid fa-money-bill-wave nav-icon"></i> Payment
        </a>

        <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>

        <a href="Notification.aspx" class="<%= NavClass("Notification") %>">
            <i class="fa-solid fa-bell nav-icon"></i> Notifications
        </a>

        <a href="Contacts.aspx" class="<%= NavClass("Contacts") %>">
            <i class="fa-solid fa-address-book nav-icon"></i> Contacts
        </a>

        <div class="sidebar-section-label" style="margin-top:12px;">Account</div>

        <a href="MyProfile.aspx" class="<%= NavClass("MyProfile") %>">
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
                    <asp:Label ID="lblSidebarName" runat="server" Text="Student" />
                </div>
                <div class="user-role">Student</div>
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

<script>
    function showLogoutModal() {
        var modal = document.getElementById('logoutModal');
        if (modal) modal.style.display = 'flex';
    }

    function hideLogoutModal() {
        var modal = document.getElementById('logoutModal');
        if (modal) modal.style.display = 'none';
    }

    function hideLogoutModalOnBackdrop(event) {
        if (event.target && event.target.id === 'logoutModal') {
            hideLogoutModal();
        }
    }
</script>