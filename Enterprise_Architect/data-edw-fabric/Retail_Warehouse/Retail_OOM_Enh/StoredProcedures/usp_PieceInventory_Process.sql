CREATE   PROCEDURE [Retail_OOM_Enh].[usp_PieceInventory_Process]
AS
BEGIN

    SET NOCOUNT ON;

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Enh.usp_PieceInventory_Process';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_OOM_Enh';
    SET @DestinationTable = 'PieceInventory_Process';

    SELECT @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    --// AUDIT LOGGING END //--

    BEGIN TRY

        DECLARE @TransDate DATE;

        SET @TransDate = GETDATE();

        EXEC [Retail_OOM_Wrk].[usp_PieceInventory_Insert001] @TransDate;

        EXEC [Retail_OOM_Wrk].[usp_PieceInventory_Update001] @TransDate;

        EXEC [Retail_OOM_Wrk].[usp_PieceInventory_UpdateOrderInfo] @TransDate;

        EXEC [Retail_OOM_Enh].usp_Buckets_Insert;

        EXEC [Retail_OOM_Wrk].[usp_PieceInventory_SoftCommitted] @TransDate;

        EXEC [Retail_OOM_Wrk].[usp_PieceInventory_SoftCommitted_MFR_CWC_ASAP] @TransDate;

        EXEC [Retail_OOM_Wrk].[usp_PieceInventory_OISoftCommitted] @TransDate;

        EXEC [Retail_OOM_Wrk].[usp_PieceInventory_InternalTransfers];

        EXEC [Retail_OOM_Wrk].[usp_PieceInventory_InvSubBucketID] @TransDate;

        EXEC [Retail_OOM_Wrk].[usp_PieceInventory_OrderStoreBrandID] @TransDate;

        EXEC [Retail_OOM_Wrk].[usp_PieceInventory_Update002] @TransDate;

        EXEC [Retail_OOM_Enh].[usp_InventorySummary_Insert] @TransDate;

        EXEC [Retail_OOM_Wrk].[usp_PieceInventory_Surplus];

        EXEC Retail_OOM_Enh.[usp_PieceHist_Insert001] @TransDate;

        EXEC [Retail_OOM_Enh].[usp_PieceInventoryToDART_InsertUpdate];

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