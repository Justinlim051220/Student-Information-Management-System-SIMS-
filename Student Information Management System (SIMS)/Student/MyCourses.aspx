<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyCourses.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student.MyCourses" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Courses - SIMS Student Portal</title>

    <link rel="stylesheet" href="../Styles/SIMS.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        .sidebar {
            position: fixed;
            top: 0; left: 0; width: 260px; height: 100vh;
            overflow-y: auto; overflow-x: hidden; scrollbar-width: thin;
        }
        .main-wrapper { margin-left: 260px; }
        .filter-bar {
            display: grid; grid-template-columns: 1fr 1fr auto; gap: 12px; align-items: end; margin-bottom: 22px;
        }
        .filter-item label {
            display: block; font-size: 12px; font-weight: 800; color: var(--text-secondary);
            margin-bottom: 6px; text-transform: uppercase; letter-spacing: .4px;
        }
        .course-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 18px; overflow: visible; }
        
        /* Updated Course Card rules to support absolute positioning controls */
        .course-card {
            position: relative; border: 1px solid var(--border-light); border-radius: var(--radius-md);
            background: var(--white); overflow: visible; transition: var(--transition); min-height: 190px;
        }
        .course-card:hover { box-shadow: var(--shadow-card); transform: translateY(-2px); }
        .course-body-link { display: block; padding: 26px 20px 20px; cursor: pointer; color: inherit; text-decoration: none; }
        
        .course-name { font-family: var(--font-accent); font-size: 18px; font-weight: 800; color: var(--text-primary); margin-bottom: 8px; padding-right: 25px; }
        .course-code { font-size: 13px; font-weight: 800; color: var(--orange-main); margin-bottom: 8px; }
        .course-session { font-size: 13px; color: var(--text-muted); font-weight: 700; }
        .course-semester { margin-top: 6px; font-size: 13px; color: var(--text-secondary); font-weight: 700; }
        
        /* Layout Ordering Action Menu Elements */
        .card-actions-menu { position: absolute; top: 15px; right: 15px; z-index: 10; display: inline-block; }
        .actions-toggle-btn { background: none; border: none; color: var(--text-muted); cursor: pointer; padding: 4px 8px; font-size: 16px; border-radius: 4px; }
        .actions-toggle-btn:hover { background: #f0f0f0; color: var(--text-primary); }
        
        .actions-dropdown-list {
            display: none; position: absolute; right: 0; top: 100%; background: #ffffff;
            min-width: 140px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); border: 1px solid #e2e8f0;
            border-radius: 6px; padding: 4px 0; z-index: 100;
        }
        .card-actions-menu:hover .actions-dropdown-list { display: block; }
        
        .action-menu-item {
            display: block; width: 100%; text-align: left; padding: 8px 14px; background: none;
            border: none; font-size: 13px; color: #334155; cursor: pointer; font-weight: 600;
        }
        .action-menu-item:hover { background: #f8fafc; color: var(--orange-main); }
        .action-menu-item i { margin-right: 8px; width: 14px; text-align: center; }

        .empty-state { text-align: center; padding: 46px 20px; color: var(--text-muted); }
        .empty-state i { font-size: 42px; color: var(--orange-main); margin-bottom: 12px; }

        @media (max-width: 1200px) { .course-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 900px) {
            .filter-bar { grid-template-columns: 1fr; }
            .course-grid { grid-template-columns: 1fr; }
        }
        .sidebar-user { margin-bottom: 18px; align-items: flex-start; }
        .user-info { padding-top: 4px; }
        .user-name { margin-bottom: 4px; }
        .user-role { margin-top: 2px; }
        /* ===== Synchronized Logout Modal Styles from Dashboard ===== */
        .modal-overlay {
          position: fixed;
          inset: 0;
          background: rgba(30,30,40,.60);
          display: none;
          align-items: center;
          justify-content: center;
          z-index: 9999;
          padding: 18px;
        }
        .system-dialog .modal-box {
          width: 100%;
          max-width: 400px;
          background: #fff;
          border-radius: 16px;
          box-shadow: 0 12px 40px rgba(0,0,0,.28);
          text-align: center;
          overflow: hidden;
          animation: studentModalPop .18s ease-out;
        }
        @keyframes studentModalPop {
          from { opacity: 0; transform: translateY(10px) scale(.98); }
          to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .system-dialog .modal-head {
          background: #fff;
          color: #1a1a2e;
          display: flex;
          align-items: center;
          justify-content: center;
          flex-direction: column;
          border-bottom: 1px solid #ececec;
          padding: 36px 32px 18px;
          font-size: 1.2rem;
          font-weight: 800;
          gap: 14px;
        }
        .system-dialog .modal-body {
          padding: 18px 32px 28px;
          color: #555;
          font-size: .97rem;
          line-height: 1.65;
        }
        .system-dialog .modal-actions {
          display: flex;
          justify-content: center;
          align-items: center;
          gap: 12px;
          padding: 0 32px 28px;
        }
        .system-dialog .modal-cancel,
        .system-dialog .modal-submit {
          min-width: 110px;
          padding: 10px 32px;
          border-radius: 50px;
          font-size: .95rem;
          font-weight: 700;
          cursor: pointer;
          text-decoration: none;
          transition: all .18s ease;
          box-sizing: border-box;
          display: inline-flex;
          align-items: center;
          justify-content: center;
        }
        .system-dialog .modal-cancel {
          background: transparent;
          border: 2px solid #e8a838;
          color: #e8a838;
        }
        .system-dialog .modal-submit {
          background: #e8a838;
          border: 2px solid #e8a838;
          color: #fff;
          box-shadow: 0 8px 18px rgba(232,168,56,.22);
        }
        .system-dialog .modal-cancel:hover { background: #fff8e1; }
        .system-dialog .modal-submit:hover { background: #d99a2e; border-color: #d99a2e; }

        .logout-warning-icon,
        .prompt-modal .cm-icon-wrap.logout-warning-icon {
            width: 72px !important;
            height: 72px !important;
            margin: 0 auto 16px !important;
            padding: 0 !important;
            border: 0 !important;
            border-radius: 0 !important;
            background: transparent !important;
            color: #f59e0b !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            line-height: 1 !important;
            box-shadow: none !important;
            font-family: inherit !important;
        }
        .logout-warning-icon i,
        .prompt-modal .cm-icon-wrap.logout-warning-icon i {
            color: #f59e0b !important;
            font-size: 56px !important;
            line-height: 1 !important;
            display: block !important;
        }
    </style>
</head>
<body>
<form id="form1" runat="server">

<div class="sidebar" id="sidebar">
  <div class="sidebar-brand">
    <img src="~/Images/Logo_Dashboard.png" runat="server" alt="ONTI SIMS" class="brand-logo" />
    <div class="brand-text">
      <div class="brand-name">SIMS</div>
      <div class="brand-sub">Student Portal</div>
    </div>
  </div>

  <nav class="sidebar-nav">
    <div class="sidebar-section-label">Main</div>
    <a href="Student_Dashboard.aspx" class="sidebar-link">
      <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Academic</div>
    <a href="MyCourses.aspx" class="sidebar-link active">
      <i class="fa-solid fa-book-open nav-icon"></i> My Courses
    </a>
    <a href="Attendance.aspx" class="sidebar-link">
      <i class="fa-solid fa-calendar-check nav-icon"></i> Attendance
    </a>
    <a href="Student_Enrollment.aspx" class="sidebar-link">
      <i class="fa-solid fa-clipboard-list nav-icon"></i> Enrollment
    </a>
    <a href="Results.aspx" class="sidebar-link">
      <i class="fa-solid fa-chart-line nav-icon"></i> Results
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Finance</div>
    <a href="Student_Payment.aspx" class="sidebar-link">
      <i class="fa-solid fa-money-bill-wave nav-icon"></i> Payment
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>
    <a href="Notification.aspx" class="sidebar-link">
      <i class="fa-solid fa-bell nav-icon"></i> Notifications
    </a>
    <a href="Contacts.aspx" class="sidebar-link">
      <i class="fa-solid fa-address-book nav-icon"></i> Contacts
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Account</div>
    <a href="MyProfile.aspx" class="sidebar-link">
      <i class="fa-solid fa-circle-user nav-icon"></i> My Profile
    </a>
  </nav>

  <div class="sidebar-footer">
    <div class="sidebar-user">
      <div class="user-avatar">
         <asp:Label ID="lblAvatarInitial" runat="server" Text="S" />
     </div>
      <div class="user-info">
        <div class="user-name">
          <asp:Label ID="lblSidebarName" runat="server" Text="Student" />
        </div>
        <div class="user-role">Student</div>
      </div>
    </div>
    <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link" OnClientClick="showLogoutModal(); return false;">
      <i class="fa-solid fa-right-from-bracket"></i> Log Out
    </asp:LinkButton>
  </div>
</div>

<div class="main-wrapper">
    <div class="topbar">
        <div>
            <div class="topbar-title">My Courses</div>
            <div class="topbar-date"><asp:Label ID="lblDate" runat="server" /></div>
        </div>
        <div class="topbar-right">
            <a href="Notification.aspx" class="topbar-icon-btn" title="Notifications">
                <i class="fa-solid fa-bell"></i>
                <asp:Panel ID="pnlNotifBadge" runat="server" CssClass="badge-dot" Visible="false" />
            </a>
            <a href="MyProfile.aspx" class="topbar-icon-btn" title="My Profile">
                <i class="fa-solid fa-circle-user"></i>
            </a>
        </div>
    </div>

    <div class="page-content">
        <div class="page-header">
            <h1>My Enrolled Courses</h1>
            <p>View your registered academic modules and course details.</p>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="alert alert-danger" Visible="false" style="display:block; margin-bottom:20px; padding:12px; border-radius:4px;" />

        <div class="card" style="margin-bottom:24px;">
            <div class="card-body">
                <div class="filter-bar">
                    <div class="filter-item">
                        <label>Academic Session</label>
                        <asp:DropDownList ID="ddlFilterSession" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSession_SelectedIndexChanged" />
                    </div>
                    <div class="filter-item">
                        <label>Semester</label>
                        <asp:DropDownList ID="ddlFilterSemester" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSemester_SelectedIndexChanged" />
                    </div>
                    <div class="filter-item">
                        <asp:Button ID="btnSearch" runat="server" Text="Filter" CssClass="btn btn-primary btn-sm" OnClick="btnSearch_Click" Style="width:auto;" />
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <span class="card-title">Enrolled Courses</span>
                <span class="badge badge-orange"><asp:Label ID="lblTotal" runat="server" Text="0" /> Modules</span>
            </div>

            <div class="card-body">
                <asp:Repeater ID="rptCourses" runat="server">
                    <HeaderTemplate>
                        <div class="course-grid">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="course-card">
                            <a class="course-body-link" href='CourseDetails.aspx?courseId=<%# Eval("CourseId") %>&session=<%# Server.UrlEncode(Convert.ToString(Eval("Session"))) %>'>
                                <div class="course-name"><%# Eval("CourseName") %></div>
                                <div class="course-code"><%# Eval("CourseCode") %></div>
                                <div class="course-session">
                                    <i class="fa-solid fa-calendar-days"></i> Session: <%# Eval("Session") %>
                                </div>
                                <div class="course-semester">
                                    <i class="fa-solid fa-layer-group"></i> Semester: <%# Eval("Semester") %>
                                </div>
                            </a>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                    <i class="fa-solid fa-book-open"></i>
                    <h3>No courses found</h3>
                    <p>You are not enrolled in any modules for the selected criteria.</p>
                </asp:Panel>
            </div>
        </div>
    </div>
</div>

<div id="logoutModal" class="modal-overlay system-dialog">
  <div class="modal-box">
    <div class="modal-head">
      <div class="logout-warning-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
      <span>Log Out</span>
    </div>
    <div class="modal-body">
      Are you sure you want to log out?
    </div>
    <div class="modal-actions">
      <button type="button" class="modal-cancel" onclick="hideLogoutModal();">Cancel</button>
      <asp:LinkButton ID="btnConfirmLogout" runat="server"
        CssClass="modal-submit" OnClick="lbLogout_Click">Log Out</asp:LinkButton>
    </div>
  </div>
</div>

<script>
    function showLogoutModal() { document.getElementById('logoutModal').style.display = 'flex'; }
    function hideLogoutModal() { document.getElementById('logoutModal').style.display = 'none'; }
</script>
</form>
</body>
</html>
