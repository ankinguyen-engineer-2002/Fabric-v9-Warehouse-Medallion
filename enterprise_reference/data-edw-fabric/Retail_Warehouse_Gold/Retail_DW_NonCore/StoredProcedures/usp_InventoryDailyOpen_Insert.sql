CREATE PROCEDURE [Retail_DW_NonCore].[usp_InventoryDailyOpen_Insert]

AS
BEGIN
	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_OOM_Enh.usp_InventoryDailyOpen_Insert' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_OOM_Enh'
	SET @DestinationTable = 'InventoryDailyOpen';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

	BEGIN TRY

    DECLARE @TransDate DATE = GETDATE()-1

    --UPDATE wim
    --SET wim.ProductKey = pm.ProductKey
   -- FROM [$(Retail_Warehouse)].[Retail_OOM_Enh].[PieceInventoryToDART] wim 
    --INNER JOIN [Retail_DW_Core].[DimProductMaster] pm ON wim.ProductID = pm.SKU

    DELETE FROM [Retail_DW_NonCore].[FactInventoryDailyOpen]
    WHERE TransDateKey >= CONVERT(VARCHAR(8), @TransDate, 112);



    INSERT INTO [Retail_DW_NonCore].[FactInventoryDailyOpen]
    (
        TransDateKey,
        ProductID,
        SerialNbrID,
        LocationID,
        StoreBrandID,
        StorageID,
        MaterialCost,
        LandedFreight,
        Addon1Cost,
        Addon2Cost,
        Addon3Cost,
        Addon4Cost,
        TotalCost,
        Qty,
        QtyCommitted,
        QtySoftCommitted,
        DateAsIs,
        AsIsReasonCodeID,
        InvSubBucketID,
        PieceStatusID, 
		InvBucketID, 
		DateInStorageID, 
		DateInReasonCodeID
    )
    SELECT CONVERT(VARCHAR(8), TransDate, 112) TransDateKey,
           wpitd.ProductID,
           CASE
               WHEN wpitd.ReasonCodeID IS NOT NULL THEN
                   wpitd.SerialNbrID
               ELSE
                   NULL
           END AS SerialNbrID,
           wpitd.StoreID,
           wpitd.StoreBrandID,
           wpitd.StorageID,
           SUM(wpitd.MaterialCost) AS MaterialCost,
           SUM(wpitd.LandedFreight) AS LandedFreight,
           SUM(wpitd.Addon1Cost) AS Addon1Cost,
           SUM(wpitd.Addon2Cost) AS Addon2Cost,
           SUM(wpitd.Addon3Cost) AS Addon3Cost,
           SUM(wpitd.Addon4Cost) AS Addon4Cost,
           SUM(wpitd.TotalCost) AS TotalCost,
           SUM(QtyOnHand) AS Qty,
           SUM(QtyCommitted) AS QtyCommitted,
           SUM(SoftCommitted) AS QtySoftCommitted,
           wpitd.DateAsIs,
           wpitd.ReasonCodeID,
           wpitd.InvSubBucketID,
           wpitd.PieceStatusID, 
		   wpitd.InvBucketID, 
		   wpitd.DateInStorageID, 
		   wpitd.DateInReasonCodeID
    FROM [$(Retail_Warehouse)].[Retail_OOM_Enh].[PieceInventoryToDART] AS wpitd
    WHERE wpitd.TransDate >= @TransDate
    --AND wpitd.StoreID='401'
    GROUP BY CONVERT(VARCHAR(8), TransDate, 112),
             CASE
                 WHEN wpitd.ReasonCodeID IS NOT NULL THEN
                     wpitd.SerialNbrID
                 ELSE
                     NULL
             END,
             wpitd.ProductID,
             wpitd.StoreID,
             wpitd.StoreBrandID,
             wpitd.StorageID,
             wpitd.DateAsIs,
             wpitd.ReasonCodeID,
             wpitd.InvSubBucketID,
             wpitd.PieceStatusID, 
			 wpitd.InvBucketID, 
		     wpitd.DateInStorageID, 
		     wpitd.DateInReasonCodeID;

		SET @DateValue = GETDATE();

		SELECT
			@DateValue = CSTDateValue
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, 'Process Complete'
		);

		--- Update last modified in Table Dictionary 
		DECLARE @Exists INT
		SET @Exists = 
		(
			SELECT COUNT(*)
			FROM [$(ETL_Framework)].[DW_Developer].[TableDictionary]
			WHERE DatabaseName= @DestinationDatabase 
			AND SchemaName=  @DestinationSchema   
			AND TableName=  @DestinationTable
		)

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
				'EDW-Fabric',
				@DestinationDatabase,
				@DestinationSchema, 
				@DestinationTable,
				'Table',
				'Delta',
				@String
			)

		END

		UPDATE [$(ETL_Framework)].[DW_Developer].[TableDictionary]
		SET Modified = @DateValue
		WHERE DatabaseName = @DestinationDatabase 
		AND SchemaName = @DestinationSchema   
		AND TableName = @DestinationTable                       


		INSERT INTO [$(ETL_Framework)].[DW_Developer].[TableDictionary_UpdateLog]
		VALUES
		(
			@DestinationDatabase, 
			@DestinationSchema,
			@DestinationTable, 
			@DateValue
		);
		
	END TRY

	BEGIN CATCH
        
		DECLARE
			@ErrorMessage  VARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState    INT;

		SET @ErrorMessage = ERROR_MESSAGE();
		SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
		SET @ErrorState = ISNULL(ERROR_STATE(), 0);
		SET @DateValue = GETDATE();

		SELECT
			@DateValue = CSTDateValue
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, @ErrorMessage
		);

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	END CATCH
END;