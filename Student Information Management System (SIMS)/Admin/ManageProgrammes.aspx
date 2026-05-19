<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageProgrammes.aspx.cs" 
         Inherits="Student_Information_Management_System__SIMS_.Admin.ManageProgrammes" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Manage Programmes - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-content">

            <h2><i class="fa-solid fa-layer-group"></i> Manage Programmes</h2>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false"></asp:Label>

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
                        
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" 
                                    CssClass="btn btn-outline" OnClick="btnCancel_Click" 
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
                                    <asp:LinkButton runat="server" CommandName="Edit" 
                                        CommandArgument='<%# Eval("ProgrammeId") %>' 
                                        CssClass="btn btn-sm btn-outline" style="margin-right:8px;">
                                        <i class="fa-solid fa-edit"></i> Edit
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="Delete" 
                                        CommandArgument='<%# Eval("ProgrammeId") %>' 
                                        CssClass="btn btn-sm btn-outline"
                                        OnClientClick="return confirm('Are you sure you want to delete this programme?');">
                                        <i class="fa-solid fa-trash"></i> Delete
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

        </div>
    </form>
</body>
</html>