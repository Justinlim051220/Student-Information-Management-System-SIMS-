<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AtRiskStudents.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer.AtRiskStudents" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <title>At-Risk Students - SIMS Lecturer Portal</title>

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
            grid-template-columns: 1fr 1fr 1fr 1fr 1.4fr auto;
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

        .search-box {
            position: relative;
        }

        .search-box i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
        }

        .search-box .form-control {
            padding-left: 40px;
        }

        .risk-table {
            width: 100%;
            border-collapse: collapse;
        }

        .risk-table th {
            background: #fff8e1;
            color: var(--text-primary);
            font-size: 13px;
            text-align: left;
            padding: 14px;
        }

        .risk-table td {
            padding: 14px;
            border-bottom: 1px solid var(--border-light);
            font-size: 14px;
            vertical-align: top;
        }

        .risk-badge {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 800;
            margin: 2px 4px 2px 0;
        }

        .risk-high {
            background: rgba(231,76,60,.12);
            color: #e74c3c;
        }

        .risk-medium {
            background: rgba(243,156,18,.14);
            color: #f39c12;
        }

        .risk-low {
            background: rgba(46,204,113,.12);
            color: #27ae60;
        }

        .stats-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: var(--white);
            border: 1px solid var(--border-light);
            border-radius: var(--radius-md);
            padding: 18px 20px;
            box-shadow: var(--shadow-sm);
        }

        .stat-title {
            font-size: 12px;
            font-weight: 800;
            color: var(--text-muted);
            text-transform: uppercase;
            margin-bottom: 8px;
        }

        .stat-value {
            font-size: 26px;
            font-weight: 900;
            color: var(--text-primary);
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
            .filter-bar {
                grid-template-columns: 1fr 1fr;
            }

            .stats-row {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 800px) {
            .stats-row {
                grid-template-columns: 1fr;
            }
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

    <div class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            <img src="~/Images/Logo_Dashboard.png" runat="server" alt="ONTI SIMS" class="brand-logo" />
            <div class="brand-text">
                <div class="brand-name">SIMS</div>
                <div class="brand-sub">Lecturer Portal</div>
            </div>
        </div>

        <nav class="sidebar-nav">
            <div class="sidebar-section-label">Main</div>

            <a href="Lecturer_Dashboard.aspx" class="sidebar-link">
                <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
            </a>

            <a href="MyCourses.aspx" class="sidebar-link">
                <i class="fa-solid fa-book-open nav-icon"></i> My Courses
            </a>

            <div class="sidebar-section-label" style="margin-top:12px;">Academic</div>

            <a href="Attendance.aspx" class="sidebar-link">
                <i class="fa-solid fa-clipboard-check nav-icon"></i> Attendance
            </a>

            <a href="AtRiskStudents.aspx" class="sidebar-link active">
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

            <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link"
                OnClientClick="showLogoutModal(); return false;">
                <i class="fa-solid fa-right-from-bracket"></i> Log Out
            </asp:LinkButton>
        </div>
    </div>

    <div class="main-wrapper">

        <div class="topbar">
            <div>
                <div class="topbar-title">At-Risk Students</div>
                <div class="topbar-date">
                    <asp:Label ID="lblDate" runat="server" />
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

        <div class="page-content">

            <div class="page-header">
                <h1>At-Risk Students</h1>
                <p>Identify students with poor attendance, frequent lateness, or weak academic performance.</p>
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

            <div class="card" style="margin-bottom:24px;">
                <div class="card-body">
                    <div class="filter-bar">

                        <div class="filter-item">
                            <label>Programme</label>
                            <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" />
                        </div>

                        <div class="filter-item">
                            <label>Course</label>
                            <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged" />
                        </div>

                        <div class="filter-item">
                            <label>Session</label>
                            <asp:DropDownList ID="ddlSession" runat="server" CssClass="form-control" />
                        </div>

                        <div class="filter-item">
                            <label>Risk Type</label>
                            <asp:DropDownList ID="ddlRiskType" runat="server" CssClass="form-control">
                                <asp:ListItem Text="All Risks" Value=""></asp:ListItem>
                                <asp:ListItem Text="Attendance Risk" Value="Attendance"></asp:ListItem>
                                <asp:ListItem Text="Academic Risk" Value="Academic"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="filter-item">
                            <label>Search</label>
                            <div class="search-box">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control"
                                    placeholder="Search student ID or name..." />
                            </div>
                        </div>

                        <div class="filter-item">
                            <asp:Button ID="btnSearch" runat="server" Text="Search"
                                CssClass="btn btn-primary btn-sm"
                                OnClick="btnSearch_Click"
                                Style="width:auto;" />
                        </div>

                    </div>
                </div>
            </div>

            <div class="stats-row">
                <div class="stat-card">
                    <div class="stat-title">Total At-Risk</div>
                    <div class="stat-value"><asp:Label ID="lblTotalRisk" runat="server" Text="0" /></div>
                </div>

                <div class="stat-card">
                    <div class="stat-title">Attendance Risk</div>
                    <div class="stat-value"><asp:Label ID="lblAttendanceRisk" runat="server" Text="0" /></div>
                </div>

                <div class="stat-card">
                    <div class="stat-title">Academic Risk</div>
                    <div class="stat-value"><asp:Label ID="lblAcademicRisk" runat="server" Text="0" /></div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <span class="card-title">Risk Student List</span>
                    <span class="badge badge-orange">
                        <asp:Label ID="lblTotal" runat="server" Text="0" /> Students
                    </span>
                </div>

                <div class="card-body">
                    <asp:Repeater ID="rptRiskStudents" runat="server">
                        <HeaderTemplate>
                            <table class="risk-table">
                                <thead>
                                    <tr>
                                        <th>No.</th>
                                        <th>Student ID</th>
                                        <th>Student Name</th>
                                        <th>Course</th>
                                        <th>Session</th>
                                        <th>Present Time</th>
                                        <th>Attendance Rate</th>
                                        <th>Average Marks</th>
                                        <th>Risk Reason</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>

                        <ItemTemplate>
                            <tr>
                                <td><%# Container.ItemIndex + 1 %></td>
                                <td><%# Eval("StudentId") %></td>
                                <td><%# Eval("StudentName") %></td>
                                <td><%# Eval("CourseDisplay") %></td>
                                <td><%# Eval("Session") %></td>
                                <td><%# Eval("PresentCount") %> / <%# Eval("RollCallCount") %></td>
                                <td><%# Eval("AttendanceRate") %>%</td>
                                <td><%# Eval("AverageMarks") %>%</td>
                                <td><%# Eval("RiskReason") %></td>
                            </tr>
                        </ItemTemplate>

                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                        <i class="fa-solid fa-circle-check"></i>
                        <h3>No at-risk students found</h3>
                        <p>No students match the current risk criteria.</p>
                    </asp:Panel>
                </div>
            </div>

        </div>
    </div>
<!-- Logout Confirmation Modal -->
<div id="logoutModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(26,26,46,0.85); z-index: 9999; align-items: center; justify-content: center;">
  <div style="background: white; border-radius: 12px; width: 100%; max-width: 380px; box-shadow: 0 15px 35px rgba(0,0,0,0.3); overflow: hidden;">
    <div style="padding: 25px 30px 10px; text-align: center; border-bottom: 1px solid #eee;">
      <h3>&#128274; Log Out</h3>
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
