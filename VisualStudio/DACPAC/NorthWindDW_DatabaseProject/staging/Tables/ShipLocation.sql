CREATE TABLE [staging].[ShipLocation] (
    [ShipName]        NVARCHAR (40) NULL,
    [ShipAddress]     NVARCHAR (60) NULL,
    [ShipCity]        NVARCHAR (15) NULL,
    [ShipRegion]      NVARCHAR (15) NULL,
    [ShipPostalCode]  NVARCHAR (10) NULL,
    [ShipCountry]     NVARCHAR (15) NULL,
    [RowVersionValue] VARBINARY (8) NULL
);

