CREATE   PROCEDURE [Retail_OOM_Wrk].[usp_InventorySummary_Update]
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Wrk.usp_InventorySummary_Update';
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

        UPDATE invs
        SET invs.QtyOnFloor = ps.QtyOnFloor,
            invs.RateOfSale = CASE WHEN ib.InvBucketID = 'TB' THEN ps.RateOfSale ELSE NULL END,
            invs.QtyBO = CASE
                             WHEN ib.InvBucketID = 'TB' THEN
                                 CASE WHEN ps.Backordered IS NULL THEN 0 ELSE ps.Backordered END
                             WHEN ib.InvBucketID = 'DB' THEN
                                 CASE WHEN ps.BackorderedDespisedMCode IS NULL THEN 0 ELSE ps.BackorderedDespisedMCode END
                             ELSE
                                 0
                         END,
            invs.TBDaysOfSupply = CASE WHEN ib.InvBucketID = 'TB' THEN ps.TBDaysOfSupply ELSE NULL END,
            invs.Diff = pinv.QtyOnHand - CASE
                                             WHEN ib.InvBucketID = 'TB' THEN
                                                 CASE WHEN ps.Backordered IS NULL THEN 0 ELSE ps.Backordered END
                                             ELSE
                                                 0
                                         END,
            invs.MCodeDiff = pinv.QtyOnHand - CASE
                                                  WHEN ib.InvBucketID = 'DB' THEN
                                                      CASE
                                                          WHEN ps.BackorderedDespisedMCode IS NULL THEN
                                                              0
                                                          ELSE
                                                              ps.BackorderedDespisedMCode
                                                      END
                                                  ELSE
                                                      0
                                              END
        FROM [$(Source_Data)].[Retail_Miniapps].[Product] p
            INNER JOIN [Retail_OOM_Wrk].[PieceInventory] pinv
                ON p.ProductID = pinv.ProductID
            INNER JOIN [$(Source_Data)].[Retail_External].[InventorySubBuckets] isb
                ON isb.InvSubBucketID = pinv.InvSubBucketID
            INNER JOIN [$(Source_Data)].[Retail_External].[InventoryBuckets] ib
                ON ib.InvBucketID = isb.InvBucketID
            LEFT OUTER JOIN [Retail_OOM_Wrk].[PieceInventory_Surplus] ps
                ON ps.StoreID = pinv.StoreID
                   AND ps.ProductID = pinv.ProductID
            INNER JOIN [Retail_OOM_Enh].[InventorySummary] invs
                ON p.ProductID = invs.ProductID
                   AND p.StoreBrand_ID = invs.StoreBrandID
                   AND invs.LocationID = ps.StoreID
                   AND isb.InvSubBucketID = invs.InvSubBucketID
                   AND invs.ReasonCodeID = pinv.ReasonCodeID
                   AND invs.BodTransDate = pinv.TransDate;

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