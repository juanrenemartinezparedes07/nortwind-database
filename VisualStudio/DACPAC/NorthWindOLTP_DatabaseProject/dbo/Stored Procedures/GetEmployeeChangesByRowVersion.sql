
CREATE   PROCEDURE dbo.GetEmployeeChangesByRowVersion
    @LastRowVersion VARBINARY(8) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        EmployeeID,
        LastName,
        FirstName,
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
        ReportsTo,
        CONVERT(VARBINARY(8), [rowversion]) AS RowVersionValue
    FROM dbo.Employees
    WHERE 
        @LastRowVersion IS NULL
        OR [rowversion] > @LastRowVersion
    ORDER BY [rowversion];
END;
