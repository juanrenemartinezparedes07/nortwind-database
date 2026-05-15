
CREATE   PROCEDURE dbo.DW_MergeDimShipperByRowVersion
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PackageName NVARCHAR(100) = 'DimShipper';
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

    TRUNCATE TABLE staging.Shipper;

    INSERT INTO staging.Shipper
    (
        ShipperID,
        CompanyName,
        Phone,
        RowVersionValue
    )
    EXEC NorthWindOLTP.dbo.GetShipperChangesByRowVersion
        @LastRowVersion = @LastRowVersion;

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

    SELECT TOP 1 @NewLastRowVersion = RowVersionValue
    FROM staging.Shipper
    ORDER BY RowVersionValue DESC;

    IF @NewLastRowVersion IS NOT NULL
    BEGIN
        EXEC dbo.DW_UpdateLastPackageRowVersion
            @PackageName = @PackageName,
            @LastRowVersion = @NewLastRowVersion;
    END;
END;
