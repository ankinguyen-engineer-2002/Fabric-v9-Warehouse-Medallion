CREATE   PROCEDURE [Retail_OOM_Wrk].[usp_PieceInventory_Surplus]
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Wrk.usp_PieceInventory_Surplus';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_OOM_Wrk';
    SET @DestinationTable = 'PieceInventory_Surplus';

    SELECT @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    --// AUDIT LOGGING END //--

    BEGIN TRY

        DECLARE @From DATE;
        DECLARE @To DATE;
        DECLARE @LocationID VARCHAR(10);
        DECLARE @TransDate DATE;

        SET @TransDate = GETDATE();
        SET @To = DATEADD(dd, -1, @TransDate);
        SET @From = DATEADD(dd, -90, @TransDate);
        SET @LocationID = 'ALL';

        TRUNCATE TABLE [Retail_OOM_Wrk].[PieceInventory_Surplus];

        INSERT INTO [Retail_OOM_Wrk].[PieceInventory_Surplus]
        (
            [StoreID],
            [ProductID],
            TBOnHand,
            DBOnHand,
            [RateOfSale],
            [TBDaysOfSupply],
            [DBDaysOfSupply]
        )
        SELECT  wpi.StoreID,
                ProductID,
                SUM(CASE WHEN isb.InvBucketID = 'TB' THEN wpi.QtyOnHand ELSE 0 END) AS TBOnHand,
                SUM(CASE WHEN isb.InvBucketID = 'DB' THEN wpi.QtyOnHand ELSE 0 END) AS DBOnHand,
                0 AS RateofSale,
                0 AS TBDaysofSupply,
                0 AS DBDaysofSupply
        FROM [Retail_OOM_Wrk].[PieceInventory] AS wpi
            INNER JOIN [$(Source_Data)].[Retail_External].[InventorySubBuckets] AS isb
                ON isb.InvSubBucketID = wpi.InvSubBucketID
        WHERE (isb.InvBucketID IN ('DB', 'TB'))
        GROUP BY wpi.StoreID,
                 ProductID;

        EXEC [Retail_OOM_Wrk].[usp_InventoryDetail];
        EXEC [Retail_OOM_Wrk].[usp_PieceInventory_Surplus_ROS] @From, @To;

        UPDATE [Retail_OOM_Wrk].[PieceInventory_Surplus]
        SET TBDaysOfSupply = TBOnHand / RateOfSale,
            DBDaysOfSupply = DBOnHand / RateOfSale
        WHERE RateOfSale <> 0;

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