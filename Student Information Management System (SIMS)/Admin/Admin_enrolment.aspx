<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_enrolment.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.Admin.Admin_enrolment" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Student Enrollment - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />
    <style>
        h2.page-title { margin-bottom: 25px; }
        .course-box { border:1px solid #e5e7eb; border-radius:14px; padding:16px; max-height:300px; overflow:auto; background:#fff; }
        .course-box label { margin-left:8px; }
        .data-table td:nth-child(4) { line-height:1.8; min-width:460px; }
        .course-line { display:grid; grid-template-columns:110px minmax(220px, 1fr) 95px; gap:12px; align-items:start; padding:4px 0; border-bottom:1px dashed #eee; }
        .course-line:last-child { border-bottom:none; }
        .course-line .course-code { font-weight:700; color:#1a1a2e; }
        .course-line .course-name { color:#333; }
        .course-line .course-fee { color:#777; white-space:nowrap; text-align:right; }

        .data-table .btn { padding:7px 14px; font-size:.82rem; border-radius:999px; text-decoration:none; display:inline-block; }
        .action-row { display:flex; align-items:center; gap:10px; flex-wrap:nowrap; white-space:nowrap; justify-content:center; }
        .action-row .action-btn { min-width:112px; text-align:center; margin:0 !important; }
        .data-table th:last-child, .data-table td:last-child { min-width:260px; }
        .drop-reason-text { display:block; max-width:280px; line-height:1.55; color:#555; white-space:normal; word-break:break-word; }
        .drop-reason-empty { color:#999; }
        #confirmModalOverlay { display:none; position:fixed; inset:0; background:rgba(30,30,40,.60); z-index:10000; justify-content:center; align-items:center; }
        #confirmModalOverlay.active { display:flex; }
        #confirmModal { background:#fff; border-radius:16px; width:100%; max-width:400px; padding:36px 32px 28px; box-shadow:0 12px 40px rgba(0,0,0,.28); text-align:center; }
        #confirmModal .cm-icon-wrap { width:68px; height:68px; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 16px; background:#fff8e1; }
        #confirmModal svg { width:32px; height:32px; display:block; }
        #confirmModal .cm-title { font-size:1.2rem; font-weight:700; color:#1a1a2e; margin-bottom:14px; }
        #confirmModal .cm-divider { border:none; border-top:1px solid #ececec; margin:0 -32px 18px; }
        #confirmModal .cm-body { font-size:.97rem; line-height:1.65; color:#555; margin-bottom:26px; }
        #confirmModal .cm-actions { display:flex; justify-content:center; align-items:center; gap:12px; margin-top:0; }
        #confirmModal .cm-btn { padding:10px 28px; border-radius:50px; font-size:.95rem; font-weight:600; cursor:pointer; transition:all .18s; min-width:105px; }
        #confirmModal .cm-btn-primary { background:#e8a838; border:2px solid #e8a838; color:#fff; }
        #confirmModal .cm-btn-primary:hover { background:#d99a2e; border-color:#d99a2e; }
        #confirmModal .cm-btn-secondary { background:transparent; border:2px solid #e8a838; color:#e8a838; }
        #confirmModal .cm-btn-secondary:hover { background:#fdf3e0; }
        #customModalOverlay { display:none; position:fixed; inset:0; background:rgba(30,30,40,.60); z-index:9999; justify-content:center; align-items:center; }
        #customModalOverlay.active { display:flex; }
        #customModal { background:#fff; border-radius:16px; width:100%; max-width:400px; padding:36px 32px 28px; box-shadow:0 12px 40px rgba(0,0,0,.28); text-align:center; }
        #customModal .cm-icon-wrap { width:68px; height:68px; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 16px; background:#fff8e1; }
        #customModal svg { width:32px; height:32px; display:block; }
        #customModal .cm-title { font-size:1.2rem; font-weight:700; color:#1a1a2e; margin-bottom:14px; }
        #customModal .cm-divider { border:none; border-top:1px solid #ececec; margin:0 -32px 18px; }
        #customModal .cm-body { font-size:.97rem; line-height:1.65; color:#555; margin-bottom:28px; }
        #customModal .cm-btn { padding:10px 32px; border-radius:50px; font-size:.95rem; font-weight:600; cursor:pointer; transition:all .18s; min-width:110px; background:transparent; border:2px solid #e8a838; color:#e8a838; }
        #customModal .cm-btn:hover { background:#fdf3e0; }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <div class="page-content">
        <h2 class="page-title"><i class="fa-solid fa-clipboard-list"></i> Student Enrollment</h2>
        <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false"></asp:Label>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fa-solid fa-user-graduate"></i></div>
                <div>
                    <div class="stat-value"><asp:Label ID="lblTotalEnrollments" runat="server" Text="0" /></div>
                    <div class="stat-label">Total Enrollments</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fa-solid fa-money-bill-wave"></i></div>
                <div>
                    <div class="stat-value">RM <asp:Label ID="lblPendingFees" runat="server" Text="0.00" /></div>
                    <div class="stat-label">Pending Tuition</div>
                </div>
            </div>
        </div>

        <div class="card" style="margin-bottom:30px;">
            <div class="card-header">
                <span class="card-title"><i class="fa-solid fa-plus-circle"></i> Enroll Student to Courses</span>
            </div>
            <div class="card-body">
                <div class="grid-2">
                    <div class="form-group">
                        <label>Programme <span style="color:red">*</span></label>
                        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-control"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" />
                    </div>
                    <div class="form-group">
                        <label>Student <span style="color:red">*</span></label>
                        <asp:DropDownList ID="ddlStudent" runat="server" CssClass="form-control"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlStudent_SelectedIndexChanged" />
                    </div>
                </div>

                <div class="grid-2">
                    <div class="form-group">
                        <label>Session <span style="color:red">*</span></label>
                        <asp:DropDownList ID="ddlSession" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlSession_SelectedIndexChanged" />
                    </div>
                    <div class="form-group">
                        <label>Semester <span style="color:red">*</span></label>
                        <asp:TextBox ID="txtSemester" runat="server" CssClass="form-control" TextMode="Number" />
                    </div>
                </div>

                <div class="form-group">
                    <label>Courses <span style="color:red">*</span></label>
                    <div class="course-box">
                        <asp:CheckBoxList ID="cblCourses" runat="server" RepeatDirection="Vertical" />
                    </div>
                </div>

                <div style="margin-top:25px; display:flex; gap:12px; flex-wrap:wrap;">
                    <asp:Button ID="btnEnroll" runat="server" Text="Enroll Selected Courses" CssClass="btn btn-primary" OnClick="btnEnroll_Click" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-outline" OnClick="btnClear_Click" CausesValidation="false" />
                    <asp:Button ID="btnBack" runat="server" Text="Back to Dashboard" CssClass="btn btn-outline" OnClick="btnBack_Click" CausesValidation="false" />
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <span class="card-title"><i class="fa-solid fa-list"></i> Student Enrollment Summary</span>
            </div>
            <div class="card-body">
                <div class="grid-2" style="margin-bottom:18px;">
                    <div class="form-group">
                        <label>Filter by Programme</label>
                        <asp:DropDownList ID="ddlFilterProgramme" runat="server" CssClass="form-control"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProgramme_SelectedIndexChanged" />
                    </div>
                    <div class="form-group">
                        <label>Filter by Status</label>
                        <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-control"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStatus_SelectedIndexChanged">
                            <asp:ListItem Text="-- All Status --" Value="" />
                            <asp:ListItem Text="Active" Value="Active" />
                            <asp:ListItem Text="Drop Pending" Value="Drop Pending" />
                            <asp:ListItem Text="Dropped" Value="Dropped" />
                            <asp:ListItem Text="Drop Rejected" Value="Drop Rejected" />
                            <asp:ListItem Text="Completed" Value="Completed" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div style="margin-bottom:18px;">
                    <asp:Button ID="btnResetSummaryFilter" runat="server" Text="Reset Filter" CssClass="btn btn-outline" OnClick="btnResetSummaryFilter_Click" CausesValidation="false" />
                </div>
                <div class="table-wrapper">
                    <asp:GridView ID="gvSummary" runat="server" CssClass="data-table" AutoGenerateColumns="false" EmptyDataText="No enrollment summary found." OnRowCommand="gvSummary_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="StudentId" HeaderText="Student ID" />
                            <asp:BoundField DataField="StudentName" HeaderText="Student Name" />
                            <asp:BoundField DataField="ProgrammeCode" HeaderText="Programme" />
                            <asp:TemplateField HeaderText="Enrolled Courses">
                                <ItemTemplate>
                                    <asp:Literal ID="litCourses" runat="server" Text='<%# Eval("CourseList") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="CourseCount" HeaderText="Total Courses" />
                            <asp:BoundField DataField="Session" HeaderText="Session" />
                            <asp:BoundField DataField="Semester" HeaderText="Sem" />
                            <asp:BoundField DataField="TotalAmount" HeaderText="Total Fee (RM)" DataFormatString="{0:N2}" />
                            <asp:BoundField DataField="Status" HeaderText="Status" />
                            <asp:TemplateField HeaderText="Drop Reason">
                                <ItemTemplate>
                                    <asp:Label ID="lblDropReason" runat="server"
                                        CssClass='<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("DropReason"))) ? "drop-reason-empty" : "drop-reason-text" %>'
                                        Text='<%# FormatDropReason(Eval("DropReason")) %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <div class="action-row">
                                        <asp:LinkButton ID="btnApproveDrop" runat="server"
                                            Text="Approve Drop"
                                            CssClass="btn btn-primary action-btn"
                                            CommandName="ApproveDrop"
                                            CommandArgument='<%# Eval("StudentId") + "|" + Eval("CourseId") + "|" + Eval("Session") + "|" + Eval("Semester") %>'
                                            Visible='<%# IsDropPending(Eval("Status")) %>'
                                            OnClientClick="return showConfirmDialog(this, 'Approve this drop request?');" />

                                        <asp:LinkButton ID="btnRejectDrop" runat="server"
                                            Text="Reject"
                                            CssClass="btn btn-outline action-btn"
                                            CommandName="RejectDrop"
                                            CommandArgument='<%# Eval("StudentId") + "|" + Eval("CourseId") + "|" + Eval("Session") + "|" + Eval("Semester") %>'
                                            Visible='<%# IsDropPending(Eval("Status")) %>'
                                            OnClientClick="return showConfirmDialog(this, 'Reject this drop request?');" />

                                        <asp:Label ID="lblNoAction" runat="server"
                                            Text="-"
                                            Visible='<%# !IsDropPending(Eval("Status")) %>' />
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

    <div id="customModalOverlay">
        <div id="customModal">
            <div class="cm-icon-wrap"><span id="cmIcon"></span></div>
            <div class="cm-title" id="cmTitle">Message</div>
            <hr class="cm-divider" />
            <div class="cm-body" id="cmBody"></div>
            <button type="button" class="cm-btn" onclick="closeCustomModal()">OK</button>
        </div>
    </div>


    <div id="confirmModalOverlay">
        <div id="confirmModal">
            <div class="cm-icon-wrap"><span id="confirmIcon"></span></div>
            <div class="cm-title">Confirmation</div>
            <hr class="cm-divider" />
            <div class="cm-body" id="confirmBody"></div>
            <div class="cm-actions">
                <button type="button" class="cm-btn cm-btn-primary" onclick="confirmProceed()">Yes</button>
                <button type="button" class="cm-btn cm-btn-secondary" onclick="closeConfirmModal()">Cancel</button>
            </div>
        </div>
    </div>

    <script>
        var SVG_TICK = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
        var SVG_WARN = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
        function showMessageModal(title, message) {
            document.getElementById('cmIcon').innerHTML = title.indexOf('Warning') >= 0 || title.indexOf('Error') >= 0 ? SVG_WARN : SVG_TICK;
            document.getElementById('cmTitle').innerHTML = title;
            document.getElementById('cmBody').innerHTML = message;
            document.getElementById('customModalOverlay').classList.add('active');
        }
        function closeCustomModal() { document.getElementById('customModalOverlay').classList.remove('active'); }
        var pendingConfirmButton = null;
        function showConfirmDialog(btn, message) {
            if (btn.getAttribute('data-confirmed') === 'true') {
                btn.removeAttribute('data-confirmed');
                return true;
            }
            pendingConfirmButton = btn;
            document.getElementById('confirmIcon').innerHTML = SVG_WARN;
            document.getElementById('confirmBody').innerHTML = message;
            document.getElementById('confirmModalOverlay').classList.add('active');
            return false;
        }
        function closeConfirmModal() {
            document.getElementById('confirmModalOverlay').classList.remove('active');
            pendingConfirmButton = null;
        }
        function confirmProceed() {
            if (pendingConfirmButton) {
                var btn = pendingConfirmButton;
                closeConfirmModal();
                btn.setAttribute('data-confirmed', 'true');
                btn.click();
            }
        }

    </script>
</form>
</body>
</html>
