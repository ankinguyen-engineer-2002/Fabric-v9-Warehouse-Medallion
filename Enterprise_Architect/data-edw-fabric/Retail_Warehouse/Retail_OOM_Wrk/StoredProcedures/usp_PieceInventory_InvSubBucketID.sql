CREATE    PROCEDURE [Retail_OOM_Wrk].[usp_PieceInventory_InvSubBucketID] (@TransDate DATETIME)
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_wrk.usp_PieceInventory_InvSubBucketID';
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

        WITH p
        AS
        (
            SELECT  ph.ProductID,
                    ph.SerialNbrID,
                    ph.ReasonCodeID,
                    ph.OrderTransCodeID,
                    ph.StorageID,
                    ph.SoftCommitted,
                    pe.InventoryTierID,
                    pe.ProductStatus,
                    ph.SourceID,
                    ph.TransDate,
                    p.PurchaseStatusID,
                    p.PurchaseStatusCodeID
            FROM [Retail_OOM_Wrk].[PieceInventory] AS ph
               -- INNER JOIN [$(Source_Data)].[Retail_Corporate].[ProductMaster] AS pe
                  --  ON ph.ProductID = pe.ProductID
                    INNER JOIN  [MasterData_Product_Enh].[ProductInfo] as pe
                    ON ph.ProductID = pe.SKU
                INNER JOIN [$(Source_Data)].[Retail_Corporate].[Product] AS p
                    ON p.ProductID = pe.SKU
            WHERE (ph.TransDate = @TransDate)
        )
        UPDATE ph
        SET InvSubBucketID = CASE
                                 -- SoftCommitted = 1
                                 WHEN p.SoftCommitted = 1
                                      AND p.OrderTransCodeID IS NOT NULL THEN
                                     'RIT'
                                 WHEN p.SoftCommitted = 1 THEN
                                     'RSV'
                                 -- StorageID = 'RESEARCH'
                                 WHEN p.StorageID = 'RESEARCH' THEN
                                     'NIL'
                                 -- ReasonCodeID logic
                                 WHEN p.ReasonCodeID IS NOT NULL
                                      AND rc.RollUpCode IS NULL THEN
                                     'ONS'
                                 WHEN p.ReasonCodeID IS NOT NULL
                                      AND rc.RollUpCode <> '1' THEN
                                     rc.RollUpCode
                                 -- PurchaseStatusCodeID
                                 WHEN p.PurchaseStatusCodeID IN ('D', 'T') THEN
                                     'MFR'
                                 -- ProductStatus
                                 WHEN p.ProductStatus = 'SPBUY' THEN
                                     'SPB'
                                 -- InventoryTierID
                                 WHEN p.InventoryTierID IN ('1.5', '2.0') THEN
                                     'BS'
                                 -- Default
                                 ELSE
                                     'GS'
                             END
        FROM [Retail_OOM_Wrk].[PieceInventory] ph
            INNER JOIN p
                ON ph.ProductID = p.ProductID
                   AND ph.SerialNbrID = p.SerialNbrID
                   AND ph.TransDate = p.TransDate
                   AND ph.SourceID = p.SourceID
            LEFT JOIN [MasterData_Ent].[ReasonCode] rc
                ON p.ReasonCodeID = rc.ReasonCodeID
        WHERE ph.TransDate = @TransDate;

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