
CREATE   PROCEDURE dbo.DW_MergeDimProductByRowVersion
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PackageName NVARCHAR(100) = 'DimProduct';
    DECLARE @LastRowVersion VARBINARY(8);
    DECLARE @NewLastRowVersion VARBINARY(8);

    IF NOT EXISTS (
        SELECT 1 FROM dbo.PackageConfig WHERE PackageName = @PackageName
    )
    BEGIN
        INSERT INTO dbo.PackageConfig (PackageName, LastRowVersion, LastLoadDate)
        VALUES (@PackageName, NULL, GETDATE());
    END;

    SELECT @LastRowVersion = LastRowVersion
    FROM dbo.PackageConfig
    WHERE PackageName = @PackageName;

    TRUNCATE TABLE staging.Product;

    INSERT INTO staging.Product
    (
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
        SupplierCountry,
        RowVersionValue
    )
    EXEC NorthWindOLTP.dbo.GetProductChangesByRowVersion
        @LastRowVersion = @LastRowVersion;

    UPDATE target
    SET
        target.ProductName = source.ProductName,
        target.QuantityPerUnit = source.QuantityPerUnit,
        target.UnitPrice = source.UnitPrice,
        target.UnitsInStock = source.UnitsInStock,
        target.UnitsOnOrder = source.UnitsOnOrder,
        target.ReorderLevel = source.ReorderLevel,
        target.Discontinued = source.Discontinued,
        target.CategoryName = source.CategoryName,
        target.CategoryDescription = source.CategoryDescription,
        target.SupplierName = source.SupplierName,
        target.SupplierContactName = source.SupplierContactName,
        target.SupplierContactTitle = source.SupplierContactTitle,
        target.SupplierCity = source.SupplierCity,
        target.SupplierRegion = source.SupplierRegion,
        target.SupplierCountry = source.SupplierCountry
    FROM dbo.DimProduct target
    INNER JOIN staging.Product source
        ON target.ProductID = source.ProductID;

    INSERT INTO dbo.DimProduct
    (
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
        source.ProductID,
        source.ProductName,
        source.QuantityPerUnit,
        source.UnitPrice,
        source.UnitsInStock,
        source.UnitsOnOrder,
        source.ReorderLevel,
        source.Discontinued,
        source.CategoryName,
        source.CategoryDescription,
        source.SupplierName,
        source.SupplierContactName,
        source.SupplierContactTitle,
        source.SupplierCity,
        source.SupplierRegion,
        source.SupplierCountry
    FROM staging.Product source
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.DimProduct target
        WHERE target.ProductID = source.ProductID
    );

    SELECT TOP 1 @NewLastRowVersion = RowVersionValue
    FROM staging.Product
    ORDER BY RowVersionValue DESC;

    IF @NewLastRowVersion IS NOT NULL
    BEGIN
        EXEC dbo.DW_UpdateLastPackageRowVersion
            @PackageName = @PackageName,
            @LastRowVersion = @NewLastRowVersion;
    END;
END;
