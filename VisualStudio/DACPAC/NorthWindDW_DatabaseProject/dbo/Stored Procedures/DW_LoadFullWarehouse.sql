
CREATE   PROCEDURE dbo.DW_LoadFullWarehouse
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.DW_LoadDimCustomer;
    EXEC dbo.DW_LoadDimEmployee;
    EXEC dbo.DW_LoadDimShipper;
    EXEC dbo.DW_LoadDimProduct;
    EXEC dbo.DW_LoadDimShipLocation;
    EXEC dbo.DW_LoadFactSales;
END;
