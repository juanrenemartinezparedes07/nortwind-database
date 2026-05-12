-- ============================================================
--  PROJECT  : Northwind OLTP
--  FILE     : 02_OLTP_SeedData.sql
--  DESC     : Copy data from original Northwind to NorthwindOLTP
--             Run AFTER 01_OLTP_Create.sql
-- ============================================================

USE NorthwindOLTP;
GO

-- ============================================================
-- 1. Categories
-- ============================================================
SET IDENTITY_INSERT dbo.Categories ON;
INSERT INTO dbo.Categories (CategoryID, CategoryName, Description)
SELECT CategoryID, CategoryName, CAST(Description AS NVARCHAR(500))
FROM Northwind.dbo.Categories;
SET IDENTITY_INSERT dbo.Categories OFF;
GO
PRINT '>> Categories loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ============================================================
-- 2. Suppliers
-- ============================================================
SET IDENTITY_INSERT dbo.Suppliers ON;
INSERT INTO dbo.Suppliers (SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Country, Phone, Fax)
SELECT SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Country, Phone, Fax
FROM Northwind.dbo.Suppliers;
SET IDENTITY_INSERT dbo.Suppliers OFF;
GO
PRINT '>> Suppliers loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ============================================================
-- 3. Products
-- ============================================================
SET IDENTITY_INSERT dbo.Products ON;
INSERT INTO dbo.Products (ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
SELECT ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued
FROM Northwind.dbo.Products;
SET IDENTITY_INSERT dbo.Products OFF;
GO
PRINT '>> Products loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ============================================================
-- 4. Employees (boss first to respect FK)
-- ============================================================
SET IDENTITY_INSERT dbo.Employees ON;
INSERT INTO dbo.Employees (EmployeeID, LastName, FirstName, Title, BirthDate, HireDate, Address, City, Country, ReportsTo)
SELECT EmployeeID, LastName, FirstName, Title, BirthDate, HireDate, Address, City, Country, ReportsTo
FROM Northwind.dbo.Employees WHERE ReportsTo IS NULL;

INSERT INTO dbo.Employees (EmployeeID, LastName, FirstName, Title, BirthDate, HireDate, Address, City, Country, ReportsTo)
SELECT EmployeeID, LastName, FirstName, Title, BirthDate, HireDate, Address, City, Country, ReportsTo
FROM Northwind.dbo.Employees WHERE ReportsTo IS NOT NULL;
SET IDENTITY_INSERT dbo.Employees OFF;
GO
PRINT '>> Employees loaded successfully';

-- ============================================================
-- 5. Customers
-- ============================================================
INSERT INTO dbo.Customers (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone)
SELECT CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone
FROM Northwind.dbo.Customers;
GO
PRINT '>> Customers loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ============================================================
-- 6. Shippers
-- ============================================================
SET IDENTITY_INSERT dbo.Shippers ON;
INSERT INTO dbo.Shippers (ShipperID, CompanyName, Phone)
SELECT ShipperID, CompanyName, Phone
FROM Northwind.dbo.Shippers;
SET IDENTITY_INSERT dbo.Shippers OFF;
GO
PRINT '>> Shippers loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ============================================================
-- 7. Orders
-- ============================================================
SET IDENTITY_INSERT dbo.Orders ON;
INSERT INTO dbo.Orders (OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipCountry)
SELECT OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipCountry
FROM Northwind.dbo.Orders;
SET IDENTITY_INSERT dbo.Orders OFF;
GO
PRINT '>> Orders loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ============================================================
-- 8. OrderDetails
-- ============================================================
INSERT INTO dbo.OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
SELECT OrderID, ProductID, UnitPrice, Quantity, Discount
FROM Northwind.dbo.[Order Details];
GO
PRINT '>> OrderDetails loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ============================================================
-- VALIDATION
-- ============================================================
PRINT '=== DATA VALIDATION ===';
SELECT 'Categories'  AS TableName, COUNT(*) AS Records FROM dbo.Categories
UNION ALL SELECT 'Suppliers',    COUNT(*) FROM dbo.Suppliers
UNION ALL SELECT 'Products',     COUNT(*) FROM dbo.Products
UNION ALL SELECT 'Employees',    COUNT(*) FROM dbo.Employees
UNION ALL SELECT 'Customers',    COUNT(*) FROM dbo.Customers
UNION ALL SELECT 'Shippers',     COUNT(*) FROM dbo.Shippers
UNION ALL SELECT 'Orders',       COUNT(*) FROM dbo.Orders
UNION ALL SELECT 'OrderDetails', COUNT(*) FROM dbo.OrderDetails;

-- Verify RowVersion is working
PRINT '=== ROWVERSION VERIFICATION ===';
SELECT TOP 3 OrderID, CustomerID, OrderDate, rowversion
FROM dbo.Orders
ORDER BY OrderID;
GO

PRINT '>> 02_OLTP_SeedData executed successfully!';
GO
