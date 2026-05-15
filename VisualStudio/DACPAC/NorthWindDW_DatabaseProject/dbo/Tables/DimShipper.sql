CREATE TABLE [dbo].[DimShipper] (
    [ShipperSK]   INT           IDENTITY (1, 1) NOT NULL,
    [ShipperID]   INT           NOT NULL,
    [CompanyName] NVARCHAR (40) NOT NULL,
    [Phone]       NVARCHAR (24) NULL,
    PRIMARY KEY CLUSTERED ([ShipperSK] ASC)
);

