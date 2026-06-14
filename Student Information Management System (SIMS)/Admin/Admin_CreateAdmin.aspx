<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="Admin_CreateAdmin.aspx.cs"
    Inherits="Student_Information_Management_System__SIMS_.Admin.Admin_CreateAdmin" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Create Admin Account - SIMS</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet" />

    <style>
        :root {
            --primary: #f59e0b;
            --primary-dark: #ea580c;
            --primary-soft: #fff7ed;
            --navy: #111827;
            --text: #1f2937;
            --muted: #7c8497;
            --line: #e8ecf3;
            --bg: #f5f7fb;
            --white: #ffffff;
            --success: #16a34a;
            --danger: #dc2626;
            --shadow: 0 18px 45px rgba(15, 23, 42, .08);
            --radius: 22px;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: 'Nunito', Arial, sans-serif;
            background: var(--bg);
            color: var(--text);
        }

        .page {
            min-height: 100vh;
            padding: 34px;
        }

        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
            margin-bottom: 28px;
        }

        .title-wrap h1 {
            margin: 0;
            font-size: 32px;
            font-weight: 900;
            color: var(--navy);
            letter-spacing: -.6px;
        }

        .title-wrap p {
            margin: 8px 0 0;
            color: var(--muted);
            font-size: 15px;
            font-weight: 700;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 9px;
            min-height: 46px;
            padding: 0 20px;
            border-radius: 999px;
            border: 1px solid var(--line);
            background: var(--white);
            color: var(--navy);
            font-weight: 900;
            text-decoration: none;
            box-shadow: 0 8px 20px rgba(15,23,42,.05);
            transition: .2s;
        }

        .back-btn:hover {
            transform: translateY(-2px);
            border-color: #fed7aa;
            color: var(--primary-dark);
        }

        .layout {
            display: grid;
            grid-template-columns: minmax(0, 1.05fr) minmax(360px, .95fr);
            gap: 24px;
            align-items: stretch;
        }

        .info-card,
        .form-card {
            background: var(--white);
            border: 1px solid var(--line);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
        }

        .info-card {
            padding: 30px;
            overflow: hidden;
            position: relative;
        }

        .info-card::after {
            content: "";
            position: absolute;
            width: 260px;
            height: 260px;
            right: -90px;
            bottom: -110px;
            border-radius: 50%;
            background: linear-gradient(135deg, rgba(245,158,11,.18), rgba(234,88,12,.06));
        }

        .hero-icon {
            width: 78px;
            height: 78px;
            border-radius: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-dark);
            background: var(--primary-soft);
            font-size: 32px;
            margin-bottom: 22px;
            box-shadow: inset 0 0 0 1px #fed7aa;
        }

        .info-card h2 {
            margin: 0 0 10px;
            font-size: 26px;
            font-weight: 900;
            color: var(--navy);
        }

        .info-card .lead {
            color: var(--muted);
            line-height: 1.7;
            font-weight: 700;
            max-width: 720px;
            margin: 0 0 24px;
        }

        .check-list {
            display: grid;
            gap: 14px;
            margin-top: 28px;
            position: relative;
            z-index: 1;
        }

        .check-item {
            display: flex;
            gap: 13px;
            align-items: flex-start;
            padding: 15px 16px;
            border: 1px solid #f0f2f7;
            border-radius: 16px;
            background: #fff;
        }

        .check-item i {
            color: var(--success);
            margin-top: 2px;
        }

        .check-item strong {
            display: block;
            color: var(--navy);
            font-weight: 900;
            margin-bottom: 3px;
        }

        .check-item span {
            color: var(--muted);
            font-weight: 700;
            font-size: 14px;
        }

        .form-card {
            padding: 0;
            overflow: hidden;
        }

        .form-head {
            padding: 24px 28px;
            background: linear-gradient(135deg, #fff7ed, #ffffff);
            border-bottom: 1px solid var(--line);
        }

        .form-head h2 {
            margin: 0;
            font-size: 22px;
            font-weight: 900;
            color: var(--navy);
        }

        .form-head p {
            margin: 7px 0 0;
            color: var(--muted);
            font-size: 14px;
            font-weight: 700;
        }

        .form-body {
            padding: 28px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }

        .field {
            margin-bottom: 18px;
        }

        .field.full {
            grid-column: 1 / -1;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: var(--navy);
            font-size: 14px;
            font-weight: 900;
        }

        .input {
            width: 100%;
            height: 48px;
            border: 1px solid #dfe5ef;
            border-radius: 14px;
            padding: 0 15px;
            font-family: inherit;
            font-size: 15px;
            font-weight: 700;
            color: var(--text);
            outline: none;
            transition: .18s;
            background: #fff;
        }

        .input:focus {
            border-color: #f59e0b;
            box-shadow: 0 0 0 4px rgba(245, 158, 11, .12);
        }

        .hint {
            margin-top: 7px;
            color: var(--muted);
            font-size: 12px;
            font-weight: 700;
        }

        .btn-primary {
            width: 100%;
            height: 52px;
            border: none;
            border-radius: 16px;
            cursor: pointer;
            color: #fff;
            font-family: inherit;
            font-size: 16px;
            font-weight: 900;
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            box-shadow: 0 14px 28px rgba(234, 88, 12, .24);
            transition: .2s;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 18px 34px rgba(234, 88, 12, .30);
        }

        .btn-primary:disabled {
            opacity: .7;
            cursor: not-allowed;
            transform: none;
        }

        .alert {
            margin-bottom: 18px;
            padding: 14px 16px;
            border-radius: 15px;
            font-weight: 800;
            line-height: 1.5;
        }

        .alert-success {
            color: #166534;
            background: #ecfdf3;
            border: 1px solid #bbf7d0;
        }

        .alert-error {
            color: #991b1b;
            background: #fef2f2;
            border: 1px solid #fecaca;
        }

        .security-note {
            margin-top: 18px;
            padding: 15px;
            border-radius: 15px;
            background: #f8fafc;
            border: 1px dashed #d7deea;
            color: #64748b;
            font-size: 13px;
            font-weight: 800;
            line-height: 1.55;
        }

        @media (max-width: 960px) {
            .layout {
                grid-template-columns: 1fr;
            }

            .page {
                padding: 24px;
            }
        }

        @media (max-width: 560px) {
            .topbar {
                flex-direction: column;
                align-items: flex-start;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .title-wrap h1 {
                font-size: 27px;
            }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <div class="page">
        <div class="topbar">
            <div class="title-wrap">
                <h1>Create Admin Account</h1>
                <p>Create another administrator account for SIMS management access.</p>
            </div>

            <a href="Dashboard.aspx" class="back-btn">
                <i class="fa-solid fa-arrow-left"></i>
                Back to Dashboard
            </a>
        </div>

        <div class="layout">
            <section class="info-card">
                <div class="hero-icon">
                    <i class="fa-solid fa-user-shield"></i>
                </div>

                <h2>Administrator Access Control</h2>
                <p class="lead">
                    Use this page to create a new Admin / Head of Programme account. The account will be saved into
                    the Users table with Admin role access and linked to the HoP details record.
                </p>

                <div class="check-list">
                    <div class="check-item">
                        <i class="fa-solid fa-circle-check"></i>
                        <div>
                            <strong>Admin Role</strong>
                            <span>The new account is created with Role 1 access.</span>
                        </div>
                    </div>

                    <div class="check-item">
                        <i class="fa-solid fa-lock"></i>
                        <div>
                            <strong>Password Security</strong>
                            <span>Password is hashed using your existing SIMS PasswordHelper.</span>
                        </div>
                    </div>

                    <div class="check-item">
                        <i class="fa-solid fa-id-card"></i>
                        <div>
                            <strong>HoP Profile Record</strong>
                            <span>A matching HoPDetails record is created automatically.</span>
                        </div>
                    </div>
                </div>
            </section>

            <section class="form-card">
                <div class="form-head">
                    <h2>New Admin Details</h2>
                    <p>Fill in the required information below.</p>
                </div>

                <div class="form-body">
                    <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="alert alert-success">
                        <asp:Label ID="lblSuccess" runat="server" />
                    </asp:Panel>

                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-error">
                        <asp:Label ID="lblError" runat="server" />
                    </asp:Panel>

                    <div class="form-grid">
                        <div class="field">
                            <label for="txtFirst">First Name</label>
                            <asp:TextBox ID="txtFirst" runat="server" CssClass="input" />
                        </div>

                        <div class="field">
                            <label for="txtLast">Last Name</label>
                            <asp:TextBox ID="txtLast" runat="server" CssClass="input" />
                        </div>

                        <div class="field full">
                            <label for="txtEmail">Email Address</label>
                            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="input" />
                        </div>

                        <div class="field full">
                            <label for="txtPassword">Temporary Password</label>
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="input" />
                            <div class="hint">Password must be at least 8 characters.</div>
                        </div>
                    </div>

                    <asp:Button ID="btnSeed" runat="server"
                        Text="Create Admin Account"
                        OnClick="btnSeed_Click"
                        CssClass="btn-primary" />

                    <div class="security-note">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                        Only existing admins should access this page. After creating the account, the new admin can log in using the email and temporary password.
                    </div>
                </div>
            </section>
        </div>
    </div>
</form>
</body>
</html>
