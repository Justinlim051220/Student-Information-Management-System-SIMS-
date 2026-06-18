<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageFees.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.Admin_ManageFees" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Manage Fees - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />
    <style>
        h2.page-title { margin-bottom:25px; }
        .fee-note { background:#fff8e1; border:1px solid #f0d38a; border-radius:14px; padding:15px 18px; margin-bottom:24px; color:#555; line-height:1.6; }
        .status-badge { padding:6px 12px; border-radius:50px; font-size:12px; font-weight:700; display:inline-block; }
        .status-pending { background:#fff8e1; color:#b7791f; border:1px solid #f0d38a; }
        .status-paid { background:#e7f8ee; color:#16803a; border:1px solid #a9e7bf; }
        .status-rejected { background:#fdecec; color:#c53030; border:1px solid #f5b5b5; }
        .action-row { display:flex; gap:10px; flex-wrap:wrap; align-items:center; }
        .action-btn { display:inline-flex; align-items:center; justify-content:center; gap:7px; min-width:86px; padding:8px 14px; border-radius:50px; font-weight:700; font-size:12px; cursor:pointer; text-decoration:none; border:2px solid transparent; transition:all .18s ease; background:#fff; }
        .approve-btn { color:#16803a; border-color:#16803a; }
        .approve-btn:hover { background:#16803a; color:#fff; }
        .reject-btn { color:#c53030; border-color:#c53030; }
        .reject-btn:hover { background:#c53030; color:#fff; }
        .suspend-btn { color:#7c2d12; border-color:#f97316; }
        .suspend-btn:hover { background:#f97316; color:#fff; }
        .unsuspend-btn { color:#166534; border-color:#22c55e; }
        .unsuspend-btn:hover { background:#22c55e; color:#fff; }
        .edit-btn { color:#e8a838; border-color:#e8a838; }
        .edit-btn:hover { background:#e8a838; color:#fff; }
        .delete-btn { color:#e8a838; border-color:#e8a838; }
        .delete-btn:hover { background:#e8a838; color:#fff; }
        #customModalOverlay { display:none; position:fixed; inset:0; background:rgba(30,30,40,.60); z-index:9999; justify-content:center; align-items:center; }
        #customModalOverlay.active { display:flex; }
        #customModal { background:#fff; border-radius:16px; width:100%; max-width:400px; padding:36px 32px 28px; box-shadow:0 12px 40px rgba(0,0,0,.28); text-align:center; }
        #customModal .cm-icon-wrap { width:68px; height:68px; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 16px; background:#fff8e1; }
        #customModal svg { width:32px; height:32px; display:block; }
        #customModal .cm-title { font-size:1.2rem; font-weight:700; color:#1a1a2e; margin-bottom:14px; }
        #customModal .cm-divider { border:none; border-top:1px solid #ececec; margin:0 -32px 18px; }
        #customModal .cm-body { font-size:.97rem; line-height:1.65; color:#555; margin-bottom:28px; }
        #customModal .cm-actions { display:flex; gap:12px; justify-content:center; flex-wrap:wrap; }
        #customModal .cm-btn { padding:10px 32px; border-radius:50px; font-size:.95rem; font-weight:600; cursor:pointer; transition:all .18s; min-width:110px; background:transparent; border:2px solid #e8a838; color:#e8a838; }
        #customModal .cm-btn:hover { background:#fdf3e0; }
        #customModal .cm-btn-danger { border-color:#dc3545; color:#dc3545; }
        #customModal .cm-btn-danger:hover { background:#dc3545; color:#fff; }
        #customModal .cm-btn-muted { border-color:#9ca3af; color:#4b5563; }
        #customModal .cm-btn-muted:hover { background:#f3f4f6; }
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }

        .status-paid {
            background: #d4edda;
            color: #155724;
        }

        .status-pending {
            background: #fff3cd;
            color: #856404;
        }

        .status-overdue {
            background: #f8d7da;
            color: #721c24;
        }


        .course-list { line-height:1.65; min-width:260px; }
        .course-line { padding:4px 0; border-bottom:1px dashed #eee; }
        .course-line:last-child { border-bottom:none; }
        .course-code { font-weight:700; color:#1f2937; margin-right:8px; }
        .course-name { color:#4b5563; }
        .course-fee { color:#b7791f; font-weight:700; margin-left:8px; white-space:nowrap; }
        .receipt-link { display:inline-flex; align-items:center; gap:7px; padding:7px 12px; border:1px solid #e8a838; color:#b7791f; border-radius:50px; text-decoration:none; font-weight:700; font-size:12px; background:#fffaf0; }
        .receipt-link:hover { background:#e8a838; color:#fff; }
        .receipt-empty { color:#9ca3af; font-size:12px; font-weight:600; }

        .status-rejected {
            background: #e2e3e5;
            color: #383d41;
        }

        .status-not-active {
            background: #eef2f7;
            color: #475569;
            border: 1px solid #d7dee8;
        }

        .status-suspended {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .status-active-account {
            background: #e7f8ee;
            color: #16803a;
            border: 1px solid #a9e7bf;
        }

        .suspension-reason {
            display: block;
            margin-top: 6px;
            font-size: 12px;
            color: #64748b;
            font-weight: 600;
            line-height: 1.4;
        }

        .no-admin-action {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 8px 14px;
            border-radius: 50px;
            background: #f3f6fa;
            color: #475569;
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <div class="page-content">
        <h2 class="page-title"><i class="fa-solid fa-money-bill-wave"></i> Manage Fees</h2>


        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fa-solid fa-clock"></i></div>
                <div><div class="stat-value">RM <asp:Label ID="lblPendingAmount" runat="server" Text="0.00" /></div><div class="stat-label">Pending Fees</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green"><i class="fa-solid fa-check"></i></div>
                <div><div class="stat-value">RM <asp:Label ID="lblPaidAmount" runat="server" Text="0.00" /></div><div class="stat-label">Approved / Paid</div></div>
            </div>
        </div>

        <div class="card" style="margin-bottom:30px;">
            <div class="card-header"><span class="card-title"><i class="fa-solid fa-tags"></i> Manage Course Fee</span></div>
            <div class="card-body">
                <asp:HiddenField ID="hfCourseFeeId" runat="server" />
                <asp:HiddenField ID="hfDeleteCourseFeeId" runat="server" />
                <div class="grid-2">
                    <div class="form-group">
                        <label>Programme</label>
                        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" />
                    </div>
                    <div class="form-group">
                        <label>Course</label>
                        <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="grid-2">
                    <div class="form-group">
                        <label>Session</label>
                        <asp:DropDownList ID="ddlFeeSession" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label>Amount (RM)</label>
                        <asp:TextBox ID="txtAmount" runat="server" CssClass="form-control" TextMode="Number" placeholder="e.g. 1200.00" />
                    </div>
                </div>
                <div style="margin-top:20px; display:flex; gap:12px; flex-wrap:wrap;">
                    <asp:Button ID="btnSaveCourseFee" runat="server" Text="Save Course Fee" CssClass="btn btn-primary" OnClick="btnSaveCourseFee_Click" />
                    <asp:Button ID="btnClearCourseFee" runat="server" Text="Clear" CssClass="btn btn-outline" OnClick="btnClearCourseFee_Click" CausesValidation="false" />
                    <asp:Button ID="btnBack" runat="server" Text="Back to Dashboard" CssClass="btn btn-outline" OnClick="btnBack_Click" CausesValidation="false" />
                    <asp:Button ID="btnConfirmDeleteCourseFee" runat="server" Text="Confirm Delete" OnClick="btnConfirmDeleteCourseFee_Click" CausesValidation="false" Style="display:none;" />
                </div>

                <div class="table-wrapper" style="margin-top:25px;">
                    <asp:GridView ID="gvCourseFees" runat="server" CssClass="data-table" AutoGenerateColumns="false" EmptyDataText="No course fee found." OnRowCommand="gvCourseFees_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="ProgrammeCode" HeaderText="Programme" />
                            <asp:BoundField DataField="CourseCode" HeaderText="Code" />
                            <asp:BoundField DataField="CourseName" HeaderText="Course" />
                            <asp:BoundField DataField="Session" HeaderText="Session" />
                            <asp:BoundField DataField="Amount" HeaderText="Amount (RM)" DataFormatString="{0:N2}" />
                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <div class="action-row">
                                        <asp:LinkButton ID="btnEditFee" runat="server" CssClass="action-btn edit-btn" CommandName="EditFee" CommandArgument='<%# Eval("CourseFeeId") %>'><i class="fa-solid fa-pen-to-square"></i> Edit</asp:LinkButton>
                                        <asp:LinkButton ID="btnDeleteFee" runat="server" CssClass="action-btn delete-btn" CommandName="DeleteFee" CommandArgument='<%# Eval("CourseFeeId") %>' OnClientClick='<%# "showDeleteConfirm(\"" + Eval("CourseFeeId") + "\"); return false;" %>'><i class="fa-solid fa-trash"></i> Delete</asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header"><span class="card-title"><i class="fa-solid fa-receipt"></i> Pending Student Payments</span></div>
            <div class="card-body">
                <div class="grid-2">
                    <div class="form-group">
                        <label>Filter Session</label>
                        <asp:DropDownList ID="ddlPaymentSession" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlPaymentSession_SelectedIndexChanged" />
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                            <asp:ListItem Text="Pending" Value="Pending" />
                            <asp:ListItem Text="Paid" Value="Paid" />
                            <asp:ListItem Text="Rejected" Value="Rejected" />
                            <asp:ListItem Text="Overdue" Value="Overdue" />
                            <asp:ListItem Text="Not Active" Value="Not Active" />
                            <asp:ListItem Text="All" Value="" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="table-wrapper">
                    <asp:GridView ID="gvPayments" runat="server" CssClass="data-table" AutoGenerateColumns="false" EmptyDataText="No fee records found." OnRowCommand="gvPayments_RowCommand" OnRowDataBound="gvPayments_RowDataBound">
                        <Columns>
                            <asp:BoundField DataField="StudentId" HeaderText="Student ID" />
                            <asp:BoundField DataField="StudentName" HeaderText="Student" />
                            <asp:BoundField DataField="ProgrammeCode" HeaderText="Programme" />
                            <asp:BoundField DataField="Session" HeaderText="Session" />
                            <asp:TemplateField HeaderText="Courses to Pay">
                                <ItemTemplate>
                                    <div class="course-list">
                                        <%# Eval("CoursePaymentList") %>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="DisplayAmount" HeaderText="Total Amount (RM)" DataFormatString="{0:N2}" />
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <asp:Label ID="lblStatus" runat="server"
                                        Text='<%# Eval("DisplayStatus") %>'
                                        CssClass='<%# "status-badge " + GetStatusCss(Eval("DisplayStatus")) %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Account">
                                <ItemTemplate>
                                    <asp:Label ID="lblAccountStatus" runat="server"
                                        Text='<%# GetAccountStatusText(Eval("IsSuspended")) %>'
                                        CssClass='<%# "status-badge " + GetAccountStatusCss(Eval("IsSuspended")) %>' />
                                    <%# GetSuspensionReason(Eval("IsSuspended"), Eval("SuspensionReason")) %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="PaymentDate" HeaderText="Payment Date" DataFormatString="{0:yyyy-MM-dd}" />
                            <asp:TemplateField HeaderText="Receipt">
                                <ItemTemplate>
                                    <%# GetReceiptLink(Eval("PaymentReceiptPath")) %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <div class="action-row">
                                        <asp:LinkButton ID="btnApprove" runat="server" CssClass="action-btn approve-btn" CommandName="ApprovePayment" CommandArgument='<%# Eval("FeeId") %>'><i class="fa-solid fa-check"></i> Approve</asp:LinkButton>
                                        <asp:LinkButton ID="btnReject" runat="server" CssClass="action-btn reject-btn" CommandName="RejectPayment" CommandArgument='<%# Eval("FeeId") %>'><i class="fa-solid fa-xmark"></i> Reject</asp:LinkButton>
                                        <asp:LinkButton ID="btnSuspend" runat="server" CssClass="action-btn suspend-btn" CommandName="SuspendStudent" CommandArgument='<%# Eval("StudentId") %>'><i class="fa-solid fa-user-lock"></i> Suspend</asp:LinkButton>
                                        <asp:LinkButton ID="btnUnsuspend" runat="server" CssClass="action-btn unsuspend-btn" CommandName="UnsuspendStudent" CommandArgument='<%# Eval("StudentId") %>'><i class="fa-solid fa-user-check"></i> Unsuspend</asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

    <div id="customModalOverlay"><div id="customModal"><div class="cm-icon-wrap"><span id="cmIcon"></span></div><div class="cm-title" id="cmTitle">Message</div><hr class="cm-divider" /><div class="cm-body" id="cmBody"></div><div class="cm-actions" id="cmActions"><button type="button" class="cm-btn" onclick="closeCustomModal()">OK</button></div></div></div>
    <script>
        var SVG_TICK = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
        var SVG_WARN = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
        function showMessageModal(title, message) {
            document.getElementById('cmIcon').innerHTML = title.indexOf('Warning') >= 0 || title.indexOf('Error') >= 0 ? SVG_WARN : SVG_TICK;
            document.getElementById('cmTitle').innerHTML = title;
            document.getElementById('cmBody').innerHTML = message;
            document.getElementById('cmActions').innerHTML = '<button type="button" class="cm-btn" onclick="closeCustomModal()">OK</button>';
            document.getElementById('customModalOverlay').classList.add('active');
        }
        function showDeleteConfirm(courseFeeId) {
            document.getElementById('<%= hfDeleteCourseFeeId.ClientID %>').value = courseFeeId;
            document.getElementById('cmIcon').innerHTML = SVG_WARN;
            document.getElementById('cmTitle').innerHTML = 'Confirm Delete';
            document.getElementById('cmBody').innerHTML = 'Are you sure you want to delete this course fee?';
            document.getElementById('cmActions').innerHTML = '<button type="button" class="cm-btn cm-btn-muted" onclick="closeCustomModal()">Cancel</button><button type="button" class="cm-btn cm-btn-danger" onclick="confirmDeleteCourseFee()">Delete</button>';
            document.getElementById('customModalOverlay').classList.add('active');
        }
        function confirmDeleteCourseFee() {
            closeCustomModal();
            document.getElementById('<%= btnConfirmDeleteCourseFee.ClientID %>').click();
        }
        function closeCustomModal() { document.getElementById('customModalOverlay').classList.remove('active'); }
    </script>
</form>
</body>
</html>
