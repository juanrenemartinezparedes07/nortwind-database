
CREATE   PROCEDURE dbo.DW_SyncDimShipperFromStaging
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PackageName NVARCHAR(100) = 'DimShipper';
    DECLARE @NewLastRowVersion VARBINARY(8);

    UPDATE target
    SET
        target.CompanyName = source.CompanyName,
        target.Phone = source.Phone
    FROM dbo.DimShipper target
    INNER JOIN staging.Shipper source
        ON target.ShipperID = source.ShipperID;

    INSERT INTO dbo.DimShipper
    (
        ShipperID,
        CompanyName,
        Phone
    )
    SELECT
        source.ShipperID,
        source.CompanyName,
        source.Phone
    FROM staging.Shipper source
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.DimShipper target
        WHERE target.ShipperID = source.ShipperID
    );

    SELECT TOP 1
        @NewLastRowVersion = RowVersionValue
    FROM staging.Shipper
    ORDER BY RowVersionValue DESC;

    IF @NewLastRowVersion IS NOT NULL
    BEGIN
        EXEC dbo.DW_UpdateLastPackageRowVersion
            @PackageName = @PackageName,
            @LastRowVersion = @NewLastRowVersion;
    END;
END;
