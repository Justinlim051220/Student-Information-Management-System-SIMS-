<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Announcements.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer.Announcements" %>
<%@ Register Src="~/Lecturer/LecturerSidebar.ascx" TagPrefix="uc" TagName="LecturerSidebar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Announcements - SIMS Lecturer Portal</title>
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
            grid-template-columns: 1fr 1fr 1fr 1.5fr auto;
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

        .announcement-card {
            border: 1px solid var(--border-light);
            border-radius: var(--radius-md);
            padding: 18px 20px;
            margin-bottom: 14px;
            background: var(--white);
            transition: var(--transition);
        }

        .announcement-card:hover {
            box-shadow: var(--shadow-card);
            transform: translateY(-2px);
        }

        .announcement-top {
            display: flex;
            justify-content: space-between;
            gap: 14px;
            align-items: flex-start;
            margin-bottom: 10px;
        }

        .announcement-title {
            font-family: var(--font-accent);
            font-size: 17px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 4px;
        }

        .announcement-meta {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            color: var(--text-muted);
            font-size: 12px;
            font-weight: 700;
        }

        .announcement-content {
            color: var(--text-secondary);
            font-size: 14px;
            line-height: 1.6;
            white-space: pre-line;
        }

        .announcement-actions {
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

        .icon-btn.edit:hover {
            background: rgba(52,152,219,.12);
            color: var(--info);
        }

        .icon-btn.delete:hover {
            background: rgba(231,76,60,.12);
            color: var(--danger);
        }

        .form-actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            margin-top: 18px;
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

        /* Custom Modal */
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

        #customModal .cm-btn-delete {
            background: transparent;
            border: none;
            color: #e8a838;
            font-weight: 700;
            font-size: .97rem;
            padding: 10px 8px;
        }

        #customModal .cm-btn-delete:hover {
            color: #c8881a;
            text-decoration: underline;
        }

        @media (max-width: 1100px) {
            .filter-bar {
                grid-template-columns: 1fr 1fr;
            }
        }
        /* Move name + role upward and separate from logout */
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
        /* ================================================================
           Logout confirmation prompt - exact Lecturer_Dashboard style
           ================================================================ */
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
            to   { transform: translateY(0) scale(1); opacity: 1; }
        }

        .logout-modal-top { padding: 36px 32px 20px; }

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

        .logout-warning-icon i { color: #f59e0b; }

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
    </style>
</head>

<body>
<form id="form1" runat="server">

    <uc:LecturerSidebar ID="LecturerSidebar1" runat="server" />

    <div class="main-wrapper">
        <div class="topbar">
            <div>
                <div class="topbar-title">Announcements</div>
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
                <h1>Manage Announcements</h1>
                <p>Create, edit, filter, and delete announcements for your assigned courses.</p>
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

            <div class="card" style="margin-bottom: 24px;">
                <div class="card-body">
                    <div class="filter-bar">
                        <div class="filter-item">
                            <label>Programme</label>
                            <asp:DropDownList ID="ddlFilterProgramme" runat="server" CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProgramme_SelectedIndexChanged" />
                        </div>

                        <div class="filter-item">
                            <label>Course</label>
                            <asp:DropDownList ID="ddlFilterCourse" runat="server" CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
                        </div>

                        <div class="filter-item">
                            <label>Session</label>
                            <asp:DropDownList ID="ddlFilterSession" runat="server" CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" />
                        </div>

                        <div class="filter-item">
                            <label>Search</label>
                            <div class="search-box">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control"
                                    placeholder="Search announcement title or content..." />
                            </div>
                        </div>

                        <div class="filter-item">
                            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-outline btn-sm"
                                OnClick="btnSearch_Click" Style="margin-right:8px;" />

                            <asp:LinkButton ID="btnShowAdd" runat="server" CssClass="btn btn-primary btn-sm"
                                OnClick="btnShowAdd_Click" CausesValidation="false" Style="width:auto;">
                                <i class="fa-solid fa-plus"></i> Add
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>
            </div>

            <asp:Panel ID="pnlForm" runat="server" CssClass="card" Visible="false" Style="margin-bottom:24px;">
                <div class="card-header">
                    <span class="card-title">
                        <asp:Label ID="lblFormTitle" runat="server" Text="Add Announcement" />
                    </span>
                </div>

                <div class="card-body">
                    <asp:HiddenField ID="hfAnnouncementId" runat="server" />

                    <div class="grid-2">
                        <div class="form-group">
                            <label class="form-label">Title <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="200" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">Programme <span style="color:red">*</span></label>
                            <asp:DropDownList ID="ddlFormProgramme" runat="server" CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlFormProgramme_SelectedIndexChanged" />
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label class="form-label">Course</label>
                            <asp:DropDownList ID="ddlFormCourse" runat="server" CssClass="form-control" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">Session <span style="color:red">*</span></label>
                            <asp:DropDownList ID="ddlFormSession" runat="server" CssClass="form-control" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Announcement Content <span style="color:red">*</span></label>
                        <asp:TextBox ID="txtContent" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="6" />
                    </div>

                    <div class="form-actions">
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-outline btn-sm"
                            OnClick="btnCancel_Click" CausesValidation="false" />

                        <asp:Button ID="btnSave" runat="server" Text="Save Announcement" CssClass="btn btn-primary btn-sm"
                            OnClick="btnSave_Click" Style="width:auto;" />
                    </div>
                </div>
            </asp:Panel>

            <div class="card">
                <div class="card-header">
                    <span class="card-title">Posted Announcements</span>
                    <span class="badge badge-orange">
                        <asp:Label ID="lblTotal" runat="server" Text="0" /> Posted
                    </span>
                </div>

                <div class="card-body">
                    <asp:Repeater ID="rptAnnouncements" runat="server" OnItemCommand="rptAnnouncements_ItemCommand">
                        <ItemTemplate>
                            <div class="announcement-card">
                                <div class="announcement-top">
                                    <div>
                                        <div class="announcement-title"><%# Eval("Title") %></div>
                                        <div class="announcement-meta">
                                            <span><i class="fa-solid fa-calendar-days"></i> <%# Eval("CreatedAt", "{0:dd MMM yyyy, hh:mm tt}") %></span>
                                            <span><i class="fa-solid fa-layer-group"></i> <%# Eval("ProgrammeCode") %></span>
                                            <span><i class="fa-solid fa-book"></i> <%# Eval("CourseDisplay") %></span>
                                            <span><i class="fa-solid fa-clock"></i> <%# Eval("Session") %></span>
                                        </div>
                                    </div>

                                    <div class="announcement-actions">
                                        <asp:LinkButton ID="btnEdit" runat="server" CssClass="icon-btn edit"
                                            CommandName="EditAnnouncement" CommandArgument='<%# Eval("AnnouncementId") %>'
                                            ToolTip="Edit">
                                            <i class="fa-solid fa-pen"></i>
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnDelete" runat="server" CssClass="icon-btn delete"
                                            CommandArgument='<%# Eval("AnnouncementId") %>'
                                            ToolTip="Delete"
                                            OnClientClick='<%# "showMessageModal(\"Confirm Delete\", \"Are you sure you want to delete this announcement?\", true, \"" + Eval("AnnouncementId") + "\"); return false;" %>'>
                                            <i class="fa-solid fa-trash"></i>
                                        </asp:LinkButton>
                                    </div>
                                </div>

                                <div class="announcement-content"><%# Eval("Content") %></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                        <i class="fa-solid fa-bullhorn"></i>
                        <h3>No announcements found</h3>
                        <p>Try changing the filters or add a new announcement.</p>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <!-- Custom Modal -->
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
                <button type="button" class="cm-btn cm-btn-delete" id="cmBtnDelete" style="display:none;">Yes, Delete</button>
                <button type="button" class="cm-btn cm-btn-ok" id="cmBtnOk" style="display:none;" onclick="closeCustomModal()">OK</button>
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hfDeleteTarget" runat="server" />
    <asp:Button ID="btnDeleteConfirmed" runat="server" Style="display:none;"
        OnClick="btnDeleteConfirmed_Click" CausesValidation="false" />

    <script>
        var SVG_TICK = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
        var SVG_CROSS = '<svg viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>';
        var SVG_WARN = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
        var SVG_TRASH = '<svg viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>';

        function showMessageModal(title, message, isConfirmDelete, announcementId) {
            var iconWrap = document.getElementById('cmIconWrap');
            var iconEl = document.getElementById('cmIcon');
            var titleEl = document.getElementById('cmTitle');
            var body = document.getElementById('cmBody');
            var btnOk = document.getElementById('cmBtnOk');
            var btnCancel = document.getElementById('cmBtnCancel');
            var btnDelete = document.getElementById('cmBtnDelete');

            iconWrap.className = 'cm-icon-wrap';

            if (isConfirmDelete) {
                iconWrap.classList.add('icon-delete');
                iconEl.innerHTML = SVG_TRASH;
                titleEl.innerHTML = 'Confirm Delete';
            } else if (title.indexOf('✅') !== -1) {
                iconWrap.classList.add('icon-success');
                iconEl.innerHTML = SVG_TICK;
                titleEl.innerHTML = 'Success';
            } else if (title.indexOf('❌') !== -1) {
                iconWrap.classList.add('icon-error');
                iconEl.innerHTML = SVG_CROSS;
                titleEl.innerHTML = 'Error';
            } else if (title.indexOf('⚠') !== -1) {
                iconWrap.classList.add('icon-warning');
                iconEl.innerHTML = SVG_WARN;
                titleEl.innerHTML = 'Warning';
            } else if (title === 'Edit Mode') {
                iconWrap.classList.add('icon-warning');
                iconEl.innerHTML = SVG_WARN;
                titleEl.innerHTML = 'Edit Mode';
            } else {
                iconWrap.classList.add('icon-success');
                iconEl.innerHTML = SVG_TICK;
                titleEl.innerHTML = title;
            }

            body.innerHTML = message;

            btnOk.style.display = 'none';
            btnCancel.style.display = 'none';
            btnDelete.style.display = 'none';

            if (isConfirmDelete) {
                btnCancel.style.display = 'inline-block';
                btnDelete.style.display = 'inline-block';

                btnDelete.onclick = function () {
                    document.getElementById('<%= hfDeleteTarget.ClientID %>').value = announcementId;
                    closeCustomModal();
                    document.getElementById('<%= btnDeleteConfirmed.ClientID %>').click();
                };
            } else {
                btnOk.style.display = 'inline-block';
            }

            document.getElementById('customModalOverlay').classList.add('active');
        }

        function closeCustomModal() {
            document.getElementById('customModalOverlay').classList.remove('active');
        }

        document.getElementById('customModalOverlay').addEventListener('click', function (e) {
            if (e.target === this) closeCustomModal();
        });
    </script>

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
</script>
</form>
</body>
</html>