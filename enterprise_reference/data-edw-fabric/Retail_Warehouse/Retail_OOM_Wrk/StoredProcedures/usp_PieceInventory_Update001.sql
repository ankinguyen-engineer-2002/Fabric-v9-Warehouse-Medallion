CREATE   PROCEDURE [Retail_OOM_Wrk].[usp_PieceInventory_Update001] (@TransDate DATETIME)
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Wrk.usp_PieceInventory_Update001';
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

        UPDATE pie
        SET SoftCommitted = pie.QtyCommitted
        FROM [Retail_OOM_Wrk].[PieceInventory] pie;

        UPDATE pie
        SET StoreBrandID = p.StoreBrand_ID
        FROM [Retail_OOM_Wrk].[PieceInventory] pie,
             [$(Source_Data)].[Retail_Miniapps].[Product] p
        WHERE pie.ProductID = p.ProductID AND pie.TransDate = @TransDate;

        UPDATE pie
        SET StoreBrandID = s.StoreBrandID
        FROM [Retail_OOM_Wrk].[PieceInventory] pie,
             [$(Source_Data)].[Retail_External].[store] s
        WHERE pie.StoreID = s.LocationID
              AND pie.TransDate = @TransDate
              AND s.StoreBrandID IS NOT NULL;

        UPDATE [Retail_OOM_Wrk].[PieceInventory]
        SET ABC = slp.ABC
        FROM [Retail_OOM_Wrk].[PieceInventory] wpi
            INNER JOIN [$(Source_Data)].[Retail_External].[stocklocationproducts] slp
                ON wpi.StoreID = slp.ShipToLocationID
                   AND wpi.ProductID = slp.ProductID
        WHERE slp.ABC IS NOT NULL;

        UPDATE wp
        SET DateInStorageID =
            (
                SELECT TOP (1) TransDate
                FROM [$(Source_Data)].[Retail_Corporate].[InvactivityRaw]
                WHERE ProductID = wp.ProductID
                      AND SerialNbrID = wp.SerialNbrID
                      AND StoreID = wp.StoreID
                      AND
                      (
                          (InStorageID = wp.StorageID)
                          OR
                          (
                              InvTransTypeID IN (1, 2, 5, 6, 7, 11, 12, 17) AND AdjQty = 1
                          )
                      )
                ORDER BY TransDate DESC
            )
        FROM [Retail_OOM_Wrk].[PieceInventory] wp
        WHERE wp.StorageID NOT IN
              (
                  SELECT GroupID FROM [$(Source_Data)].[Retail_Corporate].[Groups]
              )
              AND CASE
                      WHEN StorageID NOT LIKE '[0-9][0-9]-[A-Z]-[0-9][0-9]'
                           AND StorageID NOT LIKE '[0-9][0-9][0-9]-[A-Z]-[0-9][0-9]' THEN
                          0
                      ELSE
                          1
                  END = 0;

        UPDATE wpi
        SET wpi.DateInReasonCodeID =
            (
                SELECT TOP (1) r.TransDate
                FROM [$(Source_Data)].[Retail_Corporate].[InvactivityRaw] r
                WHERE r.ProductID = wpi.ProductID
                      AND r.SerialNbrID = wpi.SerialNbrID
                      AND
                      (
                          (r.ReasonCodeID = wpi.ReasonCodeID OR r.InStorageID = wpi.ReasonCodeID)
                          OR (r.InvTransTypeID IN (1, 5, 6, 7, 11, 17) AND r.AdjQty = 1)
                          OR (r.InvTransTypeID = 13 AND r.AdjQty = 0)
                          OR (r.InvTransTypeID = 11 AND r.AdjQty = -1)
                      )
                ORDER BY r.TransDate DESC
            )
        FROM [Retail_OOM_Wrk].[PieceInventory] AS wpi
            INNER JOIN [$(Source_Data)].[Retail_Corporate].[Store] s
                ON s.StoreID = wpi.StoreID
        WHERE (
                  (s.LocnType <> 'ST' AND wpi.ReasonCodeID = 'FLR')
                  OR wpi.ReasonCodeID NOT IN ('NIL', 'RBC', 'FLR')
              );

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