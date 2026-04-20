CREATE   PROCEDURE [Retail_OOM_Wrk].[usp_PieceInventory_Surplus_ROS]
(
    @FromDate DATETIME,
    @ToDate DATETIME
)
AS
BEGIN

    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Wrk.usp_PieceInventory_Surplus_ROS';
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

        SELECT  StoreID AS StrLocationID,
                ProductID,
                SUM(NetUnits) AS WrittenUnits,
                VendorID,
                1 AS MapType,
                NULL AS LocationID
        INTO #SlsUnits
        FROM [$(Source_Data)].[Retail_Corporate].[BtaData]
        WHERE TransCodeID IN
              (
                  SELECT TransCodeID FROM [$(Source_Data)].[Retail_External].[TransCodeMap]
              )
              AND Source = 'W'
              AND TransDate BETWEEN @FromDate AND @ToDate
        GROUP BY StoreID,
                 ProductID,
                 VendorID;

        /* Duplicate data for Store/Whs Locations */

        INSERT INTO #SlsUnits
        (
            StrLocationID,
            ProductID,
            WrittenUnits,
            LocationID,
            VendorID,
            MapType
        )
        SELECT  tlm.MapToLocationID,
                ProductID,
                SUM(WrittenUnits),
                tlm.LocationID,
                su.VendorID,
                3 MapType
        FROM #SlsUnits su
            INNER JOIN [Retail_OOM_Wrk].[TurnsLocationMap] tlm
                ON tlm.MapToLocationID = su.StrLocationID
        WHERE tlm.MapType = 3 AND tlm.LocationType <> 'D'
        GROUP BY tlm.MapToLocationID,
                 ProductID,
                 tlm.LocationID,
                 su.VendorID;

        /* Update DC*/
        UPDATE sc
        SET LocationID = m.MapToLocationID
        FROM #SlsUnits sc
            INNER JOIN [Retail_OOM_Wrk].[TurnsLocationMap] m
                ON sc.StrLocationID = m.LocationID
                   AND sc.MapType = m.MapType
        WHERE m.MapType = 1
              AND CASE WHEN m.VendorID = '*' THEN sc.VendorID ELSE m.VendorID END = sc.VendorID;

        UPDATE [Retail_OOM_Wrk].[PieceInventory_Surplus]
        SET RateOfSale = su.Units / 90
        FROM #SlsUnits u
            INNER JOIN
            (
                SELECT  LocationID,
                        ProductID,
                        SUM(WrittenUnits) AS Units
                FROM #SlsUnits
                GROUP BY LocationID,
                         ProductID
            ) su
                ON su.LocationID = u.LocationID
                   AND su.ProductID = u.ProductID
            INNER JOIN [Retail_OOM_Wrk].[PieceInventory_Surplus] wps
                ON wps.ProductID = su.ProductID
                   AND wps.StoreID = su.LocationID;

        DROP TABLE #SlsUnits;

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