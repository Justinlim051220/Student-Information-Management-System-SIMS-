
-- =============================================
-- SIMS - Student Information Management System
-- =============================================

CREATE DATABASE SIMS;


USE SIMS;


-- =============================================
-- TABLE 1: Users
-- Core login table for all roles
-- =============================================
CREATE TABLE Users (
    UserId      INT             NOT NULL IDENTITY(1,1),
    Email       VARCHAR(100)    NOT NULL,
    PasswordHash VARCHAR(255)   NOT NULL,
    Role        TINYINT         NOT NULL,   -- 1 = Admin, 2 = Lecturer, 3 = Student
    IsActive    BIT             NOT NULL DEFAULT 1,
    CreatedAt   DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Users PRIMARY KEY (UserId),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT CK_Users_Role CHECK (Role IN (1, 2, 3))
);

select * from Users;


-- =============================================
-- TABLE 2: HoPDetails
-- Head of Programme / Admin profile
-- =============================================
CREATE TABLE HoPDetails (
    HoPId       VARCHAR(20)     NOT NULL,
    UserId      INT             NOT NULL,
    FirstName   VARCHAR(50)     NOT NULL,
    LastName    VARCHAR(50)     NOT NULL,
    Phone       VARCHAR(20)     NULL,
    Department  VARCHAR(100)    NULL,

    CONSTRAINT PK_HoPDetails PRIMARY KEY (HoPId),
    CONSTRAINT FK_HoPDetails_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

-- New Aded for Credit Hour, 29/5, Justin

IF COL_LENGTH('HoPDetails', 'ProfilePicture') IS NULL
BEGIN
    ALTER TABLE HoPDetails
    ADD ProfilePicture VARCHAR(255) NULL;
END;

-- =============================================
-- TABLE 3: Programmes
-- Academic programmes managed by HoP
-- =============================================
CREATE TABLE Programmes (
    ProgrammeId     INT             NOT NULL IDENTITY(1,1),
    ProgrammeName   VARCHAR(100)    NOT NULL,
    ProgrammeCode   VARCHAR(20)     NOT NULL,
    Duration        INT             NOT NULL,   -- In years
    Description     TEXT            NULL,
    HoPId           VARCHAR(20)     NOT NULL,

    CONSTRAINT PK_Programmes PRIMARY KEY (ProgrammeId),
    CONSTRAINT UQ_Programmes_Code UNIQUE (ProgrammeCode),
    CONSTRAINT FK_Programmes_HoP FOREIGN KEY (HoPId) REFERENCES HoPDetails(HoPId)
);

select * from Programmes;


-- New Aded for Credit Hour, 29/5, Justin

IF COL_LENGTH('Programmes', 'CreditHour') IS NULL
BEGIN
    ALTER TABLE Programmes
    ADD CreditHour INT NOT NULL CONSTRAINT DF_Programmes_CreditHour DEFAULT (0);
END;


-- =============================================
-- TABLE 4: LecturerDetails
-- Lecturer profile
-- =============================================
CREATE TABLE LecturerDetails (
    LecturerId      VARCHAR(20)     NOT NULL,
    UserId          INT             NOT NULL,
    FirstName       VARCHAR(50)     NOT NULL,
    LastName        VARCHAR(50)     NOT NULL,
    Gender          VARCHAR(10)     NULL,
    Phone           VARCHAR(20)     NULL,
    Specialization  VARCHAR(500)    NULL,
    JoinDate        DATE            NULL,
    ProgrammeId     INT             NULL,
    ProfilePicture VARCHAR(255) NULL,

    CONSTRAINT PK_LecturerDetails PRIMARY KEY (LecturerId),

    CONSTRAINT FK_LecturerDetails_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),

    CONSTRAINT FK_LecturerDetails_Programme FOREIGN KEY (ProgrammeId) REFERENCES Programmes(ProgrammeId)
);


select * from LecturerDetails;

-- =============================================
-- TABLE 5: StudentDetails
-- Student profile
-- =============================================
CREATE TABLE StudentDetails (
    StudentId       VARCHAR(20)     NOT NULL,
    UserId          INT             NOT NULL,
    FirstName       VARCHAR(50)     NOT NULL,
    LastName        VARCHAR(50)     NOT NULL,
    DateOfBirth     DATE            NULL,
    Gender          VARCHAR(10)     NULL,
    Phone           VARCHAR(20)     NULL,
    Address         TEXT            NULL,
    ProfilePicture  VARCHAR(255)    NULL,
    EnrollmentDate  DATE            NULL,
    ProgrammeId     INT             NOT NULL,

    CONSTRAINT PK_StudentDetails PRIMARY KEY (StudentId),
    CONSTRAINT FK_StudentDetails_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_StudentDetails_Programme FOREIGN KEY (ProgrammeId) REFERENCES Programmes(ProgrammeId)
);

--New added 29/5 - For Student Portal Enrollment side
IF COL_LENGTH('StudentDetails', 'CurrentSemester') IS NULL
BEGIN
    ALTER TABLE StudentDetails
    ADD CurrentSemester INT NOT NULL CONSTRAINT DF_StudentDetails_CurrentSemester DEFAULT 1;
END;
GO

/* 2. Safety check for semester value. */
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_StudentDetails_CurrentSemester'
)
BEGIN
    ALTER TABLE StudentDetails
    ADD CONSTRAINT CK_StudentDetails_CurrentSemester CHECK (CurrentSemester >= 1);
END;

-- =============================================
-- TABLE 6: Courses
-- Courses under a programme
-- =============================================
CREATE TABLE Courses (
    CourseId        INT             NOT NULL IDENTITY(1,1),
    CourseCode      VARCHAR(20)     NOT NULL,
    CourseName      VARCHAR(100)    NOT NULL,
    Credits         INT             NOT NULL,
    ProgrammeId     INT             NOT NULL,
    Description     TEXT            NULL,

    CONSTRAINT PK_Courses PRIMARY KEY (CourseId),
    CONSTRAINT UQ_Courses_Code UNIQUE (CourseCode),
    CONSTRAINT FK_Courses_Programme FOREIGN KEY (ProgrammeId) REFERENCES Programmes(ProgrammeId)
);

-- New Added Table for Course Materails, By Jason 30/5 

CREATE TABLE CourseMaterials (
    MaterialId INT IDENTITY(1,1) NOT NULL,
    CourseId INT NOT NULL,
    Session VARCHAR(15) NOT NULL,
    LecturerId VARCHAR(20) NOT NULL,
    Title VARCHAR(200) NOT NULL,
    MaterialType VARCHAR(50) NULL, 
    Description VARCHAR(MAX) NULL,
    FileName VARCHAR(255) NOT NULL,
    FilePath VARCHAR(500) NOT NULL,
    FileType VARCHAR(100) NULL,
    FileSizeKB INT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_CourseMaterials PRIMARY KEY (MaterialId),
    CONSTRAINT FK_CourseMaterials_Course FOREIGN KEY (CourseId) REFERENCES Courses(CourseId),
    CONSTRAINT FK_CourseMaterials_Lecturer FOREIGN KEY (LecturerId) REFERENCES LecturerDetails(LecturerId)
);

ALTER TABLE CourseMaterials ALTER COLUMN FileName VARCHAR(255) NULL;
ALTER TABLE CourseMaterials ALTER COLUMN FilePath VARCHAR(500) NULL;
ALTER TABLE CourseMaterials ALTER COLUMN FileType VARCHAR(100) NULL;
ALTER TABLE CourseMaterials ALTER COLUMN FileSizeKB INT NULL;

CREATE TABLE CourseMaterialFiles (
    FileId INT IDENTITY(1,1) NOT NULL,
    MaterialId INT NOT NULL,
    FileName VARCHAR(255) NOT NULL,
    FilePath VARCHAR(500) NOT NULL,
    FileType VARCHAR(100) NULL,
    FileSizeKB INT NULL,
    UploadedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_CourseMaterialFiles PRIMARY KEY (FileId),
    CONSTRAINT FK_CourseMaterialFiles_Material 
        FOREIGN KEY (MaterialId) REFERENCES CourseMaterials(MaterialId)
        ON DELETE CASCADE
);
---

-- =============================================
-- TABLE 7: Enrollment
-- Student enrolment per course per session
-- Composite PK: StudentId + CourseId + Session
-- =============================================
CREATE TABLE Enrollment (
    StudentId       VARCHAR(20)     NOT NULL,
    CourseId        INT             NOT NULL,
    Session         VARCHAR(15)     NOT NULL,   -- 'April 2026' / 'August 2026'
    Semester        INT             NOT NULL DEFAULT 1,
    Status          VARCHAR(20)     NOT NULL DEFAULT 'Active',
    EnrollmentDate  DATE            NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Enrollment PRIMARY KEY (StudentId, CourseId, Session),
    CONSTRAINT FK_Enrollment_Student FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    CONSTRAINT FK_Enrollment_Course FOREIGN KEY (CourseId) REFERENCES Courses(CourseId),
    CONSTRAINT CK_Enrollment_Status CHECK (Status IN ('Active', 'Dropped', 'Completed')),
    CONSTRAINT CK_Enrollment_Semester CHECK (Semester >= 1)
);

--New added Alter Table Enrollment, 31/5 By Justin

/* =========================================================
   UPDATE ENROLLMENT STATUS FOR DROP REQUEST FLOW
   ========================================================= */

-- 1. Drop old CHECK constraint
ALTER TABLE Enrollment
DROP CONSTRAINT CK_Enrollment_Status;

-- 2. Add new CHECK constraint with drop request statuses
ALTER TABLE Enrollment
ADD CONSTRAINT CK_Enrollment_Status
CHECK (Status IN (
    'Enrollment Pending',
    'Enrollment Rejected',
    'Active',
    'Drop Pending',
    'Drop Rejected',
    'Dropped',
    'Completed'
));

-- 3. Add drop request tracking columns
ALTER TABLE Enrollment
ADD
    DropReason VARCHAR(255) NULL,
    DropRequestedAt DATETIME NULL,
    DropReviewedAt DATETIME NULL,
    DropReviewedBy VARCHAR(20) NULL;
----------------------------------------------

select * from Enrollment;

-- =============================================
-- TABLE 8: LecturerCourse
-- Assign lecturer to teach a course per session
-- Composite PK: LecturerId + CourseId + Session
-- =============================================
CREATE TABLE LecturerCourse (
    LecturerId      VARCHAR(20)     NOT NULL,
    CourseId        INT             NOT NULL,
    Session         VARCHAR(15)     NOT NULL,   -- 'April 2026' / 'August 2026'
    Semester        INT             NOT NULL,
    AssignedDate    DATE            NOT NULL DEFAULT GETDATE(),
    SortOrder INT NULL;

    CONSTRAINT PK_LecturerCourse PRIMARY KEY (LecturerId, CourseId, Session),
    CONSTRAINT FK_LecturerCourse_Lecturer FOREIGN KEY (LecturerId) REFERENCES LecturerDetails(LecturerId),
    CONSTRAINT FK_LecturerCourse_Course FOREIGN KEY (CourseId) REFERENCES Courses(CourseId)
);

-- =============================================
-- TABLE 9: Attendance
-- Per student per course per date
-- Composite PK: CourseId + AttendanceDate + StudentId
-- =============================================
CREATE TABLE Attendance (
    CourseId        INT             NOT NULL,
    AttendanceDate  DATE            NOT NULL,
    StudentId       VARCHAR(20)     NOT NULL,
    LecturerId      VARCHAR(20)     NOT NULL,
    Session         VARCHAR(15)     NOT NULL,
    Status          VARCHAR(10)     NOT NULL DEFAULT 'Present',

    CONSTRAINT PK_Attendance PRIMARY KEY (CourseId, AttendanceDate, StudentId, Session),
    CONSTRAINT FK_Attendance_Course FOREIGN KEY (CourseId) REFERENCES Courses(CourseId),
    CONSTRAINT FK_Attendance_Student FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    CONSTRAINT FK_Attendance_Lecturer FOREIGN KEY (LecturerId) REFERENCES LecturerDetails(LecturerId),
    CONSTRAINT CK_Attendance_Status CHECK (Status IN ('Present', 'Absent', 'Late'))
);

--New added by Yin jia - 31/5
-- =============================================
-- TABLE 10: Grades
-- Assessment marks per student per course
-- Composite PK: StudentId + CourseId + Type
-- =============================================
CREATE TABLE Grades (
    StudentId           VARCHAR(20)     NOT NULL,
    CourseId            INT             NOT NULL,
    MaterialId          INT             NOT NULL DEFAULT 0,
    Type                VARCHAR(20)     NOT NULL,
    Title               VARCHAR(100)    NOT NULL,
    MaxMarks            DECIMAL(5,2)    NOT NULL,
    MarksObtained       DECIMAL(5,2)    NULL,
    DraftMarksObtained  DECIMAL(5,2)     NULL,
    WeightPercentage    DECIMAL(5,2)    NULL,
    Grade               VARCHAR(5)      NULL,
    DueDate             DATE            NULL,
    Remarks             TEXT            NULL,
    SubmittedAt         DATETIME        NULL,

    CONSTRAINT PK_Grades
        PRIMARY KEY (StudentId, CourseId, Type, MaterialId),

    CONSTRAINT FK_Grades_Student
        FOREIGN KEY (StudentId)
        REFERENCES StudentDetails(StudentId),

    CONSTRAINT FK_Grades_Course
        FOREIGN KEY (CourseId)
        REFERENCES Courses(CourseId),

    CONSTRAINT CK_Grades_Type
        CHECK (Type IN ('Assignment', 'Quiz', 'Exam'))
);

select * from Grades;

-- =============================================
-- TABLE 11: Fees
-- Fee record per student per session
-- Composite PK: StudentId + Session + FeeType
-- =============================================
CREATE TABLE Fees (
    StudentId       VARCHAR(20)     NOT NULL,
    Session         VARCHAR(15)     NOT NULL,
    FeeType         VARCHAR(30)     NOT NULL,   -- 'Tuition', 'Registration'
    Amount          DECIMAL(10,2)   NOT NULL,
    Status          VARCHAR(10)     NOT NULL DEFAULT 'Pending',
    PaymentDate     DATE            NULL,

    CONSTRAINT PK_Fees PRIMARY KEY (StudentId, Session, FeeType),
    CONSTRAINT FK_Fees_Student FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    CONSTRAINT CK_Fees_Status CHECK (Status IN ('Paid', 'Pending', 'Overdue'))
);


-- =============================================
-- TABLE 12: Announcements
-- Posted by Admin or Lecturer
-- =============================================
CREATE TABLE Announcements (
    AnnouncementId  INT             NOT NULL IDENTITY(1,1),
    Title           VARCHAR(200)    NOT NULL,
    Content         TEXT            NOT NULL,
    PostedByUserId  INT             NOT NULL,
    TargetRole      VARCHAR(20)     NOT NULL DEFAULT 'All',
    ProgrammeId     INT             NULL,
    CourseId        INT             NULL,   -- NULL means global announcement
    Session         VARCHAR(15)             NULL,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Announcements PRIMARY KEY (AnnouncementId),
    CONSTRAINT FK_Announcements_User FOREIGN KEY (PostedByUserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Announcements_Programme FOREIGN KEY (ProgrammeId) REFERENCES Programmes(ProgrammeId),
    CONSTRAINT FK_Announcements_Course FOREIGN KEY (CourseId) REFERENCES Courses(CourseId),
    CONSTRAINT CK_Announcements_TargetRole CHECK (TargetRole IN ('All', 'Student', 'Lecturer'))
);

select * from Announcements;

-- =============================================
-- TABLE 13: Notifications
-- Per user notification inbox
-- =============================================
CREATE TABLE Notifications (
    NotificationId  INT             NOT NULL IDENTITY(1,1),
    UserId          INT             NOT NULL,
    Title           VARCHAR(200)    NOT NULL,
    Message         TEXT            NOT NULL,
    IsRead          BIT             NOT NULL DEFAULT 0,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Notifications PRIMARY KEY (NotificationId),
    CONSTRAINT FK_Notifications_User FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

CREATE TABLE CourseFees (
        CourseFeeId INT NOT NULL IDENTITY(1,1),
        CourseId INT NOT NULL,
        Session VARCHAR(15) NOT NULL,
        Amount DECIMAL(10,2) NOT NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_CourseFees PRIMARY KEY (CourseFeeId),
        CONSTRAINT UQ_CourseFees_Course_Session UNIQUE (CourseId, Session),
        CONSTRAINT FK_CourseFees_Course FOREIGN KEY (CourseId) REFERENCES Courses(CourseId),
        CONSTRAINT CK_CourseFees_Amount CHECK (Amount >= 0)
    );

   /* =========================================================
   SIMS PATCH: Allow one lecturer to belong to multiple programmes
   Run this ONCE after your existing SIMS database is created.
   ========================================================= */


GO

/* 1. Junction table: one lecturer can have many programmes */
IF OBJECT_ID('dbo.LecturerProgramme', 'U') IS NULL
BEGIN
    CREATE TABLE LecturerProgramme (
        LecturerId  VARCHAR(20) NOT NULL,
        ProgrammeId INT         NOT NULL,
        AssignedDate DATE       NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_LecturerProgramme PRIMARY KEY (LecturerId, ProgrammeId),
        CONSTRAINT FK_LecturerProgramme_Lecturer
            FOREIGN KEY (LecturerId) REFERENCES LecturerDetails(LecturerId),
        CONSTRAINT FK_LecturerProgramme_Programme
            FOREIGN KEY (ProgrammeId) REFERENCES Programmes(ProgrammeId)
    );
END
GO

/* 2. Migrate existing LecturerDetails.ProgrammeId data into the new table */
INSERT INTO LecturerProgramme (LecturerId, ProgrammeId)
SELECT LecturerId, ProgrammeId
FROM LecturerDetails ld
WHERE ld.ProgrammeId IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM LecturerProgramme lp
      WHERE lp.LecturerId = ld.LecturerId
        AND lp.ProgrammeId = ld.ProgrammeId
  );

  /* =============================================================
   SIMS Enrollment + Fees Patch
   Use CourseFees as price master.
   Use Fees as student invoice/payment status.
   CourseFees does NOT need Status.
   ============================================================= */

  IF OBJECT_ID('CourseFees', 'U') IS NULL
BEGIN
    CREATE TABLE CourseFees (
        CourseFeeId INT NOT NULL IDENTITY(1,1),
        CourseId INT NOT NULL,
        Session VARCHAR(15) NOT NULL,
        Amount DECIMAL(10,2) NOT NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_CourseFees PRIMARY KEY (CourseFeeId),
        CONSTRAINT UQ_CourseFees_Course_Session UNIQUE (CourseId, Session),
        CONSTRAINT FK_CourseFees_Course FOREIGN KEY (CourseId) REFERENCES Courses(CourseId),
        CONSTRAINT CK_CourseFees_Amount CHECK (Amount >= 0)
    );
END;
GO

/* Your ManageFees page has Reject button, so Fees.Status needs Rejected. */
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Fees_Status')
BEGIN
    ALTER TABLE Fees DROP CONSTRAINT CK_Fees_Status;
END;
GO

ALTER TABLE Fees ADD CONSTRAINT CK_Fees_Status
CHECK (Status IN ('Paid', 'Pending', 'Overdue', 'Rejected'));
GO

Select * from Users;
select * from HopDetails;
select * from Programmes;

--New Added in 29/5 for Session Enrollment
-- =========================================================
-- SIMS SQL Patch: Course Offering
-- Purpose: Admin controls which course is open for which
--          session, programme and semester.
-- =========================================================

IF OBJECT_ID('dbo.CourseOffering', 'U') IS NULL
BEGIN
    CREATE TABLE CourseOffering (
        OfferingId   INT IDENTITY(1,1) NOT NULL,
        Session      VARCHAR(15)       NOT NULL,
        ProgrammeId  INT               NOT NULL,
        CourseId     INT               NOT NULL,
        Semester     INT               NOT NULL,
        Status       VARCHAR(20)       NOT NULL DEFAULT 'Closed',
        CreatedDate  DATE              NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_CourseOffering PRIMARY KEY (OfferingId),
        CONSTRAINT FK_CourseOffering_Programme FOREIGN KEY (ProgrammeId) REFERENCES Programmes(ProgrammeId),
        CONSTRAINT FK_CourseOffering_Course FOREIGN KEY (CourseId) REFERENCES Courses(CourseId),
        CONSTRAINT CK_CourseOffering_Status CHECK (Status IN ('Open', 'Closed')),
        CONSTRAINT CK_CourseOffering_Semester CHECK (Semester >= 1),
        CONSTRAINT UQ_CourseOffering UNIQUE (Session, ProgrammeId, CourseId, Semester)
    );
END;
