
CREATE   PROCEDURE dbo.GetProductChangesByRowVersion
    @LastRowVersion VARBINARY(8) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
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
        s.Country AS SupplierCountry,
        CONVERT(VARBINARY(8), p.[rowversion]) AS RowVersionValue
    FROM dbo.Products p
    LEFT JOIN dbo.Categories c
        ON p.CategoryID = c.CategoryID
    LEFT JOIN dbo.Suppliers s
        ON p.SupplierID = s.SupplierID
    WHERE 
        @LastRowVersion IS NULL
        OR p.[rowversion] > @LastRowVersion
    ORDER BY p.[rowversion];
END;
