﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Report.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer.Report" %>
<%@ Register Src="~/Lecturer/LecturerSidebar.ascx" TagPrefix="uc" TagName="LecturerSidebar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Reports - SIMS Lecturer Portal</title>

    <link rel="stylesheet" href="../Styles/SIMS.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        html,
        body {
            margin: 0;
            padding: 0;
            min-height: 100%;
            background: #f5f6fa;
        }

        form {
            margin: 0;
            padding: 0;
        }

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
            min-height: 100vh;
            background: #f5f6fa;
        }

        .topbar {
            margin: 0;
        }

        .page-content {
            padding: 30px;
        }

        .page-header {
            margin: 0 0 26px;
        }

        .report-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(260px, 1fr));
            gap: 22px;
        }

        .report-card {
            background: linear-gradient(180deg, #fff 0%, #fffaf3 100%);
            border: 1px solid #edf0f6;
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-card);
            padding: 26px;
            text-decoration: none;
            color: inherit;
            transition: var(--transition);
            min-height: 190px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .report-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-elevated);
            border-color: #f2c46f;
        }

        .report-icon {
            width: 54px;
            height: 54px;
            border-radius: 18px;
            background: var(--orange-gradient);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            box-shadow: var(--shadow-orange);
            margin-bottom: 18px;
        }

        .report-title {
            font-size: 20px;
            font-weight: 900;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .report-desc {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-muted);
            line-height: 1.5;
        }

        .report-action {
            margin-top: 22px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--orange-dark);
            font-size: 13px;
            font-weight: 900;
        }

        /* Match other lecturer pages: separate lecturer identity from logout link */
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
            to { transform: translateY(0) scale(1); opacity: 1; }
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

        @media (max-width: 900px) {
            .report-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>
<form id="form1" runat="server">

    <uc:LecturerSidebar ID="LecturerSidebar1" runat="server" />

    <div class="main-wrapper">

        <div class="topbar">
            <div>
                <div class="topbar-title">Reports</div>
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
                <h1>Reports</h1>
                <p>View attendance and course reports for your assigned classes.</p>
            </div>

            <div class="report-grid">

                <a href="AttendanceReport.aspx" class="report-card">
                    <div>
                        <div class="report-icon">
                            <i class="fa-solid fa-chart-column"></i>
                        </div>
                        <div class="report-title">Attendance Report</div>
                        <div class="report-desc">
                            View attendance summaries, percentages, and student attendance performance.
                        </div>
                    </div>

                    <div class="report-action">
                        Open Attendance Report <i class="fa-solid fa-arrow-right"></i>
                    </div>
                </a>

                <a href="CourseReport.aspx" class="report-card">
                    <div>
                        <div class="report-icon">
                            <i class="fa-solid fa-book-open-reader"></i>
                        </div>
                        <div class="report-title">Course Report</div>
                        <div class="report-desc">
                            View course summaries, enrolled students, course details, and teaching records.
                        </div>
                    </div>

                    <div class="report-action">
                        Open Course Report <i class="fa-solid fa-arrow-right"></i>
                    </div>
                </a>

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
