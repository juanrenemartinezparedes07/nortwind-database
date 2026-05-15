
CREATE   PROCEDURE dbo.DW_MergeDimShipLocationByRowVersion
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PackageName NVARCHAR(100) = 'DimShipLocation';
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

    TRUNCATE TABLE staging.ShipLocation;

    INSERT INTO staging.ShipLocation
    (
        ShipName,
        ShipAddress,
        ShipCity,
        ShipRegion,
        ShipPostalCode,
        ShipCountry,
        RowVersionValue
    )
    EXEC NorthWindOLTP.dbo.GetShipLocationChangesByRowVersion
        @LastRowVersion = @LastRowVersion;

    INSERT INTO dbo.DimShipLocation
    (
        ShipName,
        ShipAddress,
        ShipCity,
        ShipRegion,
        ShipPostalCode,
        ShipCountry
    )
    SELECT
        source.ShipName,
        source.ShipAddress,
        source.ShipCity,
        source.ShipRegion,
        source.ShipPostalCode,
        source.ShipCountry
    FROM staging.ShipLocation source
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.DimShipLocation target
        WHERE ISNULL(target.ShipName COLLATE DATABASE_DEFAULT, '') = ISNULL(source.ShipName COLLATE DATABASE_DEFAULT, '')
          AND ISNULL(target.ShipAddress COLLATE DATABASE_DEFAULT, '') = ISNULL(source.ShipAddress COLLATE DATABASE_DEFAULT, '')
          AND ISNULL(target.ShipCity COLLATE DATABASE_DEFAULT, '') = ISNULL(source.ShipCity COLLATE DATABASE_DEFAULT, '')
          AND ISNULL(target.ShipRegion COLLATE DATABASE_DEFAULT, '') = ISNULL(source.ShipRegion COLLATE DATABASE_DEFAULT, '')
          AND ISNULL(target.ShipPostalCode COLLATE DATABASE_DEFAULT, '') = ISNULL(source.ShipPostalCode COLLATE DATABASE_DEFAULT, '')
          AND ISNULL(target.ShipCountry COLLATE DATABASE_DEFAULT, '') = ISNULL(source.ShipCountry COLLATE DATABASE_DEFAULT, '')
    );

    SELECT TOP 1 @NewLastRowVersion = RowVersionValue
    FROM staging.ShipLocation
    ORDER BY RowVersionValue DESC;

    IF @NewLastRowVersion IS NOT NULL
    BEGIN
        EXEC dbo.DW_UpdateLastPackageRowVersion
            @PackageName = @PackageName,
            @LastRowVersion = @NewLastRowVersion;
    END;
END;
