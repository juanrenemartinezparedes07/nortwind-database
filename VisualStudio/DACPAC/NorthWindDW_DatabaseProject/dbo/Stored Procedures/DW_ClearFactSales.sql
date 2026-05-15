
CREATE   PROCEDURE dbo.DW_ClearFactSales
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.FactSales;
END;
