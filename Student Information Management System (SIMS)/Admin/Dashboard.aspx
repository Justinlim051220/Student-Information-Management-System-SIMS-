﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Admin_Dashboard" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SIMS – Admin Dashboard | ONTI International University</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
  <link rel="stylesheet" href="../Styles/SIMS.css" />

  <style>
    /* Quick-action buttons */
    .quick-actions {
      display: flex;
      gap    : 12px;
      flex-wrap: wrap;
      margin-bottom: 28px;
    }
    .quick-btn {
      display        : flex;
      align-items    : center;
      gap            : 8px;
      padding        : 10px 20px;
      border-radius  : var(--radius-pill);
      border         : 2px solid var(--orange-main);
      background     : var(--white);
      color          : var(--orange-dark);
      font-family    : var(--font-primary);
      font-size      : 13px;
      font-weight    : 700;
      cursor         : pointer;
      transition     : var(--transition);
      text-decoration: none;
    }
    .quick-btn:hover {
      background: var(--orange-gradient);
      color     : var(--white);
      border-color: transparent;
      box-shadow: var(--shadow-orange);
      transform : translateY(-2px);
    }

    /* Recent activity list */
    .activity-list { list-style: none; }
    .activity-item {
      display       : flex;
      align-items   : flex-start;
      gap           : 12px;
      padding       : 12px 0;
      border-bottom : 1px solid var(--border-light);
    }
    .activity-item:last-child { border-bottom: none; }
    .activity-dot {
      width        : 10px; height: 10px;
      border-radius: 50%;
      background   : var(--orange-main);
      margin-top   : 5px;
      flex-shrink  : 0;
    }
    .activity-dot.green { background: var(--success); }
    .activity-dot.blue  { background: var(--info);    }
    .activity-dot.red   { background: var(--danger);  }

    .activity-text { font-size: 13px; color: var(--text-secondary); line-height: 1.5; }
    .activity-text strong { color: var(--text-primary); }
    .activity-time { font-size: 11px; color: var(--text-muted); display: block; margin-top: 2px; }

    /* Mini chart placeholder bars */
    .mini-chart {
      display: flex;
      align-items: flex-end;
      gap    : 6px;
      height : 60px;
    }
    .mini-bar {
      flex          : 1;
      border-radius : 4px 4px 0 0;
      background    : var(--orange-gradient);
      opacity       : 0.8;
      transition    : opacity 0.2s;
    }
    .mini-bar:hover { opacity: 1; }

    /* Move name + role upward and separate from logout */
    .sidebar-user{
        margin-bottom:18px;
        align-items:flex-start;
    }

    .user-info{
        padding-top:4px;
    }

    .user-name{
        margin-bottom:4px;
    }

    .user-role{
        margin-top:2px;
    }
    .sidebar{
        position: fixed;
        top: 0;
        left: 0;
        width: 260px;
        height: 100vh;

        overflow-y: auto;      /* ENABLE VERTICAL SCROLL */
        overflow-x: hidden;

        scrollbar-width: thin; /* Firefox */
    }


    .sidebar-photo-avatar {
        width: 42px;
        height: 42px;
        border-radius: 50%;
        overflow: hidden;
        padding: 0 !important;
        flex-shrink: 0;
    }

    .sidebar-avatar-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 50%;
        display: block;
    }

  

    /* ================================================================
       Logout confirmation prompt - same clean dialog style
       ================================================================ */
    .logout-modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(17, 24, 39, 0.62);
        z-index: 9999;
        align-items: center;
        justify-content: center;
        padding: 20px;
    }

    .logout-modal-card {
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
        to   { transform: translateY(0) scale(1); opacity: 1; }
    }

    .logout-modal-top {
        padding: 36px 32px 20px;
    }

    .logout-warning-icon {
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

    .logout-warning-icon i {
        color: #f59e0b;
    }

    .logout-title {
        margin: 0;
        color: var(--text-primary);
        font-size: 20px;
        font-weight: 800;
        line-height: 1.25;
    }

    .logout-message {
        margin: 0;
        padding: 20px 32px;
        border-top: 1px solid var(--border-light);
        color: var(--text-secondary);
        font-size: 15px;
        font-weight: 500;
        line-height: 1.5;
    }

    .logout-actions {
        display: flex;
        justify-content: center;
        gap: 12px;
        padding: 18px 28px 28px;
    }

    .logout-btn {
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

    .logout-btn-cancel {
        border: 2px solid var(--orange-main);
        background: #ffffff;
        color: var(--orange-main);
    }

    .logout-btn-cancel:hover {
        background: #fff7ed;
        transform: translateY(-1px);
    }

    .logout-btn-confirm {
        border: 2px solid transparent;
        background: var(--orange-gradient);
        color: #ffffff !important;
        box-shadow: var(--shadow-orange);
    }

    .logout-btn-confirm:hover {
        transform: translateY(-1px);
        color: #ffffff !important;
    }

  

    /* ================================================================
       Professional admin dashboard upgrade
       ================================================================ */
    .main-wrapper {
        min-height: 100vh;
        background: #f6f8fb;
    }

    .topbar {
        background: #ffffff !important;
        border-bottom: 1px solid #edf0f6 !important;
        box-shadow: 0 6px 18px rgba(15, 23, 42, 0.03);
    }

    .page-content {
        padding: 28px 34px 40px !important;
    }

    .admin-hero {
        background: linear-gradient(135deg, #fff7ed 0%, #ffffff 58%, #fff3d6 100%);
        border: 1px solid rgba(245, 166, 35, .22);
        border-radius: 26px;
        box-shadow: 0 18px 42px rgba(15, 23, 42, .08);
        padding: 26px;
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 22px;
    }

    .admin-hero-left {
        display: flex;
        align-items: center;
        gap: 18px;
        min-width: 0;
    }

    .admin-hero-icon {
        width: 74px;
        height: 74px;
        border-radius: 24px;
        background: var(--orange-gradient);
        color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 31px;
        box-shadow: var(--shadow-orange);
        flex-shrink: 0;
    }

    .admin-hero-kicker {
        font-size: 12px;
        font-weight: 900;
        letter-spacing: .08em;
        text-transform: uppercase;
        color: var(--orange-dark);
    }

    .admin-hero-title {
        font-family: var(--font-accent);
        font-size: 30px;
        line-height: 1.12;
        font-weight: 900;
        color: var(--text-primary);
        margin-top: 5px;
    }

    .admin-hero-text {
        margin-top: 8px;
        color: var(--text-secondary);
        font-size: 14px;
        font-weight: 700;
        line-height: 1.55;
    }

    .admin-hero-actions {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
        justify-content: flex-end;
    }

    .admin-hero-btn {
        border-radius: 999px;
        padding: 11px 18px;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        font-weight: 900;
        font-size: 13px;
        text-decoration: none;
        transition: var(--transition);
        white-space: nowrap;
    }

    .admin-hero-btn.primary {
        color: #ffffff;
        background: var(--orange-gradient);
        box-shadow: var(--shadow-orange);
        border: 2px solid transparent;
    }

    .admin-hero-btn.secondary {
        color: var(--orange-dark);
        background: #ffffff;
        border: 2px solid rgba(245, 166, 35, .35);
    }

    .admin-hero-btn:hover {
        transform: translateY(-2px);
        text-decoration: none;
    }

    .admin-kpi-grid {
        display: grid;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        gap: 18px;
        margin-bottom: 24px;
    }

    .admin-kpi-card {
        position: relative;
        overflow: hidden;
        background: #ffffff;
        border: 1px solid #edf0f6;
        border-radius: 22px;
        padding: 22px;
        min-height: 130px;
        box-shadow: 0 14px 30px rgba(15, 23, 42, .06);
    }

    .admin-kpi-card::after {
        content: '';
        position: absolute;
        right: -36px;
        top: -36px;
        width: 108px;
        height: 108px;
        border-radius: 50%;
        background: rgba(245, 166, 35, .10);
    }

    .admin-kpi-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 14px;
        position: relative;
        z-index: 1;
    }

    .admin-kpi-icon {
        width: 48px;
        height: 48px;
        border-radius: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #ffffff;
        font-size: 20px;
        box-shadow: 0 10px 24px rgba(15,23,42,.10);
    }

    .admin-kpi-icon.orange { background: var(--orange-gradient); }
    .admin-kpi-icon.blue { background: linear-gradient(135deg, #3b82f6, #60a5fa); }
    .admin-kpi-icon.green { background: linear-gradient(135deg, #16a34a, #4ade80); }
    .admin-kpi-icon.red { background: linear-gradient(135deg, #ef4444, #fb7185); }

    .admin-kpi-value {
        margin-top: 18px;
        font-size: 31px;
        line-height: 1;
        font-weight: 900;
        color: var(--text-primary);
        position: relative;
        z-index: 1;
    }

    .admin-kpi-label {
        margin-top: 8px;
        color: var(--text-secondary);
        font-size: 13px;
        font-weight: 900;
        text-transform: uppercase;
        letter-spacing: .04em;
        position: relative;
        z-index: 1;
    }

    .admin-kpi-note {
        margin-top: 6px;
        color: var(--text-muted);
        font-size: 12px;
        font-weight: 700;
        position: relative;
        z-index: 1;
    }

    .admin-quick-panel {
        background: #ffffff;
        border: 1px solid #edf0f6;
        border-radius: 22px;
        box-shadow: 0 14px 30px rgba(15, 23, 42, .06);
        padding: 18px;
        margin-bottom: 24px;
    }

    .admin-section-title {
        display: flex;
        align-items: center;
        gap: 10px;
        color: var(--text-primary);
        font-size: 16px;
        font-weight: 900;
        margin-bottom: 14px;
    }

    .admin-section-title i {
        color: var(--orange-main);
    }

    .quick-actions {
        margin-bottom: 0 !important;
    }

    .quick-btn {
        background: #fffaf5 !important;
        border: 1px solid #f3dfc2 !important;
        color: #9a4f00 !important;
        padding: 11px 16px !important;
        box-shadow: none !important;
    }

    .quick-btn:hover {
        color: #ffffff !important;
        background: var(--orange-gradient) !important;
        border-color: transparent !important;
        box-shadow: var(--shadow-orange) !important;
    }

    .admin-card-grid {
        display: grid;
        grid-template-columns: minmax(0, 1.2fr) minmax(0, .8fr);
        gap: 24px;
    }

    .admin-card-grid.equal {
        grid-template-columns: repeat(2, minmax(0, 1fr));
        margin-top: 24px;
    }

    .card {
        border-radius: 22px !important;
        border: 1px solid #edf0f6 !important;
        box-shadow: 0 14px 30px rgba(15, 23, 42, .06) !important;
        overflow: hidden;
    }

    .card-header {
        background: #ffffff !important;
        border-bottom: 1px solid #edf0f6 !important;
        padding: 18px 20px !important;
    }

    .card-title {
        font-size: 16px !important;
        font-weight: 900 !important;
        color: var(--text-primary) !important;
    }

    .data-table th {
        background: #fff7ed !important;
        color: #8a4b09 !important;
        font-size: 12px !important;
        text-transform: uppercase;
        letter-spacing: .04em;
    }

    .fee-status-dashboard {
        display: grid;
        gap: 14px;
    }

    .fee-status-row {
        display: grid;
        grid-template-columns: 82px minmax(0, 1fr) 38px;
        gap: 12px;
        align-items: center;
        font-size: 13px;
        font-weight: 800;
        color: var(--text-secondary);
    }

    .fee-status-track {
        height: 12px;
        border-radius: 999px;
        overflow: hidden;
        background: #eef2f7;
    }

    .fee-status-fill {
        width: 0%;
        height: 100%;
        border-radius: 999px;
        transition: width .45s ease;
    }

    .fee-status-fill.paid { background: linear-gradient(135deg, #16a34a, #4ade80); }
    .fee-status-fill.pending { background: var(--orange-gradient); }
    .fee-status-fill.overdue { background: linear-gradient(135deg, #ef4444, #fb7185); }
@media (max-width: 1180px) {
        .admin-kpi-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        .admin-card-grid,
        .admin-card-grid.equal { grid-template-columns: 1fr; }
    }

    @media (max-width: 720px) {
        .page-content { padding: 20px !important; }
        .admin-hero { flex-direction: column; align-items: flex-start; }
        .admin-hero-actions { justify-content: flex-start; }
        .admin-kpi-grid { grid-template-columns: 1fr; }
    }

  </style>
</head>
<body>
    <form id="form1" runat="server">

<!-- ================================================================
     SIDEBAR
     ================================================================ -->
<div class="sidebar" id="sidebar">

 <!-- Brand -->
<div class="sidebar-brand">
    <img src="~/Images/Logo_Dashboard.png" runat="server" alt="ONTI SIMS" class="brand-logo" />
    
    <div class="brand-text">
        <div class="brand-name">SIMS</div>
        <div class="brand-sub">Admin Portal</div>
    </div>
</div>

  <!-- Navigation -->
  <nav class="sidebar-nav">
    <div class="sidebar-section-label">Overview</div>
    <a href="Dashboard.aspx" class="sidebar-link active">
      <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">User Management</div>
    <a href="ManageStudents.aspx" class="sidebar-link">
      <i class="fa-solid fa-user-graduate nav-icon"></i> Students
    </a>
    <a href="ManageLecturers.aspx" class="sidebar-link">
      <i class="fa-solid fa-chalkboard-teacher nav-icon"></i> Lecturers
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Academic Setup</div>
    <a href="ManageProgrammes.aspx" class="sidebar-link">
      <i class="fa-solid fa-layer-group nav-icon"></i> Programmes
    </a>
    <a href="ManageCourses.aspx" class="sidebar-link">
      <i class="fa-solid fa-book-open nav-icon"></i> Courses
    </a>
    <a href="AssignLecturerCourse.aspx" class="sidebar-link">
      <i class="fa-solid fa-user-check nav-icon"></i> Assign Course
    </a>
    <a href="CourseOffering.aspx" class="sidebar-link">
      <i class="fa-solid fa-calendar-check nav-icon"></i> Course Offering
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Enrollment</div>
    <a href="Admin_enrolment.aspx" class="sidebar-link">
      <i class="fa-solid fa-clipboard-list nav-icon"></i> Enrollment
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Finance & Reports</div>
    <a href="ManageFees.aspx" class="sidebar-link">
      <i class="fa-solid fa-money-bill-wave nav-icon"></i> Fees
    </a>
    <a href="Reports.aspx" class="sidebar-link">
      <i class="fa-solid fa-chart-bar nav-icon"></i> Reports
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>
    <a href="Admin_Announcement.aspx" class="sidebar-link">
      <i class="fa-solid fa-bullhorn nav-icon"></i> Announcements
    </a>
    <a href="Admin_Notification.aspx" class="sidebar-link">
      <i class="fa-solid fa-bell nav-icon"></i> Notifications
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Account</div>
    <a href="Admin_Profile.aspx" class="sidebar-link">
      <i class="fa-solid fa-circle-user nav-icon"></i> My Profile
    </a>
  </nav>

  <!-- Sidebar user footer -->
  <div class="sidebar-footer">
    <div class="sidebar-user">
      <div class="user-avatar" id="divSidebarInitial" runat="server">
        <asp:Label ID="lblAvatarInitial" runat="server" Text="A" />
      </div>
      <div class="user-avatar sidebar-photo-avatar" id="divSidebarPhoto" runat="server" visible="false">
        <asp:Image ID="imgSidebarAvatar" runat="server" CssClass="sidebar-avatar-img" />
      </div>
      <div class="user-info">
        <div class="user-name">
          <asp:Label ID="lblSidebarName" runat="server" Text="Admin" />
        </div>
        <div class="user-role">Head of Programme</div>
      </div>
    </div>
    <!-- Log Out -->
        <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link" OnClientClick="showLogoutModal(); return false;">
        <i class="fa-solid fa-right-from-bracket"></i> Log Out
    </asp:LinkButton>
  </div>

</div><!-- /sidebar -->

<!-- ================================================================
     MAIN CONTENT
     ================================================================ -->

<div class="main-wrapper">

  <!-- Topbar -->
  <div class="topbar">
    <div>
      <div class="topbar-title">Dashboard</div>
      <div class="topbar-date">
        <asp:Label ID="lblDate" runat="server" Text="" />
      </div>
    </div>
    <div class="topbar-right">
      <a href="Admin_Notification.aspx" class="topbar-icon-btn" title="Notifications">
        <i class="fa-solid fa-bell"></i>
        <asp:Panel ID="pnlNotifBadge" runat="server" CssClass="badge-dot" Visible="false" />
      </a>
      <a href="Admin_Profile.aspx" class="topbar-icon-btn" title="My Profile">
        <i class="fa-solid fa-circle-user"></i>
      </a>
    </div>
  </div>

  <!-- Page content -->
  <div class="page-content">

    <!-- Professional hero -->
    <section class="admin-hero">
      <div class="admin-hero-left">
        <div class="admin-hero-icon">
          <i class="fa-solid fa-shield-halved"></i>
        </div>
        <div>
          <div class="admin-hero-kicker">Admin Control Centre</div>
          <div class="admin-hero-title">
            Welcome back, <asp:Label ID="lblWelcomeName" runat="server" Text="Admin" />
          </div>
          <div class="admin-hero-text">
            Monitor student enrolment, academic setup, payments, announcements, and reports from one professional dashboard.
          </div>
        </div>
      </div>

      <div class="admin-hero-actions">
        <a href="Reports.aspx" class="admin-hero-btn secondary">
          <i class="fa-solid fa-chart-line"></i> View Reports
        </a>
        <a href="ManageFees.aspx" class="admin-hero-btn primary">
          <i class="fa-solid fa-receipt"></i> Manage Fees
        </a>
      </div>
    </section>

    <!-- KPI cards -->
    <section class="admin-kpi-grid">
      <div class="admin-kpi-card">
        <div class="admin-kpi-top">
          <div class="admin-kpi-icon orange"><i class="fa-solid fa-user-graduate"></i></div>
        </div>
        <div class="admin-kpi-value"><asp:Label ID="lblTotalStudents" runat="server" Text="0" /></div>
        <div class="admin-kpi-label">Active students</div>
        <div class="admin-kpi-note">Users currently active in SIMS</div>
      </div>

      <div class="admin-kpi-card">
        <div class="admin-kpi-top">
          <div class="admin-kpi-icon blue"><i class="fa-solid fa-chalkboard-teacher"></i></div>
        </div>
        <div class="admin-kpi-value"><asp:Label ID="lblTotalLecturers" runat="server" Text="0" /></div>
        <div class="admin-kpi-label">Lecturers</div>
        <div class="admin-kpi-note">Active lecturer accounts</div>
      </div>

      <div class="admin-kpi-card">
        <div class="admin-kpi-top">
          <div class="admin-kpi-icon green"><i class="fa-solid fa-layer-group"></i></div>
        </div>
        <div class="admin-kpi-value"><asp:Label ID="lblTotalProgrammes" runat="server" Text="0" /></div>
        <div class="admin-kpi-label">Programmes</div>
        <div class="admin-kpi-note">Available academic programmes</div>
      </div>

      <div class="admin-kpi-card">
        <div class="admin-kpi-top">
          <div class="admin-kpi-icon red"><i class="fa-solid fa-money-bill-wave"></i></div>
        </div>
        <div class="admin-kpi-value"><asp:Label ID="lblPendingFees" runat="server" Text="0" /></div>
        <div class="admin-kpi-label">Pending payments</div>
        <div class="admin-kpi-note">Excludes dropped / not-active history</div>
      </div>
    </section>

    <!-- Quick actions -->
    <section class="admin-quick-panel">
      <div class="admin-section-title"><i class="fa-solid fa-bolt"></i> Quick Actions</div>
      <div class="quick-actions">
        <a href="ManageStudents.aspx?action=add" class="quick-btn">
          <i class="fa-solid fa-user-plus"></i> Add Student
        </a>
        <a href="ManageLecturers.aspx?action=add" class="quick-btn">
          <i class="fa-solid fa-user-tie"></i> Add Lecturer
        </a>
        <a href="ManageCourses.aspx?action=add" class="quick-btn">
          <i class="fa-solid fa-book-medical"></i> Add Course
        </a>
        <a href="Admin_Announcement.aspx?action=add" class="quick-btn">
          <i class="fa-solid fa-bullhorn"></i> Post Announcement
        </a>
        <a href="Admin_enrolment.aspx" class="quick-btn">
          <i class="fa-solid fa-clipboard-list"></i> Enrollment
        </a>
        <a href="ManageFees.aspx" class="quick-btn">
          <i class="fa-solid fa-receipt"></i> Manage Fees
        </a>
      </div>
    </section>

    <!-- Main data row -->
    <section class="admin-card-grid">
      <div class="card">
        <div class="card-header">
          <span class="card-title"><i class="fa-solid fa-user-clock"></i> Recently Enrolled Students</span>
          <a href="ManageStudents.aspx" class="btn btn-outline btn-sm">View All</a>
        </div>
        <div class="card-body" style="padding:0;">
          <div class="table-wrapper">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Student ID</th>
                  <th>Name</th>
                  <th>Programme</th>
                  <th>Enrolled</th>
                </tr>
              </thead>
              <tbody>
                <asp:Repeater ID="rptRecentStudents" runat="server">
                  <ItemTemplate>
                    <tr>
                      <td><code><%# Eval("StudentId") %></code></td>
                      <td><%# Eval("FullName") %></td>
                      <td><span class="badge badge-orange"><%# Eval("ProgrammeCode") %></span></td>
                      <td class="text-muted"><%# Eval("EnrollmentDate", "{0:dd MMM yyyy}") %></td>
                    </tr>
                  </ItemTemplate>
                  <FooterTemplate>
                    <%# rptRecentStudents.Items.Count == 0
                        ? "<tr><td colspan='4' style='text-align:center;color:var(--text-muted);padding:24px;'>No students enrolled yet.</td></tr>"
                        : "" %>
                  </FooterTemplate>
                </asp:Repeater>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title"><i class="fa-solid fa-circle-nodes"></i> Payment Status Overview</span>
          <a href="ManageFees.aspx" class="btn btn-outline btn-sm">Details</a>
        </div>
        <div class="card-body">
          <div class="admin-kpi-grid" style="grid-template-columns:repeat(2,minmax(0,1fr));gap:14px;margin-bottom:18px;">
            <div class="admin-kpi-card" style="min-height:105px;padding:16px;box-shadow:none;">
              <div class="admin-kpi-icon green" style="width:38px;height:38px;font-size:16px;"><i class="fa-solid fa-circle-check"></i></div>
              <div class="admin-kpi-value" style="font-size:24px;margin-top:12px;"><asp:Label ID="lblPaidFees" runat="server" Text="0" /></div>
              <div class="admin-kpi-label">Paid</div>
            </div>

            <div class="admin-kpi-card" style="min-height:105px;padding:16px;box-shadow:none;">
              <div class="admin-kpi-icon red" style="width:38px;height:38px;font-size:16px;"><i class="fa-solid fa-clock"></i></div>
              <div class="admin-kpi-value" style="font-size:24px;margin-top:12px;"><asp:Label ID="lblOverdueFees" runat="server" Text="0" /></div>
              <div class="admin-kpi-label">Overdue</div>
            </div>
          </div>

          <div class="fee-status-dashboard" aria-label="Payment status chart">
            <div class="fee-status-row">
              <span>Paid</span>
              <div class="fee-status-track"><div id="feePaidBar" class="fee-status-fill paid"></div></div>
              <strong id="feePaidValue">0</strong>
            </div>
            <div class="fee-status-row">
              <span>Pending</span>
              <div class="fee-status-track"><div id="feePendingBar" class="fee-status-fill pending"></div></div>
              <strong id="feePendingValue">0</strong>
            </div>
            <div class="fee-status-row">
              <span>Overdue</span>
              <div class="fee-status-track"><div id="feeOverdueBar" class="fee-status-fill overdue"></div></div>
              <strong id="feeOverdueValue">0</strong>
            </div>
          </div>
</div>
      </div>
    </section>

    <!-- Second data row -->
    <section class="admin-card-grid equal">
      <div class="card">
        <div class="card-header">
          <span class="card-title"><i class="fa-solid fa-book-open-reader"></i> Active Course Enrolments — April 2026</span>
          <a href="ManageCourses.aspx" class="btn btn-outline btn-sm">Manage</a>
        </div>
        <div class="card-body" style="padding:0;">
          <div class="table-wrapper">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Code</th>
                  <th>Course Name</th>
                  <th>Credits</th>
                  <th>Active Students</th>
                </tr>
              </thead>
              <tbody>
                <asp:Repeater ID="rptCourses" runat="server">
                  <ItemTemplate>
                    <tr>
                      <td><code><%# Eval("CourseCode") %></code></td>
                      <td><%# Eval("CourseName") %></td>
                      <td><%# Eval("Credits") %></td>
                      <td><span class="badge badge-info"><%# Eval("EnrolledCount") %></span></td>
                    </tr>
                  </ItemTemplate>
                  <FooterTemplate>
                    <%# rptCourses.Items.Count == 0
                        ? "<tr><td colspan='4' style='text-align:center;color:var(--text-muted);padding:24px;'>No courses found.</td></tr>"
                        : "" %>
                  </FooterTemplate>
                </asp:Repeater>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title"><i class="fa-solid fa-bullhorn"></i> Recent Announcements</span>
          <a href="Admin_Announcement.aspx" class="btn btn-outline btn-sm">View All</a>
        </div>
        <div class="card-body">
          <ul class="activity-list">
            <asp:Repeater ID="rptAnnouncements" runat="server">
              <ItemTemplate>
                <li class="activity-item">
                  <span class="activity-dot"></span>
                  <div>
                    <div class="activity-text"><strong><%# Eval("Title") %></strong></div>
                    <span class="activity-time">
                      <i class="fa-regular fa-clock"></i>
                      <%# Eval("CreatedAt", "{0:dd MMM yyyy HH:mm}") %>
                      &nbsp;·&nbsp; Target: <%# Eval("TargetRole") %>
                    </span>
                  </div>
                </li>
              </ItemTemplate>
              <FooterTemplate>
                <%# rptAnnouncements.Items.Count == 0
                    ? "<li style='color:var(--text-muted);font-size:13px;padding:12px 0;'>No announcements yet.</li>"
                    : "" %>
              </FooterTemplate>
            </asp:Repeater>
          </ul>
        </div>
      </div>
    </section>

  </div><!-- /page-content -->
</div><!-- /main-wrapper -->

<script>
    function renderDashboardFeeChart(data) {
        if (!data) return;

        var paid = Number(data.paid || 0);
        var pending = Number(data.pending || 0);
        var overdue = Number(data.overdue || 0);
        var max = Math.max(paid, pending, overdue, 1);

        var items = [
            { bar: 'feePaidBar', value: 'feePaidValue', count: paid },
            { bar: 'feePendingBar', value: 'feePendingValue', count: pending },
            { bar: 'feeOverdueBar', value: 'feeOverdueValue', count: overdue }
        ];

        items.forEach(function (item) {
            var bar = document.getElementById(item.bar);
            var value = document.getElementById(item.value);
            var width = item.count <= 0 ? 0 : Math.max(6, Math.round((item.count / max) * 100));

            if (bar) bar.style.width = width + '%';
            if (value) value.textContent = item.count;
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        if (window.dashboardFeeData) {
            renderDashboardFeeChart(window.dashboardFeeData);
        }
    });
</script>
<script>
    // Sidebar toggle for mobile
    function toggleSidebar() {
        document.getElementById('sidebar').classList.toggle('open');
    }
</script>

<!-- Logout Confirmation Modal -->
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
      <asp:LinkButton ID="btnConfirmLogout" runat="server"
          CssClass="logout-btn logout-btn-confirm"
          OnClick="lbLogout_Click">
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

    </form>
</body>
</html>
