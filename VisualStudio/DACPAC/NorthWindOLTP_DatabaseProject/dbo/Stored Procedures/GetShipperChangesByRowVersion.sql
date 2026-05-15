
CREATE   PROCEDURE dbo.GetShipperChangesByRowVersion
    @LastRowVersion VARBINARY(8) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ShipperID,
        CompanyName,
        Phone,
        CONVERT(VARBINARY(8), [rowversion]) AS RowVersionValue
    FROM dbo.Shippers
    WHERE 
        @LastRowVersion IS NULL
        OR [rowversion] > @LastRowVersion
    ORDER BY [rowversion];
END;
