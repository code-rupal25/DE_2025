/**
Source File / Source System
        ↓
Staging Table (raw / landing) // DWH OLTP(sources).  >  OLAP (mutiple database) DWH 
  (stg)                       // SQL Database. 
                              // FILE > as is > RAW / LANDING || <stg>
        ↓
Transform + Compare
        ↓
Target Table (EmployeeDetails) -- dev
        ├── INSERT (new employees)
        └── UPDATE (changed employees)
**/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC ('CREATE SCHEMA stg');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dev')
BEGIN
    EXEC ('CREATE SCHEMA dev');
END;
GO



-- STAGING TABLE
SELECT * INTO stg.EmployeeDetails
FROM dbo.EmployeeDetails
WHERE 1=0 -- NO FILTER

-- DROP TABLE stg.EmployeeDetails

-- SELECT CURRENT_TIMESTAMP,MONTH(GETDATE())


SELECT * FROM stg.EmployeeDetails
-- DROP TABLe stg.EmployeeDetails
-- TARGET TABLE
------ CDC 1st
SELECT *,
CURRENT_TIMESTAMP as 'Creation_Date' -- 
INTO stg.EmployeeDetails  -- Table Define (structure query)
FROM dbo.EmployeeDetails
WHERE 1=0 --

-- > DBO. SOURCE > REMOVE CONSTRAINT ADDED VARCHAR 
-- > STG > DBO.EM + CREATION_DATE
-- > DEV (WE DEFINE DATA TYPE CONSTRAINT)

-- Daily run
INSERT INTO stg.EmployeeDetails
(
    EmployeeID,
    EmpCode,
    FirstName,
    LastName,
    Gender,
    Department,
    Designation,
    Salary,
    Bonus,
    ManagerID,
    HireDate,
    [Location],
    [Status],
    Creation_Date
)
SELECT 
    EmployeeID,
    EmpCode,
    FirstName,
    LastName,
    Gender,
    Department,
    Designation,
    Salary,
    Bonus,
    ManagerID,
    HireDate,
    [Location],
    [Status],
CURRENT_TIMESTAMP as 'Creation_Date' 
FROM dbo.EmployeeDetails;

-- writing basic data sanity checks

SELECT DISTINCT EmpCode,* FROM stg.EmployeeDetails


-- Null business key check
SELECT *
FROM stg.EmployeeDetails
WHERE EmpCode IS NULL;

-- Duplicate business key check

SELECT EmpCode, COUNT(*)
FROM stg.EmployeeDetails
GROUP BY EmpCode
HAVING COUNT(*) > 1


DELETE FROM stg.EmployeeDetails
WHERE 
(
SELECT ROW_NUMBER() OVER(PARTITION BY EmpCode ORDER BY Creation_Date DESC) RNK,
* FROM stg.EmployeeDetails
)AA
WHERE RNK = 1

-- writing data cleaning activity
-- duplicate, null check, etc (cleaining activty)

WITH Deduped AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY EmpCode
               ORDER BY Creation_Date DESC
           ) AS rn
    FROM stg.EmployeeDetails
)
DELETE
FROM Deduped
WHERE rn > 1;

SELECT COUNT(*) FROM stg.EmployeeDetails
-- UPSERT LOGIC FROM STG --> TARGET


INSERT INTO dev.EmployeeDetails
(
    EmployeeID,
    EmpCode,
    FirstName,
    LastName,
    Gender,
    Department,
    Designation,
    Salary,
    Bonus,
    ManagerID,
    HireDate,
    [Location],
    [Status],
    Creation_Date
)
SELECT
    s.EmployeeID,
    s.EmpCode,
    s.FirstName,
    s.LastName,
    s.Gender,
    s.Department,
    s.Designation,
    s.Salary,
    s.Bonus,
    s.ManagerID,
    s.HireDate,
    s.[Location],
    s.[Status],
    CURRENT_TIMESTAMP
FROM stg.EmployeeDetails s
LEFT JOIN dev.EmployeeDetails t
    ON s.EmpCode = t.EmpCode
WHERE t.EmpCode IS NULL;

-- UPDATE
UPDATE t
SET
    t.FirstName   = s.FirstName,
    t.LastName    = s.LastName,
    t.Gender      = s.Gender,
    t.Department  = s.Department,
    t.Designation = s.Designation,
    t.Salary      = s.Salary,
    t.Bonus       = s.Bonus,
    t.ManagerID   = s.ManagerID,
    t.HireDate    = s.HireDate,
    t.[Location]  = s.[Location],
    t.[Status]    = s.[Status]
FROM dev.EmployeeDetails t
INNER JOIN stg.EmployeeDetails s
    ON t.EmpCode = s.EmpCode
WHERE
    ISNULL(t.FirstName,'')   <> ISNULL(s.FirstName,'')
 OR ISNULL(t.LastName,'')    <> ISNULL(s.LastName,'')
 OR ISNULL(t.Gender,'')      <> ISNULL(s.Gender,'')
 OR ISNULL(t.Department,'')  <> ISNULL(s.Department,'')
 OR ISNULL(t.Designation,'') <> ISNULL(s.Designation,'')
 OR ISNULL(t.Salary,0)       <> ISNULL(s.Salary,0)
 OR ISNULL(t.Bonus,0)        <> ISNULL(s.Bonus,0)
 OR ISNULL(t.ManagerID,0)    <> ISNULL(s.ManagerID,0)
 OR ISNULL(t.HireDate,'1900-01-01') <> ISNULL(s.HireDate,'1900-01-01')
 OR ISNULL(t.[Location],'')  <> ISNULL(s.[Location],'')
 OR ISNULL(t.[Status],'')    <> ISNULL(s.[Status],'');
