CREATE TABLE [staging].[Customer] (
    [CustomerID]      NCHAR (5)     NULL,
    [CompanyName]     NVARCHAR (40) NULL,
    [ContactName]     NVARCHAR (30) NULL,
    [ContactTitle]    NVARCHAR (30) NULL,
    [Address]         NVARCHAR (60) NULL,
    [City]            NVARCHAR (15) NULL,
    [Region]          NVARCHAR (15) NULL,
    [PostalCode]      NVARCHAR (10) NULL,
    [Country]         NVARCHAR (15) NULL,
    [Phone]           NVARCHAR (24) NULL,
    [Fax]             NVARCHAR (24) NULL,
    [RowVersionValue] VARBINARY (8) NULL
);

