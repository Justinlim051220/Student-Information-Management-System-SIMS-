<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyCourses.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer.MyCourses" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Courses - SIMS Lecturer Portal</title>

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
            grid-template-columns: 1fr 1fr 1fr auto;
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

        .course-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px;
        }

        .course-card {
            position: relative;
            border: 1px solid var(--border-light);
            border-radius: var(--radius-md);
            background: var(--white);
            overflow: hidden;
            transition: var(--transition);
        }

        .course-card:hover {
            box-shadow: var(--shadow-card);
            transform: translateY(-2px);
        }

        .course-image {
            width: 100%;
            height: 150px;
            object-fit: cover;
            background: #f5f7fa;
        }

        .course-body {
            padding: 18px 20px;
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

        .course-session {
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 700;
        }

        .course-semester {
            margin-top: 6px;
            font-size: 13px;
            color: var(--text-secondary);
            font-weight: 700;
        }

        .course-menu-wrap {
            position: absolute;
            top: 12px;
            right: 12px;
        }

        .course-menu-btn {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            border: none;
            background: rgba(255,255,255,.95);
            color: var(--text-primary);
            box-shadow: var(--shadow-card);
            cursor: pointer;
        }

        .course-menu {
            display: none;
            position: absolute;
            right: 0;
            top: 42px;
            width: 190px;
            background: var(--white);
            border: 1px solid var(--border-light);
            border-radius: 12px;
            box-shadow: var(--shadow-card);
            padding: 8px;
            z-index: 999;
        }

        .course-menu.show {
            display: block;
        }

        .course-menu .menu-action {
            display: block;
            width: 100%;
            padding: 9px 12px;
            border-radius: 8px;
            color: var(--text-secondary);
            text-align: left;
            text-decoration: none;
            border: none;
            background: transparent;
            cursor: pointer;
            font-size: 13px;
            font-weight: 700;
        }

        .course-menu .menu-action:hover {
            background: #fff8e1;
            color: var(--orange-main);
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

            <a href="MyCourses.aspx" class="sidebar-link active">
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
                <div class="topbar-title">My Courses</div>
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
                <h1>My Courses</h1>
                <p>View and arrange your assigned teaching courses.</p>
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

            <div class="card" style="margin-bottom:24px;">
                <div class="card-body">
                    <div class="filter-bar">

                        <div class="filter-item">
                            <label>Programme</label>
                            <asp:DropDownList ID="ddlFilterProgramme" runat="server" CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProgramme_SelectedIndexChanged" />
                        </div>

                        <div class="filter-item">
                            <label>Course</label>
                           <asp:DropDownList ID="ddlFilterCourse"
                                runat="server"
                                CssClass="form-control"
                                AutoPostBack="true"
                                OnSelectedIndexChanged="ddlFilterCourse_SelectedIndexChanged" />
                        </div>

                        <div class="filter-item">
                            <label>Session</label>
                            <asp:DropDownList ID="ddlFilterSession"
                                runat="server"
                                CssClass="form-control"
                                AutoPostBack="true"
                                OnSelectedIndexChanged="ddlFilterSession_SelectedIndexChanged" />
                        </div>

                        <div class="filter-item">
                            <asp:Button ID="btnSearch" runat="server" Text="Filter"
                                CssClass="btn btn-primary btn-sm"
                                OnClick="btnSearch_Click"
                                Style="width:auto;" />
                        </div>

                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <span class="card-title">Assigned Courses</span>

                    <span class="badge badge-orange">
                        <asp:Label ID="lblTotal" runat="server" Text="0" /> Courses
                    </span>
                </div>

                <div class="card-body">

                    <asp:Repeater ID="rptCourses" runat="server" OnItemCommand="rptCourses_ItemCommand">
                        <HeaderTemplate>
                            <div class="course-grid">
                        </HeaderTemplate>

                        <ItemTemplate>
                            <div class="course-card">

                                <asp:Image ID="imgCourse" runat="server"
                                    CssClass="course-image"
                                    ImageUrl='<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("CourseImage"))) 
                                        ? "~/CoursePicture/default-course.png" 
                                        : Eval("CourseImage") %>' />

                                <div class="course-menu-wrap">
                                    <button type="button"
                                        class="course-menu-btn"
                                        onclick="toggleCourseMenu(this, event)">
                                        <i class="fa-solid fa-ellipsis-vertical"></i>
                                    </button>

                                    <div class="course-menu">
                                        <asp:LinkButton ID="btnMoveTop" runat="server"
                                            CssClass="menu-action"
                                            CommandName="MoveTop"
                                            CommandArgument='<%# Eval("CourseId") + "|" + Eval("Session") %>'>
                                            <i class="fa-solid fa-angles-up"></i> Move Highest
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnMoveUp" runat="server"
                                            CssClass="menu-action"
                                            CommandName="MoveUp"
                                            CommandArgument='<%# Eval("CourseId") + "|" + Eval("Session") %>'>
                                            <i class="fa-solid fa-angle-up"></i> Move Up
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnMoveDown" runat="server"
                                            CssClass="menu-action"
                                            CommandName="MoveDown"
                                            CommandArgument='<%# Eval("CourseId") + "|" + Eval("Session") %>'>
                                            <i class="fa-solid fa-angle-down"></i> Move Down
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnMoveBottom" runat="server"
                                            CssClass="menu-action"
                                            CommandName="MoveBottom"
                                            CommandArgument='<%# Eval("CourseId") + "|" + Eval("Session") %>'>
                                            <i class="fa-solid fa-angles-down"></i> Move Bottom
                                        </asp:LinkButton>
                                    </div>
                                </div>

                                <div class="course-body">
                                    <div class="course-name"><%# Eval("CourseName") %></div>
                                    <div class="course-code"><%# Eval("CourseCode") %></div>

                                    <div class="course-session">
                                        <i class="fa-solid fa-calendar-days"></i>
                                        Session: <%# Eval("Session") %>
                                    </div>

                                    <div class="course-semester">
                                        <i class="fa-solid fa-layer-group"></i>
                                        Semester: <%# Eval("Semester") %>
                                    </div>
                                </div>

                            </div>
                        </ItemTemplate>

                        <FooterTemplate>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                        <i class="fa-solid fa-book-open"></i>
                        <h3>No courses found</h3>
                        <p>Try changing your filters.</p>
                    </asp:Panel>

                </div>
            </div>
        </div>
    </div>
<script>

    function toggleCourseMenu(button, e) {

        e.stopPropagation();

        var menu = button.nextElementSibling;

        var isOpen = menu.classList.contains('show');

        document.querySelectorAll('.course-menu').forEach(function (m) {
            m.classList.remove('show');
        });

        if (!isOpen) {
            menu.classList.add('show');
        }
    }

    document.addEventListener('click', function () {

        document.querySelectorAll('.course-menu').forEach(function (menu) {
            menu.classList.remove('show');
        });

    });

    document.querySelectorAll('.course-menu').forEach(function (menu) {

        menu.addEventListener('click', function (e) {
            e.stopPropagation();
        });

    });

</script>
</form>
</body>
</html>