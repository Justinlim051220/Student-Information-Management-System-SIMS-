<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageProgrammes.aspx.cs" 
         Inherits="Student_Information_Management_System__SIMS_.Admin.ManageProgrammes" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Manage Programmes - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />

    <style>
        /* Custom Modal Overlay */
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
            color: #c8881a;
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-content">

            <h2 style="margin-bottom:25px;"><i class="fa-solid fa-layer-group"></i> Manage Programmes</h2>


            <!-- Add/Edit Form - Full Width -->
            <div class="card" style="margin-bottom: 30px;">
                <div class="card-header">
                    <asp:Label ID="lblFormTitle" runat="server" Text="Add New Programme" Font-Bold="true" />
                </div>
                <div class="card-body">

                    <asp:HiddenField ID="hfProgrammeId" runat="server" />

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Programme Name <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtProgrammeName" runat="server" CssClass="form-control" />
                        </div>
                        <div class="form-group">
                            <label>Programme Code <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtProgrammeCode" runat="server" CssClass="form-control" 
                                         placeholder="e.g. BCS, BBA" />
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Duration (Years) <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtDuration" runat="server" TextMode="Number" CssClass="form-control" />
                        </div>
                        <div class="form-group">
                            <label>Head of Programme</label>
                            <asp:Label ID="lblCurrentHoP" runat="server" CssClass="form-control" BackColor="#f8f9fa" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control" />
                    </div>

                    <div style="margin-top: 25px; display: flex; gap: 12px;">
                        <asp:Button ID="btnSave" runat="server" Text="Save Programme" 
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

            <!-- Search / Filter Programmes -->
            <div class="card" style="margin-bottom: 30px;">
                <div class="card-header">
                    <span class="card-title"><i class="fa-solid fa-magnifying-glass"></i> Search / Filter Programmes</span>
                </div>
                <div class="card-body">
                    <div class="grid-2">
                        <div class="form-group">
                            <label>Search Programme Code / Name / Description</label>
                            <asp:TextBox ID="txtSearchProgramme" runat="server" CssClass="form-control"
                                         placeholder="e.g. DCS, Computer Science, Diploma" />
                        </div>

                        <div class="form-group">
                            <label>Duration</label>
                            <asp:DropDownList ID="ddlFilterDuration" runat="server" CssClass="form-control">
                                <asp:ListItem Value="">All Durations</asp:ListItem>
                                <asp:ListItem Value="1">1 Year</asp:ListItem>
                                <asp:ListItem Value="2">2 Years</asp:ListItem>
                                <asp:ListItem Value="3">3 Years</asp:ListItem>
                                <asp:ListItem Value="4">4 Years</asp:ListItem>
                                <asp:ListItem Value="5">5 Years</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div style="display:flex; gap:12px; flex-wrap:wrap;">
                        <asp:Button ID="btnSearchProgramme" runat="server" Text="Search"
                                    CssClass="btn btn-primary" OnClick="btnSearchProgramme_Click"
                                    CausesValidation="false" />
                        <asp:Button ID="btnClearProgrammeSearch" runat="server" Text="Reset"
                                    CssClass="btn btn-outline" OnClick="btnClearProgrammeSearch_Click"
                                    CausesValidation="false" />
                    </div>
                </div>
            </div>

            <!-- Programmes List -->
            <div class="card">
                <div class="card-header">
                    <span class="card-title">All Programmes</span>
                </div>
                <div class="card-body">
                    <asp:GridView ID="gvProgrammes" runat="server" CssClass="data-table" 
                        AutoGenerateColumns="false" DataKeyNames="ProgrammeId"
                        OnRowCommand="gvProgrammes_RowCommand"
                        AllowPaging="true" PageSize="10" OnPageIndexChanging="gvProgrammes_PageIndexChanging">
                        
                        <Columns>
                            <asp:BoundField DataField="ProgrammeCode" HeaderText="Code" />
                            <asp:BoundField DataField="ProgrammeName" HeaderText="Programme Name" />
                            <asp:BoundField DataField="Duration" HeaderText="Duration (Years)" />
                            <asp:BoundField DataField="Description" HeaderText="Description" />
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="EditProgramme" 
                                        CommandArgument='<%# Eval("ProgrammeId") %>' 
                                        CssClass="btn btn-sm btn-outline" style="margin-right:8px;">
                                        <i class="fa-solid fa-edit"></i> Edit
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="DeleteProgramme" 
                                        CommandArgument='<%# Eval("ProgrammeId") %>' 
                                        CssClass="btn btn-sm btn-outline">
                                        <i class="fa-solid fa-trash"></i> Delete
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
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

            function showMessageModal(type, title, message, isConfirmDelete, targetId) {
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
                    iconEl.innerHTML = SVG_TRASH;
                } else if (type === 'success') {
                    iconWrap.classList.add('icon-success');
                    iconEl.innerHTML = SVG_TICK;
                } else if (type === 'error') {
                    iconWrap.classList.add('icon-error');
                    iconEl.innerHTML = SVG_CROSS;
                } else if (type === 'warning') {
                    iconWrap.classList.add('icon-warning');
                    iconEl.innerHTML = SVG_WARN;
                } else if (type === 'delete') {
                    iconWrap.classList.add('icon-delete');
                    iconEl.innerHTML = SVG_TRASH;
                } else {
                    iconEl.innerHTML = '';
                }

                titleEl.innerHTML = title;
                body.innerHTML = message;

                btnOk.style.display = 'none';
                btnCancel.style.display = 'none';
                btnDelete.style.display = 'none';

                if (isConfirmDelete) {
                    btnCancel.style.display = 'inline-block';
                    btnDelete.style.display = 'inline-block';
                    btnDelete.onclick = function () {
                        document.getElementById('<%= hfDeleteTarget.ClientID %>').value = targetId;
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