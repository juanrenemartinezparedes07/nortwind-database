-- ============================================================
--  PROJECT  : Northwind OLTP
--  FILE     : 01_OLTP_Create.sql
--  DESC     : Transactional database based on Northwind
--             Normalized to 3NF - Tables in English
--             Includes RowVersion for incremental ETL
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'NorthwindOLTP')
BEGIN
    ALTER DATABASE NorthwindOLTP SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NorthwindOLTP;
END
GO

CREATE DATABASE NorthwindOLTP;
GO

USE NorthwindOLTP;
GO

-- ============================================================
-- TABLE 1: Categories
-- ============================================================
CREATE TABLE dbo.Categories (
    CategoryID   INT           NOT NULL IDENTITY(1,1),
    CategoryName NVARCHAR(50)  NOT NULL,
    Description  NVARCHAR(500) NULL,
    rowversion   ROWVERSION    NOT NULL,
    CONSTRAINT PK_Categories      PRIMARY KEY (CategoryID),
    CONSTRAINT UQ_Categories_Name UNIQUE (CategoryName)
);
GO

-- ============================================================
-- TABLE 2: Suppliers
-- ============================================================
CREATE TABLE dbo.Suppliers (
    SupplierID   INT           NOT NULL IDENTITY(1,1),
    CompanyName  NVARCHAR(100) NOT NULL,
    ContactName  NVARCHAR(100) NULL,
    ContactTitle NVARCHAR(50)  NULL,
    Address      NVARCHAR(200) NULL,
    City         NVARCHAR(50)  NULL,
    Country      NVARCHAR(50)  NULL,
    Phone        NVARCHAR(30)  NULL,
    Fax          NVARCHAR(30)  NULL,
    rowversion   ROWVERSION    NOT NULL,
    CONSTRAINT PK_Suppliers PRIMARY KEY (SupplierID)
);
GO

-- ============================================================
-- TABLE 3: Products
-- ============================================================
CREATE TABLE dbo.Products (
    ProductID       INT           NOT NULL IDENTITY(1,1),
    ProductName     NVARCHAR(100) NOT NULL,
    SupplierID      INT           NULL,
    CategoryID      INT           NULL,
    QuantityPerUnit NVARCHAR(50)  NULL,
    UnitPrice       MONEY         NOT NULL CONSTRAINT DF_Products_UnitPrice    DEFAULT (0),
    UnitsInStock    SMALLINT      NOT NULL CONSTRAINT DF_Products_Stock        DEFAULT (0),
    UnitsOnOrder    SMALLINT      NOT NULL CONSTRAINT DF_Products_OnOrder      DEFAULT (0),
    ReorderLevel    SMALLINT      NOT NULL CONSTRAINT DF_Products_ReorderLevel DEFAULT (0),
    Discontinued    BIT           NOT NULL CONSTRAINT DF_Products_Discontinued DEFAULT (0),
    rowversion      ROWVERSION    NOT NULL,
    CONSTRAINT PK_Products          PRIMARY KEY (ProductID),
    CONSTRAINT FK_Products_Supplier FOREIGN KEY (SupplierID) REFERENCES dbo.Suppliers  (SupplierID),
    CONSTRAINT FK_Products_Category FOREIGN KEY (CategoryID) REFERENCES dbo.Categories (CategoryID),
    CONSTRAINT CK_Products_UnitPrice CHECK (UnitPrice >= 0),
    CONSTRAINT CK_Products_Stock     CHECK (UnitsInStock >= 0)
);
GO

-- ============================================================
-- TABLE 4: Employees
-- ============================================================
CREATE TABLE dbo.Employees (
    EmployeeID INT           NOT NULL IDENTITY(1,1),
    LastName   NVARCHAR(50)  NOT NULL,
    FirstName  NVARCHAR(50)  NOT NULL,
    Title      NVARCHAR(50)  NULL,
    BirthDate  DATE          NULL,
    HireDate   DATE          NULL,
    Address    NVARCHAR(200) NULL,
    City       NVARCHAR(50)  NULL,
    Country    NVARCHAR(50)  NULL,
    ReportsTo  INT           NULL,
    rowversion ROWVERSION    NOT NULL,
    CONSTRAINT PK_Employees      PRIMARY KEY (EmployeeID),
    CONSTRAINT FK_Employees_Boss FOREIGN KEY (ReportsTo) REFERENCES dbo.Employees (EmployeeID)
);
GO

-- ============================================================
-- TABLE 5: Customers
-- ============================================================
CREATE TABLE dbo.Customers (
    CustomerID   NCHAR(5)      NOT NULL,
    CompanyName  NVARCHAR(100) NOT NULL,
    ContactName  NVARCHAR(100) NULL,
    ContactTitle NVARCHAR(50)  NULL,
    Address      NVARCHAR(200) NULL,
    City         NVARCHAR(50)  NULL,
    Region       NVARCHAR(50)  NULL,
    PostalCode   NVARCHAR(20)  NULL,
    Country      NVARCHAR(50)  NULL,
    Phone        NVARCHAR(30)  NULL,
    rowversion   ROWVERSION    NOT NULL,
    CONSTRAINT PK_Customers PRIMARY KEY (CustomerID)
);
GO

-- ============================================================
-- TABLE 6: Shippers
-- ============================================================
CREATE TABLE dbo.Shippers (
    ShipperID   INT          NOT NULL IDENTITY(1,1),
    CompanyName NVARCHAR(50) NOT NULL,
    Phone       NVARCHAR(30) NULL,
    rowversion  ROWVERSION   NOT NULL,
    CONSTRAINT PK_Shippers PRIMARY KEY (ShipperID)
);
GO

-- ============================================================
-- TABLE 7: Orders
-- ============================================================
CREATE TABLE dbo.Orders (
    OrderID      INT           NOT NULL IDENTITY(1,1),
    CustomerID   NCHAR(5)      NOT NULL,
    EmployeeID   INT           NOT NULL,
    OrderDate    DATE          NOT NULL CONSTRAINT DF_Orders_Date    DEFAULT (GETDATE()),
    RequiredDate DATE          NULL,
    ShippedDate  DATE          NULL,
    ShipVia      INT           NULL,
    Freight      MONEY         NOT NULL CONSTRAINT DF_Orders_Freight DEFAULT (0),
    ShipName     NVARCHAR(100) NULL,
    ShipAddress  NVARCHAR(200) NULL,
    ShipCity     NVARCHAR(50)  NULL,
    ShipCountry  NVARCHAR(50)  NULL,
    rowversion   ROWVERSION    NOT NULL,
    CONSTRAINT PK_Orders          PRIMARY KEY (OrderID),
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Customers (CustomerID),
    CONSTRAINT FK_Orders_Employee FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees (EmployeeID),
    CONSTRAINT FK_Orders_Shipper  FOREIGN KEY (ShipVia)    REFERENCES dbo.Shippers  (ShipperID),
    CONSTRAINT CK_Orders_Freight  CHECK (Freight >= 0),
    CONSTRAINT CK_Orders_Dates    CHECK (ShippedDate IS NULL OR ShippedDate >= OrderDate)
);
GO

-- ============================================================
-- TABLE 8: OrderDetails
-- ============================================================
CREATE TABLE dbo.OrderDetails (
    OrderID    INT        NOT NULL,
    ProductID  INT        NOT NULL,
    UnitPrice  MONEY      NOT NULL,
    Quantity   SMALLINT   NOT NULL CONSTRAINT DF_OrderDetails_Qty  DEFAULT (1),
    Discount   REAL       NOT NULL CONSTRAINT DF_OrderDetails_Disc DEFAULT (0),
    rowversion ROWVERSION NOT NULL,
    CONSTRAINT PK_OrderDetails          PRIMARY KEY (OrderID, ProductID),
    CONSTRAINT FK_OrderDetails_Order    FOREIGN KEY (OrderID)   REFERENCES dbo.Orders   (OrderID),
    CONSTRAINT FK_OrderDetails_Product  FOREIGN KEY (ProductID) REFERENCES dbo.Products (ProductID),
    CONSTRAINT CK_OrderDetails_Price    CHECK (UnitPrice >= 0),
    CONSTRAINT CK_OrderDetails_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderDetails_Discount CHECK (Discount BETWEEN 0 AND 1)
);
GO

-- ============================================================
-- PERFORMANCE INDEXES
-- ============================================================
CREATE INDEX IX_Products_Category  ON dbo.Products    (CategoryID);
CREATE INDEX IX_Products_Supplier  ON dbo.Products    (SupplierID);
CREATE INDEX IX_Orders_Customer    ON dbo.Orders      (CustomerID);
CREATE INDEX IX_Orders_Employee    ON dbo.Orders      (EmployeeID);
CREATE INDEX IX_Orders_Date        ON dbo.Orders      (OrderDate);
CREATE INDEX IX_OrderDetails_Prod  ON dbo.OrderDetails(ProductID);
GO

-- ============================================================
-- ETL CONTROL TABLE (RowVersion tracking)
-- Esta tabla guarda la ultima version procesada por el ETL
-- ============================================================
CREATE TABLE dbo.ETL_Control (
    TableName      NVARCHAR(100) NOT NULL,
    LastRowVersion BINARY(8)     NULL,
    LastLoadDate   DATETIME      NOT NULL CONSTRAINT DF_ETL_LastLoad DEFAULT (GETDATE()),
    CONSTRAINT PK_ETL_Control PRIMARY KEY (TableName)
);
GO

INSERT INTO dbo.ETL_Control (TableName, LastRowVersion) VALUES
('Categories',  0x0000000000000000),
('Suppliers',   0x0000000000000000),
('Products',    0x0000000000000000),
('Employees',   0x0000000000000000),
('Customers',   0x0000000000000000),
('Shippers',    0x0000000000000000),
('Orders',      0x0000000000000000),
('OrderDetails',0x0000000000000000);
GO

PRINT '>> NorthwindOLTP created successfully.';
PRINT '>> Tables: Categories, Suppliers, Products, Employees, Customers, Shippers, Orders, OrderDetails';
PRINT '>> RowVersion included in all tables for incremental ETL';
GO
