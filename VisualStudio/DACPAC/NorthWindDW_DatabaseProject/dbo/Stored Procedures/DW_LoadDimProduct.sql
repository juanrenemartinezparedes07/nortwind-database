
CREATE   PROCEDURE dbo.DW_LoadDimProduct
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.FactSales;
    DELETE FROM dbo.DimProduct;

    SET IDENTITY_INSERT dbo.DimProduct ON;

    INSERT INTO dbo.DimProduct
    (
        ProductSK,
        ProductID,
        ProductName,
        QuantityPerUnit,
        UnitPrice,
        UnitsInStock,
        UnitsOnOrder,
        ReorderLevel,
        Discontinued,
        CategoryName,
        CategoryDescription,
        SupplierName,
        SupplierContactName,
        SupplierContactTitle,
        SupplierCity,
        SupplierRegion,
        SupplierCountry
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY p.ProductID) AS ProductSK,
        p.ProductID,
        p.ProductName,
        p.QuantityPerUnit,
        p.UnitPrice,
        p.UnitsInStock,
        p.UnitsOnOrder,
        p.ReorderLevel,
        p.Discontinued,
        c.CategoryName,
        c.Description AS CategoryDescription,
        s.CompanyName AS SupplierName,
        s.ContactName AS SupplierContactName,
        s.ContactTitle AS SupplierContactTitle,
        s.City AS SupplierCity,
        s.Region AS SupplierRegion,
        s.Country AS SupplierCountry
    FROM NorthWindOLTP.dbo.Products p
    LEFT JOIN NorthWindOLTP.dbo.Categories c
        ON p.CategoryID = c.CategoryID
    LEFT JOIN NorthWindOLTP.dbo.Suppliers s
        ON p.SupplierID = s.SupplierID;

    SET IDENTITY_INSERT dbo.DimProduct OFF;

    DECLARE @MaxSK INT;
    SELECT @MaxSK = MAX(ProductSK) FROM dbo.DimProduct;

    DBCC CHECKIDENT ('dbo.DimProduct', RESEED, @MaxSK);
END;
