<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Reports.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.Admin.Reports" EnableEventValidation="false" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Reports - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />
    <style>
        .filter-card { margin-bottom:26px; }
        .report-actions { display:flex; gap:12px; flex-wrap:wrap; align-items:center; margin-top:18px; }
        .coming-soon-note { margin-top:8px; color:#d97706; font-size:13px; font-weight:800; }
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
        #customModalOverlay { display:none; position:fixed; inset:0; background:rgba(30,30,40,.60); z-index:9999; justify-content:center; align-items:center; }
        #customModalOverlay.active { display:flex; }
        #customModal { background:#fff; border-radius:16px; width:100%; max-width:400px; padding:36px 32px 28px; box-shadow:0 12px 40px rgba(0,0,0,.28); text-align:center; }
        #customModal .cm-icon-wrap { width:68px; height:68px; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 16px; background:#fff8e1; color:#e8a838; font-size:28px; }
        #customModal .cm-title { font-size:1.2rem; font-weight:800; color:#1a1a2e; margin-bottom:14px; }
        #customModal .cm-divider { border:none; border-top:1px solid #ececec; margin:0 -32px 18px; }
        #customModal .cm-body { font-size:.97rem; line-height:1.65; color:#555; margin-bottom:28px; }
        #customModal .cm-btn { padding:10px 32px; border-radius:50px; font-size:.95rem; font-weight:700; cursor:pointer; transition:all .18s; min-width:110px; background:transparent; border:2px solid #e8a838; color:#e8a838; }
        #customModal .cm-btn:hover { background:#fdf3e0; }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <div class="page-content">
        <h2 style="margin-bottom:25px;"class="page-title"><i class="fa-solid fa-chart-column"></i> Reports</h2>
        <div class="card filter-card">
            <div class="card-header">
                <span class="card-title"><i class="fa-solid fa-filter"></i> Report Filter</span>
            </div>
            <div class="card-body">
                <div class="grid-2">
                    <div class="form-group">
                        <label>Report Type</label>
                        <asp:DropDownList ID="ddlReportType" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlReportType_SelectedIndexChanged">
                            <asp:ListItem Text="-- Select Report Type --" Value="" />
                            <asp:ListItem Text="Fee Payment Report" Value="FeePayment" />
                            <asp:ListItem Text="Enrollment Statistics Report" Value="Enrollment" />
                            <asp:ListItem Text="Attendance Report" Value="Attendance" />
                            <asp:ListItem Text="Academic Report (Coming Soon)" Value="Academic" />
                        </asp:DropDownList>
                        <asp:Panel ID="pnlAcademicSoon" runat="server" Visible="false" CssClass="coming-soon-note">
                            Academic Report is coming soon.
                        </asp:Panel>
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
                    <asp:Panel ID="pnlCourseFilter" runat="server" CssClass="form-group" Visible="false">
                        <label>Course Code and Name</label>
                        <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control" />
                    </asp:Panel>
                </div>

                <div class="report-actions">
                    <asp:Button ID="btnGenerate" runat="server" Text="Generate Report" CssClass="btn btn-primary" OnClick="btnGenerate_Click" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear Filter" CssClass="btn btn-outline" OnClick="btnClear_Click" CausesValidation="false" />
                    <asp:Button ID="btnBack" runat="server" Text="Back to Dashboard" CssClass="btn btn-outline" OnClick="btnBack_Click" CausesValidation="false" />
                </div>
            </div>
        </div>

        <asp:Panel ID="pnlReport" runat="server" Visible="false" CssClass="report-section">
            <div class="report-header-box">
                <strong><asp:Label ID="lblReportTitle" runat="server" /></strong><br />
                Session: <asp:Label ID="lblSession" runat="server" /> <br />
                Programme: <asp:Label ID="lblProgramme" runat="server" />
                <asp:Panel ID="pnlCourseInfo" runat="server" Visible="false">
                    Course: <asp:Label ID="lblCourse" runat="server" />
                </asp:Panel>
            </div>

            <asp:Panel ID="pnlSummary" runat="server" CssClass="summary-grid">
                <div class="summary-card"><div class="label"><asp:Label ID="lblSummaryLabel1" runat="server" /></div><div class="value"><asp:Label ID="lblSummaryValue1" runat="server" /></div></div>
                <div class="summary-card"><div class="label"><asp:Label ID="lblSummaryLabel2" runat="server" /></div><div class="value"><asp:Label ID="lblSummaryValue2" runat="server" /></div></div>
                <div class="summary-card"><div class="label"><asp:Label ID="lblSummaryLabel3" runat="server" /></div><div class="value"><asp:Label ID="lblSummaryValue3" runat="server" /></div></div>
                <div class="summary-card"><div class="label"><asp:Label ID="lblSummaryLabel4" runat="server" /></div><div class="value"><asp:Label ID="lblSummaryValue4" runat="server" /></div></div>
            </asp:Panel>

            <div class="report-actions">
                <asp:Button ID="btnExportCsv" runat="server" Text="Export CSV" CssClass="btn btn-outline" OnClick="btnExportCsv_Click" />
                <asp:Button ID="btnExportExcel" runat="server" Text="Export Excel" CssClass="btn btn-outline" OnClick="btnExportExcel_Click" />
                <asp:Button ID="btnExportPdf" runat="server" Text="Export PDF" CssClass="btn btn-outline" OnClick="btnExportPdf_Click" />
                <asp:Button ID="btnPrint" runat="server" Text="Print" CssClass="btn btn-outline" OnClientClick="window.print(); return false;" />
            </div>

            <asp:Panel ID="pnlDateSummary" runat="server" Visible="false">
                <div class="section-title"><i class="fa-solid fa-calendar-days"></i> Attendance Date Summary</div>
                <div class="table-scroll">
                    <asp:GridView ID="gvDateSummary" runat="server" CssClass="orange-grid" AutoGenerateColumns="true" GridLines="None" />
                </div>
            </asp:Panel>

            <div class="section-title"><i class="fa-solid fa-table"></i> Report Details</div>
            <div class="table-scroll">
                <asp:GridView ID="gvReport" runat="server" CssClass="orange-grid" AutoGenerateColumns="true" GridLines="None" OnRowDataBound="gvReport_RowDataBound" />
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
            No records found for the selected filter.
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
