-- ============================================================
--  PROJECT  : Northwind Data Warehouse
--  FILE     : 03_DW_Create.sql
--  DESC     : Star schema DW based on NorthwindOLTP
--             All tables in English
--             Includes RowVersion-based incremental ETL support
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'NorthwindDW')
BEGIN
    ALTER DATABASE NorthwindDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NorthwindDW;
END
GO

CREATE DATABASE NorthwindDW;
GO

USE NorthwindDW;
GO

-- ============================================================
-- DIMENSION 1: DimDate
-- Decomposes date into analytical attributes
-- ============================================================
CREATE TABLE dbo.DimDate (
    DateKey             INT          NOT NULL,  -- YYYYMMDD
    FullDate            DATE         NOT NULL,
    Year                SMALLINT     NOT NULL,
    Quarter             TINYINT      NOT NULL,
    QuarterName         NVARCHAR(6)  NOT NULL,  -- Q1..Q4
    Month               TINYINT      NOT NULL,
    MonthName           NVARCHAR(20) NOT NULL,
    Week                TINYINT      NOT NULL,
    DayOfWeek           TINYINT      NOT NULL,
    DayName             NVARCHAR(12) NOT NULL,
    IsWeekend           BIT          NOT NULL,
    CONSTRAINT PK_DimDate PRIMARY KEY (DateKey)
);
GO

-- ============================================================
-- DIMENSION 2: DimCustomer
-- ============================================================
CREATE TABLE dbo.DimCustomer (
    CustomerSK   INT           NOT NULL IDENTITY(1,1),  -- Surrogate Key
    CustomerID   NCHAR(5)      NOT NULL,                -- Business Key
    CompanyName  NVARCHAR(100) NOT NULL,
    ContactName  NVARCHAR(100) NULL,
    City         NVARCHAR(50)  NULL,
    Country      NVARCHAR(50)  NULL,
    Region       NVARCHAR(50)  NULL,
    CONSTRAINT PK_DimCustomer PRIMARY KEY (CustomerSK)
);
GO

-- ============================================================
-- DIMENSION 3: DimProduct
-- Denormalized: includes Category and Supplier info
-- ============================================================
CREATE TABLE dbo.DimProduct (
    ProductSK       INT           NOT NULL IDENTITY(1,1),
    ProductID       INT           NOT NULL,
    ProductName     NVARCHAR(100) NOT NULL,
    CategoryName    NVARCHAR(50)  NULL,
    SupplierName    NVARCHAR(100) NULL,
    SupplierCountry NVARCHAR(50)  NULL,
    UnitPrice       MONEY         NOT NULL,
    Discontinued    BIT           NOT NULL,
    CONSTRAINT PK_DimProduct PRIMARY KEY (ProductSK)
);
GO

-- ============================================================
-- DIMENSION 4: DimEmployee
-- ============================================================
CREATE TABLE dbo.DimEmployee (
    EmployeeSK INT           NOT NULL IDENTITY(1,1),
    EmployeeID INT           NOT NULL,
    FullName   NVARCHAR(100) NOT NULL,
    Title      NVARCHAR(50)  NULL,
    City       NVARCHAR(50)  NULL,
    Country    NVARCHAR(50)  NULL,
    HireDate   DATE          NULL,
    CONSTRAINT PK_DimEmployee PRIMARY KEY (EmployeeSK)
);
GO

-- ============================================================
-- DIMENSION 5: DimShipper
-- ============================================================
CREATE TABLE dbo.DimShipper (
    ShipperSK   INT          NOT NULL IDENTITY(1,1),
    ShipperID   INT          NOT NULL,
    CompanyName NVARCHAR(50) NOT NULL,
    Phone       NVARCHAR(30) NULL,
    CONSTRAINT PK_DimShipper PRIMARY KEY (ShipperSK)
);
GO

-- ============================================================
-- FACT TABLE: FactOrders
-- Granularity: one row per order line (OrderID + ProductID)
-- ============================================================
CREATE TABLE dbo.FactOrders (
    OrderSK        INT      NOT NULL IDENTITY(1,1),
    OrderID        INT      NOT NULL,   -- Degenerate dimension
    ProductID      INT      NOT NULL,   -- Degenerate dimension
    OrderDateKey   INT      NOT NULL,
    RequiredDateKey INT     NULL,
    ShippedDateKey INT      NULL,
    CustomerSK     INT      NOT NULL,
    ProductSK      INT      NOT NULL,
    EmployeeSK     INT      NOT NULL,
    ShipperSK      INT      NOT NULL,

    -- METRICS
    Quantity       SMALLINT NOT NULL,
    UnitPrice      MONEY    NOT NULL,
    Discount       REAL     NOT NULL,
    ExtendedPrice  MONEY    NOT NULL,  -- UnitPrice * Quantity * (1 - Discount)
    Freight        MONEY    NOT NULL,

    CONSTRAINT PK_FactOrders         PRIMARY KEY (OrderSK),
    CONSTRAINT FK_Fact_OrderDate     FOREIGN KEY (OrderDateKey)    REFERENCES dbo.DimDate     (DateKey),
    CONSTRAINT FK_Fact_Customer      FOREIGN KEY (CustomerSK)      REFERENCES dbo.DimCustomer (CustomerSK),
    CONSTRAINT FK_Fact_Product       FOREIGN KEY (ProductSK)       REFERENCES dbo.DimProduct  (ProductSK),
    CONSTRAINT FK_Fact_Employee      FOREIGN KEY (EmployeeSK)      REFERENCES dbo.DimEmployee (EmployeeSK),
    CONSTRAINT FK_Fact_Shipper       FOREIGN KEY (ShipperSK)       REFERENCES dbo.DimShipper  (ShipperSK)
);
GO

-- ============================================================
-- PERFORMANCE INDEXES
-- ============================================================
CREATE INDEX IX_Fact_OrderDate  ON dbo.FactOrders (OrderDateKey);
CREATE INDEX IX_Fact_Customer   ON dbo.FactOrders (CustomerSK);
CREATE INDEX IX_Fact_Product    ON dbo.FactOrders (ProductSK);
CREATE INDEX IX_Fact_Employee   ON dbo.FactOrders (EmployeeSK);
GO

-- ============================================================
-- ETL CONTROL TABLE (RowVersion tracking for incremental load)
-- ============================================================
CREATE TABLE dbo.ETL_Control (
    TableName      NVARCHAR(100) NOT NULL,
    LastRowVersion BINARY(8)     NULL,
    LastLoadDate   DATETIME      NOT NULL DEFAULT (GETDATE()),
    CONSTRAINT PK_ETL_Control PRIMARY KEY (TableName)
);
GO

INSERT INTO dbo.ETL_Control (TableName, LastRowVersion) VALUES
('Customers',    0x0000000000000000),
('Products',     0x0000000000000000),
('Employees',    0x0000000000000000),
('Shippers',     0x0000000000000000),
('Orders',       0x0000000000000000),
('OrderDetails', 0x0000000000000000);
GO

PRINT '>> NorthwindDW created successfully.';
PRINT '>> Dimensions: DimDate, DimCustomer, DimProduct, DimEmployee, DimShipper';
PRINT '>> Fact Table: FactOrders';
PRINT '>> ETL Control table ready for RowVersion incremental load';
GO
