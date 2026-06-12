/* =============================================================
   SIMS - Student Information Management System
   FINAL RESET CLEAN SQL

   Important:
   - This script DROPS and RECREATES the SIMS database.
   - Run this only when you want a fresh database structure.
   - No ALTER patch commands are used for table design.
   - Includes EnrollmentId + Fees.EnrollmentId relationship.
   - Includes PaymentId as Fees primary key and FeeId auto-filled by trigger.
   ============================================================= */

IF DB_ID('SIMS') IS NOT NULL
BEGIN
    ALTER DATABASE SIMS SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SIMS;
END;
GO

CREATE DATABASE SIMS;
GO

USE SIMS;
GO

/* =============================================================
   1. USERS
   ============================================================= */
CREATE TABLE dbo.Users (
    UserId        INT IDENTITY(1,1) NOT NULL,
    Email         VARCHAR(100)      NOT NULL,
    PasswordHash  VARCHAR(255)      NOT NULL,
    Role          TINYINT           NOT NULL, -- 1 = Admin, 2 = Lecturer, 3 = Student
    IsActive      BIT               NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT 1,
    CreatedAt     DATETIME          NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_Users PRIMARY KEY (UserId),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT CK_Users_Role CHECK (Role IN (1, 2, 3))
);
GO

/* =============================================================
   2. HOP / ADMIN DETAILS
   ============================================================= */
CREATE TABLE dbo.HoPDetails (
    HoPId           VARCHAR(20)  NOT NULL,
    UserId          INT          NOT NULL,
    FirstName       VARCHAR(50)  NOT NULL,
    LastName        VARCHAR(50)  NOT NULL,
    Phone           VARCHAR(20)  NULL,
    Department      VARCHAR(100) NULL,
    ProfilePicture  VARCHAR(255) NULL,

    CONSTRAINT PK_HoPDetails PRIMARY KEY (HoPId),
    CONSTRAINT FK_HoPDetails_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);
GO

/* =============================================================
   3. PROGRAMMES
   ============================================================= */
CREATE TABLE dbo.Programmes (
    ProgrammeId    INT IDENTITY(1,1) NOT NULL,
    ProgrammeName  VARCHAR(100)      NOT NULL,
    ProgrammeCode  VARCHAR(20)       NOT NULL,
    Duration       INT               NOT NULL,
    CreditHour     INT               NOT NULL CONSTRAINT DF_Programmes_CreditHour DEFAULT 0,
    Description    TEXT              NULL,
    HoPId          VARCHAR(20)       NOT NULL,

    CONSTRAINT PK_Programmes PRIMARY KEY (ProgrammeId),
    CONSTRAINT UQ_Programmes_Code UNIQUE (ProgrammeCode),
    CONSTRAINT FK_Programmes_HoP FOREIGN KEY (HoPId) REFERENCES dbo.HoPDetails(HoPId)
);
GO

/* =============================================================
   4. LECTURER DETAILS
   ============================================================= */
CREATE TABLE dbo.LecturerDetails (
    LecturerId      VARCHAR(20)  NOT NULL,
    UserId          INT          NOT NULL,
    FirstName       VARCHAR(50)  NOT NULL,
    LastName        VARCHAR(50)  NOT NULL,
    Gender          VARCHAR(10)  NULL,
    Phone           VARCHAR(20)  NULL,
    Specialization  VARCHAR(500) NULL,
    JoinDate        DATE         NULL,
    ProgrammeId     INT          NULL,
    ProfilePicture  VARCHAR(255) NULL,

    CONSTRAINT PK_LecturerDetails PRIMARY KEY (LecturerId),
    CONSTRAINT FK_LecturerDetails_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_LecturerDetails_Programme FOREIGN KEY (ProgrammeId) REFERENCES dbo.Programmes(ProgrammeId)
);
GO

/* =============================================================
   5. LECTURER PROGRAMME
   One lecturer can belong to multiple programmes.
   ============================================================= */
CREATE TABLE dbo.LecturerProgramme (
    LecturerId    VARCHAR(20) NOT NULL,
    ProgrammeId   INT         NOT NULL,
    AssignedDate  DATE        NOT NULL CONSTRAINT DF_LecturerProgramme_AssignedDate DEFAULT GETDATE(),

    CONSTRAINT PK_LecturerProgramme PRIMARY KEY (LecturerId, ProgrammeId),
    CONSTRAINT FK_LecturerProgramme_Lecturer FOREIGN KEY (LecturerId) REFERENCES dbo.LecturerDetails(LecturerId),
    CONSTRAINT FK_LecturerProgramme_Programme FOREIGN KEY (ProgrammeId) REFERENCES dbo.Programmes(ProgrammeId)
);
GO

/* =============================================================
   6. STUDENT DETAILS
   ============================================================= */
CREATE TABLE dbo.StudentDetails (
    StudentId        VARCHAR(20)  NOT NULL,
    UserId           INT          NOT NULL,
    FirstName        VARCHAR(50)  NOT NULL,
    LastName         VARCHAR(50)  NOT NULL,
    DateOfBirth      DATE         NULL,
    Gender           VARCHAR(10)  NULL,
    Phone            VARCHAR(20)  NULL,
    Address          TEXT         NULL,
    ProfilePicture   VARCHAR(255) NULL,
    EnrollmentDate   DATE         NULL,
    ProgrammeId      INT          NOT NULL,
    CurrentSemester  INT          NOT NULL CONSTRAINT DF_StudentDetails_CurrentSemester DEFAULT 1,

    CONSTRAINT PK_StudentDetails PRIMARY KEY (StudentId),
    CONSTRAINT FK_StudentDetails_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_StudentDetails_Programme FOREIGN KEY (ProgrammeId) REFERENCES dbo.Programmes(ProgrammeId),
    CONSTRAINT CK_StudentDetails_CurrentSemester CHECK (CurrentSemester >= 1)
);
GO

/* =============================================================
   7. COURSES
   ============================================================= */
CREATE TABLE dbo.Courses (
    CourseId     INT IDENTITY(1,1) NOT NULL,
    CourseCode   VARCHAR(20)       NOT NULL,
    CourseName   VARCHAR(100)      NOT NULL,
    Credits      INT               NOT NULL,
    ProgrammeId  INT               NOT NULL,
    Description  TEXT              NULL,

    CONSTRAINT PK_Courses PRIMARY KEY (CourseId),
    CONSTRAINT UQ_Courses_Code UNIQUE (CourseCode),
    CONSTRAINT FK_Courses_Programme FOREIGN KEY (ProgrammeId) REFERENCES dbo.Programmes(ProgrammeId)
);
GO

/* =============================================================
   8. COURSE OFFERING
   Admin controls which course opens by session/programme/semester.
   ============================================================= */
CREATE TABLE dbo.CourseOffering (
    OfferingId   INT IDENTITY(1,1) NOT NULL,
    [Session]    VARCHAR(15)       NOT NULL,
    ProgrammeId  INT               NOT NULL,
    CourseId     INT               NOT NULL,
    Semester     INT               NOT NULL,
    Status       VARCHAR(20)       NOT NULL CONSTRAINT DF_CourseOffering_Status DEFAULT 'Closed',
    CreatedDate  DATE              NOT NULL CONSTRAINT DF_CourseOffering_CreatedDate DEFAULT GETDATE(),

    CONSTRAINT PK_CourseOffering PRIMARY KEY (OfferingId),
    CONSTRAINT FK_CourseOffering_Programme FOREIGN KEY (ProgrammeId) REFERENCES dbo.Programmes(ProgrammeId),
    CONSTRAINT FK_CourseOffering_Course FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT CK_CourseOffering_Status CHECK (Status IN ('Open', 'Closed')),
    CONSTRAINT CK_CourseOffering_Semester CHECK (Semester >= 1),
    CONSTRAINT UQ_CourseOffering UNIQUE ([Session], ProgrammeId, CourseId, Semester)
);
GO

/* =============================================================
   9. COURSE MATERIALS
   ============================================================= */
CREATE TABLE dbo.CourseMaterials (
    MaterialId         INT IDENTITY(1,1) NOT NULL,
    CourseId           INT               NOT NULL,
    [Session]          VARCHAR(15)       NOT NULL,
    LecturerId         VARCHAR(20)       NOT NULL,
    Title              VARCHAR(200)      NOT NULL,
    MaterialType       VARCHAR(50)       NULL,
    Description        VARCHAR(MAX)      NULL,
    FileName           NVARCHAR(255)     NULL,
    FilePath           VARCHAR(500)      NULL,
    FileType           VARCHAR(100)      NULL,
    FileSizeKB         INT               NULL,
    WeightPercentage   DECIMAL(5,2)      NULL,
    CreatedAt          DATETIME          NOT NULL CONSTRAINT DF_CourseMaterials_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_CourseMaterials PRIMARY KEY (MaterialId),
    CONSTRAINT FK_CourseMaterials_Course FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT FK_CourseMaterials_Lecturer FOREIGN KEY (LecturerId) REFERENCES dbo.LecturerDetails(LecturerId)
);
GO

/* =============================================================
   10. COURSE MATERIAL FILES
   ============================================================= */
CREATE TABLE dbo.CourseMaterialFiles (
    FileId       INT IDENTITY(1,1) NOT NULL,
    MaterialId   INT               NOT NULL,
    FileName     NVARCHAR(255)     NOT NULL,
    FilePath     VARCHAR(500)      NOT NULL,
    FileType     VARCHAR(100)      NULL,
    FileSizeKB   INT               NULL,
    UploadedAt   DATETIME          NOT NULL CONSTRAINT DF_CourseMaterialFiles_UploadedAt DEFAULT GETDATE(),

    CONSTRAINT PK_CourseMaterialFiles PRIMARY KEY (FileId),
    CONSTRAINT FK_CourseMaterialFiles_Material FOREIGN KEY (MaterialId)
        REFERENCES dbo.CourseMaterials(MaterialId) ON DELETE CASCADE
);
GO

/* =============================================================
   11. ENROLLMENT
   Latest clean version uses EnrollmentId as unique primary key.
   This allows history for dropped/re-enrolled records.
   ============================================================= */
CREATE TABLE dbo.Enrollment (
    EnrollmentId       INT IDENTITY(1,1) NOT NULL,
    StudentId          VARCHAR(20)       NOT NULL,
    CourseId           INT               NOT NULL,
    [Session]          VARCHAR(15)       NOT NULL,
    Semester           INT               NOT NULL CONSTRAINT DF_Enrollment_Semester DEFAULT 1,
    Status             VARCHAR(30)       NOT NULL CONSTRAINT DF_Enrollment_Status DEFAULT 'Active',
    EnrollmentDate     DATE              NOT NULL CONSTRAINT DF_Enrollment_EnrollmentDate DEFAULT GETDATE(),
    DropReason         VARCHAR(255)      NULL,
    DropRequestedAt    DATETIME          NULL,
    DropReviewedAt     DATETIME          NULL,
    DropReviewedBy     VARCHAR(20)       NULL,

    CONSTRAINT PK_Enrollment_EnrollmentId PRIMARY KEY (EnrollmentId),
    CONSTRAINT FK_Enrollment_Student FOREIGN KEY (StudentId) REFERENCES dbo.StudentDetails(StudentId),
    CONSTRAINT FK_Enrollment_Course FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT CK_Enrollment_Status CHECK (Status IN (
        'Enrollment Pending',
        'Enrollment Rejected',
        'Active',
        'Drop Pending',
        'Drop Rejected',
        'Dropped',
        'Completed'
    )),
    CONSTRAINT CK_Enrollment_Semester CHECK (Semester >= 1)
);
GO

CREATE INDEX IX_Enrollment_Student_Course_Session_Status
ON dbo.Enrollment(StudentId, CourseId, [Session], Status);
GO

/* =============================================================
   12. LECTURER COURSE
   ============================================================= */
CREATE TABLE dbo.LecturerCourse (
    LecturerId    VARCHAR(20) NOT NULL,
    CourseId      INT         NOT NULL,
    [Session]     VARCHAR(15) NOT NULL,
    Semester      INT         NOT NULL,
    AssignedDate  DATE        NOT NULL CONSTRAINT DF_LecturerCourse_AssignedDate DEFAULT GETDATE(),
    SortOrder     INT         NULL,

    CONSTRAINT PK_LecturerCourse PRIMARY KEY (LecturerId, CourseId, [Session]),
    CONSTRAINT FK_LecturerCourse_Lecturer FOREIGN KEY (LecturerId) REFERENCES dbo.LecturerDetails(LecturerId),
    CONSTRAINT FK_LecturerCourse_Course FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT CK_LecturerCourse_Semester CHECK (Semester >= 1)
);
GO

/* =============================================================
   13. ATTENDANCE
   ============================================================= */
CREATE TABLE dbo.Attendance (
    CourseId        INT         NOT NULL,
    AttendanceDate  DATE        NOT NULL,
    StudentId       VARCHAR(20) NOT NULL,
    LecturerId      VARCHAR(20) NOT NULL,
    [Session]       VARCHAR(15) NOT NULL,
    Status          VARCHAR(10) NOT NULL CONSTRAINT DF_Attendance_Status DEFAULT 'Present',

    CONSTRAINT PK_Attendance PRIMARY KEY (CourseId, AttendanceDate, StudentId, [Session]),
    CONSTRAINT FK_Attendance_Course FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT FK_Attendance_Student FOREIGN KEY (StudentId) REFERENCES dbo.StudentDetails(StudentId),
    CONSTRAINT FK_Attendance_Lecturer FOREIGN KEY (LecturerId) REFERENCES dbo.LecturerDetails(LecturerId),
    CONSTRAINT CK_Attendance_Status CHECK (Status IN ('Present', 'Absent', 'Late'))
);
GO

/* =============================================================
   14. GRADES
   ============================================================= */
CREATE TABLE dbo.Grades (
    StudentId            VARCHAR(20)   NOT NULL,
    CourseId             INT           NOT NULL,
    MaterialId           INT           NOT NULL CONSTRAINT DF_Grades_MaterialId DEFAULT 0,
    Type                 VARCHAR(20)   NOT NULL,
    Title                VARCHAR(100)  NOT NULL,
    MaxMarks             DECIMAL(5,2)  NOT NULL,
    MarksObtained        DECIMAL(5,2)  NULL,
    DraftMarksObtained   DECIMAL(5,2)  NULL,
    WeightPercentage     DECIMAL(5,2)  NULL,
    Grade                VARCHAR(5)    NULL,
    DueDate              DATE          NULL,
    Remarks              TEXT          NULL,
    SubmittedAt          DATETIME      NULL,

    CONSTRAINT PK_Grades PRIMARY KEY (StudentId, CourseId, Type, MaterialId),
    CONSTRAINT FK_Grades_Student FOREIGN KEY (StudentId) REFERENCES dbo.StudentDetails(StudentId),
    CONSTRAINT FK_Grades_Course FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT CK_Grades_Type CHECK (Type IN ('Assignment', 'Quiz', 'Exam'))
);
GO

/* =============================================================
   15. COURSE FEES
   Price master table by course and session.
   ============================================================= */
CREATE TABLE dbo.CourseFees (
    CourseFeeId  INT IDENTITY(1,1) NOT NULL,
    CourseId     INT               NOT NULL,
    [Session]    VARCHAR(15)       NOT NULL,
    Amount       DECIMAL(10,2)     NOT NULL,
    CreatedAt    DATETIME          NOT NULL CONSTRAINT DF_CourseFees_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_CourseFees PRIMARY KEY (CourseFeeId),
    CONSTRAINT UQ_CourseFees_Course_Session UNIQUE (CourseId, [Session]),
    CONSTRAINT FK_CourseFees_Course FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT CK_CourseFees_Amount CHECK (Amount >= 0)
);
GO

/* =============================================================
   16. FEES
   Latest clean design:
   - PaymentId is the real identity primary key.
   - FeeId is nullable and auto-filled to PaymentId by trigger.
   - EnrollmentId links payment to a specific enrollment record.
   ============================================================= */
CREATE TABLE dbo.Fees (
    PaymentId                 INT IDENTITY(1,1) NOT NULL,
    FeeId                     INT               NULL,
    EnrollmentId              INT               NULL,
    StudentId                 VARCHAR(20)       NOT NULL,
    [Session]                 VARCHAR(15)       NOT NULL,
    FeeType                   VARCHAR(30)       NOT NULL,
    Amount                    DECIMAL(10,2)     NOT NULL,
    Status                    VARCHAR(10)       NOT NULL CONSTRAINT DF_Fees_Status DEFAULT 'Pending',
    PaymentDate               DATE              NULL,
    PaymentReceiptPath        VARCHAR(255)      NULL,
    PaymentReceiptUploadedAt  DATETIME          NULL,

    CONSTRAINT PK_Fees_PaymentId PRIMARY KEY (PaymentId),
    CONSTRAINT FK_Fees_Student FOREIGN KEY (StudentId) REFERENCES dbo.StudentDetails(StudentId),
    CONSTRAINT FK_Fees_Enrollment FOREIGN KEY (EnrollmentId) REFERENCES dbo.Enrollment(EnrollmentId),
    CONSTRAINT CK_Fees_Status CHECK (Status IN ('Paid', 'Pending', 'Overdue', 'Rejected', 'Approved'))
);
GO

CREATE UNIQUE INDEX IX_Fees_FeeId
ON dbo.Fees(FeeId)
WHERE FeeId IS NOT NULL;
GO

CREATE INDEX IX_Fees_Student_Session_Status
ON dbo.Fees(StudentId, [Session], Status);
GO

CREATE TRIGGER dbo.trg_Fees_SetFeeId
ON dbo.Fees
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE f
    SET f.FeeId = f.PaymentId
    FROM dbo.Fees f
    INNER JOIN inserted i
        ON f.PaymentId = i.PaymentId
    WHERE f.FeeId IS NULL;
END;
GO

/* =============================================================
   17. ANNOUNCEMENTS
   ============================================================= */
CREATE TABLE dbo.Announcements (
    AnnouncementId  INT IDENTITY(1,1) NOT NULL,
    Title           VARCHAR(200)      NOT NULL,
    Content         TEXT              NOT NULL,
    PostedByUserId  INT               NOT NULL,
    TargetRole      VARCHAR(20)       NOT NULL CONSTRAINT DF_Announcements_TargetRole DEFAULT 'All',
    ProgrammeId     INT               NULL,
    CourseId        INT               NULL,
    [Session]       VARCHAR(15)       NULL,
    CreatedAt       DATETIME          NOT NULL CONSTRAINT DF_Announcements_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_Announcements PRIMARY KEY (AnnouncementId),
    CONSTRAINT FK_Announcements_User FOREIGN KEY (PostedByUserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Announcements_Programme FOREIGN KEY (ProgrammeId) REFERENCES dbo.Programmes(ProgrammeId),
    CONSTRAINT FK_Announcements_Course FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT CK_Announcements_TargetRole CHECK (TargetRole IN ('All', 'Student', 'Lecturer'))
);
GO

/* =============================================================
   18. NOTIFICATIONS
   ============================================================= */
CREATE TABLE dbo.Notifications (
    NotificationId  INT IDENTITY(1,1) NOT NULL,
    UserId          INT               NOT NULL,
    Title           VARCHAR(200)      NOT NULL,
    Message         TEXT              NOT NULL,
    IsRead          BIT               NOT NULL CONSTRAINT DF_Notifications_IsRead DEFAULT 0,
    CreatedAt       DATETIME          NOT NULL CONSTRAINT DF_Notifications_CreatedAt DEFAULT GETDATE(),

    CONSTRAINT PK_Notifications PRIMARY KEY (NotificationId),
    CONSTRAINT FK_Notifications_User FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);
GO

/* =============================================================
   19. RESULTS
   Stores final semester results, GPA and CGPA.
   ============================================================= */
CREATE TABLE dbo.Results (
    ResultId      INT IDENTITY(1,1) NOT NULL,
    StudentId     VARCHAR(20)       NOT NULL,
    [Session]     VARCHAR(50)       NOT NULL,
    Semester      INT               NOT NULL,
    CourseId      INT               NOT NULL,
    FinalMark     DECIMAL(5,2)      NOT NULL,
    Grade         VARCHAR(5)        NOT NULL,
    GradePoint    DECIMAL(4,2)      NOT NULL,
    Credits       INT               NOT NULL,
    GPA           DECIMAL(4,2)      NOT NULL,
    CGPA          DECIMAL(4,2)      NOT NULL,
    ResultStatus  VARCHAR(20)       NOT NULL CONSTRAINT DF_Results_ResultStatus DEFAULT 'Published',
    PublishedAt   DATETIME          NOT NULL CONSTRAINT DF_Results_PublishedAt DEFAULT GETDATE(),

    CONSTRAINT PK_Results PRIMARY KEY (ResultId),
    CONSTRAINT FK_Results_Student FOREIGN KEY (StudentId) REFERENCES dbo.StudentDetails(StudentId),
    CONSTRAINT FK_Results_Course FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT CK_Results_Semester CHECK (Semester >= 1),
    CONSTRAINT CK_Results_ResultStatus CHECK (ResultStatus IN ('Published', 'Void')),
    CONSTRAINT UQ_Results_Student_Session_Semester_Course UNIQUE (StudentId, [Session], Semester, CourseId)
);

