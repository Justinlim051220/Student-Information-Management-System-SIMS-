<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Lecturer.Profile" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Profile - SIMS Lecturer Portal</title>

    <link rel="stylesheet" href="../Styles/SIMS.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>

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

        .profile-container {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 24px;
        }

        .profile-card {
            text-align: center;
            padding: 28px;
        }

        .profile-image-wrapper {
            width: 180px;
            height: 180px;
            margin: 0 auto 20px;
        }

        .profile-image {
            width: 180px;
            height: 180px;
            border-radius: 50%;
            object-fit: cover;
            border: 6px solid #fff;
            box-shadow: var(--shadow-card);
        }

        .profile-upload {
            margin-top: 16px;
        }

        .profile-name {
            font-size: 24px;
            font-weight: 700;
            margin-top: 14px;
        }

        .profile-role {
            color: var(--text-muted);
            font-weight: 600;
            margin-top: 6px;
        }

        .readonly-box {
            background: #f5f7fa;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2,1fr);
            gap: 18px;
        }

        .full-width {
            grid-column: 1 / -1;
        }

        .sidebar-user {
          margin-bottom: 18px;
          align-items  : flex-start;
        }
        .user-info  { padding-top: 4px; }
        .user-name  { margin-bottom: 4px; }
        .user-role  { margin-top: 2px; }

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

        @media (max-width: 1000px) {
            .profile-container {
                grid-template-columns: 1fr;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }
        }

        #customModalOverlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(30,30,40,.60);
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
        }

        .cm-icon-wrap {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
        }

        .cm-icon-wrap #cmIcon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
        }

        .cm-icon-wrap svg {
            width: 32px;
            height: 32px;
            display: block;
        }

        .cm-icon-wrap.icon-success {
            background: #fff8e1;
        }

        .cm-icon-wrap.icon-error {
            background: #fdecea;
        }

        .cm-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1a1a2e;
            margin-bottom: 14px;
        }

        .cm-divider {
            border: none;
            border-top: 1px solid #ececec;
            margin: 0 -32px 18px;
        }

        .cm-body {
            font-size: .97rem;
            line-height: 1.65;
            color: #555;
            margin-bottom: 28px;
        }

        .cm-footer {
            display: flex;
            justify-content: center;
        }

        .cm-btn {
            padding: 10px 32px;
            border-radius: 50px;
            font-size: .95rem;
            font-weight: 600;
            cursor: pointer;
            border: 2px solid #e8a838;
            background: transparent;
            color: #e8a838;
        }

        .cm-btn:hover {
            background: #fdf3e0;
        }
    </style>
</head>

<body>
<form id="form1" runat="server">

    <div class="sidebar">

        <div class="sidebar-brand">
            <img src="~/Images/Logo_Dashboard.png" runat="server" class="brand-logo" />
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

            <a href="Profile.aspx" class="sidebar-link active">
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

            <asp:LinkButton ID="lbLogout"
                runat="server"
                CssClass="sidebar-link"
                OnClientClick="showLogoutModal(); return false;">
                <i class="fa-solid fa-right-from-bracket"></i> Log Out
            </asp:LinkButton>

        </div>

    </div>

    <div class="main-wrapper">

        <div class="topbar">
            <div>
                <div class="topbar-title">My Profile</div>
                <div class="topbar-date">
                    <asp:Label ID="lblDate" runat="server" />
                </div>
            </div>
        </div>

        <div class="page-content">

            <div class="profile-container">

                <div class="card">
                    <div class="profile-card">

                        <div class="profile-image-wrapper">
                            <asp:Image ID="imgProfile"
                                runat="server"
                                CssClass="profile-image"
                                ImageUrl="~/ProfilePicture/default-profile.png" />
                        </div>

                        <asp:FileUpload ID="fuProfilePicture"
                            runat="server"
                            CssClass="form-control profile-upload" />

                        <div class="profile-name">
                            <asp:Label ID="lblFullName" runat="server" />
                        </div>

                        <div class="profile-role">
                            Lecturer
                        </div>

                    </div>
                </div>

                <div class="card">

                    <div class="card-header">
                        <span class="card-title">Profile Information</span>
                    </div>

                    <div class="card-body">

                        <div class="form-grid">

                            <div class="form-group">
                                <label class="form-label">Lecturer ID</label>
                                <asp:TextBox ID="txtLecturerId"
                                    runat="server"
                                    CssClass="form-control readonly-box"
                                    ReadOnly="true" />
                            </div>

                            <div class="form-group">
                                <label class="form-label">Join Date</label>
                                <asp:TextBox ID="txtJoinDate"
                                    runat="server"
                                    CssClass="form-control readonly-box"
                                    ReadOnly="true" />
                            </div>

                            <div class="form-group">
                                <label class="form-label">First Name</label>
                                <asp:TextBox ID="txtFirstName"
                                    runat="server"
                                    CssClass="form-control" />
                            </div>

                            <div class="form-group">
                                <label class="form-label">Last Name</label>
                                <asp:TextBox ID="txtLastName"
                                    runat="server"
                                    CssClass="form-control" />
                            </div>

                            <div class="form-group">
                                <label class="form-label">Gender</label>
                                <asp:DropDownList ID="ddlGender"
                                    runat="server"
                                    CssClass="form-control">
                                    <asp:ListItem Text="-- Select Gender --" Value=""></asp:ListItem>
                                    <asp:ListItem Text="Male" Value="Male"></asp:ListItem>
                                    <asp:ListItem Text="Female" Value="Female"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Phone Number</label>
                                <asp:TextBox ID="txtPhone"
                                    runat="server"
                                    CssClass="form-control" />
                            </div>

                            <div class="form-group full-width">
                                <label class="form-label">Specialization</label>
                                <asp:TextBox ID="txtSpecialization"
                                    runat="server"
                                    CssClass="form-control"
                                    TextMode="MultiLine"
                                    Rows="5" />
                            </div>

                        </div>

                        <div style="margin-top:24px; text-align:right;">
                            <asp:Button ID="btnSaveProfile"
                                runat="server"
                                Text="Save Profile"
                                CssClass="btn btn-primary"
                                OnClick="btnSaveProfile_Click" />
                        </div>

                    </div>

                </div>

            </div>

        </div>

    </div>

    <div id="customModalOverlay">
        <div id="customModal">

            <div class="cm-icon-wrap" id="cmIconWrap">
                <span id="cmIcon"></span>
            </div>

            <div class="cm-title" id="cmTitle">Message</div>

            <hr class="cm-divider" />

            <div class="cm-body" id="cmBody"></div>

            <div class="cm-footer">
                <button type="button"
                    class="cm-btn cm-btn-ok"
                    id="cmBtnOk"
                    onclick="closeCustomModal()">
                    OK
                </button>
            </div>

        </div>
    </div>

    <div id="logoutModal"
        style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(26,26,46,0.85); z-index:9999; align-items:center; justify-content:center;">

        <div style="background:white; border-radius:12px; width:100%; max-width:380px; box-shadow:0 15px 35px rgba(0,0,0,0.3); overflow:hidden;">

            <div style="padding:25px 30px 10px; text-align:center; border-bottom:1px solid #eee;">
                <h3>🔒 Log Out</h3>
            </div>

            <div style="padding:25px 30px; text-align:center; color:#555;">
                <p>Are you sure you want to log out of the SIMS system?</p>
            </div>

            <div style="padding:20px 30px 25px; display:flex; gap:12px; justify-content:center; border-top:1px solid #eee;">

                <button type="button"
                    onclick="hideLogoutModal()"
                    class="btn btn-outline"
                    style="padding:10px 24px;">
                    Cancel
                </button>

                <asp:LinkButton ID="btnConfirmLogout"
                    runat="server"
                    CssClass="btn btn-danger"
                    OnClick="lbLogout_Click">
                    Yes, Log Out
                </asp:LinkButton>

            </div>

        </div>

    </div>

    <script>
        var SVG_TICK =
            '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round">' +
            '<polyline points="20 6 9 17 4 12"/>' +
            '</svg>';

        var SVG_CROSS =
            '<svg viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round">' +
            '<line x1="18" y1="6" x2="6" y2="18"/>' +
            '<line x1="6" y1="6" x2="18" y2="18"/>' +
            '</svg>';

        function showMessageModal(title, message, isSuccess) {

            var iconWrap = document.getElementById('cmIconWrap');
            var iconEl = document.getElementById('cmIcon');

            if (isSuccess) {
                iconWrap.className = 'cm-icon-wrap icon-success';
                iconEl.innerHTML = SVG_TICK;
            }
            else {
                iconWrap.className = 'cm-icon-wrap icon-error';
                iconEl.innerHTML = SVG_CROSS;
            }

            document.getElementById('cmTitle').innerHTML = title;
            document.getElementById('cmBody').innerHTML = message;

            document.getElementById('customModalOverlay').classList.add('active');
        }

        function closeCustomModal() {
            document.getElementById('customModalOverlay').classList.remove('active');
        }

        function showLogoutModal() {
            document.getElementById('logoutModal').style.display = 'flex';
        }

        function hideLogoutModal() {
            document.getElementById('logoutModal').style.display = 'none';
        }
    </script>

</form>
</body>
</html>