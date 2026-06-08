<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Results.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student.Results" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <title>My Academic Results - SIMS Student Portal</title>

    <link rel="stylesheet" href="../Styles/SIMS.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        .sidebar { position: fixed; top: 0; left: 0; width: 260px; height: 100vh; overflow-y: auto; overflow-x: hidden; scrollbar-width: thin; }
        .main-wrapper { margin-left: 260px; }
        .filter-bar { display: grid; grid-template-columns: 1fr 1fr auto; gap: 12px; align-items: end; margin-bottom: 22px; }
        .filter-item label { display: block; font-size: 12px; font-weight: 800; color: var(--text-secondary); margin-bottom: 6px; text-transform: uppercase; letter-spacing: .4px; }
        .results-table { width: 100%; border-collapse: collapse; }
        .results-table th { background: #fff8e1; color: var(--text-primary); font-size: 13px; text-align: left; padding: 14px; }
        .results-table td { padding: 14px; border-bottom: 1px solid var(--border-light); font-size: 14px; }
        .grade-badge { display: inline-block; padding: 4px 10px; border-radius: 4px; font-weight: 700; font-size: 13px; text-align: center; min-width: 28px; }
        .grade-pass { background-color: #e6f4ea; color: #137333; }
        .grade-fail { background-color: #fce8e6; color: #c5221f; }
        .grade-pending { background-color: #f1f3f4; color: #5f6368; }
        .summary-flex { display: flex; gap: 24px; flex-wrap: wrap; margin-bottom: 18px; }
        .summary-box { display: flex; gap: 10px; align-items: center; font-weight: 800; color: var(--text-primary); background: var(--bg-light); padding: 10px 18px; border-radius: 8px; }
        .summary-box i { color: var(--orange-main); }
        .summary-box .metric-value { font-size: 18px; font-weight: 800; color: var(--orange-main); }
        .empty-state { text-align: center; padding: 46px 20px; color: var(--text-muted); }
        .empty-state i { font-size: 42px; color: var(--orange-main); margin-bottom: 12px; }
        .sidebar-user { margin-bottom: 18px; align-items: flex-start; }
        .user-info { padding-top: 4px; }
        .user-name { margin-bottom: 4px; }
        .user-role { margin-top: 2px; }
        @media (max-width: 900px) { .filter-bar { grid-template-columns: 1fr; } }

        /* ===== Standard Student logout dialog styles synchronized with Student Dashboard ===== */
        .modal-overlay {
          position: fixed;
          inset: 0;
          background: rgba(30,30,40,.60);
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
    </style>
</head>

<body>
<form id="form1" runat="server">

    <div class="sidebar">
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
            <asp:HyperLink ID="lnkMyCourses" runat="server" NavigateUrl="~/Student/MyCourses.aspx" CssClass="sidebar-link">
                <i class="fa-solid fa-book-open nav-icon"></i> My Courses
            </asp:HyperLink>
            <asp:HyperLink ID="lnkAttendance" runat="server" NavigateUrl="~/Student/Attendance.aspx" CssClass="sidebar-link">
                <i class="fa-solid fa-calendar-check nav-icon"></i> Attendance
            </asp:HyperLink>
            <asp:HyperLink ID="lnkEnrollment" runat="server" NavigateUrl="~/Student/Student_Enrollment.aspx" CssClass="sidebar-link">
                <i class="fa-solid fa-clipboard-list nav-icon"></i> Enrollment
            </asp:HyperLink>
            <asp:HyperLink ID="lnkResults" runat="server" NavigateUrl="~/Student/Results.aspx" CssClass="sidebar-link active">
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
                <div class="user-avatar" style="width: 42px; height: 42px; border-radius: 50%; background: var(--orange-gradient); display: flex; align-items: center; justify-content: center; color: var(--white); font-weight: 800;">
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
                <div class="topbar-title">Academic Examination Results</div>
                <div class="topbar-date"><asp:Label ID="lblDate" runat="server" /></div>
            </div>
            <div class="topbar-right">
                <a href="Notifications.aspx" class="topbar-icon-btn" title="Notifications">
                    <i class="fa-solid fa-bell"></i>
                    <asp:Panel ID="pnlNotifBadge" runat="server" CssClass="badge-dot" Visible="false" />
                </a>
                <a href="MyProfile.aspx" class="topbar-icon-btn" title="My Profile"><i class="fa-solid fa-circle-user"></i></a>
            </div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <h1>My Academic Transcripts</h1>
                <p>Filter your grading metrics by academic cycles or view complete summary tallies.</p>
            </div>

            <div class="card" style="margin-bottom:24px;">
                <div class="card-body">
                    <div class="filter-bar">
                        <div class="filter-item">
                            <label>Academic Session</label>
                            <asp:DropDownList ID="ddlSession" runat="server" CssClass="form-control" />
                        </div>

                        <div class="filter-item">
                            <label>Semester</label>
                            <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-control">
                                <asp:ListItem Text="All Semesters" Value="" />
                                <asp:ListItem Text="Semester 1" Value="1" />
                                <asp:ListItem Text="Semester 2" Value="2" />
                                <asp:ListItem Text="Semester 3" Value="3" />
                                <asp:ListItem Text="Semester 4" Value="4" />
                            </asp:DropDownList>
                        </div>

                        <div class="filter-item">
                            <asp:Button ID="btnFilter" runat="server" Text="View Results" CssClass="btn btn-primary btn-sm" OnClick="btnFilter_Click" Style="width:auto;" />
                        </div>
                    </div>
                </div>
            </div>

            <asp:Panel ID="pnlResults" runat="server" CssClass="card">
                <div class="card-header">
                    <span class="card-title">Grade Performance Sheet</span>
                </div>

                <div class="card-body">
                    <div class="summary-flex">
                        <div class="summary-box">
                            <i class="fa-solid fa-graduation-cap"></i>
                            Calculated GPA: &nbsp;<asp:Label ID="lblGPA" runat="server" CssClass="metric-value" Text="0.00" />
                        </div>
                        <div class="summary-box">
                            <i class="fa-solid fa-calculator"></i>
                            Calculated CGPA: &nbsp;<asp:Label ID="lblCGPA" runat="server" CssClass="metric-value" Text="0.00" style="color: #137333;" />
                        </div>
                        <div class="summary-box">
                            <i class="fa-solid fa-award"></i>
                            Total Earned Credits: &nbsp;<asp:Label ID="lblTotalCredits" runat="server" CssClass="metric-value" Text="0" />
                        </div>
                    </div>

                    <asp:Repeater ID="rptGrades" runat="server">
                        <HeaderTemplate>
                            <table class="results-table">
                                <thead>
                                    <tr>
                                        <th>No.</th>
                                        <th>Module Code & Name</th>
                                        <th>Credit Hours</th>
                                        <th>Overall Score (%)</th>
                                        <th>Letter Grade</th>
                                        <th>Outcome</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td><%# Container.ItemIndex + 1 %></td>
                                <td><%# Eval("CourseDisplay") %></td>
                                <td><%# Eval("Credits") %></td>
                                <td><%# Eval("FinalPercentage") != DBNull.Value ? string.Format("{0:0.0}%", Eval("FinalPercentage")) : "-" %></td>
                                <td><strong><%# Eval("CalculatedGrade") %></strong></td>
                                <td>
                                    <span class='<%# 
                                        Eval("CalculatedGrade").ToString() == "In Progress (IP)" ? "grade-badge grade-pending" : 
                                        (Eval("CalculatedGrade").ToString() != "F" ? "grade-badge grade-pass" : "grade-badge grade-fail") 
                                    %>'>
                                        <%# 
                                            Eval("CalculatedGrade").ToString() == "In Progress (IP)" ? "PENDING" : 
                                            (Eval("CalculatedGrade").ToString() != "F" ? "PASS" : "FAIL") 
                                        %>
                                    </span>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
                        <i class="fa-solid fa-folder-open"></i>
                        <h3>No grade results published</h3>
                        <p>No verified grade records found for the chosen selection parameter combinations.</p>
                    </asp:Panel>
                </div>
           </asp:Panel>
        </div>
    </div>

    <div id="logoutModal" class="modal-overlay system-dialog">
        <div class="modal-box">
            <div class="modal-head">
                <div class="logout-warning-icon">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                </div>
                Log Out
            </div>
            <div class="modal-body">
                <p>Are you sure you want to log out?</p>
            </div>
            <div class="modal-actions">
                <button type="button" onclick="hideLogoutModal()" class="modal-cancel">Cancel</button>
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