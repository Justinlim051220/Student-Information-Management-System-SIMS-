<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AtRiskStudents.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer.AtRiskStudents" %>
<%@ Register Src="~/Lecturer/LecturerSidebar.ascx" TagPrefix="uc" TagName="LecturerSidebar" %>

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
        /* ================================================================
           Logout confirmation prompt - exact Lecturer_Dashboard style
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

        .logout-modal-top { padding: 36px 32px 20px; }

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

        .logout-warning-icon i { color: #f59e0b; }

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
    </style>
</head>

<body>
<form id="form1" runat="server">

    <uc:LecturerSidebar ID="LecturerSidebar1" runat="server" />

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
