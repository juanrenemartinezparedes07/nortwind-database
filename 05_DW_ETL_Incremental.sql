-- ============================================================
--  PROJECT  : Northwind Data Warehouse
--  FILE     : 05_DW_ETL_Incremental.sql
--  DESC     : Stored Procedure for incremental ETL
--             Uses RowVersion to detect new/changed records
--             Run AFTER 04_DW_ETL.sql
-- ============================================================

USE NorthwindDW;
GO

-- ============================================================
-- STORED PROCEDURE: usp_ETL_LoadIncrementalDW
-- Loads only NEW records from NorthwindOLTP to NorthwindDW
-- Uses RowVersion to detect changes automatically
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.usp_ETL_LoadIncrementalDW
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime    DATETIME = GETDATE();
    DECLARE @RowsLoaded   INT      = 0;
    DECLARE @TotalRows    INT      = 0;

    PRINT '============================================';
    PRINT 'ETL Incremental Load Started: ' + CONVERT(VARCHAR, @StartTime, 120);
    PRINT '============================================';

    -- --------------------------------------------------------
    -- STEP 1: DimCustomer (RowVersion incremental)
    -- --------------------------------------------------------
    DECLARE @LastRV_Customer BINARY(8);
    SELECT @LastRV_Customer = LastRowVersion
    FROM dbo.ETL_Control WHERE TableName = 'Customers';

    INSERT INTO dbo.DimCustomer (CustomerID, CompanyName, ContactName, City, Country, Region)
    SELECT c.CustomerID, c.CompanyName, c.ContactName, c.City, c.Country, c.Region
    FROM NorthwindOLTP.dbo.Customers c
    WHERE c.rowversion > @LastRV_Customer
      AND NOT EXISTS (
          SELECT 1 FROM dbo.DimCustomer dc WHERE dc.CustomerID = c.CustomerID
      );

    SET @RowsLoaded = @@ROWCOUNT;
    SET @TotalRows  = @TotalRows + @RowsLoaded;

    UPDATE dbo.ETL_Control
    SET LastRowVersion = (SELECT MAX(rowversion) FROM NorthwindOLTP.dbo.Customers),
        LastLoadDate   = GETDATE()
    WHERE TableName = 'Customers';

    PRINT '>> DimCustomer: ' + CAST(@RowsLoaded AS VARCHAR) + ' new rows loaded';

    -- --------------------------------------------------------
    -- STEP 2: DimProduct (RowVersion incremental)
    -- --------------------------------------------------------
    DECLARE @LastRV_Product BINARY(8);
    SELECT @LastRV_Product = LastRowVersion
    FROM dbo.ETL_Control WHERE TableName = 'Products';

    INSERT INTO dbo.DimProduct (ProductID, ProductName, CategoryName, SupplierName, SupplierCountry, UnitPrice, Discontinued)
    SELECT
        p.ProductID, p.ProductName,
        c.CategoryName,
        s.CompanyName, s.Country,
        p.UnitPrice, p.Discontinued
    FROM NorthwindOLTP.dbo.Products   p
    LEFT JOIN NorthwindOLTP.dbo.Categories c ON p.CategoryID = c.CategoryID
    LEFT JOIN NorthwindOLTP.dbo.Suppliers  s ON p.SupplierID = s.SupplierID
    WHERE p.rowversion > @LastRV_Product
      AND NOT EXISTS (
          SELECT 1 FROM dbo.DimProduct dp WHERE dp.ProductID = p.ProductID
      );

    SET @RowsLoaded = @@ROWCOUNT;
    SET @TotalRows  = @TotalRows + @RowsLoaded;

    UPDATE dbo.ETL_Control
    SET LastRowVersion = (SELECT MAX(rowversion) FROM NorthwindOLTP.dbo.Products),
        LastLoadDate   = GETDATE()
    WHERE TableName = 'Products';

    PRINT '>> DimProduct: ' + CAST(@RowsLoaded AS VARCHAR) + ' new rows loaded';

    -- --------------------------------------------------------
    -- STEP 3: DimEmployee (RowVersion incremental)
    -- --------------------------------------------------------
    DECLARE @LastRV_Employee BINARY(8);
    SELECT @LastRV_Employee = LastRowVersion
    FROM dbo.ETL_Control WHERE TableName = 'Employees';

    INSERT INTO dbo.DimEmployee (EmployeeID, FullName, Title, City, Country, HireDate)
    SELECT
        e.EmployeeID,
        e.FirstName + ' ' + e.LastName,
        e.Title, e.City, e.Country, e.HireDate
    FROM NorthwindOLTP.dbo.Employees e
    WHERE e.rowversion > @LastRV_Employee
      AND NOT EXISTS (
          SELECT 1 FROM dbo.DimEmployee de WHERE de.EmployeeID = e.EmployeeID
      );

    SET @RowsLoaded = @@ROWCOUNT;
    SET @TotalRows  = @TotalRows + @RowsLoaded;

    UPDATE dbo.ETL_Control
    SET LastRowVersion = (SELECT MAX(rowversion) FROM NorthwindOLTP.dbo.Employees),
        LastLoadDate   = GETDATE()
    WHERE TableName = 'Employees';

    PRINT '>> DimEmployee: ' + CAST(@RowsLoaded AS VARCHAR) + ' new rows loaded';

    -- --------------------------------------------------------
    -- STEP 4: DimShipper (RowVersion incremental)
    -- --------------------------------------------------------
    DECLARE @LastRV_Shipper BINARY(8);
    SELECT @LastRV_Shipper = LastRowVersion
    FROM dbo.ETL_Control WHERE TableName = 'Shippers';

    INSERT INTO dbo.DimShipper (ShipperID, CompanyName, Phone)
    SELECT sh.ShipperID, sh.CompanyName, sh.Phone
    FROM NorthwindOLTP.dbo.Shippers sh
    WHERE sh.rowversion > @LastRV_Shipper
      AND NOT EXISTS (
          SELECT 1 FROM dbo.DimShipper ds WHERE ds.ShipperID = sh.ShipperID
      );

    SET @RowsLoaded = @@ROWCOUNT;
    SET @TotalRows  = @TotalRows + @RowsLoaded;

    UPDATE dbo.ETL_Control
    SET LastRowVersion = (SELECT MAX(rowversion) FROM NorthwindOLTP.dbo.Shippers),
        LastLoadDate   = GETDATE()
    WHERE TableName = 'Shippers';

    PRINT '>> DimShipper: ' + CAST(@RowsLoaded AS VARCHAR) + ' new rows loaded';

    -- --------------------------------------------------------
    -- STEP 5: DimDate (new dates only)
    -- --------------------------------------------------------
    INSERT INTO dbo.DimDate (DateKey, FullDate, Year, Quarter, QuarterName, Month, MonthName, Week, DayOfWeek, DayName, IsWeekend)
    SELECT DISTINCT
        CONVERT(INT, FORMAT(o.OrderDate, 'yyyyMMdd')),
        o.OrderDate,
        YEAR(o.OrderDate),
        DATEPART(QUARTER, o.OrderDate),
        'Q' + CAST(DATEPART(QUARTER, o.OrderDate) AS NVARCHAR),
        MONTH(o.OrderDate),
        DATENAME(MONTH, o.OrderDate),
        DATEPART(WEEK, o.OrderDate),
        DATEPART(WEEKDAY, o.OrderDate),
        DATENAME(WEEKDAY, o.OrderDate),
        CASE WHEN DATEPART(WEEKDAY, o.OrderDate) IN (1,7) THEN 1 ELSE 0 END
    FROM NorthwindOLTP.dbo.Orders o
    WHERE o.OrderDate IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM dbo.DimDate d
          WHERE d.DateKey = CONVERT(INT, FORMAT(o.OrderDate, 'yyyyMMdd'))
      );

    SET @RowsLoaded = @@ROWCOUNT;
    SET @TotalRows  = @TotalRows + @RowsLoaded;
    PRINT '>> DimDate: ' + CAST(@RowsLoaded AS VARCHAR) + ' new rows loaded';

    -- --------------------------------------------------------
    -- STEP 6: FactOrders (RowVersion incremental)
    -- --------------------------------------------------------
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
        o.OrderID, od.ProductID,
        CONVERT(INT, FORMAT(o.OrderDate,    'yyyyMMdd')),
        CONVERT(INT, FORMAT(o.RequiredDate, 'yyyyMMdd')),
        CONVERT(INT, FORMAT(o.ShippedDate,  'yyyyMMdd')),
        dc.CustomerSK, dp.ProductSK, de.EmployeeSK, ds.ShipperSK,
        od.Quantity, od.UnitPrice, od.Discount,
        CAST(od.UnitPrice * od.Quantity * (1 - od.Discount) AS MONEY),
        o.Freight
    FROM NorthwindOLTP.dbo.Orders      o
    JOIN NorthwindOLTP.dbo.OrderDetails od ON o.OrderID    = od.OrderID
    JOIN dbo.DimCustomer               dc  ON o.CustomerID = dc.CustomerID
    JOIN dbo.DimProduct                dp  ON od.ProductID = dp.ProductID
    JOIN dbo.DimEmployee               de  ON o.EmployeeID = de.EmployeeID
    JOIN dbo.DimShipper                ds  ON o.ShipVia    = ds.ShipperID
    JOIN dbo.DimDate                   dd  ON CONVERT(INT, FORMAT(o.OrderDate,'yyyyMMdd')) = dd.DateKey
    WHERE o.rowversion > @LastRV_Orders
      AND NOT EXISTS (
          SELECT 1 FROM dbo.FactOrders f
          WHERE f.OrderID = o.OrderID AND f.ProductID = od.ProductID
      );

    SET @RowsLoaded = @@ROWCOUNT;
    SET @TotalRows  = @TotalRows + @RowsLoaded;

    UPDATE dbo.ETL_Control
    SET LastRowVersion = (SELECT MAX(rowversion) FROM NorthwindOLTP.dbo.Orders),
        LastLoadDate   = GETDATE()
    WHERE TableName = 'Orders';

    PRINT '>> FactOrders: ' + CAST(@RowsLoaded AS VARCHAR) + ' new rows loaded';

    -- --------------------------------------------------------
    -- SUMMARY
    -- --------------------------------------------------------
    PRINT '============================================';
    PRINT 'ETL Completed: ' + CONVERT(VARCHAR, GETDATE(), 120);
    PRINT 'Total new rows loaded: ' + CAST(@TotalRows AS VARCHAR);
    PRINT 'Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, GETDATE()) AS VARCHAR) + ' seconds';
    PRINT '============================================';

END;
GO

-- ============================================================
-- TEST: Execute the incremental ETL
-- ============================================================
PRINT '>> Testing incremental ETL (should load 0 new rows - data already loaded)';
EXEC dbo.usp_ETL_LoadIncrementalDW;
GO

-- ============================================================
-- DEMO: Insert a new order in OLTP and verify it loads to DW
-- ============================================================
PRINT '>> Inserting test order in NorthwindOLTP...';

USE NorthwindOLTP;
GO

INSERT INTO dbo.Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipCountry)
VALUES ('ALFKI', 1, GETDATE(), DATEADD(DAY, 14, GETDATE()), 1, 25.50, 'Alfreds Futterkiste', 'Obere Str. 57', 'Berlin', 'Germany');

DECLARE @NewOrderID INT = SCOPE_IDENTITY();

INSERT INTO dbo.OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
VALUES (@NewOrderID, 1, 18.00, 10, 0.05);

PRINT '>> New OrderID created: ' + CAST(@NewOrderID AS VARCHAR);
GO

-- Now run ETL again - should detect and load the new order
PRINT '>> Running ETL again - should detect new order...';
USE NorthwindDW;
EXEC dbo.usp_ETL_LoadIncrementalDW;
GO

-- Verify new order appears in DW
PRINT '>> Verifying new order in DW...';
SELECT TOP 3
    f.OrderID,
    c.CompanyName   AS Customer,
    e.FullName      AS Employee,
    d.FullDate      AS OrderDate,
    f.ExtendedPrice AS Sales
FROM dbo.FactOrders  f
JOIN dbo.DimCustomer c ON f.CustomerSK  = c.CustomerSK
JOIN dbo.DimEmployee e ON f.EmployeeSK  = e.EmployeeSK
JOIN dbo.DimDate     d ON f.OrderDateKey = d.DateKey
ORDER BY f.OrderID DESC;
GO

PRINT '>> 05_DW_ETL_Incremental.sql executed successfully!';
GO
