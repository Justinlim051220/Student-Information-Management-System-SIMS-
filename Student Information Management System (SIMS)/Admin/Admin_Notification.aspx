<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_Notification.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.Admin_Notification" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <title>Admin Notifications - SIMS</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />

    <style>
        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: var(--font-main, 'Nunito', Arial, sans-serif);
            background: var(--bg-main, #f5f7fb);
            color: var(--text-primary, #172033);
        }

        .admin-page-shell {
            width: 100%;
            min-height: 100vh;
            padding: 34px 42px 50px;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
            margin-bottom: 32px;
            flex-wrap: wrap;
        }

        .title-wrap {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        h1 {
            margin: 0;
            font-family: var(--font-accent, 'Poppins', Arial, sans-serif);
            font-size: 28px;
            font-weight: 800;
            color: var(--text-primary, #172033);
            letter-spacing: -.2px;
        }

        .subtitle {
            margin: 6px 0 0;
            color: var(--text-secondary, #64748b);
            font-size: 14px;
            font-weight: 600;
        }

        .back-dashboard {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 9px;
            min-height: 44px;
            padding: 0 18px;
            border-radius: 50px;
            background: #fff;
            color: var(--text-primary, #1f2a44);
            border: 1px solid #e5eaf2;
            text-decoration: none;
            font-weight: 800;
            box-shadow: 0 8px 18px rgba(15,23,42,.06);
            transition: all .18s ease;
        }

        .back-dashboard:hover {
            border-color: var(--orange-main, #f5a623);
            color: var(--orange-dark, #e8890a);
            transform: translateY(-1px);
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
            gap: 18px;
            margin-bottom: 24px;
        }

        .summary-card {
            background: var(--white, #fff);
            border-radius: var(--radius-md, 18px);
            padding: 20px 22px;
            box-shadow: var(--shadow-card, 0 10px 25px rgba(15,23,42,.07));
            display: flex;
            align-items: center;
            gap: 14px;
            border: 1px solid #edf0f6;
        }

        .summary-icon {
            width: 46px;
            height: 46px;
            border-radius: 14px;
            background: rgba(245,166,35,.14);
            color: var(--orange-dark, #e8890a);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
        }

        .summary-label {
            color: var(--text-muted, #8a94a6);
            font-size: 12px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: .4px;
        }

        .summary-value {
            display: block;
            font-family: var(--font-accent, 'Poppins', Arial, sans-serif);
            font-size: 28px;
            line-height: 1;
            color: var(--text-primary, #172033);
            font-weight: 800;
            margin-top: 4px;
        }

        .filter-card {
            background: var(--white, #fff);
            border-radius: var(--radius-md, 18px);
            box-shadow: var(--shadow-card, 0 10px 25px rgba(15,23,42,.07));
            padding: 14px 20px 20px 20px;
            margin-bottom: 28px;
            border: 1px solid #edf0f6;
        }

        .filter-bar {
            display: grid;
            grid-template-columns: minmax(210px, 1fr) minmax(260px, 330px) 190px auto auto;
            gap: 14px;
            align-items: start;
        }

        .filter-title {
            display: flex;
            align-items: center;
            align-self: center;
            gap: 10px;
            font-size: 17px;
            font-weight: 900;
            margin-top: 5px;
            color: var(--text-primary, #172033);
        }

        .filter-group label {
            display: block;
            font-size: 13px;
            font-weight: 800;
            color: var(--text-primary, #172033);
            margin-bottom: 7px;
        }

        .filter-select,
        .search-input {
            width: 100%;
            height: 44px;
            border: 1px solid #dde3ee;
            border-radius: 12px;
            padding: 0 14px;
            font-size: 14px;
            font-weight: 700;
            outline: none;
            background: #fff;
            color: var(--text-primary, #172033);
        }

        .search-input::placeholder {
            color: #9aa6b8;
            font-weight: 700;
        }

        .btn-orange,
        .btn-light {
            height: 44px;
            padding: 0 22px;
            border-radius: 50px;
            font-size: 14px;
            font-weight: 900;
            cursor: pointer;
            transition: all .18s ease;
            white-space: nowrap;
        }

        .btn-orange {
            border: 0;
            background: var(--orange-gradient, linear-gradient(135deg,#f5a623,#e8890a));
            color: #fff;
            box-shadow: 0 8px 18px rgba(232,137,10,.22);
        }

        .btn-orange:hover { transform: translateY(-1px); }

        .btn-light {
            border: 1px solid #e5eaf2;
            background: #fff;
            color: var(--text-primary, #1f2a44);
        }

        .btn-light:hover {
            border-color: var(--orange-main, #f5a623);
            color: var(--orange-dark, #e8890a);
        }

        .notification-list-card {
            background: var(--white, #fff);
            border: 1px solid #edf0f6;
            border-radius: var(--radius-md, 18px);
            box-shadow: var(--shadow-card, 0 10px 25px rgba(15,23,42,.07));
            overflow: hidden;
        }

        .card-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 14px;
            padding: 20px 24px;
            border-bottom: 1px solid #edf0f6;
        }

        .card-heading h2 {
            margin: 0;
            font-size: 18px;
            font-weight: 900;
            color: var(--text-primary, #172033);
        }

        .table-wrap { width: 100%; overflow-x: auto; }

        .notification-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 880px;
        }

        .notification-table th {
            background: #fff7ed;
            color: #9a4b00;
            font-size: 13px;
            font-weight: 900;
            text-align: left;
            padding: 15px 18px;
            border-bottom: 1px solid #f3d8b2;
            text-transform: uppercase;
            letter-spacing: .25px;
        }

        .notification-table td {
            padding: 18px;
            border-bottom: 1px solid #eef2f7;
            color: #334155;
            font-size: 14px;
            vertical-align: top;
        }

        .notification-title {
            color: var(--text-primary, #172033);
            font-size: 15px;
            font-weight: 900;
            margin-bottom: 7px;
        }

        .notification-message {
            color: var(--text-secondary, #64748b);
            font-size: 13px;
            line-height: 1.65;
            white-space: pre-line;
            max-width: 700px;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 78px;
            padding: 7px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
        }

        .badge-unread { background: #fff7ed; color: #c2410c; }
        .badge-read { background: #e8f5e9; color: #166534; }

        .action-buttons {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .action-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            border: 1px solid transparent;
            transition: all .18s ease;
            font-size: 15px;
        }

        .action-read {
            background: #e8f8ee;
            color: #16a34a;
            border-color: #bbf7d0;
        }

        .action-delete {
            background: #fee2e2;
            color: #dc2626;
            border-color: #fecaca;
        }

        .action-icon:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 18px rgba(15,23,42,.08);
        }

        .action-disabled {
            color: #94a3b8;
            font-size: 13px;
            font-weight: 900;
        }

        .empty-text {
            padding: 46px 24px;
            text-align: center;
            color: var(--text-muted, #94a3b8);
            font-size: 14px;
            font-weight: 800;
        }

        .dialog-overlay {
            position: fixed;
            inset: 0;
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            background: rgba(30,30,40,.60);
            padding: 20px;
        }

        .dialog-overlay.show { display: flex; }

        .dialog-box {
            width: 400px;
            max-width: 100%;
            background: #fff;
            border-radius: 16px;
            padding: 36px 32px 28px;
            text-align: center;
            box-shadow: 0 12px 40px rgba(0,0,0,.28);
            animation: modalIn .18s ease;
        }

        @keyframes modalIn {
            from { transform: scale(.93); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        .dialog-icon {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            background: #fff8e1;
            color: #e8a838;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
            font-size: 32px;
            font-weight: 900;
        }

        .dialog-title {
            margin: 0 0 12px;
            font-size: 20px;
            font-weight: 900;
            color: #1a1a2e;
        }

        .dialog-message {
            margin: 0 0 26px;
            color: #555;
            font-size: .97rem;
            line-height: 1.65;
        }

        .dialog-btn {
            min-width: 110px;
            padding: 10px 30px;
            border-radius: 50px;
            border: 2px solid #e8a838;
            background: #e8a838;
            color: #fff;
            font-weight: 800;
            cursor: pointer;
        }

        @media(max-width:900px) {
            .admin-page-shell { padding: 24px 18px 40px; }
            .page-header, .card-heading { align-items: stretch; flex-direction: column; }
            .filter-bar { grid-template-columns: 1fr; }
            .filter-select, .btn-orange, .btn-light { width: 100%; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <div class="admin-page-shell">
        <div class="page-header">
            <div class="title-wrap">
                <div>
                    <h1>Admin Notifications</h1>
                    <p class="subtitle">Review payment receipts, enrolment activity, and course drop requests.</p>
                </div>
            </div>
            <a href="Dashboard.aspx" class="back-dashboard">
                <i class="fa-solid fa-arrow-left"></i>
                <span>Back to Dashboard</span>
            </a>
        </div>

        <div class="summary-grid">
            <div class="summary-card">
                <div class="summary-icon"><i class="fa-solid fa-bell"></i></div>
                <div>
                    <div class="summary-label">Total Notifications</div>
                    <asp:Label ID="lblTotal" runat="server" CssClass="summary-value" Text="0" />
                </div>
            </div>
            <div class="summary-card">
                <div class="summary-icon"><i class="fa-solid fa-envelope"></i></div>
                <div>
                    <div class="summary-label">Unread</div>
                    <asp:Label ID="lblUnread" runat="server" CssClass="summary-value" Text="0" />
                </div>
            </div>
            <div class="summary-card">
                <div class="summary-icon"><i class="fa-solid fa-receipt"></i></div>
                <div>
                    <div class="summary-label">Payment Messages</div>
                    <asp:Label ID="lblPaymentAlerts" runat="server" CssClass="summary-value" Text="0" />
                </div>
            </div>
        </div>

        <div class="filter-card">
            <div class="filter-bar">
                <div class="filter-title">
                    <i class="fa-solid fa-filter"></i>
                    <span>Notification Filter</span>
                </div>

                <div class="filter-group">
                    <label>Search Notification</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Search notification..." />
                </div>

                <div class="filter-group">
                    <label>Status</label>
                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="filter-select">
                        <asp:ListItem Text="All Notifications" Value="" />
                        <asp:ListItem Text="Unread Only" Value="Unread" />
                        <asp:ListItem Text="Read Only" Value="Read" />
                    </asp:DropDownList>
                </div>

                <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="btn-orange" OnClick="btnFilter_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn-light" OnClick="btnClear_Click" />
            </div>
        </div>

        <div class="notification-list-card">
            <div class="card-heading">
                <h2>Notification List</h2>
            </div>

            <div class="table-wrap">
                <asp:GridView ID="gvNotifications" runat="server"
                    AutoGenerateColumns="False"
                    CssClass="notification-table"
                    GridLines="None"
                    EmptyDataText="No notifications found."
                    OnRowCommand="gvNotifications_RowCommand"
                    DataKeyNames="NotificationId">
                    <Columns>
                        <asp:TemplateField HeaderText="Notification">
                            <ItemTemplate>
                                <div class="notification-title"><%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %></div>
                                <div class="notification-message"><%# Server.HtmlEncode(Convert.ToString(Eval("Message"))) %></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="CreatedAt" HeaderText="Date" DataFormatString="{0:dd MMM yyyy, hh:mm tt}" />

                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='<%# Convert.ToBoolean(Eval("IsRead")) ? "badge badge-read" : "badge badge-unread" %>'>
                                    <%# Convert.ToBoolean(Eval("IsRead")) ? "Read" : "Unread" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <div class="action-buttons">
                                    <asp:LinkButton ID="btnMarkRead" runat="server"
                                        CssClass="action-icon action-read"
                                        CommandName="MarkRead"
                                        CommandArgument='<%# Eval("NotificationId") %>'
                                        ToolTip="Mark as read"
                                        Visible='<%# !Convert.ToBoolean(Eval("IsRead")) %>'>
                                        <i class="fa-solid fa-check"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnDelete" runat="server"
                                        CssClass="action-icon action-delete"
                                        CommandName="DeleteNotification"
                                        CommandArgument='<%# Eval("NotificationId") %>'
                                        ToolTip="Delete notification"
                                        OnClientClick="return confirm('Delete this notification?');">
                                        <i class="fa-solid fa-trash"></i>
                                    </asp:LinkButton>

                                    <asp:Label ID="lblReadDone" runat="server"
                                        CssClass="action-disabled"
                                        Text="Read"
                                        Visible='<%# Convert.ToBoolean(Eval("IsRead")) %>' />
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="empty-text">
                            <i class="fa-regular fa-bell-slash" style="font-size:38px;color:#f5a623;margin-bottom:12px;display:block;"></i>
                            No notifications found.
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div id="messageDialog" class="dialog-overlay">
        <div class="dialog-box">
            <div class="dialog-icon"><i class="fa-solid fa-check"></i></div>
            <h3 class="dialog-title" id="dialogTitle">Success</h3>
            <p class="dialog-message" id="dialogMessage">Action completed successfully.</p>
            <button type="button" class="dialog-btn" onclick="hideDialog()">OK</button>
        </div>
    </div>

    <script type="text/javascript">
        function showDialog(title, message) {
            document.getElementById('dialogTitle').innerText = title;
            document.getElementById('dialogMessage').innerText = message;
            document.getElementById('messageDialog').classList.add('show');
        }
        function hideDialog() {
            document.getElementById('messageDialog').classList.remove('show');
        }
    </script>
</form>
</body>
</html>
