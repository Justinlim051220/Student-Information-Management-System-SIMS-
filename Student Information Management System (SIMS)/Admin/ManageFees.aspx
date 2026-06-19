<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageFees.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.Admin_ManageFees" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Manage Fees - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />
    <style>
        h2.page-title { margin-bottom:25px; }
        .fee-note { background:#fff8e1; border:1px solid #f0d38a; border-radius:14px; padding:15px 18px; margin-bottom:24px; color:#555; line-height:1.6; }
        .status-badge { padding:6px 12px; border-radius:50px; font-size:12px; font-weight:700; display:inline-block; }
        .status-pending { background:#fff8e1; color:#b7791f; border:1px solid #f0d38a; }
        .status-paid { background:#e7f8ee; color:#16803a; border:1px solid #a9e7bf; }
        .status-rejected { background:#fdecec; color:#c53030; border:1px solid #f5b5b5; }
        .action-row { display:flex; gap:10px; flex-wrap:wrap; align-items:center; }
        .action-btn { display:inline-flex; align-items:center; justify-content:center; gap:7px; min-width:86px; padding:8px 14px; border-radius:50px; font-weight:700; font-size:12px; cursor:pointer; text-decoration:none; border:2px solid transparent; transition:all .18s ease; background:#fff; }
        .approve-btn { color:#16803a; border-color:#16803a; }
        .approve-btn:hover { background:#16803a; color:#fff; }
        .reject-btn { color:#c53030; border-color:#c53030; }
        .reject-btn:hover { background:#c53030; color:#fff; }
        .suspend-btn { color:#7c2d12; border-color:#f97316; }
        .suspend-btn:hover { background:#f97316; color:#fff; }
        .unsuspend-btn { color:#166534; border-color:#22c55e; }
        .unsuspend-btn:hover { background:#22c55e; color:#fff; }
        .edit-btn { color:#e8a838; border-color:#e8a838; }
        .edit-btn:hover { background:#e8a838; color:#fff; }
        .delete-btn { color:#e8a838; border-color:#e8a838; }
        .delete-btn:hover { background:#e8a838; color:#fff; }
        #customModalOverlay { display:none; position:fixed; inset:0; background:rgba(30,30,40,.60); z-index:9999; justify-content:center; align-items:center; }
        #customModalOverlay.active { display:flex; }
        #customModal { background:#fff; border-radius:16px; width:100%; max-width:400px; padding:36px 32px 28px; box-shadow:0 12px 40px rgba(0,0,0,.28); text-align:center; }
        #customModal .cm-icon-wrap { width:68px; height:68px; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 16px; background:#fff8e1; }
        #customModal svg { width:32px; height:32px; display:block; }
        #customModal .cm-title { font-size:1.2rem; font-weight:700; color:#1a1a2e; margin-bottom:14px; }
        #customModal .cm-divider { border:none; border-top:1px solid #ececec; margin:0 -32px 18px; }
        #customModal .cm-body { font-size:.97rem; line-height:1.65; color:#555; margin-bottom:28px; }
        #customModal .cm-actions { display:flex; gap:12px; justify-content:center; flex-wrap:wrap; }
        #customModal .cm-btn { padding:10px 32px; border-radius:50px; font-size:.95rem; font-weight:600; cursor:pointer; transition:all .18s; min-width:110px; background:transparent; border:2px solid #e8a838; color:#e8a838; }
        #customModal .cm-btn:hover { background:#fdf3e0; }
        #customModal .cm-btn-danger { border-color:#dc3545; color:#dc3545; }
        #customModal .cm-btn-danger:hover { background:#dc3545; color:#fff; }
        #customModal .cm-btn-muted { border-color:#9ca3af; color:#4b5563; }
        #customModal .cm-btn-muted:hover { background:#f3f4f6; }
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }

        .status-paid {
            background: #d4edda;
            color: #155724;
        }

        .status-pending {
            background: #fff3cd;
            color: #856404;
        }

        .status-overdue {
            background: #f8d7da;
            color: #721c24;
        }


        .course-list { line-height:1.65; min-width:260px; }
        .course-line { padding:4px 0; border-bottom:1px dashed #eee; }
        .course-line:last-child { border-bottom:none; }
        .course-code { font-weight:700; color:#1f2937; margin-right:8px; }
        .course-name { color:#4b5563; }
        .course-fee { color:#b7791f; font-weight:700; margin-left:8px; white-space:nowrap; }
        .receipt-link { display:inline-flex; align-items:center; gap:7px; padding:7px 12px; border:1px solid #e8a838; color:#b7791f; border-radius:50px; text-decoration:none; font-weight:700; font-size:12px; background:#fffaf0; }
        .receipt-link:hover { background:#e8a838; color:#fff; }
        .receipt-empty { color:#9ca3af; font-size:12px; font-weight:600; }

        .status-rejected {
            background: #e2e3e5;
            color: #383d41;
        }

        .status-not-active {
            background: #eef2f7;
            color: #475569;
            border: 1px solid #d7dee8;
        }

        .status-suspended {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .status-active-account {
            background: #e7f8ee;
            color: #16803a;
            border: 1px solid #a9e7bf;
        }

        .suspension-reason {
            display: block;
            margin-top: 6px;
            font-size: 12px;
            color: #64748b;
            font-weight: 600;
            line-height: 1.4;
        }

        .no-admin-action {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 8px 14px;
            border-radius: 50px;
            background: #f3f6fa;
            color: #475569;
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
        }


        /* ===== Professional grouped fee/payment tables ===== */
        .filter-panel {
            display: grid;
            grid-template-columns: minmax(150px, 1fr) minmax(220px, 1.25fr) minmax(145px, .9fr) minmax(240px, 1.35fr) auto auto;
            gap: 14px;
            align-items: end;
            margin-bottom: 18px;
            padding: 16px 18px;
            border: 1px solid #edf0f6;
            background: #fafafa;
            border-radius: 18px;
        }
        .filter-panel .form-group { margin-bottom: 0; }
        .filter-panel label { margin-bottom: 7px; }
        .filter-button-group .btn {
            height: 44px;
            min-width: 105px;
            padding: 0 20px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            white-space: nowrap;
        }
        .filter-button-group label { visibility: hidden; }
        .session-group-row td,
        .session-group-row th {
            background: #fff8e7 !important;
            color: #9a650f !important;
            font-weight: 800 !important;
            font-size: 13px !important;
            letter-spacing: .2px;
            padding: 12px 18px !important;
            border-top: 2px solid #f1d18b !important;
            border-bottom: 1px solid #f1d18b !important;
        }
        .payment-ref-box { min-width: 140px; }
        .payment-ref-main { font-weight: 800; color: #1f2937; margin-bottom: 4px; }
        .payment-ref-sub { font-size: 12px; color: #64748b; font-weight: 600; }
        .student-pay-box { min-width: 170px; }
        .student-pay-name { font-weight: 800; color: #1f2937; margin-bottom: 4px; }
        .student-pay-meta { font-size: 12px; color: #64748b; font-weight: 600; }
        .amount-status-box { display:flex; flex-direction:column; gap:8px; min-width: 150px; }
        .amount-line { font-size: 15px; font-weight: 900; color: #1f2937; }
        .paid-date-line { font-size: 12px; color: #64748b; font-weight: 600; }
        .table-subtitle-small { color:#64748b; font-size:13px; font-weight:600; margin-top:4px; }
        .data-table th { white-space: nowrap; }
        .data-table td { vertical-align: top; }


        /* ===== Grouped Course Fee Table ===== */
        .course-fee-filter-panel {
            display: grid;
            grid-template-columns: minmax(160px, 1fr) minmax(230px, 1.25fr) minmax(250px, 1.35fr) auto auto;
            gap: 14px;
            align-items: end;
            margin: 24px 0 18px;
            padding: 16px 18px;
            border: 1px solid #edf0f6;
            background: #fafafa;
            border-radius: 18px;
        }
        .course-fee-filter-panel .form-group { margin-bottom: 0; }
        .course-fee-filter-panel label { margin-bottom: 7px; }
        .course-fee-groups { display: flex; flex-direction: column; gap: 16px; }
        .course-fee-group-card {
            border: 1px solid #edf0f6;
            border-radius: 18px;
            overflow: hidden;
            background: #fff;
            box-shadow: 0 8px 22px rgba(15, 23, 42, 0.04);
        }
        .course-fee-group-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            padding: 16px 18px;
            background: #fff8e7;
            border-bottom: 1px solid #f1d18b;
        }
        .course-fee-group-title {
            font-size: 15px;
            font-weight: 900;
            color: #1f2937;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .course-fee-group-subtitle {
            margin-top: 4px;
            font-size: 12px;
            font-weight: 700;
            color: #8a5a0a;
        }
        .course-fee-group-total {
            text-align: right;
            font-size: 12px;
            font-weight: 700;
            color: #64748b;
            white-space: nowrap;
        }
        .course-fee-group-total strong {
            display: block;
            font-size: 18px;
            color: #1f2937;
            margin-top: 4px;
        }
        .course-fee-mini-table {
            width: 100%;
            border-collapse: collapse;
        }
        .course-fee-mini-table th {
            background: #f8fafc;
            color: #334155;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: .04em;
            padding: 12px 16px;
            text-align: left;
            border-bottom: 1px solid #e5e7eb;
            white-space: nowrap;
        }
        .course-fee-mini-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #edf0f6;
            vertical-align: middle;
        }
        .course-fee-mini-table tr:last-child td { border-bottom: none; }
        .course-code-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 10px;
            border-radius: 999px;
            background: #f3f6fa;
            color: #1f2937;
            font-weight: 800;
            font-size: 12px;
            white-space: nowrap;
        }
        .course-fee-name { font-weight: 750; color: #1f2937; }
        .course-fee-amount { font-weight: 900; color: #b7791f; white-space: nowrap; }
        .empty-state {
            padding: 22px;
            border: 1px dashed #d7dee8;
            border-radius: 18px;
            color: #64748b;
            font-weight: 700;
            text-align: center;
            background: #fafafa;
        }
        @media(max-width: 1100px) {
            .course-fee-filter-panel { grid-template-columns: repeat(2, minmax(180px, 1fr)); }
            .course-fee-group-header { flex-direction: column; align-items: flex-start; }
            .course-fee-group-total { text-align: left; }
        }
        @media(max-width: 700px) {
            .course-fee-filter-panel { grid-template-columns: 1fr; }
            .course-fee-mini-table th:nth-child(3),
            .course-fee-mini-table td:nth-child(3) { display: none; }
        }

        @media(max-width: 1250px) {
            .filter-panel { grid-template-columns: repeat(3, minmax(180px, 1fr)); }
            .filter-button-group .btn { width: 100%; }
        }
        @media(max-width: 800px) {
            .filter-panel { grid-template-columns: 1fr; }
            .filter-button-group label { display: none; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <div class="page-content">
        <h2 class="page-title"><i class="fa-solid fa-money-bill-wave"></i> Manage Fees</h2>


        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fa-solid fa-clock"></i></div>
                <div><div class="stat-value">RM <asp:Label ID="lblPendingAmount" runat="server" Text="0.00" /></div><div class="stat-label">Pending Fees</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="fa-solid fa-check"></i></div>
                <div><div class="stat-value">RM <asp:Label ID="lblPaidAmount" runat="server" Text="0.00" /></div><div class="stat-label">Approved / Paid</div></div>
            </div>
        </div>

        <div class="card" style="margin-bottom:30px;">
            <div class="card-header"><span class="card-title"><i class="fa-solid fa-tags"></i> Manage Course Fee</span></div>
            <div class="card-body">
                <asp:HiddenField ID="hfCourseFeeId" runat="server" />
                <asp:HiddenField ID="hfDeleteCourseFeeId" runat="server" />
                <div class="grid-2">
                    <div class="form-group">
                        <label>Programme</label>
                        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" />
                    </div>
                    <div class="form-group">
                        <label>Course</label>
                        <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="grid-2">
                    <div class="form-group">
                        <label>Session</label>
                        <asp:DropDownList ID="ddlFeeSession" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label>Amount (RM)</label>
                        <asp:TextBox ID="txtAmount" runat="server" CssClass="form-control" TextMode="Number" placeholder="e.g. 1200.00" />
                    </div>
                </div>
                <div style="margin-top:20px; display:flex; gap:12px; flex-wrap:wrap;">
                    <asp:Button ID="btnSaveCourseFee" runat="server" Text="Save Course Fee" CssClass="btn btn-primary" OnClick="btnSaveCourseFee_Click" />
                    <asp:Button ID="btnClearCourseFee" runat="server" Text="Clear" CssClass="btn btn-outline" OnClick="btnClearCourseFee_Click" CausesValidation="false" />
                    <asp:Button ID="btnBack" runat="server" Text="Back to Dashboard" CssClass="btn btn-outline" OnClick="btnBack_Click" CausesValidation="false" />
                    <asp:Button ID="btnConfirmDeleteCourseFee" runat="server" Text="Confirm Delete" OnClick="btnConfirmDeleteCourseFee_Click" CausesValidation="false" Style="display:none;" />
                </div>

                <div class="course-fee-filter-panel">
                    <div class="form-group">
                        <label>Session</label>
                        <asp:DropDownList ID="ddlCourseFeeFilterSession" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlCourseFeeFilterSession_SelectedIndexChanged" />
                    </div>
                    <div class="form-group">
                        <label>Programme</label>
                        <asp:DropDownList ID="ddlCourseFeeFilterProgramme" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlCourseFeeFilterProgramme_SelectedIndexChanged" />
                    </div>
                    <div class="form-group">
                        <label>Search</label>
                        <asp:TextBox ID="txtCourseFeeSearch" runat="server" CssClass="form-control" placeholder="Course code / course name" />
                    </div>
                    <div class="form-group filter-button-group">
                        <label>Search Button</label>
                        <asp:Button ID="btnSearchCourseFee" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearchCourseFee_Click" CausesValidation="false" />
                    </div>
                    <div class="form-group filter-button-group">
                        <label>Reset Button</label>
                        <asp:Button ID="btnResetCourseFeeFilter" runat="server" Text="Reset" CssClass="btn btn-outline" OnClick="btnResetCourseFeeFilter_Click" CausesValidation="false" />
                    </div>
                </div>

                <asp:Panel ID="pnlNoCourseFees" runat="server" CssClass="empty-state" Visible="false">
                    No course fee records found for the selected filter.
                </asp:Panel>

                <div class="course-fee-groups">
                    <asp:Repeater ID="rptCourseFeeGroups" runat="server" OnItemDataBound="rptCourseFeeGroups_ItemDataBound">
                        <ItemTemplate>
                            <div class="course-fee-group-card">
                                <div class="course-fee-group-header">
                                    <div>
                                        <div class="course-fee-group-title">
                                            <i class="fa-solid fa-calendar-days"></i>
                                            <%# Eval("Session") %> · <%# Eval("ProgrammeCode") %>
                                        </div>
                                        <div class="course-fee-group-subtitle"><%# Eval("ProgrammeName") %> · <%# Eval("CourseCount") %> course(s)</div>
                                    </div>
                                    <div class="course-fee-group-total">
                                        Total course fee value
                                        <strong>RM <%# Eval("TotalAmount", "{0:N2}") %></strong>
                                    </div>
                                </div>
                                <asp:HiddenField ID="hfGroupSession" runat="server" Value='<%# Eval("Session") %>' />
                                <asp:HiddenField ID="hfGroupProgrammeId" runat="server" Value='<%# Eval("ProgrammeId") %>' />
                                <asp:Repeater ID="rptCourseFeeItems" runat="server" OnItemCommand="rptCourseFeeItems_ItemCommand">
                                    <HeaderTemplate>
                                        <table class="course-fee-mini-table">
                                            <thead>
                                                <tr>
                                                    <th>Code</th>
                                                    <th>Course</th>
                                                    <th>Amount (RM)</th>
                                                    <th>Action</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                                <tr>
                                                    <td><span class="course-code-pill"><%# Eval("CourseCode") %></span></td>
                                                    <td><div class="course-fee-name"><%# Eval("CourseName") %></div></td>
                                                    <td><span class="course-fee-amount">RM <%# Eval("Amount", "{0:N2}") %></span></td>
                                                    <td>
                                                        <div class="action-row">
                                                            <asp:LinkButton ID="btnEditFee" runat="server" CssClass="action-btn edit-btn" CommandName="EditFee" CommandArgument='<%# Eval("CourseFeeId") %>'><i class="fa-solid fa-pen-to-square"></i> Edit</asp:LinkButton>
                                                            <asp:LinkButton ID="btnDeleteFee" runat="server" CssClass="action-btn delete-btn" CommandName="DeleteFee" CommandArgument='<%# Eval("CourseFeeId") %>' OnClientClick='<%# "showDeleteConfirm(\"" + Eval("CourseFeeId") + "\"); return false;" %>'><i class="fa-solid fa-trash"></i> Delete</asp:LinkButton>
                                                        </div>
                                                    </td>
                                                </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                            </tbody>
                                        </table>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <div>
                    <span class="card-title"><i class="fa-solid fa-receipt"></i> Student Payment Records</span>
                    <div class="table-subtitle-small">Records are grouped by session. Each enrolled course remains as its own payment row for clear audit history.</div>
                </div>
            </div>
            <div class="card-body">
                <div class="filter-panel">
                    <div class="form-group">
                        <label>Session</label>
                        <asp:DropDownList ID="ddlPaymentSession" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlPaymentSession_SelectedIndexChanged" />
                    </div>
                    <div class="form-group">
                        <label>Programme</label>
                        <asp:DropDownList ID="ddlPaymentProgramme" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlPaymentProgramme_SelectedIndexChanged" />
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                            <asp:ListItem Text="Pending" Value="Pending" />
                            <asp:ListItem Text="Paid" Value="Paid" />
                            <asp:ListItem Text="Rejected" Value="Rejected" />
                            <asp:ListItem Text="Overdue" Value="Overdue" />
                            <asp:ListItem Text="Not Active" Value="Not Active" />
                            <asp:ListItem Text="All" Value="" />
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>Search</label>
                        <asp:TextBox ID="txtPaymentSearch" runat="server" CssClass="form-control" placeholder="Student / payment / course" />
                    </div>
                    <div class="form-group filter-button-group">
                        <label>Search Button</label>
                        <asp:Button ID="btnSearchPayment" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearchPayment_Click" />
                    </div>
                    <div class="form-group filter-button-group">
                        <label>Reset Button</label>
                        <asp:Button ID="btnResetPaymentFilter" runat="server" Text="Reset" CssClass="btn btn-outline" OnClick="btnResetPaymentFilter_Click" CausesValidation="false" />
                    </div>
                </div>

                <div class="table-wrapper">
                    <asp:GridView ID="gvPayments" runat="server" CssClass="data-table" AutoGenerateColumns="false" EmptyDataText="No fee records found." OnRowCommand="gvPayments_RowCommand" OnRowDataBound="gvPayments_RowDataBound">
                        <Columns>
                            <asp:TemplateField HeaderText="Payment">
                                <ItemTemplate>
                                    <div class="payment-ref-box">
                                        <div class="payment-ref-main"><%# Eval("PaymentRef") %></div>
                                        <div class="payment-ref-sub"><%# Eval("Session") %></div>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Student">
                                <ItemTemplate>
                                    <div class="student-pay-box">
                                        <div class="student-pay-name"><%# Eval("StudentName") %></div>
                                        <div class="student-pay-meta"><%# Eval("StudentId") %> · <%# Eval("ProgrammeCode") %></div>
                                        <asp:Label ID="lblAccountStatus" runat="server"
                                            Text='<%# GetAccountStatusText(Eval("IsSuspended")) %>'
                                            CssClass='<%# "status-badge " + GetAccountStatusCss(Eval("IsSuspended")) %>' />
                                        <%# GetSuspensionReason(Eval("IsSuspended"), Eval("SuspensionReason")) %>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Course / Fee Item">
                                <ItemTemplate>
                                    <div class="course-list">
                                        <%# Eval("CoursePaymentList") %>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Amount / Status">
                                <ItemTemplate>
                                    <div class="amount-status-box">
                                        <div class="amount-line">RM <%# Eval("DisplayAmount", "{0:N2}") %></div>
                                        <asp:Label ID="lblStatus" runat="server"
                                            Text='<%# Eval("DisplayStatus") %>'
                                            CssClass='<%# "status-badge " + GetStatusCss(Eval("DisplayStatus")) %>' />
                                        <div class="paid-date-line"><%# FormatPaymentDate(Eval("PaymentDate")) %></div>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Receipt">
                                <ItemTemplate>
                                    <%# GetReceiptLink(Eval("PaymentReceiptPath")) %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <div class="action-row">
                                        <asp:LinkButton ID="btnApprove" runat="server" CssClass="action-btn approve-btn" CommandName="ApprovePayment" CommandArgument='<%# Eval("FeeId") %>'><i class="fa-solid fa-check"></i> Approve</asp:LinkButton>
                                        <asp:LinkButton ID="btnReject" runat="server" CssClass="action-btn reject-btn" CommandName="RejectPayment" CommandArgument='<%# Eval("FeeId") %>'><i class="fa-solid fa-xmark"></i> Reject</asp:LinkButton>
                                        <asp:LinkButton ID="btnSuspend" runat="server" CssClass="action-btn suspend-btn" CommandName="SuspendStudent" CommandArgument='<%# Eval("StudentId") %>'><i class="fa-solid fa-user-lock"></i> Suspend</asp:LinkButton>
                                        <asp:LinkButton ID="btnUnsuspend" runat="server" CssClass="action-btn unsuspend-btn" CommandName="UnsuspendStudent" CommandArgument='<%# Eval("StudentId") %>'><i class="fa-solid fa-user-check"></i> Unsuspend</asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

    <div id="customModalOverlay"><div id="customModal"><div class="cm-icon-wrap"><span id="cmIcon"></span></div><div class="cm-title" id="cmTitle">Message</div><hr class="cm-divider" /><div class="cm-body" id="cmBody"></div><div class="cm-actions" id="cmActions"><button type="button" class="cm-btn" onclick="closeCustomModal()">OK</button></div></div></div>
    <script>
        var SVG_TICK = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
        var SVG_WARN = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
        function showMessageModal(title, message) {
            document.getElementById('cmIcon').innerHTML = title.indexOf('Warning') >= 0 || title.indexOf('Error') >= 0 ? SVG_WARN : SVG_TICK;
            document.getElementById('cmTitle').innerHTML = title;
            document.getElementById('cmBody').innerHTML = message;
            document.getElementById('cmActions').innerHTML = '<button type="button" class="cm-btn" onclick="closeCustomModal()">OK</button>';
            document.getElementById('customModalOverlay').classList.add('active');
        }
        function showDeleteConfirm(courseFeeId) {
            document.getElementById('<%= hfDeleteCourseFeeId.ClientID %>').value = courseFeeId;
            document.getElementById('cmIcon').innerHTML = SVG_WARN;
            document.getElementById('cmTitle').innerHTML = 'Confirm Delete';
            document.getElementById('cmBody').innerHTML = 'Are you sure you want to delete this course fee?';
            document.getElementById('cmActions').innerHTML = '<button type="button" class="cm-btn cm-btn-muted" onclick="closeCustomModal()">Cancel</button><button type="button" class="cm-btn cm-btn-danger" onclick="confirmDeleteCourseFee()">Delete</button>';
            document.getElementById('customModalOverlay').classList.add('active');
        }
        function confirmDeleteCourseFee() {
            closeCustomModal();
            document.getElementById('<%= btnConfirmDeleteCourseFee.ClientID %>').click();
        }
        function closeCustomModal() { document.getElementById('customModalOverlay').classList.remove('active'); }
    </script>
</form>
</body>
</html>
