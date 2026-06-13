# Student Information Management System (SIMS)

## Overview

Student Information Management System (SIMS) is a web-based university management system developed using ASP.NET Web Forms (C#) and Microsoft SQL Server.

The system supports three user roles:

* Administrator (Head of Programme)
* Lecturer
* Student

Key features include:

* Student Enrollment Management
* Course Management
* Programme Management
* Lecturer Assignment
* Attendance Tracking
* Academic Results Management
* Fee Payment Management
* Notifications & Announcements
* Password Reset via Email
* Academic and Administrative Reporting

---

# System Requirements

## Software Requirements

### Development Environment

* Microsoft Visual Studio 2022
* .NET Framework 4.8
* SQL Server 2019 or later
* SQL Server Management Studio (SSMS)

### Browser Support

* Google Chrome
* Microsoft Edge
* Mozilla Firefox

---

# Database Setup

## Step 1: Create Database

Open SQL Server Management Studio (SSMS).

Create a new database:

```sql
CREATE DATABASE SIMS;
```

---

## Step 2: Execute Main Database Script

Open the provided SQL file:

```text
SIMS_Database.sql
```

Execute the entire script.

This will create all required tables including:

* Users
* StudentDetails
* LecturerDetails
* HoPDetails
* Programmes
* Courses
* CourseOffering
* Enrollment
* Fees
* Attendance
* Grades
* Results
* Notifications
* Announcements

and all supporting database objects.

---

## Step 3: Execute Password Reset Patch

Open:

```text
SIMS_Patch_PasswordResets.sql
```

Execute the script.

This patch creates:

```text
PasswordResets
```

which is required for:

* Forgot Password
* Password Reset via Email
* Reset Token Verification

---

## Step 4: Verify Connection String

Open:

```text
Web.config
```

Locate:

```xml
<connectionStrings>
```

Update the connection string according to your SQL Server configuration.

Example:

```xml
<connectionStrings>
  <add name="SIMSConnection"
       connectionString="Data Source=localhost;
                         Initial Catalog=SIMS;
                         Integrated Security=True"
       providerName="System.Data.SqlClient"/>
</connectionStrings>
```

---

# First Time System Setup

A new database contains no users.

Therefore, the first administrator account must be created before login is possible.

## Step 5: Run System Setup

Open:

```text
SystemSetup.aspx
```

Example:

```text
https://localhost:44300/SystemSetup.aspx
```

Create the first administrator account.

Required information:

* First Name
* Last Name
* Email Address
* Password

After successful creation:

```text
Administrator account created successfully.
```

---

# Login

After creating the first administrator account:

Open:

```text
Login.aspx
```

Login using the newly created administrator credentials.

---

# Initial Configuration

After administrator login:

Recommended setup order:

## 1. Create Programmes

Navigate to:

```text
Admin → Manage Programmes
```

Examples:

* Diploma in Computer Science
* Diploma in Information Technology
* Bachelor of Software Engineering

---

## 2. Create Courses

Navigate to:

```text
Admin → Manage Courses
```

Examples:

* Programming Fundamentals
* Database Systems
* Software Engineering

---

## 3. Create Lecturer Accounts

Navigate to:

```text
Admin → Manage Lecturers
```

---

## 4. Create Student Accounts

Navigate to:

```text
Admin → Manage Students
```

---

## 5. Assign Courses

Navigate to:

```text
Admin → Assign Lecturer Course
```

Assign lecturers to courses.

---

## 6. Open Course Offerings

Navigate to:

```text
Admin → Course Offering
```

Open courses for specific:

* Programme
* Session

---

# Academic Workflow

## Enrollment

Students:

```text
Student → Enrollment
```

can enroll into open sessions.

Upon enrollment:

* Enrollment record is created
* Payment record is generated automatically
* Notification is sent to Administrator

---

## Payment

Students upload payment receipts.

Administrator:

```text
Admin → Manage Fees
```

can:

* Approve Payment
* Reject Payment

Notifications are sent automatically.

---

## Attendance

Lecturers record attendance.

Students can view attendance percentage and attendance history.

---

## Results

Lecturers enter assessment marks.

The system automatically:

* Calculates grades
* Calculates GPA
* Calculates CGPA
* Stores academic results

Students can view their results.

Administrators can generate academic reports.

---

# Reports

Administrator can generate:

* Enrollment Report
* Fee Payment Report
* Attendance Report
* Academic Report

Export formats:

* PDF
* Excel
* CSV

---

# User Roles

## Administrator

Functions:

* Manage Students
* Manage Lecturers
* Manage Programmes
* Manage Courses
* Course Offering
* Enrollment Approval
* Fee Approval
* Reports
* Notifications
* Announcements

---

## Lecturer

Functions:

* View Assigned Courses
* Record Attendance
* Enter Student Marks
* Publish Announcements
* Receive Notifications

---

## Student

Functions:

* Enrollment
* Fee Payment
* Attendance Viewing
* Result Viewing
* Notifications
* Profile Management

---

# Important Notes

## SystemSetup.aspx

This page is intended only for first-time setup.

After the first administrator account is created:

```text
SystemSetup.aspx
```

should be disabled or removed in production environments.

---

## Email Configuration

Password reset functionality requires SMTP configuration.

Update:

```text
Web.config
```

SMTP settings before using Forgot Password.

---

# Project Information

Student Information Management System (SIMS)

Developed using:

* ASP.NET Web Forms (C#)
* Microsoft SQL Server
* HTML5
* CSS3
* JavaScript
* Bootstrap
* Font Awesome

Academic Project Submission
INTI International University
