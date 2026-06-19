<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_Profile.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Admin_Profile" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Profile - SIMS Admin Portal</title>

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <link rel="stylesheet" href="../Styles/SIMS.css" />

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

        .main-wrapper { margin-left: 260px; }

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
            position: relative;
        }

        .profile-image {
            width: 180px;
            height: 180px;
            border-radius: 50%;
            object-fit: cover;
            border: 6px solid #fff;
            box-shadow: var(--shadow-card);
        }

        .profile-avatar-big {
            width: 180px;
            height: 180px;
            border-radius: 50%;
            background: var(--orange-gradient);
            color: var(--white);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 64px;
            font-weight: 900;
            border: 6px solid #fff;
            box-shadow: var(--shadow-card);
        }

        .profile-upload {
            margin-top: 16px;
        }

        .profile-upload-note {
            margin-top: 8px;
            color: var(--text-muted);
            font-size: 13px;
            line-height: 1.4;
        }

        .profile-name {
            font-size: 24px;
            font-weight: 700;
            margin-top: 14px;
            color: var(--text-primary);
        }

        .profile-role {
            color: var(--text-muted);
            font-weight: 600;
            margin-top: 6px;
        }

        .readonly-box { background: #f5f7fa; }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 18px;
        }

        .full-width { grid-column: 1 / -1; }

        .sidebar-user {
            margin-bottom: 18px;
            align-items: flex-start;
        }
        .user-info { padding-top: 4px; }
        .user-name { margin-bottom: 4px; }
        .user-role { margin-top: 2px; }

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
            .profile-container { grid-template-columns: 1fr; }
            .form-grid { grid-template-columns: 1fr; }
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
        #customModalOverlay.active { display: flex; }
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
        .cm-icon-wrap svg { width: 32px; height: 32px; display: block; }
        .cm-icon-wrap.icon-success { background: #fff8e1; }
        .cm-icon-wrap.icon-error { background: #fdecea; }
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
        .cm-footer { display: flex; justify-content: center; }
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
        .cm-btn:hover { background: #fdf3e0; }
    </style>
</head>

<body>
<form id="form1" runat="server">

    <div class="sidebar" id="sidebar">

 <!-- Brand -->
<div class="sidebar-brand">
    <img src="~/Images/Logo_Dashboard.png" runat="server" alt="ONTI SIMS" class="brand-logo" />
    
    <div class="brand-text">
        <div class="brand-name">SIMS</div>
        <div class="brand-sub">Admin Portal</div>
    </div>
</div>

  <!-- Navigation -->
  <nav class="sidebar-nav">
    <div class="sidebar-section-label">Overview</div>
    <a href="Dashboard.aspx" class="sidebar-link">
      <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">User Management</div>
    <a href="ManageStudents.aspx" class="sidebar-link">
      <i class="fa-solid fa-user-graduate nav-icon"></i> Students
    </a>
    <a href="ManageLecturers.aspx" class="sidebar-link">
      <i class="fa-solid fa-chalkboard-teacher nav-icon"></i> Lecturers
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Academic Setup</div>
    <a href="ManageProgrammes.aspx" class="sidebar-link">
      <i class="fa-solid fa-layer-group nav-icon"></i> Programmes
    </a>
    <a href="ManageCourses.aspx" class="sidebar-link">
      <i class="fa-solid fa-book-open nav-icon"></i> Courses
    </a>
    <a href="AssignLecturerCourse.aspx" class="sidebar-link">
      <i class="fa-solid fa-user-check nav-icon"></i> Assign Course
    </a>
    <a href="CourseOffering.aspx" class="sidebar-link">
      <i class="fa-solid fa-calendar-check nav-icon"></i> Course Offering
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Enrollment</div>
    <a href="Admin_enrolment.aspx" class="sidebar-link">
      <i class="fa-solid fa-clipboard-list nav-icon"></i> Enrollment
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Finance & Reports</div>
    <a href="ManageFees.aspx" class="sidebar-link">
      <i class="fa-solid fa-money-bill-wave nav-icon"></i> Fees
    </a>
    <a href="Reports.aspx" class="sidebar-link">
      <i class="fa-solid fa-chart-bar nav-icon"></i> Reports
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>
    <a href="Admin_Announcement.aspx" class="sidebar-link">
      <i class="fa-solid fa-bullhorn nav-icon"></i> Announcements
    </a>
    <a href="Admin_Notification.aspx" class="sidebar-link">
      <i class="fa-solid fa-bell nav-icon"></i> Notifications
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Account</div>
    <a href="Admin_Profile.aspx" class="sidebar-link active">
      <i class="fa-solid fa-circle-user nav-icon"></i> My Profile
    </a>
  </nav>

  <!-- Sidebar user footer -->
  <div class="sidebar-footer">
    <div class="sidebar-user">
      <div class="user-avatar" id="divSidebarInitial" runat="server">
        <asp:Label ID="lblAvatarInitial" runat="server" Text="A" />
      </div>
      <div class="user-avatar sidebar-photo-avatar" id="divSidebarPhoto" runat="server" visible="false">
        <asp:Image ID="imgSidebarAvatar" runat="server" CssClass="sidebar-avatar-img" />
      </div>
      <div class="user-info">
        <div class="user-name">
          <asp:Label ID="lblSidebarName" runat="server" Text="Admin" />
        </div>
        <div class="user-role">Head of Programme</div>
      </div>
    </div>
    <!-- Log Out -->
        <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link" OnClientClick="showLogoutModal(); return false;">
        <i class="fa-solid fa-right-from-bracket"></i> Log Out
    </asp:LinkButton>
  </div>

</div><!-- /sidebar -->

<!-- ================================================================
     MAIN CONTENT
     ================================================================ -->

<div class="main-wrapper">

        <div class="topbar">
            <div>
                <div class="topbar-title">My Profile</div>
                <div class="topbar-date">
                    <asp:Label ID="lblDate" runat="server" />
                </div>
            </div>
            <div class="topbar-right">
                <a href="Admin_Profile.aspx" class="topbar-icon-btn" title="My Profile">
                    <i class="fa-solid fa-circle-user"></i>
                </a>
            </div>
        </div>

        <div class="page-content">
            <div class="profile-container">

                <div class="card">
                    <div class="profile-card">
                        <div class="profile-image-wrapper">
                            <div class="profile-avatar-big" id="divProfileInitial" runat="server">
                                <asp:Label ID="lblProfileInitial" runat="server" Text="A" />
                            </div>
                            <asp:Image ID="imgProfile"
                                runat="server"
                                CssClass="profile-image"
                                Visible="false" />
                        </div>

                        <asp:FileUpload ID="fuProfilePicture"
                            runat="server"
                            CssClass="form-control profile-upload" />
                        <div class="profile-upload-note">
                            Upload JPG, JPEG, or PNG only. Maximum size: 2MB.
                        </div>

                        <div class="profile-name">
                            <asp:Label ID="lblFullName" runat="server" Text="Admin" />
                        </div>

                        <div class="profile-role">Head of Programme</div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Profile Information</span>
                    </div>

                    <div class="card-body">
                        <div class="form-grid">

                            <div class="form-group">
                                <label class="form-label">HoP ID</label>
                                <asp:TextBox ID="txtHoPId"
                                    runat="server"
                                    CssClass="form-control readonly-box"
                                    ReadOnly="true" />
                            </div>

                            <div class="form-group">
                                <label class="form-label">Email</label>
                                <asp:TextBox ID="txtEmail"
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
                                <label class="form-label">Phone Number</label>
                                <asp:TextBox ID="txtPhone"
                                    runat="server"
                                    CssClass="form-control" />
                            </div>

                            <div class="form-group">
                                <label class="form-label">Account Created</label>
                                <asp:TextBox ID="txtCreatedAt"
                                    runat="server"
                                    CssClass="form-control readonly-box"
                                    ReadOnly="true" />
                            </div>

                            <div class="form-group full-width">
                                <label class="form-label">Department</label>
                                <asp:TextBox ID="txtDepartment"
                                    runat="server"
                                    CssClass="form-control"
                                    TextMode="MultiLine"
                                    Rows="4" />
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
                <button type="button" class="cm-btn" onclick="closeCustomModal()">OK</button>
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
                <button type="button" onclick="hideLogoutModal()" class="btn btn-outline" style="padding:10px 24px;">
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
