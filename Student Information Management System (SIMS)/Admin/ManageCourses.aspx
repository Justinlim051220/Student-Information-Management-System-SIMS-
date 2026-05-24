<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageCourses.aspx.cs"
         Inherits="Student_Information_Management_System__SIMS_.Admin.ManageCourses" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Manage Courses - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />
    <style>
        /* ── Custom Modal Overlay ── */
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
            max-width: 400px;
            padding: 36px 32px 28px;
            box-shadow: 0 12px 40px rgba(0,0,0,.28);
            text-align: center;
            animation: modalIn .18s ease;
        }
        @keyframes modalIn {
            from { transform: scale(.93); opacity: 0; }
            to   { transform: scale(1);  opacity: 1; }
        }

        /* Large icon circle above title */
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

        /* The inner span must also be flex so SVG centres perfectly */
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

        /* Title */
        #customModal .cm-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1a1a2e;
            margin-bottom: 14px;
        }

        /* Divider */
        #customModal .cm-divider {
            border: none;
            border-top: 1px solid #ececec;
            margin: 0 -32px 18px;
        }

        /* Body text */
        #customModal .cm-body {
            font-size: .97rem;
            line-height: 1.65;
            color: #555;
            margin-bottom: 28px;
        }

        /* Footer – centered buttons */
        #customModal .cm-footer {
            display: flex;
            justify-content: center;
            gap: 16px;
        }

        /* Base pill button */
        #customModal .cm-btn {
            padding: 10px 32px;
            border-radius: 50px;
            font-size: .95rem;
            font-weight: 600;
            cursor: pointer;
            transition: all .18s;
            min-width: 110px;
        }

        /* Outlined Cancel – yellow theme */
        #customModal .cm-btn-cancel {
            background: transparent;
            border: 2px solid #e8a838;
            color: #e8a838;
        }
        #customModal .cm-btn-cancel:hover { background: #fdf3e0; }

        /* OK – yellow theme (solid) */
        #customModal .cm-btn-ok {
            background: transparent;
            border: 2px solid #e8a838;
            color: #e8a838;
        }
        #customModal .cm-btn-ok:hover { background: #fdf3e0; }

        /* Confirm delete – yellow text link style */
        #customModal .cm-btn-delete {
            background: transparent;
            border: none;
            color: #e8a838;
            font-weight: 700;
            font-size: .97rem;
            padding: 10px 8px;
        }
        #customModal .cm-btn-delete:hover {
            color: #c8881a;
            text-decoration: underline;
        }


        /* Action buttons spacing */
        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 10px;
            align-items: center;
        }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-content">

            <h2 style="margin-bottom:25px;"><i class="fa-solid fa-book-open"></i> Manage Courses</h2>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false"></asp:Label>

            <!-- Summary Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon orange"><i class="fa-solid fa-book-open"></i></div>
                    <div>
                        <div class="stat-value"><asp:Label ID="lblTotalCourses" runat="server" Text="0" /></div>
                        <div class="stat-label">Total Courses</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fa-solid fa-layer-group"></i></div>
                    <div>
                        <div class="stat-value"><asp:Label ID="lblTotalProgrammes" runat="server" Text="0" /></div>
                        <div class="stat-label">Programmes</div>
                    </div>
                </div>
            </div>

            <!-- Add/Edit Form -->
            <div class="card" style="margin-bottom: 30px;">
                <div class="card-header">
                    <asp:Label ID="lblFormTitle" runat="server" Text="Add New Course" Font-Bold="true" />
                </div>
                <div class="card-body">

                    <asp:HiddenField ID="hfCourseId" runat="server" />

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Course Code <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtCourseCode" runat="server" CssClass="form-control"
                                         placeholder="e.g. CSC101" MaxLength="20" />
                        </div>

                        <div class="form-group">
                            <label>Course Name <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtCourseName" runat="server" CssClass="form-control"
                                         placeholder="e.g. Introduction to Programming" MaxLength="100" />
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Credits <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtCredits" runat="server" TextMode="Number" CssClass="form-control"
                                         placeholder="e.g. 3" />
                        </div>

                        <div class="form-group">
                            <label>Programme <span style="color:red">*</span></label>
                            <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-control" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4"
                                     CssClass="form-control" placeholder="Short course description" />
                    </div>

                    <div style="margin-top: 25px; display: flex; gap: 12px; flex-wrap: wrap;">
                        <asp:Button ID="btnSave" runat="server" Text="Save Course"
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

            <!-- Search / Filter -->
            <div class="card" style="margin-bottom: 30px;">
                <div class="card-header">
                    <span class="card-title"><i class="fa-solid fa-magnifying-glass"></i> Search / Filter Courses</span>
                </div>
                <div class="card-body">
                    <div class="grid-2">
                        <div class="form-group">
                            <label>Search Course</label>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control"
                                         placeholder="Search by course code or course name" />
                        </div>

                        <div class="form-group">
                            <label>Filter by Programme</label>
                            <asp:DropDownList ID="ddlFilterProgramme" runat="server" CssClass="form-control" />
                        </div>
                    </div>

                    <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                        <asp:Button ID="btnSearch" runat="server" Text="Search"
                                    CssClass="btn btn-primary" OnClick="btnSearch_Click" />

                        <asp:Button ID="btnResetSearch" runat="server" Text="Reset"
                                    CssClass="btn btn-outline" OnClick="btnResetSearch_Click"
                                    CausesValidation="false" />
                    </div>
                </div>
            </div>

            <!-- Courses List -->
            <div class="card">
                <div class="card-header">
                    <span class="card-title">All Courses</span>
                </div>
                <div class="card-body">
                    <div class="table-wrapper">
                        <asp:GridView ID="gvCourses" runat="server" CssClass="data-table"
                            AutoGenerateColumns="false" DataKeyNames="CourseId"
                            OnRowCommand="gvCourses_RowCommand"
                            AllowPaging="true" PageSize="10" OnPageIndexChanging="gvCourses_PageIndexChanging"
                            EmptyDataText="No courses found.">

                            <Columns>
                                <asp:BoundField DataField="CourseCode" HeaderText="Code" />
                                <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
                                <asp:BoundField DataField="Credits" HeaderText="Credits" />
                                <asp:BoundField DataField="ProgrammeCode" HeaderText="Programme" />
                                <asp:BoundField DataField="ProgrammeName" HeaderText="Programme Name" />
                                <asp:BoundField DataField="Description" HeaderText="Description" />

                                <asp:TemplateField HeaderText="Actions">
                                    <ItemTemplate>
                                        <div class="action-buttons">
                                            <asp:LinkButton ID="btnEdit" runat="server"
                                                CommandName="EditCourse"
                                                CommandArgument='<%# Eval("CourseId") %>'
                                                CssClass="btn btn-sm btn-outline">
                                                <i class="fa-solid fa-pen-to-square"></i> Edit
                                            </asp:LinkButton>

                                            <asp:LinkButton ID="btnDelete" runat="server"
                                                CommandName="DeleteCourse"
                                                CommandArgument='<%# Eval("CourseId") %>'
                                                CssClass="btn btn-sm btn-outline">
                                                <i class="fa-solid fa-trash"></i> Delete
                                            </asp:LinkButton>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

        </div>
        <!-- ====================== CUSTOM MODAL ====================== -->
        <div id="customModalOverlay">
            <div id="customModal">
                <div class="cm-icon-wrap" id="cmIconWrap">
                    <span id="cmIcon"></span>
                </div>
                <div class="cm-title" id="cmTitle">Message</div>
                <hr class="cm-divider" />
                <div class="cm-body" id="cmBody"></div>
                <div class="cm-footer">
                    <button type="button" class="cm-btn cm-btn-cancel" id="cmBtnCancel" style="display:none;" onclick="closeCustomModal()">Cancel</button>
                    <button type="button" class="cm-btn cm-btn-delete" id="cmBtnDelete" style="display:none;">Yes, Delete</button>
                    <button type="button" class="cm-btn cm-btn-ok" id="cmBtnOk" style="display:none;" onclick="closeCustomModal()">OK</button>
                </div>
            </div>
        </div>

        <asp:HiddenField ID="hfDeleteTarget" runat="server" />
        <asp:Button ID="btnDeleteConfirmed" runat="server" style="display:none;"
            OnClick="btnDeleteConfirmed_Click" CausesValidation="false" />

        <script>
            var SVG_TICK  = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
            var SVG_CROSS = '<svg viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>';
            var SVG_WARN  = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
            var SVG_TRASH = '<svg viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>';

            function showMessageModal(title, message, isConfirmDelete, courseId) {
                var iconWrap  = document.getElementById('cmIconWrap');
                var iconEl    = document.getElementById('cmIcon');
                var titleEl   = document.getElementById('cmTitle');
                var body      = document.getElementById('cmBody');
                var btnOk     = document.getElementById('cmBtnOk');
                var btnCancel = document.getElementById('cmBtnCancel');
                var btnDelete = document.getElementById('cmBtnDelete');

                iconWrap.className = 'cm-icon-wrap';

                if (isConfirmDelete) {
                    iconWrap.classList.add('icon-delete');
                    iconEl.innerHTML  = SVG_TRASH;
                    titleEl.innerHTML = 'Confirm Delete';
                } else if (title.indexOf('✅') !== -1) {
                    iconWrap.classList.add('icon-success');
                    iconEl.innerHTML  = SVG_TICK;
                    titleEl.innerHTML = 'Success';
                } else if (title.indexOf('❌') !== -1) {
                    iconWrap.classList.add('icon-error');
                    iconEl.innerHTML  = SVG_CROSS;
                    titleEl.innerHTML = 'Error';
                } else if (title.indexOf('⚠') !== -1) {
                    iconWrap.classList.add('icon-warning');
                    iconEl.innerHTML  = SVG_WARN;
                    titleEl.innerHTML = 'Warning';
                } else if (title === 'Edit Mode') {
                    iconWrap.classList.add('icon-success');
                    iconEl.innerHTML  = SVG_TICK;
                    titleEl.innerHTML = 'Edit Mode';
                } else {
                    iconWrap.classList.add('icon-success');
                    iconEl.innerHTML  = SVG_TICK;
                    titleEl.innerHTML = title;
                }

                body.innerHTML = message;
                btnOk.style.display = 'none';
                btnCancel.style.display = 'none';
                btnDelete.style.display = 'none';

                if (isConfirmDelete) {
                    btnCancel.style.display = 'inline-block';
                    btnDelete.style.display = 'inline-block';
                    btnDelete.onclick = function () {
                        document.getElementById('<%= hfDeleteTarget.ClientID %>').value = courseId;
                        closeCustomModal();
                        document.getElementById('<%= btnDeleteConfirmed.ClientID %>').click();
                    };
                } else {
                    btnOk.style.display = 'inline-block';
                }

                document.getElementById('customModalOverlay').classList.add('active');
            }

            function closeCustomModal() {
                document.getElementById('customModalOverlay').classList.remove('active');
            }

            document.getElementById('customModalOverlay').addEventListener('click', function (e) {
                if (e.target === this) closeCustomModal();
            });
        </script>
    </form>
</body>
</html>
