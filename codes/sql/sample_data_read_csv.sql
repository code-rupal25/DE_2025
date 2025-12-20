BULK INSERT dbo.SalesOrders
FROM '/var/opt/mssql/data/sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

-----------------

BULK INSERT dbo.Customers
FROM '/var/opt/mssql/data/Customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

-----------------

BULK INSERT dbo.Products
FROM '/var/opt/mssql/data/Products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

-----------------

BULK INSERT dbo.People
FROM '/var/opt/mssql/data/People.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

-----------------

BULK INSERT dbo.Leads
FROM '/var/opt/mssql/data/Leads.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

-----------------

BULK INSERT dbo.Organizations
FROM '/var/opt/mssql/data/Organizations.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO
