﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SystemSetup.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.SystemSetup" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SIMS Initial Setup</title>

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="crossorigin" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />

    <style>
        :root {
            --brand: #f97316;
            --brand-dark: #ea580c;
            --brand-soft: #fff7ed;
            --ink: #111827;
            --muted: #6b7280;
            --line: #e5e7eb;
            --card: #ffffff;
            --bg: #f8fafc;
            --success: #16a34a;
            --danger: #dc2626;
            --radius-lg: 28px;
            --radius-md: 18px;
            --shadow: 0 20px 50px rgba(15, 23, 42, .12);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: 'Nunito', Arial, sans-serif;
            color: var(--ink);
            background:
                radial-gradient(circle at top left, rgba(249,115,22,.18), transparent 35%),
                linear-gradient(135deg, #fff7ed 0%, #ffffff 42%, #f8fafc 100%);
        }

        .setup-shell {
            min-height: 100vh;
            display: grid;
            grid-template-columns: minmax(320px, 470px) minmax(520px, 720px);
            align-items: center;
            justify-content: center;
            gap: 54px;
            padding: 48px 64px;
        }

        .brand-panel {
            padding: 34px;
        }

        .logo-row {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 34px;
        }

        .logo-mark {
            width: 58px;
            height: 58px;
            border-radius: 18px;
            background: linear-gradient(135deg, var(--brand), var(--brand-dark));
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            box-shadow: 0 15px 30px rgba(249, 115, 22, .30);
        }

        .logo-title {
            font-size: 22px;
            font-weight: 900;
            letter-spacing: -.4px;
        }

        .logo-subtitle {
            font-size: 13px;
            color: var(--muted);
            font-weight: 700;
            margin-top: 2px;
        }

        .hero-label {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 9px 14px;
            border-radius: 999px;
            background: #fff;
            border: 1px solid rgba(249, 115, 22, .25);
            color: var(--brand-dark);
            font-weight: 900;
            font-size: 13px;
            margin-bottom: 18px;
        }

        h1 {
            margin: 0;
            font-size: 46px;
            line-height: 1.08;
            letter-spacing: -1.4px;
            font-weight: 900;
        }

        .hero-text {
            margin: 18px 0 28px;
            color: var(--muted);
            font-size: 17px;
            line-height: 1.65;
            max-width: 440px;
            font-weight: 600;
        }

        .setup-steps {
            display: grid;
            gap: 14px;
        }

        .step-card {
            display: flex;
            align-items: center;
            gap: 14px;
            background: rgba(255,255,255,.72);
            border: 1px solid rgba(229,231,235,.85);
            border-radius: 18px;
            padding: 15px 16px;
            backdrop-filter: blur(10px);
        }

        .step-number {
            width: 34px;
            height: 34px;
            border-radius: 12px;
            background: var(--brand-soft);
            color: var(--brand-dark);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
        }

        .step-card strong {
            display: block;
            font-size: 14px;
            font-weight: 900;
        }

        .step-card span {
            color: var(--muted);
            font-size: 13px;
            font-weight: 700;
        }

        .setup-card {
            background: rgba(255,255,255,.96);
            border: 1px solid rgba(229,231,235,.95);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .card-header {
            padding: 28px 34px;
            border-bottom: 1px solid var(--line);
            background: #fff;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 18px;
        }

        .card-header h2 {
            margin: 0;
            font-size: 28px;
            font-weight: 900;
            letter-spacing: -.6px;
        }

        .card-header p {
            margin: 7px 0 0;
            color: var(--muted);
            font-size: 14px;
            font-weight: 700;
        }

        .status-pill {
            white-space: nowrap;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border-radius: 999px;
            padding: 9px 13px;
            font-size: 12px;
            font-weight: 900;
            background: var(--brand-soft);
            color: var(--brand-dark);
        }

        .card-body {
            padding: 34px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 20px;
        }

        .form-group.full { grid-column: 1 / -1; }

        label {
            display: block;
            margin-bottom: 8px;
            color: #374151;
            font-size: 13px;
            font-weight: 900;
        }

        .form-control {
            width: 100%;
            height: 48px;
            border: 1px solid #dfe4ee;
            border-radius: 14px;
            padding: 0 15px;
            font-family: inherit;
            font-size: 15px;
            font-weight: 700;
            color: var(--ink);
            background: #fff;
            outline: none;
            transition: .18s ease;
        }

        .form-control:focus {
            border-color: var(--brand);
            box-shadow: 0 0 0 4px rgba(249,115,22,.14);
        }

        .password-note {
            margin-top: 8px;
            color: var(--muted);
            font-size: 12px;
            font-weight: 700;
        }

        .button-row {
            display: flex;
            gap: 14px;
            align-items: center;
            margin-top: 26px;
            flex-wrap: wrap;
        }

        .btn-primary, .btn-secondary {
            border: 0;
            height: 48px;
            border-radius: 999px;
            padding: 0 24px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            font-family: inherit;
            font-size: 14px;
            font-weight: 900;
            text-decoration: none;
            cursor: pointer;
            transition: .18s ease;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--brand), var(--brand-dark));
            color: #fff;
            box-shadow: 0 12px 22px rgba(249,115,22,.25);
        }

        .btn-primary:hover { transform: translateY(-1px); }

        .btn-secondary {
            background: #fff;
            color: #374151;
            border: 1px solid #dfe4ee;
        }

        .alert {
            margin-top: 22px;
            border-radius: 18px;
            padding: 16px 18px;
            font-weight: 800;
            line-height: 1.45;
        }

        .alert-success {
            background: #ecfdf5;
            border: 1px solid #bbf7d0;
            color: #166534;
        }

        .alert-error {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #991b1b;
        }

        .locked-card {
            background: #fff7ed;
            border: 1px solid rgba(249,115,22,.25);
            border-radius: 20px;
            padding: 22px;
            display: flex;
            gap: 16px;
            align-items: flex-start;
        }

        .locked-icon {
            width: 44px;
            height: 44px;
            border-radius: 15px;
            background: #fff;
            color: var(--brand-dark);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex: 0 0 auto;
        }

        .locked-card h3 {
            margin: 0 0 8px;
            font-size: 20px;
            font-weight: 900;
        }

        .locked-card p {
            margin: 0 0 16px;
            color: #7c2d12;
            font-weight: 700;
            line-height: 1.55;
        }

        .footer-note {
            padding: 20px 34px;
            border-top: 1px solid var(--line);
            background: #fafafa;
            color: var(--muted);
            font-size: 12px;
            font-weight: 700;
        }

        @media (max-width: 980px) {
            .setup-shell {
                grid-template-columns: 1fr;
                padding: 28px;
                gap: 24px;
            }

            .brand-panel { padding: 10px; }
            h1 { font-size: 36px; }
        }

        @media (max-width: 620px) {
            .setup-shell { padding: 18px; }
            .card-header, .card-body, .footer-note { padding-left: 22px; padding-right: 22px; }
            .form-grid { grid-template-columns: 1fr; }
            .card-header { flex-direction: column; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="setup-shell">
            <section class="brand-panel">
                <div class="logo-row">
                    <div class="logo-mark"><i class="fa-solid fa-graduation-cap"></i></div>
                    <div>
                        <div class="logo-title">ONTI SIMS</div>
                        <div class="logo-subtitle">Student Information Management System</div>
                    </div>
                </div>

                <div class="hero-label"><i class="fa-solid fa-shield-halved"></i> Secure System Setup</div>
                <h1>Create administrator accounts securely.</h1>
                <p class="hero-text">
                    Use this page to create the first administrator for a fresh database. If an administrator already exists, verification is required before creating another admin account.
                </p>

                <div class="setup-steps">
                    <div class="step-card">
                        <div class="step-number">1</div>
                        <div><strong>Run database script</strong><span>Create all SIMS tables first.</span></div>
                    </div>
                    <div class="step-card">
                        <div class="step-number">2</div>
                        <div><strong>Verify setup access</strong><span>First setup or existing admin verification.</span></div>
                    </div>
                    <div class="step-card">
                        <div class="step-number">3</div>
                        <div><strong>Create admin account</strong><span>Register the admin account securely.</span></div>
                    </div>
                </div>
            </section>

            <section class="setup-card">
                <div class="card-header">
                    <div>
                        <h2><asp:Label ID="lblModeTitle" runat="server" Text="Admin Setup" /></h2>
                        <p><asp:Label ID="lblModeSubtitle" runat="server" Text="Create the first or additional administrator account." /></p>
                    </div>
                    <span class="status-pill"><i class="fa-solid fa-lock"></i> Setup Protected</span>
                </div>

                <div class="card-body">
                    <asp:Panel ID="pnlVerifyAdmin" runat="server" Visible="false">
                        <div class="locked-card" style="background:#fff; border-color:#edf0f6; margin-bottom:22px;">
                            <div class="locked-icon"><i class="fa-solid fa-user-lock"></i></div>
                            <div>
                                <h3>Admin Verification Required</h3>
                                <p>
                                    An administrator account already exists. Please verify using an existing admin email and password before creating another administrator account.
                                </p>
                            </div>
                        </div>

                        <div class="form-grid">
                            <div class="form-group full">
                                <label for="txtVerifyEmail">Existing Admin Email</label>
                                <asp:TextBox ID="txtVerifyEmail" runat="server" TextMode="Email" CssClass="form-control" placeholder="existing.admin@onti.edu.my" />
                            </div>

                            <div class="form-group full">
                                <label for="txtVerifyPassword">Existing Admin Password</label>
                                <asp:TextBox ID="txtVerifyPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Enter existing admin password" />
                            </div>
                        </div>

                        <div class="button-row">
                            <asp:LinkButton ID="btnVerifyAdmin" runat="server" CssClass="btn-primary" OnClick="btnVerifyAdmin_Click">
                                <i class="fa-solid fa-shield-check"></i>
                                Verify Admin
                            </asp:LinkButton>
                            <a href="Login.aspx" class="btn-secondary">
                                <i class="fa-solid fa-arrow-right-to-bracket"></i>
                                Go to Login
                            </a>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlSetupForm" runat="server">
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="txtFirst">First Name</label>
                                <asp:TextBox ID="txtFirst" runat="server" CssClass="form-control" placeholder="e.g. Justin" />
                            </div>

                            <div class="form-group">
                                <label for="txtLast">Last Name</label>
                                <asp:TextBox ID="txtLast" runat="server" CssClass="form-control" placeholder="e.g. Lim" />
                            </div>

                            <div class="form-group full">
                                <label for="txtEmail">Admin Email</label>
                                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-control" placeholder="admin@onti.edu.my" />
                            </div>

                            <div class="form-group full">
                                <label for="txtPassword">Password</label>
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Minimum 8 characters" />
                                <div class="password-note">Use at least 8 characters. This password will be stored using your SIMS password hash.</div>
                            </div>
                        </div>

                        <div class="button-row">
                            <asp:LinkButton ID="btnSeed" runat="server" CssClass="btn-primary" OnClick="btnSeed_Click">
                                <i class="fa-solid fa-user-shield"></i>
                                Create Admin Account
                            </asp:LinkButton>
                            <a href="Login.aspx" class="btn-secondary">
                                <i class="fa-solid fa-arrow-right-to-bracket"></i>
                                Go to Login
                            </a>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlLocked" runat="server" Visible="false" CssClass="locked-card">
                        <div class="locked-icon"><i class="fa-solid fa-circle-check"></i></div>
                        <div>
                            <h3>Verification required</h3>
                            <p>
                                An administrator already exists. Please use the verification form on this page to create another admin account, or login through the normal Admin Portal.
                            </p>
                            <a href="Login.aspx" class="btn-primary">
                                <i class="fa-solid fa-arrow-right-to-bracket"></i>
                                Login to SIMS
                            </a>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="alert alert-success">
                        <asp:Label ID="lblSuccess" runat="server" />
                    </asp:Panel>

                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-error">
                        <asp:Label ID="lblError" runat="server" />
                    </asp:Panel>
                </div>

                <div class="footer-note">
                    For assignment deployment: use this page after restoring a fresh database. If an admin already exists, verify an existing admin first before creating another admin account.
                </div>
            </section>
        </div>
    </form>
</body>
</html>
