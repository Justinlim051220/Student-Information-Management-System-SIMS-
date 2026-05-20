<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageStudents.aspx.cs" 
         Inherits="Student_Information_Management_System__SIMS_.Admin.ManageStudents" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Add New Student - SIMS</title>
    <link href="../Styles/SIMS.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">

        <div class="page-content">
            <h2><i class="fa-solid fa-user-plus"></i> Add New Student</h2>
            <p>Student ID will be auto-generated</p>

            <div class="card" style="max-width: 700px; margin: 0 auto;">
                <div class="card-body">

                    <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false"></asp:Label>

                    <div class="form-group">
                        <label>Student ID (Auto)</label>
                        <asp:TextBox ID="txtStudentId" runat="server" CssClass="form-control" ReadOnly="true" />
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>First Name *</label>
                            <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" required />
                        </div>
                        <div class="form-group">
                            <label>Last Name *</label>
                            <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" required />
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Email *</label>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-control" required />
                    </div>

                    <div class="form-group">
                        <label>Password *</label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" required />
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Date of Birth</label>
                            <asp:TextBox ID="txtDob" runat="server" TextMode="Date" CssClass="form-control" />
                        </div>
                        <div class="form-group">
                            <label>Gender</label>
                            <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-control">
                                <asp:ListItem Value="">Select Gender</asp:ListItem>
                                <asp:ListItem>Male</asp:ListItem>
                                <asp:ListItem>Female</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Programme *</label>
                        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-control" required />
                    </div>

                    <div class="form-group">
                        <label>Phone</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
                    </div>

                    <div class="form-group">
                        <label>Address</label>
                        <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" />
                    </div>

                    <hr />
                    <div style="margin-top: 25px; display: flex; gap: 12px;">
                        <asp:Button ID="btnAddStudent" runat="server" Text="Add Student" 
                                    CssClass="btn btn-primary" OnClick="btnAddStudent_Click" />
    
                        <asp:Button ID="btnCancel" runat="server" Text="Back" 
                            CssClass="btn btn-outline" 
                            OnClick="btnCancel_Click" 
                            CausesValidation="false"
                            UseSubmitBehavior="false" />
                    </div>

                </div>
            </div>
        </div>

    </form>
</body>
</html>