<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CourseDetails.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student.CourseDetails" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Course Materials & Details - SIMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="../Styles/SIMS.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style>
        /* ===== Synchronized Sidebar Layout Metrics ===== */
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

        .sidebar-user {
            margin-bottom: 18px;
            align-items: flex-start;
        }

        .user-info {
            padding-top: 4px;
        }

        .user-name {
            margin-bottom: 4px;
        }

        .user-role {
            margin-top: 2px;
        }

        /* ===== Main Wrapper Layout Configuration ===== */
        .main-wrapper {
            margin-left: 260px;
            width: calc(100% - 260px);
            box-sizing: border-box;
        }

        .page-content {
            padding: 30px 40px;
            width: 100%;
            box-sizing: border-box;
        }

        /* Expanded Container Rules: Prevents empty right area */
        .container {
            width: 100%;
            max-width: 100%;
            box-sizing: border-box;
        }

        :root {
            --primary: #1a1a2e;
            --accent: #d99a2e;
            --accent-hover: #e8a838;
            --bg-neutral: #f7f8fa;
            --text-main: #2c3e50;
            --text-muted: #6c757d;
            --border-color: #eef0f4;
        }

        body {
            font-family: 'Nunito', 'Poppins', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-neutral);
            margin: 0;
            padding: 0;
            color: var(--text-main);
            overflow-x: hidden;
        }

        /* ===== Oval Filter Buttons Layout ===== */
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            background-color: #e8a838;
            color: #fff !important;
            font-family: 'Nunito', sans-serif;
            font-weight: 700;
            font-size: 14px;
            padding: 8px 22px;
            border-radius: 50px;
            margin-bottom: 25px;
            box-shadow: 0 4px 12px rgba(232, 168, 56, 0.15);
            transition: all 0.2s ease-in-out;
        }

        .back-link:hover {
            background-color: #d99a2e;
            transform: translateY(-1px);
            box-shadow: 0 6px 14px rgba(217, 154, 46, 0.25);
        }

        .btn-download {
            font-family: 'Nunito', sans-serif;
            font-size: 13px;
            color: #fff !important;
            background-color: #e8a838;
            text-decoration: none;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 18px;
            border-radius: 50px;
            box-shadow: 0 3px 10px rgba(232, 168, 56, 0.12);
            transition: all 0.2s ease-in-out;
        }

        .btn-download:hover {
            text-decoration: none;
            background-color: #d99a2e;
            transform: translateY(-1px);
            box-shadow: 0 5px 12px rgba(217, 154, 46, 0.22);
        }

        /* ===== Full Width Cards ===== */
        .course-card-header {
            background: #fff;
            padding: 30px;
            border-radius: 14px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            border: 1px solid var(--border-color);
            margin-bottom: 30px;
            width: 100%;
            box-sizing: border-box;
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
            width: 100%;
            box-sizing: border-box;
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
            padding: 14px 16px;
            border: 1px solid #e9ecef;
        }

        .file-list-title {
            font-size: 12px;
            font-weight: 700;
            color: var(--text-muted);
            text-transform: uppercase;
            margin-bottom: 12px;
            letter-spacing: 0.5px;
        }

        .file-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
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
            color: #dc3545;
        }

        .file-size {
            font-size: 12px;
            color: var(--text-muted);
            margin-left: 5px;
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
            width: 100%;
            box-sizing: border-box;
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

        /* ===== Synchronized Logout Modal Styles ===== */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(30, 30, 40, .60);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            padding: 18px;
        }
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

        /* ===== Added Tabs Navigation Styles ===== */
        .navigation-tabs {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 25px;
        }

        .tab-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 24px;
            border-radius: 50px;
            font-family: 'Nunito', sans-serif;
            font-weight: 700;
            font-size: 14px;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
            background-color: #fff;
            color: #e8a838;
            border: 2px solid #e8a838;
        }

        .tab-btn:hover, .tab-btn.active {
            background-color: #e8a838;
            color: #fff !important;
            border-color: #e8a838;
        }

        .student-table {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
        }

        .student-table th {
            background: #fff8e1;
            color: var(--text-primary);
            font-size: 13px;
            font-weight: 700;
            text-align: left;
            padding: 14px;
            border-bottom: 2px solid #eef0f4;
        }

        .student-table td {
            padding: 14px;
            border-bottom: 1px solid #eef0f4;
            font-size: 14px;
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
                    <div class="brand-sub">Student Portal</div>
                </div>
            </div>

            <nav class="sidebar-nav">
                <div class="sidebar-section-label">Main</div>
                <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/Student/Student_Dashboard.aspx" CssClass="sidebar-link">
                    <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
                </asp:HyperLink>

                <div class="sidebar-section-label" style="margin-top:12px;">Academic</div>
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

                <div class="sidebar-section-label" style="margin-top:12px;">Finance</div>
                <asp:HyperLink ID="lnkPayment" runat="server" NavigateUrl="~/Student/Student_Payment.aspx" CssClass="sidebar-link">
                    <i class="fa-solid fa-money-bill-wave nav-icon"></i> Payment
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
                <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link" OnClientClick="showLogoutModal(); return false;">
                    <i class="fa-solid fa-right-from-bracket"></i> Log Out
                </asp:LinkButton>
            </div>
        </div>
        
        <div class="main-wrapper">
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

                    <div class="navigation-tabs">
                        <asp:LinkButton ID="btnModulesTab" runat="server" CssClass="tab-btn active" OnClick="btnModulesTab_Click">
                            <i class="fa-solid fa-file-lines"></i> Modules
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnGradesTab" runat="server" CssClass="tab-btn" OnClick="btnGradesTab_Click">
                            <i class="fa-solid fa-star"></i> Grades
                        </asp:LinkButton>
                    </div>

                    <asp:Panel ID="pnlModulesSection" runat="server" Visible="true">
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
                    </asp:Panel>

                    <asp:Panel ID="pnlGradesSection" runat="server" Visible="false">
                        <div class="section-title">
                            <i class="fa-solid fa-square-poll-vertical"></i> Course Grades
                        </div>
                        <div class="course-card-header" style="background: #fff; padding: 20px; border-radius: 14px; border: 1px solid #eef0f4; overflow-x: auto;">
                            <asp:GridView ID="gvStudentGrades" runat="server" CssClass="student-table" GridLines="None" AutoGenerateColumns="true">
                                <HeaderStyle BackColor="#fff8e1" Font-Bold="true" HorizontalAlign="Left" />
                                <RowStyle BackColor="#ffffff" />
                            </asp:GridView>
                            <asp:Panel ID="pnlNoGrades" runat="server" Visible="false" style="text-align:center; padding: 40px 20px;">
                                <i class="fa-solid fa-graduation-cap" style="font-size: 46px; color: #e8a838; margin-bottom: 12px; display:block;"></i>
                                <h3>No marks have been posted or published yet.</h3>
                            </asp:Panel>
                        </div>
                    </asp:Panel>

                </div>
            </div>
        </div>
        
        <div id="logoutModal" class="modal-overlay system-dialog">
            <div class="modal-box">
                <div class="modal-head">
                    <div class="logout-warning-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                    <span>Log Out</span>
                </div>
                <div class="modal-body">
                    Are you sure you want to log out?
                </div>
                <div class="modal-actions">
                    <button type="button" class="modal-cancel" onclick="hideLogoutModal();">Cancel</button>
                    <asp:LinkButton ID="btnConfirmLogout" runat="server" CssClass="modal-submit" OnClick="lbLogout_Click">
                        Log Out
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