<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AttendanceReport.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.Admin.AttendanceReport" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Detailed Attendance Report - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />
    <style>
        .filter-card{margin-bottom:26px;}
        .report-actions{display:flex;gap:12px;flex-wrap:wrap;align-items:center;margin-top:18px;}
        .report-info-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px;margin-bottom:22px;}
        .info-item{background:#f8fafc;border:1px solid #e5e7eb;border-radius:14px;padding:14px 16px;}
        .info-label{font-size:12px;text-transform:uppercase;letter-spacing:.04em;color:#64748b;font-weight:800;margin-bottom:5px;}
        .info-value{font-weight:800;color:#1a1a2e;}
        .mini-stats{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px;margin:20px 0 24px;}
        .mini-card{background:#fff;border:1px solid #edf0f5;border-radius:18px;padding:18px;box-shadow:0 6px 20px rgba(15,23,42,.06);display:flex;align-items:center;gap:14px;}
        .mini-icon{width:46px;height:46px;border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:20px;}
        .mini-icon.orange{background:#fff1db;color:#e8a838;}.mini-icon.green{background:#dcfce7;color:#16a34a;}.mini-icon.blue{background:#dbeafe;color:#2563eb;}.mini-icon.red{background:#fee2e2;color:#dc2626;}
        .mini-value{font-size:24px;font-weight:900;color:#111827;line-height:1;}.mini-label{font-size:12px;color:#64748b;font-weight:800;margin-top:6px;}
        .section-title{display:flex;align-items:center;gap:9px;font-weight:900;color:#1a1a2e;margin:24px 0 12px;font-size:1.05rem;}
        .matrix-scroll{overflow:auto;border:1px solid #e5e7eb;border-radius:16px;background:#fff;}
        .matrix-grid{width:100%;border-collapse:collapse;min-width:850px;}
        .matrix-grid th{background:#e8a838;color:#fff;font-size:12px;text-transform:uppercase;letter-spacing:.03em;padding:13px 12px;text-align:left;white-space:nowrap;}
        .matrix-grid td{padding:12px;border-bottom:1px solid #edf0f5;color:#374151;font-size:13px;white-space:nowrap;}
        .matrix-grid tr:hover td{background:#fffaf0;}
        .status-pill{display:inline-flex;align-items:center;justify-content:center;min-width:34px;border-radius:999px;padding:5px 9px;font-weight:900;font-size:12px;}
        .status-present{background:#dcfce7;color:#15803d;}.status-absent{background:#fee2e2;color:#b91c1c;}.status-late{background:#ffedd5;color:#c2410c;}.status-empty{background:#f1f5f9;color:#64748b;}
        .risk-badge{display:inline-block;border-radius:999px;padding:6px 12px;font-size:12px;font-weight:900;background:#fee2e2;color:#b91c1c;}
        .safe-badge{display:inline-block;border-radius:999px;padding:6px 12px;font-size:12px;font-weight:900;background:#dcfce7;color:#15803d;}
        .export-btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;border-radius:50px;padding:10px 18px;font-weight:800;font-size:13px;border:2px solid #e8a838;background:#fff;color:#e8a838;cursor:pointer;transition:all .18s ease;text-decoration:none;}
        .export-btn:hover{background:#e8a838;color:#fff;}
        .empty-state{background:#f8fafc;border:1px dashed #cbd5e1;color:#64748b;border-radius:14px;padding:22px;line-height:1.7;margin-top:20px;}
        #customModalOverlay{display:none;position:fixed;inset:0;background:rgba(30,30,40,.60);z-index:9999;justify-content:center;align-items:center;}
        #customModalOverlay.active{display:flex;}
        #customModal{background:#fff;border-radius:16px;width:100%;max-width:400px;padding:36px 32px 28px;box-shadow:0 12px 40px rgba(0,0,0,.28);text-align:center;}
        #customModal .cm-icon-wrap{width:68px;height:68px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 16px;background:#fff8e1;color:#e8a838;font-size:28px;}
        #customModal .cm-title{font-size:1.2rem;font-weight:800;color:#1a1a2e;margin-bottom:14px;}
        #customModal .cm-divider{border:none;border-top:1px solid #ececec;margin:0 -32px 18px;}
        #customModal .cm-body{font-size:.97rem;line-height:1.65;color:#555;margin-bottom:28px;}
        #customModal .cm-btn{padding:10px 32px;border-radius:50px;font-size:.95rem;font-weight:700;cursor:pointer;transition:all .18s;min-width:110px;background:transparent;border:2px solid #e8a838;color:#e8a838;}
        #customModal .cm-btn:hover{background:#fdf3e0;}
        @media(max-width:900px){.report-info-grid,.mini-stats{grid-template-columns:1fr;}}
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <div class="page-content">
        <h2 class="page-title"><i class="fa-solid fa-calendar-check"></i> Detailed Attendance Report</h2>

        <div class="card filter-card">
            <div class="card-header">
                <span class="card-title"><i class="fa-solid fa-filter"></i> Report Filter</span>
            </div>
            <div class="card-body">
                <div class="grid-2">
                    <div class="form-group">
                        <label>Session</label>
                        <asp:DropDownList ID="ddlSession" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label>Programme</label>
                        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="grid-2">
                    <div class="form-group">
                        <label>Course Code and Name</label>
                        <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label>&nbsp;</label>
                        <div class="report-actions" style="margin-top:0;">
                            <asp:Button ID="btnGenerate" runat="server" Text="Generate Report" CssClass="btn btn-primary" OnClick="btnGenerate_Click" />
                            <asp:Button ID="btnClear" runat="server" Text="Clear Filter" CssClass="btn btn-outline" CausesValidation="false" OnClick="btnClear_Click" />
                            <asp:Button ID="btnBack" runat="server" Text="Back to Reports" CssClass="btn btn-outline" CausesValidation="false" OnClick="btnBack_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <asp:Panel ID="pnlReport" runat="server" Visible="false">
            <div class="card">
                <div class="card-header">
                    <span class="card-title"><i class="fa-solid fa-circle-info"></i> Course Information</span>
                    <span class="status-pill status-empty"><asp:Label ID="lblGeneratedAt" runat="server" Text="Not generated" /></span>
                </div>
                <div class="card-body">
                    <div class="report-info-grid">
                        <div class="info-item"><div class="info-label">Course Code</div><div class="info-value"><asp:Label ID="lblCourseCode" runat="server" /></div></div>
                        <div class="info-item"><div class="info-label">Course Name</div><div class="info-value"><asp:Label ID="lblCourseName" runat="server" /></div></div>
                        <div class="info-item"><div class="info-label">Programme</div><div class="info-value"><asp:Label ID="lblProgramme" runat="server" /></div></div>
                        <div class="info-item"><div class="info-label">Session</div><div class="info-value"><asp:Label ID="lblSession" runat="server" /></div></div>
                    </div>

                    <div class="mini-stats">
                        <div class="mini-card"><div class="mini-icon orange"><i class="fa-solid fa-users"></i></div><div><div class="mini-value"><asp:Label ID="lblTotalStudents" runat="server" Text="0" /></div><div class="mini-label">Total Students</div></div></div>
                        <div class="mini-card"><div class="mini-icon blue"><i class="fa-solid fa-calendar-days"></i></div><div><div class="mini-value"><asp:Label ID="lblTotalClasses" runat="server" Text="0" /></div><div class="mini-label">Total Classes</div></div></div>
                        <div class="mini-card"><div class="mini-icon green"><i class="fa-solid fa-chart-line"></i></div><div><div class="mini-value"><asp:Label ID="lblAverageAttendance" runat="server" Text="0%" /></div><div class="mini-label">Average Attendance</div></div></div>
                    </div>

                    <div class="report-actions" style="margin-top:0; margin-bottom:18px;">
                        <asp:LinkButton ID="btnExportCsv" runat="server" CssClass="export-btn" OnClick="btnExportCsv_Click"><i class="fa-solid fa-file-csv"></i> Export CSV</asp:LinkButton>
                        <asp:LinkButton ID="btnExportExcel" runat="server" CssClass="export-btn" OnClick="btnExportExcel_Click"><i class="fa-solid fa-file-excel"></i> Export Excel</asp:LinkButton>
                        <asp:LinkButton ID="btnExportPdf" runat="server" CssClass="export-btn" OnClick="btnExportPdf_Click"><i class="fa-solid fa-file-pdf"></i> Export PDF</asp:LinkButton>
                    </div>

                    <div class="section-title"><i class="fa-solid fa-calendar-day"></i> Attendance Date Summary</div>
                    <div class="matrix-scroll">
                        <asp:GridView ID="gvDateSummary" runat="server" CssClass="matrix-grid" AutoGenerateColumns="true" EmptyDataText="No attendance dates found." />
                    </div>

                    <div class="section-title"><i class="fa-solid fa-table"></i> Student Attendance Matrix</div>
                    <div class="matrix-scroll">
                        <asp:GridView ID="gvMatrix" runat="server" CssClass="matrix-grid" AutoGenerateColumns="true" OnRowDataBound="gvMatrix_RowDataBound" EmptyDataText="No enrolled students found for this filter." />
                    </div>

                </div>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state">
            Please select a session, programme, and course, then click <strong>Generate Report</strong>.
        </asp:Panel>
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
