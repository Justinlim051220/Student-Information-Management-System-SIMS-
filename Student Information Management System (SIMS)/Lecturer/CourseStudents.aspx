<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="CourseStudents.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.Lecturer.CourseStudents" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <title>Registered Students - SIMS Lecturer Portal</title>

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

        .student-table {
            width: 100%;
            border-collapse: collapse;
        }

        .student-table th {
            background: #fff8e1;
            color: var(--text-primary);
            font-size: 13px;
            text-align: left;
            padding: 14px;
        }

        .student-table td {
            padding: 14px;
            border-bottom: 1px solid var(--border-light);
            font-size: 14px;
        }

        .top-actions {
            margin-bottom: 18px;
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

        .course-action-bar {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 28px;
        }

        .course-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }

        .course-action-bar {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 0;
        }

        .course-action-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;

            height: 42px;
            padding: 0 20px;

            border-radius: var(--radius-pill);
            border: 2px solid var(--orange-main);
            background: var(--white);
            color: var(--orange-dark);

            font-family: var(--font-primary);
            font-size: 13px;
            font-weight: 700;
            line-height: 1;

            text-decoration: none;
            cursor: pointer;
            transition: var(--transition);
            box-sizing: border-box;
            white-space: nowrap;
        }
        .course-action-btn:hover,
        .course-action-btn.active {
            background: var(--orange-gradient);
            color: var(--white);
            border-color: transparent;
            box-shadow: var(--shadow-orange);
            transform: translateY(-2px);
        }

        .material-form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 22px;
        }

        .material-item {
            padding: 18px 20px;
            border: 1px solid var(--border-light);
            border-radius: 14px;
            margin-bottom: 14px;
            background: var(--white);
        }

        .material-item h3 {
            margin: 0 0 8px;
            font-size: 16px;
            color: var(--text-primary);
        }

        .material-item p {
            margin: 0 0 10px;
            color: var(--text-muted);
            font-size: 14px;
        }

        .material-meta {
            font-size: 12px;
            color: var(--text-muted);
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 12px;
        }

        .material-top {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: flex-start;
        }

        .material-actions {
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
            color: var(--text-primary);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            transition: var(--transition);
        }

        .icon-btn:hover {
            background: var(--orange-gradient);
            color: var(--white);
            border-color: transparent;
        }

        .icon-btn.danger:hover {
            background: #dc3545;
            color: #fff;
            border-color: transparent;
        }

        .edit-note {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 6px;
        }

        .posted-files-box {
            margin-top: 18px;
            padding: 14px;
            border: 1px solid var(--border-light);
            border-radius: 14px;
            background: #fffaf0;
        }

        .posted-files-title {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 10px;
        }

        .material-file-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            border: 1px solid var(--border-light);
            border-radius: 10px;
            padding: 10px 14px;
            margin-top: 8px;
            background: var(--white);
        }

        .material-file-row a {
            color: var(--orange-dark);
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            word-break: break-all;
        }

        .material-file-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-top: 10px;
        }

        .material-file-link {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            color: var(--orange-dark);
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
        }

        .material-file-link:hover {
            text-decoration: underline;
        }

        .material-form-actions {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 10px;
            margin-top: 18px;
        }

        .material-form-actions .btn {
            min-width: 140px;
        }

        .grade-table-wrap {
            width: 100%;
            overflow-x: auto;
        }

        .grade-readonly {
            font-weight: 700;
            color: var(--text-primary);
        }

        .grade-status {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 12px;
            border-radius: var(--radius-pill);
            font-size: 12px;
            font-weight: 800;
        }

        .grade-status.published {
            background: #eaf8ef;
            color: #207543;
        }

        .grade-status.unpublished {
            background: #fff3e0;
            color: var(--orange-dark);
        }

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
            from {
                transform: scale(.93);
                opacity: 0;
            }

            to {
                transform: scale(1);
                opacity: 1;
            }
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

        #customModal .icon-success {
            background: #fff8e1;
        }

        #customModal .icon-error {
            background: #fdecea;
        }

        #customModal .icon-warning {
            background: #fff3e0;
        }

        #customModal .icon-delete {
            background: #fdecea;
        }

        #cmIcon i {
            font-size: 30px;
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
            min-width: 110px;
        }

        #customModal .cm-btn-cancel,
        #customModal .cm-btn-ok {
            background: transparent;
            border: 2px solid #e8a838;
            color: #e8a838;
        }

        #customModal .cm-btn-delete {
            background: transparent;
            border: none;
            color: #e8a838;
            font-weight: 700;
        }

        @media (max-width: 900px) {
            .course-toolbar {
                align-items: flex-start;
            }

            .material-form-grid {
                grid-template-columns: 1fr;
            }

            .material-top {
                flex-direction: column;
            }

            .material-file-row {
                align-items: flex-start;
            }

        }
    </style>
</head>

<body>
<form id="form1" runat="server">

    <asp:HiddenField ID="hfEditMaterialId" runat="server" Value="0" />
    <asp:HiddenField ID="hfDeleteMaterialId" runat="server" Value="0" />
    <asp:HiddenField ID="hfDeleteFileId" runat="server" Value="0" />

    <asp:Button ID="btnDeleteMaterialConfirmed" runat="server"
        Style="display:none;"
        OnClick="btnDeleteMaterialConfirmed_Click" />

    <asp:Button ID="btnDeleteFileConfirmed" runat="server"
        Style="display:none;"
        OnClick="btnDeleteFileConfirmed_Click" />

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
                <div class="topbar-title">
                    <asp:Label ID="lblTopbarTitle" runat="server" Text="Registered Students" />
                </div>
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
                <h1>
                    <asp:Label ID="lblCourseTitle" runat="server" Text="Course Title" />
                </h1>
                <p>
                    <asp:Label ID="lblCourseInfo" runat="server" />
                </p>
            </div>

            <div class="course-toolbar">

                <div class="course-action-bar">

                    <asp:LinkButton ID="lbShowStudents" runat="server"
                        CssClass="course-action-btn active"
                        OnClick="lbShowStudents_Click">
                        <i class="fa-solid fa-user-graduate"></i>
                        Registered Students
                    </asp:LinkButton>

                    <asp:LinkButton ID="lbPostMaterial" runat="server"
                        CssClass="course-action-btn"
                        OnClick="lbPostMaterial_Click">
                        <i class="fa-solid fa-file-arrow-up"></i>
                        Post Material
                    </asp:LinkButton>

                    <asp:LinkButton ID="lbGrades" runat="server"
                        CssClass="course-action-btn"
                        OnClick="lbGrades_Click">
                        <i class="fa-solid fa-star-half-stroke"></i>
                        Grades
                    </asp:LinkButton>

                </div>

                   <asp:LinkButton ID="lbBackToCourses"
                        runat="server"
                        CssClass="course-action-btn"
                        OnClick="lbBackToCourses_Click">
                        <i class="fa-solid fa-arrow-left"></i>
                        Back to My Courses
                    </asp:LinkButton>

            </div>

            <asp:Panel ID="pnlStudentsSection" runat="server">
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Student List</span>

                        <span class="badge badge-orange">
                            <asp:Label ID="lblTotal" runat="server" Text="0" />
                            Students
                        </span>
                    </div>

                    <div class="card-body">
                        <asp:Repeater ID="rptStudents" runat="server">
                            <HeaderTemplate>
                                <table class="student-table">
                                    <thead>
                                        <tr>
                                            <th>No.</th>
                                            <th>Student ID</th>
                                            <th>Student Name</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>

                            <ItemTemplate>
                                <tr>
                                    <td><%# Container.ItemIndex + 1 %></td>
                                    <td><%# Eval("StudentId") %></td>
                                    <td><%# Eval("StudentName") %></td>
                                </tr>
                            </ItemTemplate>

                            <FooterTemplate>
                                    </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>

                        <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                            <i class="fa-solid fa-user-slash"></i>
                            <h3>No students found</h3>
                            <p>No students registered for this course and session.</p>
                        </asp:Panel>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlMaterialsSection" runat="server" Visible="false">

                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Post Course Material</span>
                    </div>

                    <div class="card-body">

                        <div class="material-form-grid">
                            <div class="form-group">
                                <label>Material Title *</label>
                                <asp:TextBox ID="txtMaterialTitle" runat="server" CssClass="form-control" />
                            </div>

                            <div class="form-group">
                                <label>Material Type *</label>
                                <asp:DropDownList ID="ddlMaterialType" runat="server" CssClass="form-control">
                                    <asp:ListItem Text="Select Material Type" Value="" />
                                    <asp:ListItem Text="Assignment" Value="Assignment" />
                                    <asp:ListItem Text="Lecture Notes" Value="Lecture Notes" />
                                    <asp:ListItem Text="Tutorial & Lab Exercise" Value="Tutorial & Lab Exercise" />
                                    <asp:ListItem Text="Final Exam" Value="Final Exam" />
                                </asp:DropDownList>
                            </div>

                            <div class="form-group">
                                <label>Attachment</label>
                                <asp:FileUpload ID="fuMaterial" runat="server" CssClass="form-control" AllowMultiple="true" />
                                <div class="edit-note">
                                    Attachments are optional. You can select multiple files if needed.
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Description</label>
                            <asp:TextBox ID="txtMaterialDescription" runat="server"
                                CssClass="form-control"
                                TextMode="MultiLine"
                                Rows="4" />
                        </div>

                        <asp:Panel ID="pnlExistingFiles" runat="server" CssClass="posted-files-box" Visible="false">
                            <div class="posted-files-title">
                                Recently Posted Files
                            </div>

                            <asp:Repeater ID="rptExistingFiles" runat="server">
                                <ItemTemplate>
                                    <div class="material-file-row">
                                        <a href='<%# ResolveUrl(Eval("FilePath").ToString()) %>' target="_blank">
                                            <i class="fa-solid fa-paperclip"></i>
                                            <%# Eval("FileName") %>
                                        </a>

                                        <asp:LinkButton ID="btnDeleteFile" runat="server"
                                            CssClass="icon-btn danger"
                                            CommandName="DeleteFile"
                                            CommandArgument='<%# Eval("FileId") %>'
                                            ToolTip="Delete File"
                                            OnClientClick='<%# "showDeleteFileModal(" + Eval("FileId") + "); return false;" %>'>
                                            <i class="fa-solid fa-trash"></i>
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:Panel>

                        <div class="material-form-actions">
                            <asp:Button ID="btnUploadMaterial" runat="server"
                                Text="Post Material"
                                CssClass="btn btn-primary"
                                OnClick="btnUploadMaterial_Click" />
                            <asp:Button ID="btnCancelEditMaterial" runat="server"
                                Text="Cancel"
                                CssClass="btn btn-outline"
                                Visible="false"
                                OnClick="btnCancelEditMaterial_Click" />
                        </div>
                    </div>
                </div>

                <div class="card" style="margin-top:24px;">
                    <div class="card-header">
                        <span class="card-title">Recently Posted Course Materials</span>

                        <span class="badge badge-orange">
                            <asp:Label ID="lblMaterialTotal" runat="server" Text="0" />
                            Posted
                        </span>
                    </div>

                    <div class="card-body">
                        <asp:Repeater ID="rptMaterials" runat="server"
                            OnItemCommand="rptMaterials_ItemCommand"
                            OnItemDataBound="rptMaterials_ItemDataBound">

                            <ItemTemplate>
                                <div class="material-item">
                                    <div class="material-top">
                                        <div>
                                            <h3><%# Eval("Title") %></h3>

                                            <div class="material-meta">
                                                <span>
                                                    <i class="fa-solid fa-calendar"></i>
                                                    <%# Eval("CreatedAt", "{0:dd MMM yyyy, hh:mm tt}") %>
                                                </span>

                                                <span>
                                                    <i class="fa-solid fa-tag"></i>
                                                    <%# Eval("MaterialType") %>
                                                </span>
                                            </div>
                                        </div>

                                        <div class="material-actions">
                                            <asp:LinkButton ID="btnEditMaterial" runat="server"
                                                CssClass="icon-btn"
                                                CommandName="EditMaterial"
                                                CommandArgument='<%# Eval("MaterialId") %>'
                                                ToolTip="Edit">
                                                <i class="fa-solid fa-pen"></i>
                                            </asp:LinkButton>

                                            <asp:LinkButton ID="btnDeleteMaterial" runat="server"
                                                CssClass="icon-btn danger"
                                                CommandName="DeleteMaterial"
                                                CommandArgument='<%# Eval("MaterialId") %>'
                                                ToolTip="Delete"
                                                OnClientClick='<%# "showDeleteMaterialModal(" + Eval("MaterialId") + "); return false;" %>'>
                                                <i class="fa-solid fa-trash"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </div>

                                    <p><%# Eval("Description") %></p>

                                    <div class="material-file-list">
                                        <asp:Repeater ID="rptMaterialFiles" runat="server">
                                            <ItemTemplate>
                                                <a href='<%# ResolveUrl(Eval("FilePath").ToString()) %>'
                                                    target="_blank"
                                                    class="material-file-link">
                                                    <i class="fa-solid fa-paperclip"></i>
                                                    <%# Eval("FileName") %>
                                                </a>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <asp:Panel ID="pnlNoMaterials" runat="server" CssClass="empty-state" Visible="false">
                            <i class="fa-solid fa-folder-open"></i>
                            <h3>No course materials posted</h3>
                            <p>Uploaded course materials will appear here.</p>
                        </asp:Panel>
                    </div>
                </div>

            </asp:Panel>
            <asp:Panel ID="pnlGradesSection" runat="server" Visible="false">

    <div class="card">
        <div class="card-header">
            <span class="card-title">Student Grades</span>

            <span class="badge badge-orange">
                <asp:Label ID="lblGradeTotal" runat="server" Text="0" />
                Students
            </span>

            <asp:Label ID="lblGradePublishStatus" runat="server"
                CssClass="grade-status unpublished"
                Text="Not Published" />
        </div>

        <div class="card-body">

            <div class="grade-table-wrap">
                <asp:GridView ID="gvGrades" runat="server"
                    AutoGenerateColumns="true"
                    CssClass="student-table"
                    GridLines="None"
                    OnRowDataBound="gvGrades_RowDataBound">
                </asp:GridView>
            </div>

            <asp:Panel ID="pnlNoGrades" runat="server" CssClass="empty-state" Visible="false">
                <i class="fa-solid fa-user-slash"></i>
                <h3>No students found</h3>
                <p>No active students are enrolled in this course and session.</p>
            </asp:Panel>

            <div class="material-form-actions">
                <asp:Button ID="btnSaveGrades" runat="server"
                    Text="Save Marks"
                    CssClass="btn btn-primary"
                    OnClick="btnSaveGrades_Click" />

                <asp:Button ID="btnEditGrades" runat="server"
                    Text="Edit Marks"
                    CssClass="btn btn-outline"
                    Visible="false"
                    OnClick="btnEditGrades_Click" />

                <asp:Button ID="btnPublishGrades" runat="server"
                    Text="Publish Marks"
                    CssClass="btn btn-primary"
                    OnClick="btnPublishGrades_Click" />
            </div>

        </div>
    </div>

</asp:Panel>
        </div>
    </div>

    <div id="customModalOverlay">
        <div id="customModal">
            <div id="cmIconWrap" class="cm-icon-wrap">
                <div id="cmIcon"></div>
            </div>

            <div id="cmTitle" class="cm-title">Message</div>
            <hr class="cm-divider" />

            <div id="cmBody" class="cm-body"></div>

            <div class="cm-footer">
                <button type="button" id="cmBtnOk" class="cm-btn cm-btn-ok" onclick="closeCustomModal()">OK</button>
                <button type="button" id="cmBtnCancel" class="cm-btn cm-btn-cancel" onclick="closeCustomModal()">Cancel</button>
                <button type="button" id="cmBtnDelete" class="cm-btn cm-btn-delete">Delete</button>
            </div>
        </div>
    </div>

    <script>
        function showMessageModal(title, message, type) {
            var iconWrap = document.getElementById('cmIconWrap');
            var iconEl = document.getElementById('cmIcon');
            var titleEl = document.getElementById('cmTitle');
            var body = document.getElementById('cmBody');

            iconWrap.className = 'cm-icon-wrap';

            if (type === 'success') {
                iconWrap.classList.add('icon-success');
                iconEl.innerHTML = '<i class="fa-solid fa-check" style="color:#e8a838;"></i>';
                titleEl.innerHTML = 'Success';
            } else if (type === 'danger') {
                iconWrap.classList.add('icon-error');
                iconEl.innerHTML = '<i class="fa-solid fa-xmark" style="color:#e74c3c;"></i>';
                titleEl.innerHTML = 'Error';
            } else {
                iconWrap.classList.add('icon-warning');
                iconEl.innerHTML = '<i class="fa-solid fa-triangle-exclamation" style="color:#e8a838;"></i>';
                titleEl.innerHTML = title || 'Edit Mode';
            }

            body.innerHTML = message;

            document.getElementById('cmBtnOk').style.display = 'inline-block';
            document.getElementById('cmBtnCancel').style.display = 'none';
            document.getElementById('cmBtnDelete').style.display = 'none';

            document.getElementById('customModalOverlay').classList.add('active');
        }

        function showDeleteMaterialModal(materialId) {
            document.getElementById('cmIconWrap').className = 'cm-icon-wrap icon-delete';
            document.getElementById('cmIcon').innerHTML = '<i class="fa-solid fa-trash" style="color:#e74c3c;"></i>';
            document.getElementById('cmTitle').innerHTML = 'Confirm Delete';
            document.getElementById('cmBody').innerHTML = 'Are you sure you want to delete this course material and all attached files?';

            document.getElementById('cmBtnOk').style.display = 'none';
            document.getElementById('cmBtnCancel').style.display = 'inline-block';
            document.getElementById('cmBtnDelete').style.display = 'inline-block';

            document.getElementById('cmBtnDelete').onclick = function () {
                document.getElementById('<%= hfDeleteMaterialId.ClientID %>').value = materialId;
                closeCustomModal();
                document.getElementById('<%= btnDeleteMaterialConfirmed.ClientID %>').click();
            };

            document.getElementById('customModalOverlay').classList.add('active');
        }

        function showDeleteFileModal(fileId) {
            document.getElementById('cmIconWrap').className = 'cm-icon-wrap icon-delete';
            document.getElementById('cmIcon').innerHTML = '<i class="fa-solid fa-trash" style="color:#e74c3c;"></i>';
            document.getElementById('cmTitle').innerHTML = 'Confirm Delete';
            document.getElementById('cmBody').innerHTML = 'Are you sure you want to delete this file only?';

            document.getElementById('cmBtnOk').style.display = 'none';
            document.getElementById('cmBtnCancel').style.display = 'inline-block';
            document.getElementById('cmBtnDelete').style.display = 'inline-block';

            document.getElementById('cmBtnDelete').onclick = function () {
                document.getElementById('<%= hfDeleteFileId.ClientID %>').value = fileId;
                closeCustomModal();
                document.getElementById('<%= btnDeleteFileConfirmed.ClientID %>').click();
            };

            document.getElementById('customModalOverlay').classList.add('active');
        }

        function closeCustomModal() {
            document.getElementById('customModalOverlay').classList.remove('active');
        }
    </script>

</form>
</body>
</html>

