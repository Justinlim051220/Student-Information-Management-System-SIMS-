﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Contacts.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student_Contacts" %>
<%@ Register Src="~/Student/StudentSidebar.ascx" TagPrefix="uc" TagName="StudentSidebar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Contacts - SIMS Student Portal</title>

    <link rel="stylesheet" href="../Styles/SIMS.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        .sidebar { position:fixed; top:0; left:0; width:260px; height:100vh; overflow-y:auto; overflow-x:hidden; scrollbar-width:thin; }
        .main-wrapper { margin-left:260px; }
        .sidebar-user { margin-bottom:18px; align-items:flex-start; }
        .user-info { padding-top:4px; }
        .user-name { margin-bottom:4px; }
        .user-role { margin-top:2px; }

        .contacts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 22px;
        }

        .lecturer-card {
            background: var(--white);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-card);
            padding: 24px;
            transition: var(--transition);
        }

        .lecturer-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-elevated);
        }

        .lecturer-top {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 18px;
        }

        .lecturer-photo {
            width: 76px;
            height: 76px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid #fff;
            box-shadow: var(--shadow-card);
            flex-shrink: 0;
        }

        .lecturer-name {
            font-size: 18px;
            font-weight: 900;
            color: var(--text-primary);
            line-height: 1.25;
        }

        .lecturer-role {
            font-size: 12px;
            font-weight: 800;
            color: var(--orange-dark);
            margin-top: 4px;
        }

        .contact-line {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            padding: 10px 0;
            border-top: 1px solid var(--border-light);
            color: var(--text-secondary);
            font-size: 13px;
            font-weight: 700;
            overflow-wrap: anywhere;
        }

        .contact-line i {
            color: var(--orange-main);
            width: 18px;
            margin-top: 2px;
            flex-shrink: 0;
        }

        .course-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 7px;
            margin-top: 8px;
        }

        .course-tag {
            display: inline-flex;
            align-items: center;
            border-radius: var(--radius-pill);
            background: rgba(245,166,35,.14);
            color: var(--orange-dark);
            font-size: 11px;
            font-weight: 900;
            padding: 5px 10px;
        }

        .empty-card {
            background: var(--white);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-card);
            padding: 34px;
            text-align: center;
            color: var(--text-muted);
            font-weight: 700;
        }

        /* ================================================================
           Logout confirmation prompt - same clean dialog style
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
        .logout-warning-icon { width:72px; height:72px; margin:0 auto 18px; display:flex; align-items:center; justify-content:center; background:transparent; color:#f59e0b; font-size:56px; line-height:1; }
        .logout-warning-icon i { color:#f59e0b; }
        .logout-title { margin:0; color:var(--text-primary); font-size:20px; font-weight:800; line-height:1.25; }
        .logout-message { margin:0; padding:20px 32px; border-top:1px solid var(--border-light); color:var(--text-secondary); font-size:15px; font-weight:500; line-height:1.5; }
        .logout-actions { display:flex; justify-content:center; gap:12px; padding:18px 28px 28px; }
        .logout-btn { min-width:118px; height:44px; border-radius:999px; font-family:var(--font-primary); font-size:14px; font-weight:800; display:inline-flex; align-items:center; justify-content:center; cursor:pointer; text-decoration:none; transition:var(--transition); }
        .logout-btn-cancel { border:2px solid var(--orange-main); background:#ffffff; color:var(--orange-main); }
        .logout-btn-cancel:hover { background:#fff7ed; transform:translateY(-1px); }
        .logout-btn-confirm { border:2px solid transparent; background:var(--orange-gradient); color:#ffffff!important; box-shadow:var(--shadow-orange); }
        .logout-btn-confirm:hover { transform:translateY(-1px); color:#ffffff!important; }

        .sidebar-photo-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            overflow: hidden;
            padding: 0 !important;
            flex-shrink: 0;
            background: #ffffff;
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
<uc:StudentSidebar ID="StudentSidebar1" runat="server" />

    <div class="main-wrapper">
        <div class="topbar">
            <div>
                <div class="topbar-title">Contacts</div>
                <div class="topbar-date"><asp:Label ID="lblDate" runat="server" /></div>
            </div>
            <div class="topbar-right">
                <a href="Notification.aspx" class="topbar-icon-btn" title="Notifications">
                    <i class="fa-solid fa-bell"></i>
                    <asp:Panel ID="pnlNotifBadge" runat="server" CssClass="badge-dot" Visible="false" />
                </a>
                <a href="MyProfile.aspx" class="topbar-icon-btn" title="My Profile">
                    <i class="fa-solid fa-circle-user"></i>
                </a>
            </div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <h1>Lecturer Contacts</h1>
                <p>Lecturers assigned to your enrolled courses.</p>
            </div>

            <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-card" Visible="false">
                No lecturer contacts found for your current enrollments.
            </asp:Panel>

            <div class="contacts-grid">
                <asp:Repeater ID="rptLecturerContacts" runat="server">
                    <ItemTemplate>
                        <div class="lecturer-card">
                            <div class="lecturer-top">
                                <asp:Image ID="imgLecturer" runat="server" CssClass="lecturer-photo" ImageUrl='<%# Eval("ProfilePicture") %>' />
                                <div>
                                    <div class="lecturer-name"><%# Eval("LecturerName") %></div>
                                    <div class="lecturer-role">Course Lecturer</div>
                                </div>
                            </div>

                            <div class="contact-line">
                                <i class="fa-solid fa-envelope"></i>
                                <span><%# Eval("Email") %></span>
                            </div>

                            <div class="contact-line">
                                <i class="fa-solid fa-phone"></i>
                                <span><%# Eval("Phone") %></span>
                            </div>

                            <div class="contact-line">
                                <i class="fa-solid fa-book-open"></i>
                                <div class="course-tags"><%# Eval("CourseList") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>


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
