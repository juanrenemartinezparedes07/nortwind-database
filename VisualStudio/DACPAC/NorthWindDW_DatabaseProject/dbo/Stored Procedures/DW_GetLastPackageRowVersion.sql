
CREATE   PROCEDURE dbo.DW_GetLastPackageRowVersion
    @PackageName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.PackageConfig 
        WHERE PackageName = @PackageName
    )
    BEGIN
        INSERT INTO dbo.PackageConfig
        (
            PackageName,
            LastRowVersion,
            LastLoadDate
        )
        VALUES
        (
            @PackageName,
            NULL,
            GETDATE()
        );
    END;

    SELECT
        PackageName,
        LastRowVersion,
        LastLoadDate
    FROM dbo.PackageConfig
    WHERE PackageName = @PackageName;
END;
