ç<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="Contacts.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.Student.Contacts" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Contacts</title>

    <link rel="stylesheet" href="../Styles/SIMS.css" />

    <style>
        body {
            background: #f5f6fa;
            font-family: Arial;
        }

        .container {
            max-width: 1000px;
            margin: 40px auto;
        }

        .page-title {
            font-size: 32px;
            font-weight: bold;
            margin-bottom: 25px;
        }

        .contact-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px,1fr));
            gap: 20px;
        }

        .contact-card {
            background: white;
            border-radius: 14px;
            padding: 22px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }

        .contact-name {
            font-size: 22px;
            font-weight: bold;
            color: #ff8800;
        }

        .contact-role {
            margin-top: 5px;
            color: gray;
            font-size: 14px;
        }

        .contact-info {
            margin-top: 16px;
            line-height: 1.8;
            color: #444;
        }

        .empty {
            background: white;
            padding: 30px;
            border-radius: 12px;
            text-align: center;
            color: gray;
        }
    </style>

</head>

<body>

<form id="form1" runat="server">

<div class="container">

    <div class="page-title">
        Contacts
    </div>

    <div class="contact-grid">

        <asp:Repeater ID="rptContacts" runat="server">

            <ItemTemplate>

                <div class="contact-card">

                    <div class="contact-name">
                        <%# Eval("Name") %>
                    </div>

                    <div class="contact-role">
                        <%# Eval("Role") %>
                    </div>

                    <div class="contact-info">

                        📧 <%# Eval("Email") %>

                        <br />

                        📞 <%# Eval("Phone") %>

                    </div>

                </div>

            </ItemTemplate>

        </asp:Repeater>

    </div>

    <asp:Label ID="lblEmpty"
        runat="server"
        CssClass="empty"
        Text="No contacts found."
        Visible="false" />

</div>

</form>

</body>
</html>