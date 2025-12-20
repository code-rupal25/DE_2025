USE msdb;
GO
DROP TABLE IF EXISTS dbo.SalesOrders ;
CREATE TABLE dbo.SalesOrders (
    SalesOrderNumber        NVARCHAR(500),        -- example: SO43701
    SalesOrderLineNumber    NVARCHAR(500),                 -- numeric: 1,2,...
    OrderDate               DATE,                -- 2019-07-01 format
    CustomerName            NVARCHAR(100),       -- names vary
    EmailAddress            NVARCHAR(150),       -- email can be long
    Item                    NVARCHAR(200),       -- product description
    Quantity                NVARCHAR(500),                -- integer quantity
    UnitPrice               NVARCHAR(500),       -- money values
    TaxAmount               NVARCHAR(500)        -- more precision for tax
);
GO

----------------------------------

DROP TABLE IF EXISTS dbo.Customers ;
CREATE TABLE dbo.Customers (
    CustomerIndex        INT            NOT NULL,
    CustomerId           VARCHAR(32)    NOT NULL PRIMARY KEY,
    FirstName            VARCHAR(50)    NOT NULL,
    LastName             VARCHAR(50)    NOT NULL,
    Company              VARCHAR(150)   NULL,
    City                 VARCHAR(100)   NULL,
    Country              VARCHAR(100)   NOT NULL,
    Phone1               VARCHAR(100)    NOT NULL,
    Phone2               VARCHAR(100)    NULL,
    Email                VARCHAR(150)   NOT NULL UNIQUE,
    SubscriptionDate     VARCHAR(150)   NOT NULL,
    Website              VARCHAR(200)   NULL
);



---------------------------

DROP TABLE IF EXISTS dbo.Products ;
CREATE TABLE dbo.Products (
    ProductIndex        INT             NOT NULL,
    Name                VARCHAR(150)    NOT NULL,
    Description         VARCHAR(500)    NULL,
    Brand               VARCHAR(100)    NOT NULL,
    Category            VARCHAR(100)    NOT NULL,
    Price               VARCHAR(150)   NOT NULL CHECK (Price > 0),
    Currency            VARCHAR(10)         NOT NULL DEFAULT 'USD',
    Stock               VARCHAR(20)             NOT NULL CHECK (Stock >= 0),
    EAN                 VARCHAR(20)     NOT NULL,   -- product barcode
    Color               VARCHAR(50)     NULL,
    Size                VARCHAR(20)     NULL,
    Availability        VARCHAR(30)     NOT NULL CHECK (Availability IN 
                        ('in_stock', 'backorder', 'out_of_stock', 'pre_order')),
    InternalID          VARCHAR(100)             NOT NULL,

);



-----------------------

DROP TABLE IF EXISTS dbo.People ;
CREATE TABLE dbo.People (
    [Index]       INT  NOT NULL,
    UserId        VARCHAR(32)  NOT NULL PRIMARY KEY,
    FirstName     VARCHAR(50)   NULL,
    LastName      VARCHAR(50)   NULL,
    Sex           VARCHAR(50)  NULL,
    Email         VARCHAR(100)  NULL,
    Phone         VARCHAR(30)  NULL,
    DateOfBirth   VARCHAR(30)    NULL,
    JobTitle      VARCHAR(100)  NULL
);

---------------------

DROP TABLE IF EXISTS dbo.Leads ;
CREATE TABLE dbo.Leads (
    AccountId    VARCHAR(32)   NOT NULL PRIMARY KEY,
    LeadOwner    VARCHAR(100)  NOT NULL,
    FirstName    VARCHAR(50)   NOT NULL,
    LastName     VARCHAR(50)   NOT NULL,
    Company      VARCHAR(150)  NOT NULL,
    Phone1       VARCHAR(30)   NOT NULL,
    Phone2       VARCHAR(30)   NULL,
    Email1       VARCHAR(100)  NOT NULL,
    Email2       VARCHAR(100)  NULL,
    Website      VARCHAR(200)  NULL,
    Source       VARCHAR(50)   NOT NULL,
    DealStage    VARCHAR(50)   NOT NULL,
    Notes        VARCHAR(500)  NULL
);


--------------------------

DROP TABLE IF EXISTS dbo.Organizations ;
CREATE TABLE dbo.Organizations (
    OrgIndex            INT            NOT NULL,
    OrganizationId      VARCHAR(32)    NOT NULL PRIMARY KEY,
    Name                VARCHAR(150)   NOT NULL,
    Website             VARCHAR(200)   NULL,
    Country             VARCHAR(100)   NOT NULL,
    Description         VARCHAR(500)   NULL,
    Founded             INT            CHECK (Founded >= 1800 AND Founded <= YEAR(GETDATE())),
    Industry            VARCHAR(150)   NOT NULL,
    NumberOfEmployees   VARCHAR(150)            CHECK (NumberOfEmployees >= 0)
);



