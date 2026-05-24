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

            <a href="MyStudents.aspx" class="sidebar-link">
                <i class="fa-solid fa-user-graduate nav-icon"></i> My Students
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
                <div class="user-avatar">
                    <asp:Label ID="lblAvatarInitial" runat="server" Text="L" />
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
                                            ToolTip="Mark as Read">
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
                                            OnClientClick="return confirm('Are you sure you want to delete this notification?');">
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

</form>
</body>
</html>