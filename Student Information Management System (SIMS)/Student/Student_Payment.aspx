<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Student_Payment.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student_Payment" %>
<%@ Register Src="~/Student/StudentSidebar.ascx" TagPrefix="uc" TagName="StudentSidebar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SIMS - Student Payment</title>

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <link rel="stylesheet" href="../Styles/SIMS.css" />

    <style>
        html,
        body {
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
            z-index: 3000 !important;
            pointer-events: auto !important;
        }

        .sidebar a,
        .sidebar .sidebar-link {
            position: relative;
            z-index: 3001 !important;
            pointer-events: auto !important;
        }

        .main-wrapper {
            position: relative !important;
            z-index: 1 !important;
            margin-left: 260px !important;
            width: calc(100% - 260px) !important;
        }

        h2.page-title {
            margin-bottom: 25px;
        }

        .page-header p {
            margin-top: 6px;
            color: var(--text-secondary);
        }

        .payment-suspension-warning {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            background: linear-gradient(135deg, #fff7ed 0%, #ffffff 72%, #fff3d6 100%);
            border: 1px solid rgba(245, 166, 35, .34);
            border-left: 6px solid #f97316;
            border-radius: 22px;
            padding: 20px 22px;
            margin: 0 0 26px 0;
            box-shadow: 0 14px 32px rgba(15, 23, 42, .08);
        }

        .payment-suspension-warning-icon {
            width: 48px;
            height: 48px;
            border-radius: 16px;
            background: linear-gradient(135deg, #f59e0b, #f97316);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 21px;
            box-shadow: var(--shadow-orange);
            flex-shrink: 0;
        }

        .payment-suspension-warning-title {
            font-family: var(--font-accent);
            font-size: 17px;
            font-weight: 900;
            color: #9a3412;
            margin-bottom: 5px;
        }

        .payment-suspension-warning-text {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-secondary);
            line-height: 1.55;
        }

        .payment-suspension-warning-reason {
            margin-top: 8px;
            font-size: 13px;
            font-weight: 900;
            color: #7c2d12;
        }


        .student-info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
            gap: 18px;
            margin-bottom: 26px;
        }

        .student-info-card {
            background: var(--white);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-card);
            padding: 20px 22px;
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .student-info-icon {
            width: 48px;
            height: 48px;
            border-radius: var(--radius-md);
            background: rgba(245,166,35,.14);
            color: var(--orange-dark);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
        }

        .student-info-label {
            font-size: 12px;
            font-weight: 800;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: .35px;
        }

        .student-info-value {
            font-size: 15px;
            font-weight: 900;
            color: var(--text-primary);
            margin-top: 3px;
        }

        .payment-course-list {
            display: flex;
            flex-direction: column;
            gap: 7px;
            min-width: 390px;
        }

        .payment-course-line {
            display: grid;
            grid-template-columns: 100px minmax(210px, 1fr) 95px;
            gap: 12px;
            align-items: start;
            padding: 5px 0;
            border-bottom: 1px dashed #eee;
        }

        .payment-course-line:last-child {
            border-bottom: none;
        }

        .payment-course-code {
            font-weight: 900;
            color: #1a1a2e;
            white-space: nowrap;
        }

        .payment-course-name {
            font-weight: 700;
            color: #333;
        }

        .payment-course-fee {
            font-weight: 900;
            color: #666;
            white-space: nowrap;
            text-align: right;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 13px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
            white-space: nowrap;
        }

        .status-pending {
            background: #fff8e1;
            color: #b36b00;
            border: 1px solid #f4d48b;
        }

        .status-paid {
            background: #e9f9ef;
            color: #188044;
            border: 1px solid #bfe8cc;
        }

        .status-rejected {
            background: #fdecec;
            color: #b42318;
            border: 1px solid #f5c2c2;
        }

        .status-overdue {
            background: #f4ecff;
            color: #6c3483;
            border: 1px solid #ddc7f5;
        }

        .status-not-active {
            background: #eef2f7;
            color: #475569;
            border: 1px solid #cbd5e1;
        }

        .receipt-link {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            color: var(--orange-dark);
            font-weight: 900;
            text-decoration: none;
            white-space: nowrap;
        }

        .receipt-empty {
            color: var(--text-muted);
            font-size: 12px;
            font-weight: 800;
            white-space: nowrap;
        }

        .receipt-uploaded {
            color: #188044;
            font-size: 12px;
            font-weight: 900;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            white-space: nowrap;
        }

        .not-active-note {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 12px;
            border-radius: 999px;
            background: #f1f5f9;
            color: #475569;
            font-size: 12px;
            font-weight: 900;
        }

        .data-table td {
            vertical-align: middle;
        }

        .data-table td:nth-child(3) {
            line-height: 1.7;
            min-width: 430px;
        }

        .data-table th:last-child,
        .data-table td:last-child {
            min-width: 280px;
        }

        .action-panel {
            display: flex;
            flex-direction: column;
            gap: 14px;
            align-items: flex-start;
            min-width: 260px;
            padding: 6px 0;
        }

        .action-panel .btn {
            padding: 9px 16px;
            font-size: .84rem;
            border-radius: 999px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 7px;
            justify-content: center;
            line-height: 1;
        }

        .action-panel .btn.btn-outline {
            min-width: 136px;
        }

        .action-row {
            display: flex;
            flex-direction: column;
            align-items: stretch;
            gap: 10px;
            width: 100%;
            max-width: 250px;
            margin-top: 0;
        }

        .action-panel .btn.btn-primary {
            width: 100%;
            height: 42px;
            border-radius: 999px;
            font-weight: 900;
            box-shadow: 0 8px 18px rgba(232,137,10,.24);
        }

        .payment-filter-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 16px;
            margin-bottom: 22px;
            flex-wrap: wrap;
            width: 100%;
        }

        .payment-filter-left {
            display: flex;
            align-items: flex-end;
            gap: 14px;
            flex-wrap: wrap;
        }

        .payment-filter-right {
            display: flex;
            align-items: flex-end;
            justify-content: flex-end;
        }

        .payment-filter-group {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }

        .payment-filter-group label {
            font-size: 13px;
            font-weight: 800;
            color: #1f2a44;
            letter-spacing: .2px;
        }

        .payment-filter-select {
            min-width: 220px;
            height: 44px;
            border: 1px solid #dde3ee;
            border-radius: 12px;
            padding: 0 14px;
            background: #fff;
            color: #1f2a44;
            font-size: 14px;
            font-weight: 600;
            outline: none;
        }

        .payment-refresh-btn {
            height: 44px;
            min-width: 118px;
            border: 0;
            border-radius: 999px;
            background: linear-gradient(135deg, #f5a623, #e8890a);
            color: #fff;
            font-size: 14px;
            font-weight: 800;
            cursor: pointer;
            box-shadow: 0 8px 18px rgba(232,137,10,.22);
        }

        .payment-refresh-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 22px rgba(232,137,10,.30);
        }

        .receipt-file-input {
            width: 100%;
            max-width: 250px;
            font-size: 12px;
            font-family: var(--font-primary);
            color: #64748b;
            font-weight: 700;
        }

        .receipt-file-input::file-selector-button {
            margin-right: 10px;
            height: 38px;
            border: 1px solid #f5a623;
            border-radius: 999px;
            background: linear-gradient(135deg, #fff7d6, #ffe2a8);
            color: #a86405;
            padding: 0 15px;
            font-family: var(--font-primary);
            font-size: 12px;
            font-weight: 900;
            cursor: pointer;
            box-shadow: 0 6px 14px rgba(245, 166, 35, .18);
            transition: all .18s ease;
        }

        .receipt-file-input::file-selector-button:hover {
            background: linear-gradient(135deg, #f5a623, #e8890a);
            color: #ffffff;
            transform: translateY(-1px);
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

        .prompt-modal {
            background: #fff;
            border-radius: 16px;
            width: 100%;
            max-width: 400px;
            padding: 36px 32px 28px;
            box-shadow: 0 12px 40px rgba(0,0,0,.28);
            text-align: center;
        }

        .prompt-modal .cm-icon-wrap {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
            background: #fff8e1;
        }

        .prompt-modal svg {
            width: 32px;
            height: 32px;
            display: block;
        }

        .prompt-modal .cm-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1a1a2e;
            margin-bottom: 14px;
        }

        .prompt-modal .cm-divider {
            border: none;
            border-top: 1px solid #ececec;
            margin: 0 -32px 18px;
        }

        .prompt-modal .cm-body {
            font-size: .97rem;
            line-height: 1.65;
            color: #555;
            margin-bottom: 28px;
        }

        .prompt-modal .cm-actions {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 12px;
        }

        .prompt-modal .cm-btn {
            padding: 10px 32px;
            border-radius: 50px;
            font-size: .95rem;
            font-weight: 600;
            cursor: pointer;
            transition: all .18s;
            min-width: 110px;
        }

        .prompt-modal .cm-btn-secondary {
            background: transparent;
            border: 2px solid #e8a838;
            color: #e8a838;
        }

        .prompt-modal .cm-btn-secondary:hover {
            background: #fdf3e0;
        }

        @media (max-width: 900px) {
            .payment-course-list {
                min-width: 320px;
            }

            .payment-course-line {
                grid-template-columns: 85px 1fr;
            }

            .payment-course-fee {
                text-align: left;
                grid-column: 2;
            }
        }

        @media (max-width: 768px) {
            .main-wrapper {
                margin-left: 0 !important;
                width: 100% !important;
            }

            .payment-filter-toolbar {
                align-items: stretch;
            }

            .payment-filter-left,
            .payment-filter-right,
            .payment-filter-select,
            .payment-refresh-btn {
                width: 100%;
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
                <div class="topbar-title">Payment</div>
                <div class="topbar-date">
                    <asp:Label ID="lblDate" runat="server" Text="" />
                </div>
            </div>

            <div class="topbar-right">
                <a href="Notification.aspx" class="topbar-icon-btn" title="Notifications">
                    <i class="fa-solid fa-bell"></i>
                </a>

                <a href="MyProfile.aspx" class="topbar-icon-btn" title="My Profile">
                    <i class="fa-solid fa-circle-user"></i>
                </a>
            </div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <h1>Student Payment</h1>
                <p>View pending tuition records and upload your payment receipt for admin verification.</p>
            </div>

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" Style="display:none;">
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </asp:Panel>

            <div class="student-info-grid">
                <div class="student-info-card">
                    <div class="student-info-icon"><i class="fa-solid fa-user-graduate"></i></div>
                    <div>
                        <div class="student-info-label">Student Name</div>
                        <div class="student-info-value">
                            <asp:Label ID="lblStudentName" runat="server" Text="Student" />
                        </div>
                    </div>
                </div>

                <div class="student-info-card">
                    <div class="student-info-icon"><i class="fa-solid fa-id-card"></i></div>
                    <div>
                        <div class="student-info-label">Student ID</div>
                        <div class="student-info-value">
                            <asp:Label ID="lblStudentId" runat="server" Text="-" />
                        </div>
                    </div>
                </div>

                <div class="student-info-card">
                    <div class="student-info-icon"><i class="fa-solid fa-layer-group"></i></div>
                    <div>
                        <div class="student-info-label">Programme</div>
                        <div class="student-info-value">
                            <asp:Label ID="lblProgramme" runat="server" Text="-" />
                        </div>
                    </div>
                </div>
            </div>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon orange"><i class="fa-solid fa-file-invoice"></i></div>
                    <div>
                        <div class="stat-value">
                            <asp:Label ID="lblPendingCount" runat="server" Text="0" />
                        </div>
                        <div class="stat-label">Pending Payments</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fa-solid fa-money-bill-wave"></i></div>
                    <div>
                        <div class="stat-value">
                            RM <asp:Label ID="lblPendingAmount" runat="server" Text="0.00" />
                        </div>
                        <div class="stat-label">Pending Amount</div>
                    </div>
                </div>
            </div>

            <asp:Panel ID="pnlDetail" runat="server" Visible="false" CssClass="card" Style="margin-bottom:30px;">
                <div class="card-header">
                    <span class="card-title"><i class="fa-solid fa-circle-info"></i> Payment Details</span>
                    <asp:Button ID="btnCloseDetail"
                        runat="server"
                        Text="Close"
                        CssClass="btn btn-outline btn-sm"
                        OnClick="btnCloseDetail_Click"
                        CausesValidation="false" />
                </div>

                <div class="card-body">
                    <div class="grid-2">
                        <div class="form-group">
                            <label>Payment ID</label>
                            <asp:TextBox ID="txtDetailPaymentId" runat="server" CssClass="form-control" ReadOnly="true" />
                        </div>

                        <div class="form-group">
                            <label>Session</label>
                            <asp:TextBox ID="txtDetailSession" runat="server" CssClass="form-control" ReadOnly="true" />
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Status</label>
                            <asp:TextBox ID="txtDetailStatus" runat="server" CssClass="form-control" ReadOnly="true" />
                        </div>

                        <div class="form-group">
                            <label>Amount</label>
                            <asp:TextBox ID="txtDetailAmount" runat="server" CssClass="form-control" ReadOnly="true" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Courses Included</label>
                        <asp:Literal ID="litDetailCourses" runat="server" />
                    </div>
                </div>
            </asp:Panel>

            <div class="card">
                <div class="card-header">
                    <span class="card-title">
                        <i class="fa-solid fa-file-invoice-dollar"></i> Payment Records
                    </span>
                </div>

                <div class="card-body">
                    <div class="payment-filter-toolbar">
                        <div class="payment-filter-left">
                            <div class="payment-filter-group">
                                <label>Filter by Session</label>
                                <asp:DropDownList ID="ddlSession"
                                    runat="server"
                                    CssClass="payment-filter-select"
                                    AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlSession_SelectedIndexChanged" />
                            </div>

                            <div class="payment-filter-group">
                                <label>Filter by Status</label>
                                <asp:DropDownList ID="ddlStatus"
                                    runat="server"
                                    CssClass="payment-filter-select"
                                    AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                                    <asp:ListItem Text="-- All Status --" Value="" />
                                    <asp:ListItem Text="Pending" Value="Pending" />
                                    <asp:ListItem Text="Paid" Value="Paid" />
                                    <asp:ListItem Text="Rejected" Value="Rejected" />
                                    <asp:ListItem Text="Overdue" Value="Overdue" />
                                    <asp:ListItem Text="Not Active" Value="Not Active" />
                                </asp:DropDownList>
                            </div>
                        </div>

                        <div class="payment-filter-right">
                            <asp:Button ID="btnRefresh"
                                runat="server"
                                Text="Refresh"
                                CssClass="btn btn-outline payment-refresh-btn"
                                OnClick="btnRefresh_Click"
                                CausesValidation="false" />
                        </div>
                    </div>

                    <div class="table-wrapper">
                        <asp:GridView ID="gvPayments"
                            runat="server"
                            CssClass="data-table"
                            AutoGenerateColumns="false"
                            EmptyDataText="No payment record found."
                            DataKeyNames="FeeId"
                            OnRowCommand="gvPayments_RowCommand"
                            OnRowDataBound="gvPayments_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="PaymentId" HeaderText="Payment Ref" />
                                <asp:BoundField DataField="Session" HeaderText="Session" />

                                <asp:TemplateField HeaderText="Courses to Pay">
                                    <ItemTemplate>
                                        <asp:Literal ID="litCoursePaymentList" runat="server" Text='<%# Eval("CoursePaymentList") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:BoundField DataField="DisplayAmount" HeaderText="Total (RM)" DataFormatString="{0:N2}" />

                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <asp:Label ID="lblStatusBadge" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Receipt">
                                    <ItemTemplate>
                                        <asp:Literal ID="litReceipt" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <div class="action-panel">
                                            <asp:LinkButton ID="btnView"
                                                runat="server"
                                                CssClass="btn btn-outline"
                                                CommandName="ViewPayment"
                                                CommandArgument='<%# Container.DataItemIndex %>'
                                                CausesValidation="false">
                                                <i class="fa-solid fa-eye"></i> View Details
                                            </asp:LinkButton>

                                            <div class="action-row" id="uploadBox" runat="server">
                                                <asp:FileUpload ID="fuReceipt" runat="server" CssClass="receipt-file-input" />

                                                <asp:LinkButton ID="btnUpload"
                                                    runat="server"
                                                    CssClass="btn btn-primary"
                                                    CommandName="UploadReceipt"
                                                    CommandArgument='<%# Container.DataItemIndex %>'>
                                                    <i class="fa-solid fa-upload"></i> Upload
                                                </asp:LinkButton>
                                            </div>

                                            <asp:Label ID="lblActionNote" runat="server" CssClass="receipt-empty" />
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="customModalOverlay">
        <div class="prompt-modal">
            <div class="cm-icon-wrap" id="modalIcon"></div>
            <div class="cm-title" id="modalTitle">Message</div>
            <hr class="cm-divider" />
            <div class="cm-body" id="modalBody">Message content</div>
            <div class="cm-actions">
                <button type="button" class="cm-btn cm-btn-secondary" onclick="closeSystemDialog()">OK</button>
            </div>
        </div>
    </div>

    <script>
        function showSystemDialog(message, type) {
            var overlay = document.getElementById('customModalOverlay');
            var title = document.getElementById('modalTitle');
            var body = document.getElementById('modalBody');
            var icon = document.getElementById('modalIcon');

            body.innerText = message || '';

            if (type === 'success') {
                title.innerText = 'Success';
                icon.innerHTML = '<svg viewBox="0 0 52 52"><circle cx="26" cy="26" r="24" fill="none" stroke="#e8a838" stroke-width="4"/><path fill="none" stroke="#e8a838" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" d="M15 27l7 7 15-16"/></svg>';
            } else if (type === 'error') {
                title.innerText = 'Error';
                icon.innerHTML = '<svg viewBox="0 0 52 52"><circle cx="26" cy="26" r="24" fill="none" stroke="#e8a838" stroke-width="4"/><path fill="none" stroke="#e8a838" stroke-width="5" stroke-linecap="round" d="M18 18l16 16M34 18L18 34"/></svg>';
            } else {
                title.innerText = 'Information';
                icon.innerHTML = '<svg viewBox="0 0 52 52"><circle cx="26" cy="26" r="24" fill="none" stroke="#e8a838" stroke-width="4"/><path fill="none" stroke="#e8a838" stroke-width="5" stroke-linecap="round" d="M26 24v14"/><circle cx="26" cy="15" r="2.8" fill="#e8a838"/></svg>';
            }

            overlay.classList.add('active');
        }

        function closeSystemDialog() {
            document.getElementById('customModalOverlay').classList.remove('active');
        }
    </script>

</form>
</body>
</html>