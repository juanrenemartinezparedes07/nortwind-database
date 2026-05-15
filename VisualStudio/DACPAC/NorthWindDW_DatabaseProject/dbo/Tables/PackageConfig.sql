CREATE TABLE [dbo].[PackageConfig] (
    [PackageName]    NVARCHAR (100) NOT NULL,
    [LastRowVersion] VARBINARY (8)  NULL,
    [LastLoadDate]   DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([PackageName] ASC)
);

