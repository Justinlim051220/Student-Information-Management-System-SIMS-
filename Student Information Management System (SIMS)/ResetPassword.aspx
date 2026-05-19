<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.ResetPassword" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>SIMS – Reset Password | ONTI International University</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
  <link rel="stylesheet" href="Styles/SIMS.css" />

  <style>
    /* Password strength meter */
    .strength-bar {
      height       : 5px;
      border-radius: 5px;
      background   : var(--border-light);
      margin-top   : 8px;
      overflow     : hidden;
    }
    .strength-fill {
      height    : 100%;
      width     : 0%;
      border-radius: 5px;
      transition: width 0.3s ease, background 0.3s ease;
    }
    .strength-label {
      font-size  : 12px;
      margin-top : 5px;
      font-weight: 600;
    }
  </style>
</head>
<body>
    <form id="form1" runat="server">

  <div class="login-page">
    <div class="login-card">

      <!-- Logo -->
      <div class="login-logo">
        <span class="logo-icon">π</span>
        <div class="logo-text">
          <div class="name">ONTI</div>
          <div class="sub">International University Malaysia</div>
        </div>
      </div>

      <!-- Alert panels -->
      <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger">
        <i class="fa-solid fa-circle-exclamation"></i>
        <asp:Label ID="lblError" runat="server" />
      </asp:Panel>

      <!-- ── Valid token: show reset form ── -->
      <asp:Panel ID="pnlForm" runat="server">

        <h1 class="login-title">Set New Password</h1>
        <p class="login-subtitle">
          Choose a strong password for your account.
        </p>

        <!-- Hidden fields to carry token & email through postback -->
        <asp:HiddenField ID="hfToken" runat="server" />
        <asp:HiddenField ID="hfEmail" runat="server" />

        <!-- New password -->
        <div class="form-group">
          <label class="form-label">New Password</label>
          <div class="input-wrapper">
            <i class="fa-solid fa-lock input-icon"></i>
            <asp:TextBox
              ID="txtNewPassword"
              runat="server"
              CssClass="form-control"
              TextMode="Password"
              placeholder="At least 8 characters"
              MaxLength="255"
              onkeyup="checkStrength(this.value)" />
            <button type="button" class="toggle-password" onclick="togglePwd('txtNew','eyeNew')">
              <i id="eyeNew" class="fa-solid fa-eye"></i>
            </button>
          </div>
          <!-- Strength bar -->
          <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
          <span class="strength-label text-muted" id="strengthLabel"></span>

          <asp:RequiredFieldValidator
            ID="rfvNew" runat="server"
            ControlToValidate="txtNewPassword"
            ErrorMessage="New password is required."
            CssClass="validation-message"
            Display="Dynamic"
            ValidationGroup="ResetGroup" />
        </div>

        <!-- Confirm password -->
        <div class="form-group">
          <label class="form-label">Confirm Password</label>
          <div class="input-wrapper">
            <i class="fa-solid fa-lock input-icon"></i>
            <asp:TextBox
              ID="txtConfirmPassword"
              runat="server"
              CssClass="form-control"
              TextMode="Password"
              placeholder="Re-enter new password"
              MaxLength="255" />
            <button type="button" class="toggle-password" onclick="togglePwd('txtConfirm','eyeConfirm')">
              <i id="eyeConfirm" class="fa-solid fa-eye"></i>
            </button>
          </div>
          <asp:RequiredFieldValidator
            ID="rfvConfirm" runat="server"
            ControlToValidate="txtConfirmPassword"
            ErrorMessage="Please confirm your password."
            CssClass="validation-message"
            Display="Dynamic"
            ValidationGroup="ResetGroup" />
          <asp:CompareValidator
            ID="cvPasswords" runat="server"
            ControlToValidate="txtConfirmPassword"
            ControlToCompare="txtNewPassword"
            ErrorMessage="Passwords do not match."
            CssClass="validation-message"
            Display="Dynamic"
            ValidationGroup="ResetGroup" />
        </div>

        <asp:Button
          ID="btnReset"
          runat="server"
          Text="Update Password"
          CssClass="btn btn-primary"
          OnClick="btnReset_Click"
          ValidationGroup="ResetGroup" />

      </asp:Panel>

      <!-- ── Invalid/expired token ── -->
      <asp:Panel ID="pnlInvalid" runat="server" Visible="false">
        <div style="text-align:center; padding: 16px 0;">
          <i class="fa-solid fa-link-slash"
             style="font-size:48px; color:var(--danger); margin-bottom:16px; display:block;"></i>
          <h1 class="login-title">Link Expired</h1>
          <p class="login-subtitle">
            This password reset link has expired or already been used.
            Please request a new one.
          </p>
          <a href="ForgotPassword.aspx" class="btn btn-primary" style="margin-top:12px; display:inline-flex;">
            Request New Link
          </a>
        </div>
      </asp:Panel>

      <!-- Back to login -->
      <a href="Login.aspx" class="back-link" style="display:flex;justify-content:center;align-items:center;gap:6px;margin-top:20px;font-size:13px;font-weight:700;color:var(--orange-dark);">
        <i class="fa-solid fa-arrow-left"></i> Back to Login
      </a>

    </div><!-- /login-card -->
  </div><!-- /login-page -->

  <script>
    // Toggle individual password field visibility
    function togglePwd(inputId, iconId) {
      // ASP.NET renders TextBox IDs — we use partial match via contains selector
      var inputs = document.querySelectorAll('input[id*="' + inputId + '"]');
      var icon   = document.getElementById(iconId);
      if (inputs.length > 0) {
        var box = inputs[0];
        if (box.type === 'password') {
          box.type       = 'text';
          icon.className = 'fa-solid fa-eye-slash';
        } else {
          box.type       = 'password';
          icon.className = 'fa-solid fa-eye';
        }
      }
    }

    // Password strength checker
    function checkStrength(val) {
      var fill  = document.getElementById('strengthFill');
      var label = document.getElementById('strengthLabel');
      var score = 0;
      if (val.length >= 8)              score++;
      if (/[A-Z]/.test(val))           score++;
      if (/[0-9]/.test(val))           score++;
      if (/[^A-Za-z0-9]/.test(val))    score++;

      var colors = ['', '#E74C3C', '#E67E22', '#F39C12', '#2ECC71'];
      var labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
      var widths = ['0%', '25%', '50%', '75%', '100%'];

      fill.style.width      = widths[score] || '0%';
      fill.style.background = colors[score] || 'transparent';
      label.textContent     = val.length > 0 ? labels[score] : '';
      label.style.color     = colors[score] || '';
    }
  </script>

</body>
    </form>

</html>
