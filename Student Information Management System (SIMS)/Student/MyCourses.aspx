<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyCourses.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student.MyCourses" %>
<%@ Register Src="~/Student/StudentSidebar.ascx" TagPrefix="uc" TagName="StudentSidebar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Courses - SIMS Student Portal</title>

    <link rel="stylesheet" href="../Styles/SIMS.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        html,
        body {
            margin: 0;
            padding: 0;
        }

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
            min-height: 190px;
        }

        .course-card:hover {
            box-shadow: var(--shadow-card);
            transform: translateY(-2px);
        }

        .course-body-link {
            display: block;
            padding: 26px 20px 20px;
            cursor: pointer;
            color: inherit;
            text-decoration: none;
        }



        .course-menu-wrap {
            position: absolute;
            top: 12px;
            right: 12px;
            z-index: 50;
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
            box-shadow: 0 12px 28px rgba(0,0,0,.16);
            padding: 8px;
            z-index: 99999;
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

        .course-name {
            font-family: var(--font-accent);
            font-size: 18px;
            font-weight: 800;
            color: var(--text-primary);
            margin-bottom: 8px;
            padding-right: 25px;
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
    </style>
</head>

<body>
<form id="form1" runat="server">

    <uc:StudentSidebar ID="StudentSidebar1" runat="server" />

    <div class="main-wrapper">
        <div class="topbar">
            <div>
                <div class="topbar-title">My Courses</div>
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
            </div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <h1>My Enrolled Courses</h1>
                <p>View your registered academic modules and course details.</p>
            </div>

            <asp:Label ID="lblMessage"
                runat="server"
                CssClass="alert alert-danger"
                Visible="false"
                Style="display:block; margin-bottom:20px; padding:12px; border-radius:4px;" />

            <div class="card" style="margin-bottom:24px;">
                <div class="card-body">
                    <div class="filter-bar">
                        <div class="filter-item">
                            <label>Academic Session</label>
                            <asp:DropDownList ID="ddlFilterSession"
                                runat="server"
                                CssClass="form-control"
                                AutoPostBack="true"
                                OnSelectedIndexChanged="ddlFilterSession_SelectedIndexChanged" />
                        </div>

                        <div class="filter-item">
                            <label>Semester</label>
                            <asp:DropDownList ID="ddlFilterSemester"
                                runat="server"
                                CssClass="form-control"
                                AutoPostBack="true"
                                OnSelectedIndexChanged="ddlFilterSemester_SelectedIndexChanged" />
                        </div>

                        <div class="filter-item">
                            <asp:Button ID="btnSearch"
                                runat="server"
                                Text="Filter"
                                CssClass="btn btn-primary btn-sm"
                                OnClick="btnSearch_Click"
                                Style="width:auto;" />
                        </div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <span class="card-title">Enrolled Courses</span>
                    <span class="badge badge-orange">
                        <asp:Label ID="lblTotal" runat="server" Text="0" /> Modules
                    </span>
                </div>

                <div class="card-body">
                    <asp:Repeater ID="rptCourses" runat="server" OnItemCommand="rptCourses_ItemCommand">
                        <HeaderTemplate>
                            <div class="course-grid">
                        </HeaderTemplate>

                        <ItemTemplate>
                            <div class="course-card">
                                <div class="course-menu-wrap" onclick="event.stopPropagation();">
                                    <button type="button"
                                        class="course-menu-btn"
                                        onclick="toggleCourseMenu(this, event)">
                                        <i class="fa-solid fa-ellipsis-vertical"></i>
                                    </button>

                                    <div class="course-menu">
                                        <asp:LinkButton ID="btnMoveTop" runat="server"
                                            CssClass="menu-action"
                                            CommandName="MoveTop"
                                            CommandArgument='<%# Eval("CourseId") + "|" + Eval("Session") + "|" + Eval("Semester") %>'>
                                            <i class="fa-solid fa-angles-up"></i> Move Highest
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnMoveUp" runat="server"
                                            CssClass="menu-action"
                                            CommandName="MoveUp"
                                            CommandArgument='<%# Eval("CourseId") + "|" + Eval("Session") + "|" + Eval("Semester") %>'>
                                            <i class="fa-solid fa-angle-up"></i> Move Up
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnMoveDown" runat="server"
                                            CssClass="menu-action"
                                            CommandName="MoveDown"
                                            CommandArgument='<%# Eval("CourseId") + "|" + Eval("Session") + "|" + Eval("Semester") %>'>
                                            <i class="fa-solid fa-angle-down"></i> Move Down
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnMoveBottom" runat="server"
                                            CssClass="menu-action"
                                            CommandName="MoveBottom"
                                            CommandArgument='<%# Eval("CourseId") + "|" + Eval("Session") + "|" + Eval("Semester") %>'>
                                            <i class="fa-solid fa-angles-down"></i> Move Bottom
                                        </asp:LinkButton>
                                    </div>
                                </div>

                                <a class="course-body-link"
                                   href='CourseDetails.aspx?courseId=<%# Eval("CourseId") %>&session=<%# Server.UrlEncode(Convert.ToString(Eval("Session"))) %>'>
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
                                </a>
                            </div>
                        </ItemTemplate>

                        <FooterTemplate>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                        <i class="fa-solid fa-book-open"></i>
                        <h3>No courses found</h3>
                        <p>You are not enrolled in any modules for the selected criteria.</p>
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

        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.course-menu').forEach(function (menu) {
                menu.addEventListener('click', function (e) {
                    e.stopPropagation();
                });
            });
        });
    </script>

</form>
</body>
</html>