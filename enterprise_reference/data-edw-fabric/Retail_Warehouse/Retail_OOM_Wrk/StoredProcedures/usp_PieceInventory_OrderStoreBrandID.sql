CREATE   PROCEDURE [Retail_OOM_Wrk].[usp_PieceInventory_OrderStoreBrandID] (@TransDate DATETIME)
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Wrk.usp_PieceInventory_OrderStoreBrandID';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_OOM_Wrk';
    SET @DestinationTable = 'PieceInventory';

    SELECT @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    --// AUDIT LOGGING END //--

    BEGIN TRY

        UPDATE [Retail_OOM_Wrk].[PieceInventory]
        SET StoreBrandID = s.StoreBrandID
        FROM [$(Source_Data)].[Retail_External].[store] AS s
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] AS oi
                ON s.LocationID = oi.BookedStoreID
            INNER JOIN [Retail_OOM_Wrk].[PieceInventory]
                ON oi.OrderID = [Retail_OOM_Wrk].[PieceInventory].OrderID
                   AND oi.ItemID = [Retail_OOM_Wrk].[PieceInventory].ItemID
        WHERE ([Retail_OOM_Wrk].[PieceInventory].TransDate = @TransDate)
              AND ([Retail_OOM_Wrk].[PieceInventory].SoftCommitted = 1)
              AND oi.TransCodeID NOT IN (60, 61, 63, 66, 67)
              AND s.StoreBrandID IS NOT NULL;

        UPDATE [Retail_OOM_Wrk].[PieceInventory]
        SET StoreBrandID = s.StoreBrandID
        FROM [Retail_OOM_Wrk].[PieceInventory]
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] AS oi
                ON [Retail_OOM_Wrk].[PieceInventory].OrderID = oi.OrderID
                   AND [Retail_OOM_Wrk].[PieceInventory].ItemID = oi.ItemID
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[Orders] AS o
                ON oi.OrderID = o.OrderID
            INNER JOIN [$(Source_Data)].[Retail_External].[store] AS s
                ON o.CustomerID = s.LocationID
        WHERE ([Retail_OOM_Wrk].[PieceInventory].TransDate = @TransDate)
              AND ([Retail_OOM_Wrk].[PieceInventory].SoftCommitted = 1)
              AND (oi.TransCodeID IN (60, 61, 63, 66, 67))
              AND (s.StoreBrandID IS NOT NULL);

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
        Exec [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase,@DestinationSchema,@DestinationTable

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