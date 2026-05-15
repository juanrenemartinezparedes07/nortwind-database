
CREATE   PROCEDURE dbo.GetCustomerChangesByRowVersion
    @LastRowVersion VARBINARY(8) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
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
        CONVERT(VARBINARY(8), [rowversion]) AS RowVersionValue
    FROM dbo.Customers
    WHERE 
        @LastRowVersion IS NULL
        OR [rowversion] > @LastRowVersion
    ORDER BY [rowversion];
END;
