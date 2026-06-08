<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Student_Dashboard.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student_Dashboard" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SIMS – Student Dashboard | ONTI International University</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
  <link rel="stylesheet" href="../Styles/SIMS.css" />
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

  <style>
    /* ── Student stat cards ──────────────────────────────── */
    .stu-stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 20px;
      margin-bottom: 28px;
    }

    .stu-stat-card {
      background: var(--bg-card);
      border-radius: var(--radius-md);
      padding: 24px 20px;
      box-shadow: var(--shadow-card);
      display: flex;
      flex-direction: column;
      gap: 8px;
      transition: var(--transition);
    }
    .stu-stat-card:hover {
      transform: translateY(-3px);
      box-shadow: var(--shadow-elevated);
    }
    .notif-link{
    position:relative;
    }

    .notif-link{
    position:relative;
    }

    .notif-dot{
        position:absolute;

        top:-2px;
        right:-2px;

        width:10px;
        height:10px;

        background:#ef4444;
        border:2px solid #ffffff;
        border-radius:50%;

        z-index:999;
    }
    .notif-wrap{position:relative;display:inline-block;}

    .stu-stat-icon {
      width: 48px; height: 48px;
      border-radius: var(--radius-sm);
      background: var(--orange-gradient);
      display: flex; align-items: center; justify-content: center;
      color: var(--white);
      font-size: 22px;
      margin-bottom: 4px;
    }
    .stu-stat-label {
      font-size: 13px;
      font-weight: 600;
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .stu-stat-value {
      font-family: var(--font-accent);
      font-size: 28px;
      font-weight: 800;
      color: var(--orange-dark);
      line-height: 1;
    }
    .stu-stat-value.neutral {
      color: var(--text-primary);
    }

    /* ── Enrolled courses badge list ─────────────────────── */
    .course-badge-list {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      margin-top: 4px;
    }
    .course-badge {
      background: var(--orange-gradient);
      color: var(--white);
      font-size: 11px;
      font-weight: 700;
      padding: 3px 10px;
      border-radius: var(--radius-pill);
      letter-spacing: 0.3px;
    }

    /* ── Charts row ──────────────────────────────────────── */
    .charts-row {
      display: grid;
      grid-template-columns: 1fr 1fr 340px;
      gap: 20px;
      margin-bottom: 28px;
    }
    @media (max-width: 1100px) {
      .charts-row { grid-template-columns: 1fr 1fr; }
      .announcement-card { grid-column: span 2; }
    }
    @media (max-width: 700px) {
      .charts-row { grid-template-columns: 1fr; }
      .announcement-card { grid-column: span 1; }
    }

    .chart-card {
      background: var(--bg-card);
      border-radius: var(--radius-md);
      padding: 20px;
      box-shadow: var(--shadow-card);
    }
    .chart-card-title {
      font-size: 14px;
      font-weight: 800;
      color: var(--text-primary);
      margin-bottom: 16px;
    }
    .chart-canvas-wrap {
      position: relative;
      height: 200px;
    }

    /* ── Announcement card ───────────────────────────────── */
    .announcement-card {
      background: var(--orange-gradient);
      border-radius: var(--radius-md);
      padding: 20px;
      box-shadow: var(--shadow-orange);
      color: var(--white);
      display: flex;
      flex-direction: column;
      gap: 12px;
      min-height: 260px;
    }
    .announcement-card .card-title-white {
      font-size: 15px;
      font-weight: 800;
      color: var(--white);
    }
    .ann-item {
      background: rgba(255,255,255,0.18);
      border-radius: var(--radius-sm);
      padding: 10px 14px;
    }
    .ann-item-title {
      font-size: 13px;
      font-weight: 700;
      color: var(--white);
    }
    .ann-item-date {
      font-size: 11px;
      color: rgba(255,255,255,0.75);
      margin-top: 3px;
    }
    .ann-empty {
      font-size: 13px;
      color: rgba(255,255,255,0.7);
      text-align: center;
      margin: auto 0;
    }

    /* ── Enrollment section ──────────────────────────────── */
    .enrollment-card {
      background: var(--bg-card);
      border-radius: var(--radius-md);
      box-shadow: var(--shadow-card);
      margin-bottom: 28px;
      overflow: hidden;
    }
    .enrollment-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 18px 24px;
      border-bottom: 1px solid var(--border-light);
    }
    .enrollment-title {
      font-size: 15px;
      font-weight: 800;
      color: var(--text-primary);
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .enrollment-title i { color: var(--orange-main); }
    .session-badge {
      background: var(--orange-gradient);
      color: var(--white);
      font-size: 12px;
      font-weight: 700;
      padding: 4px 14px;
      border-radius: var(--radius-pill);
    }
    .enroll-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 13px;
    }
    .enroll-table thead tr {
      background: var(--orange-gradient);
      color: var(--white);
    }
    .enroll-table thead th {
      padding: 11px 16px;
      font-weight: 700;
      text-align: left;
      white-space: nowrap;
    }
    .enroll-table tbody tr {
      border-bottom: 1px solid var(--border-light);
      transition: background 0.15s;
    }
    .enroll-table tbody tr:last-child { border-bottom: none; }
    .enroll-table tbody tr:hover { background: var(--off-white); }
    .enroll-table td {
      padding: 11px 16px;
      color: var(--text-primary);
      vertical-align: middle;
    }
    .enroll-table td.code { font-weight: 700; color: var(--orange-dark); }
    .enroll-empty {
      text-align: center;
      color: var(--text-muted);
      padding: 28px;
      font-size: 13px;
    }
    .enroll-add-row td {
      background: var(--off-white);
      padding: 10px 16px;
    }
    .enroll-add-row .add-row-inner {
      display: flex;
      align-items: center;
      gap: 10px;
      flex-wrap: wrap;
    }
    .enroll-select {
      flex: 1;
      min-width: 200px;
      padding: 8px 12px;
      border: 1.5px solid var(--border-mid);
      border-radius: var(--radius-sm);
      font-family: var(--font-primary);
      font-size: 13px;
      color: var(--text-primary);
      background: var(--white);
      outline: none;
      transition: border-color 0.2s;
    }
    .enroll-select:focus { border-color: var(--orange-main); }
    .btn-enroll-add {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 8px 18px;
      background: var(--orange-gradient);
      color: var(--white);
      border: none;
      border-radius: var(--radius-pill);
      font-family: var(--font-primary);
      font-size: 13px;
      font-weight: 700;
      cursor: pointer;
      transition: var(--transition);
    }
    .btn-enroll-add:hover {
      box-shadow: var(--shadow-orange);
      transform: translateY(-1px);
    }
    .btn-drop {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      padding: 5px 12px;
      background: transparent;
      color: var(--danger);
      border: 1.5px solid var(--danger);
      border-radius: var(--radius-pill);
      font-family: var(--font-primary);
      font-size: 12px;
      font-weight: 700;
      cursor: pointer;
      transition: var(--transition);
    }
    .btn-drop:hover { background: var(--danger); color: var(--white); }
    .enroll-alert {
      margin: 0 24px 14px;
      padding: 10px 16px;
      border-radius: var(--radius-sm);
      font-size: 13px;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .enroll-alert.success {
      background: rgba(46,204,113,0.12);
      color: #1a7a40;
      border: 1px solid rgba(46,204,113,0.35);
    }
    .enroll-alert.error {
      background: rgba(231,76,60,0.10);
      color: #b03a2e;
      border: 1px solid rgba(231,76,60,0.30);
    }

    /* ── Student profile topbar card ─────────────────────── */
    .student-profile-topbar {
      display: flex;
      align-items: center;
      gap: 12px;
      background: var(--bg-card);
      border-radius: var(--radius-md);
      padding: 12px 18px;
      box-shadow: var(--shadow-card);
      margin-bottom: 24px;
    }
    .stu-avatar {
      width: 52px; height: 52px;
      border-radius: 50%;
      background: var(--orange-gradient);
      display: flex; align-items: center; justify-content: center;
      color: var(--white);
      font-size: 20px;
      font-weight: 800;
      flex-shrink: 0;
    }
    .stu-profile-info { flex: 1; }
    .stu-profile-name {
      font-size: 16px;
      font-weight: 800;
      color: var(--text-primary);
    }
    .stu-profile-id {
      font-size: 12px;
      color: var(--orange-dark);
      font-weight: 700;
    }
    .stu-profile-prog {
      font-size: 11px;
      color: var(--text-muted);
      margin-top: 2px;
    }
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

    /* ===== Standard Student logout dialog - same layout as Enrollment/Payment ===== */
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
    .logout-warning-icon {
      width: 68px;
      height: 68px;
      border-radius: 50%;
      background: #fff8e1;
      color: #e8a838;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 34px;
      font-weight: 900;
      margin: 0 auto 2px;
      line-height: 1;
      font-family: Arial, sans-serif;
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
    .dashboard-hidden-badge { display: none !important; visibility: hidden !important; }

  

    /* ===== FINAL STANDARD LOGOUT TRIANGLE ICON - DO NOT DUPLICATE ===== */
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



    /* ===== Professional dashboard upgrade ===== */
    .dashboard-hero {
      background: linear-gradient(135deg, #fff7ed 0%, #ffffff 58%, #fff3d6 100%);
      border: 1px solid rgba(245,166,35,.20);
      border-radius: 24px;
      box-shadow: 0 16px 38px rgba(15,23,42,.08);
      padding: 24px;
      margin-bottom: 26px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 22px;
    }
    .hero-left { display:flex; align-items:center; gap:16px; min-width:0; }
    .hero-avatar {
      width:70px; height:70px; border-radius:22px;
      background:var(--orange-gradient);
      color:#fff; display:flex; align-items:center; justify-content:center;
      font-size:28px; font-weight:900; box-shadow:var(--shadow-orange);
      flex-shrink:0;
    }
    .hero-kicker { font-size:12px; font-weight:900; letter-spacing:.08em; text-transform:uppercase; color:var(--orange-dark); }
    .hero-name { font-family:var(--font-accent); font-size:28px; line-height:1.1; font-weight:900; color:var(--text-primary); margin-top:4px; }
    .hero-meta { margin-top:8px; display:flex; gap:10px; flex-wrap:wrap; color:var(--text-secondary); font-size:13px; font-weight:700; }
    .hero-pill { background:#fff; border:1px solid #f2e2c5; border-radius:999px; padding:6px 12px; }
    .hero-actions { display:flex; gap:10px; flex-wrap:wrap; justify-content:flex-end; }
    .hero-action {
      display:inline-flex; align-items:center; gap:8px; text-decoration:none;
      padding:11px 16px; border-radius:999px; font-weight:900; font-size:13px;
      border:1.5px solid #f2c46f; color:#9a5a00; background:#fff;
      transition:.18s ease;
    }
    .hero-action.primary { background:var(--orange-gradient); color:#fff; border-color:transparent; box-shadow:var(--shadow-orange); }
    .hero-action:hover { transform:translateY(-2px); }

    .student-profile-topbar { display:none; }
    .stu-stats-grid { grid-template-columns: repeat(5, minmax(170px, 1fr)); gap:18px; }
    @media (max-width: 1250px){ .stu-stats-grid { grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); } }
    .stu-stat-card {
      border:1px solid #edf0f6;
      background:linear-gradient(180deg,#fff 0%,#fffaf3 100%);
      min-height:150px;
      position:relative;
      overflow:hidden;
    }
    .stu-stat-card:after {
      content:""; position:absolute; right:-28px; top:-28px; width:92px; height:92px;
      background:rgba(245,166,35,.10); border-radius:50%;
    }
    .stu-stat-icon { border-radius:18px; }
    .stu-stat-label { font-weight:900; }
    .stat-caption { color:var(--text-muted); font-size:12px; font-weight:700; margin-top:2px; }
    .quick-actions-card {
      background:var(--bg-card); border-radius:var(--radius-md); box-shadow:var(--shadow-card);
      border:1px solid #edf0f6; padding:22px; margin-bottom:28px;
    }
    .section-head { display:flex; justify-content:space-between; align-items:center; gap:12px; margin-bottom:16px; }
    .section-title { font-size:16px; font-weight:900; color:var(--text-primary); display:flex; align-items:center; gap:9px; }
    .section-title i { color:var(--orange-main); }
    .quick-actions-grid { display:grid; grid-template-columns:repeat(4,minmax(160px,1fr)); gap:14px; }
    @media (max-width: 850px){ .quick-actions-grid { grid-template-columns:repeat(2,1fr); } .dashboard-hero{align-items:flex-start;flex-direction:column;} .hero-actions{justify-content:flex-start;} }
    .quick-action-tile {
      display:flex; align-items:center; gap:12px; text-decoration:none; padding:16px;
      border-radius:18px; border:1px solid #edf0f6; background:#fff; transition:.18s ease;
    }
    .quick-action-tile:hover { transform:translateY(-2px); box-shadow:0 14px 30px rgba(15,23,42,.08); border-color:#f2c46f; }
    .quick-action-icon { width:42px; height:42px; border-radius:15px; background:#fff3d6; color:#d97706; display:flex; align-items:center; justify-content:center; font-size:18px; }
    .quick-action-text strong { display:block; color:var(--text-primary); font-size:14px; font-weight:900; }
    .quick-action-text span { color:var(--text-muted); font-size:12px; font-weight:700; }
    .charts-row { grid-template-columns: 1fr 1fr 360px; }
    .chart-card { border:1px solid #edf0f6; }
    .announcement-card { background:linear-gradient(135deg,#f59e0b,#f97316); }

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
      <div class="brand-sub">Student Portal</div>
    </div>
  </div>

  <!-- Navigation -->
  <nav class="sidebar-nav">
    <div class="sidebar-section-label">Main</div>

    <a href="Student_Dashboard.aspx" class="sidebar-link active">
      <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Academic</div>

    <a href="MyCourses.aspx" class="sidebar-link">
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
      <asp:Panel ID="pnlSidebarNotifBadge" runat="server" CssClass="badge-dot dashboard-hidden-badge" Visible="false" style="display:none !important;" />
    </a>
    <a href="Contacts.aspx" class="sidebar-link">
      <i class="fa-solid fa-address-book nav-icon"></i> Contacts
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Account</div>

    <a href="MyProfile.aspx" class="sidebar-link">
      <i class="fa-solid fa-circle-user nav-icon"></i> My Profile
    </a>
  </nav>

  <!-- Sidebar user footer -->
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
    <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link"
      OnClientClick="showLogoutModal(); return false;">
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
      <a href="Notification.aspx" class="topbar-icon-btn" title="Notifications">
        <span class="notif-wrap"><i class="fa-solid fa-bell"></i><asp:Panel ID="pnlNotifBadge" runat="server" CssClass="notif-dot" Visible="false" /></span>
        <asp:Panel ID="Panel1" runat="server" CssClass="badge-dot dashboard-hidden-badge" Visible="false" style="display:none !important;" />
      </a>
      <a href="MyProfile.aspx" class="topbar-icon-btn" title="My Profile">
        <i class="fa-solid fa-circle-user"></i>
      </a>
    </div>
  </div>

  <!-- Page content -->
  <div class="page-content">

    <!-- Professional student summary hero -->
    <div class="dashboard-hero">
      <div class="hero-left">
        <div class="hero-avatar">
          <asp:Label ID="lblTopbarInitial" runat="server" Text="S" />
        </div>
        <div>
          <div class="hero-kicker">Student Academic Portal</div>
          <div class="hero-name">
            Welcome back, <asp:Label ID="lblStudentName" runat="server" Text="Student" />
          </div>
          <div class="hero-meta">
            <span class="hero-pill"><i class="fa-solid fa-id-card"></i> <asp:Label ID="lblStudentId" runat="server" Text="" /></span>
            <span class="hero-pill"><i class="fa-solid fa-building-columns"></i> <asp:Label ID="lblProgramme" runat="server" Text="" /></span>
          </div>
        </div>
      </div>
      <div class="hero-actions">
        <a href="Student_Enrollment.aspx" class="hero-action primary"><i class="fa-solid fa-clipboard-list"></i> Enroll Course</a>
        <a href="Student_Payment.aspx" class="hero-action"><i class="fa-solid fa-credit-card"></i> Payment</a>
        <a href="Results.aspx" class="hero-action"><i class="fa-solid fa-chart-line"></i> Results</a>
      </div>
    </div>

    <!-- Professional KPI cards -->
    <div class="stu-stats-grid">

      <div class="stu-stat-card">
        <div class="stu-stat-icon"><i class="fa-solid fa-graduation-cap"></i></div>
        <div class="stu-stat-label">Current GPA</div>
        <div class="stu-stat-value"><asp:Label ID="lblGPA" runat="server" Text="N/A" /></div>
        <div class="stat-caption">Latest published semester result</div>
      </div>

      <div class="stu-stat-card">
        <div class="stu-stat-icon"><i class="fa-solid fa-ranking-star"></i></div>
        <div class="stu-stat-label">CGPA</div>
        <div class="stu-stat-value"><asp:Label ID="lblCGPA" runat="server" Text="N/A" /></div>
        <div class="stat-caption">Overall academic performance</div>
      </div>

      <div class="stu-stat-card">
        <div class="stu-stat-icon"><i class="fa-solid fa-calendar-check"></i></div>
        <div class="stu-stat-label">Attendance</div>
        <div class="stu-stat-value"><asp:Label ID="lblAttendance" runat="server" Text="0.00" />%</div>
        <div class="stat-caption">Across enrolled courses</div>
      </div>

      <div class="stu-stat-card">
        <div class="stu-stat-icon"><i class="fa-solid fa-book-open"></i></div>
        <div class="stu-stat-label">Enrolled Courses</div>
        <div class="course-badge-list">
          <asp:Repeater ID="rptEnrolledCourses" runat="server">
            <ItemTemplate><span class="course-badge"><%# Eval("CourseCode") %></span></ItemTemplate>
          </asp:Repeater>
          <asp:Label ID="lblNoCourses" runat="server" Text="None" Style="color:var(--text-muted);font-size:13px;" Visible="false" />
        </div>
      </div>

      <div class="stu-stat-card">
        <div class="stu-stat-icon"><i class="fa-solid fa-wallet"></i></div>
        <div class="stu-stat-label">Outstanding Fees</div>
        <div class="stu-stat-value neutral">RM <asp:Label ID="lblFees" runat="server" Text="00.00" /></div>
        <div class="stat-caption">Pending finance action</div>
      </div>

    </div>

    <!-- Quick action tiles -->
    <div class="quick-actions-card">
      <div class="section-head">
        <div class="section-title"><i class="fa-solid fa-bolt"></i> Quick Actions</div>
      </div>
      <div class="quick-actions-grid">
        <a href="Student_Enrollment.aspx" class="quick-action-tile">
          <div class="quick-action-icon"><i class="fa-solid fa-clipboard-list"></i></div>
          <div class="quick-action-text"><strong>Enrollment</strong><span>Register next session courses</span></div>
        </a>
        <a href="MyCourses.aspx" class="quick-action-tile">
          <div class="quick-action-icon"><i class="fa-solid fa-book-open"></i></div>
          <div class="quick-action-text"><strong>My Courses</strong><span>View course materials</span></div>
        </a>
        <a href="Results.aspx" class="quick-action-tile">
          <div class="quick-action-icon"><i class="fa-solid fa-square-poll-vertical"></i></div>
          <div class="quick-action-text"><strong>Results</strong><span>Check GPA and CGPA</span></div>
        </a>
        <a href="Student_Payment.aspx" class="quick-action-tile">
          <div class="quick-action-icon"><i class="fa-solid fa-credit-card"></i></div>
          <div class="quick-action-text"><strong>Payment</strong><span>Upload payment receipt</span></div>
        </a>
      </div>
    </div>

    <!-- Charts + Announcements row -->
    <div class="charts-row">

      <!-- Attendance Trend Chart -->
      <div class="chart-card">
        <div class="chart-card-title">
          <i class="fa-solid fa-chart-column" style="color:var(--orange-main);margin-right:6px;"></i>
          Attendance Trend Chart
        </div>
        <div class="chart-canvas-wrap">
          <canvas id="attendanceChart"></canvas>
        </div>
      </div>

      <!-- GPA Trend Chart -->
      <div class="chart-card">
        <div class="chart-card-title">
          <i class="fa-solid fa-chart-line" style="color:var(--orange-main);margin-right:6px;"></i>
          GPA Trend Chart
        </div>
        <div class="chart-canvas-wrap">
          <canvas id="gpaChart"></canvas>
        </div>
      </div>

      <!-- Announcement -->
      <div class="announcement-card">
        <div class="card-title-white">
          <i class="fa-solid fa-bullhorn" style="margin-right:6px;"></i> Announcements
        </div>
        <asp:Repeater ID="rptAnnouncements" runat="server">
          <ItemTemplate>
            <div class="ann-item">
              <div class="ann-item-title"><%# Eval("Title") %></div>
              <div class="ann-item-date">
                <i class="fa-regular fa-clock"></i>
                <%# Eval("CreatedAt", "{0:dd MMM yyyy}") %>
              </div>
            </div>
          </ItemTemplate>
        </asp:Repeater>
        <asp:Label ID="lblNoAnnouncements" runat="server"
          CssClass="ann-empty" Text="No announcements at this time." Visible="false" />
      </div>

    </div><!-- /charts-row -->

  </div><!-- /page-content -->
</div><!-- /main-wrapper -->

<!-- ── Hidden data fields for charts ──────────────────────────────── -->
<asp:HiddenField ID="hdnAttendanceLabels" runat="server" />
<asp:HiddenField ID="hdnAttendanceData"  runat="server" />
<asp:HiddenField ID="hdnGpaLabels"       runat="server" />
<asp:HiddenField ID="hdnGpaData"         runat="server" />

<!-- ================================================================
     LOGOUT MODAL
     ================================================================ -->
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
    /* ── Logout modal ─────────────────────────────────────── */
    function showLogoutModal() { document.getElementById('logoutModal').style.display = 'flex'; }
    function hideLogoutModal() { document.getElementById('logoutModal').style.display = 'none'; }

    /* ── Charts (run after DOM ready) ────────────────────── */
    document.addEventListener('DOMContentLoaded', function () {
        var attLabels = document.getElementById('<%= hdnAttendanceLabels.ClientID %>').value;
    var attData   = document.getElementById('<%= hdnAttendanceData.ClientID %>').value;
    var gpaLabels = document.getElementById('<%= hdnGpaLabels.ClientID %>').value;
    var gpaData   = document.getElementById('<%= hdnGpaData.ClientID %>').value;

        var aLabels = attLabels ? attLabels.split('|') : [];
        var aData = attData ? attData.split('|').map(Number) : [];
        var gLabels = gpaLabels ? gpaLabels.split('|') : [];
        var gData = gpaData ? gpaData.split('|').map(Number) : [];

        /* ── Attendance Chart ──────── */
        var attCtx = document.getElementById('attendanceChart').getContext('2d');
        new Chart(attCtx, {
            type: 'bar',
            data: {
                labels: aLabels,
                datasets: [{
                    label: 'Attendance %',
                    data: aData,
                    backgroundColor: 'rgba(245,166,35,0.75)',
                    borderColor: '#E8890A',
                    borderWidth: 2,
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100,
                        ticks: { callback: function (v) { return v + '%'; }, font: { size: 11 } },
                        grid: { color: 'rgba(0,0,0,0.05)' }
                    },
                    x: { ticks: { font: { size: 11 } }, grid: { display: false } }
                }
            }
        });

        /* ── GPA Chart ─────────────── */
        var gpaCtx = document.getElementById('gpaChart').getContext('2d');
        new Chart(gpaCtx, {
            type: 'line',
            data: {
                labels: gLabels,
                datasets: [{
                    label: 'GPA',
                    data: gData,
                    borderColor: '#F5A623',
                    backgroundColor: 'rgba(245,166,35,0.15)',
                    borderWidth: 2.5,
                    pointBackgroundColor: '#E8890A',
                    pointRadius: 5,
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: {
                        beginAtZero: false,
                        min: 0, max: 4,
                        ticks: { font: { size: 11 } },
                        grid: { color: 'rgba(0,0,0,0.05)' }
                    },
                    x: { ticks: { font: { size: 11 } }, grid: { display: false } }
                }
            }
        });
    });
</script>

  </form>
</body>
</html>
