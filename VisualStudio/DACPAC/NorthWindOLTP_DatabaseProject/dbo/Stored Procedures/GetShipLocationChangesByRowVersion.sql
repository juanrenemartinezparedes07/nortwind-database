
CREATE   PROCEDURE dbo.GetShipLocationChangesByRowVersion
    @LastRowVersion VARBINARY(8) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ShipName,
        ShipAddress,
        ShipCity,
        ShipRegion,
        ShipPostalCode,
        ShipCountry,
        MAX(CONVERT(VARBINARY(8), [rowversion])) AS RowVersionValue
    FROM dbo.Orders
    WHERE
        @LastRowVersion IS NULL
        OR [rowversion] > @LastRowVersion
    GROUP BY
        ShipName,
        ShipAddress,
        ShipCity,
        ShipRegion,
        ShipPostalCode,
        ShipCountry
    ORDER BY RowVersionValue;
END;
