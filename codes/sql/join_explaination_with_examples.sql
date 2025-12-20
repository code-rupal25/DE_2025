select * from [dbo].[test] A
order by id,name

-- INSERT INTO [dbo].[test]
-- VALUES (null , null)
/* ----------------------------------------
id		name
NULL	NULL
1		1
1		1
1		1
1		2
1		3
1		3
2		NULL
2		3
----------------------------------------- */

with A as 
(select id as col from [dbo].[test]),
B as (select name as col from [dbo].[test])
select * from A
cross join B 
-- on A.col=B.col
order by A.col,B.col

-- INNER JOIN 
-- WILL GIVE OUTPUT 20 counts as every row matches with other matching rows
-- but NULL values will not give any output here because ??

-- LEFT JOIN
-- Will give output 21 count as every left (A) table tries to match with rows in B
-- and Null from one row is given output though B has two null but only 1 row is matched

-- RIGHT JOIN
-- Will give output of 25 where right (B) tries to match with (A)
-- and Null (2 rows will contains output) it does not mean it join with A null nope it just holds nothing 
-- thus nothing joins nothing gives nothing and remaing 3 not joined thus null in A

-- OUTER JOIN
-- join from left + join from right after individualling single matching row by row basically 
-- inner join + remaing from left table + remaing from right table

-- CROSS JOIN
-- Cartesian product of the table table A and table B in the final out thus 9 rows each cartesian product 
-- each row paired with each irrespective of matching.


