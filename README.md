# PROG6212-POE

# RaceDay - Database Schema & Seeding Documentation

This directory contains the complete T-SQL script (`RaceDay_Schema.sql`) to generate and seed the database for **RaceDay**, a full-stack event management system tailored for the South African road running, walking, and cycling community.

---

## Relational Database Schema Overview

The database contains **six core entities** designed to enforce strict data integrity, foreign key cascading rules, check constraints, and role-based access.

### Entity Definitions & Key Constraints

1. **`Roles`**
   * **`RoleID`** (`INT`, Primary Key, Auto-Increment)
   * **`RoleName`** (`VARCHAR(50)`, Unique, Not Null) — Limits system access (`Organiser`, `Participant`).

2. **`Users`**
   * **`UserID`** (`INT`, Primary Key, Auto-Increment)
   * **`RoleID`** (`INT`, Foreign Key $\rightarrow$ `Roles(RoleID)`)
   * **`FirstName`**, **`LastName`** (`VARCHAR(50)`, Not Null)
   * **`Email`** (`VARCHAR(100)`, Unique, Not Null)
   * **`PasswordHash`** (`VARCHAR(255)`, Not Null)
   * **`PhoneNumber`** (`VARCHAR(20)`, Nullable)
   * **`CreatedAt`** (`DATETIME`, Default: Current Timestamp)

3. **`Events`**
   * **`EventID`** (`INT`, Primary Key, Auto-Increment)
   * **`OrganiserID`** (`INT`, Foreign Key $\rightarrow$ `Users(UserID)`)
   * **`EventName`** (`VARCHAR(150)`, Not Null)
   * **`Description`** (`VARCHAR(MAX)`, Nullable)
   * **`Location`** (`VARCHAR(150)`, Not Null)
   * **`EventDate`** (`DATETIME`, Not Null)
   * **`CreatedAt`** (`DATETIME`, Default: Current Timestamp)

4. **`Categories`**
   * **`CategoryID`** (`INT`, Primary Key, Auto-Increment)
   * **`EventID`** (`INT`, Foreign Key $\rightarrow$ `Events(EventID)` ON DELETE CASCADE)
   * **`CategoryName`** (`VARCHAR(100)`, Not Null)
   * **`DistanceKM`** (`DECIMAL(5,2)`, Check: `DistanceKM > 0`)
   * **`EntryFee`** (`DECIMAL(10,2)`, Check: `EntryFee >= 0`)
   * **`MaxParticipants`** (`INT`, Check: `MaxParticipants > 0`)

5. **`Enrolments`**
   * **`EnrolmentID`** (`INT`, Primary Key, Auto-Increment)
   * **`ParticipantID`** (`INT`, Foreign Key $\rightarrow$ `Users(UserID)`)
   * **`CategoryID`** (`INT`, Foreign Key $\rightarrow$ `Categories(CategoryID)` ON DELETE CASCADE)
   * **`EnrolmentDate`** (`DATETIME`, Default: Current Timestamp)
   * **`PaymentStatus`** (`VARCHAR(20)`, Default: `'Pending'`, Check: `'Paid'`, `'Pending'`, `'Cancelled'`)
   * **`RaceNumber`** (`INT`, Nullable)
   * **Composite Constraint**: `UNIQUE(ParticipantID, CategoryID)` to prevent double entries.

6. **`Results`**
   * **`ResultID`** (`INT`, Primary Key, Auto-Increment)
   * **`EnrolmentID`** (`INT`, Unique Foreign Key $\rightarrow$ `Enrolments(EnrolmentID)` ON DELETE CASCADE)
   * **`FinishTime`** (`TIME`, Nullable)
   * **`OverallPosition`**, **`CategoryPosition`** (`INT`, Nullable)
   * **`Status`** (`VARCHAR(20)`, Default: `'Finished'`, Check: `'Finished'`, `'DNF'`, `'DNS'`, `'DQ'`)

---

## Prerequisites & Setup

- **Database Engine:** Microsoft SQL Server 2019+ or Azure SQL Database
- **GUI Tool:** SQL Server Management Studio (SSMS) or Azure Data Studio

---

## Execution Instructions

1. Open **SQL Server Management Studio (SSMS)** and connect to your SQL instance.
2. Navigate to `File` > `Open` > `File...` and open `RaceDay_Schema.sql`.
3. Click **Execute** (or press `F5`).

The script automatically executes the following workflow cleanly:
* Checks if `RaceDayDB` exists and creates it.
* Drops existing tables in reverse dependency order (allowing repeatable, error-free runs).
* Creates all 6 tables alongside their `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, and `DEFAULT` constraints.
* Seeds the database with realistic initial sample data.

---

## Seed Data Verification

After running the script, verify that data was successfully populated across all entities by running:

```sql
USE RaceDayDB;
GO

-- Summary Count Check
SELECT 'Roles' AS Entity, COUNT(*) AS TotalRecords FROM dbo.Roles
UNION ALL
SELECT 'Users', COUNT(*) FROM dbo.Users
UNION ALL
SELECT 'Events', COUNT(*) FROM dbo.Events
UNION ALL
SELECT 'Categories', COUNT(*) FROM dbo.Categories
UNION ALL
SELECT 'Enrolments', COUNT(*) FROM dbo.Enrolments
UNION ALL
SELECT 'Results', COUNT(*) FROM dbo.Results;
