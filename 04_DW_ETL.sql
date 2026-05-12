-- ============================================================
--  PROJECT  : Northwind Data Warehouse
--  FILE     : 04_DW_ETL.sql
--  DESC     : ETL with RowVersion for incremental load
--             Extract from NorthwindOLTP → Load to NorthwindDW
--             Run AFTER 03_DW_Create.sql
-- ============================================================

USE NorthwindDW;
GO

-- ============================================================
-- STEP 1: Load DimDate
-- Generates one row per unique date in Orders
-- ============================================================
INSERT INTO dbo.DimDate (DateKey, FullDate, Year, Quarter, QuarterName, Month, MonthName, Week, DayOfWeek, DayName, IsWeekend)
SELECT DISTINCT
    CONVERT(INT, FORMAT(o.OrderDate, 'yyyyMMdd'))        AS DateKey,
    o.OrderDate                                           AS FullDate,
    YEAR(o.OrderDate)                                     AS Year,
    DATEPART(QUARTER, o.OrderDate)                        AS Quarter,
    'Q' + CAST(DATEPART(QUARTER, o.OrderDate) AS NVARCHAR) AS QuarterName,
    MONTH(o.OrderDate)                                    AS Month,
    DATENAME(MONTH, o.OrderDate)                          AS MonthName,
    DATEPART(WEEK, o.OrderDate)                           AS Week,
    DATEPART(WEEKDAY, o.OrderDate)                        AS DayOfWeek,
    DATENAME(WEEKDAY, o.OrderDate)                        AS DayName,
    CASE WHEN DATEPART(WEEKDAY, o.OrderDate) IN (1,7) THEN 1 ELSE 0 END AS IsWeekend
FROM NorthwindOLTP.dbo.Orders o
WHERE o.OrderDate IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM dbo.DimDate d
      WHERE d.DateKey = CONVERT(INT, FORMAT(o.OrderDate, 'yyyyMMdd'))
  );

PRINT '>> DimDate loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================
-- STEP 2: Load DimCustomer (with RowVersion)
-- ============================================================
DECLARE @LastRV_Customer BINARY(8);
SELECT @LastRV_Customer = LastRowVersion
FROM dbo.ETL_Control WHERE TableName = 'Customers';

INSERT INTO dbo.DimCustomer (CustomerID, CompanyName, ContactName, City, Country, Region)
SELECT
    c.CustomerID,
    c.CompanyName,
    c.ContactName,
    c.City,
    c.Country,
    c.Region
FROM NorthwindOLTP.dbo.Customers c
WHERE c.rowversion > @LastRV_Customer
  AND NOT EXISTS (
      SELECT 1 FROM dbo.DimCustomer dc
      WHERE dc.CustomerID = c.CustomerID
  );

-- Update ETL Control with latest RowVersion
UPDATE dbo.ETL_Control
SET LastRowVersion = (SELECT MAX(rowversion) FROM NorthwindOLTP.dbo.Customers),
    LastLoadDate   = GETDATE()
WHERE TableName = 'Customers';

PRINT '>> DimCustomer loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================
-- STEP 3: Load DimProduct (with RowVersion - Denormalized)
-- ============================================================
DECLARE @LastRV_Product BINARY(8);
SELECT @LastRV_Product = LastRowVersion
FROM dbo.ETL_Control WHERE TableName = 'Products';

INSERT INTO dbo.DimProduct (ProductID, ProductName, CategoryName, SupplierName, SupplierCountry, UnitPrice, Discontinued)
SELECT
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    s.CompanyName    AS SupplierName,
    s.Country        AS SupplierCountry,
    p.UnitPrice,
    p.Discontinued
FROM NorthwindOLTP.dbo.Products  p
LEFT JOIN NorthwindOLTP.dbo.Categories c ON p.CategoryID  = c.CategoryID
LEFT JOIN NorthwindOLTP.dbo.Suppliers  s ON p.SupplierID  = s.SupplierID
WHERE p.rowversion > @LastRV_Product
  AND NOT EXISTS (
      SELECT 1 FROM dbo.DimProduct dp
      WHERE dp.ProductID = p.ProductID
  );

UPDATE dbo.ETL_Control
SET LastRowVersion = (SELECT MAX(rowversion) FROM NorthwindOLTP.dbo.Products),
    LastLoadDate   = GETDATE()
WHERE TableName = 'Products';

PRINT '>> DimProduct loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================
-- STEP 4: Load DimEmployee (with RowVersion)
-- ============================================================
DECLARE @LastRV_Employee BINARY(8);
SELECT @LastRV_Employee = LastRowVersion
FROM dbo.ETL_Control WHERE TableName = 'Employees';

INSERT INTO dbo.DimEmployee (EmployeeID, FullName, Title, City, Country, HireDate)
SELECT
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS FullName,
    e.Title,
    e.City,
    e.Country,
    e.HireDate
FROM NorthwindOLTP.dbo.Employees e
WHERE e.rowversion > @LastRV_Employee
  AND NOT EXISTS (
      SELECT 1 FROM dbo.DimEmployee de
      WHERE de.EmployeeID = e.EmployeeID
  );

UPDATE dbo.ETL_Control
SET LastRowVersion = (SELECT MAX(rowversion) FROM NorthwindOLTP.dbo.Employees),
    LastLoadDate   = GETDATE()
WHERE TableName = 'Employees';

PRINT '>> DimEmployee loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================
-- STEP 5: Load DimShipper (with RowVersion)
-- ============================================================
DECLARE @LastRV_Shipper BINARY(8);
SELECT @LastRV_Shipper = LastRowVersion
FROM dbo.ETL_Control WHERE TableName = 'Shippers';

INSERT INTO dbo.DimShipper (ShipperID, CompanyName, Phone)
SELECT
    sh.ShipperID,
    sh.CompanyName,
    sh.Phone
FROM NorthwindOLTP.dbo.Shippers sh
WHERE sh.rowversion > @LastRV_Shipper
  AND NOT EXISTS (
      SELECT 1 FROM dbo.DimShipper ds
      WHERE ds.ShipperID = sh.ShipperID
  );

UPDATE dbo.ETL_Control
SET LastRowVersion = (SELECT MAX(rowversion) FROM NorthwindOLTP.dbo.Shippers),
    LastLoadDate   = GETDATE()
WHERE TableName = 'Shippers';

PRINT '>> DimShipper loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================
-- STEP 6: Load FactOrders (with RowVersion)
-- ============================================================
DECLARE @LastRV_Orders BINARY(8);
SELECT @LastRV_Orders = LastRowVersion
FROM dbo.ETL_Control WHERE TableName = 'Orders';

INSERT INTO dbo.FactOrders (
    OrderID, ProductID,
    OrderDateKey, RequiredDateKey, ShippedDateKey,
    CustomerSK, ProductSK, EmployeeSK, ShipperSK,
    Quantity, UnitPrice, Discount, ExtendedPrice, Freight
)
SELECT
    o.OrderID,
    od.ProductID,
    CONVERT(INT, FORMAT(o.OrderDate,     'yyyyMMdd')) AS OrderDateKey,
    CONVERT(INT, FORMAT(o.RequiredDate,  'yyyyMMdd')) AS RequiredDateKey,
    CONVERT(INT, FORMAT(o.ShippedDate,   'yyyyMMdd')) AS ShippedDateKey,
    dc.CustomerSK,
    dp.ProductSK,
    de.EmployeeSK,
    ds.ShipperSK,
    od.Quantity,
    od.UnitPrice,
    od.Discount,
    CAST(od.UnitPrice * od.Quantity * (1 - od.Discount) AS MONEY) AS ExtendedPrice,
    o.Freight
FROM NorthwindOLTP.dbo.Orders      o
JOIN NorthwindOLTP.dbo.OrderDetails od ON o.OrderID     = od.OrderID
JOIN dbo.DimCustomer               dc  ON o.CustomerID  = dc.CustomerID
JOIN dbo.DimProduct                dp  ON od.ProductID  = dp.ProductID
JOIN dbo.DimEmployee               de  ON o.EmployeeID  = de.EmployeeID
JOIN dbo.DimShipper                ds  ON o.ShipVia     = ds.ShipperID
JOIN dbo.DimDate                   dd  ON CONVERT(INT, FORMAT(o.OrderDate,'yyyyMMdd')) = dd.DateKey
WHERE o.rowversion > @LastRV_Orders
  AND NOT EXISTS (
      SELECT 1 FROM dbo.FactOrders f
      WHERE f.OrderID = o.OrderID AND f.ProductID = od.ProductID
  );

UPDATE dbo.ETL_Control
SET LastRowVersion = (SELECT MAX(rowversion) FROM NorthwindOLTP.dbo.Orders),
    LastLoadDate   = GETDATE()
WHERE TableName = 'Orders';

PRINT '>> FactOrders loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================
-- VALIDATION
-- ============================================================
PRINT '=== DW VALIDATION ===';
SELECT 'DimDate'     AS TableName, COUNT(*) AS Records FROM dbo.DimDate
UNION ALL SELECT 'DimCustomer', COUNT(*) FROM dbo.DimCustomer
UNION ALL SELECT 'DimProduct',  COUNT(*) FROM dbo.DimProduct
UNION ALL SELECT 'DimEmployee', COUNT(*) FROM dbo.DimEmployee
UNION ALL SELECT 'DimShipper',  COUNT(*) FROM dbo.DimShipper
UNION ALL SELECT 'FactOrders',  COUNT(*) FROM dbo.FactOrders;
GO

-- ============================================================
-- ANALYTICAL QUERIES
-- ============================================================

-- Sales by Year and Quarter
PRINT '--- Sales by Quarter ---';
SELECT
    d.Year,
    d.QuarterName,
    COUNT(DISTINCT f.OrderID)  AS TotalOrders,
    SUM(f.Quantity)            AS UnitsSold,
    SUM(f.ExtendedPrice)       AS TotalSales
FROM dbo.FactOrders f
JOIN dbo.DimDate    d ON f.OrderDateKey = d.DateKey
GROUP BY d.Year, d.Quarter, d.QuarterName
ORDER BY d.Year, d.Quarter;
GO

-- Top 5 Products
PRINT '--- Top 5 Products ---';
SELECT TOP 5
    p.ProductName,
    p.CategoryName,
    SUM(f.Quantity)      AS UnitsSold,
    SUM(f.ExtendedPrice) AS TotalSales
FROM dbo.FactOrders f
JOIN dbo.DimProduct p ON f.ProductSK = p.ProductSK
GROUP BY p.ProductName, p.CategoryName
ORDER BY TotalSales DESC;
GO

-- Sales by Country
PRINT '--- Sales by Country ---';
SELECT TOP 10
    c.Country,
    COUNT(DISTINCT f.OrderID) AS TotalOrders,
    SUM(f.ExtendedPrice)      AS TotalSales
FROM dbo.FactOrders  f
JOIN dbo.DimCustomer c ON f.CustomerSK = c.CustomerSK
GROUP BY c.Country
ORDER BY TotalSales DESC;
GO

-- Employee Performance
PRINT '--- Employee Performance ---';
SELECT
    e.FullName,
    e.Title,
    COUNT(DISTINCT f.OrderID) AS OrdersHandled,
    SUM(f.ExtendedPrice)      AS TotalSales
FROM dbo.FactOrders  f
JOIN dbo.DimEmployee e ON f.EmployeeSK = e.EmployeeSK
GROUP BY e.FullName, e.Title
ORDER BY TotalSales DESC;
GO

PRINT '>> ETL completed. NorthwindDW ready for analysis!';
GO
