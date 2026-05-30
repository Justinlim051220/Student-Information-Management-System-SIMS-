<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Admin_Dashboard" %>
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
    <div class="sidebar-section-label">Main</div>

    <a href="Dashboard.aspx" class="sidebar-link active">
      <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
    </a>
    <a href="ManageStudents.aspx" class="sidebar-link">
      <i class="fa-solid fa-user-graduate nav-icon"></i> Students
    </a>
    <a href="ManageLecturers.aspx" class="sidebar-link">
      <i class="fa-solid fa-chalkboard-teacher nav-icon"></i> Lecturers
    </a>
    <a href="ManageProgrammes.aspx" class="sidebar-link">
      <i class="fa-solid fa-layer-group nav-icon"></i> Programmes
    </a>
    <a href="ManageCourses.aspx" class="sidebar-link">
      <i class="fa-solid fa-book-open nav-icon"></i> Courses
    </a>
    <a href="AssignLecturerCourse.aspx" class="sidebar-link">
      <i class="fa-solid fa-user-check nav-icon"></i> Assign Course
    </a>
    <a href="Admin_enrolment.aspx" class="sidebar-link">
      <i class="fa-solid fa-clipboard-list nav-icon"></i> Enrollment
    </a>

    <a href="CourseOffering.aspx" class="sidebar-link">
      <i class="fa-solid fa-calendar-check"></i> Course Offering
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
      <a href="Admin_Announcement.aspx" class="topbar-icon-btn" title="Notifications">
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

    <!-- Page header with welcome message -->
    <div class="page-header">
      <h1>Welcome back, <asp:Label ID="lblWelcomeName" runat="server" Text="Admin" />! 👋</h1>
      <p>Here's an overview of the SIMS system for <strong>April 2026</strong> session.</p>
    </div>

    <!-- Quick Actions -->
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
      <a href="Announcements.aspx?action=add" class="quick-btn">
        <i class="fa-solid fa-bullhorn"></i> Post Announcement
      </a>
      <a href="ManageFees.aspx" class="quick-btn">
        <i class="fa-solid fa-receipt"></i> Manage Fees
      </a>
    </div>

    <!-- Stats row -->
    <div class="stats-grid">

      <div class="stat-card">
        <div class="stat-icon orange">
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
        <div class="stat-icon blue">
          <i class="fa-solid fa-chalkboard-teacher"></i>
        </div>
        <div>
          <div class="stat-value">
            <asp:Label ID="lblTotalLecturers" runat="server" Text="0" />
          </div>
          <div class="stat-label">Lecturers</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon green">
          <i class="fa-solid fa-layer-group"></i>
        </div>
        <div>
          <div class="stat-value">
            <asp:Label ID="lblTotalProgrammes" runat="server" Text="0" />
          </div>
          <div class="stat-label">Programmes</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon red">
          <i class="fa-solid fa-money-bill-wave"></i>
        </div>
        <div>
          <div class="stat-value">
            <asp:Label ID="lblPendingFees" runat="server" Text="0" />
          </div>
          <div class="stat-label">Pending Fee Records</div>
        </div>
      </div>

    </div><!-- /stats-grid -->

    <!-- Second row: Recent students + Activity -->
    <div class="grid-2">

      <!-- Recent Students -->
      <div class="card">
        <div class="card-header">
          <span class="card-title">Recently Enrolled Students</span>
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
                      <td>
                        <span class="badge badge-orange">
                          <%# Eval("ProgrammeCode") %>
                        </span>
                      </td>
                      <td class="text-muted">
                        <%# Eval("EnrollmentDate", "{0:dd MMM yyyy}") %>
                      </td>
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

      <!-- System Activity / Announcements -->
      <div class="card">
        <div class="card-header">
          <span class="card-title">Recent Announcements</span>
          <a href="Admin_Announcement.aspx" class="btn btn-outline btn-sm">View All</a>
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

    <!-- Third row: Courses this session + Fee summary -->
    <div class="grid-2" style="margin-top:24px;">

      <!-- Courses this session -->
      <div class="card">
        <div class="card-header">
          <span class="card-title">Courses — April 2026 Session</span>
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
                  <th>Enrolled</th>
                </tr>
              </thead>
              <tbody>
                <asp:Repeater ID="rptCourses" runat="server">
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

      <!-- Fee Overview -->
      <div class="card">
        <div class="card-header">
          <span class="card-title">Fee Collection Overview</span>
          <a href="ManageFees.aspx" class="btn btn-outline btn-sm">Details</a>
        </div>
        <div class="card-body">
          <div class="stats-grid" style="grid-template-columns:1fr 1fr;gap:16px;margin-bottom:0;">

            <div class="stat-card" style="flex-direction:column;align-items:flex-start;gap:6px;">
              <div class="stat-icon green" style="width:38px;height:38px;font-size:18px;">
                <i class="fa-solid fa-circle-check"></i>
              </div>
              <div class="stat-value" style="font-size:22px;">
                <asp:Label ID="lblPaidFees" runat="server" Text="0" />
              </div>
              <div class="stat-label">Paid</div>
            </div>

            <div class="stat-card" style="flex-direction:column;align-items:flex-start;gap:6px;">
              <div class="stat-icon red" style="width:38px;height:38px;font-size:18px;">
                <i class="fa-solid fa-clock"></i>
              </div>
              <div class="stat-value" style="font-size:22px;">
                <asp:Label ID="lblOverdueFees" runat="server" Text="0" />
              </div>
              <div class="stat-label">Overdue</div>
            </div>

          </div>

          <div style="margin-top:20px;">
            <div style="font-size:13px;font-weight:700;color:var(--text-secondary);margin-bottom:8px;">
              Collection by month (mock chart)
            </div>
            <div class="mini-chart">
              <div class="mini-bar" style="height:30%;"></div>
              <div class="mini-bar" style="height:55%;"></div>
              <div class="mini-bar" style="height:45%;"></div>
              <div class="mini-bar" style="height:70%;"></div>
              <div class="mini-bar" style="height:85%;"></div>
              <div class="mini-bar" style="height:100%;"></div>
            </div>
          </div>
        </div>
      </div>

    </div><!-- /grid-2 second row -->

  </div><!-- /page-content -->
</div><!-- /main-wrapper -->

<script>
  // Sidebar toggle for mobile
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
