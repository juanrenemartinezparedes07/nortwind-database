
CREATE   PROCEDURE dbo.DW_MergeIncrementalWarehouse
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.DW_MergeDimCustomerByRowVersion;
    EXEC dbo.DW_MergeDimEmployeeByRowVersion;
    EXEC dbo.DW_MergeDimProductByRowVersion;
    EXEC dbo.DW_MergeDimShipperByRowVersion;
    EXEC dbo.DW_MergeDimShipLocationByRowVersion;
    EXEC dbo.DW_MergeFactSalesByRowVersion;
END;
