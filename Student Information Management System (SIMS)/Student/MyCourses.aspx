<%@ Page Language="C#"
    AutoEventWireup="true"
    CodeBehind="MyCourses.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.MyCourses" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Courses - SIMS Student Portal</title>

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
            grid-template-columns: 1fr 1fr auto;
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

        .course-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px;
            overflow: visible;
        }

        .course-card {
            position: relative;
            border: 1px solid var(--border-light);
            border-radius: var(--radius-md);
            background: var(--white);
            overflow: visible;
            transition: var(--transition);
            min-height: 170px;
            cursor: pointer;
        }

        .course-card:hover {
            box-shadow: var(--shadow-card);
            transform: translateY(-2px);
        }

        .course-body {
            padding: 24px 20px 20px;
        }

        .course-name {
            font-family: var(--font-accent);
            font-size: 18px;
            font-weight: 800;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .course-code {
            font-size: 13px;
            font-weight: 800;
            color: var(--orange-main);
            margin-bottom: 8px;
        }

        .course-session, .course-semester, .course-lecturer {
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 700;
            margin-top: 4px;
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

        @media (max-width: 1200px) {
            .course-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 900px) {
            .filter-bar {
                grid-template-columns: 1fr;
            }
            .course-grid {
                grid-template-columns: 1fr;
            }
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


        .logout-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, .55);
            z-index: 9999;
            align-items: center;
            justify-content: center;
            padding: 18px;
        }

        .logout-modal {
            width: 400px;
            max-width: 100%;
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 24px 70px rgba(15, 23, 42, .28);
            overflow: hidden;
            text-align: center;
        }

        .logout-modal-top { padding: 36px 28px 26px; }

        .logout-icon-circle {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            background: #fff4d8;
            color: #f5a21a;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 34px;
            font-weight: 900;
            margin: 0 auto 18px;
        }

        .logout-title {
            font-size: 20px;
            font-weight: 900;
            color: #1f2937;
        }

        .logout-modal-body {
            border-top: 1px solid #edf0f3;
            padding: 24px 28px 30px;
        }

        .logout-message {
            color: #6b7280;
            font-size: 15px;
            font-weight: 600;
            margin-bottom: 22px;
        }

        .logout-actions {
            display: flex;
            justify-content: center;
            gap: 14px;
        }

        .btn-logout-cancel,
        .btn-logout-confirm {
            min-width: 118px;
            height: 44px;
            border-radius: 999px;
            font-size: 14px;
            font-weight: 800;
            cursor: pointer;
        }

        .btn-logout-cancel {
            border: 2px solid #f5a21a;
            background: #fff;
            color: #f5a21a;
        }

        .btn-logout-confirm {
            border: 2px solid #f5a21a;
            background: linear-gradient(135deg, #ffb02e, #f59e0b);
            color: #fff;
            box-shadow: 0 10px 22px rgba(245, 158, 11, .28);
        }

    </style>
</head>

<body>
<form id="form1" runat="server">

    <div class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            <img src="~/Images/Logo_Dashboard.png" runat="server" alt="SIMS" class="brand-logo" />
            <div class="brand-text">
                <div class="brand-name">SIMS</div>
                <div class="brand-sub">Student Portal</div>
            </div>
        </div>

        <nav class="sidebar-nav">
            <div class="sidebar-section-label">Main</div>
            <a href="Student_Dashboard.aspx" class="sidebar-link">
                <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
            </a>
            <a href="MyCourses.aspx" class="sidebar-link active">
                <i class="fa-solid fa-book-open nav-icon"></i> My Courses
            </a>

            <div class="sidebar-section-label" style="margin-top:12px;">Academic</div>
            <a href="Attendance.aspx" class="sidebar-link">
                <i class="fa-solid fa-clipboard-check nav-icon"></i> Attendance
            </a>
            <a href="Grades.aspx" class="sidebar-link">
                <i class="fa-solid fa-star-half-stroke nav-icon"></i> My Grades
            </a>

            <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>
            <a href="Announcements.aspx" class="sidebar-link">
                <i class="fa-solid fa-bullhorn nav-icon"></i> Announcements
            </a>
            <a href="Notifications.aspx" class="sidebar-link">
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
                    <asp:Image ID="imgSidebarAvatar" runat="server" ImageUrl="~/ProfilePicture/default-profile.png" CssClass="sidebar-avatar-img" />
                </div>
                <div class="user-info">
                    <div class="user-name">
                        <asp:Label ID="lblSidebarName" runat="server" Text="Student" />
                    </div>
                    <div class="user-role">Student</div>
                </div>
            </div>
            <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link" OnClientClick="openLogoutModal(); return false;">
                <i class="fa-solid fa-right-from-bracket"></i> Log Out
            </asp:LinkButton>
        </div>
    </div>

    <div class="main-wrapper">
        <div class="topbar">
            <div>
                <div class="topbar-title">My Enrolled Courses</div>
                <div class="topbar-date"><asp:Label ID="lblDate" runat="server" /></div>
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
                <h1>My Courses</h1>
                <p>View your course status, semesters, and individual module credit allocations.</p>
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

            <div class="card" style="margin-bottom:24px;">
                <div class="card-body">
                    <div class="filter-bar">
                        <div class="filter-item">
                            <label>Academic Session</label>
                            <asp:DropDownList ID="ddlFilterSession" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSession_SelectedIndexChanged" />
                        </div>

                        <div class="filter-item">
                            <label>Semester</label>
                            <asp:DropDownList ID="ddlFilterSemester" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSemester_SelectedIndexChanged">
                                <asp:ListItem Text="All Semesters" Value="" />
                                <asp:ListItem Text="Semester 1" Value="1" />
                                <asp:ListItem Text="Semester 2" Value="2" />
                                <asp:ListItem Text="Semester 3" Value="3" />
                            </asp:DropDownList>
                        </div>

                        <div class="filter-item">
                            <asp:Button ID="btnSearch" runat="server" Text="Filter" CssClass="btn btn-primary btn-sm" OnClick="btnSearch_Click" Style="width:auto;" />
                        </div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <span class="card-title">Enrolled Academic Subjects</span>
                    <span class="badge badge-orange">
                        <asp:Label ID="lblTotal" runat="server" Text="0" /> Modules Enrolled
                    </span>
                </div>

                <div class="card-body">
                    <asp:Repeater ID="rptCourses" runat="server">
                        <HeaderTemplate>
                            <div class="course-grid">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div class="course-card" onclick="window.location.href='CourseDetails.aspx?courseId=<%# Eval("CourseId") %>&session=<%# Eval("Session") %>';">
                                <div class="course-body">
                                    <div class="course-name"><%# Eval("CourseName") %></div>
                                    <div class="course-code"><%# Eval("CourseCode") %></div>

                                    <div class="course-session">
                                        <i class="fa-solid fa-calendar-days"></i> Session: <%# Eval("Session") %>
                                    </div>
                                    <div class="course-semester">
                                        <i class="fa-solid fa-layer-group"></i> Semester: <%# Eval("Semester") %>
                                    </div>
                                    <div class="course-lecturer">
                                        <i class="fa-solid fa-award"></i> Credits: <%# Eval("Credits") %> Unit(s)
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                        <i class="fa-solid fa-book-bookmark"></i>
                        <h3>No matching enrollments found</h3>
                        <p>You have no active courses logged for the selected dropdown parameters.</p>
                    </asp:Panel>
                </div>
            </div>

        </div>
    </div>


    <div id="logoutOverlay" class="logout-overlay">
        <div class="logout-modal">
            <div class="logout-modal-top">
                <div class="logout-icon-circle">!</div>
                <div class="logout-title">Log Out</div>
            </div>
            <div class="logout-modal-body">
                <div class="logout-message">Are you sure you want to log out?</div>
                <div class="logout-actions">
                    <button type="button" class="btn-logout-cancel" onclick="closeLogoutModal();">Cancel</button>
                    <asp:Button ID="btnConfirmLogout" runat="server" Text="Log Out" CssClass="btn-logout-confirm" OnClick="btnConfirmLogout_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <script>
        function openLogoutModal() {
            document.getElementById('logoutOverlay').style.display = 'flex';
        }

        function closeLogoutModal() {
            document.getElementById('logoutOverlay').style.display = 'none';
        }
    </script>

</form>
</body>
</html>