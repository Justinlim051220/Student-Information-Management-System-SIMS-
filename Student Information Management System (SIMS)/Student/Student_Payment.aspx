<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Student_Payment.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student_Payment" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SIMS – Student Payment</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <link rel="stylesheet" href="../Styles/SIMS.css" />

    <style>
        .sidebar { position:fixed; top:0; left:0; width:260px; height:100vh; overflow-y:auto; overflow-x:hidden; scrollbar-width:thin; }
        .sidebar-user { margin-bottom:18px; align-items:flex-start; }
        .user-info { padding-top:4px; }
        .user-name { margin-bottom:4px; }
        .user-role { margin-top:2px; }
        .sidebar-photo-avatar { width:42px; height:42px; border-radius:50%; overflow:hidden; padding:0!important; flex-shrink:0; }
        .sidebar-avatar-img { width:100%; height:100%; object-fit:cover; border-radius:50%; display:block; }

        h2.page-title { margin-bottom:25px; }
        .page-header p { margin-top:6px; color:var(--text-secondary); }

        .student-info-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(230px,1fr)); gap:18px; margin-bottom:26px; }
        .student-info-card { background:var(--white); border-radius:var(--radius-md); box-shadow:var(--shadow-card); padding:20px 22px; display:flex; align-items:center; gap:14px; }
        .student-info-icon { width:48px; height:48px; border-radius:var(--radius-md); background:rgba(245,166,35,.14); color:var(--orange-dark); display:flex; align-items:center; justify-content:center; font-size:20px; flex-shrink:0; }
        .student-info-label { font-size:12px; font-weight:800; color:var(--text-muted); text-transform:uppercase; letter-spacing:.35px; }
        .student-info-value { font-size:15px; font-weight:900; color:var(--text-primary); margin-top:3px; }

        .payment-course-list { display:flex; flex-direction:column; gap:7px; min-width:390px; }
        .payment-course-line { display:grid; grid-template-columns:100px minmax(210px,1fr) 95px; gap:12px; align-items:start; padding:5px 0; border-bottom:1px dashed #eee; }
        .payment-course-line:last-child { border-bottom:none; }
        .payment-course-code { font-weight:900; color:#1a1a2e; white-space:nowrap; }
        .payment-course-name { font-weight:700; color:#333; }
        .payment-course-fee { font-weight:900; color:#666; white-space:nowrap; text-align:right; }

        .status-badge { display:inline-flex; align-items:center; justify-content:center; padding:6px 13px; border-radius:999px; font-size:12px; font-weight:900; white-space:nowrap; }
        .status-pending { background:#fff8e1; color:#b36b00; border:1px solid #f4d48b; }
        .status-paid { background:#e9f9ef; color:#188044; border:1px solid #bfe8cc; }
        .status-rejected { background:#fdecec; color:#b42318; border:1px solid #f5c2c2; }
        .status-overdue { background:#f4ecff; color:#6c3483; border:1px solid #ddc7f5; }

        .receipt-link { display:inline-flex; align-items:center; gap:7px; color:var(--orange-dark); font-weight:900; text-decoration:none; white-space:nowrap; }
        .receipt-empty { color:var(--text-muted); font-size:12px; font-weight:800; white-space:nowrap; }
        .receipt-uploaded { color:#188044; font-size:12px; font-weight:900; display:inline-flex; align-items:center; gap:6px; white-space:nowrap; }

        .filter-toolbar { display:flex; align-items:flex-end; gap:12px; flex-wrap:wrap; margin-bottom:18px; }
        .filter-toolbar .form-group { min-width:250px; margin-bottom:0; }
        .filter-toolbar .btn { height:42px; display:inline-flex; align-items:center; justify-content:center; }

        .data-table td { vertical-align:middle; }
        .data-table td:nth-child(3) { line-height:1.7; min-width:430px; }
        .data-table th:last-child, .data-table td:last-child { min-width:280px; }

        .action-panel { display:flex; flex-direction:column; gap:9px; align-items:flex-start; min-width:260px; }
        .action-panel .btn { padding:8px 14px; font-size:.82rem; border-radius:999px; text-decoration:none; display:inline-flex; align-items:center; gap:7px; justify-content:center; }
        .action-row { display:flex; align-items:center; gap:8px; flex-wrap:wrap; }

        .file-picker { max-width:180px; font-size:12px; font-family:var(--font-primary); color:var(--text-secondary); }
        .file-picker::file-selector-button { margin-right:10px; border:none; border-radius:999px; background:#fff3da; color:#a86405; padding:8px 13px; font-family:var(--font-primary); font-weight:900; cursor:pointer; transition:all .18s; }
        .file-picker::file-selector-button:hover { background:#f5a623; color:#fff; }

        #customModalOverlay, #logoutModalOverlay { display:none; position:fixed; inset:0; background:rgba(30,30,40,.60); z-index:9999; justify-content:center; align-items:center; }
        #customModalOverlay.active, #logoutModalOverlay.active { display:flex; }
        .prompt-modal { background:#fff; border-radius:16px; width:100%; max-width:400px; padding:36px 32px 28px; box-shadow:0 12px 40px rgba(0,0,0,.28); text-align:center; }
        .prompt-modal .cm-icon-wrap { width:68px; height:68px; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 16px; background:#fff8e1; }
        .prompt-modal svg { width:32px; height:32px; display:block; }
        .prompt-modal .cm-title { font-size:1.2rem; font-weight:700; color:#1a1a2e; margin-bottom:14px; }
        .prompt-modal .cm-divider { border:none; border-top:1px solid #ececec; margin:0 -32px 18px; }
        .prompt-modal .cm-body { font-size:.97rem; line-height:1.65; color:#555; margin-bottom:28px; }
        .prompt-modal .cm-actions { display:flex; justify-content:center; align-items:center; gap:12px; }
        .prompt-modal .cm-btn { padding:10px 32px; border-radius:50px; font-size:.95rem; font-weight:600; cursor:pointer; transition:all .18s; min-width:110px; }
        .prompt-modal .cm-btn-primary { background:#e8a838; border:2px solid #e8a838; color:#fff; }
        .prompt-modal .cm-btn-secondary { background:transparent; border:2px solid #e8a838; color:#e8a838; }
        .prompt-modal .cm-btn-secondary:hover { background:#fdf3e0; }
        .prompt-modal .cm-btn-primary:hover { background:#d99a2e; border-color:#d99a2e; }

        @media(max-width:900px) { .payment-course-list { min-width:320px; } .payment-course-line { grid-template-columns:85px 1fr; } .payment-course-fee { text-align:left; grid-column:2; } }
    
        /* Final payment toolbar alignment */
        .payment-filter-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 16px;
            margin-bottom: 22px;
            flex-wrap: wrap;
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


        .payment-refresh-btn{height:44px;padding:0 22px;border-radius:12px;font-weight:900;}
        .payment-filter-toolbar{width:100%;}

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
            border-radius: 12px;
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

        .receipt-state-text {
            display: block;
            margin-top: 6px;
            font-size: 12px;
            font-weight: 700;
            color: #64748b;
        }

        .receipt-state-text.hide-when-paid {
            display: none;
        }

        .receipt-uploaded-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 12px;
            border-radius: 999px;
            background: #fff7ed;
            color: #c2410c;
            font-size: 12px;
            font-weight: 800;
        }

        .paid-clean-note {
            display: none !important;
        }

        .custom-file-wrap {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .custom-file-upload {
            position: relative;
            overflow: hidden;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 136px;
            height: 40px;
            padding: 0 16px;
            border-radius: 12px;
            border: 1px solid #f5a623;
            background: #fff7ed;
            color: #d97706;
            font-size: 13px;
            font-weight: 800;
            cursor: pointer;
        }

        .custom-file-upload input[type=file],
        .custom-file-wrap input[type=file] {
            position: absolute;
            left: -9999px;
            opacity: 0;
            width: 1px;
            height: 1px;
        }

        .file-name-text {
            max-width: 190px;
            color: #64748b;
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .upload-action-btn {
            height: 40px;
            padding: 0 16px;
            border: 0;
            border-radius: 12px;
            background: #1f2a44;
            color: #fff;
            font-size: 13px;
            font-weight: 800;
            cursor: pointer;
        }

        .upload-action-btn:disabled,
        .upload-disabled {
            opacity: .55;
            cursor: not-allowed;
        }

        @media (max-width: 768px) {
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


        /* Consistent Admin/Lecturer logout prompt */
        .logout-overlay {
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, .45);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            padding: 20px;
        }

        .logout-overlay.show {
            display: flex;
        }

        .logout-modal {
            width: 420px;
            max-width: 100%;
            background: #ffffff;
            border-radius: 18px;
            padding: 34px 32px 28px;
            text-align: center;
            box-shadow: 0 24px 70px rgba(15, 23, 42, .22);
            animation: modalPop .18s ease-out;
        }

        @keyframes modalPop {
            from { transform: translateY(10px) scale(.98); opacity: 0; }
            to { transform: translateY(0) scale(1); opacity: 1; }
        }

        .logout-icon-wrap {
            width: 74px;
            height: 74px;
            border-radius: 50%;
            background: #fff4de;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 18px;
        }

        .logout-icon-circle {
            width: 38px;
            height: 38px;
            border: 2px solid #e8a52b;
            border-radius: 50%;
            color: #e8a52b;
            font-size: 24px;
            font-weight: 900;
            line-height: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: Arial, sans-serif;
        }

        .logout-modal h3 {
            margin: 0 0 10px;
            font-size: 22px;
            font-weight: 800;
            color: #172033;
        }

        .logout-modal p {
            margin: 0 0 26px;
            font-size: 14px;
            color: #6b7280;
            line-height: 1.5;
        }

        .logout-actions {
            display: flex;
            gap: 14px;
            justify-content: center;
        }

        .logout-btn-cancel,
        .logout-btn-confirm {
            min-width: 120px;
            height: 44px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 800;
            cursor: pointer;
            border: 0;
        }

        .logout-btn-cancel {
            background: #eef2f7;
            color: #1f2937;
        }

        .logout-btn-confirm {
            background: linear-gradient(135deg, #f5a623, #e8890a);
            color: #ffffff;
            box-shadow: 0 10px 20px rgba(232, 137, 10, .24);
        }

        .logout-btn-cancel:hover,
        .logout-btn-confirm:hover {
            transform: translateY(-1px);
        }


        .logout-warning-wrap {
            background:#fff8e1 !important;
        }
        .logout-warning-icon {
            width:34px;
            height:34px;
            border:2px solid #e8a838;
            border-radius:50%;
            color:#e8a838;
            font-size:22px;
            font-weight:900;
            line-height:1;
            display:flex;
            align-items:center;
            justify-content:center;
            font-family:Arial, sans-serif;
        }



    /* ===== Navigation Click Fix: keep sidebar above main content ===== */
    .sidebar{
        z-index:3000 !important;
        pointer-events:auto !important;
    }
    .sidebar a,
    .sidebar .sidebar-link{
        position:relative;
        z-index:3001 !important;
        pointer-events:auto !important;
    }
    .main-wrapper{
        position:relative !important;
        z-index:1 !important;
        margin-left:260px !important;
        width:calc(100% - 260px) !important;
    }
    @media(max-width:768px){
        .main-wrapper{
            margin-left:0 !important;
            width:100% !important;
        }
    }

  

    /* ===== Standardized logout warning icon: triangle + ! ===== */
    .logout-warning-icon {
        width: 74px !important;
        height: 66px !important;
        margin: 0 auto 14px !important;
        border: 0 !important;
        border-radius: 0 !important;
        background: #fff8e1 !important;
        color: #e8a838 !important;
        clip-path: polygon(50% 0%, 100% 100%, 0% 100%) !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        padding-top: 14px !important;
        box-sizing: border-box !important;
        font-family: Arial, sans-serif !important;
        font-size: 34px !important;
        font-weight: 900 !important;
        line-height: 1 !important;
    }

  </style>
</head>
<body>
<form id="form1" runat="server">

<div class="sidebar" id="sidebar">
    <div class="sidebar-brand">
        <img src="~/Images/Logo_Dashboard.png" runat="server" alt="ONTI SIMS" class="brand-logo" />
        <div class="brand-text">
            <div class="brand-name">SIMS</div>
            <div class="brand-sub">Student Portal</div>
        </div>
    </div>

    <nav class="sidebar-nav">
        <div class="sidebar-section-label">Main</div>
        <a href="Student_Dashboard.aspx" class="sidebar-link"><i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard</a>
        <a href="MyCourses.aspx" class="sidebar-link"><i class="fa-solid fa-book-open nav-icon"></i> My Courses</a>
        <a href="Attendance.aspx" class="sidebar-link"><i class="fa-solid fa-calendar-check nav-icon"></i> Attendance</a>

        <a href="Student_Enrollment.aspx" class="sidebar-link"><i class="fa-solid fa-clipboard-list nav-icon"></i> Enrollment</a>
        <a href="Student_Payment.aspx" class="sidebar-link active"><i class="fa-solid fa-money-bill-wave nav-icon"></i> Payment</a>

        <a href="Results.aspx" class="sidebar-link"><i class="fa-solid fa-chart-line nav-icon"></i> Results</a>
        <a href="AcademicHistory.aspx" class="sidebar-link"><i class="fa-solid fa-clock-rotate-left nav-icon"></i> Academic History</a>

        <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>
        <a href="Notifications.aspx" class="sidebar-link"><i class="fa-solid fa-bell nav-icon"></i> Notifications</a>
        <a href="Contacts.aspx" class="sidebar-link"><i class="fa-solid fa-address-book nav-icon"></i> Contacts</a>

        <div class="sidebar-section-label" style="margin-top:12px;">Account</div>
        <a href="MyProfile.aspx" class="sidebar-link"><i class="fa-solid fa-circle-user nav-icon"></i> My Profile</a>
    </nav>

    <div class="sidebar-footer">
        <div class="sidebar-user">
            <div class="user-avatar" id="divSidebarInitial" runat="server">
                <asp:Label ID="lblAvatarInitial" runat="server" Text="S" />
            </div>
            <div class="user-info">
                <div class="user-name"><asp:Label ID="lblSidebarName" runat="server" Text="Student" /></div>
                <div class="user-role">Student</div>
            </div>
        </div>
        <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link" OnClientClick="showLogoutModal(); return false;">
            <i class="fa-solid fa-right-from-bracket"></i> Log Out
        </asp:LinkButton>
    </div>
</div>

<div class="main-wrapper">
    <div class="topbar">
        <div>
            <div class="topbar-title">Payment</div>
            <div class="topbar-date"><asp:Label ID="lblDate" runat="server" Text="" /></div>
        </div>
        <div class="topbar-right">
            <a href="Notifications.aspx" class="topbar-icon-btn" title="Notifications"><i class="fa-solid fa-bell"></i></a>
            <a href="MyProfile.aspx" class="topbar-icon-btn" title="My Profile"><i class="fa-solid fa-circle-user"></i></a>
        </div>
    </div>

    <div class="page-content">
        <div class="page-header">
            <h1>Student Payment</h1>
            <p>View pending tuition records and upload your payment receipt for admin verification.</p>
        </div>

        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert">
            <asp:Label ID="lblMessage" runat="server"></asp:Label>
        </asp:Panel>

        <div class="student-info-grid">
            <div class="student-info-card">
                <div class="student-info-icon"><i class="fa-solid fa-user-graduate"></i></div>
                <div><div class="student-info-label">Student Name</div><div class="student-info-value"><asp:Label ID="lblStudentName" runat="server" Text="Student" /></div></div>
            </div>
            <div class="student-info-card">
                <div class="student-info-icon"><i class="fa-solid fa-id-card"></i></div>
                <div><div class="student-info-label">Student ID</div><div class="student-info-value"><asp:Label ID="lblStudentId" runat="server" Text="-" /></div></div>
            </div>
            <div class="student-info-card">
                <div class="student-info-icon"><i class="fa-solid fa-layer-group"></i></div>
                <div><div class="student-info-label">Programme</div><div class="student-info-value"><asp:Label ID="lblProgramme" runat="server" Text="-" /></div></div>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fa-solid fa-file-invoice"></i></div>
                <div><div class="stat-value"><asp:Label ID="lblPendingCount" runat="server" Text="0" /></div><div class="stat-label">Pending Payments</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fa-solid fa-money-bill-wave"></i></div>
                <div><div class="stat-value">RM <asp:Label ID="lblPendingAmount" runat="server" Text="0.00" /></div><div class="stat-label">Pending Amount</div></div>
            </div>
        </div>

        <asp:Panel ID="pnlDetail" runat="server" Visible="false" CssClass="card" style="margin-bottom:30px;">
            <div class="card-header">
                <span class="card-title"><i class="fa-solid fa-circle-info"></i> Payment Details</span>
                <asp:Button ID="btnCloseDetail" runat="server" Text="Close" CssClass="btn btn-outline btn-sm" OnClick="btnCloseDetail_Click" CausesValidation="false" />
            </div>
            <div class="card-body">
                <div class="grid-2">
                    <div class="form-group"><label>Payment ID</label><asp:TextBox ID="txtDetailPaymentId" runat="server" CssClass="form-control" ReadOnly="true" /></div>
                    <div class="form-group"><label>Session</label><asp:TextBox ID="txtDetailSession" runat="server" CssClass="form-control" ReadOnly="true" /></div>
                </div>
                <div class="grid-2">
                    <div class="form-group"><label>Session</label><asp:TextBox ID="txtDetailStatus" runat="server" CssClass="form-control" ReadOnly="true" /></div>
                    <div class="form-group"><label>Amount</label><asp:TextBox ID="txtDetailAmount" runat="server" CssClass="form-control" ReadOnly="true" /></div>
                </div>
                <div class="form-group">
                    <label>Courses Included</label>
                    <asp:Literal ID="litDetailCourses" runat="server" />
                </div>
            </div>
        </asp:Panel>

        <div class="card">
            <div class="card-header">
                <span class="card-title"><i class="fa-solid fa-file-invoice-dollar"></i> Payment Records</span>
            </div>
            <div class="card-body">
                <div class="payment-filter-toolbar">
                    <div class="payment-filter-left">
                        <div class="payment-filter-group">
                            <label>Filter by Session</label>
                            <asp:DropDownList ID="ddlSession" runat="server" CssClass="payment-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSession_SelectedIndexChanged" />
                        </div>
                    </div>
                    <div class="payment-filter-right">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn btn-outline payment-refresh-btn" OnClick="btnRefresh_Click" CausesValidation="false" />
                    </div>
                </div>

                <div class="table-wrapper">
                    <asp:GridView ID="gvPayments" runat="server" CssClass="data-table" AutoGenerateColumns="false" EmptyDataText="No payment record found."
                        DataKeyNames="Session,FeeType" OnRowCommand="gvPayments_RowCommand" OnRowDataBound="gvPayments_RowDataBound">
                        <Columns>
                            <asp:BoundField DataField="PaymentId" HeaderText="Payment Ref" />
                            <asp:BoundField DataField="Session" HeaderText="Session" />
                            <asp:TemplateField HeaderText="Courses to Pay">
                                <ItemTemplate><asp:Literal ID="litCoursePaymentList" runat="server" Text='<%# Eval("CoursePaymentList") %>' /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Amount" HeaderText="Total (RM)" DataFormatString="{0:N2}" />
                            <asp:TemplateField HeaderText="Status"><ItemTemplate><asp:Label ID="lblStatusBadge" runat="server" /></ItemTemplate></asp:TemplateField>
                            <asp:TemplateField HeaderText="Receipt"><ItemTemplate><asp:Literal ID="litReceipt" runat="server" /></ItemTemplate></asp:TemplateField>
                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <div class="action-panel">
                                        <asp:LinkButton ID="btnView" runat="server" CssClass="btn btn-outline" CommandName="ViewPayment" CommandArgument='<%# Container.DataItemIndex %>' CausesValidation="false"><i class="fa-solid fa-eye"></i> View Details</asp:LinkButton>
                                        <div class="action-row" id="uploadBox" runat="server">
                                            <asp:FileUpload ID="fuReceipt" runat="server" CssClass="receipt-file-input" />
                                            <asp:LinkButton ID="btnUpload" runat="server" CssClass="btn btn-primary" CommandName="UploadReceipt" CommandArgument='<%# Container.DataItemIndex %>'><i class="fa-solid fa-upload"></i> Upload</asp:LinkButton>
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
        <div class="cm-actions"><button type="button" class="cm-btn cm-btn-secondary" onclick="closeSystemDialog()">OK</button></div>
    </div>
</div>

<div id="logoutModalOverlay">
    <div class="prompt-modal">
        <div class="cm-icon-wrap logout-warning-icon">!</div>
        <div class="cm-title">Log Out</div>
        <hr class="cm-divider" />
        <div class="cm-body">Are you sure you want to log out?</div>
        <div class="cm-actions">
            <button type="button" class="cm-btn cm-btn-secondary" onclick="closeLogoutModal()">Cancel</button>
            <asp:LinkButton ID="lbConfirmLogout" runat="server" CssClass="cm-btn cm-btn-primary" OnClick="lbLogout_Click">Log Out</asp:LinkButton>
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
    function closeSystemDialog() { document.getElementById('customModalOverlay').classList.remove('active'); }
    function showLogoutModal() { document.getElementById('logoutModalOverlay').classList.add('active'); }
    function closeLogoutModal() { document.getElementById('logoutModalOverlay').classList.remove('active'); }
</script>


<script type="text/javascript">
    function updateReceiptFileName(input, labelId) {
        var label = document.getElementById(labelId);
        if (!label) return;

        if (input.files && input.files.length > 0) {
            label.innerText = input.files[0].name;
        } else {
            label.innerText = "No file selected";
        }
    }
</script>




</form>
</body>
</html>
