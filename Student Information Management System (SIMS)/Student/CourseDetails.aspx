<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CourseDetails.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student.CourseDetails" %>
<%@ Register Src="~/Student/StudentSidebar.ascx" TagPrefix="uc" TagName="StudentSidebar" %>

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
        html,
        body {
            margin: 0;
            padding: 0;
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
            color: var(--text-main);
            overflow-x: hidden;
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
            width: calc(100% - 260px);
            box-sizing: border-box;
        }

        .page-content {
            padding: 30px 40px;
            width: 100%;
            box-sizing: border-box;
        }

        .container {
            width: 100%;
            max-width: 100%;
            box-sizing: border-box;
        }

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

        .tab-btn:hover,
        .tab-btn.active {
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

    <uc:StudentSidebar ID="StudentSidebar1" runat="server" />

    <div class="main-wrapper">
        <div class="topbar">
            <div>
                <div class="topbar-title">Course Details</div>
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
            <div class="container">

                <a href="MyCourses.aspx" class="back-link">
                    <i class="fa-solid fa-arrow-left"></i> Back to Enrolled Modules
                </a>

                <div class="course-card-header">
                    <div class="course-meta-top">
                        <asp:Label ID="lblCourseCode" runat="server" />
                        &bull;
                        <asp:Label ID="lblCredits" runat="server" /> Credits
                    </div>

                    <h1>
                        <asp:Label ID="lblCourseName" runat="server" />
                    </h1>

                    <p style="margin:0; color:#5a626a; line-height:1.5;">
                        <asp:Label ID="lblDescription" runat="server" />
                    </p>

                    <div class="lecturer-info">
                        <i class="fa-solid fa-chalkboard-user"></i>
                        <span>
                            Instructor:
                            <strong><asp:Label ID="lblLecturerName" runat="server" Text="Not Assigned Yet" /></strong>
                        </span>
                    </div>
                </div>

                <div class="navigation-tabs">
                    <asp:LinkButton ID="btnModulesTab"
                        runat="server"
                        CssClass="tab-btn active"
                        OnClick="btnModulesTab_Click">
                        <i class="fa-solid fa-file-lines"></i> Modules
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnGradesTab"
                        runat="server"
                        CssClass="tab-btn"
                        OnClick="btnGradesTab_Click">
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

                                                <a href='<%# GetDownloadUrl(Eval("FileId"), Eval("FilePath")) %>' class="btn-download">
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

                    <div class="course-card-header" style="background:#fff; padding:20px; border-radius:14px; border:1px solid #eef0f4; overflow-x:auto;">
                        <asp:GridView ID="gvStudentGrades"
                            runat="server"
                            CssClass="student-table"
                            GridLines="None"
                            AutoGenerateColumns="true"
                            OnRowDataBound="gvStudentGrades_RowDataBound">
                            <HeaderStyle BackColor="#fff8e1" Font-Bold="true" HorizontalAlign="Left" />
                            <RowStyle BackColor="#ffffff" />
                        </asp:GridView>

                        <asp:Panel ID="pnlNoGrades" runat="server" Visible="false" Style="text-align:center; padding:40px 20px;">
                            <i class="fa-solid fa-graduation-cap" style="font-size:46px; color:#e8a838; margin-bottom:12px; display:block;"></i>
                            <h3>No marks have been posted or published yet.</h3>
                        </asp:Panel>
                    </div>
                </asp:Panel>

            </div>
        </div>
    </div>

</form>
</body>
</html>