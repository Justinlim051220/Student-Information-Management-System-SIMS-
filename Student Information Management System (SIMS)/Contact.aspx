<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" 
         Inherits="Student_Information_Management_System__SIMS_.Contact" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Contact Us - SIMS | ONTI International University</title>
  <link rel="stylesheet" href="Styles/SIMS.css" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
</head>
<body>

  <form id="form1" runat="server">
    <div class="login-page" style="min-height:100vh; padding-top:40px;">
      <div class="login-card" style="max-width: 700px;">

        <div class="login-logo">
          <img src="Images/logo.png" alt="ONTI International University" 
               style="height: 55px; width: auto;" />
        </div>

        <h1 class="login-title">Contact Us</h1>
        <p class="login-subtitle">We are here to help you</p>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 40px; margin-top: 30px;">

          <!-- Left Side - Contact Info -->
          <div>
            <h3 style="margin-bottom:20px; color:var(--orange-dark);">Get in Touch</h3>
            
            <p><strong>ONTI International University Malaysia</strong></p>
            
            <p style="margin:20px 0;">
              <i class="fa-solid fa-location-dot"></i> Bukit Mertajam, Penang, Malaysia
            </p>
            
            <p style="margin:15px 0;">
              <i class="fa-solid fa-phone"></i> +60 12-345 6789
            </p>
            
            <p style="margin:15px 0;">
              <i class="fa-solid fa-envelope"></i> 
              <a href="mailto:helpdesk@onti.edu.my">helpdesk@onti.edu.my</a>
            </p>

            <hr style="margin:30px 0;" />
            
            <h4>Office Hours</h4>
            <p>Monday - Friday: 8:30 AM - 5:30 PM</p>
          </div>

          <!-- Right Side - Quick Links -->
          <div>
            <h3 style="margin-bottom:20px; color:var(--orange-dark);">Quick Support</h3>
            
            <div style="background:#f8f9fa; padding:20px; border-radius:12px;">
              <p><strong>For Students & Staff:</strong></p>
              <ul style="margin:15px 0; padding-left:20px;">
                <li>Password Reset Issues</li>
                <li>Account Activation</li>
                <li>System Access Problems</li>
              </ul>
              
              <a href="mailto:helpdesk@onti.edu.my" class="btn btn-primary" 
                 style="display:inline-block; width:100%; text-align:center; margin-top:10px;">
                Email Support Team
              </a>
            </div>
          </div>

        </div>

        <div style="text-align:center; margin-top:40px;">
          <a href="Login.aspx" class="back-link">
            <i class="fa-solid fa-arrow-left"></i> Back to Login
          </a>
        </div>

      </div>
    </div>
  </form>

</body>
</html>