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
    .system-message{font-size:14px;line-height:1.6;font-weight:700;color:var(--text-primary);}

  </style>
</head>
<body>
<form id="form1" runat="server">
<asp:HiddenField ID="hfDropCourseId" runat="server" />
<asp:HiddenField ID="hfDropSession" runat="server" />

<div class="sidebar" id="sidebar">
  <div class="sidebar-brand">
    <img src="../Images/Logo_Dashboard.png" alt="ONTI SIMS" class="brand-logo" />
    <div class="brand-text"><div class="brand-name">SIMS</div><div class="brand-sub">Student Portal</div></div>
  </div>

  <nav class="sidebar-nav">
    <div class="sidebar-section-label">Main</div>
    <a href="Student_Dashboard.aspx" class="sidebar-link"><i class="fa-solid fa-gauge-high nav-icon"></i> Dashboard</a>
    <a href="MyCourses.aspx" class="sidebar-link"><i class="fa-solid fa-book-open nav-icon"></i> My Courses</a>
    <a href="Attendance.aspx" class="sidebar-link"><i class="fa-solid fa-calendar-check nav-icon"></i> Attendance</a>
    <a href="Student_Enrollment.aspx" class="sidebar-link active"><i class="fa-solid fa-clipboard-list nav-icon"></i> Enrollment</a>
    <a href="Results.aspx" class="sidebar-link"><i class="fa-solid fa-chart-line nav-icon"></i> Results</a>
    <a href="AcademicHistory.aspx" class="sidebar-link"><i class="fa-solid fa-clock-rotate-left nav-icon"></i> Academic History</a>

    <div class="sidebar-section-label" style="margin-top:12px;">Communication</div>
    <a href="Notifications.aspx" class="sidebar-link"><i class="fa-solid fa-bell nav-icon"></i> Notifications</a>
    <a href="Contacts.aspx" class="sidebar-link"><i class="fa-solid fa-address-book nav-icon"></i> Contacts</a>

    <div class="sidebar-section-label" style="margin-top:12px;">Account</div>
    <a href="MyProfile.aspx" class="sidebar-link"><i class="fa-solid fa-circle-user nav-icon"></i> My Profile</a>
  </nav>

  <div class="sidebar-footer">
    <div class="sidebar-user">
      <div class="user-avatar"><asp:Label ID="lblAvatarInitial" runat="server" Text="S" /></div>
      <div class="user-info"><div class="user-name"><asp:Label ID="lblSidebarName" runat="server" Text="Student" /></div><div class="user-role">Student</div></div>
    </div>
    <asp:LinkButton ID="lbLogout" runat="server" CssClass="sidebar-link" OnClick="lbLogout_Click"><i class="fa-solid fa-right-from-bracket"></i> Log Out</asp:LinkButton>
  </div>
</div>

<div class="main-wrapper">
  <div class="topbar">
    <div><div class="topbar-title">Enrollment</div><div class="topbar-date"><asp:Label ID="lblDate" runat="server" /></div></div>
    <div class="topbar-right"><a href="MyProfile.aspx" class="topbar-icon-btn" title="My Profile"><i class="fa-solid fa-circle-user"></i></a></div>
  </div>

  <div class="page-content">
    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert-box info">
      <i class="fa-solid fa-circle-info"></i><asp:Label ID="lblMessage" runat="server" />
    </asp:Panel>

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
          <div class="helper-text">Courses are filtered by your programme, your current semester, and admin-open course offerings only.</div>
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
          <div class="card-title"><i class="fa-solid fa-list-check"></i> My Current Enrollments</div>
          <div class="table-subtitle">Use Request Drop to send a subject drop request to admin. The subject is not removed until admin approves it.</div>
        </div>
      </div>
      <asp:GridView ID="gvEnrolled" runat="server" AutoGenerateColumns="False" CssClass="enroll-table" GridLines="None" EmptyDataText="No enrolled course yet.">
        <Columns>
          <asp:BoundField DataField="CourseCode" HeaderText="Code" ItemStyle-CssClass="course-code" />
          <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
          <asp:BoundField DataField="Credits" HeaderText="Credit" />
          <asp:BoundField DataField="Session" HeaderText="Session" />
          <asp:TemplateField HeaderText="Status">
            <ItemTemplate>
              <span class='status-badge <%# GetStatusCss(Eval("Status")) %>'><%# Eval("Status") %></span>
            </ItemTemplate>
          </asp:TemplateField>
          <asp:BoundField DataField="EnrollmentDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
          <asp:TemplateField HeaderText="Action">
            <ItemTemplate>
              <asp:LinkButton ID="btnRequestDrop" runat="server"
                CssClass='<%# CanRequestDrop(Eval("Status")) ? "action-btn action-drop" : "action-btn action-disabled" %>'
                Enabled='<%# CanRequestDrop(Eval("Status")) %>'
                OnClientClick='<%# GetDropClientClick(Eval("CourseId"), Eval("Session"), Eval("CourseCode"), Eval("CourseName")) %>'>
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


<div id="dropModal" class="modal-overlay">
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
    <div class="modal-actions"><button type="button" class="modal-submit" onclick="closeSystemDialog();">OK</button></div>
  </div>
</div>

<script type="text/javascript">
  function openDropModal(courseId, session, courseText) {
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
        return confirm('Submit this drop request to admin?');
    }

    function showSystemDialog(message, type) {
        var title = 'Message';
        var icon = 'fa-circle-info';
        if (type === 'success') { title = 'Success'; icon = 'fa-circle-check'; }
        if (type === 'error') { title = 'Notice'; icon = 'fa-triangle-exclamation'; }
        document.getElementById('systemDialogTitle').innerText = title;
        document.getElementById('systemDialogIcon').className = 'fa-solid ' + icon;
        document.getElementById('systemDialogMessage').innerText = message;
        document.getElementById('systemDialog').style.display = 'flex';
    }

    function closeSystemDialog() {
        document.getElementById('systemDialog').style.display = 'none';
    }
</script>

</form>
</body>
</html>
