CREATE PROCEDURE [Retail_OOM_Enh].[usp_Update_OrderTransDetailDailyStat]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_OOM_Enh.usp_Update_OrderTransDetailDailyStat';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_OOM_Enh';
	SET @DestinationTable = 'OrderTransDetailDailyStat';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @TransDate DATE;

		SET @TransDate = (GETDATE() - 1);

		TRUNCATE TABLE [Retail_OOM_Wrk].[OrderTransDetailDailyStat];

		--TRUNCATE TABLE [Retail_OOM_Enh].[OrderTransDetailDailyStat];

		INSERT INTO [Retail_OOM_Wrk].[OrderTransDetailDailyStat]
		(
			BookedStoreID
			, DCStoreID
			, TransDate
			, OrderID
			, ItemID
			, DeliveryStatus
			, DeliveryDate
			, NumDeliveryDateChanged
			, ScheduleSource
			, ScheduleBy
			, QuantityOrdered
			, QuantityCommitted
			, OrderAmount
		)
		
		SELECT	
			store_b.STORE_ID AS BookedStoreID
			, store_dc.STORE_ID AS DCStoreID
			, @TransDate
			, oi.OrderID
			, oi.ItemID
			, oi.DlvyStatus as DeliveryStatus
			, oi.DlvyDate  as DeliveryDate
			, otd.NumDeliveryDateChanged
			, CAST(NULL AS VARCHAR(10)) AS ScheduleSource
			, CAST(NULL AS VARCHAR(50)) AS ScheduleBy
			, oi.QtyOrdered AS QuantityOrdered
			, oi.QtyCommitted AS QuantityCommitted
			, (oi.QtyOrdered * oi.CaseSellingPrice) AS OrderAmount
		FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi
		LEFT OUTER JOIN [Retail_OOM_Enh].[OrderTransDetail] otd 
		ON oi.OrderID = otd.OrderID
		AND	oi.ItemID = otd.ItemID
		OUTER APPLY 
		(
			SELECT TOP 1 STORE_ID
			FROM 
			(
				SELECT oi2.BookedStoreID AS STORE_ID
				FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi2 
				WHERE oi2.OrderID = oi.OrderID
				and oi2.RecStatus <> 'D'
				
				UNION
				
				SELECT ii2.BookedStoreID AS STORE_ID
				FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem] ii2 
				WHERE ii2.OrderID = oi.OrderID
			) R
		) AS store_b
		OUTER APPLY 
		(
			SELECT TOP 1 STORE_ID
			FROM 
			(
				SELECT oi3.StoreID AS STORE_ID
				FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi3 
				WHERE oi3.OrderID = oi.OrderID
				and oi3.RecStatus <> 'D'
				
				UNION
			
				SELECT ii3.StoreID AS STORE_ID
				FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem] ii3 
				WHERE ii3.OrderID = oi.OrderID
			) R
		) AS store_dc
		WHERE oi.RecStatus <> 'D'
		AND oi.TransCodeID IN (0, 1, 7);

		--FirstScheduled=1  if first record with DeliveryStatus = SCH
		UPDATE src
		SET src.FirstSchedule = 1
		FROM [Retail_OOM_Wrk].[OrderTransDetailDailyStat] src
		WHERE src.DeliveryStatus = 'SCD'
		AND NOT EXISTS 
		(
			SELECT s.DeliveryStatus
			FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] s
			WHERE src.OrderID = s.OrderID
			AND src.ItemID = s.ItemID
			AND s.DeliveryStatus = 'SCD'
		);

		--ScheduledToday=1 if yesterday's record didn't have DeliveryStatus = SCH
		UPDATE src
		SET src.ScheduleToday = 1
		FROM [Retail_OOM_Wrk].[OrderTransDetailDailyStat] src
		INNER JOIN 
		(
			SELECT	
				otdds.OrderID
				, otdds.ItemID
			FROM [Retail_OOM_Enh].[OrderTransDetailDailyStat] otdds
			WHERE otdds.DeliveryStatus <> 'SCD'
			AND otdds.TransDate = DATEADD(dd, -1, @TransDate)
		) lst
		ON src.OrderID = lst.OrderID
		AND src.ItemID = lst.ItemID
		WHERE	src.DeliveryStatus = 'SCD';

		-- Set schedule today for same day scheduled
		UPDATE src
		SET src.ScheduleToday = 1
		FROM [Retail_OOM_Wrk].[OrderTransDetailDailyStat] src
		WHERE src.FirstSchedule = 1
		AND src.ScheduleToday IS NULL;

		--Set ScheduleChangeType based on OrderChangeRegistry
		SELECT	
			ocr.OrderID
			, ocr.OrderChangeRegistryTypeID
			, ocr.StaffID
			, ocr.SourceID
		INTO #ORCDetails
		FROM [Retail_OOM_Enh].[OrderChangeRegistry] ocr
		INNER JOIN 
		(
			SELECT	
				OrderID
				, MAX(OrderChangeRegistryID) AS OrderChangeRegistryID
			FROM [Retail_OOM_Enh].[OrderChangeRegistry]
			WHERE CommentDate = @TransDate
			AND OrderChangeRegistryTypeID BETWEEN 2 AND 5 -----New changed from 4 to 5
			GROUP BY OrderID
		) ocrList 
		ON ocr.OrderChangeRegistryID = ocrList.OrderChangeRegistryID;

		UPDATE src
		SET src.ScheduleChangeType = ocr.OrderChangeRegistryTypeID
		FROM [Retail_OOM_Wrk].[OrderTransDetailDailyStat] src
		INNER JOIN #ORCDetails ocr 
		ON ocr.OrderID = src.OrderID
		WHERE src.DeliveryStatus = 'SCD';

		UPDATE src
		SET src.ScheduleBy = ocr.StaffID
			, src.ScheduleSource = ocr.SourceID
		FROM [Retail_OOM_Wrk].[OrderTransDetailDailyStat] src
		INNER JOIN #ORCDetails ocr
		ON ocr.OrderID = src.OrderID
		WHERE src.ScheduleChangeType BETWEEN 2 AND 4
		AND src.ScheduleBy IS NULL;

		DROP TABLE #ORCDetails;

		INSERT INTO [Retail_OOM_Enh].[OrderTransDetailDailyStat]
		(
			TransDate
			, OrderID
			, ItemID
			, BookedStoreID
			, DCStoreID
			, DeliveryStatus
			, DeliveryDate
			, NumDeliveryDateChanged
			, ScheduleSource
			, ScheduleBy
			, ScheduleChangeType
			, SupplySource
			, SupplySourceDate
			, SupplySourceID
			, SupplySourceLineID
			, FirstSchedule
			, ScheduleToday
			, QuantityOrdered
			, QuantityCommitted
			, OrderAmount
		)
		
		SELECT	
			src.TransDate
			, src.OrderID
			, src.ItemID
			, src.BookedStoreID
			, src.DCStoreID
			, src.DeliveryStatus
			, src.DeliveryDate
			, src.NumDeliveryDateChanged
			, src.ScheduleSource
			, src.ScheduleBy
			, src.ScheduleChangeType
			, src.SupplySource
			, src.SupplySourceDate
			, src.SupplySourceID
			, src.SupplySourceLineID
			, COALESCE(src.FirstSchedule, 0)
			, COALESCE(src.ScheduleToday, 0)
			, src.QuantityOrdered
			, src.QuantityCommitted
			, src.OrderAmount
		FROM [Retail_OOM_Wrk].[OrderTransDetailDailyStat] src;

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
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable
	
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

END