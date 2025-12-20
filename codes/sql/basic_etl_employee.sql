/****************************************************
 BASIC ETL LEARNING SQL SCRIPT
 Source -> Staging -> Target (Upsert)
 Columns: ID, Name, Salary, Dept
****************************************************/

/*==============================
1. SOURCE TABLE (RAW - VARCHAR)
==============================*/

-- on prem SQL Server > Table 

DROP TABLE IF EXISTS src_employee;
CREATE TABLE src_employee (
    ID        VARCHAR(50),
    Name      VARCHAR(100),
    Salary    VARCHAR(50),
    Dept      VARCHAR(50),
    LoadDate  VARCHAR(20)
);

/* Sample Source Load - Day 1 */
INSERT INTO src_employee VALUES
('1','Rahul','50000','IT','2025-01-01'),
('2','Anita','60000','HR','2025-01-01'),
('3','Vikas','55000','Finance','2025-01-01'),
('4','Nikhil','55000','Finance','2025-02-01'),
('4','Vikram','55000','Finance','2025-03-01');


-- DEBUG
SELECT * FROM src_employee

/*==============================
2. STAGING TABLE (LATEST SNAPSHOT)
==============================*/

DROP TABLE IF EXISTS stg_employee;
CREATE TABLE stg_employee (
    ID        VARCHAR(50),
    Name      VARCHAR(100),
    Salary    VARCHAR(50),
    Dept      VARCHAR(50),
    LoadDate  VARCHAR(50)
);


--- STORED PROCDEDURE 

SELECT * FROM src_employee

/* Load Source -> Staging */
INSERT INTO stg_employee
SELECT
    ID,
    Name,
    Salary,
    Dept,
    CAST(LoadDate AS DATE)
FROM src_employee
WHERE LoadDate > '2025-05-01';

SELECT * FROM src_employee
------ CHECK ------

SELECT COunt(*) fROM stg_employee

-- nulll check
SELECT * FROM stg_employee 
WHERE ID is NULL

--duplicate check
SELECT ID,COUNT(*) FROM stg_employee
GROUP BY ID
HAVING COUNT(*) > 1


--REMVE DUPLICATE AND NULL

/*
DELETE FROM 
WHERE 
(
    SELECT *,ROW_NUMBER() OVER(PARTITION BY ID ORDER BY LoadDate DESC) as RNK FROM src_employee
)int1
WHERE RNK > 1
*/


/*==============================
3. TARGET / DEV TABLE (TYPED)
==============================*/
DROP TABLE IF EXISTS dev_employee;
CREATE TABLE dev_employee (
    ID           INT PRIMARY KEY,
    Name         VARCHAR(100),
    Salary       INT,
    Dept         VARCHAR(50),
    SRC_LOAD_DATE  DATE,  -- SRC
    Created_Date  DATETIME. -- CREATED DATE AZ
);


/*==============================
4. INSERT NEW RECORDS
==============================*/

SELECT * FROM dev_employee; 

INSERT INTO dev_employee (ID, Name, Salary, Dept, LastUpdated)
SELECT
    CAST(s.ID AS INT),
    s.Name,
    CAST(s.Salary AS INT),
    s.Dept,
    CURRENT_DATE
FROM stg_employee s
LEFT JOIN dev_employee d
    ON CAST(s.ID AS INT) = d.ID
WHERE d.ID IS NULL;

-- Transformation Script

SELECT * FROM dev_employee;
SELECT * FROM stg_employee;


INSERT INTO dev_employee (ID, Name, Salary, Dept, SRC_LOAD_DATE,Created_Date)
SELECT 
    CAST(s.ID AS INT) as ID,
    s.Name,
    CAST(s.Salary AS INT) as Salary,
    s.Dept,
    LoadDate as SRC_LOAD_DATE,
    CURRENT_TIMESTAMP as Created_Date
FROM (
SELECT *,ROW_NUMBER() OVER(PARTITION BY ID ORDER BY LoadDate DESC) as RNK FROM stg_employee
)s
LEFT JOIN dev_employee dev
    ON CAST(s.ID AS INT) = dev.ID
WHERE dev.ID IS NULL
AND RNK = 1. -- removing 
AND s.ID is NOT NULL -- removing no null 

SELECT * FROM dev_employee

/*==============================
5. UPDATE CHANGED RECORDS
==============================*/


/**

UPDATE dev_employee d
SET
    d.Name = s.Name,
    d.Salary = CAST(s.Salary AS INT),
    d.Dept = s.Dept
FROM 
SELECT 
    CAST(s.ID AS INT) as ID,
    s.Name,
    CAST(s.Salary AS INT) as Salary,
    s.Dept,
    LoadDate as SRC_LOAD_DATE,
    CURRENT_TIMESTAMP as Created_Date
FROM 
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY ID ORDER BY LoadDate DESC) as RNK FROM src_employee s
)s
WHERE RNK = 1
AND d.ID = CAST(ss.ID AS INT)
AND (
       d.Name <> ss.Name
    OR d.Salary <> CAST(ss.Salary AS INT)
    OR d.Dept <> ss.Dept
);
**/

-----
UPDATE d
SET
    Name   = s.Name,
    Salary = CAST(s.Salary AS INT),
    Dept   = s.Dept
FROM dev_employee d
INNER JOIN (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ID ORDER BY LoadDate DESC) AS RNK
    FROM src_employee
) s
    ON d.ID = CAST(s.ID AS INT)
WHERE s.RNK = 1
  AND (
         d.Name   <> s.Name
      OR d.Salary <> CAST(s.Salary AS INT)
      OR d.Dept   <> s.Dept
  );

SELECT * FROM dev_employee

/*==============================
6. DAY-2 SOURCE CHANGE EXAMPLE
==============================*/
INSERT INTO src_employee VALUES
('1','Rupal','455000','IT','2025-07-02'),
('5','Nikhil','90000','IT','2025-05-02');


SELECT * FROM src_employee

SELECT * FROM stg_employee;
-- Reload staging
TRUNCATE TABLE stg_employee;

INSERT INTO stg_employee
SELECT
    ID,
    Name,
    Salary,
    Dept,
    CAST(LoadDate AS DATE)
FROM src_employee;

/* Re-run INSERT + UPDATE for incremental load */
INSERT INTO dev_employee (ID, Name, Salary, Dept, LastUpdated)
SELECT
    CAST(s.ID AS INT),
    s.Name,
    CAST(s.Salary AS INT),
    s.Dept,
    CURRENT_DATE
FROM stg_employee s
LEFT JOIN dev_employee d
    ON CAST(s.ID AS INT) = d.ID
WHERE d.ID IS NULL;

UPDATE dev_employee d
SET
    Name = s.Name,
    Salary = CAST(s.Salary AS INT),
    Dept = s.Dept,
    LastUpdated = CURRENT_DATE
FROM stg_employee s
WHERE d.ID = CAST(s.ID AS INT)
AND (
       d.Name <> s.Name
    OR d.Salary <> CAST(s.Salary AS INT)
    OR d.Dept <> s.Dept
);

/****************************************************
 END OF ETL SCRIPT
****************************************************/
