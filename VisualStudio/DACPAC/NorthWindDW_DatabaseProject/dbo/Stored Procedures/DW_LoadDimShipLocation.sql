
CREATE   PROCEDURE dbo.DW_LoadDimShipLocation
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.FactSales;
    DELETE FROM dbo.DimShipLocation;

    SET IDENTITY_INSERT dbo.DimShipLocation ON;

    WITH ShipLocations AS
    (
        SELECT DISTINCT
            ShipName,
            ShipAddress,
            ShipCity,
            ShipRegion,
            ShipPostalCode,
            ShipCountry
        FROM NorthWindOLTP.dbo.Orders
    )
    INSERT INTO dbo.DimShipLocation
    (
        ShipLocationSK,
        ShipName,
        ShipAddress,
        ShipCity,
        ShipRegion,
        ShipPostalCode,
        ShipCountry
    )
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY 
                ShipCountry,
                ShipCity,
                ShipName,
                ShipAddress,
                ShipPostalCode
        ) AS ShipLocationSK,
        ShipName,
        ShipAddress,
        ShipCity,
        ShipRegion,
        ShipPostalCode,
        ShipCountry
    FROM ShipLocations;

    SET IDENTITY_INSERT dbo.DimShipLocation OFF;

    DECLARE @MaxSK INT;
    SELECT @MaxSK = MAX(ShipLocationSK) FROM dbo.DimShipLocation;

    DBCC CHECKIDENT ('dbo.DimShipLocation', RESEED, @MaxSK);
END;
