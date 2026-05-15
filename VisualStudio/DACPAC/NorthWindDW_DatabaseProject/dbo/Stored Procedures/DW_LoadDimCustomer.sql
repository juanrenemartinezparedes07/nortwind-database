
CREATE   PROCEDURE dbo.DW_LoadDimCustomer
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.FactSales;
    DELETE FROM dbo.DimCustomer;

    SET IDENTITY_INSERT dbo.DimCustomer ON;

    INSERT INTO dbo.DimCustomer
    (
        CustomerSK,
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
        ROW_NUMBER() OVER (ORDER BY CustomerID) AS CustomerSK,
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
    FROM NorthWindOLTP.dbo.Customers;

    SET IDENTITY_INSERT dbo.DimCustomer OFF;

    DECLARE @MaxSK INT;
    SELECT @MaxSK = MAX(CustomerSK) FROM dbo.DimCustomer;

    DBCC CHECKIDENT ('dbo.DimCustomer', RESEED, @MaxSK);
END;
