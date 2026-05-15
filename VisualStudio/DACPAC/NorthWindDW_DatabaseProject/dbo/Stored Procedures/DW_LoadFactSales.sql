
CREATE   PROCEDURE dbo.DW_LoadFactSales
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.FactSales;

    DBCC CHECKIDENT ('dbo.FactSales', RESEED, 0);

    WITH SalesSource AS
    (
        SELECT
            o.OrderID,
            od.ProductID,

            CONVERT(INT, CONVERT(CHAR(8), o.OrderDate, 112)) AS OrderDateKey,

            CASE 
                WHEN o.RequiredDate IS NULL THEN NULL
                ELSE CONVERT(INT, CONVERT(CHAR(8), o.RequiredDate, 112))
            END AS RequiredDateKey,

            CASE 
                WHEN o.ShippedDate IS NULL THEN NULL
                ELSE CONVERT(INT, CONVERT(CHAR(8), o.ShippedDate, 112))
            END AS ShippedDateKey,

            o.CustomerID,
            o.EmployeeID,
            o.ShipVia AS ShipperID,

            o.ShipName,
            o.ShipAddress,
            o.ShipCity,
            o.ShipRegion,
            o.ShipPostalCode,
            o.ShipCountry,

            od.Quantity,
            od.UnitPrice,
            od.Discount,

            CAST(od.Quantity * od.UnitPrice AS MONEY) AS GrossAmount,
            CAST(od.Quantity * od.UnitPrice * od.Discount AS MONEY) AS DiscountAmount,
            CAST(od.Quantity * od.UnitPrice * (1 - od.Discount) AS MONEY) AS NetAmount,

            CAST(
                ISNULL(o.Freight, 0) 
                / COUNT(*) OVER (PARTITION BY o.OrderID)
                AS MONEY
            ) AS FreightAmount
        FROM NorthWindOLTP.dbo.Orders o
        INNER JOIN NorthWindOLTP.dbo.OrderDetails od
            ON o.OrderID = od.OrderID
    )
    INSERT INTO dbo.FactSales
    (
        OrderID,
        ProductID,
        OrderDateKey,
        RequiredDateKey,
        ShippedDateKey,
        CustomerSK,
        EmployeeSK,
        ProductSK,
        ShipperSK,
        ShipLocationSK,
        Quantity,
        UnitPrice,
        Discount,
        GrossAmount,
        DiscountAmount,
        NetAmount,
        FreightAmount
    )
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
    FROM SalesSource s
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
        AND ISNULL(s.ShipCountry COLLATE DATABASE_DEFAULT, '') = ISNULL(dsl.ShipCountry COLLATE DATABASE_DEFAULT, '');
END;
