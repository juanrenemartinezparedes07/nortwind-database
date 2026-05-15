CREATE TABLE [staging].[Product] (
    [ProductID]            INT           NULL,
    [ProductName]          NVARCHAR (40) NULL,
    [QuantityPerUnit]      NVARCHAR (20) NULL,
    [UnitPrice]            MONEY         NULL,
    [UnitsInStock]         SMALLINT      NULL,
    [UnitsOnOrder]         SMALLINT      NULL,
    [ReorderLevel]         SMALLINT      NULL,
    [Discontinued]         BIT           NULL,
    [CategoryName]         NVARCHAR (15) NULL,
    [CategoryDescription]  NTEXT         NULL,
    [SupplierName]         NVARCHAR (40) NULL,
    [SupplierContactName]  NVARCHAR (30) NULL,
    [SupplierContactTitle] NVARCHAR (30) NULL,
    [SupplierCity]         NVARCHAR (15) NULL,
    [SupplierRegion]       NVARCHAR (15) NULL,
    [SupplierCountry]      NVARCHAR (15) NULL,
    [RowVersionValue]      VARBINARY (8) NULL
);

