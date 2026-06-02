<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Reports.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.Admin.Reports" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Reports - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />
    <style>
        .report-note {
            background:#fff8e1;
            border:1px solid #f0d38a;
            border-radius:14px;
            padding:15px 18px;
            margin-bottom:24px;
            color:#555;
            line-height:1.6;
        }
        .filter-card { margin-bottom:26px; }
        .report-actions {
            display:flex;
            gap:12px;
            flex-wrap:wrap;
            align-items:center;
            margin-top:18px;
        }
        .export-btn {
            display:inline-flex;
            align-items:center;
            justify-content:center;
            gap:8px;
            border-radius:50px;
            padding:10px 18px;
            font-weight:700;
            font-size:13px;
            border:2px solid #e8a838;
            background:#fff;
            color:#e8a838;
            cursor:pointer;
            transition:all .18s ease;
        }
        .export-btn:hover { background:#e8a838; color:#fff; }
        .coming-soon {
            background:#f8fafc;
            border:1px dashed #cbd5e1;
            color:#64748b;
            border-radius:14px;
            padding:22px;
            line-height:1.7;
            margin-top:20px;
        }
        .table-wrapper { margin-top:22px; }
        .status-badge {
            display:inline-block;
            border-radius:50px;
            padding:6px 12px;
            font-size:12px;
            font-weight:700;
            background:#eef2ff;
            color:#3730a3;
        }
        #customModalOverlay { display:none; position:fixed; inset:0; background:rgba(30,30,40,.60); z-index:9999; justify-content:center; align-items:center; }
        #customModalOverlay.active { display:flex; }
        #customModal { background:#fff; border-radius:16px; width:100%; max-width:400px; padding:36px 32px 28px; box-shadow:0 12px 40px rgba(0,0,0,.28); text-align:center; }
        #customModal .cm-icon-wrap { width:68px; height:68px; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 16px; background:#fff8e1; color:#e8a838; font-size:28px; }
        #customModal .cm-title { font-size:1.2rem; font-weight:700; color:#1a1a2e; margin-bottom:14px; }
        #customModal .cm-divider { border:none; border-top:1px solid #ececec; margin:0 -32px 18px; }
        #customModal .cm-body { font-size:.97rem; line-height:1.65; color:#555; margin-bottom:28px; }
        #customModal .cm-btn { padding:10px 32px; border-radius:50px; font-size:.95rem; font-weight:600; cursor:pointer; transition:all .18s; min-width:110px; background:transparent; border:2px solid #e8a838; color:#e8a838; }
        #customModal .cm-btn:hover { background:#fdf3e0; }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <div class="page-content">
        <h2 class="page-title"><i class="fa-solid fa-chart-column"></i> Institutional Reports</h2>

        <div class="report-note">
            This page generates institutional reports for enrolment statistics and attendance summaries.
            Student performance report is prepared as a placeholder because the performance workflow is not completed yet.
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fa-solid fa-user-graduate"></i></div>
                <div>
                    <div class="stat-value"><asp:Label ID="lblTotalStudents" runat="server" Text="0" /></div>
                    <div class="stat-label">Total Students</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="fa-solid fa-file-lines"></i></div>
                <div>
                    <div class="stat-value"><asp:Label ID="lblActiveEnrollments" runat="server" Text="0" /></div>
                    <div class="stat-label">Active Enrolments</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fa-solid fa-calendar-check"></i></div>
                <div>
                    <div class="stat-value"><asp:Label ID="lblAttendanceRecords" runat="server" Text="0" /></div>
                    <div class="stat-label">Attendance Records</div>
                </div>
            </div>
        </div>

        <div class="card filter-card">
            <div class="card-header">
                <span class="card-title"><i class="fa-solid fa-filter"></i> Report Filter</span>
            </div>
            <div class="card-body">
                <div class="grid-2">
                    <div class="form-group">
                        <label>Report Type</label>
                        <asp:DropDownList ID="ddlReportType" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlReportType_SelectedIndexChanged">
                            <asp:ListItem Text="Enrolment Statistics" Value="Enrollment" />
                            <asp:ListItem Text="Attendance Summary" Value="Attendance" />
                            <asp:ListItem Text="Student Performance Report (Coming Soon)" Value="Performance" />
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>Session</label>
                        <asp:DropDownList ID="ddlSession" runat="server" CssClass="form-control" />
                    </div>
                </div>

                <div class="grid-2">
                    <div class="form-group">
                        <label>Programme</label>
                        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label>Course</label>
                        <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control" />
                    </div>
                </div>

                <div class="report-actions">
                    <asp:Button ID="btnGenerate" runat="server" Text="Generate Report" CssClass="btn btn-primary" OnClick="btnGenerate_Click" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear Filter" CssClass="btn btn-outline" OnClick="btnClear_Click" CausesValidation="false" />
                    <asp:Button ID="btnBack" runat="server" Text="Back to Dashboard" CssClass="btn btn-outline" OnClick="btnBack_Click" CausesValidation="false" />
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <span class="card-title"><i class="fa-solid fa-table"></i> <asp:Label ID="lblReportTitle" runat="server" Text="Report Result" /></span>
                <span class="status-badge"><asp:Label ID="lblGeneratedAt" runat="server" Text="Not generated" /></span>
            </div>
            <div class="card-body">
                <asp:Panel ID="pnlPerformanceComingSoon" runat="server" Visible="false" CssClass="coming-soon">
                    <strong>Student Performance Report is not available yet.</strong><br />
                    You can connect this section later after the marks, grade calculation, and GPA logic are completed.
                </asp:Panel>

                <asp:Panel ID="pnlExport" runat="server" Visible="false">
                    <div class="report-actions" style="margin-top:0; margin-bottom:12px;">
                        <asp:LinkButton ID="btnExportCsv" runat="server" CssClass="export-btn" OnClick="btnExportCsv_Click"><i class="fa-solid fa-file-csv"></i> Export CSV</asp:LinkButton>
                        <asp:LinkButton ID="btnExportExcel" runat="server" CssClass="export-btn" OnClick="btnExportExcel_Click"><i class="fa-solid fa-file-excel"></i> Export Excel</asp:LinkButton>
                        <asp:LinkButton ID="btnExportPdf" runat="server" CssClass="export-btn" OnClick="btnExportPdf_Click"><i class="fa-solid fa-file-pdf"></i> Export PDF</asp:LinkButton>
                    </div>
                </asp:Panel>

                <div class="table-wrapper">
                    <asp:GridView ID="gvReport" runat="server" CssClass="data-table" AutoGenerateColumns="true" EmptyDataText="No report data found." />
                </div>
            </div>
        </div>
    </div>

    <div id="customModalOverlay">
        <div id="customModal">
            <div class="cm-icon-wrap"><i class="fa-solid fa-circle-info"></i></div>
            <div class="cm-title" id="cmTitle">Message</div>
            <hr class="cm-divider" />
            <div class="cm-body" id="cmBody">Message body</div>
            <button type="button" class="cm-btn" onclick="closeCustomModal()">OK</button>
        </div>
    </div>

    <script>
        function showMessageModal(title, message) {
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
