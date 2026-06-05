<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CourseDetails.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student.CourseDetails" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Course Materials & Details - SIMS</title>
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

        .page-content {
            padding: 30px 40px;
        }

        .container {
            max-width: 1000px;
            width: 100%;
        }

        :root {
            --primary: #1a1a2e;
            --accent: #0d6efd;
            --accent-hover: #0b5ed7;
            --bg-neutral: #f7f8fa;
            --text-main: #2c3e50;
            --text-muted: #6c757d;
            --border-color: #eef0f4;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-neutral);
            margin: 0;
            padding: 0;
            color: var(--text-main);
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            color: var(--black);
            font-weight: 600;
            margin-bottom: 25px;
            transition: color 0.2s ease;
        }

        .back-link:hover {
            color: var(--accent-hover);
        }

        .course-card-header {
            background: #fff;
            padding: 30px;
            border-radius: 14px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            border: 1px solid var(--border-color);
            margin-bottom: 30px;
        }

        .course-meta-top {
            font-size: 14px;
            font-weight: 700;
            color: var(--orange-dark);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 5px;
        }

        .course-card-header h1 {
            margin: 0 0 10px 0;
            font-size: 28px;
            color: var(--primary);
        }

        .lecturer-info {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px dashed var(--border-color);
            font-size: 14px;
            color: var(--text-muted);
        }

        .lecturer-info i {
            color: var(--orange-dark);
        }

        .section-title {
            font-size: 20px;
            font-weight: 700;
            color: var(--primary);
            margin: 35px 0 15px 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .material-post {
            background: #fff;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.02);
            border: 1px solid var(--border-color);
        }

        .material-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 15px;
            margin-bottom: 12px;
        }

        .material-title {
            margin: 0;
            font-size: 18px;
            color: var(--primary);
            font-weight: 600;
        }

        .badge-group {
            display: flex;
            gap: 8px;
        }

        .badge {
            display: inline-block;
            padding: 4px 10px;
            font-size: 12px;
            font-weight: 600;
            border-radius: 20px;
            background: #e9ecef;
            color: #495057;
        }

        .badge-type {
            background: #e3f2fd;
            color: #0d6efd;
        }

        .badge-weight {
            background: #fff3cd;
            color: #856404;
        }

        .material-desc {
            font-size: 14px;
            color: #5a626a;
            line-height: 1.6;
            margin: 0 0 20px 0;
            white-space: pre-line;
        }

        .file-list-box {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 12px 16px;
            border: 1px solid #e9ecef;
        }

        .file-list-title {
            font-size: 12px;
            font-weight: 700;
            color: var(--text-muted);
            text-transform: uppercase;
            margin-bottom: 10px;
            letter-spacing: 0.5px;
        }

        .file-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            border-bottom: 1px solid #edf0f2;
        }

        .file-row:last-child {
            border-bottom: none;
        }

        .file-info {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 14px;
        }

        .file-info i {
            font-size: 16px;
            color: #dc3545; /* Default file icon color */
        }

        .file-size {
            font-size: 12px;
            color: var(--text-muted);
            margin-left: 5px;
        }

        .btn-download {
            font-size: 13px;
            color: var(--accent);
            text-decoration: none;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .btn-download:hover {
            text-decoration: underline;
            color: var(--accent-hover);
        }

        .post-footer-date {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 15px;
            text-align: right;
        }

        .empty-container {
            text-align: center;
            padding: 60px 20px;
            background: #fff;
            border-radius: 14px;
            border: 1px dashed #ced4da;
            color: var(--text-muted);
        }

        .empty-container i {
            font-size: 48px;
            color: #dee2e6;
            margin-bottom: 15px;
        }

        .empty-container h3 {
            margin: 0 0 8px 0;
            color: var(--primary);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- ================================================================
             SIDEBAR
             ================================================================ -->
        <div class="sidebar" id="sidebar">
            <!-- Brand -->
            <div class="sidebar-brand">
                <img src="~/Images/Logo_Dashboard.png" runat="server" alt="ONTI SIMS" class="brand-logo" />
                <div class="brand-text">
                    <div class="brand-name">SIMS</div>
                    <div class="brand-sub">Student Portal</div>
                </div>
            </div>

            <!-- Navigation -->
            <nav class="sidebar-nav">
                <div class="sidebar-section-label">Main</div>

                <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/Student/Student_Dashboard.aspx" CssClass="sidebar-link">
                    <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
                </asp:HyperLink>

                <asp:HyperLink ID="lnkMyCourses" runat="server" NavigateUrl="~/Student/MyCourses.aspx" CssClass="sidebar-link active">
                    <i class="fa-solid fa-book-open nav-icon"></i> My Courses
                </asp:HyperLink>

                <asp:HyperLink ID="lnkAttendance" runat="server" NavigateUrl="~/Student/Attendance.aspx" CssClass="sidebar-link">
                    <i class="fa-solid fa-calendar-check nav-icon"></i> Attendance
                </asp:HyperLink>

                <asp:HyperLink ID="lnkEnrollment" runat="server" NavigateUrl="~/Student/Student_Enrollment.aspx" CssClass="sidebar-link">
                    <i class="fa-solid fa-clipboard-list nav-icon"></i> Enrollment
                </asp:HyperLink>

                <asp:HyperLink ID="lnkResults" runat="server" NavigateUrl="~/Student/Results.aspx" CssClass="sidebar-link">
                    <i class="fa-solid fa-chart-line nav-icon"></i> Results
                </asp:HyperLink>

                <asp:HyperLink ID="lnkAcademicHistory" runat="server" NavigateUrl="~/Student/AcademicHistory.aspx" CssClass="sidebar-link">
                    <i class="fa-solid fa-clock-rotate-left nav-icon"></i> Academic History
                </asp:HyperLink>

                <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>

                <asp:HyperLink ID="lnkNotifications" runat="server" NavigateUrl="~/Student/Notifications.aspx" CssClass="sidebar-link">
                    <i class="fa-solid fa-bell nav-icon"></i> Notifications
                    <asp:Panel ID="pnlSidebarNotifBadge" runat="server" CssClass="badge-dot" Visible="false" style="margin-left:auto;" />
                </asp:HyperLink>

                <asp:HyperLink ID="lnkContacts" runat="server" NavigateUrl="~/Student/Contacts.aspx" CssClass="sidebar-link">
                    <i class="fa-solid fa-address-book nav-icon"></i> Contacts
                </asp:HyperLink>

                <div class="sidebar-section-label" style="margin-top:12px;">Account</div>

                <asp:HyperLink ID="lnkProfile" runat="server" NavigateUrl="~/Student/MyProfile.aspx" CssClass="sidebar-link">
                    <i class="fa-solid fa-circle-user nav-icon"></i> My Profile
                </asp:HyperLink>
            </nav>

            <!-- Sidebar user footer -->
            <div class="sidebar-footer">
                <div class="sidebar-user">
                    <div class="user-avatar">
                        <asp:Label ID="lblAvatarInitial" runat="server" Text="S" />
                    </div>
                    <div class="user-info">
                        <div class="user-name">
                            <asp:Label ID="lblSidebarName" runat="server" Text="Student" />
                        </div>
                        <div class="user-role">Student</div>
                    </div>
                </div>
                <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link"
                    OnClientClick="showLogoutModal(); return false;">
                    <i class="fa-solid fa-right-from-bracket"></i> Log Out
                </asp:LinkButton>
            </div>
        </div><!-- /sidebar -->

        <!-- ================================================================
             MAIN CONTENT
             ================================================================ -->
        <div class="main-wrapper">
            <!-- Topbar -->
            <div class="topbar">
                <div>
                    <div class="topbar-title">Course Details</div>
                    <div class="topbar-date">
                        <asp:Label ID="lblDate" runat="server" />
                    </div>
                </div>
                <div class="topbar-right">
                    <a href="Notifications.aspx" class="topbar-icon-btn" title="Notifications">
                        <i class="fa-solid fa-bell"></i>
                        <asp:Panel ID="pnlNotifBadge" runat="server" CssClass="badge-dot" Visible="false" />
                    </a>
                    <a href="MyProfile.aspx" class="topbar-icon-btn" title="My Profile">
                        <i class="fa-solid fa-circle-user"></i>
                    </a>
                </div>
            </div>

            <!-- Page content -->
            <div class="page-content">
                <div class="container">
            
            <a href="MyCourses.aspx" class="back-link">
                <i class="fa-solid fa-arrow-left"></i> Back to Enrolled Modules
            </a>

            <div class="course-card-header">
                <div class="course-meta-top">
                    <asp:Label ID="lblCourseCode" runat="server" /> &bull; <asp:Label ID="lblCredits" runat="server" /> Credits
                </div>
                <h1><asp:Label ID="lblCourseName" runat="server" /></h1>
                <p style="margin: 0; color: #5a626a; line-height: 1.5;">
                    <asp:Label ID="lblDescription" runat="server" />
                </p>
                
                <div class="lecturer-info">
                    <i class="fa-solid fa-chalkboard-user"></i>
                    <span>Instructor: <strong><asp:Label ID="lblLecturerName" runat="server" Text="Not Assigned Yet" /></strong></span>
                </div>
            </div>

            <div class="section-title">
                <i class="fa-solid fa-folder-open"></i> Learning References & Materials
            </div>

            <asp:Repeater ID="rptMaterials" runat="server" OnItemDataBound="rptMaterials_ItemDataBound">
                <ItemTemplate>
                    <div class="material-post">
                        <asp:HiddenField ID="hfMaterialId" runat="server" Value='<%# Eval("MaterialId") %>' />
                        <asp:HiddenField ID="hfLegacyFileName" runat="server" Value='<%# Eval("FileName") %>' />
                        <asp:HiddenField ID="hfLegacyFilePath" runat="server" Value='<%# Eval("FilePath") %>' />
                        <asp:HiddenField ID="hfLegacyFileType" runat="server" Value='<%# Eval("FileType") %>' />
                        <asp:HiddenField ID="hfLegacyFileSize" runat="server" Value='<%# Eval("FileSizeKB") %>' />

                        <div class="material-top">
                            <h3 class="material-title"><%# Eval("Title") %></h3>
                            <div class="badge-group">
                                <span class="badge badge-type"><%# Eval("MaterialType") %></span>
                            </div>
                        </div>

                        <p class="material-desc"><%# Eval("Description") %></p>

                        <div class="file-list-box">
                            <div class="file-list-title">Attachments</div>
                            
                            <asp:Repeater ID="rptFiles" runat="server">
                                <ItemTemplate>
                                    <div class="file-row">
                                        <div class="file-info">
                                            <i class="fa-solid fa-file-pdf"></i>
                                            <span><%# Eval("FileName") %></span>
                                            <span class="file-size">(<%# Eval("FileSizeKB") %> KB)</span>
                                        </div>
                                        <a href='<%# ResolveUrl(Eval("FilePath").ToString()) %>' class="btn-download" target="_blank">
                                            <i class="fa-solid fa-download"></i> Open File
                                        </a>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <div class="post-footer-date">
                            Posted on: <%# Eval("CreatedAt", "{0:dd MMM yyyy, hh:mm tt}") %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoMaterials" runat="server" CssClass="empty-container" Visible="false">
                <i class="fa-solid fa-box-open"></i>
                <h3>No materials posted yet</h3>
                <p>Your lecturer hasn't uploaded files or references for this course section.</p>
            </asp:Panel>

                </div><!-- /container -->
            </div><!-- /page-content -->
        </div><!-- /main-wrapper -->

        <!-- Logout Modal -->
        <div id="logoutModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(26,26,46,0.85); z-index: 9999; align-items: center; justify-content: center;">
            <div style="background: white; border-radius: 12px; width: 100%; max-width: 380px; box-shadow: 0 15px 35px rgba(0,0,0,0.3); overflow: hidden;">
                <div style="padding: 25px 30px 10px; text-align: center; border-bottom: 1px solid #eee;">
                    <h3>🔒 Log Out</h3>
                </div>
                <div style="padding: 25px 30px; text-align: center; color: #555;">
                    <p>Are you sure you want to log out of SIMS?</p>
                </div>
                <div style="padding: 20px 30px 25px; display: flex; gap: 12px; justify-content: center; border-top: 1px solid #eee;">
                    <button type="button" onclick="hideLogoutModal()" style="padding: 10px 24px;" class="btn btn-outline">Cancel</button>
                    <asp:LinkButton ID="btnConfirmLogout" runat="server" CssClass="btn btn-danger" OnClick="lbLogout_Click">
                        Yes, Log Out
                    </asp:LinkButton>
                </div>
            </div>
        </div>

        <script>
            function showLogoutModal() { document.getElementById('logoutModal').style.display = 'flex'; }
            function hideLogoutModal() { document.getElementById('logoutModal').style.display = 'none'; }
        </script>
    </form>
</body>
</html>