<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Lecturer_Dashboard.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer_Dashboard" %>
<%@ Register Src="~/Lecturer/LecturerSidebar.ascx" TagPrefix="uc" TagName="LecturerSidebar" %>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SIMS – Lecturer Dashboard | ONTI International University</title>
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
      background : var(--orange-gradient);
      color      : var(--white);
      border-color: transparent;
      box-shadow : var(--shadow-orange);
      transform  : translateY(-2px);
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

    /* Mini bar chart */
    .mini-chart {
      display    : flex;
      align-items: flex-end;
      gap        : 6px;
      height     : 60px;
    }
    .mini-bar {
      flex          : 1;
      border-radius : 4px 4px 0 0;
      background    : var(--orange-gradient);
      opacity       : 0.8;
      transition    : opacity 0.2s;
    }
    .mini-bar:hover { opacity: 1; }

    /* Sidebar user footer adjustments */
    .sidebar-user {
      margin-bottom: 18px;
      align-items  : flex-start;
    }
    .user-info  { padding-top: 4px; }
    .user-name  { margin-bottom: 4px; }
    .user-role  { margin-top: 2px; }

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


    /* At-risk badge */
    .badge-warning {
      background : #fff3cd;
      color      : #856404;
      padding    : 2px 8px;
      border-radius: 20px;
      font-size  : 11px;
      font-weight: 700;
    }
    .badge-danger {
      background : #f8d7da;
      color      : #842029;
      padding    : 2px 8px;
      border-radius: 20px;
      font-size  : 11px;
      font-weight: 700;
    }
    .badge-success {
      background : #d1e7dd;
      color      : #0f5132;
      padding    : 2px 8px;
      border-radius: 20px;
      font-size  : 11px;
      font-weight: 700;
    }

    /* Attendance progress bar */
    .attendance-bar-wrap {
      display        : flex;
      align-items    : center;
      gap            : 8px;
    }
    .attendance-bar-bg {
      flex           : 1;
      height         : 8px;
      background     : var(--border-light);
      border-radius  : 99px;
      overflow       : hidden;
    }
    .attendance-bar-fill {
      height         : 100%;
      border-radius  : 99px;
      background     : var(--orange-gradient);
    }
    .attendance-bar-fill.low   { background: linear-gradient(90deg,#f87171,#ef4444); }
    .attendance-bar-fill.mid   { background: linear-gradient(90deg,#fbbf24,#f59e0b); }
    .attendance-pct {
      font-size      : 12px;
      font-weight    : 700;
      color          : var(--text-secondary);
      min-width      : 34px;
      text-align     : right;
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

/* Lecturer dashboard student-style design */
.dashboard-hero {
    background: linear-gradient(135deg, #fff7ed 0%, #ffffff 55%, #fff3d6 100%);
    border: 1px solid #f2e2c5;
    border-radius: 24px;
    box-shadow: 0 16px 38px rgba(15,23,42,.08);
    padding: 24px;
    margin-bottom: 26px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 22px;
}

.hero-left {
    display: flex;
    align-items: center;
    gap: 16px;
    min-width: 0;
}

.hero-avatar {
    width: 70px;
    height: 70px;
    border-radius: 22px;
    background: var(--orange-gradient);
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
    font-weight: 900;
    box-shadow: var(--shadow-orange);
    flex-shrink: 0;
}

.hero-kicker {
    font-size: 12px;
    font-weight: 900;
    letter-spacing: .08em;
    text-transform: uppercase;
    color: var(--orange-dark);
}

.hero-name {
    font-family: var(--font-accent);
    font-size: 28px;
    line-height: 1.1;
    font-weight: 900;
    color: var(--text-primary);
    margin-top: 4px;
}

.hero-meta {
    margin-top: 8px;
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    color: var(--text-secondary);
    font-size: 13px;
    font-weight: 700;
}

.hero-pill {
    background: #fff;
    border: 1px solid #f2e2c5;
    border-radius: 999px;
    padding: 6px 12px;
}

.hero-actions {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    justify-content: flex-end;
}

.hero-action {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    text-decoration: none;
    padding: 11px 16px;
    border-radius: 999px;
    font-weight: 900;
    font-size: 13px;
    border: 1.5px solid #f2c46f;
    color: #9a5a00;
    background: #fff;
    transition: .18s ease;
}

.hero-action.primary {
    background: var(--orange-gradient);
    color: #fff;
    border-color: transparent;
    box-shadow: var(--shadow-orange);
}

.hero-action:hover {
    transform: translateY(-2px);
}

.stu-stats-grid {
    display: grid;
    grid-template-columns: repeat(4, minmax(170px, 1fr));
    gap: 18px;
    margin-bottom: 28px;
}

.stu-stat-card {
    border: 1px solid #edf0f6;
    background: linear-gradient(180deg, #fff 0%, #fffaf3 100%);
    border-radius: var(--radius-md);
    box-shadow: var(--shadow-card);
    min-height: 150px;
    padding: 24px 20px;
    position: relative;
    overflow: hidden;
    transition: var(--transition);
}

.stu-stat-card:hover {
    transform: translateY(-3px);
    box-shadow: var(--shadow-elevated);
}

.stu-stat-card:after {
    content: "";
    position: absolute;
    right: -28px;
    top: -28px;
    width: 92px;
    height: 92px;
    background: rgba(245,166,35,.10);
    border-radius: 50%;
}

.stu-stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 18px;
    background: var(--orange-gradient);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--white);
    font-size: 22px;
    margin-bottom: 12px;
}

.stu-stat-label {
    font-size: 13px;
    font-weight: 900;
    color: var(--text-secondary);
    text-transform: uppercase;
    letter-spacing: .5px;
}

.stu-stat-value {
    font-family: var(--font-accent);
    font-size: 28px;
    font-weight: 800;
    color: var(--orange-dark);
    line-height: 1;
    margin-top: 8px;
}

.stat-caption {
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 700;
    margin-top: 8px;
}

.quick-actions-card {
    background: var(--bg-card);
    border-radius: var(--radius-md);
    box-shadow: var(--shadow-card);
    border: 1px solid #edf0f6;
    padding: 22px;
    margin-bottom: 28px;
}

.section-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin-bottom: 16px;
}

.section-title {
    font-size: 16px;
    font-weight: 900;
    color: var(--text-primary);
    display: flex;
    align-items: center;
    gap: 9px;
}

.section-title i {
    color: var(--orange-main);
}

.quick-actions-grid {
    display: grid;
    grid-template-columns: repeat(4, minmax(160px, 1fr));
    gap: 14px;
}

.quick-action-tile {
    display: flex;
    align-items: center;
    gap: 12px;
    text-decoration: none;
    padding: 16px;
    border-radius: 18px;
    border: 1px solid #edf0f6;
    background: #fff;
    transition: .18s ease;
}

.quick-action-tile:hover {
    transform: translateY(-2px);
    box-shadow: 0 14px 30px rgba(15,23,42,.08);
    border-color: #f2c46f;
}

.quick-action-icon {
    width: 42px;
    height: 42px;
    border-radius: 15px;
    background: #fff3d6;
    color: #d97706;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
}

.quick-action-text strong {
    display: block;
    color: var(--text-primary);
    font-size: 14px;
    font-weight: 900;
}

.quick-action-text span {
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 700;
}

.lecturer-dashboard-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 28px;
}

.announcement-card {
    background: linear-gradient(135deg, #f59e0b, #f97316);
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
    background: rgba(255,255,255,.18);
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
    color: rgba(255,255,255,.75);
    margin-top: 3px;
}

.dashboard-section {
    margin-bottom: 28px;
}

@media (max-width: 1100px) {
    .lecturer-dashboard-grid {
        grid-template-columns: 1fr;
    }

    .quick-actions-grid {
        grid-template-columns: repeat(2, 1fr);
    }

    .stu-stats-grid {
        grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
    }
}

@media (max-width: 850px) {
    .dashboard-hero {
        align-items: flex-start;
        flex-direction: column;
    }

    .hero-actions {
        justify-content: flex-start;
    }

    .quick-actions-grid {
        grid-template-columns: 1fr;
    }
}
  </style>
</head>
<body>
  <form id="form1" runat="server">

<!-- ================================================================
     SIDEBAR
     ================================================================ -->
<uc:LecturerSidebar ID="LecturerSidebar1" runat="server" />
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
      <a href="Notifications.aspx" class="topbar-icon-btn" title="Notifications">
        <i class="fa-solid fa-bell"></i>
        <asp:Panel ID="pnlNotifBadge" runat="server" CssClass="badge-dot" Visible="false" />
      </a>
      <a href="Profile.aspx" class="topbar-icon-btn" title="My Profile">
        <i class="fa-solid fa-circle-user"></i>
      </a>
    </div>
  </div>

  <!-- Page content -->
  <div class="page-content">

    <div class="dashboard-hero">
        <div class="hero-left">
            <div class="hero-avatar">
                <i class="fa-solid fa-chalkboard-user"></i>
            </div>
            <div>
                <div class="hero-kicker">Lecturer Academic Portal</div>
                <div class="hero-name">
                    Welcome back, <asp:Label ID="lblWelcomeName" runat="server" Text="Lecturer" />
                </div>
                <div class="hero-meta">
                    <span class="hero-pill"><i class="fa-solid fa-calendar-days"></i> April 2026 Session</span>
                    <span class="hero-pill"><i class="fa-solid fa-user-tie"></i> Lecturer Workspace</span>
                </div>
            </div>
        </div>

        <div class="hero-actions">
           <a href="AttendanceReport.aspx" class="hero-action primary">
                <i class="fa-solid fa-chart-column"></i> View Attendance Report
            </a>
            <a href="Announcements.aspx?action=add" class="hero-action">
                <i class="fa-solid fa-bullhorn"></i> Post Announcement
            </a>
        </div>
    </div>

    <div class="stu-stats-grid">

        <div class="stu-stat-card">
            <div class="stu-stat-icon"><i class="fa-solid fa-book-open"></i></div>
            <div class="stu-stat-label">Assigned Courses</div>
            <div class="stu-stat-value">
                <asp:Label ID="lblTotalCourses" runat="server" Text="0" />
            </div>
            <div class="stat-caption">Courses handled this session</div>
        </div>

        <div class="stu-stat-card">
            <div class="stu-stat-icon"><i class="fa-solid fa-user-graduate"></i></div>
            <div class="stu-stat-label">Total Students</div>
            <div class="stu-stat-value">
                <asp:Label ID="lblTotalStudents" runat="server" Text="0" />
            </div>
            <div class="stat-caption">Across assigned courses</div>
        </div>

        <div class="stu-stat-card">
            <div class="stu-stat-icon"><i class="fa-solid fa-calendar-check"></i></div>
            <div class="stu-stat-label">Average Attendance</div>
            <div class="stu-stat-value">
                <asp:Label ID="lblAvgAttendance" runat="server" Text="0%" />
            </div>
            <div class="stat-caption">Latest attendance records</div>
        </div>

        <div class="stu-stat-card">
            <div class="stu-stat-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
            <div class="stu-stat-label">At-Risk Students</div>
            <div class="stu-stat-value">
                <asp:Label ID="lblAtRiskCount" runat="server" Text="0" />
            </div>
            <div class="stat-caption">Below attendance threshold</div>
        </div>

    </div>

    <div class="quick-actions-card">
        <div class="section-head">
            <div class="section-title"><i class="fa-solid fa-bolt"></i> Quick Actions</div>
        </div>

        <div class="quick-actions-grid">
            <a href="AttendanceReport.aspx" class="quick-action-tile">
                <div class="quick-action-icon"><i class="fa-solid fa-chart-column"></i></div>
                <div class="quick-action-text"><strong>Attendance Report</strong><span>View attendance report</span></div>
            </a>

            <a href="CourseReport.aspx" class="quick-action-tile">
                <div class="quick-action-icon"><i class="fa-solid fa-chart-column"></i></div>
                <div class="quick-action-text"><strong>Course Report</strong><span>View course report</span></div>
            </a>

            <a href="Announcements.aspx?action=add" class="quick-action-tile">
                <div class="quick-action-icon"><i class="fa-solid fa-bullhorn"></i></div>
                <div class="quick-action-text"><strong>Announcement</strong><span>Post course updates</span></div>
            </a>

            <a href="AtRiskStudents.aspx" class="quick-action-tile">
                <div class="quick-action-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                <div class="quick-action-text"><strong>At-Risk</strong><span>Review student alerts</span></div>
            </a>
        </div>
    </div>

    <div class="lecturer-dashboard-grid">

        <div class="card">
            <div class="card-header">
                <span class="card-title">My Courses - April 2026</span>
                <a href="MyCourses.aspx" class="btn btn-outline btn-sm">View All</a>
            </div>

            <div class="card-body" style="padding:0;">
                <div class="table-wrapper">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Course Name</th>
                                <th>Credits</th>
                                <th>Students</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptMyCourses" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><code><%# Eval("CourseCode") %></code></td>
                                        <td><%# Eval("CourseName") %></td>
                                        <td><%# Eval("Credits") %></td>
                                        <td><span class="badge badge-info"><%# Eval("EnrolledCount") %></span></td>
                                    </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                    <%# rptMyCourses.Items.Count == 0
                                        ? "<tr><td colspan='4' style='text-align:center;color:var(--text-muted);padding:24px;'>No courses assigned for this session.</td></tr>"
                                        : "" %>
                                </FooterTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

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
                            &nbsp; Target: <%# Eval("TargetRole") %>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <%# rptAnnouncements.Items.Count == 0
                        ? "<div class='ann-item'><div class='ann-item-title'>No announcements yet.</div></div>"
                        : "" %>
                </FooterTemplate>
            </asp:Repeater>
        </div>

    </div>

    <div class="dashboard-section">
        <div class="card">
            <div class="card-header">
                <span class="card-title">Attendance Summary</span>
                <a href="Attendance.aspx" class="btn btn-outline btn-sm">Details</a>
            </div>

            <div class="card-body" style="padding:0;">
                <div class="table-wrapper">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Course</th>
                                <th>Classes</th>
                                <th>Attendance Rate</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptAttendanceSummary" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><code><%# Eval("CourseCode") %></code></td>
                                        <td><%# Eval("TotalClasses") %></td>
                                        <td>
                                            <div class="attendance-bar-wrap">
                                                <div class="attendance-bar-bg">
                                                    <div class="attendance-bar-fill <%# Convert.ToDouble(Eval("AttendancePct")) < 60 ? "low" : Convert.ToDouble(Eval("AttendancePct")) < 80 ? "mid" : "" %>"
                                                        style="width:<%# Eval("AttendancePct") %>%;">
                                                    </div>
                                                </div>
                                                <span class="attendance-pct"><%# Eval("AttendancePct") %>%</span>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                    <%# rptAttendanceSummary.Items.Count == 0
                                        ? "<tr><td colspan='3' style='text-align:center;color:var(--text-muted);padding:24px;'>No attendance records yet.</td></tr>"
                                        : "" %>
                                </FooterTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

   <div class="dashboard-section">
        <div class="card">
            <div class="card-header">
                <span class="card-title">At-Risk Students</span>
                <a href="AtRiskStudents.aspx" class="btn btn-outline btn-sm">View All</a>
            </div>

            <div class="card-body" style="padding:0;">
                <div class="table-wrapper">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Student</th>
                                <th>Course</th>
                                <th>Attendance</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptAtRiskStudents" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("FullName") %></td>
                                        <td><code><%# Eval("CourseCode") %></code></td>
                                        <td><%# Eval("AttendancePct") %>%</td>
                                        <td>
                                            <span class='<%# Convert.ToDouble(Eval("AttendancePct")) < 60 ? "badge-danger" : "badge-warning" %>'>
                                                <%# Convert.ToDouble(Eval("AttendancePct")) < 60 ? "Critical" : "Warning" %>
                                            </span>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                    <%# rptAtRiskStudents.Items.Count == 0
                                        ? "<tr><td colspan='4' style='text-align:center;color:var(--text-muted);padding:24px;'>No at-risk students.</td></tr>"
                                        : "" %>
                                </FooterTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>

   </div><!-- /page-content -->
</div><!-- /main-wrapper -->

<script>
  function toggleSidebar() {
    document.getElementById('sidebar').classList.toggle('open');
  }
</script>

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
