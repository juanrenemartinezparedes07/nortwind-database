
CREATE   PROCEDURE dbo.DW_SyncFactSalesFromStaging
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PackageName NVARCHAR(100) = 'FactSales';
    DECLARE @NewLastRowVersion VARBINARY(8);

    ;WITH ResolvedSales AS
    (
        SELECT
            s.OrderID,
            s.ProductID,
            s.OrderDateKey,
            s.RequiredDateKey,
            s.ShippedDateKey,
            dc.CustomerSK,
            de.EmployeeSK,
            dp.ProductSK,
            ds.ShipperSK,
            dsl.ShipLocationSK,
            s.Quantity,
            s.UnitPrice,
            s.Discount,
            s.GrossAmount,
            s.DiscountAmount,
            s.NetAmount,
            s.FreightAmount
        FROM staging.Sales s
        INNER JOIN dbo.DimCustomer dc
            ON s.CustomerID COLLATE DATABASE_DEFAULT = dc.CustomerID COLLATE DATABASE_DEFAULT
        INNER JOIN dbo.DimEmployee de
            ON s.EmployeeID = de.EmployeeID
        INNER JOIN dbo.DimProduct dp
            ON s.ProductID = dp.ProductID
        LEFT JOIN dbo.DimShipper ds
            ON s.ShipperID = ds.ShipperID
        LEFT JOIN dbo.DimShipLocation dsl
            ON ISNULL(s.ShipName COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipName COLLATE DATABASE_DEFAULT, '')
            AND ISNULL(s.ShipAddress COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipAddress COLLATE DATABASE_DEFAULT, '')
            AND ISNULL(s.ShipCity COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipCity COLLATE DATABASE_DEFAULT, '')
            AND ISNULL(s.ShipRegion COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipRegion COLLATE DATABASE_DEFAULT, '')
            AND ISNULL(s.ShipPostalCode COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipPostalCode COLLATE DATABASE_DEFAULT, '')
            AND ISNULL(s.ShipCountry COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipCountry COLLATE DATABASE_DEFAULT, '')
    )
    UPDATE target
    SET
        target.OrderDateKey = source.OrderDateKey,
        target.RequiredDateKey = source.RequiredDateKey,
        target.ShippedDateKey = source.ShippedDateKey,
        target.CustomerSK = source.CustomerSK,
        target.EmployeeSK = source.EmployeeSK,
        target.ProductSK = source.ProductSK,
        target.ShipperSK = source.ShipperSK,
        target.ShipLocationSK = source.ShipLocationSK,
        target.Quantity = source.Quantity,
        target.UnitPrice = source.UnitPrice,
        target.Discount = source.Discount,
        target.GrossAmount = source.GrossAmount,
        target.DiscountAmount = source.DiscountAmount,
        target.NetAmount = source.NetAmount,
        target.FreightAmount = source.FreightAmount
    FROM dbo.FactSales target
    INNER JOIN ResolvedSales source
        ON target.OrderID = source.OrderID
        AND target.ProductID = source.ProductID;

    ;WITH ResolvedSales AS
    (
        SELECT
            s.OrderID,
            s.ProductID,
            s.OrderDateKey,
            s.RequiredDateKey,
            s.ShippedDateKey,
            dc.CustomerSK,
            de.EmployeeSK,
            dp.ProductSK,
            ds.ShipperSK,
            dsl.ShipLocationSK,
            s.Quantity,
            s.UnitPrice,
            s.Discount,
            s.GrossAmount,
            s.DiscountAmount,
            s.NetAmount,
            s.FreightAmount
        FROM staging.Sales s
        INNER JOIN dbo.DimCustomer dc
            ON s.CustomerID COLLATE DATABASE_DEFAULT = dc.CustomerID COLLATE DATABASE_DEFAULT
        INNER JOIN dbo.DimEmployee de
            ON s.EmployeeID = de.EmployeeID
        INNER JOIN dbo.DimProduct dp
            ON s.ProductID = dp.ProductID
        LEFT JOIN dbo.DimShipper ds
            ON s.ShipperID = ds.ShipperID
        LEFT JOIN dbo.DimShipLocation dsl
            ON ISNULL(s.ShipName COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipName COLLATE DATABASE_DEFAULT, '')
            AND ISNULL(s.ShipAddress COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipAddress COLLATE DATABASE_DEFAULT, '')
            AND ISNULL(s.ShipCity COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipCity COLLATE DATABASE_DEFAULT, '')
            AND ISNULL(s.ShipRegion COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipRegion COLLATE DATABASE_DEFAULT, '')
            AND ISNULL(s.ShipPostalCode COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipPostalCode COLLATE DATABASE_DEFAULT, '')
            AND ISNULL(s.ShipCountry COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipCountry COLLATE DATABASE_DEFAULT, '')
    )
    INSERT INTO dbo.FactSales
    (
        OrderID, ProductID, OrderDateKey, RequiredDateKey, ShippedDateKey,
        CustomerSK, EmployeeSK, ProductSK, ShipperSK, ShipLocationSK,
        Quantity, UnitPrice, Discount, GrossAmount, DiscountAmount, NetAmount,
        FreightAmount
    )
    SELECT
        source.OrderID,
        source.ProductID,
        source.OrderDateKey,
        source.RequiredDateKey,
        source.ShippedDateKey,
        source.CustomerSK,
        source.EmployeeSK,
        source.ProductSK,
        source.ShipperSK,
        source.ShipLocationSK,
        source.Quantity,
        source.UnitPrice,
        source.Discount,
        source.GrossAmount,
        source.DiscountAmount,
        source.NetAmount,
        source.FreightAmount
    FROM ResolvedSales source
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.FactSales target
        WHERE target.OrderID = source.OrderID
          AND target.ProductID = source.ProductID
    );

    SELECT TOP 1 @NewLastRowVersion = RowVersionValue
    FROM staging.Sales
    ORDER BY RowVersionValue DESC;

    IF @NewLastRowVersion IS NOT NULL
    BEGIN
        EXEC dbo.DW_UpdateLastPackageRowVersion
            @PackageName = @PackageName,
            @LastRowVersion = @NewLastRowVersion;
    END;
END;
