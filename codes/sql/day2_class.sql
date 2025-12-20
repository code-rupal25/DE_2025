SELECT * FROM dbo.Organizations

-- CRUD
DROP TABLE IF EXISTS dbo.student ;
CREATE TABLE dbo.abc_table (
    id            INT            NOT NULL,
    name      VARCHAR(32)    NOT NULL PRIMARY KEY,
    subject    VARCHAR(32)   NOT NULL,
)

SELECT * FROM dbo.abc_table

INSERT INTO dbo.abc_table
VALUES (1, 'Vikram', 'Comp'),
       (1, 'Adarsh', 'Meta')

-- CRUD DE

UPDATE  dbo.abc_table
SET subject = 'Comp'
WHERE NAME = 'Nikhil'

---
TRUNCATE TABLE dbo.abc_table ;

DROP TABLE dbo.abc_table ;

----

-- STRUCTURE OF QUERY 
-- 


SELECT Country,COUNT(*)     / min / max / AVG / SUM 
FROM [dbo].[Customers]
WHERE Country LIKE 'A%'
GROUP BY Country
HAVING COUNT(*) > 3
