IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'RaceDayDB')
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

-- ----------------------------------------------------------------------------
-- Drop Tables if they exist (Enforces clean re-runs)
-- ----------------------------------------------------------------------------
IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL DROP TABLE dbo.Enrolments;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
GO

-- ----------------------------------------------------------------------------
-- Table 1: Roles
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Roles (
    RoleID INT IDENTITY(1,1) NOT NULL,
    RoleName VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Roles PRIMARY KEY (RoleID),
    CONSTRAINT UQ_Roles_RoleName UNIQUE (RoleName)
);

-- ----------------------------------------------------------------------------
-- Table 2: Users
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Users (
    UserID INT IDENTITY(1,1) NOT NULL,
    RoleID INT NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(20) NULL,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT GETDATE(),
    CONSTRAINT PK_Users PRIMARY KEY (UserID),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleID) REFERENCES dbo.Roles(RoleID) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- Table 3: Events
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Events (
    EventID INT IDENTITY(1,1) NOT NULL,
    OrganiserID INT NOT NULL,
    EventName VARCHAR(150) NOT NULL,
    Description VARCHAR(MAX) NULL,
    Location VARCHAR(150) NOT NULL,
    EventDate DATETIME NOT NULL,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Events_CreatedAt DEFAULT GETDATE(),
    CONSTRAINT PK_Events PRIMARY KEY (EventID),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserID) REFERENCES dbo.Users(UserID)
);

-- ----------------------------------------------------------------------------
-- Table 4: Categories
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Categories (
    CategoryID INT IDENTITY(1,1) NOT NULL,
    EventID INT NOT NULL,
    CategoryName VARCHAR(100) NOT NULL,
    DistanceKM DECIMAL(5,2) NOT NULL,
    EntryFee DECIMAL(10,2) NOT NULL,
    MaxParticipants INT NOT NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventID) REFERENCES dbo.Events(EventID) ON DELETE CASCADE,
    CONSTRAINT CK_Categories_Distance CHECK (DistanceKM > 0),
    CONSTRAINT CK_Categories_Fee CHECK (EntryFee >= 0),
    CONSTRAINT CK_Categories_MaxPart CHECK (MaxParticipants > 0)
);

-- ----------------------------------------------------------------------------
-- Table 5: Enrolments
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Enrolments (
    EnrolmentID INT IDENTITY(1,1) NOT NULL,
    ParticipantID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME NOT NULL CONSTRAINT DF_Enrolments_EnrolmentDate DEFAULT GETDATE(),
    PaymentStatus VARCHAR(20) NOT NULL CONSTRAINT DF_Enrolments_PaymentStatus DEFAULT 'Pending',
    RaceNumber INT NULL,
    CONSTRAINT PK_Enrolments PRIMARY KEY (EnrolmentID),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (ParticipantID) REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID) ON DELETE CASCADE,
    CONSTRAINT UQ_Participant_Category UNIQUE (ParticipantID, CategoryID),
    CONSTRAINT CK_Enrolments_PaymentStatus CHECK (PaymentStatus IN ('Paid', 'Pending', 'Cancelled'))
);

-- ----------------------------------------------------------------------------
-- Table 6: Results
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.Results (
    ResultID INT IDENTITY(1,1) NOT NULL,
    EnrolmentID INT NOT NULL,
    FinishTime TIME NULL,
    OverallPosition INT NULL,
    CategoryPosition INT NULL,
    Status VARCHAR(20) NOT NULL CONSTRAINT DF_Results_Status DEFAULT 'Finished',
    CONSTRAINT PK_Results PRIMARY KEY (ResultID),
    CONSTRAINT UQ_Results_EnrolmentID UNIQUE (EnrolmentID),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentID) REFERENCES dbo.Enrolments(EnrolmentID) ON DELETE CASCADE,
    CONSTRAINT CK_Results_Status CHECK (Status IN ('Finished', 'DNF', 'DNS', 'DQ'))
);
GO

-- ============================================================================
-- Seed Sample Data
-- ============================================================================

-- 1. Insert Roles
INSERT INTO dbo.Roles (RoleName) VALUES 
('Organiser'),
('Participant');

-- 2. Insert Users (2 Organisers, 2 Participants)
-- Password hashes represent placeholder hashed values
INSERT INTO dbo.Users (RoleID, FirstName, LastName, Email, PasswordHash, PhoneNumber) VALUES
(1, 'Sipho', 'Nkosi', 'sipho.nkosi@raceevents.co.za', 'AQAAAAEAACcQAAAAEHhashedpass1...', '0821112223'),
(1, 'Anika', 'Van Zyl', 'anika@capesports.co.za', 'AQAAAAEAACcQAAAAEHhashedpass2...', '0834445556'),
(2, 'Thabo', 'Mokoena', 'thabo.m@gmail.com', 'AQAAAAEAACcQAAAAEHhashedpass3...', '0717778889'),
(2, 'Sarah', 'Jenkins', 'sarah.j@yahoo.com', 'AQAAAAEAACcQAAAAEHhashedpass4...', '0790001112');

-- 3. Insert Events (3 Events)
INSERT INTO dbo.Events (OrganiserID, EventName, Description, Location, EventDate) VALUES
(1, 'Soweto Marathon 2026', 'The iconic race through historic Soweto landmarks.', 'Soweto, Johannesburg', '2026-11-01 06:00:00'),
(2, 'Cape Town Cycle Tour 2027', 'World famous road cycling event around the Cape Peninsula.', 'Cape Town, Western Cape', '2027-03-14 06:30:00'),
(1, 'Durban Promenade Fun Run', 'Family-friendly coastal run along the Durban beachfront.', 'Durban, KwaZulu-Natal', '2026-10-15 07:00:00');

-- 4. Insert Categories
INSERT INTO dbo.Categories (EventID, CategoryName, DistanceKM, EntryFee, MaxParticipants) VALUES
-- Soweto Marathon Categories
(1, '42.2km Full Marathon', 42.20, 350.00, 10000),
(1, '21.1km Half Marathon', 21.10, 250.00, 15000),
(1, '10km Open Run', 10.00, 150.00, 8000),
-- Cape Town Cycle Tour Categories
(2, '109km Main Race', 109.00, 650.00, 30000),
(2, '42km Short Route', 42.00, 400.00, 5000),
-- Durban Promenade Categories
(3, '10km Timed Run', 10.00, 120.00, 2000),
(3, '5km Fun Walk', 5.00, 80.00, 3000);

-- 5. Insert Enrolments
INSERT INTO dbo.Enrolments (ParticipantID, CategoryID, PaymentStatus, RaceNumber) VALUES
(3, 1, 'Paid', 1001), -- Thabo enrolled in Soweto Full Marathon
(4, 2, 'Paid', 5042), -- Sarah enrolled in Soweto Half Marathon
(3, 4, 'Paid', 1209), -- Thabo enrolled in Cape Town Cycle 109km
(4, 6, 'Pending', NULL); -- Sarah enrolled in Durban 10km

-- 6. Insert Results
INSERT INTO dbo.Results (EnrolmentID, FinishTime, OverallPosition, CategoryPosition, Status) VALUES
(1, '03:15:42', 142, 28, 'Finished'),
(2, '01:45:10', 310, 45, 'Finished');
GO


USE RaceDayDB;
GO

SELECT * FROM dbo.Roles;
SELECT * FROM dbo.Users;
SELECT * FROM dbo.Events;
SELECT * FROM dbo.Categories;
SELECT * FROM dbo.Enrolments;
SELECT * FROM dbo.Results;