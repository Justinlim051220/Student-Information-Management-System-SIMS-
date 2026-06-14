﻿﻿﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Notification.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.Notification" %>
<%@ Register Src="~/Student/StudentSidebar.ascx" TagPrefix="uc" TagName="StudentSidebar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <title>Student Notifications - SIMS</title>

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />

    <style>
        html,
        body {
            margin: 0;
            padding: 0;
        }

        #form1 {
            margin: 0;
            padding: 0;
        }

        /* Match Attendance/MyCourses topbar exactly: white bar, no grey layer above */
        .topbar {
            background: #ffffff !important;
            border-bottom: 1px solid #edf0f6 !important;
            margin: 0 !important;
            padding: 20px 40px !important;
        }

        .topbar-title {
            margin: 0;
            line-height: 1.2;
        }

        .topbar-date {
            margin-top: 5px;
        }

        .notification-header {
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:18px;
            margin-bottom:22px;
            flex-wrap:wrap;
        }

        h2.page-title {
            margin-bottom:6px;
        }

        .page-subtitle {
            color:var(--text-secondary);
            font-size:14px;
            margin:0;
        }

        .student-page-card {
            background: var(--white);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-card);
            padding: 26px 28px 30px;
            margin-bottom: 24px;
        }

        .student-page-card .notification-header {
            margin-bottom: 22px;
            padding-bottom: 22px;
            border-bottom: 1px solid var(--border-light);
        }

        .notif-stats {
            display:grid;
            grid-template-columns:repeat(2,minmax(240px,1fr));
            gap:18px;
            margin-bottom:24px;
        }

        .notif-stat-card {
            background:var(--white);
            border-radius:var(--radius-md);
            box-shadow:var(--shadow-card);
            padding:20px 22px;
            display:flex;
            align-items:center;
            gap:14px;
        }

        .notif-stat-icon {
            width:46px;
            height:46px;
            border-radius:14px;
            background:rgba(245,166,35,.14);
            color:var(--orange-dark);
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:20px;
        }

        .notif-stat-label {
            font-size:12px;
            font-weight:800;
            color:var(--text-muted);
            text-transform:uppercase;
            letter-spacing:.4px;
        }

        .notif-stat-value {
            font-size:26px;
            font-weight:900;
            color:var(--text-primary);
            line-height:1;
            margin-top:4px;
        }

        .filter-card {
            background: transparent;
            border-radius: 0;
            box-shadow: none;
            padding: 0;
            margin-bottom: 22px;
        }

        .filter-title {
            display: flex;
            align-items: center;
            gap: 10px;
            color: var(--text-primary);
            font-size: 20px;
            font-weight: 900;
            margin-bottom: 16px;
        }

        .filter-title i {
            color: var(--orange-main);
        }

        .filter-bar {
            display:grid;
            grid-template-columns:1.3fr 1fr;
            gap:24px;
            align-items:end;
        }

        .filter-actions {
            display:flex;
            align-items:center;
            gap:12px;
            margin-top:18px;
        }

        .mark-read-row {
            display:block;
            margin-top:18px;
        }

        .mark-read-row .btn {
            width:100%;
            min-height:44px;
        }

        .topbar-profile-img {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            object-fit: cover;
            display: block;
            border: 2px solid #fff;
            box-shadow: 0 4px 12px rgba(15,23,42,.12);
        }

        .filter-group label {
            display:block;
            font-size:13px;
            font-weight:800;
            color:var(--text-primary);
            margin-bottom:7px;
        }

        .filter-input,
        .filter-select {
            width:100%;
            height:44px;
            border:1px solid #dde3ee;
            border-radius:12px;
            padding:0 14px;
            font-size:14px;
            font-weight:600;
            outline:none;
            background:#fff;
        }

        .notification-list {
            display:flex;
            flex-direction:column;
            gap:14px;
        }

        .notification-item {
            background:var(--white);
            border-radius:var(--radius-md);
            box-shadow:var(--shadow-card);
            padding:20px 22px;
            border-left:5px solid #e5e7eb;
            display:flex;
            justify-content:space-between;
            gap:18px;
            transition:var(--transition);
        }

        .notification-item.unread {
            border-left-color:var(--orange-main);
            background:#fffdf8;
        }

        .notification-item:hover {
            transform:translateY(-2px);
            box-shadow:var(--shadow-elevated);
        }

        .notification-main {
            flex:1;
            min-width:0;
        }

        .notification-top {
            display:flex;
            align-items:center;
            gap:10px;
            flex-wrap:wrap;
            margin-bottom:7px;
        }

        .notification-title {
            font-size:16px;
            font-weight:900;
            color:var(--text-primary);
        }

        .notification-badge {
            display:inline-flex;
            align-items:center;
            justify-content:center;
            padding:4px 10px;
            border-radius:999px;
            background:#fff8e1;
            color:#b7791f;
            font-size:11px;
            font-weight:900;
        }

        .notification-meta {
            color:var(--text-muted);
            font-size:12px;
            font-weight:700;
            margin-bottom:10px;
        }

        .notification-content {
            color:var(--text-secondary);
            font-size:14px;
            line-height:1.65;
            white-space:pre-line;
        }

        .notification-actions {
            display:flex;
            gap:8px;
            flex-shrink:0;
            align-items:flex-start;
        }

        .icon-btn {
            width:36px;
            height:36px;
            border-radius:50%;
            border:1px solid var(--border-light);
            background:var(--white);
            color:var(--text-secondary);
            display:inline-flex;
            align-items:center;
            justify-content:center;
            cursor:pointer;
            transition:var(--transition);
            text-decoration:none;
        }

        .icon-btn.read-btn:hover {
            background:rgba(46,204,113,.12);
            color:var(--success);
        }

        .icon-btn.unread-btn:hover {
            background:rgba(52,152,219,.12);
            color:var(--info);
        }

        .icon-btn.delete:hover {
            background:rgba(231,76,60,.12);
            color:var(--danger);
        }

        .empty-state {
            background:var(--white);
            border-radius:var(--radius-md);
            box-shadow:var(--shadow-card);
            text-align:center;
            padding:50px 20px;
            color:var(--text-muted);
        }

        .empty-state i {
            font-size:42px;
            color:var(--orange-main);
            margin-bottom:14px;
        }

        #customModalOverlay {
            display:none;
            position:fixed;
            inset:0;
            background:rgba(30,30,40,.60);
            z-index:9999;
            justify-content:center;
            align-items:center;
        }

        #customModalOverlay.active {
            display:flex;
        }

        #customModal {
            background:#fff;
            border-radius:16px;
            width:100%;
            max-width:400px;
            padding:36px 32px 28px;
            box-shadow:0 12px 40px rgba(0,0,0,.28);
            text-align:center;
            animation:modalIn .18s ease;
        }

        @keyframes modalIn {
            from { transform:scale(.93); opacity:0; }
            to { transform:scale(1); opacity:1; }
        }

        #customModal .cm-icon-wrap {
            width:68px;
            height:68px;
            border-radius:50%;
            display:flex;
            align-items:center;
            justify-content:center;
            margin:0 auto 16px;
            background:#fff8e1;
        }

        #customModal svg {
            width:32px;
            height:32px;
            display:block;
        }

        #customModal .cm-title {
            font-size:1.2rem;
            font-weight:800;
            color:#1a1a2e;
            margin-bottom:14px;
        }

        #customModal .cm-divider {
            border:none;
            border-top:1px solid #ececec;
            margin:0 -32px 18px;
        }

        #customModal .cm-body {
            font-size:.97rem;
            line-height:1.65;
            color:#555;
            margin-bottom:28px;
        }

        #customModal .cm-footer {
            display:flex;
            justify-content:center;
            gap:14px;
            flex-wrap:wrap;
        }

        #customModal .cm-btn {
            padding:10px 30px;
            border-radius:50px;
            font-size:.95rem;
            font-weight:700;
            cursor:pointer;
            transition:all .18s;
            min-width:110px;
            background:transparent;
            border:2px solid #e8a838;
            color:#e8a838;
        }

        #customModal .cm-btn:hover {
            background:#fdf3e0;
        }

        .sidebar-user {
            margin-bottom:18px;
            align-items:flex-start;
        }

        .sidebar-photo-avatar {
            width:42px;
            height:42px;
            border-radius:50%;
            overflow:hidden;
            padding:0!important;
            flex-shrink:0;
        }

        .sidebar-avatar-img {
            width:100%;
            height:100%;
            object-fit:cover;
            border-radius:50%;
            display:block;
        }



        /* Student notification page spacing aligned with dashboard */
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
            background: #ffffff;
        }

        .content-area,
        .page-content {
            padding: 30px 40px;
            width: 100%;
            box-sizing: border-box;
            background: #ffffff;
        }

        .sidebar-user {
            margin-bottom:18px;
            align-items:flex-start;
        }

        .user-info { padding-top:4px; }
        .user-name { margin-bottom:4px; }
        .user-role { margin-top:2px; }

        /* Standard student logout dialog - same as Dashboard */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(30,30,40,.60);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 10000;
            padding: 18px;
        }

        .modal-overlay.active { display:flex; }

        .system-dialog .modal-box {
            width: 100%;
            max-width: 400px;
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 12px 40px rgba(0,0,0,.28);
            text-align: center;
            overflow: hidden;
            animation: studentModalPop .18s ease-out;
        }

        @keyframes studentModalPop {
            from { opacity: 0; transform: translateY(10px) scale(.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        .system-dialog .modal-head {
            background: #fff;
            color: #1a1a2e;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            border-bottom: 1px solid #ececec;
            padding: 36px 32px 18px;
            font-size: 1.2rem;
            font-weight: 800;
            gap: 14px;
        }

        .logout-warning-icon {
            width: 72px !important;
            height: 72px !important;
            margin: 0 auto 16px !important;
            padding: 0 !important;
            border: 0 !important;
            border-radius: 0 !important;
            background: transparent !important;
            color: #f59e0b !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            line-height: 1 !important;
            box-shadow: none !important;
            font-family: inherit !important;
        }

        .logout-warning-icon i {
            color: #f59e0b !important;
            font-size: 56px !important;
            line-height: 1 !important;
            display: block !important;
        }

        .system-dialog .modal-body {
            padding: 18px 32px 28px;
            color: #555;
            font-size: .97rem;
            line-height: 1.65;
        }

        .system-dialog .modal-actions {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 12px;
            padding: 0 32px 28px;
        }

        .system-dialog .modal-cancel,
        .system-dialog .modal-submit {
            min-width: 110px;
            padding: 10px 32px;
            border-radius: 50px;
            font-size: .95rem;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            transition: all .18s ease;
            box-sizing: border-box;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .system-dialog .modal-cancel {
            background: transparent;
            border: 2px solid #e8a838;
            color: #e8a838;
        }

        .system-dialog .modal-submit {
            background: #e8a838;
            border: 2px solid #e8a838;
            color: #fff;
            box-shadow: 0 8px 18px rgba(232,168,56,.22);
        }

        .system-dialog .modal-cancel:hover { background: #fff8e1; }
        .system-dialog .modal-submit:hover { background: #d99a2e; border-color: #d99a2e; }

        .topbar-hidden-server-avatar {
            display:none !important;
            visibility:hidden !important;
        }


        .sender-info {
            display:inline-flex;
            align-items:center;
            gap:6px;
            font-size:13px;
            color:#6b7280;
            font-weight:700;
            margin-top:6px;
        }

        .sender-info i {
            color:#9ca3af;
            font-size:12px;
        }
        @media(max-width:900px) {
            .main-wrapper {
                margin-left:0;
                width:100%;
            }
            .content-area { padding:22px 18px 34px; }
        }

        @media(max-width:1000px) {
            .filter-bar,
            .notif-stats {
                grid-template-columns:1fr;
            }
        }

        .logout-modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(17, 24, 39, 0.62);
            z-index: 9999;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .logout-modal-card {
            width: 100%;
            max-width: 400px;
            background: #ffffff;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 22px 60px rgba(15, 23, 42, 0.28);
            text-align: center;
            font-family: var(--font-primary);
            animation: logoutPop 0.18s ease-out;
        }

        @keyframes logoutPop {
            from { transform: translateY(8px) scale(0.98); opacity: 0; }
            to { transform: translateY(0) scale(1); opacity: 1; }
        }

        .logout-modal-top {
            padding: 36px 32px 20px;
        }

        .logout-warning-icon {
            width: 72px;
            height: 72px;
            margin: 0 auto 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: transparent;
            color: #f59e0b;
            font-size: 56px;
            line-height: 1;
        }

        .logout-warning-icon i {
            color: #f59e0b;
        }

        .logout-title {
            margin: 0;
            color: var(--text-primary);
            font-size: 20px;
            font-weight: 800;
            line-height: 1.25;
        }

        .logout-message {
            margin: 0;
            padding: 20px 32px;
            border-top: 1px solid var(--border-light);
            color: var(--text-secondary);
            font-size: 15px;
            font-weight: 500;
            line-height: 1.5;
        }

        .logout-actions {
            display: flex;
            justify-content: center;
            gap: 12px;
            padding: 18px 28px 28px;
        }

        .logout-btn {
            min-width: 118px;
            height: 44px;
            border-radius: 999px;
            font-family: var(--font-primary);
            font-size: 14px;
            font-weight: 800;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            text-decoration: none;
            transition: var(--transition);
        }

        .logout-btn-cancel {
            border: 2px solid var(--orange-main);
            background: #ffffff;
            color: var(--orange-main);
        }

        .logout-btn-cancel:hover {
            background: #fff7ed;
            transform: translateY(-1px);
        }

        .logout-btn-confirm {
            border: 2px solid transparent;
            background: var(--orange-gradient);
            color: #ffffff !important;
            box-shadow: var(--shadow-orange);
        }

        .logout-btn-confirm:hover {
            transform: translateY(-1px);
            color: #ffffff !important;
}

        /* FINAL TOPBAR FIX: match Attendance / Payment page header exactly and remove grey strip */
        html,
        body,
        #form1 {
            margin: 0 !important;
            padding: 0 !important;
            overflow-x: hidden !important;
        }

        body {
            background: #ffffff !important;
        }

        .main-wrapper {
            margin-left: 260px !important;
            width: calc(100% - 260px) !important;
            min-height: 100vh !important;
            background: #ffffff !important;
            padding-top: 0 !important;
        }

        .topbar {
            width: 100% !important;
            box-sizing: border-box !important;
            background: #ffffff !important;
            margin: 0 !important;
            padding: 20px 40px !important;
            border-top: 0 !important;
            border-bottom: 1px solid #edf0f6 !important;
            border-radius: 0 !important;
            box-shadow: none !important;
            display: flex !important;
            align-items: center !important;
            justify-content: space-between !important;
            min-height: auto !important;
        }

        .topbar-title {
            margin: 0 !important;
            padding: 0 !important;
            font-size: 24px !important;
            font-weight: 800 !important;
            line-height: 1.2 !important;
            color: var(--text-primary, #111827) !important;
        }

        .topbar-date {
            margin-top: 5px !important;
            padding: 0 !important;
            color: var(--text-secondary, #8b93a7) !important;
            font-size: 13px !important;
            font-weight: 600 !important;
        }

        .topbar-right {
            display: flex !important;
            align-items: center !important;
            gap: 14px !important;
        }

        .topbar-icon-btn {
            width: 44px !important;
            height: 44px !important;
            border-radius: 50% !important;
            background: #f4f6fa !important;
            color: #4b5563 !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            text-decoration: none !important;
            position: relative !important;
            border: 0 !important;
            box-shadow: none !important;
            transition: .2s ease !important;
        }

        .topbar-icon-btn:hover {
            background: #eef1f6 !important;
            color: #111827 !important;
            transform: translateY(-1px) !important;
        }

        .page-content {
            width: 100% !important;
            box-sizing: border-box !important;
            padding: 30px 40px !important;
            background: #ffffff !important;
        }

    </style>
</head>

<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <asp:HiddenField ID="hfDeleteTarget" runat="server" />
    <asp:HiddenField ID="hfReadTarget" runat="server" />
    <asp:HiddenField ID="hfUnreadTarget" runat="server" />

    <uc:StudentSidebar ID="StudentSidebar1" runat="server" />

    <div class="main-wrapper">
        <div class="topbar">
            <div>
                <div class="topbar-title">Notifications</div>
                <div class="topbar-date">
                    <asp:Label ID="lblDate" runat="server" />
                </div>
            </div>

            <div class="topbar-right">
                <a href="Notification.aspx" class="topbar-icon-btn" title="Notifications">
                    <i class="fa-solid fa-bell"></i>
                    <asp:Panel ID="pnlNotifBadge" runat="server" CssClass="badge-dot" Visible="false" />
                </a>

                <a href="MyProfile.aspx" class="topbar-icon-btn" title="My Profile">
                    <i class="fa-solid fa-circle-user"></i>
                </a>

                <!-- Kept hidden only so existing code-behind references will not break. -->
                <asp:Label ID="lblTopbarInitial" runat="server" Text="A" Style="display:none;" />
                <asp:Image ID="imgTopbarAvatar" runat="server"
                    ImageUrl="~/ProfilePicture/default-profile.png"
                    CssClass="topbar-hidden-server-avatar" />
            </div>
        </div>

        <div class="page-content">
            <div class="notif-stats">
                <div class="notif-stat-card">
                    <div class="notif-stat-icon"><i class="fa-solid fa-bell"></i></div>
                    <div>
                        <div class="notif-stat-label">Total Notifications</div>
                        <div class="notif-stat-value"><asp:Label ID="lblTotal" runat="server" Text="0" /></div>
                    </div>
                </div>

                <div class="notif-stat-card">
                    <div class="notif-stat-icon"><i class="fa-solid fa-envelope"></i></div>
                    <div>
                        <div class="notif-stat-label">Unread</div>
                        <div class="notif-stat-value"><asp:Label ID="lblUnread" runat="server" Text="0" /></div>
                    </div>
                </div>
            </div>

            <div class="student-page-card">
                <div class="notification-header">
                    <div>
                        <h2 class="page-title">Notifications</h2>
                        <p class="page-subtitle">Review payment approval updates and important student messages.</p>
                    </div>
                </div>

                <div class="filter-card">
                    <div class="filter-title">
                        <i class="fa-solid fa-filter"></i>
                        <span>Notification Filter</span>
                    </div>

                    <div class="filter-bar">
                        <div class="filter-group">
                            <label>Search</label>
                            <asp:TextBox ID="txtSearch" runat="server"
                                CssClass="filter-input"
                                placeholder="Search notification title or message..." />
                        </div>

                        <div class="filter-group">
                            <label>Status</label>
                            <asp:DropDownList ID="ddlStatusFilter" runat="server"
                                CssClass="filter-select"
                                AutoPostBack="true"
                                OnSelectedIndexChanged="Filter_Changed">
                                <asp:ListItem Text="All Notifications" Value="" />
                                <asp:ListItem Text="Unread" Value="Unread" />
                                <asp:ListItem Text="Read" Value="Read" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="filter-actions">
                        <asp:Button ID="btnSearch" runat="server"
                            Text="Search"
                            CssClass="btn btn-primary"
                            OnClick="btnSearch_Click" />

                        <asp:Button ID="btnClear" runat="server"
                            Text="Clear"
                            CssClass="btn btn-secondary"
                            OnClick="btnClear_Click" />
                    </div>
                </div>

                <div class="mark-read-row">
                    <asp:Button ID="btnMarkAllRead" runat="server"
                        Text="Mark All as Read"
                        CssClass="btn btn-primary"
                        OnClientClick="showMarkAllReadConfirm(); return false;"
                        OnClick="btnMarkAllRead_Click" />
                </div>
            </div>

            <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                <i class="fa-regular fa-bell-slash"></i>
                <h3>No notifications found</h3>
                <p>New payment updates and system notifications will appear here.</p>
            </asp:Panel>

            <div class="notification-list">
                <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
                    <ItemTemplate>
                        <div class='notification-item <%# Convert.ToBoolean(Eval("IsRead")) ? "" : "unread" %>'>
                            <div class="notification-main">
                                <div class="notification-top">
                                    <span class="notification-title"><%# Eval("Title") %></span>
                                    <%# Eval("ItemType").ToString() == "Announcement" ? "<span class='notification-badge'>ANNOUNCEMENT</span>" : (Convert.ToBoolean(Eval("IsRead")) ? "" : "<span class='notification-badge'>NEW</span>") %>
                                </div>

                                <div class="notification-meta">
                                    <i class="fa-regular fa-clock"></i>
                                    <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy, hh:mm tt") %>
                                </div>

                                <div class="sender-info">
                                    <i class="fa-solid fa-user-pen"></i>
                                    From: <%# Eval("SenderDisplay") %>
                                </div>

                                <div class="notification-content"><%# Eval("Message") %></div>
                            </div>

                            <div class="notification-actions">
                                <asp:LinkButton ID="btnMarkRead" runat="server"
                                    CssClass="icon-btn read-btn"
                                    CommandName="MarkRead"
                                    CommandArgument='<%# Eval("NotificationId") %>'
                                    OnClientClick='<%# "showReadConfirm(" + Eval("NotificationId") + "); return false;" %>'
                                    ToolTip="Mark as read"
                                    Visible='<%# Eval("ItemType").ToString() == "Notification" && !Convert.ToBoolean(Eval("IsRead")) %>'>
                                    <i class="fa-solid fa-check"></i>
                                </asp:LinkButton>

                                <asp:LinkButton ID="btnMarkUnread" runat="server"
                                    CssClass="icon-btn unread-btn"
                                    CommandName="MarkUnread"
                                    CommandArgument='<%# Eval("NotificationId") %>'
                                    OnClientClick='<%# "showUnreadConfirm(" + Eval("NotificationId") + "); return false;" %>'
                                    ToolTip="Mark as unread"
                                    Visible='<%# Eval("ItemType").ToString() == "Notification" && Convert.ToBoolean(Eval("IsRead")) %>'>
                                    <i class="fa-regular fa-envelope"></i>
                                </asp:LinkButton>

                                <asp:LinkButton ID="btnDelete" runat="server"
                                    CssClass="icon-btn delete"
                                    Visible='<%# Eval("ItemType").ToString() == "Notification" %>'
                                    CommandName="DeleteNotification"
                                    CommandArgument='<%# Eval("NotificationId") %>'
                                    OnClientClick='<%# "showDeleteConfirm(" + Eval("NotificationId") + "); return false;" %>'
                                    ToolTip="Delete">
                                    <i class="fa-solid fa-trash"></i>
                                </asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>


    <div id="customModalOverlay">
        <div id="customModal">
            <div class="cm-icon-wrap" id="cmIconWrap">
                <span id="cmIcon"></span>
            </div>
            <div class="cm-title" id="cmTitle"></div>
            <hr class="cm-divider" />
            <div class="cm-body" id="cmBody"></div>
            <div class="cm-footer">
                <button type="button" class="cm-btn" id="cmCancelBtn" style="display:none;" onclick="closeMessageModal()">Cancel</button>
                <button type="button" class="cm-btn" id="cmOkBtn" onclick="closeMessageModal()">OK</button>
            </div>
        </div>
    </div>


    <asp:Button ID="btnReadConfirmed" runat="server" Style="display:none;" OnClick="btnReadConfirmed_Click" />
    <asp:Button ID="btnUnreadConfirmed" runat="server" Style="display:none;" OnClick="btnUnreadConfirmed_Click" />
    <asp:Button ID="btnDeleteConfirmed" runat="server" Style="display:none;" OnClick="btnDeleteConfirmed_Click" />
    <asp:Button ID="btnMarkAllReadConfirmed" runat="server" Style="display:none;" OnClick="btnMarkAllRead_Click" />

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

        function iconSvg(type) {
            if (type === 'delete' || type === 'error') {
                return '<svg viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18M6 6l12 12"/></svg>';
            }

            if (type === 'warning') {
                return '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M12 9v4"/><path d="M12 17h.01"/><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z"/></svg>';
            }

            return '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>';
        }

        function showMessageModal(title, message) {
            document.getElementById('cmTitle').innerHTML = title;
            document.getElementById('cmBody').innerHTML = message;
            document.getElementById('cmIcon').innerHTML = iconSvg(title.indexOf('Error') >= 0 ? 'error' : (title.indexOf('Warning') >= 0 ? 'warning' : 'success'));
            document.getElementById('cmCancelBtn').style.display = 'none';
            document.getElementById('cmOkBtn').style.display = '';
            document.getElementById('cmOkBtn').onclick = closeMessageModal;
            document.getElementById('customModalOverlay').classList.add('active');
        }

        function closeMessageModal() {
            document.getElementById('customModalOverlay').classList.remove('active');
        }

        function showDeleteConfirm(id) {
            document.getElementById('<%= hfDeleteTarget.ClientID %>').value = id;
        document.getElementById('cmTitle').innerHTML = 'Confirm Delete';
        document.getElementById('cmBody').innerHTML = 'Are you sure you want to delete this notification?';
        document.getElementById('cmIcon').innerHTML = iconSvg('delete');
        document.getElementById('cmCancelBtn').style.display = '';
        document.getElementById('cmOkBtn').style.display = '';
        document.getElementById('cmOkBtn').onclick = function () {
            closeMessageModal();
            document.getElementById('<%= btnDeleteConfirmed.ClientID %>').click();
        };
        document.getElementById('customModalOverlay').classList.add('active');
    }

    function showReadConfirm(id) {
        document.getElementById('<%= hfReadTarget.ClientID %>').value = id;
        document.getElementById('cmTitle').innerHTML = 'Mark as Read';
        document.getElementById('cmBody').innerHTML = 'Mark this notification as read?';
        document.getElementById('cmIcon').innerHTML = iconSvg('success');
        document.getElementById('cmCancelBtn').style.display = '';
        document.getElementById('cmOkBtn').style.display = '';
        document.getElementById('cmOkBtn').onclick = function () {
            closeMessageModal();
            document.getElementById('<%= btnReadConfirmed.ClientID %>').click();
            };
            document.getElementById('customModalOverlay').classList.add('active');
        }

        function showUnreadConfirm(id) {
            document.getElementById('<%= hfUnreadTarget.ClientID %>').value = id;
            document.getElementById('cmTitle').innerHTML = 'Mark as Unread';
            document.getElementById('cmBody').innerHTML = 'Mark this notification as unread?';
            document.getElementById('cmIcon').innerHTML = iconSvg('warning');
            document.getElementById('cmCancelBtn').style.display = '';
            document.getElementById('cmOkBtn').style.display = '';
            document.getElementById('cmOkBtn').onclick = function () {
                closeMessageModal();
                document.getElementById('<%= btnUnreadConfirmed.ClientID %>').click();
            };
            document.getElementById('customModalOverlay').classList.add('active');
        }

        function showMarkAllReadConfirm() {
            document.getElementById('cmTitle').innerHTML = 'Mark All as Read';
            document.getElementById('cmBody').innerHTML = 'Mark all unread notifications as read?';
            document.getElementById('cmIcon').innerHTML = iconSvg('warning');
            document.getElementById('cmCancelBtn').style.display = '';
            document.getElementById('cmOkBtn').style.display = '';
            document.getElementById('cmOkBtn').onclick = function () {
                closeMessageModal();
                document.getElementById('<%= btnMarkAllReadConfirmed.ClientID %>').click();
            };
            document.getElementById('customModalOverlay').classList.add('active');
        }
    </script>
</form>
</body>
</html>
