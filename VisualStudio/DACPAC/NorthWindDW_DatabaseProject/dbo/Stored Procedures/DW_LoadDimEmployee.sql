
CREATE   PROCEDURE dbo.DW_LoadDimEmployee
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.FactSales;
    DELETE FROM dbo.DimEmployee;

    SET IDENTITY_INSERT dbo.DimEmployee ON;

    INSERT INTO dbo.DimEmployee
    (
        EmployeeSK,
        EmployeeID,
        LastName,
        FirstName,
        FullName,
        Title,
        TitleOfCourtesy,
        BirthDate,
        HireDate,
        Address,
        City,
        Region,
        PostalCode,
        Country,
        HomePhone,
        Extension,
        ReportsTo
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY EmployeeID) AS EmployeeSK,
        EmployeeID,
        LastName,
        FirstName,
        CONCAT(FirstName, ' ', LastName) AS FullName,
        Title,
        TitleOfCourtesy,
        BirthDate,
        HireDate,
        Address,
        City,
        Region,
        PostalCode,
        Country,
        HomePhone,
        Extension,
        ReportsTo
    FROM NorthWindOLTP.dbo.Employees;

    SET IDENTITY_INSERT dbo.DimEmployee OFF;

    DECLARE @MaxSK INT;
    SELECT @MaxSK = MAX(EmployeeSK) FROM dbo.DimEmployee;

    DBCC CHECKIDENT ('dbo.DimEmployee', RESEED, @MaxSK);
END;
