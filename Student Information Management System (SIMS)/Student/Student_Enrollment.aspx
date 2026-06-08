<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Student_Enrollment.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student_Enrollment" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SIMS – Student Enrollment</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
  <link rel="stylesheet" href="../Styles/SIMS.css" />

  <style>
    .sidebar{position:fixed;top:0;left:0;width:260px;height:100vh;overflow-y:auto;overflow-x:hidden;scrollbar-width:thin;}
    .enroll-layout{display:grid;grid-template-columns:360px 1fr;gap:22px;align-items:start;}
    @media(max-width:980px){.enroll-layout{grid-template-columns:1fr;}}
    .info-card,.form-card,.table-card{background:var(--bg-card);border-radius:var(--radius-md);box-shadow:var(--shadow-card);overflow:hidden;}
    .card-head{padding:18px 22px;border-bottom:1px solid var(--border-light);display:flex;align-items:center;justify-content:space-between;gap:10px;}
    .card-title{font-size:16px;font-weight:900;color:var(--text-primary);display:flex;align-items:center;gap:9px;}
    .card-title i{color:var(--orange-main);}
    .card-body{padding:22px;}
    .profile-row{display:flex;gap:14px;align-items:center;margin-bottom:20px;}
    .student-avatar{width:56px;height:56px;border-radius:50%;background:var(--orange-gradient);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:900;font-size:22px;flex-shrink:0;}
    .profile-name{font-size:17px;font-weight:900;color:var(--text-primary);}
    .profile-sub{font-size:12px;font-weight:700;color:var(--orange-dark);margin-top:2px;}
    .info-line{display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid var(--border-light);font-size:13px;}
    .info-line:last-child{border-bottom:0;}
    .info-label{color:var(--text-muted);font-weight:700;}
    .info-value{color:var(--text-primary);font-weight:800;text-align:right;}
    .form-group{margin-bottom:16px;}
    .form-label{display:block;font-size:13px;font-weight:800;color:var(--text-primary);margin-bottom:7px;}
    .form-control{width:100%;padding:11px 13px;border:1.5px solid var(--border-mid);border-radius:var(--radius-sm);font-family:var(--font-primary);font-size:13px;color:var(--text-primary);background:#fff;outline:none;}
    .form-control:focus{border-color:var(--orange-main);box-shadow:0 0 0 3px rgba(245,166,35,.12);}
    .readonly-box{padding:11px 13px;border-radius:var(--radius-sm);background:var(--off-white);font-size:13px;font-weight:800;color:var(--text-primary);border:1px solid var(--border-light);}
    .helper-text{font-size:12px;color:var(--text-muted);line-height:1.5;margin-top:8px;}
    .btn-row{display:flex;gap:10px;flex-wrap:wrap;margin-top:18px;}
    .btn-orange{display:inline-flex;align-items:center;gap:7px;padding:10px 18px;border:0;border-radius:var(--radius-pill);background:var(--orange-gradient);color:#fff;font-weight:800;font-size:13px;cursor:pointer;text-decoration:none;}
    .btn-orange:hover{box-shadow:var(--shadow-orange);transform:translateY(-1px);}
    .btn-outline-custom{display:inline-flex;align-items:center;gap:7px;padding:9px 17px;border:1.5px solid var(--orange-main);border-radius:var(--radius-pill);background:#fff;color:var(--orange-dark);font-weight:800;font-size:13px;cursor:pointer;text-decoration:none;}
    .alert-box{margin-bottom:16px;padding:12px 15px;border-radius:var(--radius-sm);font-size:13px;font-weight:700;display:flex;gap:8px;align-items:flex-start;}
    .alert-box.success{background:rgba(46,204,113,.12);color:#1a7a40;border:1px solid rgba(46,204,113,.35);}
    .alert-box.error{background:rgba(231,76,60,.10);color:#b03a2e;border:1px solid rgba(231,76,60,.30);}
    .alert-box.info{background:rgba(52,152,219,.10);color:#1f618d;border:1px solid rgba(52,152,219,.25);}
    .enroll-table{width:100%;border-collapse:collapse;font-size:13px;}
    .enroll-table th{background:var(--orange-gradient);color:#fff;text-align:left;padding:12px 14px;font-weight:800;white-space:nowrap;}
    .enroll-table td{padding:12px 14px;border-bottom:1px solid var(--border-light);color:var(--text-primary);vertical-align:middle;}
    .enroll-table tr:hover td{background:var(--off-white);}
    .course-code{font-weight:900;color:var(--orange-dark);}
    .status-badge{display:inline-flex;padding:4px 11px;border-radius:var(--radius-pill);font-size:11px;font-weight:900;}
    .status-active{background:rgba(46,204,113,.14);color:#1a7a40;}
    .status-completed{background:rgba(52,152,219,.12);color:#1f5f8b;}
    .status-pending{background:rgba(245,166,35,.16);color:#a86405;}
    .status-dropped{background:rgba(149,165,166,.16);color:#5d6d7e;}
    .status-rejected{background:rgba(231,76,60,.12);color:#b03a2e;}
    .action-btn{display:inline-flex;align-items:center;gap:6px;padding:7px 13px;border:0;border-radius:var(--radius-pill);font-size:12px;font-weight:900;cursor:pointer;text-decoration:none;}
    .action-drop{background:rgba(231,76,60,.10);color:#b03a2e;border:1px solid rgba(231,76,60,.30);}
    .action-drop:hover{background:rgba(231,76,60,.18);}
    .action-disabled{background:#f4f4f4;color:#999;border:1px solid #ddd;cursor:not-allowed;}
    .drop-note{font-size:12px;color:var(--text-muted);line-height:1.5;margin-top:10px;}
    .table-card .card-head{align-items:flex-start;}
    .table-subtitle{font-size:12px;color:var(--text-muted);font-weight:700;margin-top:4px;}
    .enrollment-list-tools{display:flex;align-items:flex-end;justify-content:space-between;gap:14px;flex-wrap:wrap;margin-bottom:16px;padding:14px 16px;background:#fffaf2;border:1px solid rgba(245,166,35,.22);border-radius:16px;}
    .enrollment-filter-group{min-width:230px;}
    .enrollment-filter-label{display:block;font-size:12px;font-weight:900;color:var(--text-muted);margin-bottom:7px;text-transform:uppercase;letter-spacing:.04em;}
    .enrollment-filter-select{width:100%;height:42px;border:1.5px solid var(--border-mid);border-radius:999px;background:#fff;padding:0 14px;font-family:var(--font-primary);font-size:13px;font-weight:800;color:var(--text-primary);outline:none;}
    .enrollment-filter-select:focus{border-color:var(--orange-main);box-shadow:0 0 0 3px rgba(245,166,35,.12);}
    .enrollment-filter-note{font-size:12px;color:var(--text-muted);font-weight:700;line-height:1.45;max-width:460px;}

    .empty-row{text-align:center;color:var(--text-muted);padding:28px!important;}
    .sidebar-user{margin-bottom:18px;align-items:flex-start;}.user-info{padding-top:4px;}.user-name{margin-bottom:4px;}.user-role{margin-top:2px;}
    .modal-overlay{position:fixed;inset:0;background:rgba(10,18,32,.45);display:none;align-items:center;justify-content:center;z-index:9999;padding:18px;}
    .modal-box{width:100%;max-width:480px;background:#fff;border-radius:18px;box-shadow:0 18px 48px rgba(0,0,0,.22);overflow:hidden;animation:modalIn .18s ease-out;}
    @keyframes modalIn{from{opacity:0;transform:translateY(10px) scale(.98);}to{opacity:1;transform:translateY(0) scale(1);}}
    .modal-head{padding:20px 24px;background:var(--orange-gradient);color:#fff;display:flex;align-items:center;gap:10px;font-weight:900;font-size:17px;}
    .modal-body{padding:22px 24px;color:var(--text-primary);}
    .modal-course{background:var(--off-white);border:1px solid var(--border-light);border-radius:12px;padding:12px 14px;font-size:13px;font-weight:800;color:var(--text-primary);margin-bottom:14px;}
    .modal-textarea{width:100%;min-height:110px;resize:vertical;padding:12px 14px;border:1.5px solid var(--border-mid);border-radius:12px;font-family:var(--font-primary);font-size:13px;outline:none;box-sizing:border-box;}
    .modal-textarea:focus{border-color:var(--orange-main);box-shadow:0 0 0 3px rgba(245,166,35,.12);}
    .modal-error{display:none;margin-top:8px;font-size:12px;font-weight:800;color:#b03a2e;}
    .modal-actions{display:flex;justify-content:flex-end;gap:10px;padding:0 24px 22px;}
    .modal-cancel{padding:10px 18px;border-radius:999px;border:1.5px solid var(--border-mid);background:#fff;color:var(--text-primary);font-weight:900;cursor:pointer;}
    .modal-submit{padding:10px 18px;border-radius:999px;border:0;background:var(--orange-gradient);color:#fff;font-weight:900;cursor:pointer;}
    .system-dialog .modal-head{background:var(--orange-gradient);} 
    .system-dialog .dialog-icon{width:38px;height:38px;border-radius:50%;background:rgba(255,255,255,.22);display:flex;align-items:center;justify-content:center;}

    /* ===== Payment-page consistency blocks ===== */
    h2.page-title{margin-bottom:25px;}
    .page-header p{margin-top:6px;color:var(--text-secondary);}
    .student-info-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:18px;margin-bottom:26px;}
    .student-info-card{background:var(--white);border-radius:var(--radius-md);box-shadow:var(--shadow-card);padding:20px 22px;display:flex;align-items:center;gap:14px;}
    .student-info-icon{width:48px;height:48px;border-radius:var(--radius-md);background:rgba(245,166,35,.14);color:var(--orange-dark);display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;}
    .student-info-label{font-size:12px;font-weight:800;color:var(--text-muted);text-transform:uppercase;letter-spacing:.35px;}
    .student-info-value{font-size:15px;font-weight:900;color:var(--text-primary);margin-top:3px;}
    .enroll-layout{grid-template-columns:1fr;}
    .info-card{display:none;}
    .form-card,.table-card{background:var(--white);}
    .system-dialog .modal-head{background:#fff;color:var(--text-primary);justify-content:center;flex-direction:column;border-bottom:0;}
    .system-dialog .dialog-icon{width:58px;height:58px;border-radius:50%;background:rgba(232,168,56,.13);color:#e8a838;font-size:26px;}
    .system-dialog .modal-box{max-width:430px;border-radius:18px;text-align:center;}
    .system-dialog .modal-body{padding:6px 24px 22px;}
    .system-dialog .modal-actions{justify-content:center;padding:0 24px 24px;}
    .logout-warning-icon{width:58px;height:58px;border-radius:50%;background:rgba(232,168,56,.14);color:#e8a838;display:flex;align-items:center;justify-content:center;font-size:34px;font-weight:900;margin:0 auto 12px;}
    .system-message{font-size:14px;line-height:1.6;font-weight:700;color:var(--text-primary);}

  

    /* ===== Admin portal consistency for Student Enrollment ===== */
    .table-card{background:var(--white);border-radius:var(--radius-md);box-shadow:var(--shadow-card);overflow:hidden;}
    .table-card .card-body{padding:24px;}
    .table-card .table-wrapper{overflow-x:auto;}
    .student-enrollment-table{width:100%;border-collapse:collapse;font-size:14px;}
    .student-enrollment-table th{padding:12px 16px;background:var(--bg-page)!important;color:var(--text-secondary)!important;font-weight:700;font-size:12px;text-transform:uppercase;letter-spacing:.5px;text-align:left;border-bottom:2px solid var(--border-light);white-space:nowrap;}
    .student-enrollment-table td{padding:13px 16px;border-bottom:1px solid var(--border-light);color:var(--text-primary);vertical-align:middle;}
    .student-enrollment-table tr:last-child td{border-bottom:none;}
    .student-enrollment-table tr:hover td{background:rgba(245,166,35,.04)!important;}
    .student-enrollment-table .course-code{font-weight:900;color:var(--text-primary);}
    .drop-modal-consistent .modal-box{max-width:470px;border-radius:18px;text-align:left;}
    .drop-modal-consistent .modal-head{background:#fff;color:var(--text-primary);border-bottom:1px solid var(--border-light);padding:22px 24px;font-size:18px;}
    .drop-modal-consistent .modal-head i{width:42px;height:42px;border-radius:50%;background:rgba(232,168,56,.13);color:#e8a838;display:flex;align-items:center;justify-content:center;font-size:18px;}
    .drop-modal-consistent .modal-body{padding:22px 24px;}
    .drop-modal-consistent .modal-actions{padding:0 24px 24px;justify-content:center;}
    .drop-modal-consistent .modal-submit{background:#e8a838;color:#fff;border:2px solid #e8a838;border-radius:999px;min-width:140px;}
    .drop-modal-consistent .modal-cancel{background:#fff;color:#e8a838;border:2px solid #e8a838;border-radius:999px;min-width:110px;}
    .drop-modal-consistent .modal-course{background:var(--bg-page);border:1px solid var(--border-light);border-radius:12px;padding:12px 14px;font-size:13px;font-weight:800;color:var(--text-primary);margin-bottom:16px;}
    .drop-modal-consistent .modal-textarea{border-radius:12px;min-height:115px;}
    .system-dialog .modal-submit{background:#e8a838;border:2px solid #e8a838;border-radius:999px;min-width:120px;}
    .system-dialog .modal-cancel{background:#fff;color:#e8a838;border:2px solid #e8a838;border-radius:999px;min-width:110px;}


    /* ===== Navigation Click Fix: keep sidebar above main content ===== */
    .sidebar{
        z-index:3000 !important;
        pointer-events:auto !important;
    }
    .sidebar a,
    .sidebar .sidebar-link{
        position:relative;
        z-index:3001 !important;
        pointer-events:auto !important;
    }
    .main-wrapper{
        position:relative !important;
        z-index:1 !important;
        margin-left:260px !important;
        width:calc(100% - 260px) !important;
    }
    @media(max-width:768px){
        .main-wrapper{
            margin-left:0 !important;
            width:100% !important;
        }
    }


    /* ===== Final consistent prompt/logout style (same as Admin/Lecturer screenshot) ===== */
    #<%= pnlMessage.ClientID %>, .alert-box{display:none !important;}
    .modal-overlay{background:rgba(30,30,40,.60) !important;}
    .system-dialog .modal-box,
    .drop-modal-consistent .modal-box{width:100%;max-width:400px;background:#fff;border-radius:16px;box-shadow:0 12px 40px rgba(0,0,0,.28);text-align:center;overflow:hidden;}
    .system-dialog .modal-head,
    .drop-modal-consistent .modal-head{background:#fff !important;color:#1a1a2e !important;justify-content:center;flex-direction:column;border-bottom:1px solid #ececec !important;padding:36px 32px 18px !important;font-size:1.2rem;font-weight:800;gap:14px;}
    .system-dialog .dialog-icon,
    .drop-modal-consistent .modal-head i{width:68px !important;height:68px !important;border-radius:50% !important;background:#fff8e1 !important;color:#e8a838 !important;display:flex !important;align-items:center !important;justify-content:center !important;font-size:30px !important;margin:0 auto;}
    .system-dialog .modal-body{padding:18px 32px 28px !important;color:#555;}
    .system-dialog .system-message{font-size:.97rem;line-height:1.65;color:#555;font-weight:600;}
    .system-dialog .modal-actions,
    .drop-modal-consistent .modal-actions{display:flex;justify-content:center;align-items:center;gap:12px;padding:0 32px 28px !important;}
    .system-dialog .modal-cancel,
    .drop-modal-consistent .modal-cancel{min-width:110px;padding:10px 32px;border-radius:50px;background:transparent;border:2px solid #e8a838;color:#e8a838;font-size:.95rem;font-weight:700;text-decoration:none;}
    .system-dialog .modal-submit,
    .drop-modal-consistent .modal-submit{min-width:110px;padding:10px 32px;border-radius:50px;background:#e8a838;border:2px solid #e8a838;color:#fff;font-size:.95rem;font-weight:700;text-decoration:none;box-shadow:0 8px 18px rgba(232,168,56,.22);}
    .system-dialog .modal-submit:hover,
    .drop-modal-consistent .modal-submit:hover{background:#d99a2e;border-color:#d99a2e;}
    .logout-warning-icon{width:68px !important;height:68px !important;border-radius:50% !important;background:#fff8e1 !important;color:#e8a838 !important;display:flex !important;align-items:center !important;justify-content:center !important;font-size:34px !important;font-weight:900 !important;margin:0 auto 16px !important;}
    .drop-modal-consistent .modal-body{text-align:left;padding:22px 32px 22px !important;}
    .drop-modal-consistent .modal-course{background:#fafafa;border:1px solid #ececec;border-radius:12px;padding:12px 14px;font-size:13px;font-weight:800;color:#1a1a2e;margin-bottom:16px;}
    .drop-modal-consistent .modal-textarea{border-radius:12px;min-height:115px;}

  

    /* ===== FINAL STANDARD LOGOUT TRIANGLE ICON - DO NOT DUPLICATE ===== */
    .logout-warning-icon,
    .prompt-modal .cm-icon-wrap.logout-warning-icon {
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

    .logout-warning-icon i,
    .prompt-modal .cm-icon-wrap.logout-warning-icon i {
        color: #f59e0b !important;
        font-size: 56px !important;
        line-height: 1 !important;
        display: block !important;
    }


    .notif-wrap{position:relative;display:inline-flex;align-items:center;justify-content:center;}
    .notif-dot{position:absolute;top:-3px;right:-5px;width:10px;height:10px;background:#ef4444;border:2px solid #fff;border-radius:50%;box-shadow:0 0 0 2px rgba(239,68,68,.14);z-index:5;}
    .sidebar-link.notif-link{position:relative;}
    .sidebar-link .sidebar-notif-dot{position:absolute;top:14px;right:18px;width:9px;height:9px;background:#ef4444;border:2px solid #fff;border-radius:50%;box-shadow:0 0 0 2px rgba(239,68,68,.14);}

  </style>
</head>
<body>
<form id="form1" runat="server">
<asp:HiddenField ID="hfDropEnrollmentId" runat="server" />
<asp:HiddenField ID="hfDropCourseId" runat="server" />
<asp:HiddenField ID="hfDropSession" runat="server" />

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

    <a href="Student_Dashboard.aspx" class="sidebar-link">
      <i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Academic</div>

    <a href="MyCourses.aspx" class="sidebar-link">
      <i class="fa-solid fa-book-open nav-icon"></i> My Courses
    </a>
    <a href="Attendance.aspx" class="sidebar-link">
      <i class="fa-solid fa-calendar-check nav-icon"></i> Attendance
    </a>
    <a href="Student_Enrollment.aspx" class="sidebar-link active">
      <i class="fa-solid fa-clipboard-list nav-icon"></i> Enrollment
    </a>
    <a href="Results.aspx" class="sidebar-link">
      <i class="fa-solid fa-chart-line nav-icon"></i> Results
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Finance</div>

    <a href="Student_Payment.aspx" class="sidebar-link">
      <i class="fa-solid fa-money-bill-wave nav-icon"></i> Payment
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>

    <a href="Notification.aspx" class="sidebar-link notif-link">
      <i class="fa-solid fa-bell nav-icon"></i> Notifications
      <asp:Panel ID="pnlSidebarNotifBadge" runat="server" CssClass="sidebar-notif-dot" Visible="false" />
    </a>
    <a href="Contacts.aspx" class="sidebar-link">
      <i class="fa-solid fa-address-book nav-icon"></i> Contacts
    </a>

    <div class="sidebar-section-label" style="margin-top:12px;">Account</div>

    <a href="MyProfile.aspx" class="sidebar-link">
      <i class="fa-solid fa-circle-user nav-icon"></i> My Profile
    </a>
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
    <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link"
      OnClientClick="showLogoutModal(); return false;">
      <i class="fa-solid fa-right-from-bracket"></i> Log Out
    </asp:LinkButton>
  </div>

</div>

<div class="main-wrapper">
  <div class="topbar">
    <div><div class="topbar-title">Enrollment</div><div class="topbar-date"><asp:Label ID="lblDate" runat="server" /></div></div>
    <div class="topbar-right">
      <a href="Notification.aspx" class="topbar-icon-btn" title="Notifications">
        <span class="notif-wrap">
          <i class="fa-solid fa-bell"></i>
          <asp:Panel ID="pnlNotifBadge" runat="server" CssClass="notif-dot" Visible="false" />
        </span>
      </a>
      <a href="MyProfile.aspx" class="topbar-icon-btn" title="My Profile">
        <i class="fa-solid fa-circle-user"></i>
      </a>
    </div>
  </div>

  <div class="page-content">
    <div class="page-header">
      <h1>Student Enrollment</h1>
      <p>View available course offerings, submit enrollment requests, and manage your current enrolled subjects.</p>
    </div>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert-box info">
      <i class="fa-solid fa-circle-info"></i><asp:Label ID="lblMessage" runat="server" />
    </asp:Panel>

    <div class="student-info-grid">
      <div class="student-info-card"><div class="student-info-icon"><i class="fa-solid fa-user-graduate"></i></div><div><div class="student-info-label">Student Name</div><div class="student-info-value"><asp:Label ID="lblStudentNameTop" runat="server" /></div></div></div>
      <div class="student-info-card"><div class="student-info-icon"><i class="fa-solid fa-id-card"></i></div><div><div class="student-info-label">Student ID</div><div class="student-info-value"><asp:Label ID="lblStudentIdTop" runat="server" /></div></div></div>
      <div class="student-info-card"><div class="student-info-icon"><i class="fa-solid fa-layer-group"></i></div><div><div class="student-info-label">Programme</div><div class="student-info-value"><asp:Label ID="lblProgrammeTop" runat="server" /></div></div></div>
      <div class="student-info-card"><div class="student-info-icon"><i class="fa-solid fa-calendar-days"></i></div><div><div class="student-info-label">Current Semester</div><div class="student-info-value"><asp:Label ID="lblSemesterTop" runat="server" /></div></div></div>
    </div>

    <div class="enroll-layout">
      <div class="info-card">
        <div class="card-head"><div class="card-title"><i class="fa-solid fa-user-graduate"></i> Student Info</div></div>
        <div class="card-body">
          <div class="profile-row">
            <div class="student-avatar"><asp:Label ID="lblProfileInitial" runat="server" Text="S" /></div>
            <div><div class="profile-name"><asp:Label ID="lblStudentName" runat="server" /></div><div class="profile-sub"><asp:Label ID="lblStudentId" runat="server" /></div></div>
          </div>
          <div class="info-line"><span class="info-label">Programme</span><span class="info-value"><asp:Label ID="lblProgramme" runat="server" /></span></div>
          <div class="info-line"><span class="info-label">Current Semester</span><span class="info-value"><asp:Label ID="lblSemester" runat="server" /></span></div>
          <div class="info-line"><span class="info-label">Open Sessions</span><span class="info-value"><asp:Label ID="lblOpenSessionCount" runat="server" Text="0" /></span></div>
          <div class="helper-text">Courses are filtered by your programme and admin-open course offerings only.</div>
        </div>
      </div>

      <div class="form-card">
        <div class="card-head"><div class="card-title"><i class="fa-solid fa-plus-circle"></i> Add Course Enrollment</div></div>
        <div class="card-body">
          <asp:HiddenField ID="hfProgrammeId" runat="server" />
          <asp:HiddenField ID="hfSemester" runat="server" />

          <div class="form-group">
            <label class="form-label">Open Session</label>
            <asp:DropDownList ID="ddlSession" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlSession_SelectedIndexChanged" />
          </div>

          <div class="form-group">
            <label class="form-label">Available Course</label>
            <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control" />
            <div class="helper-text">Only courses opened by admin in Course Offering will appear here.</div>
          </div>

          <div class="form-group">
            <label class="form-label">Enrollment Rule</label>
            <div class="readonly-box"><asp:Label ID="lblRule" runat="server" /></div>
          </div>

          <div class="btn-row">
            <asp:Button ID="btnEnroll" runat="server" Text="Submit Enrollment Request" CssClass="btn-orange" OnClick="btnEnroll_Click" />
            <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn-outline-custom" OnClick="btnRefresh_Click" />
          </div>
        </div>
      </div>
    </div>

    <div class="table-card" style="margin-top:22px;">
      <div class="card-head">
        <div>
          <div class="card-title"><i class="fa-solid fa-list-check"></i> My Course Enrollment</div>
          <div class="table-subtitle">The latest session is shown by default. Older sessions are shown as completed under Enrollment History.</div>
        </div>
      </div>
      <div class="card-body">
        <div class="enrollment-list-tools">
          <div class="enrollment-filter-group">
            <label class="enrollment-filter-label" for="enrollmentView">Enrollment View</label>
            <select id="enrollmentView" name="enrollmentView" class="enrollment-filter-select">
              <option value="Current" <%= GetEnrollmentViewSelected("Current") %>>Current Session Only</option>
              <option value="History" <%= GetEnrollmentViewSelected("History") %>>Previous Session History</option>
              <option value="Active" <%= GetEnrollmentViewSelected("Active") %>>Active Only</option>
              <option value="Pending" <%= GetEnrollmentViewSelected("Pending") %>>Pending Only</option>
              <option value="Drop Pending" <%= GetEnrollmentViewSelected("Drop Pending") %>>Drop Requests</option>
              <option value="Dropped" <%= GetEnrollmentViewSelected("Dropped") %>>Dropped Courses</option>
              <option value="Rejected" <%= GetEnrollmentViewSelected("Rejected") %>>Rejected Records</option>
              <option value="All" <%= GetEnrollmentViewSelected("All") %>>All Enrollment Records</option>
            </select>
          </div>
          <div class="enrollment-filter-note">
            Default view shows only the latest enrolled session. Previous sessions are kept under history.
          </div>
          <asp:Button ID="btnApplyEnrollmentFilter" runat="server" Text="Apply Filter" CssClass="btn-outline-custom" OnClick="btnRefresh_Click" />
        </div>
        <div class="table-wrapper">
      <asp:GridView ID="gvEnrolled" runat="server" AutoGenerateColumns="False" CssClass="data-table student-enrollment-table" GridLines="None" EmptyDataText="No enrolled course yet.">
        <Columns>
          <asp:BoundField DataField="CourseCode" HeaderText="Code" ItemStyle-CssClass="course-code" />
          <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
          <asp:BoundField DataField="Credits" HeaderText="Credit" />
          <asp:BoundField DataField="Session" HeaderText="Session" />
          <asp:TemplateField HeaderText="Status">
            <ItemTemplate>
              <span class='status-badge <%# GetStatusCss(Eval("DisplayStatus")) %>'><%# Eval("DisplayStatus") %></span>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:BoundField DataField="EnrollmentDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
          <asp:TemplateField HeaderText="Action">
            <ItemTemplate>
              <asp:LinkButton ID="btnRequestDrop" runat="server"
                CssClass='<%# CanRequestDrop(Eval("DisplayStatus")) ? "action-btn action-drop" : "action-btn action-disabled" %>'
                Enabled='<%# CanRequestDrop(Eval("DisplayStatus")) %>'
                OnClientClick='<%# GetDropClientClick(Eval("EnrollmentId"), Eval("CourseId"), Eval("Session"), Eval("CourseCode"), Eval("CourseName")) %>'>
                <i class="fa-solid fa-circle-minus"></i> Request Drop
              </asp:LinkButton>
            </ItemTemplate>
          </asp:TemplateField>
        </Columns>
        <EmptyDataRowStyle CssClass="empty-row" />
      </asp:GridView>
        </div>
      </div>
    </div>
  </div>
</div>


<div id="dropModal" class="modal-overlay drop-modal-consistent">
  <div class="modal-box">
    <div class="modal-head"><i class="fa-solid fa-circle-minus"></i> Request Subject Drop</div>
    <div class="modal-body">
      <div id="dropCourseText" class="modal-course">Selected course</div>
      <label class="form-label" for="txtDropReason">Drop Reason <span style="color:#b03a2e;">*</span></label>
      <asp:TextBox ID="txtDropReason" runat="server" CssClass="modal-textarea" TextMode="MultiLine" MaxLength="255" placeholder="Example: Timetable conflict, wrong subject selected, personal reason..." />
      <div id="dropReasonError" class="modal-error">Please enter your reason before submitting.</div>
      <div class="drop-note">Your request will be sent to admin for review. The subject will remain active until admin approves the drop.</div>
    </div>
    <div class="modal-actions">
      <button type="button" class="modal-cancel" onclick="closeDropModal();">Cancel</button>
      <asp:Button ID="btnSubmitDrop" runat="server" Text="Submit Drop Request" CssClass="modal-submit" CausesValidation="false" OnClientClick="return validateDropReason();" OnClick="btnSubmitDrop_Click" />
    </div>
  </div>
</div>

<div id="systemDialog" class="modal-overlay system-dialog">
  <div class="modal-box">
    <div class="modal-head"><span class="dialog-icon"><i id="systemDialogIcon" class="fa-solid fa-circle-info"></i></span><span id="systemDialogTitle">Message</span></div>
    <div class="modal-body"><div id="systemDialogMessage" class="system-message"></div></div>
    <div class="modal-actions"><button type="button" class="modal-cancel" id="systemDialogCancel" onclick="closeSystemDialog();">OK</button><button type="button" class="modal-submit" id="systemDialogPayment" style="display:none;" onclick="goPaymentPage();">Go Payment</button></div>
  </div>
</div>



<div id="dropConfirmDialog" class="modal-overlay system-dialog">
  <div class="modal-box">
    <div class="modal-body" style="padding-top:24px;">
      <div class="logout-warning-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
      <div style="font-size:18px;font-weight:900;margin-bottom:10px;">Confirm Drop Request</div>
      <div class="system-message">Submit this drop request to admin?</div>
    </div>
    <div class="modal-actions">
      <button type="button" class="modal-cancel" onclick="closeDropConfirmDialog();">Cancel</button>
      <button type="button" class="modal-submit" onclick="submitDropAfterConfirm();">Yes</button>
    </div>
  </div>
</div>

<div id="logoutModalOverlay" class="modal-overlay system-dialog">
  <div class="modal-box">
    <div class="modal-head">
      <div class="logout-warning-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
      <span>Log Out</span>
    </div>
    <div class="modal-body">
      <div class="system-message">Are you sure you want to log out?</div>
    </div>
    <div class="modal-actions">
      <button type="button" class="modal-cancel" onclick="closeLogoutModal();">Cancel</button>
      <asp:LinkButton ID="lbConfirmLogout" runat="server" CssClass="modal-submit" OnClick="lbLogout_Click">Log Out</asp:LinkButton>
    </div>
  </div>
</div>

<script type="text/javascript">
    function openDropModal(enrollmentId, courseId, session, courseText) {
        document.getElementById('<%= hfDropEnrollmentId.ClientID %>').value = enrollmentId;
        document.getElementById('<%= hfDropCourseId.ClientID %>').value = courseId;
      document.getElementById('<%= hfDropSession.ClientID %>').value = session;
      document.getElementById('<%= txtDropReason.ClientID %>').value = '';
      document.getElementById('dropReasonError').style.display = 'none';
      document.getElementById('dropCourseText').innerText = courseText + ' | ' + session;
      document.getElementById('dropModal').style.display = 'flex';
      setTimeout(function () { document.getElementById('<%= txtDropReason.ClientID %>').focus(); }, 100);
      return false;
  }

  function closeDropModal() {
      document.getElementById('dropModal').style.display = 'none';
      document.getElementById('dropReasonError').style.display = 'none';
  }

  function validateDropReason() {
      var reasonBox = document.getElementById('<%= txtDropReason.ClientID %>');
        var reason = reasonBox.value.replace(/^\s+|\s+$/g, '');
        if (reason.length === 0) {
            document.getElementById('dropReasonError').style.display = 'block';
            reasonBox.focus();
            return false;
        }
        reasonBox.value = reason;
        return showDropConfirmDialog();
    }


    var dropConfirmReady = false;

    function showDropConfirmDialog() {
        if (dropConfirmReady) {
            dropConfirmReady = false;
            return true;
        }
        document.getElementById('dropConfirmDialog').style.display = 'flex';
        return false;
    }

    function closeDropConfirmDialog() {
        document.getElementById('dropConfirmDialog').style.display = 'none';
    }

    function submitDropAfterConfirm() {
        dropConfirmReady = true;
        document.getElementById('dropConfirmDialog').style.display = 'none';
        document.getElementById('<%= btnSubmitDrop.ClientID %>').click();
    }

    function showSystemDialog(message, type) {
        var title = 'Message';
        var icon = 'fa-circle-info';
        if (type === 'success') { title = 'Success'; icon = 'fa-circle-check'; }
        if (type === 'error') { title = 'Notice'; icon = 'fa-triangle-exclamation'; }
        document.getElementById('systemDialogTitle').innerText = title;
        document.getElementById('systemDialogIcon').className = 'fa-solid ' + icon;
        document.getElementById('systemDialogMessage').innerText = message;
        document.getElementById('systemDialogCancel').innerText = 'OK';
        document.getElementById('systemDialogPayment').style.display = 'none';
        document.getElementById('systemDialog').style.display = 'flex';
    }

    function showPaymentDialog(message) {
        document.getElementById('systemDialogTitle').innerText = 'Enrollment Completed';
        document.getElementById('systemDialogIcon').className = 'fa-solid fa-circle-check';
        document.getElementById('systemDialogMessage').innerText = message;
        document.getElementById('systemDialogCancel').innerText = 'Later';
        document.getElementById('systemDialogPayment').style.display = 'inline-flex';
        document.getElementById('systemDialog').style.display = 'flex';
    }

    function closeSystemDialog() {
        document.getElementById('systemDialog').style.display = 'none';
    }

    function goPaymentPage() {
        window.location.href = 'Student_Payment.aspx';
    }

    function showLogoutModal() {
        document.getElementById('logoutModalOverlay').style.display = 'flex';
    }

    function closeLogoutModal() {
        document.getElementById('logoutModalOverlay').style.display = 'none';
    }
</script>

</form>
</body>
</html>
