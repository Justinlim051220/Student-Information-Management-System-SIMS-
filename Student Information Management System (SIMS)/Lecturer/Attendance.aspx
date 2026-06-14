<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Attendance.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer.Attendance" %>
<%@ Register Src="~/Lecturer/LecturerSidebar.ascx" TagPrefix="uc" TagName="LecturerSidebar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <title>Attendance - SIMS Lecturer Portal</title>

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
            grid-template-columns: 1fr 1fr 1fr 1fr auto;
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

        .status-options {
            display: flex;
            gap: 18px;
            align-items: center;
            flex-wrap: wrap;
        }

        .status-options label {
            font-weight: 700;
            color: var(--text-secondary);
        }

        .summary-box {
            display: flex;
            gap: 12px;
            align-items: center;
            margin-bottom: 16px;
            font-weight: 800;
            color: var(--text-primary);
        }

        .summary-box i {
            color: var(--orange-main);
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 22px;
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

        @media (max-width: 1100px) {
            .filter-bar {
                grid-template-columns: 1fr 1fr;
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
                <div class="topbar-title">Attendance</div>
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
                <h1>Record Student Attendance</h1>
                <p>Select a course session and record student attendance.</p>
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

            <div class="card" style="margin-bottom:24px;">
                <div class="card-body">
                    <div class="filter-bar">

                        <div class="filter-item">
                            <label>Date</label>
                            <asp:TextBox ID="txtAttendanceDate" runat="server" CssClass="form-control" TextMode="Date" />
                        </div>

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
                            <asp:Button ID="btnSearch" runat="server" Text="Search"
                                CssClass="btn btn-primary btn-sm"
                                OnClick="btnSearch_Click"
                                Style="width:auto;" />
                        </div>

                    </div>
                </div>
            </div>

            <asp:Panel ID="pnlAttendanceList" runat="server" CssClass="card" Visible="false">
                <div class="card-header">
                    <span class="card-title">Student Attendance List</span>
                    <span class="badge badge-orange">
                        <asp:Label ID="lblStudentCount" runat="server" Text="0" /> Students
                    </span>
                </div>

                <div class="card-body">

                    <div class="summary-box">
                        <i class="fa-solid fa-users"></i>
                        Total Students:
                        <asp:Label ID="lblTotalStudents" runat="server" Text="0" />
                    </div>

                    <asp:HiddenField ID="hfIsSubmitted" runat="server" Value="0" />

                    <asp:Repeater ID="rptStudents" runat="server">
                        <HeaderTemplate>
                            <table class="attendance-table">
                                <thead>
                                    <tr>
                                        <th>No.</th>
                                        <th>Student ID</th>
                                        <th>Student Name</th>
                                        <th>Attendance Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>

                        <ItemTemplate>
                            <tr>
                                <td><%# Container.ItemIndex + 1 %></td>

                                <td>
                                    <%# Eval("StudentId") %>
                                    <asp:HiddenField ID="hfStudentId" runat="server" Value='<%# Eval("StudentId") %>' />
                                </td>

                                <td><%# Eval("StudentName") %></td>

                                <td>
                                    <div class="status-options">
                                        <label>
                                            <asp:CheckBox ID="chkPresent" runat="server"
                                                Checked='<%# Eval("Status").ToString() == "Present" %>'
                                                Enabled='<%# Convert.ToString(Eval("CanEdit")) == "1" %>' />
                                            Present
                                        </label>

                                        <label>
                                            <asp:CheckBox ID="chkAbsent" runat="server"
                                                Checked='<%# Eval("Status").ToString() == "Absent" %>'
                                                Enabled='<%# Convert.ToString(Eval("CanEdit")) == "1" %>' />
                                            Absent
                                        </label>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>

                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                        <i class="fa-solid fa-user-slash"></i>
                        <h3>No students found</h3>
                        <p>No students are enrolled in this course/session.</p>
                    </asp:Panel>

                    <div class="form-actions">
                        <asp:Button ID="btnEditAttendance" runat="server" Text="Edit Attendance"
                            CssClass="btn btn-outline btn-sm"
                            OnClick="btnEditAttendance_Click"
                            Visible="false"
                            CausesValidation="false" />

                        <asp:Button ID="btnSubmitAttendance" runat="server" Text="Submit Attendance"
                            CssClass="btn btn-primary btn-sm"
                            OnClick="btnSubmitAttendance_Click"
                            Style="width:auto;" />
                    </div>

                </div>
            </asp:Panel>
        </div>
    </div>

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
            '<line x1="6" y1="6" x2="18" y2="18"/>' +
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

        document.addEventListener('change', function (e) {
            if (e.target.type === 'checkbox') {
                var row = e.target.closest('tr');
                if (!row) return;

                var boxes = row.querySelectorAll('input[type="checkbox"]');

                if (e.target.checked) {
                    boxes.forEach(function (box) {
                        if (box !== e.target) {
                            box.checked = false;
                        }
                    });
                }
            }
        });
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