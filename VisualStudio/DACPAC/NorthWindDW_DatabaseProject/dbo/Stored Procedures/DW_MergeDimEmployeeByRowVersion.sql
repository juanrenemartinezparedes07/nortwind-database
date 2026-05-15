
CREATE   PROCEDURE dbo.DW_MergeDimEmployeeByRowVersion
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PackageName NVARCHAR(100) = 'DimEmployee';
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

    TRUNCATE TABLE staging.Employee;

    INSERT INTO staging.Employee
    (
        EmployeeID, LastName, FirstName, Title, TitleOfCourtesy,
        BirthDate, HireDate, Address, City, Region, PostalCode,
        Country, HomePhone, Extension, ReportsTo, RowVersionValue
    )
    EXEC NorthWindOLTP.dbo.GetEmployeeChangesByRowVersion
        @LastRowVersion = @LastRowVersion;

    UPDATE target
    SET
        target.LastName = source.LastName,
        target.FirstName = source.FirstName,
        target.FullName = CONCAT(source.FirstName, ' ', source.LastName),
        target.Title = source.Title,
        target.TitleOfCourtesy = source.TitleOfCourtesy,
        target.BirthDate = source.BirthDate,
        target.HireDate = source.HireDate,
        target.Address = source.Address,
        target.City = source.City,
        target.Region = source.Region,
        target.PostalCode = source.PostalCode,
        target.Country = source.Country,
        target.HomePhone = source.HomePhone,
        target.Extension = source.Extension,
        target.ReportsTo = source.ReportsTo
    FROM dbo.DimEmployee target
    INNER JOIN staging.Employee source
        ON target.EmployeeID = source.EmployeeID;

    INSERT INTO dbo.DimEmployee
    (
        EmployeeID, LastName, FirstName, FullName, Title, TitleOfCourtesy,
        BirthDate, HireDate, Address, City, Region, PostalCode,
        Country, HomePhone, Extension, ReportsTo
    )
    SELECT
        source.EmployeeID,
        source.LastName,
        source.FirstName,
        CONCAT(source.FirstName, ' ', source.LastName),
        source.Title,
        source.TitleOfCourtesy,
        source.BirthDate,
        source.HireDate,
        source.Address,
        source.City,
        source.Region,
        source.PostalCode,
        source.Country,
        source.HomePhone,
        source.Extension,
        source.ReportsTo
    FROM staging.Employee source
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.DimEmployee target
        WHERE target.EmployeeID = source.EmployeeID
    );

    SELECT TOP 1 @NewLastRowVersion = RowVersionValue
    FROM staging.Employee
    ORDER BY RowVersionValue DESC;

    IF @NewLastRowVersion IS NOT NULL
    BEGIN
        EXEC dbo.DW_UpdateLastPackageRowVersion
            @PackageName = @PackageName,
            @LastRowVersion = @NewLastRowVersion;
    END;
END;
