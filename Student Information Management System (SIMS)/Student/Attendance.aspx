﻿﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Attendance.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student.Attendance" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <title>My Attendance - SIMS Student Portal</title>

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

        .attendance-table {
            width: 100%;
            border-collapse: collapse;
        }

        .attendance-table th {
            background: #fff8e1;
            color: var(--text-primary);
            font-size: 13px;
            text-align: left;
            padding: 14px;
        }

        .attendance-table td {
            padding: 14px;
            border-bottom: 1px solid var(--border-light);
            font-size: 14px;
        }

        /* Clean Status Badges instead of checkboxes */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            border-radius: 50px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .status-present {
            background-color: #e6f4ea;
            color: #137333;
        }

        .status-absent {
            background-color: #fce8e6;
            color: #c5221f;
        }

        .status-total {
            font-size: 18px;
            font-weight: 800;
            color: var(--orange-main);
        }

        .summary-flex {
            display: flex;
            gap: 24px;
            flex-wrap: wrap;
            margin-bottom: 18px;
        }

        .summary-box {
            display: flex;
            gap: 10px;
            align-items: center;
            font-weight: 800;
            color: var(--text-primary);
            background: var(--bg-light);
            padding: 10px 18px;
            border-radius: 8px;
        }

        .summary-box i {
            color: var(--orange-main);
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

        #customModalOverlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(30,30,40,.60);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }

        #customModalOverlay.active {
            display: flex;
        }

        #customModal {
            background: #fff;
            border-radius: 16px;
            width: 100%;
            max-width: 400px;
            padding: 36px 32px 28px;
            box-shadow: 0 12px 40px rgba(0,0,0,.28);
            text-align: center;
        }

        .cm-icon-wrap {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
        }

        .cm-icon-wrap.icon-success {
            background: #fff8e1;
        }

        .cm-icon-wrap.icon-error {
            background: #fdecea;
        }

        .cm-icon-wrap #cmIcon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
        }

        .cm-icon-wrap svg {
            width: 32px;
            height: 32px;
            display: block;
        }

        .cm-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1a1a2e;
            margin-bottom: 14px;
        }

        .cm-divider {
            border: none;
            border-top: 1px solid #ececec;
            margin: 0 -32px 18px;
        }

        .cm-body {
            font-size: .97rem;
            line-height: 1.65;
            color: #555;
            margin-bottom: 28px;
        }

        .cm-footer {
            display: flex;
            justify-content: center;
        }

        .cm-btn {
            padding: 10px 32px;
            border-radius: 50px;
            font-size: .95rem;
            font-weight: 600;
            cursor: pointer;
            border: 2px solid #e8a838;
            background: transparent;
            color: #e8a838;
        }

        .cm-btn:hover {
            background: #fdf3e0;
        }

        @media (max-width: 900px) {
            .filter-bar {
                grid-template-columns: 1fr;
            }
        }

        .sidebar-user {
            margin-bottom: 18px;
            align-items: flex-start;
        }

        .user-info {
            padding-top: 4px;
        }

        .user-name {
            margin-bottom: 4px;
        }

        .user-role {
            margin-top: 2px;
        }

        /* ===== Standard Student logout dialog - same as Dashboard ===== */
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

    </style>
</head>

<body>
<form id="form1" runat="server">

    <div class="sidebar">
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

            <div class="sidebar-section-label" style="margin-top:12px;">Academic</div>

            <asp:HyperLink ID="lnkMyCourses" runat="server" NavigateUrl="~/Student/MyCourses.aspx" CssClass="sidebar-link">
                <i class="fa-solid fa-book-open nav-icon"></i> My Courses
            </asp:HyperLink>

            <asp:HyperLink ID="lnkAttendance" runat="server" NavigateUrl="~/Student/Attendance.aspx" CssClass="sidebar-link active">
                <i class="fa-solid fa-calendar-check nav-icon"></i> Attendance
            </asp:HyperLink>

            <asp:HyperLink ID="lnkEnrollment" runat="server" NavigateUrl="~/Student/Student_Enrollment.aspx" CssClass="sidebar-link">
                <i class="fa-solid fa-clipboard-list nav-icon"></i> Enrollment
            </asp:HyperLink>

            <asp:HyperLink ID="lnkResults" runat="server" NavigateUrl="~/Student/Results.aspx" CssClass="sidebar-link">
                <i class="fa-solid fa-chart-line nav-icon"></i> Results
            </asp:HyperLink>
<div class="sidebar-section-label" style="margin-top:12px;">Finance</div>

            <asp:HyperLink ID="lnkPayment" runat="server" NavigateUrl="~/Student/Student_Payment.aspx" CssClass="sidebar-link">
                <i class="fa-solid fa-money-bill-wave nav-icon"></i> Payment
            </asp:HyperLink>

            <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>

            <asp:HyperLink ID="lnkNotifications" runat="server" NavigateUrl="~/Student/Notification.aspx" CssClass="sidebar-link">
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

            <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link" OnClientClick="showLogoutModal(); return false;">
                <i class="fa-solid fa-right-from-bracket"></i> Log Out
            </asp:LinkButton>
        </div>
    </div>

    <div class="main-wrapper">
        <div class="topbar">
            <div>
                <div class="topbar-title">My Attendance</div>
                <div class="topbar-date">
                    <asp:Label ID="lblDate" runat="server" />
                </div>
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
                <h1>My Attendance Records</h1>
                <p>Track your real-time presence history and metrics per course module.</p>
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

            <div class="card" style="margin-bottom:24px;">
                <div class="card-body">
                    <div class="filter-bar">

                        <div class="filter-item">
                            <label>Course Code & Name</label>
                            <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged" />
                        </div>

                        <div class="filter-item">
                            <label>Session</label>
                            <asp:DropDownList ID="ddlSession" runat="server" CssClass="form-control" />
                        </div>

                        <div class="filter-item">
                            <asp:Button ID="btnSearch" runat="server" Text="Filter Records"
                                CssClass="btn btn-primary btn-sm"
                                OnClick="btnSearch_Click"
                                Style="width:auto;" />
                        </div>

                    </div>
                </div>
            </div>

            <asp:Panel ID="pnlAttendanceList" runat="server" CssClass="card" Visible="true">
                <div class="card-header">
                    <span class="card-title">Detailed Logs</span>
                    <span class="badge badge-orange">
                        Attendance Rate: <asp:Label ID="lblAttendancePercentage" runat="server" Text="100%" />
                    </span>
                </div>

                <div class="card-body">

                    <div class="summary-flex">
                        <div class="summary-box">
                            <i class="fa-solid fa-calendar-check"></i>
                            Present Sessions: &nbsp;<asp:Label ID="lblPresentCount" runat="server" CssClass="status-total" Text="0" />
                        </div>
                        <div class="summary-box">
                            <i class="fa-solid fa-calendar-times" style="color: #c5221f;"></i>
                            Absent Sessions: &nbsp;<asp:Label ID="lblAbsentCount" runat="server" CssClass="status-total" style="color:#c5221f;" Text="0" />
                        </div>
                    </div>

                    <asp:Repeater ID="rptAttendance" runat="server">
                        <HeaderTemplate>
                            <table class="attendance-table">
                                <thead>
                                    <tr>
                                        <th>No.</th>
                                        <th>Session Date</th>
                                        <th>Module / Subject</th>
                                        <th>Academic Session</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>

                        <ItemTemplate>
                            <tr>
                                <td><%# Container.ItemIndex + 1 %></td>
                                <td><%# Eval("AttendanceDate", "{0:dd MMM yyyy}") %></td>
                                <td><%# Eval("CourseDisplay") %></td>
                                <td><%# Eval("Session") %></td>
                                <td>
                                    <span class='<%# Eval("Status").ToString() == "Present" ? "status-badge status-present" : "status-badge status-absent" %>'>
                                        <i class='<%# Eval("Status").ToString() == "Present" ? "fa-solid fa-circle-check" : "fa-solid fa-circle-xmark" %>'></i>
                                        <%# Eval("Status") %>
                                    </span>
                                </td>
                            </tr>
                        </ItemTemplate>

                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                        <i class="fa-solid fa-clipboard-question"></i>
                        <h3>No attendance logs found</h3>
                        <p>Adjust your select parameters or check if registration tracking has initiated for this module.</p>
                    </asp:Panel>

                </div>
            </asp:Panel>
        </div>
    </div>


    <!-- ================================================================
         LOGOUT MODAL - same UI as Student Dashboard
         ================================================================ -->
    <div id="logoutModal" class="modal-overlay system-dialog">
        <div class="modal-box">
            <div class="modal-head">
                <div class="logout-warning-icon">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                </div>
                <span>Log Out</span>
            </div>
            <div class="modal-body">
                Are you sure you want to log out?
            </div>
            <div class="modal-actions">
                <button type="button" class="modal-cancel" onclick="hideLogoutModal();">Cancel</button>
                <a href="../Login.aspx" class="modal-submit">Log Out</a>
            </div>
        </div>
    </div>

    <!-- Custom Alert Modal Structure -->
    <div id="customModalOverlay">
        <div id="customModal">
            <div class="cm-icon-wrap" id="cmIconWrap">
                <span id="cmIcon"></span>
            </div>

            <div class="cm-title" id="cmTitle">Message</div>
            <hr class="cm-divider" />
            <div class="cm-body" id="cmBody"></div>

            <div class="cm-footer">
                <button type="button" class="cm-btn" onclick="closeCustomModal()">OK</button>
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

        var SVG_TICK =
            '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round">' +
            '<polyline points="20 6 9 17 4 12"/>' +
            '</svg>';

        var SVG_CROSS =
            '<svg viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round">' +
            '<line x1="18" y1="6" x2="6" y2="18"/>' +
            '</svg>';

        function showMessageModal(title, message, isSuccess) {
            var iconWrap = document.getElementById('cmIconWrap');
            var iconEl = document.getElementById('cmIcon');

            if (isSuccess) {
                iconWrap.className = 'cm-icon-wrap icon-success';
                iconEl.innerHTML = SVG_TICK;
            } else {
                iconWrap.className = 'cm-icon-wrap icon-error';
                iconEl.innerHTML = SVG_CROSS;
            }

            document.getElementById('cmTitle').innerHTML = title;
            document.getElementById('cmBody').innerHTML = message;
            document.getElementById('customModalOverlay').classList.add('active');
        }

        function closeCustomModal() {
            document.getElementById('customModalOverlay').classList.remove('active');
        }
    </script>

</form>
</body>
</html>