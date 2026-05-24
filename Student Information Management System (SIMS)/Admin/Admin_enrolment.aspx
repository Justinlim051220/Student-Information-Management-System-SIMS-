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
        .summary-box { background:#fff8e1; border:1px solid #f0d38a; border-radius:14px; padding:18px; margin-top:18px; }
        .fee-total { font-size:1.3rem; font-weight:700; color:#1a1a2e; }
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
                        <asp:TextBox ID="txtSemester" runat="server" CssClass="form-control" TextMode="Number" Text="1" />
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

                <div class="summary-box">
                    <div class="fee-total">Selected Fee Summary: RM <asp:Label ID="lblSelectedTotal" runat="server" Text="0.00" /></div>
                    <div style="color:#666; margin-top:6px;">Fee total is based on CourseFees for the selected session.</div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <span class="card-title"><i class="fa-solid fa-list"></i> Student Enrollment Summary</span>
            </div>
            <div class="card-body">
                <div class="table-wrapper">
                    <asp:GridView ID="gvSummary" runat="server" CssClass="data-table" AutoGenerateColumns="false" EmptyDataText="No enrollment summary found.">
                        <Columns>
                            <asp:BoundField DataField="StudentId" HeaderText="Student ID" />
                            <asp:BoundField DataField="StudentName" HeaderText="Student" />
                            <asp:BoundField DataField="CourseCode" HeaderText="Code" />
                            <asp:BoundField DataField="CourseName" HeaderText="Course" />
                            <asp:BoundField DataField="Session" HeaderText="Session" />
                            <asp:BoundField DataField="Semester" HeaderText="Sem" />
                            <asp:BoundField DataField="Amount" HeaderText="Fee (RM)" DataFormatString="{0:N2}" />
                            <asp:BoundField DataField="Status" HeaderText="Status" />
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
    </script>
</form>
</body>
</html>
