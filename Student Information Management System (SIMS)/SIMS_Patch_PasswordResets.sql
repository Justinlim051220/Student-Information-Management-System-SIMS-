-- =============================================
-- SIMS — SQL Patch: Add PasswordResets table
-- Run this in SSMS after creating the main
-- SIMS database from SIMS.sql
-- =============================================

USE SIMS;
GO

-- =============================================
-- TABLE 14: PasswordResets
-- Stores secure tokens for password reset emails.
-- One active token per email at a time.
-- =============================================
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'PasswordResets'
)
BEGIN
    CREATE TABLE PasswordResets (
        ResetId    INT          NOT NULL IDENTITY(1,1),
        Email      VARCHAR(100) NOT NULL,
        Token      VARCHAR(300) NOT NULL,
        ExpiresAt  DATETIME     NOT NULL,
        IsUsed     BIT          NOT NULL DEFAULT 0,
        CreatedAt  DATETIME     NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_PasswordResets  PRIMARY KEY (ResetId),
        CONSTRAINT UQ_PasswordResets_Token UNIQUE (Token)
    );

    -- Index to speed up email lookups
    CREATE INDEX IX_PasswordResets_Email ON PasswordResets (Email);

    PRINT 'PasswordResets table created successfully.';
END
ELSE
BEGIN
    PRINT 'PasswordResets table already exists — skipping.';
END
GO


-- =============================================
-- OPTIONAL: Seed one Admin user for testing
-- Password below is: Admin@1234
-- (hashed with PasswordHelper.HashPassword)
-- Replace the PasswordHash with one generated
-- by your running app, or use this placeholder
-- and reset via Forgot Password.
-- =============================================

/*
-- Uncomment to insert a test Admin account:

INSERT INTO Users (Email, PasswordHash, Role, IsActive)
VALUES ('admin@onti.edu.my', 'REPLACE_WITH_REAL_HASH', 1, 1);

DECLARE @uid INT = SCOPE_IDENTITY();

INSERT INTO HoPDetails (HoPId, UserId, FirstName, LastName, Department)
VALUES ('HOP001', @uid, 'Admin', 'User', 'Computer Science');
*/