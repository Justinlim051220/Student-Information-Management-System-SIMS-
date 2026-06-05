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
            top: 0;
            left: 0;
            width: 260px;
            height: 100vh;
            overflow-y: auto;      
            overflow-x: hidden;
            scrollbar-width: thin;
        }

        .main-wrapper {
            margin-left: 260px;
        }

        .filter-bar {
            display: grid;
            grid-template-columns: 1fr 1fr auto;
            gap: 12px;
            align-items: end;
            margin-bottom: 22px;
        }

        .filter-item label {
            display: block;
            font-size: 12px;
            font-weight: 800;
            color: var(--text-secondary);
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: .4px;
        }

        .course-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px;
            overflow: visible;
        }

        .course-card {
            position: relative;
            border: 1px solid var(--border-light);
            border-radius: var(--radius-md);
            background: var(--white);
            overflow: visible;
            transition: var(--transition);
            min-height: 190px;
            cursor: pointer;
        }

        .course-card:hover {
            box-shadow: var(--shadow-card);
            transform: translateY(-2px);
        }

        .course-body {
            padding: 26px 20px 20px;
        }

        .course-name {
            font-family: var(--font-accent);
            font-size: 18px;
            font-weight: 800;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .course-code {
            font-size: 13px;
            font-weight: 800;
            color: var(--orange-main);
            margin-bottom: 8px;
        }

        .course-session {
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 700;
        }

        .course-semester {
            margin-top: 6px;
            font-size: 13px;
            color: var(--text-secondary);
            font-weight: 700;
        }

        .empty-state {
            text-align: center;
            padding: 46px 20px;
            color: var(--text-muted);
        }

        .empty-state i {
            font-size: 42px;
            color: var(--orange-main);
            margin-bottom: 12px;
        }

        @media (max-width: 1200px) {
            .course-grid { grid-template-columns: repeat(2, 1fr); }
        }

        @media (max-width: 900px) {
            .filter-bar { grid-template-columns: 1fr; }
            .course-grid { grid-template-columns: 1fr; }
        }

        .sidebar-user {
            margin-bottom: 18px;
            align-items: flex-start;
        }

        .user-info { padding-top: 4px; }
        .user-name { margin-bottom: 4px; }
        .user-role { margin-top: 2px; }
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
    
    <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/Student/Student_Dashboard.aspx" CssClass="sidebar-link">
      <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
    </asp:HyperLink>
    
    <asp:HyperLink ID="lnkMyCourses" runat="server" NavigateUrl="~/Student/MyCourses.aspx" CssClass="sidebar-link active">
      <i class="fa-solid fa-book-open nav-icon"></i> My Courses
    </asp:HyperLink>
    
    <asp:HyperLink ID="lnkAttendance" runat="server" NavigateUrl="~/Student/Attendance.aspx" CssClass="sidebar-link">
      <i class="fa-solid fa-calendar-check nav-icon"></i> Attendance
    </asp:HyperLink>
    
    <asp:HyperLink ID="lnkEnrollment" runat="server" NavigateUrl="~/Student/Student_Enrollment.aspx" CssClass="sidebar-link">
      <i class="fa-solid fa-clipboard-list nav-icon"></i> Enrollment
    </asp:HyperLink>
    
    <asp:HyperLink ID="lnkResults" runat="server" NavigateUrl="~/Student/Results.aspx" CssClass="sidebar-link">
      <i class="fa-solid fa-chart-line nav-icon"></i> Results
    </asp:HyperLink>
    
    <asp:HyperLink ID="lnkAcademicHistory" runat="server" NavigateUrl="~/Student/AcademicHistory.aspx" CssClass="sidebar-link">
      <i class="fa-solid fa-clock-rotate-left nav-icon"></i> Academic History
    </asp:HyperLink>

    <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>
    <asp:HyperLink ID="lnkNotifications" runat="server" NavigateUrl="~/Student/Notifications.aspx" CssClass="sidebar-link">
      <i class="fa-solid fa-bell nav-icon"></i> Notifications
      <asp:Panel ID="pnlSidebarNotifBadge" runat="server" CssClass="badge-dot" Visible="false" style="margin-left:auto;" />
    </asp:HyperLink>
    
    <asp:HyperLink ID="lnkContacts" runat="server" NavigateUrl="~/Student/Contacts.aspx" CssClass="sidebar-link">
      <i class="fa-solid fa-address-book nav-icon"></i> Contacts
    </asp:HyperLink>

    <div class="sidebar-section-label" style="margin-top:12px;">Account</div>
    <asp:HyperLink ID="lnkProfile" runat="server" NavigateUrl="~/Student/MyProfile.aspx" CssClass="sidebar-link">
      <i class="fa-solid fa-circle-user nav-icon"></i> My Profile
    </asp:HyperLink>
  </nav>

  <div class="sidebar-footer">
    <div class="sidebar-user">
      <div class="user-avatar" style="width: 42px; height: 42px; border-radius: 50%; background: var(--orange-gradient); display: flex; align-items: center; justify-content: center; color: var(--white); font-weight: 800;">
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
</div>

<div class="main-wrapper">
    <div class="topbar">
        <div>
            <div class="topbar-title">My Courses</div>
            <div class="topbar-date">
                <asp:Label ID="lblDate" runat="server" />
           </div>
        </div>

        <div class="topbar-right">
            <a href="Notifications.aspx" class="topbar-icon-btn" title="Notifications">
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
                        <asp:DropDownList ID="ddlFilterSession" runat="server" CssClass="form-control"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSession_SelectedIndexChanged" />
                    </div>

                    <div class="filter-item">
                        <label>Semester</label>
                       <asp:DropDownList ID="ddlFilterSemester" runat="server" CssClass="form-control"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSemester_SelectedIndexChanged" />
                    </div>

                    <div class="filter-item">
                        <asp:Button ID="btnSearch" runat="server" Text="Filter"
                            CssClass="btn btn-primary btn-sm"
                            OnClick="btnSearch_Click"
                            Style="width:auto;" />
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <span class="card-title">Enrolled Courses</span>
                <span class="badge badge-orange">
                    <asp:Label ID="lblTotal" runat="server" Text="0" /> Modules
               </span>
            </div>

            <div class="card-body">
                <asp:Repeater ID="rptCourses" runat="server">
                    <HeaderTemplate>
                        <div class="course-grid">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="course-card" onclick="window.location.href='CourseDetails.aspx?courseId=<%# Eval("CourseId") %>&session=<%# Server.UrlEncode(Convert.ToString(Eval("Session"))) %>';">
                            <div class="course-body">
                                <div class="course-name"><%# Eval("CourseName") %></div>
                                <div class="course-code"><%# Eval("CourseCode") %></div>
                                <div class="course-session">
                                    <i class="fa-solid fa-calendar-days"></i> Session: <%# Eval("Session") %>
                                </div>
                               <div class="course-semester">
                                    <i class="fa-solid fa-layer-group"></i> Semester: <%# Eval("Semester") %>
                                </div>
                             </div>
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

<div id="logoutModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(26,26,46,0.85); z-index: 9999; align-items: center; justify-content: center;">
  <div style="background: white; border-radius: 12px; width: 100%; max-width: 380px; box-shadow: 0 15px 35px rgba(0,0,0,0.3); overflow: hidden;">
    <div style="padding: 25px 30px 10px; text-align: center; border-bottom: 1px solid #eee;">
      <h3>🔒 Log Out</h3>
    </div>
    <div style="padding: 25px 30px; text-align: center; color: #555;">
      <p>Are you sure you want to log out of SIMS?</p>
    </div>
    <div style="padding: 20px 30px 25px; display: flex; gap: 12px; justify-content: center; border-top: 1px solid #eee;">
      <button type="button" onclick="hideLogoutModal()" style="padding: 10px 24px;" class="btn btn-outline">Cancel</button>
      <asp:LinkButton ID="btnConfirmLogout" runat="server" CssClass="btn btn-danger" OnClick="lbLogout_Click">
          Yes, Log Out
      </asp:LinkButton>
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