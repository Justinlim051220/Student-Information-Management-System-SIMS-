<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageLecturers.aspx.cs" 
         Inherits="Student_Information_Management_System__SIMS_.Admin.ManageLecturers" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Manage Lecturers - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-content">

            <h2><i class="fa-solid fa-chalkboard-user"></i> Manage Lecturers</h2>

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
                            <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-control">
                                <asp:ListItem Value="">-- Select Programme --</asp:ListItem>
                            </asp:DropDownList>
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
                            <asp:BoundField DataField="ProgrammeName" HeaderText="Programme" />
                            <asp:BoundField DataField="Specialization" HeaderText="Specialization" />
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="Edit" 
                                        CommandArgument='<%# Eval("LecturerId") %>' 
                                        CssClass="btn btn-sm btn-outline" style="margin-right:8px;">
                                        <i class="fa-solid fa-edit"></i> Edit
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="Delete" 
                                        CommandArgument='<%# Eval("LecturerId") %>' 
                                        CssClass="btn btn-sm btn-outline"
                                        OnClientClick="return confirm('Are you sure you want to delete this lecturer?');">
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