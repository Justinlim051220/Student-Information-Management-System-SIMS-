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
            margin-bottom: 22px;
        }

        h1 {
            margin: 0;
            font-family: var(--font-accent, 'Poppins', Arial, sans-serif);
            font-size: 30px;
            font-weight: 800;
            color: var(--text-primary, #172033);
            letter-spacing: -.2px;
        }

        .subtitle {
            margin: 7px 0 0;
            color: var(--text-secondary, #64748b);
            font-size: 15px;
            font-weight: 600;
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

        .card {
            background: var(--white, #fff);
            border-radius: var(--radius-md, 18px);
            box-shadow: var(--shadow-card, 0 10px 25px rgba(15,23,42,.07));
            border: 1px solid #edf0f6;
            margin-bottom: 24px;
            overflow: hidden;
        }

        .card-body { padding: 26px 30px; }

        .card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            padding: 18px 22px;
            border-bottom: 1px solid #edf0f6;
        }

        .card-title {
            font-family: var(--font-accent, 'Poppins', Arial, sans-serif);
            font-size: 18px;
            font-weight: 800;
            color: var(--text-primary, #172033);
        }

        .filter-header {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 21px;
            font-weight: 900;
            color: var(--text-primary, #172033);
            margin-bottom: 4px;
        }

        .filter-header i { color: var(--orange-dark, #e8890a); }

        .filter-note {
            margin: 0 0 22px;
            color: var(--text-secondary, #64748b);
            font-size: 14px;
            font-weight: 600;
        }

        .filter-panel {
            border: 1px solid #edf0f6;
            border-radius: 16px;
            padding: 24px;
            background: #fff;
            margin-bottom: 22px;
        }

        .filter-grid {
            display: grid;
            grid-template-columns: minmax(260px, 1fr) 260px;
            gap: 22px;
            align-items: end;
            margin-bottom: 20px;
        }

        .filter-item label {
            display: block;
            font-size: 12px;
            font-weight: 900;
            color: var(--text-secondary, #64748b);
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: .5px;
        }

        .search-box { position: relative; }

        .search-box i {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted, #8a94a6);
            font-size: 15px;
        }

        .form-control {
            width: 100%;
            height: 48px;
            border: 1px solid #dde3ee;
            border-radius: 12px;
            padding: 0 14px;
            font-size: 14px;
            font-weight: 700;
            outline: none;
            background: #fff;
            color: var(--text-primary, #172033);
        }

        .form-control:focus {
            border-color: var(--orange-main, #f5a623);
            box-shadow: 0 0 0 3px rgba(245,166,35,.14);
        }

        .search-box .form-control { padding-left: 44px; }

        .filter-button-row {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .main-action-row {
            margin-bottom: 14px;
        }

        .back-row {
            margin-top: 0;
        }

        .btn {
            min-height: 44px;
            padding: 0 22px;
            border-radius: 14px;
            font-size: 14px;
            font-weight: 900;
            cursor: pointer;
            transition: all .18s ease;
            white-space: nowrap;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 9px;
            text-decoration: none;
        }

        .btn-primary {
            border: 0;
            background: var(--orange-gradient, linear-gradient(135deg,#f5a623,#e8890a));
            color: #fff;
            box-shadow: 0 8px 18px rgba(232,137,10,.22);
        }

        .btn-outline {
            border: 1px solid #e5eaf2;
            background: #fff;
            color: var(--text-primary, #1f2a44);
        }

        .btn-dark {
            border: 0;
            background: #172033;
            color: #fff;
            box-shadow: 0 8px 18px rgba(23,32,51,.16);
        }

        .btn-wide { width: 100%; }
        .btn-back { min-width: 210px; }

        .btn:hover { transform: translateY(-1px); }
        .btn-outline:hover { border-color: var(--orange-main, #f5a623); color: var(--orange-dark, #e8890a); }

        .notification-card {
            border: 1px solid var(--border-light, #edf0f6);
            border-radius: var(--radius-md, 18px);
            padding: 18px 20px;
            margin-bottom: 14px;
            background: var(--white, #fff);
            transition: all .18s ease;
        }

        .notification-card:hover {
            box-shadow: var(--shadow-card, 0 10px 25px rgba(15,23,42,.07));
            transform: translateY(-2px);
        }

        .notification-card.unread {
            border-left: 5px solid var(--orange-main, #f5a623);
            background: #fffaf2;
        }

        .notification-card.read { opacity: .76; }

        .notification-top {
            display: flex;
            justify-content: space-between;
            gap: 14px;
            align-items: flex-start;
            margin-bottom: 10px;
        }

        .notification-title {
            font-family: var(--font-accent, 'Poppins', Arial, sans-serif);
            font-size: 17px;
            font-weight: 800;
            color: var(--text-primary, #172033);
            margin-bottom: 4px;
        }

        .notification-meta {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            color: var(--text-muted, #8a94a6);
            font-size: 12px;
            font-weight: 800;
        }

        .notification-content {
            color: var(--text-secondary, #64748b);
            font-size: 14px;
            line-height: 1.65;
            white-space: pre-line;
        }

        .notification-actions {
            display: flex;
            gap: 8px;
            flex-shrink: 0;
        }

        .icon-btn {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            border: 1px solid var(--border-light, #edf0f6);
            background: var(--white, #fff);
            color: var(--text-secondary, #64748b);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all .18s ease;
            text-decoration: none;
        }

        .icon-btn.read-btn:hover { background: rgba(46,204,113,.12); color: var(--success, #22c55e); }
        .icon-btn.unread-btn:hover { background: rgba(52,152,219,.12); color: var(--info, #3498db); }
        .icon-btn.delete:hover { background: rgba(231,76,60,.12); color: var(--danger, #e74c3c); }

        .badge-orange {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            padding: 8px 14px;
            color: var(--orange-dark, #e8890a);
            background: rgba(245,166,35,.12);
            font-size: 13px;
            font-weight: 900;
        }

        .empty-state {
            text-align: center;
            padding: 46px 20px;
            color: var(--text-muted, #8a94a6);
        }

        .empty-state i {
            font-size: 42px;
            color: var(--orange-main, #f5a623);
            margin-bottom: 12px;
        }

        #customModalOverlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(30, 30, 40, 0.60);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }

        #customModalOverlay.active { display: flex; }

        #customModal {
            background: #fff;
            border-radius: 16px;
            width: 100%;
            max-width: 400px;
            padding: 36px 32px 28px;
            box-shadow: 0 12px 40px rgba(0,0,0,.28);
            text-align: center;
            animation: modalIn .18s ease;
        }

        @keyframes modalIn { from { transform: scale(.93); opacity: 0; } to { transform: scale(1); opacity: 1; } }

        .cm-icon-wrap {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
        }

        .cm-icon-wrap.icon-success { background: #fff8e1; }
        .cm-icon-wrap.icon-error { background: #fdecea; }
        .cm-icon-wrap.icon-warning { background: #fff3e0; }
        .cm-icon-wrap.icon-delete { background: #fdecea; }
        .cm-icon-wrap i { font-size: 32px; color: #e8a838; }
        .cm-icon-wrap.icon-delete i { color: #e74c3c; }

        .cm-title {
            font-size: 1.2rem;
            font-weight: 800;
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

        .cm-footer { display: flex; justify-content: center; gap: 16px; flex-wrap: wrap; }

        .cm-btn {
            padding: 10px 28px;
            border-radius: 50px;
            font-size: .95rem;
            font-weight: 700;
            cursor: pointer;
            transition: all .18s;
            min-width: 110px;
        }

        .cm-btn-cancel,
        .cm-btn-ok {
            background: transparent;
            border: 2px solid #e8a838;
            color: #e8a838;
        }

        .cm-btn-cancel:hover,
        .cm-btn-ok:hover { background: #fdf3e0; }

        .cm-btn-delete,
        .cm-btn-read {
            background: transparent;
            border: none;
            color: #e8a838;
            font-weight: 800;
            padding: 10px 8px;
        }

        .cm-btn-delete:hover,
        .cm-btn-read:hover { color: #c8881a; text-decoration: underline; }

        .hidden-submit { display:none; }

        @media (max-width: 900px) {
            .admin-page-shell { padding: 24px 18px 40px; }
            .card-body { padding: 22px; }
            .filter-grid { grid-template-columns: 1fr; }
            .btn-wide { width: 100%; }
            .notification-top { flex-direction: column; }
        }
</style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <div class="admin-page-shell">
        <div class="page-header">
            <h1>Admin Notifications</h1>
            <p class="subtitle">Review payment receipts, enrolment activity, and course drop requests.</p>
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

        <div class="card">
            <div class="card-body">
                <div class="filter-header">
                    <i class="fa-solid fa-filter"></i>
                    <span>Notification Filter</span>
                </div>
                <p class="filter-note">Search and filter notifications to manage read and unread messages.</p>

                <div class="filter-panel">
                    <div class="filter-grid">
                        <div class="filter-item">
                            <label>Search</label>
                            <div class="search-box">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search notification title or message..." />
                            </div>
                        </div>

                        <div class="filter-item">
                            <label>Status</label>
                            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                                <asp:ListItem Text="All Notifications" Value="" />
                                <asp:ListItem Text="Unread Only" Value="Unread" />
                                <asp:ListItem Text="Read Only" Value="Read" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="filter-button-row">
                        <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="btn btn-dark" OnClick="btnFilter_Click" />
                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-outline" OnClick="btnClear_Click" />
                    </div>
                </div>

                <div class="main-action-row">
                    <asp:Button ID="btnMarkAllRead" runat="server" Text="Mark All as Read" CssClass="btn btn-primary btn-wide" OnClick="btnMarkAllRead_Click" />
                </div>

                <div class="back-row">
                    <a href="Dashboard.aspx" class="btn btn-outline btn-back">
                        <i class="fa-solid fa-arrow-left"></i>
                        <span>Back to Dashboard</span>
                    </a>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <span class="card-title">Notification List</span>
                <span class="badge-orange"><asp:Label ID="lblListTotal" runat="server" Text="0" /> Total</span>
            </div>

            <div class="card-body">
                <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
                    <ItemTemplate>
                        <div class='<%# Convert.ToBoolean(Eval("IsRead")) ? "notification-card read" : "notification-card unread" %>'>
                            <div class="notification-top">
                                <div>
                                    <div class="notification-title"><%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %></div>
                                    <div class="notification-meta">
                                        <span><i class="fa-solid fa-clock"></i> <%# Eval("CreatedAt", "{0:dd MMM yyyy, hh:mm tt}") %></span>
                                        <span><i class='<%# Convert.ToBoolean(Eval("IsRead")) ? "fa-solid fa-circle-check" : "fa-solid fa-circle-exclamation" %>'></i> <%# Convert.ToBoolean(Eval("IsRead")) ? "Read" : "Unread" %></span>
                                    </div>
                                </div>

                                <div class="notification-actions">
                                    <asp:LinkButton ID="btnMarkRead" runat="server"
                                        CssClass="icon-btn read-btn"
                                        CommandName="MarkRead"
                                        CommandArgument='<%# Eval("NotificationId") %>'
                                        Visible='<%# !Convert.ToBoolean(Eval("IsRead")) %>'
                                        ToolTip="Mark as Read"
                                        OnClientClick='<%# "return showReadConfirm(" + Eval("NotificationId") + ");" %>'>
                                        <i class="fa-solid fa-check"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnMarkUnread" runat="server"
                                        CssClass="icon-btn unread-btn"
                                        CommandName="MarkUnread"
                                        CommandArgument='<%# Eval("NotificationId") %>'
                                        Visible='<%# Convert.ToBoolean(Eval("IsRead")) %>'
                                        ToolTip="Mark as Unread">
                                        <i class="fa-solid fa-envelope"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnDelete" runat="server"
                                        CssClass="icon-btn delete"
                                        CommandName="DeleteNotification"
                                        CommandArgument='<%# Eval("NotificationId") %>'
                                        ToolTip="Delete"
                                        OnClientClick='<%# "return showDeleteConfirm(" + Eval("NotificationId") + ");" %>'>
                                        <i class="fa-solid fa-trash"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>

                            <div class="notification-content"><%# Server.HtmlEncode(Convert.ToString(Eval("Message"))) %></div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                    <i class="fa-solid fa-bell-slash"></i>
                    <h3>No notifications found</h3>
                    <p>There are no notifications matching your filter.</p>
                </asp:Panel>
            </div>
        </div>
    </div>

    <div id="customModalOverlay">
        <div id="customModal">
            <div class="cm-icon-wrap" id="cmIconWrap"><i id="cmIcon" class="fa-solid fa-check"></i></div>
            <div class="cm-title" id="cmTitle">Message</div>
            <hr class="cm-divider" />
            <div class="cm-body" id="cmBody"></div>
            <div class="cm-footer">
                <button type="button" class="cm-btn cm-btn-cancel" id="cmBtnCancel" style="display:none;" onclick="closeCustomModal()">Cancel</button>
                <button type="button" class="cm-btn cm-btn-read" id="cmBtnRead" style="display:none;">Yes, Mark Read</button>
                <button type="button" class="cm-btn cm-btn-delete" id="cmBtnDelete" style="display:none;">Yes, Delete</button>
                <button type="button" class="cm-btn cm-btn-ok" id="cmBtnOk" style="display:none;" onclick="closeCustomModal()">OK</button>
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hfReadTarget" runat="server" />
    <asp:HiddenField ID="hfDeleteTarget" runat="server" />
    <asp:Button ID="btnReadConfirmed" runat="server" CssClass="hidden-submit" OnClick="btnReadConfirmed_Click" />
    <asp:Button ID="btnDeleteConfirmed" runat="server" CssClass="hidden-submit" OnClick="btnDeleteConfirmed_Click" />

    <script type="text/javascript">
        function closeCustomModal() {
            document.getElementById('customModalOverlay').classList.remove('active');
        }

        function resetModalButtons() {
            document.getElementById('cmBtnCancel').style.display = 'none';
            document.getElementById('cmBtnRead').style.display = 'none';
            document.getElementById('cmBtnDelete').style.display = 'none';
            document.getElementById('cmBtnOk').style.display = 'none';
        }

        function setModalIcon(type) {
            var wrap = document.getElementById('cmIconWrap');
            var icon = document.getElementById('cmIcon');
            wrap.className = 'cm-icon-wrap icon-' + type;
            if (type === 'delete' || type === 'error') icon.className = 'fa-solid fa-trash';
            else if (type === 'warning') icon.className = 'fa-solid fa-triangle-exclamation';
            else icon.className = 'fa-solid fa-check';
        }

        function showMessageModal(title, message, isDelete) {
            resetModalButtons();
            document.getElementById('cmTitle').innerHTML = title;
            document.getElementById('cmBody').innerHTML = message;
            setModalIcon(isDelete ? 'delete' : 'success');
            document.getElementById('cmBtnOk').style.display = 'inline-block';
            document.getElementById('customModalOverlay').classList.add('active');
        }

        function showReadConfirm(id) {
            resetModalButtons();
            document.getElementById('<%= hfReadTarget.ClientID %>').value = id;
            document.getElementById('cmTitle').innerHTML = 'Mark as Read';
            document.getElementById('cmBody').innerHTML = 'Are you sure you want to mark this notification as read?';
            setModalIcon('success');
            document.getElementById('cmBtnCancel').style.display = 'inline-block';
            document.getElementById('cmBtnRead').style.display = 'inline-block';
            document.getElementById('customModalOverlay').classList.add('active');
            return false;
        }

        function showDeleteConfirm(id) {
            resetModalButtons();
            document.getElementById('<%= hfDeleteTarget.ClientID %>').value = id;
            document.getElementById('cmTitle').innerHTML = 'Delete Notification';
            document.getElementById('cmBody').innerHTML = 'Are you sure you want to delete this notification?';
            setModalIcon('delete');
            document.getElementById('cmBtnCancel').style.display = 'inline-block';
            document.getElementById('cmBtnDelete').style.display = 'inline-block';
            document.getElementById('customModalOverlay').classList.add('active');
            return false;
        }

        document.getElementById('cmBtnRead').onclick = function () {
            closeCustomModal();
            document.getElementById('<%= btnReadConfirmed.ClientID %>').click();
        };

        document.getElementById('cmBtnDelete').onclick = function () {
            closeCustomModal();
            document.getElementById('<%= btnDeleteConfirmed.ClientID %>').click();
        };
    </script>
</form>
</body>
</html>
