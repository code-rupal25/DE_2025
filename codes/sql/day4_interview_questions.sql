-- create a salary table from existing table (importat query structure)
-- run some basic interview questions 2nd high, rolling over, (1st Window Function after joins)
-- run all interview questions today and explain window functions

-- create table EmployeeDetails
DROP TABLE IF EXISTS EmployeeDetails;
CREATE TABLE EmployeeDetails (
    EmployeeID      VARCHAR(10),
    EmpCode         VARCHAR(10),
    FirstName       VARCHAR(50),
    LastName        VARCHAR(50),
    Gender          CHAR(1),              -- M / F
    Department      VARCHAR(50),
    Designation     VARCHAR(50),
    Salary          DECIMAL(10,2),
    Bonus           DECIMAL(10,2) NULL,
    ManagerID       INT NULL,              -- Self reference
    HireDate        DATE,
    [Location]      VARCHAR(50),
    [Status]        VARCHAR(20)             -- Active / Resigned
);
seelct v

INSERT INTO EmployeeDetails
(EmpCode, FirstName, LastName, Gender, Department, Designation, Salary, Bonus, ManagerID, HireDate, Location, Status)
VALUES
('E001','Amit','Shah','M','IT','Developer',75000,5000,NULL,'2019-01-10','Mumbai','Active'),
('E002','Rina','Patel','F','IT','Developer',72000,NULL,1,'2020-03-15','Mumbai','Active'),
('E003','Kunal','Mehta','M','IT','Tester',55000,3000,1,'2021-06-01','Pune','Active'),
('E004','Neha','Verma','F','HR','HR Executive',48000,NULL,6,'2018-02-20','Delhi','Active'),
('E005','Suresh','Iyer','M','Finance','Analyst',65000,4000,7,'2017-11-05','Chennai','Resigned'),
('E006','Pooja','Nair','F','HR','HR Manager',90000,8000,NULL,'2016-08-12','Delhi','Active'),
('E007','Rahul','Joshi','M','Finance','Finance Manager',95000,10000,NULL,'2015-04-01','Chennai','Active'),
('E008','Ankit','Singh','M','IT','Developer',80000,6000,1,'2022-09-10','Bangalore','Active'),
('E009','Sneha','Kulkarni','F','IT','Tester',58000,NULL,1,'2021-12-01','Pune','Active'),
('E010','Nikhil','Patil','M','IT','Developer',92000,NULL,NULL,'2025-12-15','Pune','Active'),
('E011','Vikram','Singh','M','Admin','Admin Executive',142000,NULL,NULL,'2025-01-15','Pune','Active'),
('E012','Adarsh','Maljhi','M','Finance','Analyst',102000,NULL,NULL,'2019-11-15','Mumbai','Active'),
('E013','Pratiksha','Gore','F','Management','Sr. Manager',192000,NULL,NULL,'2022-07-15','Mumbai','Active'),
('E014','Akshun','Tyagi','M','IT','Developer',112000,NULL,NULL,'2024-08-15','Mumbai','Active'),
('E015','Rutuja','Jambhulkar','F','Management','Jr. Manager',112000,NULL,NULL,'2025-01-15','Mumbai','Active'),
('E016','Vikas','Rao','M','Admin','Admin Executive',42000,NULL,NULL,'2023-01-15','Mumbai','Active');


INSERT INTO stg.EmployeeDetails
(EmpCode, FirstName, LastName, Gender, Department, Designation, Salary, Bonus, ManagerID, HireDate, Location, Status, Creation_Date)
VALUES
('E010','Nikhill','P.','M','IT','Management',175000,5000,NULL,'2019-01-10','Mumbai','Active',CURRENT_TIMESTAMP),
('E011','Vikram','Singh','M','IT','Developer',72000,NULL,1,'2020-03-15','Mumbai','Active',CURRENT_TIMESTAMP),
('E014','Akshun','Tyagi','M','Finance','Analyst',132000,NULL,NULL,'2024-08-15','Delhi','Active',CURRENT_TIMESTAMP);
-----------------------------

---- CRUD / ETL 

-- duplicate remove (row number)
-- Interview questions find the 2nd highest department salary
-- Interview questions find the nth highest department salary
-- Interview Questions find 2nd highest salary without window function

-----------------------------

SELECT MAX(Salary) FROM EmployeeDetails;

SELECT MAX(Salary) FROM EmployeeDetails
WHERE Salary < (SELECT MAX(Salary) FROM EmployeeDetails);

-----------------------------



SELECT 
ROW_NUMBER() OVER(PARTITION BY Department ORDER BY Salary DESC) as Row_Num
* 
FROM dbo.EmployeeDetails;

--WHERE Row_Num = 2
-- application on RNK, DNS_RNK, row_num

-- ETL 
/*
>> Employeee Table // landing / stg table 

TARGET TABLE 
**/

SELECT 
    EmployeeID,
    EmpCode,
    FirstName ,
    LastName,
    Gender ,              -- M / F
    Department,
    Designation,
    Salary ,
    Bonus,
    ManagerID,              -- Self reference
    HireDate
    [Location],
    [Status] 
INTO dbo.TARGET_EMPLOYEE
FROM 
(
SELECT 
ROW_NUMBER() OVER(PARTITION BY EmpCode ORDER BY HireDate DESC) as Row_Num,

* 
FROM dbo.EmployeeDetails
)stg_table
WHERE Row_Num = 1;

-------------------------
/*
SCD - Slowly Changing Dimension
*/

SELECT * FROM EmployeeDetails;
-- SCD Type 1. -- TRUNCATE LOAD / UPDATE with no history
UPDATE EmployeeDetails
SET EmpCode = 'E069'
WHERE EmpCode = 'E010'
AND LastName = 'P.';

-- SCD Type 2
-- add ActiveFlag 
-- update and insert
ALTER TABLE EmployeeDetails
ADD ActiveFlag VARCHAR(2);

SELECT *
FROM EmployeeDetails where EmpCode = 'E069';

INSERT INTO EmployeeDetails(EmployeeID,EmpCode,FirstName ,LastName,Gender ,Department,Designation,Salary,Bonus,ManagerID,HireDate,Location,Status,ActiveFlag)
SELECT 
    EmployeeID,
    EmpCode,
    FirstName ,
    LastName,
    Gender ,
    Department,
    'Sr. Developer' as Designation,
    Salary ,
    Bonus,
    ManagerID,
    HireDate,
    [Location],
    [Status],
    'Y' as ActiveFlag
FROM EmployeeDetails
WHERE EmpCode = 'E069'


UPDATE EmployeeDetails
SET ActiveFlag = 'Y'
WHERE EmpCode = 'E069'
AND Designation = 'Sr. Developer'

SELECT * FROM EmployeeDetails
WHERE EmpCode = 'E069' 



----

-- SCD Type 3
-- old record column
SELECT * FROM EmployeeDetails 
WHERE EmpCode = 'E069'

ALTER TABLE EmployeeDetails
ADD OLD_DESINGATION VARCHAR(50)
--SCD Type4
-- Keep current maintain version in another table



SELECT * INTO EmployeeDetails_History
FROM EmployeeDetails WHERE EmpCode = 'E069'

CREATE TABLE EmployeeDetails_History (
    EmpCode VARCHAR(10),
    OldDepartment VARCHAR(50),
    ChangeDate DATETIME
);

INSERT INTO EmployeeDetails_History
SELECT
    EmpCode,
    Department,
    GETDATE()
FROM EmployeeDetails
WHERE EmpCode = 'E001';

UPDATE EmployeeDetails
SET Department = 'Management'
WHERE EmpCode = 'E001';

