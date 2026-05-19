<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" 
         Inherits="Student_Information_Management_System__SIMS_.ForgotPassword" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SIMS – Forgot Password | ONTI International University</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
  <link rel="stylesheet" href="Styles/SIMS.css" />

  <style>
    /* Step indicator */
    .steps {
      display        : flex;
      justify-content: center;
      gap            : 0;
      margin-bottom  : 32px;
    }
    .step {
      display   : flex;
      align-items: center;
      gap       : 8px;
      font-size : 13px;
      font-weight: 600;
      color     : var(--text-muted);
    }
    .step .step-num {
      width        : 28px; height: 28px;
      border-radius: 50%;
      background   : var(--border-light);
      color        : var(--text-muted);
      display      : flex;
      align-items  : center;
      justify-content: center;
      font-size    : 13px;
      font-weight  : 800;
      transition   : var(--transition);
    }
    .step.active .step-num {
      background: var(--orange-gradient);
      color     : var(--white);
    }
    .step.active { color: var(--orange-dark); }
    .step.done .step-num {
      background: var(--success);
      color     : var(--white);
    }
    .step-line {
      width     : 48px;
      height    : 2px;
      background: var(--border-light);
      margin    : 0 6px;
      align-self: center;
    }

    .back-link {
      display    : flex;
      align-items: center;
      gap        : 6px;
      font-size  : 13px;
      font-weight: 700;
      color      : var(--orange-dark);
      margin-top : 20px;
      justify-content: center;
    }
    .back-link:hover { text-decoration: underline; }
  </style>
</head>
<body>

  <!-- ==================== FORM TAG - REQUIRED ==================== -->
  <form id="form1" runat="server">

    <div class="login-page">
      <div class="login-card">

        <!-- Logo -->
        <div class="login-logo">
          <img src="Images/logo.png" alt="ONTI International University Malaysia" 
               style="height: 60px; width: auto;" />
        </div>

        <!-- Step indicator -->
        <div class="steps">
          <div class="step active" id="step1Indicator">
            <span class="step-num">1</span> Enter Email
          </div>
          <div class="step-line"></div>
          <div class="step" id="step2Indicator">
            <span class="step-num">2</span> Check Inbox
          </div>
        </div>

        <!-- Alert panels -->
        <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger">
          <i class="fa-solid fa-circle-exclamation"></i>
          <asp:Label ID="lblError" runat="server" />
        </asp:Panel>

        <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="alert alert-success">
          <i class="fa-solid fa-circle-check"></i>
          <asp:Label ID="lblSuccess" runat="server" />
        </asp:Panel>

        <!-- STEP 1 -->
        <asp:Panel ID="pnlStep1" runat="server">
          <h1 class="login-title">Reset Password</h1>
          <p class="login-subtitle">
            Enter your registered email address and we'll send you a reset link.
          </p>

          <div class="form-group">
            <label class="form-label">Email Address</label>
            <div class="input-wrapper">
              <i class="fa-solid fa-envelope input-icon"></i>
              <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control"
                           placeholder="e.g. S125632@student.onti.edu.my"
                           TextMode="Email" MaxLength="100" />
            </div>
            <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
              ControlToValidate="txtEmail" ErrorMessage="Please enter your email address."
              CssClass="validation-message" Display="Dynamic" ValidationGroup="ForgotGroup" />
          </div>

          <asp:Button ID="btnSendLink" runat="server" Text="Send Reset Link"
                      CssClass="btn btn-primary" OnClick="btnSendLink_Click"
                      ValidationGroup="ForgotGroup" />
        </asp:Panel>

        <!-- STEP 2 -->
        <asp:Panel ID="pnlStep2" runat="server" Visible="false">
          <div style="text-align:center; margin-bottom:20px;">
            <i class="fa-solid fa-paper-plane" style="font-size:52px; background:var(--orange-gradient); -webkit-background-clip:text; -webkit-text-fill-color:transparent;"></i>
          </div>

          <h1 class="login-title">Check Your Email</h1>
          <p class="login-subtitle">
            A password reset link has been sent to your email address.
            The link will expire in <strong>30 minutes</strong>.
          </p>

          <p style="font-size:13px; color:var(--text-muted); text-align:center; margin-top:8px;">
            Didn't receive it? Check your spam folder or
            <asp:LinkButton ID="lbResend" runat="server"
              Text="click here to resend."
              OnClick="lbResend_Click"
              style="color:var(--orange-dark);font-weight:700;" />
          </p>
        </asp:Panel>

        <!-- Back to login -->
        <a href="Login.aspx" class="back-link">
          <i class="fa-solid fa-arrow-left"></i> Back to Login
        </a>

      </div><!-- /login-card -->
    </div><!-- /login-page -->

  </form>   <!-- Close Form -->

</body>
</html>