%@ Page Language="C#" AutoEventWireup="true" 
         CodeBehind="SeedAdmin.aspx.cs" 
         Inherits="Student_Information_Management_System__SIMS_.SeedAdmin" %>

<!DOCTYPE html>
<html>
<head>
    <title>Seed Admin — SIMS Setup</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            max-width: 500px; 
            margin: 60px auto; 
            padding: 20px; 
        }
        input, .form-control { 
            width: 100%; 
            padding: 8px; 
            margin: 6px 0 14px; 
            box-sizing: border-box; 
            border: 1px solid #ccc; 
            border-radius: 4px; 
        }
        button, .btn {
            background: #e8500a; 
            color: white; 
            padding: 10px 24px; 
            border: none; 
            border-radius: 4px; 
            cursor: pointer; 
            font-size: 15px; 
        }
        .success { 
            background: #d4edda; 
            color: #155724; 
            padding: 12px; 
            border-radius: 4px; 
            margin-top: 16px; 
        }
        .error { 
            background: #f8d7da; 
            color: #721c24; 
            padding: 12px; 
            border-radius: 4px; 
            margin-top: 16px; 
        }
    </style>
</head>
<body>

    <form id="form1" runat="server">

        <h2>🔧 SIMS — Create First Admin</h2>
        <p style="color:#888">Run this page once, then delete it.</p>

        <label>First Name</label>
        <asp:TextBox ID="txtFirst" runat="server" CssClass="form-control" /><br/>

        <label>Last Name</label>
        <asp:TextBox ID="txtLast" runat="server" CssClass="form-control" /><br/>

        <label>Email</label>
        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-control" /><br/>

        <label>Password</label>
        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" /><br/>

        <asp:Button ID="btnSeed" runat="server" Text="Create Admin Account" 
                    OnClick="btnSeed_Click" CssClass="btn" />

        <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="success">
            <asp:Label ID="lblSuccess" runat="server" />
        </asp:Panel>

        <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="error">
            <asp:Label ID="lblError" runat="server" />
        </asp:Panel>

    </form>

</body>
</html>