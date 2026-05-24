﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AssignLecturerCourse.aspx.cs"
         Inherits="Student_Information_Management_System__SIMS_.Admin.AssignLecturerCourse" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Assign Course - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />
    <style>
        #customModalOverlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(30, 30, 40, 0.60);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }
        #customModalOverlay.active { display: flex; }
        #customModal {
            background: #fff;
            border-radius: 16px;
            width: 100%;
            max-width: 420px;
            padding: 36px 32px 28px;
            box-shadow: 0 12px 40px rgba(0,0,0,.28);
            text-align: center;
            animation: modalIn .18s ease;
        }
        @keyframes modalIn {
            from { transform: scale(.93); opacity: 0; }
            to   { transform: scale(1);  opacity: 1; }
        }
        #customModal .cm-icon-wrap {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
        }
        #customModal .cm-icon-wrap.icon-success { background: #fff8e1; }
        #customModal .cm-icon-wrap.icon-error   { background: #fdecea; }
        #customModal .cm-icon-wrap.icon-warning { background: #fff3e0; }
        #customModal .cm-icon-wrap.icon-delete  { background: #fdecea; }
        #customModal .cm-icon-wrap #cmIcon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
        }
        #customModal .cm-icon-wrap svg {
            width: 32px;
            height: 32px;
            display: block;
        }
        #customModal .cm-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1a1a2e;
            margin-bottom: 14px;
        }
        #customModal .cm-divider {
            border: none;
            border-top: 1px solid #ececec;
            margin: 0 -32px 18px;
        }
        #customModal .cm-body {
            font-size: .97rem;
            line-height: 1.65;
            color: #555;
            margin-bottom: 28px;
        }
        #customModal .cm-footer {
            display: flex;
            justify-content: center;
            gap: 16px;
        }
        #customModal .cm-btn {
            padding: 10px 32px;
            border-radius: 50px;
            font-size: .95rem;
            font-weight: 600;
            cursor: pointer;
            transition: all .18s;
            min-width: 110px;
        }
        #customModal .cm-btn-cancel,
        #customModal .cm-btn-ok {
            background: transparent;
            border: 2px solid #e8a838;
            color: #e8a838;
        }
        #customModal .cm-btn-cancel:hover,
        #customModal .cm-btn-ok:hover { background: #fdf3e0; }
        #customModal .cm-btn-delete {
            background: transparent;
            border: none;
            color: #e8a838;
            font-weight: 700;
            font-size: .97rem;
            padding: 10px 8px;
        }
        #customModal .cm-btn-delete:hover {
            color: #e8a838;
            text-decoration: underline;
        }
        .hint-text {
            font-size: 12px;
            color: #777;
            margin-top: 6px;
        }
        .page-title {
            margin-bottom: 25px;
        }
        .action-buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .delete-outline {
            border: 2px solid #e8a838 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-content">

            <h2 style="margin-bottom:25px;">
                <i class="fa-solid fa-user-check"></i>
                Assign Course to Lecturer
            </h2>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false"></asp:Label>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon orange"><i class="fa-solid fa-list-check"></i></div>
                    <div>
                        <div class="stat-value"><asp:Label ID="lblTotalAssignments" runat="server" Text="0" /></div>
                        <div class="stat-label">Total Assignments</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fa-solid fa-chalkboard-user"></i></div>
                    <div>
                        <div class="stat-value"><asp:Label ID="lblAssignedLecturers" runat="server" Text="0" /></div>
                        <div class="stat-label">Assigned Lecturers</div>
                    </div>
                </div>
            </div>

            <div class="card" style="margin-bottom: 30px;">
                <div class="card-header">
                    <asp:Label ID="lblFormTitle" runat="server" Text="New Course Assignment" Font-Bold="true" />
                </div>
                <div class="card-body">

                    <asp:HiddenField ID="hfOriginalLecturerId" runat="server" />
                    <asp:HiddenField ID="hfOriginalCourseId" runat="server" />
                    <asp:HiddenField ID="hfOriginalSession" runat="server" />

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Programme <span style="color:red">*</span></label>
                            <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" />
                            <div class="hint-text">Lecturers and courses will be filtered by this programme.</div>
                        </div>

                        <div class="form-group">
                            <label>Session <span style="color:red">*</span></label>
                            <asp:DropDownList ID="ddlSession" runat="server" CssClass="form-control">
                                <asp:ListItem Value="">-- Select Session --</asp:ListItem>
                                <asp:ListItem>January 2026</asp:ListItem>
                                <asp:ListItem>April 2026</asp:ListItem>
                                <asp:ListItem>August 2026</asp:ListItem>
                                <asp:ListItem>January 2027</asp:ListItem>
                                <asp:ListItem>April 2027</asp:ListItem>
                                <asp:ListItem>August 2027</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Lecturer <span style="color:red">*</span></label>
                            <asp:DropDownList ID="ddlLecturer" runat="server" CssClass="form-control" />
                        </div>

                        <div class="form-group">
                            <label>Course <span style="color:red">*</span></label>
                            <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control" />
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Semester <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtSemester" runat="server" TextMode="Number" CssClass="form-control" Text="1" />
                        </div>
                    </div>

                    <div style="margin-top: 25px; display: flex; gap: 12px; flex-wrap: wrap;">
                        <asp:Button ID="btnSave" runat="server" Text="Assign Course"
                                    CssClass="btn btn-primary" OnClick="btnSave_Click" />

                        <asp:Button ID="btnClear" runat="server" Text="Clear Form"
                                    CssClass="btn btn-outline" OnClick="btnClear_Click"
                                    CausesValidation="false" />

                        <asp:Button ID="btnCancel" runat="server" Text="Back to Dashboard"
                                    CssClass="btn btn-outline" OnClick="btnCancel_Click"
                                    CausesValidation="false" />
                    </div>
                </div>
            </div>

            <div class="card" style="margin-bottom: 30px;">
                <div class="card-header">
                    <span class="card-title"><i class="fa-solid fa-magnifying-glass"></i> Search / Filter Assignments</span>
                </div>
                <div class="card-body">
                    <div class="grid-2">
                        <div class="form-group">
                            <label>Search Lecturer / Course / Session</label>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control"
                                         placeholder="e.g. LEC001, Database, April 2026" />
                        </div>

                        <div class="form-group">
                            <label>Programme</label>
                            <asp:DropDownList ID="ddlFilterProgramme" runat="server" CssClass="form-control" />
                        </div>
                    </div>

                    <div style="display:flex; gap:12px; flex-wrap:wrap;">
                        <asp:Button ID="btnSearch" runat="server" Text="Search"
                                    CssClass="btn btn-primary" OnClick="btnSearch_Click" />
                        <asp:Button ID="btnResetSearch" runat="server" Text="Reset"
                                    CssClass="btn btn-outline" OnClick="btnResetSearch_Click"
                                    CausesValidation="false" />
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <span class="card-title"><i class="fa-solid fa-table-list"></i> Lecturer Course Assignments</span>
                </div>
                <div class="card-body">
                    <asp:GridView ID="gvAssignments" runat="server" CssClass="data-table"
                        AutoGenerateColumns="false"
                        OnRowCommand="gvAssignments_RowCommand"
                        AllowPaging="true" PageSize="10" OnPageIndexChanging="gvAssignments_PageIndexChanging">

                        <Columns>
                            <asp:BoundField DataField="LecturerId" HeaderText="Lecturer ID" />
                            <asp:BoundField DataField="LecturerName" HeaderText="Lecturer" />
                            <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
                            <asp:BoundField DataField="CourseName" HeaderText="Course" />
                            <asp:BoundField DataField="ProgrammeName" HeaderText="Programme" />
                            <asp:BoundField DataField="Session" HeaderText="Session" />
                            <asp:BoundField DataField="Semester" HeaderText="Semester" />
                            <asp:BoundField DataField="AssignedDate" HeaderText="Assigned Date" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <div class="action-buttons">
                                        <asp:LinkButton runat="server" CommandName="EditAssignment"
                                            CommandArgument='<%# Eval("LecturerId") + "|" + Eval("CourseId") + "|" + Eval("Session") %>'
                                            CssClass="btn btn-sm btn-outline">
                                            <i class="fa-solid fa-pen-to-square"></i> Edit
                                        </asp:LinkButton>
                                        <asp:LinkButton runat="server" CommandName="DeleteAssignment"
                                            CommandArgument='<%# Eval("LecturerId") + "|" + Eval("CourseId") + "|" + Eval("Session") %>'
                                            CssClass="btn btn-sm btn-danger delete-outline"
                                            OnClientClick="return confirmDeleteAssignment(this);">
                                            <i class="fa-solid fa-trash"></i> Delete
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>

                        <EmptyDataTemplate>
                            <div style="text-align:center; padding:30px; color:#777;">
                                No course assignments found.
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

        </div>

        <div id="customModalOverlay">
            <div id="customModal">
                <div id="cmIconWrap" class="cm-icon-wrap icon-success">
                    <span id="cmIcon"></span>
                </div>
                <div id="cmTitle" class="cm-title">Message</div>
                <hr class="cm-divider" />
                <div id="cmBody" class="cm-body">Message body</div>
                <div class="cm-footer">
                    <button type="button" id="cmCancel" class="cm-btn cm-btn-cancel" onclick="closeCustomModal();" style="display:none;">Cancel</button>
                    <button type="button" id="cmDelete" class="cm-btn cm-btn-delete" onclick="continueDeleteAssignment();" style="display:none;">Delete</button>
                    <button type="button" id="cmOk" class="cm-btn cm-btn-ok" onclick="closeCustomModal();">OK</button>
                </div>
            </div>
        </div>

        <script type="text/javascript">
            const successIcon = `<svg viewBox="0 0 24 24" fill="none"><path d="M20 6L9 17L4 12" stroke="#e8a838" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/></svg>`;
            const errorIcon = `<svg viewBox="0 0 24 24" fill="none"><path d="M12 8V12" stroke="#e74c3c" stroke-width="3" stroke-linecap="round"/><path d="M12 16H12.01" stroke="#e74c3c" stroke-width="3" stroke-linecap="round"/><circle cx="12" cy="12" r="9" stroke="#e74c3c" stroke-width="2"/></svg>`;
            const warningIcon = `<svg viewBox="0 0 24 24" fill="none"><path d="M12 9V13" stroke="#e8a838" stroke-width="3" stroke-linecap="round"/><path d="M12 17H12.01" stroke="#e8a838" stroke-width="3" stroke-linecap="round"/><path d="M10.29 3.86L1.82 18A2 2 0 0 0 3.53 21H20.47A2 2 0 0 0 22.18 18L13.71 3.86A2 2 0 0 0 10.29 3.86Z" stroke="#e8a838" stroke-width="2"/></svg>`;
            const deleteIcon = `<svg viewBox="0 0 24 24" fill="none"><path d="M4 7H20" stroke="#e74c3c" stroke-width="2.5" stroke-linecap="round"/><path d="M10 11V17" stroke="#e74c3c" stroke-width="2.5" stroke-linecap="round"/><path d="M14 11V17" stroke="#e74c3c" stroke-width="2.5" stroke-linecap="round"/><path d="M6 7L7 21H17L18 7" stroke="#e74c3c" stroke-width="2.5" stroke-linejoin="round"/><path d="M9 7V4H15V7" stroke="#e74c3c" stroke-width="2.5" stroke-linejoin="round"/></svg>`;
            let pendingDeleteButton = null;

            function showNormalButtons() {
                document.getElementById('cmOk').style.display = 'inline-block';
                document.getElementById('cmCancel').style.display = 'none';
                document.getElementById('cmDelete').style.display = 'none';
            }

            function showDeleteButtons() {
                document.getElementById('cmOk').style.display = 'none';
                document.getElementById('cmCancel').style.display = 'inline-block';
                document.getElementById('cmDelete').style.display = 'inline-block';
            }

            function showCustomModal(type, title, message) {
                showNormalButtons();
                const wrap = document.getElementById('cmIconWrap');
                const icon = document.getElementById('cmIcon');
                wrap.className = 'cm-icon-wrap icon-' + type;

                if (type === 'error') icon.innerHTML = errorIcon;
                else if (type === 'warning') icon.innerHTML = warningIcon;
                else if (type === 'delete') icon.innerHTML = deleteIcon;
                else icon.innerHTML = successIcon;

                document.getElementById('cmTitle').innerHTML = title;
                document.getElementById('cmBody').innerHTML = message;
                document.getElementById('customModalOverlay').classList.add('active');
            }

            function closeCustomModal() {
                document.getElementById('customModalOverlay').classList.remove('active');
                pendingDeleteButton = null;
                showNormalButtons();
            }

            function confirmDeleteAssignment(button) {
                if (button.getAttribute('data-confirmed') === 'true') {
                    button.removeAttribute('data-confirmed');
                    return true;
                }

                pendingDeleteButton = button;

                const wrap = document.getElementById('cmIconWrap');
                const icon = document.getElementById('cmIcon');
                wrap.className = 'cm-icon-wrap icon-delete';
                icon.innerHTML = deleteIcon;

                document.getElementById('cmTitle').innerHTML = 'Delete Assignment?';
                document.getElementById('cmBody').innerHTML = 'Are you sure you want to delete this lecturer course assignment? This action cannot be undone.';
                showDeleteButtons();
                document.getElementById('customModalOverlay').classList.add('active');

                return false;
            }

            function continueDeleteAssignment() {
                if (pendingDeleteButton !== null) {
                    pendingDeleteButton.setAttribute('data-confirmed', 'true');
                    pendingDeleteButton.click();
                }
            }

            document.getElementById('customModalOverlay').addEventListener('click', function (e) {
                if (e.target === this) closeCustomModal();
            });
        </script>
    </form>
</body>
</html>
