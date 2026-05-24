<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Attendance.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer.Attendance" %>

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
    </style>
</head>

<body>
<form id="form1" runat="server">

    <div class="sidebar">
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

            <a href="MyStudents.aspx" class="sidebar-link">
                <i class="fa-solid fa-user-graduate nav-icon"></i> My Students
            </a>

            <div class="sidebar-section-label" style="margin-top:12px;">Academic</div>

            <a href="Attendance.aspx" class="sidebar-link active">
                <i class="fa-solid fa-clipboard-check nav-icon"></i> Attendance
            </a>

            <a href="Grades.aspx" class="sidebar-link">
                <i class="fa-solid fa-star-half-stroke nav-icon"></i> Grades
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

        <div class="sidebar-footer">
            <div class="sidebar-user">
                <div class="user-avatar">
                    <asp:Label ID="lblAvatarInitial" runat="server" Text="L" />
                </div>
                <div class="user-info">
                    <div class="user-name">
                        <asp:Label ID="lblSidebarName" runat="server" Text="Lecturer" />
                    </div>
                    <div class="user-role">Lecturer</div>
                </div>
            </div>

            <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link" OnClick="lbLogout_Click">
                <i class="fa-solid fa-right-from-bracket"></i> Log Out
            </asp:LinkButton>
        </div>
    </div>

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

                                        <label>
                                            <asp:CheckBox ID="chkLate" runat="server"
                                                Checked='<%# Eval("Status").ToString() == "Late" %>'
                                                Enabled='<%# Convert.ToString(Eval("CanEdit")) == "1" %>' />
                                            Late
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

</form>
</body>
</html>