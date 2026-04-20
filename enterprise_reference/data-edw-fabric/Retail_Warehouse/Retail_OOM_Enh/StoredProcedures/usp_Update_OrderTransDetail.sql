CREATE PROCEDURE [Retail_OOM_Enh].[usp_Update_OrderTransDetail]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_OOM_Enh.usp_Update_OrderTransDetail';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_OOM_Enh';
	SET @DestinationTable = 'OrderTransDetail';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_OOM_Enh].[OrderTransDetail];

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(OrderTransDetailID), 0) FROM [Retail_OOM_Enh].[OrderTransDetail]);
		
		IF OBJECT_ID('tempdb..#OrderTrans') IS NOT NULL 
		DROP TABLE #OrderTrans;

		SELECT
			 OrderID
			, ItemID
			, ProductID
			, WrittenDate
			, VendorModelNumber
			, KitGroupNumber
			, TransCodeID
			, Quantity
			, UnitListPrice
			, UnitSellPrice
			, UnitCost
			, OtherDiscount
			, ProductDiscountCode
			, SpecialOrderFlag
			, AsIsReasonCodeID
			, DateCreated
			, DateChanged
			, DeliveryDate
			, DeliveryStatus
			, DeliveryStatusAtPOS
			, DeliveryType
			, DeliveryStoreID
			, StockLocationID
			, ReasonCodeID
			, PriceOverrideStaffID
		INTO #OrderTrans
		FROM
		(
			/* Open or Voided OrderItem Lines */
			SELECT
				oi.OrderID
				, oi.ItemID
				, oi.ProductID
				, oi.WrittenDate
				, CASE WHEN oi.SpecOrderFlg = 1 THEN oi.SpecialOrder_Frame ELSE p.VendorModelNbr END AS VendorModelNumber
				, oi.KitGroupNumber
				, oi.TransCodeID
				, oi.QtyOrdered AS Quantity
				, oi.CasePriceDefault AS UnitListPrice
				, oi.CaseSellingPrice AS UnitSellPrice
				, oi.LineCost / NULLIF(oi.QtyOrdered, 0) AS UnitCost
				, oi.ProdDiscntAmt AS OtherDiscount
				, oi.PriceVarianceExceptionReasonCodeID AS ProductDiscountCode
				, oi.SpecOrderFlg AS SpecialOrderFlag
				, o.AsIsReasonCodeID
				, oi.DateCreated
				, oi.DateChanged
				, CAST(NULL AS DATE) AS DeliveryDate
				, CAST(NULL AS VARCHAR(10)) AS DeliveryStatus
				, CAST(NULL AS VARCHAR(10)) AS DeliveryStatusAtPOS
				, CAST(NULL AS VARCHAR(4)) AS DeliveryType
				, CAST(NULL AS VARCHAR(50)) AS DeliveryStoreID
				, oi.StoreID AS StockLocationID
				, oi.ReasonCodeID
				, oi.PriceOverrideStaffID
				--, ROW_NUMBER() OVER(PARTITION BY oi.OrderID, oi.ItemID ORDER BY oi.OrderID, oi.ItemID DESC) RowNum
			FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi
			INNER JOIN [$(Source_Data)].[Retail_Corporate].[Orders] o
			ON oi.OrderID = o.OrderID
			INNER JOIN [$(Source_Data)].[Retail_Corporate].[Product] p 
			ON oi.ProductID = p.ProductID
			WHERE o.RecStatus <> 'D'
			AND oi.RecStatus <> 'D'
			AND oi.ProductID <> 'RESELECT'

			UNION ALL

			/* Invoiced Lines that are not in OI */

			SELECT
				i.Base_OrderID AS OrderID
				, ii.ItemID
				, ii.ProductID
				, ii.WrittenDate
				, CASE WHEN ii.SpecOrderFlg = 1 THEN ii.SpecialOrder_Frame ELSE p.VendorModelNbr END AS VendorModelNumber
				, ii.KitGroupNumber
				, ii.TransCodeID
				, ii.QtyCommitted AS Quantity
				, ii.CasePriceDefault AS UnitListPrice
				, ii.CaseSellingPrice AS UnitSellPrice
				, ii.LineCost / NULLIF(ii.QtyOrdered, 0) AS UnitCost
				, ii.ProdDiscntAmt AS OtherDiscount
				, ii.PriceVarianceExceptionReasonCodeID AS ProductDiscountCode
				, ii.SpecOrderFlg AS SpecialOrderFlag
				, i.AsIsReasonCodeID
				, ii.DateCreated
				, ii.DateChanged
				, CAST(NULL AS DATE) AS DeliveryDate
				, CAST(NULL AS VARCHAR(10)) AS DeliveryStatus
				, CAST(NULL AS VARCHAR(10)) AS DeliveryStatusAtPOS
				, CAST(NULL AS VARCHAR(4)) AS DeliveryType
				, CAST(NULL AS VARCHAR(50)) AS DeliveryStoreID
				, ii.StoreID AS StockLocationID
				, ii.ReasonCodeID
				, ii.PriceOverrideStaffID
				--, ROW_NUMBER() OVER(PARTITION BY i.Base_OrderID, ii.ProductID, ii.ItemID ORDER BY COALESCE(ii.DateChanged, ii.DateCreated) DESC) RowNum
			FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem] ii
			INNER JOIN [$(Source_Data)].[Retail_Corporate].[Invoice] i 
			ON ii.OrderID = i.OrderID
			INNER JOIN [$(Source_Data)].[Retail_Corporate].[Product] p 
			ON ii.ProductID = p.ProductID
			WHERE ii.ProductID <> 'RESELECT'
			AND NOT EXISTS 
			(
				SELECT 1
				FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oit
				WHERE oit.OrderID = i.Base_OrderID
				AND oit.ItemID = ii.ItemID
				AND oit.ProductID <> 'RESELECT'
				AND oit.RecStatus <> 'D'
			 )
		) AS cs
		WHERE NOT EXISTS 
		(
			SELECT 1
			FROM [Retail_OOM_Enh].[OrderTransDetail] t
			WHERE t.OrderID = cs.OrderID
			AND t.ItemID = cs.ItemID
		);

		IF OBJECT_ID('tempdb..#OrderTransDetail') IS NOT NULL 
		DROP TABLE #OrderTransDetail;

		SELECT
         @MaxID + CAST(ROW_NUMBER() OVER (ORDER BY OrderID, ItemID) AS BIGINT) AS OrderTransDetailID
         , OrderID
		 , ItemID
		 , ProductID
		 , WrittenDate
		 , VendorModelNumber
		 , KitGroupNumber
		 , TransCodeID
		 , Quantity
		 , UnitListPrice
		 , UnitSellPrice
		 , UnitCost
		 , OtherDiscount
		 , ProductDiscountCode
		 , SpecialOrderFlag
		 , AsIsReasonCodeID
		 , DateCreated
		 , DateChanged
		 , DeliveryDate
		 , DeliveryStatus
		 , DeliveryStatusAtPOS
		 , DeliveryType
		 , DeliveryStoreID
		 , StockLocationID
		 , ReasonCodeID
		 , PriceOverrideStaffID
        INTO #OrderTransDetail
        FROM #OrderTrans;

		IF OBJECT_ID('tempdb..#OrderTransDetailHolding') IS NOT NULL 
		DROP TABLE #OrderTransDetailHolding;

		SELECT 
			OrderTransDetailID
			, OrderID
			, ItemID
			, ProductID
			, WrittenDate
			, VendorModelNumber
			, KitGroupNumber
			, TransCodeID
			, Quantity
			, UnitListPrice
			, UnitSellPrice
			, UnitCost
			, OtherDiscount
			, ProductDiscountCode
			, SpecialOrderFlag
			, AsIsReasonCodeID
			, DateCreated
			, DateChanged
			, DeliveryDate
			, DeliveryStatus
			, DeliveryStatusAtPOS
			, DeliveryType
			, DeliveryStoreID
			, StockLocationID
			, ReasonCodeID
			, PriceOverrideStaffID
		INTO #OrderTransDetailHolding
		FROM #OrderTransDetail;

		UPDATE otd
		SET TransCodeID = 99
		FROM #OrderTransDetailHolding otd
		LEFT JOIN 
		(
			SELECT	
				OrderID
				, ItemID
			FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] oi
			where oi.RecStatus <> 'D'
		
			UNION
		
			SELECT	
				Base_OrderID AS OrderID
				, ItemID
			FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem] ii
			INNER JOIN [$(Source_Data)].[Retail_Corporate].[Invoice] i
			ON i.OrderID = ii.OrderID
		) o 
		ON o.OrderID = otd.OrderID
		AND o.ItemID = otd.ItemID
		WHERE o.ItemID IS NULL;

		UPDATE otd
		SET otd.DeliveryDate = oi.DlvyDate
			, otd.DeliveryStatus = oi.DlvyStatus
			, otd.DeliveryStatusAtPOS = oi.DlvyStatus
			, otd.DeliveryType = oi.DlvyTypeCodeID
			, otd.TransCodeID = oi.TransCodeID
			, otd.DeliveryStoreID = oi.ShipLocnID
		FROM #OrderTransDetailHolding otd
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] AS oi 
		ON otd.OrderID = oi.OrderID
		AND otd.ItemID = oi.ItemID
		where oi.RecStatus <> 'D';

		UPDATE otd
		SET otd.DeliveryDate = oi.DlvyDate
			, otd.DeliveryStatus = oi.DlvyStatus
			, otd.DeliveryStatusAtPOS = oi.DlvyStatus
			, otd.DeliveryType = oi.DlvyTypeCodeID
			, otd.TransCodeID = oi.TransCodeID
			, otd.DeliveryStoreID = oi.ShipLocnID
		FROM #OrderTransDetailHolding otd
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[InvoiceItem] AS oi
		ON otd.OrderID = oi.OrderID
		AND otd.ItemID = oi.ItemID
		WHERE otd.DeliveryDate IS NULL;

		INSERT INTO [Retail_OOM_Enh].[OrderTransDetail]
		(
			OrderTransDetailID
			, OrderID
			, ItemID
			, ProductID
			, WrittenDate
			, VendorModelNumber
			, KitGroupNumber
			, TransCodeID
			, Quantity
			, UnitListPrice
			, UnitSellPrice
			, UnitCost
			, OtherDiscount
			, ProductDiscountCode
			, SpecialOrderFlag
			, AsIsReasonCodeID
			, DateCreated
			, DateChanged
			, DeliveryDate
			, DeliveryStatus
			, DeliveryStatusAtPOS
			, DeliveryType
			, DeliveryStoreID
			, StockLocationID
			, ReasonCodeID
			, PriceOverrideStaffID
		)

		SELECT
			OrderTransDetailID
			, OrderID
			, ItemID
			, ProductID
			, WrittenDate
			, VendorModelNumber
			, KitGroupNumber
			, TransCodeID
			, Quantity
			, UnitListPrice
			, UnitSellPrice
			, UnitCost
			, OtherDiscount
			, ProductDiscountCode
			, SpecialOrderFlag
			, AsIsReasonCodeID
			, DateCreated
			, DateChanged
			, DeliveryDate
			, DeliveryStatus
			, DeliveryStatusAtPOS
			, DeliveryType
			, DeliveryStoreID
			, StockLocationID
			, ReasonCodeID
			, PriceOverrideStaffID
		FROM #OrderTransDetailHolding;

		SELECT	
			RecordID AS OrderID
			, ItemID
		INTO #NewOrders
		FROM [Retail_OOM_Wrk].[OrderComments]
		WHERE IsChangeOrder = 1
		AND Comment LIKE '%Delivery Dates%'
		AND LEFT(Comment, 4) = 'Line'
		GROUP BY 
			RecordID
			, ItemID;

		SELECT	
			ocr.OrderID
			, ocr.ItemID
			, COUNT(*) NumDeliveryDateChanged
		INTO #Data
		FROM [Retail_OOM_Enh].[OrderChangeRegistry] ocr
		INNER JOIN #NewOrders wrk
		ON wrk.OrderID = ocr.OrderID
		AND wrk.ItemID = ocr.ItemID
		WHERE ocr.OrderChangeRegistryTypeID = 1
		AND CONVERT(DATE, ocr.ToValue) > CONVERT(DATE, ocr.FromValue)
		GROUP BY 
			ocr.OrderID
			, ocr.ItemID;

		UPDATE otd
		SET NumDeliveryDateChanged = d.NumDeliveryDateChanged
		FROM [Retail_OOM_Enh].[OrderTransDetail] otd
		INNER JOIN #Data d 
		ON d.OrderID = otd.OrderID
		AND d.ItemID = otd.ItemID;

		DROP TABLE #Data
				  , #NewOrders;

		SET @DateValue = GETDATE();

		SELECT
			@DateValue = CSTDateValue
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, 'Process Complete'
		);

	-- Update last modified in Table Dictionary 
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