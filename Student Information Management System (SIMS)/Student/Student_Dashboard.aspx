<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Student_Dashboard.aspx.cs" Inherits="Student_Information_Management_System__SIMS_.Student_Dashboard" %>
<%@ Register Src="~/Student/StudentSidebar.ascx" TagPrefix="uc" TagName="StudentSidebar" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SIMS - Student Dashboard | ONTI International University</title>

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <link rel="stylesheet" href="../Styles/SIMS.css" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

    <style>
        html,
        body {
            margin: 0;
            padding: 0;
        }

        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            width: 260px;
            height: 100vh;
            overflow-y: auto;
            overflow-x: hidden;
            scrollbar-width: thin;
        }

        .main-wrapper {
            margin-left: 260px;
        }

        .notif-wrap {
            position: relative;
            display: inline-block;
        }

        .notif-dot {
            position: absolute;
            top: -2px;
            right: -2px;
            width: 10px;
            height: 10px;
            background: #ef4444;
            border: 2px solid #ffffff;
            border-radius: 50%;
            z-index: 999;
        }

        .stu-stats-grid {
            display: grid;
            grid-template-columns: repeat(5, minmax(170px, 1fr));
            gap: 18px;
            margin-bottom: 28px;
        }

        .stu-stat-card {
            border: 1px solid #edf0f6;
            background: linear-gradient(180deg, #fff 0%, #fffaf3 100%);
            border-radius: var(--radius-md);
            padding: 24px 20px;
            box-shadow: var(--shadow-card);
            display: flex;
            flex-direction: column;
            gap: 8px;
            transition: var(--transition);
            min-height: 150px;
            position: relative;
            overflow: hidden;
        }

        .stu-stat-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-elevated);
        }

        .stu-stat-card:after {
            content: "";
            position: absolute;
            right: -28px;
            top: -28px;
            width: 92px;
            height: 92px;
            background: rgba(245,166,35,.10);
            border-radius: 50%;
        }

        .stu-stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 18px;
            background: var(--orange-gradient);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-size: 22px;
            margin-bottom: 4px;
        }

        .stu-stat-label {
            font-size: 13px;
            font-weight: 900;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stu-stat-value {
            font-family: var(--font-accent);
            font-size: 28px;
            font-weight: 800;
            color: var(--orange-dark);
            line-height: 1;
        }

        .stu-stat-value.neutral {
            color: var(--text-primary);
        }

        .stat-caption {
            color: var(--text-muted);
            font-size: 12px;
            font-weight: 700;
            margin-top: 2px;
        }

        .course-badge-list {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-top: 4px;
        }

        .course-badge {
            background: var(--orange-gradient);
            color: var(--white);
            font-size: 11px;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: var(--radius-pill);
            letter-spacing: 0.3px;
        }

        .charts-row {
            display: grid;
            grid-template-columns: 1fr 1fr 360px;
            gap: 20px;
            margin-bottom: 28px;
        }

        .chart-card {
            background: var(--bg-card);
            border-radius: var(--radius-md);
            padding: 20px;
            box-shadow: var(--shadow-card);
            border: 1px solid #edf0f6;
        }

        .chart-card-title {
            font-size: 14px;
            font-weight: 800;
            color: var(--text-primary);
            margin-bottom: 16px;
        }

        .chart-canvas-wrap {
            position: relative;
            height: 200px;
        }

        .announcement-card {
            background: linear-gradient(135deg, #f59e0b, #f97316);
            border-radius: var(--radius-md);
            padding: 20px;
            box-shadow: var(--shadow-orange);
            color: var(--white);
            display: flex;
            flex-direction: column;
            gap: 12px;
            min-height: 260px;
        }

        .announcement-card .card-title-white {
            font-size: 15px;
            font-weight: 800;
            color: var(--white);
        }

        .ann-item {
            background: rgba(255,255,255,0.18);
            border-radius: var(--radius-sm);
            padding: 10px 14px;
        }

        .ann-item-title {
            font-size: 13px;
            font-weight: 700;
            color: var(--white);
        }

        .ann-item-date {
            font-size: 11px;
            color: rgba(255,255,255,0.75);
            margin-top: 3px;
        }

        .ann-empty {
            font-size: 13px;
            color: rgba(255,255,255,0.7);
            text-align: center;
            margin: auto 0;
        }

        .dashboard-hero {
            background: linear-gradient(135deg, #fff7ed 0%, #ffffff 58%, #fff3d6 100%);
            border: 1px solid rgba(245,166,35,.20);
            border-radius: 24px;
            box-shadow: 0 16px 38px rgba(15,23,42,.08);
            padding: 24px;
            margin-bottom: 26px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 22px;
        }

        .hero-left {
            display: flex;
            align-items: center;
            gap: 16px;
            min-width: 0;
        }

        .hero-avatar {
            width: 70px;
            height: 70px;
            border-radius: 22px;
            background: var(--orange-gradient);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            font-weight: 900;
            box-shadow: var(--shadow-orange);
            flex-shrink: 0;
        }

        .hero-kicker {
            font-size: 12px;
            font-weight: 900;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: var(--orange-dark);
        }

        .hero-name {
            font-family: var(--font-accent);
            font-size: 28px;
            line-height: 1.1;
            font-weight: 900;
            color: var(--text-primary);
            margin-top: 4px;
        }

        .hero-meta {
            margin-top: 8px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            color: var(--text-secondary);
            font-size: 13px;
            font-weight: 700;
        }

        .hero-pill {
            background: #fff;
            border: 1px solid #f2e2c5;
            border-radius: 999px;
            padding: 6px 12px;
        }

        .hero-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .hero-action {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            padding: 11px 16px;
            border-radius: 999px;
            font-weight: 900;
            font-size: 13px;
            border: 1.5px solid #f2c46f;
            color: #9a5a00;
            background: #fff;
            transition: .18s ease;
        }

        .hero-action.primary {
            background: var(--orange-gradient);
            color: #fff;
            border-color: transparent;
            box-shadow: var(--shadow-orange);
        }

        .hero-action:hover {
            transform: translateY(-2px);
        }

        .quick-actions-card {
            background: var(--bg-card);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-card);
            border: 1px solid #edf0f6;
            padding: 22px;
            margin-bottom: 28px;
        }

        .section-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
        }

        .section-title {
            font-size: 16px;
            font-weight: 900;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: 9px;
        }

        .section-title i {
            color: var(--orange-main);
        }

        .quick-actions-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(160px, 1fr));
            gap: 14px;
        }

        .quick-action-tile {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            padding: 16px;
            border-radius: 18px;
            border: 1px solid #edf0f6;
            background: #fff;
            transition: .18s ease;
        }

        .quick-action-tile:hover {
            transform: translateY(-2px);
            box-shadow: 0 14px 30px rgba(15,23,42,.08);
            border-color: #f2c46f;
        }

        .quick-action-icon {
            width: 42px;
            height: 42px;
            border-radius: 15px;
            background: #fff3d6;
            color: #d97706;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }

        .quick-action-text strong {
            display: block;
            color: var(--text-primary);
            font-size: 14px;
            font-weight: 900;
        }

        .quick-action-text span {
            color: var(--text-muted);
            font-size: 12px;
            font-weight: 700;
        }

        @media (max-width: 1250px) {
            .stu-stats-grid {
                grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
            }
        }

        @media (max-width: 1100px) {
            .charts-row {
                grid-template-columns: 1fr 1fr;
            }

            .announcement-card {
                grid-column: span 2;
            }
        }

        @media (max-width: 850px) {
            .quick-actions-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .dashboard-hero {
                align-items: flex-start;
                flex-direction: column;
            }

            .hero-actions {
                justify-content: flex-start;
            }
        }

        @media (max-width: 700px) {
            .charts-row {
                grid-template-columns: 1fr;
            }

            .announcement-card {
                grid-column: span 1;
            }
        }
    </style>
</head>

<body>
<form id="form1" runat="server">

    <uc:StudentSidebar ID="StudentSidebar1" runat="server" />

    <div class="main-wrapper">

        <div class="topbar">
            <div>
                <div class="topbar-title">Dashboard</div>
                <div class="topbar-date">
                    <asp:Label ID="lblDate" runat="server" Text="" />
                </div>
            </div>

            <div class="topbar-right">
                <a href="Notification.aspx" class="topbar-icon-btn" title="Notifications">
                    <span class="notif-wrap">
                        <i class="fa-solid fa-bell"></i>
                        <asp:Panel ID="pnlNotifBadge" runat="server" CssClass="notif-dot" Visible="false" />
                    </span>
                </a>

                <a href="MyProfile.aspx" class="topbar-icon-btn" title="My Profile">
                    <i class="fa-solid fa-circle-user"></i>
                </a>
            </div>
        </div>

        <div class="page-content">

            <div class="dashboard-hero">
                <div class="hero-left">
                    <div class="hero-avatar">
                        <asp:Label ID="lblTopbarInitial" runat="server" Text="S" />
                    </div>

                    <div>
                        <div class="hero-kicker">Student Academic Portal</div>
                        <div class="hero-name">
                            Welcome back, <asp:Label ID="lblStudentName" runat="server" Text="Student" />
                        </div>

                        <div class="hero-meta">
                            <span class="hero-pill">
                                <i class="fa-solid fa-id-card"></i>
                                <asp:Label ID="lblStudentId" runat="server" Text="" />
                            </span>

                            <span class="hero-pill">
                                <i class="fa-solid fa-building-columns"></i>
                                <asp:Label ID="lblProgramme" runat="server" Text="" />
                            </span>
                        </div>
                    </div>
                </div>

                <div class="hero-actions">
                    <a href="Student_Enrollment.aspx" class="hero-action primary">
                        <i class="fa-solid fa-clipboard-list"></i> Enroll Course
                    </a>

                    <a href="Student_Payment.aspx" class="hero-action">
                        <i class="fa-solid fa-credit-card"></i> Payment
                    </a>

                    <a href="Results.aspx" class="hero-action">
                        <i class="fa-solid fa-chart-line"></i> Results
                    </a>
                </div>
            </div>

            <div class="stu-stats-grid">

                <div class="stu-stat-card">
                    <div class="stu-stat-icon"><i class="fa-solid fa-graduation-cap"></i></div>
                    <div class="stu-stat-label">Current GPA</div>
                    <div class="stu-stat-value">
                        <asp:Label ID="lblGPA" runat="server" Text="N/A" />
                    </div>
                    <div class="stat-caption">Latest published semester result</div>
                </div>

                <div class="stu-stat-card">
                    <div class="stu-stat-icon"><i class="fa-solid fa-ranking-star"></i></div>
                    <div class="stu-stat-label">CGPA</div>
                    <div class="stu-stat-value">
                        <asp:Label ID="lblCGPA" runat="server" Text="N/A" />
                    </div>
                    <div class="stat-caption">Overall academic performance</div>
                </div>

                <div class="stu-stat-card">
                    <div class="stu-stat-icon"><i class="fa-solid fa-calendar-check"></i></div>
                    <div class="stu-stat-label">Attendance</div>
                    <div class="stu-stat-value">
                        <asp:Label ID="lblAttendance" runat="server" Text="0.00" />%
                    </div>
                    <div class="stat-caption">Across enrolled courses</div>
                </div>

                <div class="stu-stat-card">
                    <div class="stu-stat-icon"><i class="fa-solid fa-book-open"></i></div>
                    <div class="stu-stat-label">Enrolled Courses</div>
                    <div class="course-badge-list">
                        <asp:Repeater ID="rptEnrolledCourses" runat="server">
                            <ItemTemplate>
                                <span class="course-badge"><%# Eval("CourseCode") %></span>
                            </ItemTemplate>
                        </asp:Repeater>

                        <asp:Label ID="lblNoCourses"
                            runat="server"
                            Text="None"
                            Style="color:var(--text-muted);font-size:13px;"
                            Visible="false" />
                    </div>
                </div>

                <div class="stu-stat-card">
                    <div class="stu-stat-icon"><i class="fa-solid fa-wallet"></i></div>
                    <div class="stu-stat-label">Outstanding Fees</div>
                    <div class="stu-stat-value neutral">
                        RM <asp:Label ID="lblFees" runat="server" Text="00.00" />
                    </div>
                    <div class="stat-caption">Pending finance action</div>
                </div>

            </div>

            <div class="quick-actions-card">
                <div class="section-head">
                    <div class="section-title">
                        <i class="fa-solid fa-bolt"></i> Quick Actions
                    </div>
                </div>

                <div class="quick-actions-grid">
                    <a href="Student_Enrollment.aspx" class="quick-action-tile">
                        <div class="quick-action-icon"><i class="fa-solid fa-clipboard-list"></i></div>
                        <div class="quick-action-text">
                            <strong>Enrollment</strong>
                            <span>Register next session courses</span>
                        </div>
                    </a>

                    <a href="MyCourses.aspx" class="quick-action-tile">
                        <div class="quick-action-icon"><i class="fa-solid fa-book-open"></i></div>
                        <div class="quick-action-text">
                            <strong>My Courses</strong>
                            <span>View course materials</span>
                        </div>
                    </a>

                    <a href="Results.aspx" class="quick-action-tile">
                        <div class="quick-action-icon"><i class="fa-solid fa-square-poll-vertical"></i></div>
                        <div class="quick-action-text">
                            <strong>Results</strong>
                            <span>Check GPA and CGPA</span>
                        </div>
                    </a>

                    <a href="Student_Payment.aspx" class="quick-action-tile">
                        <div class="quick-action-icon"><i class="fa-solid fa-credit-card"></i></div>
                        <div class="quick-action-text">
                            <strong>Payment</strong>
                            <span>Upload payment receipt</span>
                        </div>
                    </a>
                </div>
            </div>

            <div class="charts-row">

                <div class="chart-card">
                    <div class="chart-card-title">
                        <i class="fa-solid fa-chart-column" style="color:var(--orange-main);margin-right:6px;"></i>
                        Attendance Trend Chart
                    </div>
                    <div class="chart-canvas-wrap">
                        <canvas id="attendanceChart"></canvas>
                    </div>
                </div>

                <div class="chart-card">
                    <div class="chart-card-title">
                        <i class="fa-solid fa-chart-line" style="color:var(--orange-main);margin-right:6px;"></i>
                        GPA Trend Chart
                    </div>
                    <div class="chart-canvas-wrap">
                        <canvas id="gpaChart"></canvas>
                    </div>
                </div>

                <div class="announcement-card">
                    <div class="card-title-white">
                        <i class="fa-solid fa-bullhorn" style="margin-right:6px;"></i> Announcements
                    </div>

                    <asp:Repeater ID="rptAnnouncements" runat="server">
                        <ItemTemplate>
                            <div class="ann-item">
                                <div class="ann-item-title"><%# Eval("Title") %></div>
                                <div class="ann-item-date">
                                    <i class="fa-regular fa-clock"></i>
                                    <%# Eval("CreatedAt", "{0:dd MMM yyyy}") %>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <asp:Label ID="lblNoAnnouncements"
                        runat="server"
                        CssClass="ann-empty"
                        Text="No announcements at this time."
                        Visible="false" />
                </div>

            </div>

        </div>
    </div>

    <asp:HiddenField ID="hdnAttendanceLabels" runat="server" />
    <asp:HiddenField ID="hdnAttendanceData" runat="server" />
    <asp:HiddenField ID="hdnGpaLabels" runat="server" />
    <asp:HiddenField ID="hdnGpaData" runat="server" />

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var attLabels = document.getElementById('<%= hdnAttendanceLabels.ClientID %>').value;
            var attData = document.getElementById('<%= hdnAttendanceData.ClientID %>').value;
            var gpaLabels = document.getElementById('<%= hdnGpaLabels.ClientID %>').value;
            var gpaData = document.getElementById('<%= hdnGpaData.ClientID %>').value;

            var aLabels = attLabels ? attLabels.split('|') : [];
            var aData = attData ? attData.split('|').map(Number) : [];
            var gLabels = gpaLabels ? gpaLabels.split('|') : [];
            var gData = gpaData ? gpaData.split('|').map(Number) : [];

            var attCtx = document.getElementById('attendanceChart').getContext('2d');
            new Chart(attCtx, {
                type: 'bar',
                data: {
                    labels: aLabels,
                    datasets: [{
                        label: 'Attendance %',
                        data: aData,
                        backgroundColor: 'rgba(245,166,35,0.75)',
                        borderColor: '#E8890A',
                        borderWidth: 2,
                        borderRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: 100,
                            ticks: {
                                callback: function (v) { return v + '%'; },
                                font: { size: 11 }
                            },
                            grid: { color: 'rgba(0,0,0,0.05)' }
                        },
                        x: {
                            ticks: { font: { size: 11 } },
                            grid: { display: false }
                        }
                    }
                }
            });

            var gpaCtx = document.getElementById('gpaChart').getContext('2d');
            new Chart(gpaCtx, {
                type: 'line',
                data: {
                    labels: gLabels,
                    datasets: [{
                        label: 'GPA',
                        data: gData,
                        borderColor: '#F5A623',
                        backgroundColor: 'rgba(245,166,35,0.15)',
                        borderWidth: 2.5,
                        pointBackgroundColor: '#E8890A',
                        pointRadius: 5,
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: {
                            beginAtZero: false,
                            min: 0,
                            max: 4,
                            ticks: { font: { size: 11 } },
                            grid: { color: 'rgba(0,0,0,0.05)' }
                        },
                        x: {
                            ticks: { font: { size: 11 } },
                            grid: { display: false }
                        }
                    }
                }
            });
        });
    </script>

</form>
</body>
</html>