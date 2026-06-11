﻿﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Attendance.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student.Attendance" %>
<%@ Register Src="~/Student/StudentSidebar.ascx" TagPrefix="uc" TagName="StudentSidebar" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <title>My Attendance - SIMS Student Portal</title>

    <link rel="stylesheet" href="../Styles/SIMS.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        html,
        body {
            margin: 0 !important;
            padding: 0 !important;
        }

        body {
            overflow-x: hidden;
        }

        #form1 {
            margin: 0 !important;
            padding: 0 !important;
        }

        .sidebar {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 260px !important;
            height: 100vh !important;
            overflow-y: auto;
            overflow-x: hidden;
            scrollbar-width: thin;
            z-index: 3000 !important;
        }

        .main-wrapper {
            position: relative !important;
            z-index: 1 !important;
            margin-left: 260px !important;
            margin-top: 0 !important;
            padding-top: 0 !important;
            width: calc(100% - 260px) !important;
            min-height: 100vh;
        }

        .main-wrapper > .topbar {
            margin-top: 0 !important;
            top: 0 !important;
        }

        .content-area {
            padding: 28px 34px 40px;
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

    </style>
</head>

<body>
<form id="form1" runat="server">

 <uc:StudentSidebar ID="StudentSidebar1" runat="server" />

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