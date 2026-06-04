<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Lecturer_Dashboard.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer_Dashboard" %>
<!DOCTYPE html>
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
      <div class="brand-sub">Lecturer Portal</div>
    </div>
  </div>

  <!-- Navigation -->
  <nav class="sidebar-nav">
    <div class="sidebar-section-label">Main</div>

    <a href="Lecturer_Dashboard.aspx" class="sidebar-link active">
      <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
    </a>
    <a href="MyCourses.aspx" class="sidebar-link">
      <i class="fa-solid fa-book-open nav-icon"></i> My Courses
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Academic</div>

    <a href="Attendance.aspx" class="sidebar-link">
      <i class="fa-solid fa-clipboard-check nav-icon"></i> Attendance
    </a>

    <a href="AtRiskStudents.aspx" class="sidebar-link">
      <i class="fa-solid fa-triangle-exclamation nav-icon"></i> At-Risk Students
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>

    <a href="Announcements.aspx" class="sidebar-link">
      <i class="fa-solid fa-bullhorn nav-icon"></i> Announcements
    </a>
    <a href="Notifications.aspx" class="sidebar-link">
      <i class="fa-solid fa-bell nav-icon"></i> Notifications
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Account</div>

    <a href="Profile.aspx" class="sidebar-link">
      <i class="fa-solid fa-circle-user nav-icon"></i> My Profile
    </a>
  </nav>

  <!-- Sidebar user footer -->
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
            <asp:Label ID="lblSidebarName"
                runat="server"
                Text="Lecturer" />
        </div>

        <div class="user-role">
            Lecturer
        </div>

    </div>

</div>
    <!-- Log Out -->
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

    <!-- Page header -->
    <div class="page-header">
      <h1>Welcome back, <asp:Label ID="lblWelcomeName" runat="server" Text="Lecturer" />! 👋</h1>
      <p>Here's your teaching overview for the <strong>April 2026</strong> session.</p>
    </div>

    <!-- Quick Actions -->
    <div class="quick-actions">
      <a href="Attendance.aspx?action=record" class="quick-btn">
        <i class="fa-solid fa-clipboard-check"></i> Record Attendance
      </a>
      <a href="Grades.aspx?action=enter" class="quick-btn">
        <i class="fa-solid fa-pen-to-square"></i> Enter Grades
      </a>
      <a href="Announcements.aspx?action=add" class="quick-btn">
        <i class="fa-solid fa-bullhorn"></i> Post Announcement
      </a>
      <a href="AtRiskStudents.aspx" class="quick-btn">
        <i class="fa-solid fa-triangle-exclamation"></i> At-Risk Students
      </a>
    </div>

    <!-- Stats row -->
    <div class="stats-grid">

      <div class="stat-card">
        <div class="stat-icon orange">
          <i class="fa-solid fa-book-open"></i>
        </div>
        <div>
          <div class="stat-value">
            <asp:Label ID="lblTotalCourses" runat="server" Text="0" />
          </div>
          <div class="stat-label">Assigned Courses</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon blue">
          <i class="fa-solid fa-user-graduate"></i>
        </div>
        <div>
          <div class="stat-value">
            <asp:Label ID="lblTotalStudents" runat="server" Text="0" />
          </div>
          <div class="stat-label">Total Students</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon green">
          <i class="fa-solid fa-clipboard-check"></i>
        </div>
        <div>
          <div class="stat-value">
            <asp:Label ID="lblAvgAttendance" runat="server" Text="0%" />
          </div>
          <div class="stat-label">Avg Attendance</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon red">
          <i class="fa-solid fa-triangle-exclamation"></i>
        </div>
        <div>
          <div class="stat-value">
            <asp:Label ID="lblAtRiskCount" runat="server" Text="0" />
          </div>
          <div class="stat-label">At-Risk Students</div>
        </div>
      </div>

    </div><!-- /stats-grid -->

    <!-- Second row: My Courses + Recent Announcements -->
    <div class="grid-2">

      <!-- My Courses this session -->
      <div class="card">
        <div class="card-header">
          <span class="card-title">My Courses — April 2026</span>
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
                      <td>
                        <span class="badge badge-info"><%# Eval("EnrolledCount") %></span>
                      </td>
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

      <!-- Recent Announcements -->
      <div class="card">
        <div class="card-header">
          <span class="card-title">Recent Announcements</span>
          <a href="Announcements.aspx" class="btn btn-outline btn-sm">View All</a>
        </div>
        <div class="card-body">
          <ul class="activity-list">
            <asp:Repeater ID="rptAnnouncements" runat="server">
              <ItemTemplate>
                <li class="activity-item">
                  <span class="activity-dot"></span>
                  <div>
                    <div class="activity-text">
                      <strong><%# Eval("Title") %></strong>
                    </div>
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

    </div><!-- /grid-2 -->

    <!-- Third row: Attendance Summary + At-Risk Students -->
    <div class="grid-2" style="margin-top:24px;">

      <!-- Attendance Summary per course -->
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

      <!-- At-Risk Students -->
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
                        ? "<tr><td colspan='4' style='text-align:center;color:var(--text-muted);padding:24px;'>No at-risk students. Great work! 🎉</td></tr>"
                        : "" %>
                  </FooterTemplate>
                </asp:Repeater>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    </div><!-- /grid-2 second row -->

    <!-- Fourth row: Recent Grades Entered -->
    <div style="margin-top:24px;">
      <div class="card">
        <div class="card-header">
          <span class="card-title">Recently Entered Grades</span>
          <a href="Grades.aspx" class="btn btn-outline btn-sm">Manage Grades</a>
        </div>
        <div class="card-body" style="padding:0;">
          <div class="table-wrapper">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Student</th>
                  <th>Course</th>
                  <th>Assessment</th>
                  <th>Marks</th>
                  <th>Grade</th>
                  <th>Submitted</th>
                </tr>
              </thead>
              <tbody>
                <asp:Repeater ID="rptRecentGrades" runat="server">
                  <ItemTemplate>
                    <tr>
                      <td><%# Eval("FullName") %></td>
                      <td><code><%# Eval("CourseCode") %></code></td>
                      <td>
                        <span class="badge badge-info"><%# Eval("Type") %></span>
                        <%# Eval("Title") %>
                      </td>
                      <td><%# Eval("MarksObtained") %> / <%# Eval("MaxMarks") %></td>
                      <td>
                        <span class='<%# Eval("Grade").ToString() == "A" || Eval("Grade").ToString() == "A+" ? "badge-success" : Eval("Grade").ToString() == "F" ? "badge-danger" : "badge-warning" %>'>
                          <%# Eval("Grade") %>
                        </span>
                      </td>
                      <td class="text-muted">
                        <%# Eval("SubmittedAt", "{0:dd MMM yyyy}") %>
                      </td>
                    </tr>
                  </ItemTemplate>
                  <FooterTemplate>
                    <%# rptRecentGrades.Items.Count == 0
                        ? "<tr><td colspan='6' style='text-align:center;color:var(--text-muted);padding:24px;'>No grades entered yet.</td></tr>"
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

<!-- Logout Confirmation Modal -->
<div id="logoutModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(26,26,46,0.85); z-index: 9999; align-items: center; justify-content: center;">
  <div style="background: white; border-radius: 12px; width: 100%; max-width: 380px; box-shadow: 0 15px 35px rgba(0,0,0,0.3); overflow: hidden;">
    <div style="padding: 25px 30px 10px; text-align: center; border-bottom: 1px solid #eee;">
      <h3>🔒 Log Out</h3>
    </div>
    <div style="padding: 25px 30px; text-align: center; color: #555;">
      <p>Are you sure you want to log out of the SIMS system?</p>
    </div>
    <div style="padding: 20px 30px 25px; display: flex; gap: 12px; justify-content: center; border-top: 1px solid #eee;">
      <button type="button" onclick="hideLogoutModal()" style="padding: 10px 24px;" class="btn btn-outline">Cancel</button>
      <asp:LinkButton ID="btnConfirmLogout" runat="server"
          CssClass="btn btn-danger"
          OnClick="lbLogout_Click">
          Yes, Log Out
      </asp:LinkButton>
    </div>
  </div>
</div>

<script>
    function showLogoutModal() {
        document.getElementById('logoutModal').style.display = 'flex';
    }
    function hideLogoutModal() {
        document.getElementById('logoutModal').style.display = 'none';
    }
</script>

  </form>
</body>
</html>
