﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageLecturers.aspx.cs" 
         Inherits="Student_Information_Management_System__SIMS_.Admin.ManageLecturers" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Manage Lecturers - SIMS</title>
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
    
        .checkbox-list label { margin-left: 8px; margin-right: 18px; }
        .checkbox-list input { margin-bottom: 8px; }
</style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-content">

            <h2 style="margin-bottom:25px;"><i class="fa-solid fa-chalkboard-user"></i> Manage Lecturers</h2>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false"></asp:Label>

            <!-- Add/Edit Form -->
            <div class="card" style="margin-bottom: 30px;">
                <div class="card-header">
                    <asp:Label ID="lblFormTitle" runat="server" Text="Add New Lecturer" Font-Bold="true" />
                </div>
                <div class="card-body">

                    <asp:HiddenField ID="hfLecturerId" runat="server" />
                    <asp:HiddenField ID="hfUserId" runat="server" />

                    <div class="grid-2">
                        <div class="form-group">
                            <label>First Name <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" />
                        </div>
                        <div class="form-group">
                            <label>Last Name <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" />
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Lecturer ID <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtLecturerId" runat="server" CssClass="form-control" 
                                         ReadOnly="true" BackColor="#f8f9fa" />
                        </div>
                        <div class="form-group">
                            <label>Email <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-control" />
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Phone Number</label>
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
                        </div>
                        <div class="form-group">
                            <label>Programme <span style="color:red">*</span></label>
                            <asp:CheckBoxList ID="cblProgrammes" runat="server" CssClass="checkbox-list" RepeatDirection="Vertical" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Specialization / Expertise</label>
                        <asp:TextBox ID="txtSpecialization" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" />
                    </div>

                    <div style="margin-top: 25px; display: flex; gap: 12px;">
                        <asp:Button ID="btnSave" runat="server" Text="Save Lecturer" 
                                    CssClass="btn btn-primary" OnClick="btnSave_Click" />
                        
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" 
                                    CssClass="btn btn-outline" OnClick="btnCancel_Click" 
                                    CausesValidation="false" />
                    </div>
                </div>
            </div>

            <!-- Lecturers List -->
            <div class="card">
                <div class="card-header">
                    <span class="card-title">All Lecturers</span>
                </div>
                <div class="card-body">
                    <asp:GridView ID="gvLecturers" runat="server" CssClass="data-table" 
                        AutoGenerateColumns="false" DataKeyNames="LecturerId"
                        OnRowCommand="gvLecturers_RowCommand"
                        AllowPaging="true" PageSize="10" OnPageIndexChanging="gvLecturers_PageIndexChanging">
                        
                        <Columns>
                            <asp:BoundField DataField="LecturerId" HeaderText="Lecturer ID" />
                            <asp:BoundField DataField="FullName" HeaderText="Name" />
                            <asp:BoundField DataField="Email" HeaderText="Email" />
                            <asp:BoundField DataField="Phone" HeaderText="Phone" />
                            <asp:BoundField DataField="ProgrammeNames" HeaderText="Programmes" />
                            <asp:BoundField DataField="Specialization" HeaderText="Specialization" />
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="EditLecturer" 
                                        CommandArgument='<%# Eval("LecturerId") %>' 
                                        CssClass="btn btn-sm btn-outline" style="margin-right:8px;">
                                        <i class="fa-solid fa-edit"></i> Edit
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="DeleteLecturer" 
                                        CommandArgument='<%# Eval("LecturerId") %>' 
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
                <!-- Icon circle (shown above title) -->
                <div class="cm-icon-wrap" id="cmIconWrap">
                    <span id="cmIcon"></span>
                </div>
                <!-- Title -->
                <div class="cm-title" id="cmTitle">Message</div>
                <hr class="cm-divider" />
                <div class="cm-body" id="cmBody"></div>
                <div class="cm-footer">
                    <button type="button" class="cm-btn cm-btn-cancel" id="cmBtnCancel" style="display:none;" onclick="closeCustomModal()">Cancel</button>
                    <button type="button" class="cm-btn cm-btn-delete" id="cmBtnDelete" style="display:none;">Yes, Delete</button>
                    <button type="button" class="cm-btn cm-btn-ok"     id="cmBtnOk"     style="display:none;" onclick="closeCustomModal()">OK</button>
                </div>
            </div>
        </div>

        <asp:HiddenField ID="hfDeleteTarget" runat="server" />
        <asp:Button ID="btnDeleteConfirmed" runat="server" style="display:none;"
            OnClick="btnDeleteConfirmed_Click" CausesValidation="false" />

        <script>
            // Inline SVG icons
            var SVG_TICK    = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
            var SVG_CROSS   = '<svg viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>';
            var SVG_WARN    = '<svg viewBox="0 0 24 24" fill="none" stroke="#e8a838" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
            var SVG_TRASH   = '<svg viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>';

            function showMessageModal(title, message, isConfirmDelete, lecturerId) {
                var iconWrap  = document.getElementById('cmIconWrap');
                var iconEl    = document.getElementById('cmIcon');
                var titleEl   = document.getElementById('cmTitle');
                var body      = document.getElementById('cmBody');
                var btnOk     = document.getElementById('cmBtnOk');
                var btnCancel = document.getElementById('cmBtnCancel');
                var btnDelete = document.getElementById('cmBtnDelete');

                // Reset icon classes
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
                } else {
                    iconEl.innerHTML  = 'ℹ️';
                    titleEl.innerHTML = title;
                }

                body.innerHTML = message;

                // Reset buttons
                btnOk.style.display     = 'none';
                btnCancel.style.display = 'none';
                btnDelete.style.display = 'none';

                if (isConfirmDelete) {
                    btnCancel.style.display = 'inline-block';
                    btnDelete.style.display = 'inline-block';
                    btnDelete.onclick = function () {
                        document.getElementById('<%= hfDeleteTarget.ClientID %>').value = lecturerId;
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

            // Close when clicking the dark backdrop
            document.getElementById('customModalOverlay').addEventListener('click', function (e) {
                if (e.target === this) closeCustomModal();
            });
        </script>
    </form>
</body>
</html>