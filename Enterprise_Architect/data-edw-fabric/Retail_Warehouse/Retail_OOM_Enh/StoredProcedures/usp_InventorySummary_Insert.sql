CREATE   PROCEDURE [Retail_OOM_Enh].[usp_InventorySummary_Insert] (@TransDate DATETIME)
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Enh.usp_InventorySummary_Insert';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_OOM_Enh';
    SET @DestinationTable = 'InventorySummary';

    SELECT @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    --// AUDIT LOGGING END //--

    BEGIN TRY

        DELETE FROM [Retail_OOM_Enh].[InventorySummary]
        WHERE BodTransDate = @TransDate;

        INSERT INTO [Retail_OOM_Enh].[InventorySummary]
        (
            [LocationID],
            [StoreBrandID],
            [ProductID],
            [InvSubBucketID],
            [ReasonCodeID],
            [BodTransDate],
            [ABC],
            [Qty],
            [MaterialCost],
            [LandedFreight],
            [Addon1Cost],
            [Addon2Cost],
            [Addon3Cost],
            [Addon4Cost],
            [TotalCost],
            [SellingPrice],
            DateCreated
        )
        SELECT  StoreID,
                StoreBrandID,
                ProductID,
                InvSubBucketID,
                ReasonCodeID,
                TransDate,
                ABC,
                COUNT(*) AS Qty,
                SUM(MaterialCost) AS MaterialCost,
                SUM(LandedFreight) AS LandedFreight,
                SUM(Addon1Cost) AS Addon1Cost,
                SUM(Addon2Cost) AS Addon2Cost,
                SUM(Addon3Cost) AS Addon3Cost,
                SUM(Addon4Cost) AS Addon4Cost,
                SUM(TotalCost) AS TotalCost,
                SUM(SellingPrice) AS SellingPrice,
                GETDATE()
        FROM [Retail_OOM_Wrk].[PieceInventory]
        WHERE InvSubBucketID IS NOT NULL AND ProductTypeID = 1
        GROUP BY StoreID,
                 StoreBrandID,
                 ProductID,
                 InvSubBucketID,
                 ReasonCodeID,
                 TransDate,
                 ABC;

        EXEC [Retail_OOM_Wrk].[usp_InventorySummary_Update];

        DELETE FROM [Retail_OOM_Enh].[InventorySummary]
        WHERE BodTransDate < DATEADD(DAY, -3, @TransDate)
              AND DATEPART(dw, BodTransDate) <> 2
              AND DATEPART(dd, BodTransDate) <> 1;


        --// AUDIT LOGGING START //--

        SET @DateValue = GETDATE();

        SELECT @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES
        (
            @String, @DateValue, @User, 'Process Complete'
        );

        --- Update last modified in Table Dictionary
        DECLARE @Exists INT;
        SET @Exists =
        (
            SELECT COUNT(*)
            FROM [$(ETL_Framework)].[DW_Developer].[TableDictionary]
            WHERE DatabaseName = @DestinationDatabase
                  AND SchemaName = @DestinationSchema
                  AND TableName = @DestinationTable
        );

        IF @Exists = 0
        BEGIN
            INSERT INTO [$(ETL_Framework)].[DW_Developer].[TableDictionary]
            (
                ServerName,
                DatabaseName,
                SchemaName,
                TableName,
                ObjectType,
                StorageType,
                UpdateQuery
            )
            VALUES
            (
                'EDW-Fabric', @DestinationDatabase, @DestinationSchema, @DestinationTable, 'Table', 'Delta', @String
            );
        END;

        UPDATE [$(ETL_Framework)].[DW_Developer].[TableDictionary]
        SET Modified = @DateValue
        WHERE DatabaseName = @DestinationDatabase
              AND SchemaName = @DestinationSchema
              AND TableName = @DestinationTable;

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[TableDictionary_UpdateLog]
        VALUES
        (
            @DestinationDatabase, @DestinationSchema, @DestinationTable, @DateValue
        );

        --// AUDIT LOGGING END //--

    END TRY
    BEGIN CATCH

        --// ERROR LOGGING START //--

        DECLARE @ErrorMessage VARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
        SET @ErrorState = ISNULL(ERROR_STATE(), 0);
        SET @DateValue = GETDATE();

        SELECT @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES
        (
            @String, @DateValue, @User, @ErrorMessage
        );

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

        --// ERROR LOGGING END //--

    END CATCH;

END;