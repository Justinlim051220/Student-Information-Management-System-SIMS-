<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Results.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student.Results" %>
<%@ Register Src="~/Student/StudentSidebar.ascx" TagPrefix="uc" TagName="StudentSidebar" %>
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
        .logout-modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(17, 24, 39, 0.62);
            z-index: 9999;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .logout-modal-card {
            width: 100%;
            max-width: 400px;
            background: #ffffff;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 22px 60px rgba(15, 23, 42, 0.28);
            text-align: center;
            font-family: var(--font-primary);
            animation: logoutPop 0.18s ease-out;
        }

        @keyframes logoutPop {
            from { transform: translateY(8px) scale(0.98); opacity: 0; }
            to { transform: translateY(0) scale(1); opacity: 1; }
        }

        .logout-modal-top {
            padding: 36px 32px 20px;
        }

        .logout-warning-icon {
            width: 72px;
            height: 72px;
            margin: 0 auto 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: transparent;
            color: #f59e0b;
            font-size: 56px;
            line-height: 1;
        }

        .logout-warning-icon i {
            color: #f59e0b;
        }

        .logout-title {
            margin: 0;
            color: var(--text-primary);
            font-size: 20px;
            font-weight: 800;
            line-height: 1.25;
        }

        .logout-message {
            margin: 0;
            padding: 20px 32px;
            border-top: 1px solid var(--border-light);
            color: var(--text-secondary);
            font-size: 15px;
            font-weight: 500;
            line-height: 1.5;
        }

        .logout-actions {
            display: flex;
            justify-content: center;
            gap: 12px;
            padding: 18px 28px 28px;
        }

        .logout-btn {
            min-width: 118px;
            height: 44px;
            border-radius: 999px;
            font-family: var(--font-primary);
            font-size: 14px;
            font-weight: 800;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            text-decoration: none;
            transition: var(--transition);
        }

        .logout-btn-cancel {
            border: 2px solid var(--orange-main);
            background: #ffffff;
            color: var(--orange-main);
        }

        .logout-btn-cancel:hover {
            background: #fff7ed;
            transform: translateY(-1px);
        }

        .logout-btn-confirm {
            border: 2px solid transparent;
            background: var(--orange-gradient);
            color: #ffffff !important;
            box-shadow: var(--shadow-orange);
        }

        .logout-btn-confirm:hover {
            transform: translateY(-1px);
            color: #ffffff !important;
        }
        
    </style>
</head>

<body>
<form id="form1" runat="server">

    <uc:StudentSidebar ID="StudentSidebar1" runat="server" />

    <div class="main-wrapper">
        <div class="topbar">
            <div>
                <div class="topbar-title">Academic Examination Results</div>
                <div class="topbar-date"><asp:Label ID="lblDate" runat="server" /></div>
            </div>
            <div class="topbar-right">
                <a href="Notification.aspx" class="topbar-icon-btn" title="Notifications">
                    <i class="fa-solid fa-bell"></i>
                    <asp:Panel ID="pnlNotifBadge" runat="server" CssClass="badge-dot" Visible="false" />
                </a>
                <a href="MyProfile.aspx" class="topbar-icon-btn" title="My Profile"><i class="fa-solid fa-circle-user"></i></a>
            </div>
        </div>

        <div class="page-content">
            <div class="page-header">
                <h1>My Academic Results</h1>
                <p>Select an academic session and semester to view published results. Results only appear after all course marks are finalized.</p>
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
                                <asp:ListItem Text="-- Select Semester --" Value="" />
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
                <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                    <span class="card-title">Published Result Sheet</span>
                    <asp:LinkButton ID="btnExportResultSlip" runat="server" CssClass="btn btn-sm" 
                        Style="background-color: #e8a838; color: white; padding: 8px 14px; border-radius: 4px; text-decoration: none; border: none; cursor: pointer; font-weight: 600; font-size: 13px; display: inline-flex; align-items: center; gap: 6px;"
                        OnClick="btnExportResultSlip_Click" ToolTip="Export Result Slip as PDF">
                        <i class="fa-solid fa-file-pdf" style="font-size: 14px;"></i> Export Result Slip
                    </asp:LinkButton>
                </div>

                <div class="card-body">
                    <div class="summary-flex">
                        <div class="summary-box">
                            <i class="fa-solid fa-graduation-cap"></i>
                            GPA: &nbsp;<asp:Label ID="lblGPA" runat="server" CssClass="metric-value" Text="0.00" />
                        </div>
                        <div class="summary-box">
                            <i class="fa-solid fa-calculator"></i>
                            CGPA: &nbsp;<asp:Label ID="lblCGPA" runat="server" CssClass="metric-value" Text="0.00" style="color: #137333;" />
                        </div>
                        <div class="summary-box">
                            <i class="fa-solid fa-award"></i>
                            Total Credits: &nbsp;<asp:Label ID="lblTotalCredits" runat="server" CssClass="metric-value" Text="0" />
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
                                        <th>Final Mark (%)</th>
                                        <th>Grade</th>
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
                                <td><%# string.Format("{0:0.0}%", Eval("FinalMark")) %></td>
                                <td><strong><%# Eval("Grade") %></strong></td>
                                <td>
                                    <span class='<%# Eval("Grade").ToString() != "F" ? "grade-badge grade-pass" : "grade-badge grade-fail" %>'>
                                        <%# Eval("Grade").ToString() != "F" ? "PASS" : "FAIL" %>
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
                        <h3>Results Not Available Yet</h3>
                        <p>Some course marks have not been finalized by lecturers, or no active course was found for this session and semester.</p>
                    </asp:Panel>
                </div>
           </asp:Panel>
        </div>
    </div>


    <script>
        function showLogoutModal() {
            var modal = document.getElementById('logoutModal');
            if (modal) modal.style.display = 'flex';
        }

        function hideLogoutModal() {
            var modal = document.getElementById('logoutModal');
            if (modal) modal.style.display = 'none';
        }

        function hideLogoutModalOnBackdrop(event) {
            if (event.target && event.target.id === 'logoutModal') {
                hideLogoutModal();
            }
        }
    </script>

</form>
</body>
</html>