
CREATE   PROCEDURE dbo.GetSalesChangesByRowVersion
    @LastRowVersion VARBINARY(8) = NULL
AS
BEGIN
    SET NOCOUNT ON;

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
        ) AS FreightAmount,

        CASE 
            WHEN CONVERT(VARBINARY(8), o.[rowversion]) >= CONVERT(VARBINARY(8), od.[rowversion])
                THEN CONVERT(VARBINARY(8), o.[rowversion])
            ELSE CONVERT(VARBINARY(8), od.[rowversion])
        END AS RowVersionValue

    FROM dbo.Orders o
    INNER JOIN dbo.OrderDetails od
        ON o.OrderID = od.OrderID
    WHERE
        @LastRowVersion IS NULL
        OR CONVERT(VARBINARY(8), o.[rowversion]) > @LastRowVersion
        OR CONVERT(VARBINARY(8), od.[rowversion]) > @LastRowVersion
    ORDER BY RowVersionValue;
END;
