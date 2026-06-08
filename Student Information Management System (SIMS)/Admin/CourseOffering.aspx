<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CourseOffering.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.Admin.CourseOffering" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Course Offering - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />
    <style>
        .action-buttons { display:flex; flex-direction:row; gap:10px; align-items:center; justify-content:center; flex-wrap:nowrap; }
        .courses-summary { line-height:1.7; }
        .course-count-pill { display:inline-block; padding:6px 12px; border-radius:999px; background:#fff8e1; color:#b26b00; font-weight:700; margin-bottom:8px; }
        .status-badge { padding:6px 12px; border-radius:999px; font-weight:700; font-size:.82rem; display:inline-block; }
        .status-open { background:#e8f5e9; color:#2e7d32; }
        .status-closed { background:#fdecea; color:#c62828; }
        .multi-dropdown { position:relative; width:100%; }
        .multi-dropdown-toggle { width:100%; min-height:44px; border:1px solid #ddd; border-radius:10px; background:#fff; padding:10px 42px 10px 14px; text-align:left; cursor:pointer; font-size:.95rem; color:#333; display:flex; align-items:center; justify-content:space-between; position:relative; }
        .multi-dropdown-toggle:after { content:'\f078'; font-family:'Font Awesome 6 Free'; font-weight:900; position:absolute; right:15px; color:#777; }
        .multi-dropdown.open .multi-dropdown-toggle:after { content:'\f077'; }
        .multi-dropdown-menu { display:none; position:absolute; top:calc(100% + 6px); left:0; right:0; max-height:280px; overflow-y:auto; border:1px solid #ddd; border-radius:12px; padding:10px 14px; background:#fff; box-shadow:0 12px 30px rgba(0,0,0,.14); z-index:999; }
        .multi-dropdown.open .multi-dropdown-menu { display:block; }
        .multi-dropdown-tools { display:flex; justify-content:space-between; gap:10px; border-bottom:1px solid #eee; padding-bottom:8px; margin-bottom:8px; }
        .multi-dropdown-tools button { border:0; background:transparent; color:#e8a838; font-weight:700; cursor:pointer; padding:4px 0; }
        .course-check-list { width:100%; }
        .course-check-list label { margin-left:8px; font-weight:500; cursor:pointer; }
        .course-check-list span { display:block; padding:7px 6px; border-radius:8px; }
        .course-check-list span:hover { background:#fff8e1; }
        .course-check-list input[type=checkbox] { transform:translateY(1px); cursor:pointer; }
        .field-hint { display:block; margin-top:8px; color:#777; font-size:.86rem; }

        #customModalOverlay { display:none; position:fixed; inset:0; background:rgba(30,30,40,.6); z-index:9999; justify-content:center; align-items:center; }
        #customModalOverlay.active { display:flex; }
        #customModal { background:#fff; border-radius:16px; width:100%; max-width:400px; padding:36px 32px 28px; box-shadow:0 12px 40px rgba(0,0,0,.28); text-align:center; }
        #customModal .cm-icon-wrap { width:68px; height:68px; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 16px; background:#fff8e1; }
        #customModal .cm-icon-wrap svg { width:32px; height:32px; display:block; }
        #customModal .cm-title { font-size:1.2rem; font-weight:700; color:#1a1a2e; margin-bottom:14px; }
        #customModal .cm-divider { border:none; border-top:1px solid #ececec; margin:0 -32px 18px; }
        #customModal .cm-body { font-size:.97rem; line-height:1.65; color:#555; margin-bottom:28px; }
        #customModal .cm-footer { display:flex; justify-content:center; gap:16px; }
        #customModal .cm-btn { padding:10px 32px; border-radius:50px; font-size:.95rem; font-weight:600; cursor:pointer; min-width:110px; }
        #customModal .cm-btn-ok, #customModal .cm-btn-cancel { background:transparent; border:2px solid #e8a838; color:#e8a838; }
        #customModal .cm-btn-delete { background:transparent; border:none; color:#e8a838; font-weight:700; }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <div class="page-content">
        <h2 style="margin-bottom:25px;"><i class="fa-solid fa-calendar-check"></i> Course Offering</h2>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fa-solid fa-list-check"></i></div>
                <div><div class="stat-value"><asp:Label ID="lblTotalOfferings" runat="server" Text="0" /></div><div class="stat-label">Total Offerings</div></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fa-solid fa-lock-open"></i></div>
                <div><div class="stat-value"><asp:Label ID="lblOpenOfferings" runat="server" Text="0" /></div><div class="stat-label">Open Offerings</div></div>
            </div>
        </div>

        <div class="card" style="margin-bottom:30px;">
            <div class="card-header"><asp:Label ID="lblFormTitle" runat="server" Text="Add Course Offering" Font-Bold="true" /></div>
            <div class="card-body">
                <asp:HiddenField ID="hfOfferingId" runat="server" />

                <div class="grid-2">
                    <div class="form-group">
                        <label>Session <span style="color:red">*</span></label>
                        <asp:DropDownList ID="ddlSession" runat="server" CssClass="form-control">
                            <asp:ListItem Value="">-- Select Session --</asp:ListItem>
                            <asp:ListItem>April 2026</asp:ListItem>
                            <asp:ListItem>August 2026</asp:ListItem>
                            <asp:ListItem>January 2027</asp:ListItem>
                            <asp:ListItem>April 2027</asp:ListItem>
                            <asp:ListItem>August 2027</asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div class="form-group">
                        <label>Programme <span style="color:red">*</span></label>
                        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-control"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_SelectedIndexChanged" />
                    </div>
                </div>

                <div class="grid-2">
                    <div class="form-group">
                        <label>Courses <span style="color:red">*</span></label>
                        <div class="multi-dropdown" id="courseMultiDropdown">
                            <button type="button" class="multi-dropdown-toggle" onclick="toggleCourseDropdown(event)">
                                <span id="courseDropdownText">-- Select Course(s) --</span>
                            </button>
                            <div class="multi-dropdown-menu" onclick="keepCourseDropdownOpen(event)">
                                <div class="multi-dropdown-tools">
                                    <button type="button" onclick="selectAllCourses(event)">Select All</button>
                                    <button type="button" onclick="clearAllCourses(event)">Clear</button>
                                </div>
                                <asp:CheckBoxList ID="cblCourses" runat="server" CssClass="course-check-list" RepeatLayout="Flow" RepeatDirection="Vertical" />
                            </div>
                        </div>
                        <asp:Label ID="lblCourseHint" runat="server" CssClass="field-hint" Text="Open the dropdown and tick one or more courses for the selected session." />
                    </div>

                    <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-control" Style="display:none;">
                        <asp:ListItem Value="1" Selected="True">Semester 1</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="grid-2">
                    <div class="form-group">
                        <label>Status <span style="color:red">*</span></label>
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Value="Open">Open</asp:ListItem>
                            <asp:ListItem Value="Closed">Closed</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div style="margin-top:25px; display:flex; gap:12px; flex-wrap:wrap;">
                    <asp:Button ID="btnSave" runat="server" Text="Save Selected Courses" CssClass="btn btn-primary" OnClick="btnSave_Click" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear Form" CssClass="btn btn-outline" OnClick="btnClear_Click" CausesValidation="false" />
                    <asp:Button ID="btnBack" runat="server" Text="Back to Dashboard" CssClass="btn btn-outline" OnClick="btnBack_Click" CausesValidation="false" />
                </div>
            </div>
        </div>

        <div class="card" style="margin-bottom:30px;">
            <div class="card-header"><span class="card-title"><i class="fa-solid fa-magnifying-glass"></i> Search / Filter Offerings</span></div>
            <div class="card-body">
                <div class="grid-2">
                    <div class="form-group">
                        <label>Search Course</label>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search course code or course name" />
                    </div>
                    <div class="form-group">
                        <label>Filter Status</label>
                        <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Value="">All Status</asp:ListItem>
                            <asp:ListItem Value="Open">Open</asp:ListItem>
                            <asp:ListItem Value="Closed">Closed</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div style="display:flex; gap:12px; flex-wrap:wrap;">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-outline" OnClick="btnReset_Click" CausesValidation="false" />
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header"><span class="card-title">All Course Offerings</span></div>
            <div class="card-body">
                <div class="table-wrapper">
                    <asp:GridView ID="gvOfferings" runat="server" CssClass="data-table"
                        AutoGenerateColumns="false"
                        OnRowCommand="gvOfferings_RowCommand"
                        AllowPaging="true" PageSize="10" OnPageIndexChanging="gvOfferings_PageIndexChanging"
                        EmptyDataText="No course offerings found.">
                        <Columns>
                            <asp:BoundField DataField="Session" HeaderText="Session" />
                            <asp:BoundField DataField="ProgrammeCode" HeaderText="Programme" />
                            <asp:TemplateField HeaderText="Courses">
                                <ItemTemplate>
                                    <div class="courses-summary">
                                        <span class="course-count-pill"><%# Eval("CourseCount") %> course(s)</span><br />
                                        <%# Eval("Courses") %>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <span class='status-badge <%# GetStatusCss(Eval("Status")) %>'><%# Eval("Status") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <div class="action-buttons">
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditOffering" CommandArgument='<%# Eval("GroupKey") %>' CssClass="btn btn-sm btn-outline"><i class="fa-solid fa-pen-to-square"></i> Edit</asp:LinkButton>
                                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteOffering" CommandArgument='<%# Eval("GroupKey") %>' CssClass="btn btn-sm btn-outline"><i class="fa-solid fa-trash"></i> Delete</asp:LinkButton>
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
            <div class="cm-footer">
                <button type="button" class="cm-btn cm-btn-cancel" id="cmBtnCancel" style="display:none;" onclick="closeCustomModal()">Cancel</button>
                <button type="button" class="cm-btn cm-btn-delete" id="cmBtnDelete" style="display:none;">Yes, Delete</button>
                <button type="button" class="cm-btn cm-btn-ok" id="cmBtnOk" style="display:none;" onclick="closeCustomModal()">OK</button>
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hfDeleteTarget" runat="server" />
    <asp:Button ID="btnDeleteConfirmed" runat="server" style="display:none;" OnClick="btnDeleteConfirmed_Click" CausesValidation="false" />

    <script>
        var SVG_TICK = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
        var SVG_CROSS = '<svg viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>';
        var SVG_WARN = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
        var SVG_TRASH = '<svg viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>';

        function toggleCourseDropdown(event) {
            if (event) event.stopPropagation();
            var dropdown = document.getElementById('courseMultiDropdown');
            if (dropdown) dropdown.classList.toggle('open');
        }

        function keepCourseDropdownOpen(event) {
            if (event) event.stopPropagation();
        }

        function getCourseCheckboxes() {
            var container = document.getElementById('<%= cblCourses.ClientID %>');
            if (!container) return [];
            return Array.prototype.slice.call(container.querySelectorAll('input[type="checkbox"]'));
        }

        function updateCourseDropdownText() {
            var text = document.getElementById('courseDropdownText');
            var boxes = getCourseCheckboxes();
            if (!text) return;

            var checked = boxes.filter(function (box) { return box.checked && !box.disabled; });
            if (checked.length === 0) {
                text.innerHTML = '-- Select Course(s) --';
            } else if (checked.length === 1) {
                var label = document.querySelector('label[for="' + checked[0].id + '"]');
                text.innerHTML = label ? label.innerText : '1 course selected';
            } else {
                text.innerHTML = checked.length + ' courses selected';
            }
        }

        function selectAllCourses(event) {
            if (event) event.stopPropagation();
            getCourseCheckboxes().forEach(function (box) {
                if (!box.disabled && box.value !== '') box.checked = true;
            });
            updateCourseDropdownText();
        }

        function clearAllCourses(event) {
            if (event) event.stopPropagation();
            getCourseCheckboxes().forEach(function (box) { box.checked = false; });
            updateCourseDropdownText();
        }

        document.addEventListener('click', function (event) {
            var dropdown = document.getElementById('courseMultiDropdown');
            if (dropdown && !dropdown.contains(event.target)) dropdown.classList.remove('open');
        });

        document.addEventListener('change', function (event) {
            var container = document.getElementById('<%= cblCourses.ClientID %>');
            if (container && container.contains(event.target)) updateCourseDropdownText();
        });

        window.addEventListener('load', updateCourseDropdownText);

        function showMessageModal(title, message, isConfirmDelete, offeringId) {
            var titleEl = document.getElementById('cmTitle');
            var body = document.getElementById('cmBody');
            var icon = document.getElementById('cmIcon');
            var btnOk = document.getElementById('cmBtnOk');
            var btnCancel = document.getElementById('cmBtnCancel');
            var btnDelete = document.getElementById('cmBtnDelete');

            icon.innerHTML = title.indexOf('❌') !== -1 ? SVG_CROSS : title.indexOf('⚠') !== -1 ? SVG_WARN : isConfirmDelete ? SVG_TRASH : SVG_TICK;
            titleEl.innerHTML = isConfirmDelete ? 'Confirm Delete' : title.replace('✅ ', '').replace('❌ ', '').replace('⚠ ', '');
            body.innerHTML = message;

            btnOk.style.display = isConfirmDelete ? 'none' : 'inline-block';
            btnCancel.style.display = isConfirmDelete ? 'inline-block' : 'none';
            btnDelete.style.display = isConfirmDelete ? 'inline-block' : 'none';

            if (isConfirmDelete) {
                btnDelete.onclick = function () {
                    document.getElementById('<%= hfDeleteTarget.ClientID %>').value = offeringId;
                    closeCustomModal();
                    document.getElementById('<%= btnDeleteConfirmed.ClientID %>').click();
                };
            }
            document.getElementById('customModalOverlay').classList.add('active');
        }
        function closeCustomModal() { document.getElementById('customModalOverlay').classList.remove('active'); }
    </script>
</form>
</body>
</html>
