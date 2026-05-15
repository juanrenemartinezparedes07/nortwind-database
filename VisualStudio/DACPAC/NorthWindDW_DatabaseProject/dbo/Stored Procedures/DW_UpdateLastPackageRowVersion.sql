
CREATE   PROCEDURE dbo.DW_UpdateLastPackageRowVersion
    @PackageName NVARCHAR(100),
    @LastRowVersion VARBINARY(8)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM dbo.PackageConfig 
        WHERE PackageName = @PackageName
    )
    BEGIN
        UPDATE dbo.PackageConfig
        SET 
            LastRowVersion = @LastRowVersion,
            LastLoadDate = GETDATE()
        WHERE PackageName = @PackageName;
    END
    ELSE
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
            @LastRowVersion,
            GETDATE()
        );
    END;
END;
