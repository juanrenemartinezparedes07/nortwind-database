
CREATE   PROCEDURE dbo.DW_LoadDimShipper
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.FactSales;
    DELETE FROM dbo.DimShipper;

    SET IDENTITY_INSERT dbo.DimShipper ON;

    INSERT INTO dbo.DimShipper
    (
        ShipperSK,
        ShipperID,
        CompanyName,
        Phone
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY ShipperID) AS ShipperSK,
        ShipperID,
        CompanyName,
        Phone
    FROM NorthWindOLTP.dbo.Shippers;

    SET IDENTITY_INSERT dbo.DimShipper OFF;

    DECLARE @MaxSK INT;
    SELECT @MaxSK = MAX(ShipperSK) FROM dbo.DimShipper;

    DBCC CHECKIDENT ('dbo.DimShipper', RESEED, @MaxSK);
END;
