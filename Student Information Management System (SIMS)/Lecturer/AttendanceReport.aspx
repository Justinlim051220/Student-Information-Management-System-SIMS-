﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AttendanceReport.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer.AttendanceReport" EnableEventValidation="false" %>
<%@ Register Src="~/Lecturer/LecturerSidebar.ascx" TagPrefix="uc" TagName="LecturerSidebar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Attendance Report - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />

    <style>
        html, body { margin:0; padding:0; min-height:100%; background:#f4f6fb; }
        form { margin:0; padding:0; }
        .sidebar { position:fixed; top:0; left:0; width:260px; height:100vh; overflow-y:auto; overflow-x:hidden; scrollbar-width:thin; }
        .main-wrapper { margin-left:260px; min-height:100vh; background:#f4f6fb; }
        .topbar { margin:0; }
        .page-content { padding:30px; }
        .page-header { margin:0 0 26px; }
        .filter-card { margin-bottom:26px; }
        .report-actions { display:flex; gap:12px; flex-wrap:wrap; align-items:center; margin-top:18px; }
        .report-section { margin-top:22px; }
        .report-header-box { background:#fff7ed; border-left:5px solid #e8a838; padding:18px 22px; border-radius:14px; margin-bottom:20px; color:#374151; line-height:1.7; }
        .summary-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:16px; margin-bottom:22px; }
        .summary-card { background:#fff; border:1px solid #fed7aa; border-radius:16px; padding:18px; box-shadow:0 8px 22px rgba(15,23,42,.06); }
        .summary-card .label { color:#64748b; font-size:13px; font-weight:800; }
        .summary-card .value { color:#c2410c; font-size:25px; font-weight:900; margin-top:8px; }
        .section-title { display:flex; align-items:center; gap:9px; font-weight:900; color:#1a1a2e; margin:24px 0 12px; font-size:1.05rem; }
        .table-scroll { overflow:auto; border:1px solid #e5e7eb; border-radius:16px; background:#fff; }
        .orange-grid { width:100%; border-collapse:collapse; min-width:760px; }
        .orange-grid th { background:#e8a838 !important; color:#fff !important; font-size:12px; text-transform:uppercase; letter-spacing:.03em; padding:13px 12px; text-align:left; white-space:nowrap; }
        .orange-grid td { padding:12px; border-bottom:1px solid #edf0f5; color:#374151; font-size:13px; white-space:nowrap; }
        .orange-grid tr:hover td { background:#fffaf0; }
        .status-pill { display:inline-flex; align-items:center; justify-content:center; min-width:34px; border-radius:999px; padding:5px 9px; font-weight:900; font-size:12px; }
        .status-present { background:#dcfce7; color:#15803d; }
        .status-absent { background:#fee2e2; color:#b91c1c; }
        .status-late { background:#ffedd5; color:#c2410c; }
        .status-empty { background:#f1f5f9; color:#64748b; }
        .empty-state { background:#f8fafc; border:1px dashed #cbd5e1; color:#64748b; border-radius:14px; padding:22px; line-height:1.7; margin-top:20px; }
        .sidebar-user { margin-bottom:18px; align-items:flex-start; }
        .user-info { padding-top:4px; }
        .user-name { margin-bottom:4px; }
        .sidebar-photo-avatar { width:42px; height:42px; border-radius:50%; overflow:hidden; padding:0 !important; flex-shrink:0; }
        .sidebar-avatar-img { width:100%; height:100%; object-fit:cover; border-radius:50%; display:block; }

        .logout-modal-overlay {
            display:none;
            position:fixed;
            inset:0;
            background:rgba(17,24,39,.62);
            z-index:9999;
            align-items:center;
            justify-content:center;
            padding:20px;
        }
        .logout-modal-card {
            width:100%;
            max-width:400px;
            background:#fff;
            border-radius:14px;
            overflow:hidden;
            box-shadow:0 22px 60px rgba(15,23,42,.28);
            text-align:center;
            font-family:var(--font-primary);
            animation:logoutPop .18s ease-out;
        }
        @keyframes logoutPop {
            from { transform:translateY(8px) scale(.98); opacity:0; }
            to { transform:translateY(0) scale(1); opacity:1; }
        }
        .logout-modal-top { padding:36px 32px 20px; }
        .logout-warning-icon { width:72px; height:72px; margin:0 auto 18px; display:flex; align-items:center; justify-content:center; background:transparent; color:#f59e0b; font-size:56px; line-height:1; }
        .logout-warning-icon i { color:#f59e0b; }
        .logout-title { margin:0; color:var(--text-primary); font-size:20px; font-weight:800; line-height:1.25; }
        .logout-message { margin:0; padding:20px 32px; border-top:1px solid var(--border-light); color:var(--text-secondary); font-size:15px; font-weight:500; line-height:1.5; }
        .logout-actions { display:flex; justify-content:center; gap:12px; padding:18px 28px 28px; }
        .logout-btn { min-width:118px; height:44px; border-radius:999px; font-family:var(--font-primary); font-size:14px; font-weight:800; display:inline-flex; align-items:center; justify-content:center; cursor:pointer; text-decoration:none; transition:var(--transition); }
        .logout-btn-cancel { border:2px solid var(--orange-main); background:#fff; color:var(--orange-main); }
        .logout-btn-cancel:hover { background:#fff7ed; transform:translateY(-1px); }
        .logout-btn-confirm { border:2px solid transparent; background:var(--orange-gradient); color:#fff !important; box-shadow:var(--shadow-orange); }
        .logout-btn-confirm:hover { transform:translateY(-1px); color:#fff !important; }

        @media print {
            @page { size: landscape; margin: 14mm; }

            body {
                background: #ffffff !important;
            }

            .sidebar,
            .topbar,
            .filter-card,
            .report-actions,
            .logout-modal-overlay {
                display: none !important;
            }

            .main-wrapper {
                margin-left: 0 !important;
                width: 100% !important;
                min-height: auto !important;
                background: #ffffff !important;
            }

            .page-content {
                width: 100% !important;
                max-width: 100% !important;
                margin: 0 auto !important;
                padding: 0 !important;
            }

            .page-header,
            .report-section,
            .report-header-box,
            .summary-grid,
            .section-title,
            .table-scroll {
                max-width: 100% !important;
                margin-left: auto !important;
                margin-right: auto !important;
            }

            .page-header {
                text-align: center;
                margin-bottom: 14px !important;
            }

            .report-header-box {
                text-align: center;
                border-left: 0 !important;
                border-top: 4px solid #e8a838;
                box-shadow: none !important;
            }

            .summary-grid {
                grid-template-columns: repeat(4, 1fr) !important;
            }

            .summary-card {
                box-shadow: none !important;
                break-inside: avoid;
            }

            .table-scroll {
                overflow: visible !important;
                border: 0 !important;
            }

            .orange-grid {
                width: 100% !important;
                min-width: 0 !important;
                margin: 0 auto !important;
                font-size: 10px;
            }

            .orange-grid th,
            .orange-grid td {
                padding: 6px 7px !important;
                white-space: normal !important;
            }
        }
    </style>
</head>

<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <uc:LecturerSidebar ID="LecturerSidebar1" runat="server" />

    <div class="main-wrapper">
        <div class="topbar">
            <div>
                <div class="topbar-title">Attendance Report</div>
                <div class="topbar-date"><asp:Label ID="lblDate" runat="server" /></div>
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
                <h1><i class="fa-solid fa-chart-column"></i> Attendance Report</h1>
                <p>Generate attendance report for your assigned courses.</p>
            </div>

            <div class="card filter-card">
                <div class="card-header">
                    <span class="card-title"><i class="fa-solid fa-filter"></i> Report Filter</span>
                </div>
                <div class="card-body">
                    <div class="grid-2">
                        <div class="form-group">
                            <label>Programme</label>
                            <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" />
                        </div>

                        <div class="form-group">
                            <label>Session</label>
                            <asp:DropDownList ID="ddlSession" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlSession_SelectedIndexChanged" />
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Course Code and Name</label>
                            <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control" />
                        </div>
                    </div>

                    <div class="report-actions">
                        <asp:Button ID="btnGenerate" runat="server" Text="Generate Report" CssClass="btn btn-primary" OnClick="btnGenerate_Click" />
                        <asp:Button ID="btnClear" runat="server" Text="Clear Filter" CssClass="btn btn-outline" OnClick="btnClear_Click" CausesValidation="false" />
                        <asp:Button ID="btnBack" runat="server" Text="Back to Reports" CssClass="btn btn-outline" OnClick="btnBack_Click" CausesValidation="false" />
                    </div>
                </div>
            </div>

            <asp:Panel ID="pnlReport" runat="server" Visible="false" CssClass="report-section">
                <div class="report-header-box">
                    <strong>Attendance Report</strong><br />
                    Programme: <asp:Label ID="lblProgramme" runat="server" /><br />
                    Session: <asp:Label ID="lblSession" runat="server" /><br />
                    Course: <asp:Label ID="lblCourse" runat="server" />
                </div>

                <asp:Panel ID="pnlSummary" runat="server" CssClass="summary-grid">
                    <div class="summary-card"><div class="label">Total Students</div><div class="value"><asp:Label ID="lblTotalStudents" runat="server" /></div></div>
                    <div class="summary-card"><div class="label">Total Classes</div><div class="value"><asp:Label ID="lblTotalClasses" runat="server" /></div></div>
                    <div class="summary-card"><div class="label">Average Attendance</div><div class="value"><asp:Label ID="lblAverageAttendance" runat="server" /></div></div>
                    <div class="summary-card"><div class="label">Course</div><div class="value"><asp:Label ID="lblCourseCode" runat="server" /></div></div>
                </asp:Panel>

                <div class="report-actions">
                    <asp:Button ID="btnExportCsv" runat="server" Text="Export CSV" CssClass="btn btn-outline" OnClick="btnExportCsv_Click" />
                    <asp:Button ID="btnExportExcel" runat="server" Text="Export Excel" CssClass="btn btn-outline" OnClick="btnExportExcel_Click" />
                    <asp:Button ID="btnExportPdf" runat="server" Text="Export PDF" CssClass="btn btn-outline" OnClick="btnExportPdf_Click" />
                    <asp:Button ID="btnPrint" runat="server" Text="Print" CssClass="btn btn-outline" OnClientClick="window.print(); return false;" />
                </div>

                <div class="section-title"><i class="fa-solid fa-calendar-days"></i> Attendance Date Summary</div>
                <div class="table-scroll">
                    <asp:GridView ID="gvDateSummary" runat="server" CssClass="orange-grid" AutoGenerateColumns="true" GridLines="None" />
                </div>

                <div class="section-title"><i class="fa-solid fa-table"></i> Report Details</div>
                <div class="table-scroll">
                    <asp:GridView ID="gvReport" runat="server" CssClass="orange-grid" AutoGenerateColumns="true" GridLines="None" OnRowDataBound="gvReport_RowDataBound" />
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
                No records found for the selected filter.
            </asp:Panel>
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
