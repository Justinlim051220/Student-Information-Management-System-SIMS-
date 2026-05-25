<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer.Notifications" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <title>Notifications - SIMS Lecturer Portal</title>
    <link rel="stylesheet" href="../Styles/SIMS.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
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
        }

        .filter-bar {
            display: grid;
            grid-template-columns: 1fr 2fr auto auto;
            gap: 12px;
            align-items: end;
            margin-bottom: 22px;
        }

        .filter-item label {
            display: block;
            font-size: 12px;
            font-weight: 800;
            color: var(--text-secondary);
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: .4px;
        }

        .search-box {
            position: relative;
        }

        .search-box i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
        }

        .search-box .form-control {
            padding-left: 40px;
        }

        .notification-card {
            border: 1px solid var(--border-light);
            border-radius: var(--radius-md);
            padding: 18px 20px;
            margin-bottom: 14px;
            background: var(--white);
            transition: var(--transition);
        }

        .notification-card:hover {
            box-shadow: var(--shadow-card);
            transform: translateY(-2px);
        }

        .notification-card.unread {
            border-left: 5px solid var(--orange-main);
            background: #fffaf2;
        }

        .notification-card.read {
            opacity: .72;
        }

        .notification-top {
            display: flex;
            justify-content: space-between;
            gap: 14px;
            align-items: flex-start;
            margin-bottom: 10px;
        }

        .notification-title {
            font-family: var(--font-accent);
            font-size: 17px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 4px;
        }

        .notification-meta {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            color: var(--text-muted);
            font-size: 12px;
            font-weight: 700;
        }

        .notification-content {
            color: var(--text-secondary);
            font-size: 14px;
            line-height: 1.6;
            white-space: pre-line;
        }

        .notification-actions {
            display: flex;
            gap: 8px;
            flex-shrink: 0;
        }

        .icon-btn {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            border: 1px solid var(--border-light);
            background: var(--white);
            color: var(--text-secondary);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: var(--transition);
            text-decoration: none;
        }

        .icon-btn.read-btn:hover {
            background: rgba(46,204,113,.12);
            color: var(--success);
        }

        .icon-btn.unread-btn:hover {
            background: rgba(52,152,219,.12);
            color: var(--info);
        }

        .icon-btn.delete:hover {
            background: rgba(231,76,60,.12);
            color: var(--danger);
        }

        .empty-state {
            text-align: center;
            padding: 46px 20px;
            color: var(--text-muted);
        }

        .empty-state i {
            font-size: 42px;
            color: var(--orange-main);
            margin-bottom: 12px;
        }

        @media (max-width: 1100px) {
            .filter-bar {
                grid-template-columns: 1fr 1fr;
            }
        }

        /* Custom Modal - Same Style as ManageCourses.aspx */
        #customModalOverlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(30, 30, 40, 0.60);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }

        #customModalOverlay.active {
            display: flex;
        }

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

        @keyframes modalIn {
            from { transform: scale(.93); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        #customModal .cm-icon-wrap {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
        }

        #customModal .cm-icon-wrap.icon-success { background: #fff8e1; }
        #customModal .cm-icon-wrap.icon-error { background: #fdecea; }
        #customModal .cm-icon-wrap.icon-warning { background: #fff3e0; }
        #customModal .cm-icon-wrap.icon-delete { background: #fdecea; }

        #customModal .cm-icon-wrap #cmIcon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
        }

        #customModal .cm-icon-wrap svg {
            width: 32px;
            height: 32px;
            display: block;
        }

        #customModal .cm-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1a1a2e;
            margin-bottom: 14px;
        }

        #customModal .cm-divider {
            border: none;
            border-top: 1px solid #ececec;
            margin: 0 -32px 18px;
        }

        #customModal .cm-body {
            font-size: .97rem;
            line-height: 1.65;
            color: #555;
            margin-bottom: 28px;
        }

        #customModal .cm-footer {
            display: flex;
            justify-content: center;
            gap: 16px;
        }

        #customModal .cm-btn {
            padding: 10px 32px;
            border-radius: 50px;
            font-size: .95rem;
            font-weight: 600;
            cursor: pointer;
            transition: all .18s;
            min-width: 110px;
        }

        #customModal .cm-btn-cancel,
        #customModal .cm-btn-ok {
            background: transparent;
            border: 2px solid #e8a838;
            color: #e8a838;
        }

        #customModal .cm-btn-cancel:hover,
        #customModal .cm-btn-ok:hover {
            background: #fdf3e0;
        }

        #customModal .cm-btn-delete,
        #customModal .cm-btn-read {
            background: transparent;
            border: none;
            color: #e8a838;
            font-weight: 700;
            font-size: .97rem;
            padding: 10px 8px;
        }

        #customModal .cm-btn-delete:hover,
        #customModal .cm-btn-read:hover {
            color: #c8881a;
            text-decoration: underline;
        }

        .sidebar-user{
            margin-bottom:18px;
            align-items:flex-start;
        }

        .user-info{
            padding-top:4px;
        }

        .user-name{
            margin-bottom:4px;
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
    </style>
</head>

<body>
<form id="form1" runat="server">

    <div class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            <img src="~/Images/Logo_Dashboard.png" runat="server" alt="ONTI SIMS" class="brand-logo" />
            <div class="brand-text">
                <div class="brand-name">SIMS</div>
                <div class="brand-sub">Lecturer Portal</div>
            </div>
        </div>

        <nav class="sidebar-nav">
            <div class="sidebar-section-label">Main</div>

            <a href="Lecturer_Dashboard.aspx" class="sidebar-link">
                <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
            </a>

            <a href="MyCourses.aspx" class="sidebar-link">
                <i class="fa-solid fa-book-open nav-icon"></i> My Courses
            </a>

            <div class="sidebar-section-label" style="margin-top:12px;">Academic</div>

            <a href="Attendance.aspx" class="sidebar-link">
                <i class="fa-solid fa-clipboard-check nav-icon"></i> Attendance
            </a>

            <a href="Grades.aspx" class="sidebar-link">
                <i class="fa-solid fa-star-half-stroke nav-icon"></i> Grades
            </a>

            <a href="AtRiskStudents.aspx" class="sidebar-link">
                <i class="fa-solid fa-triangle-exclamation nav-icon"></i> At-Risk Students
            </a>

            <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>

            <a href="Announcements.aspx" class="sidebar-link">
                <i class="fa-solid fa-bullhorn nav-icon"></i> Announcements
            </a>

            <a href="Notifications.aspx" class="sidebar-link active">
                <i class="fa-solid fa-bell nav-icon"></i> Notifications
            </a>

            <div class="sidebar-section-label" style="margin-top:12px;">Account</div>

            <a href="Profile.aspx" class="sidebar-link">
                <i class="fa-solid fa-circle-user nav-icon"></i> My Profile
            </a>
        </nav>

        <div class="sidebar-footer">
            <div class="sidebar-user">
                <div class="user-avatar sidebar-photo-avatar">

                    <asp:Image ID="imgSidebarAvatar"
                        runat="server"
                        ImageUrl="~/ProfilePicture/default-profile.png"
                        CssClass="sidebar-avatar-img" />

                </div>

                <div class="user-info">
                    <div class="user-name">
                        <asp:Label ID="lblSidebarName" runat="server" Text="Lecturer" />
                    </div>
                    <div class="user-role">Lecturer</div>
                </div>
            </div>

            <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link" OnClick="lbLogout_Click">
                <i class="fa-solid fa-right-from-bracket"></i> Log Out
            </asp:LinkButton>
        </div>
    </div>

    <div class="main-wrapper">
        <div class="topbar">
            <div>
                <div class="topbar-title">Notifications</div>
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
                <h1>Notifications</h1>
                <p>View, search, mark, and delete your system notifications.</p>
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

            <div class="card" style="margin-bottom:24px;">
                <div class="card-body">
                    <div class="filter-bar">

                        <div class="filter-item">
                            <label>Status</label>
                            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                                <asp:ListItem Text="All Notifications" Value=""></asp:ListItem>
                                <asp:ListItem Text="Unread Only" Value="Unread"></asp:ListItem>
                                <asp:ListItem Text="Read Only" Value="Read"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="filter-item">
                            <label>Search</label>
                            <div class="search-box">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control"
                                    placeholder="Search notification title or message..." />
                            </div>
                        </div>

                        <div class="filter-item">
                            <asp:Button ID="btnSearch" runat="server" Text="Search"
                                CssClass="btn btn-outline btn-sm" OnClick="btnSearch_Click" />
                        </div>

                        <div class="filter-item">
                            <asp:Button ID="btnMarkAllRead" runat="server" Text="Mark All Read"
                                CssClass="btn btn-primary btn-sm" OnClick="btnMarkAllRead_Click"
                                Style="width:auto;" />
                        </div>

                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <span class="card-title">Notification List</span>

                    <span class="badge badge-orange">
                        <asp:Label ID="lblTotal" runat="server" Text="0" /> Total
                    </span>
                </div>

                <div class="card-body">
                    <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
                        <ItemTemplate>
                            <div class='<%# Convert.ToBoolean(Eval("IsRead")) ? "notification-card read" : "notification-card unread" %>'>
                                <div class="notification-top">
                                    <div>
                                        <div class="notification-title">
                                            <%# Eval("Title") %>
                                        </div>

                                        <div class="notification-meta">
                                            <span>
                                                <i class="fa-solid fa-clock"></i>
                                                <%# Eval("CreatedAt", "{0:dd MMM yyyy, hh:mm tt}") %>
                                            </span>

                                            <span>
                                                <i class='<%# Convert.ToBoolean(Eval("IsRead")) ? "fa-solid fa-circle-check" : "fa-solid fa-circle-exclamation" %>'></i>
                                                <%# Convert.ToBoolean(Eval("IsRead")) ? "Read" : "Unread" %>
                                            </span>
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

                                <div class="notification-content">
                                    <%# Eval("Message") %>
                                </div>
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
    </div>

    <div id="customModalOverlay">
        <div id="customModal">
            <div class="cm-icon-wrap" id="cmIconWrap">
                <span id="cmIcon"></span>
            </div>

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

    <asp:Button ID="btnReadConfirmed" runat="server" Style="display:none;"
        OnClick="btnReadConfirmed_Click" CausesValidation="false" />

    <asp:Button ID="btnDeleteConfirmed" runat="server" Style="display:none;"
        OnClick="btnDeleteConfirmed_Click" CausesValidation="false" />

    <script>
        var SVG_TICK = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
        var SVG_CROSS = '<svg viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>';
        var SVG_WARN = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
        var SVG_TRASH = '<svg viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>';

        function resetModalButtons() {
            document.getElementById('cmBtnOk').style.display = 'none';
            document.getElementById('cmBtnCancel').style.display = 'none';
            document.getElementById('cmBtnRead').style.display = 'none';
            document.getElementById('cmBtnDelete').style.display = 'none';
        }

        function openModal(title, message, iconClass, iconSvg) {
            var iconWrap = document.getElementById('cmIconWrap');
            iconWrap.className = 'cm-icon-wrap ' + iconClass;

            document.getElementById('cmIcon').innerHTML = iconSvg;
            document.getElementById('cmTitle').innerHTML = title;
            document.getElementById('cmBody').innerHTML = message;

            resetModalButtons();
            document.getElementById('customModalOverlay').classList.add('active');
        }

        function showMessageModal(title, message, isConfirmDelete, id) {
            var displayTitle = title;
            var iconClass = 'icon-success';
            var iconSvg = SVG_TICK;

            if (title.indexOf('✅') !== -1) {
                displayTitle = 'Success';
                iconClass = 'icon-success';
                iconSvg = SVG_TICK;
            }
            else if (title.indexOf('❌') !== -1) {
                displayTitle = 'Error';
                iconClass = 'icon-error';
                iconSvg = SVG_CROSS;
            }
            else if (title.indexOf('⚠') !== -1) {
                displayTitle = 'Warning';
                iconClass = 'icon-warning';
                iconSvg = SVG_WARN;
            }

            openModal(displayTitle, message, iconClass, iconSvg);
            document.getElementById('cmBtnOk').style.display = 'inline-block';
        }

        function showReadConfirm(notificationId) {
            openModal(
                'Confirm Read',
                'Are you sure you want to mark this notification as read?',
                'icon-warning',
                SVG_WARN
            );

            document.getElementById('cmBtnCancel').style.display = 'inline-block';
            document.getElementById('cmBtnRead').style.display = 'inline-block';

            document.getElementById('cmBtnRead').onclick = function () {
                document.getElementById('<%= hfReadTarget.ClientID %>').value = notificationId;
                closeCustomModal();
                document.getElementById('<%= btnReadConfirmed.ClientID %>').click();
            };

            return false;
        }

        function showDeleteConfirm(notificationId) {
            openModal(
                'Confirm Delete',
                'Are you sure you want to delete this notification? This action cannot be undone.',
                'icon-delete',
                SVG_TRASH
            );

            document.getElementById('cmBtnCancel').style.display = 'inline-block';
            document.getElementById('cmBtnDelete').style.display = 'inline-block';

            document.getElementById('cmBtnDelete').onclick = function () {
                document.getElementById('<%= hfDeleteTarget.ClientID %>').value = notificationId;
                closeCustomModal();
                document.getElementById('<%= btnDeleteConfirmed.ClientID %>').click();
            };

            return false;
        }

        function closeCustomModal() {
            document.getElementById('customModalOverlay').classList.remove('active');
        }

        document.getElementById('customModalOverlay').addEventListener('click', function (e) {
            if (e.target === this) closeCustomModal();
        });
    </script>

</form>
</body>
</html>