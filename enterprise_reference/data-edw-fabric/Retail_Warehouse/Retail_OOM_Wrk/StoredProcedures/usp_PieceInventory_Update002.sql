CREATE   PROCEDURE [Retail_OOM_Wrk].[usp_PieceInventory_Update002] (@TransDate DATETIME)
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Wrk.usp_PieceInventory_Update002';
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
        SET ReasonCodeID = 'MFR'
        FROM [Retail_OOM_Wrk].[PieceInventory]
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[Product] p
                ON p.ProductID = [Retail_OOM_Wrk].[PieceInventory].ProductID
        WHERE p.PurchaseStatusCodeID IN ('D', 'T') AND ReasonCodeID IS NULL;

        /* Update Order info  */
        UPDATE pie
        SET SellingPrice = oi.CaseSellingPrice,
            OrderDate = oi.WrittenDate,
            DlvyDate = oi.DlvyDate
        FROM [Retail_OOM_Wrk].[PieceInventory] pie
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] oi
                ON oi.OrderID = pie.OrderID
                   AND oi.ItemID = pie.ItemID;

        /* District Pricing */
        UPDATE [Retail_OOM_Wrk].[PieceInventory]
        SET SellingPrice = p.SellingPrice
        FROM [Retail_OOM_Wrk].[PieceInventory]
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[product_pricing] AS p
                ON p.ProductID = [Retail_OOM_Wrk].[PieceInventory].ProductID
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[Store] AS s
                ON [Retail_OOM_Wrk].[PieceInventory].SourceID = s.SourceID
                   AND [Retail_OOM_Wrk].[PieceInventory].StoreID = s.StoreID
                   AND p.PrimaryKey = s.DistrictID
        WHERE [Retail_OOM_Wrk].[PieceInventory].SellingPrice = 0 AND (p.InvTypeCodeID = 6);

        /* Product Pricing */
        UPDATE [Retail_OOM_Wrk].[PieceInventory]
        SET SellingPrice = p.SellingPrice
        FROM [Retail_OOM_Wrk].[PieceInventory]
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[product_pricing] AS p
                ON p.ProductID = [Retail_OOM_Wrk].[PieceInventory].ProductID
        WHERE [Retail_OOM_Wrk].[PieceInventory].SellingPrice = 0 AND (p.InvTypeCodeID = 0);

        /* Get product Defualt Price if price not found*/

        UPDATE [Retail_OOM_Wrk].[PieceInventory]
        SET SellingPrice = p.CaseSellPrice
        FROM [Retail_OOM_Wrk].[PieceInventory]
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[Product] AS p
                ON p.ProductID = [Retail_OOM_Wrk].[PieceInventory].ProductID
        WHERE [Retail_OOM_Wrk].[PieceInventory].SellingPrice = 0;

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