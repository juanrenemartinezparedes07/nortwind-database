
CREATE   PROCEDURE dbo.DW_MergeDimCustomerByRowVersion
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PackageName NVARCHAR(100) = 'DimCustomer';
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

    TRUNCATE TABLE staging.Customer;

    INSERT INTO staging.Customer
    (
        CustomerID,
        CompanyName,
        ContactName,
        ContactTitle,
        Address,
        City,
        Region,
        PostalCode,
        Country,
        Phone,
        Fax,
        RowVersionValue
    )
    EXEC NorthWindOLTP.dbo.GetCustomerChangesByRowVersion
        @LastRowVersion = @LastRowVersion;

    UPDATE target
    SET
        target.CompanyName = source.CompanyName,
        target.ContactName = source.ContactName,
        target.ContactTitle = source.ContactTitle,
        target.Address = source.Address,
        target.City = source.City,
        target.Region = source.Region,
        target.PostalCode = source.PostalCode,
        target.Country = source.Country,
        target.Phone = source.Phone,
        target.Fax = source.Fax
    FROM dbo.DimCustomer target
    INNER JOIN staging.Customer source
        ON target.CustomerID COLLATE DATABASE_DEFAULT = source.CustomerID COLLATE DATABASE_DEFAULT;

    INSERT INTO dbo.DimCustomer
    (
        CustomerID,
        CompanyName,
        ContactName,
        ContactTitle,
        Address,
        City,
        Region,
        PostalCode,
        Country,
        Phone,
        Fax
    )
    SELECT
        source.CustomerID,
        source.CompanyName,
        source.ContactName,
        source.ContactTitle,
        source.Address,
        source.City,
        source.Region,
        source.PostalCode,
        source.Country,
        source.Phone,
        source.Fax
    FROM staging.Customer source
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.DimCustomer target
        WHERE target.CustomerID COLLATE DATABASE_DEFAULT = source.CustomerID COLLATE DATABASE_DEFAULT
    );

    SELECT TOP 1 @NewLastRowVersion = RowVersionValue
    FROM staging.Customer
    ORDER BY RowVersionValue DESC;

    IF @NewLastRowVersion IS NOT NULL
    BEGIN
        EXEC dbo.DW_UpdateLastPackageRowVersion
            @PackageName = @PackageName,
            @LastRowVersion = @NewLastRowVersion;
    END;
END;
