CREATE PROCEDURE [Retail_Sales_Enh].[usp_Update_SalesOrderLineHistory]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Enh.usp_Update_SalesOrderLineHistory';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_Sales_Enh';
	SET @DestinationTable = 'SalesOrderLineHistory';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

	BEGIN TRY

		--TRUNCATE TABLE [Retail_Sales_Enh].[SalesOrderLineHistory];

		DECLARE @StartDate DATE = GETDATE()-3
				, @EndDate DATE = GETDATE();
				
		DELETE FROM [Retail_Sales_Enh].[SalesOrderLineHistory]
		WHERE COALESCE(CAST(DateChanged AS DATE), CAST(DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;

		IF OBJECT_ID('tempdb..#SalesOrderLineHistoryHolding') IS NOT NULL 
		DROP TABLE #SalesOrderLineHistoryHolding;

		SELECT  
			Source
			, SourceSystem
			, BtaID
			, CASE WHEN Source = 'W' THEN 1 ELSE 6 END AS SalesDataTypeKey
			, AsIsSaleReasonCodeID
			, BaseOrderID
			, SourceOrderID
			, TransDate
			, CONVERT(VARCHAR(8), TransDate, 112) AS TransDateKey
			, LineNumber
			, LineStatus
			, ItemDescription
			, SKU
			, QuantityOrdered
			, NetPrice
			, ProtectionPlanSKU
			, ProtectionPlanID
			, ProtectionPlanPrice
			, ProtectionPlanCost
			, IsServiceItem
			, HasProtectionPlan
			, WarrantyEndDate
			, StoreID
			, KitOrPackageQuantity
			, KitOrPackageSKU
			, NetCost
			, CategoryID
			, GroupID
			, CustomerID
			, DiscountCode
			, DeliveryStoreID
			, DeliveryTypeCodeID
			, SalesPersonID
			, ServiceTypeID
			, TransCodeID
			, VendorID
			, VoidedReasonCodeID
			, DateChanged
			, DateCreated
			, PurchaseStatusCodeID
			, SpecialOrder
			, UpdateDateTime
			, UpdateTypeID
			, CAST(NULL AS VARCHAR(50)) AS SuperOrderID
			, CAST(NULL AS DATE) AS OrderDate
			, CAST(NULL AS BIGINT) AS OrderDateKey
			, CAST(NULL AS VARCHAR(50)) AS TransCodeGroup
			, CAST(NULL AS VARCHAR(10)) AS ItemCommCategory
			, CAST(NULL AS VARCHAR(20)) AS DeliveryStatus
			, CAST(NULL AS VARCHAR(50)) AS ProductDiscountCode
			, CAST(NULL AS VARCHAR(50)) AS PriceVarianceExceptionReasonCodeID
			, CAST(NULL AS VARCHAR(50)) AS PriceOverrideStaffID
			, CAST(NULL AS VARCHAR(50)) AS FRLocationID
			, CAST(NULL AS INT) AS GrossMultiplier
			, CAST(NULL AS VARCHAR(50)) AS REACCategory
		INTO #SalesOrderLineHistoryHolding
		FROM [Retail_Sales].[SalesOrderLineHistory]
		WHERE COALESCE(CAST(DateChanged AS DATE), CAST(DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;

		IF OBJECT_ID('tempdb..#OrderItemProductInfo') IS NOT NULL 
		DROP TABLE #OrderItemProductInfo;

		SELECT
			OrderID
			, ItemID
			, ReasonCodeID
			, DateChanged
			, DateCreated
		INTO #OrderItemProductInfo
		FROM [$(Source_Data)].[Retail_Corporate].[OrderItem_ProductInfo]
		WHERE OrderID IN
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales].[SalesOrderLineHistory]
		);

		IF OBJECT_ID('tempdb..#InvoiceItemProductInfo') IS NOT NULL 
		DROP TABLE #InvoiceItemProductInfo;

		SELECT
			OrderID
			, ItemID
			, ReasonCodeID
			, DateChanged
			, DateCreated
		INTO #InvoiceItemProductInfo
		FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem_ProductInfo]
		WHERE OrderID IN
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales].[SalesOrderLineHistory]
		);

		IF OBJECT_ID('tempdb..#OrderItemCommissionInfo') IS NOT NULL 
		DROP TABLE #OrderItemCommissionInfo;

		SELECT 
			OrderID
			, ItemID
			, ItemCommCategory
			, DateChanged
			, DateCreated
		INTO #OrderItemCommissionInfo
		FROM [$(Source_Data)].[Retail_Corporate].[OrderItem_CommissionInfo]
		WHERE OrderID IN
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales].[SalesOrderLineHistory]
		);

		IF OBJECT_ID('tempdb..#InvoiceItemCommissionInfo') IS NOT NULL 
		DROP TABLE #InvoiceItemCommissionInfo;

		SELECT 
			OrderID
			, ItemID
			, ItemCommCategory
			, DateChanged
			, DateCreated
		INTO #InvoiceItemCommissionInfo
		FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem_CommissionInfo]
		WHERE OrderID IN
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales].[SalesOrderLineHistory]
		);

		IF OBJECT_ID('tempdb..#OrderItem') IS NOT NULL 
		DROP TABLE #OrderItem;

		SELECT
			OrderID
			, ItemID
			, DlvyStatus AS DeliveryStatus
			, ProdDiscntCode AS ProductDiscountCode
			, PriceVarianceExceptionReasonCodeID
			, PriceOverrideStaffID
			, DateChanged
			, DateCreated
		INTO #OrderItem
		FROM [$(Source_Data)].[Retail_Corporate].[OrderItem]
		WHERE OrderID IN
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales].[SalesOrderLineHistory]
		);

		IF OBJECT_ID('tempdb..#InvoiceItem') IS NOT NULL 
		DROP TABLE #InvoiceItem;

		SELECT
			OrderID
			, ItemID
			, DlvyStatus AS DeliveryStatus
			, ProdDiscntCode AS ProductDiscountCode
			, PriceVarianceExceptionReasonCodeID
			, PriceOverrideStaffID
			, DateChanged
			, DateCreated
		INTO #InvoiceItem
		FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem]
		WHERE OrderID IN
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales].[SalesOrderLineHistory]
		);

		IF OBJECT_ID('tempdb..#Orders') IS NOT NULL 
		DROP TABLE #Orders;

		SELECT
			OrderID
			, OrderDate
			, DateChanged
			, DateCreated
		INTO #Orders
		FROM [$(Source_Data)].[Retail_Corporate].[Orders]
		WHERE OrderID IN
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales].[SalesOrderLineHistory]
		);
		
		UPDATE #SalesOrderLineHistoryHolding
		SET SalesPersonID = StoreID
		WHERE SalesPersonID IS NULL
		OR SalesPersonID = '<No Value>';

		UPDATE bta
		SET bta.TransCodeGroup = tcm.TransCodeGroup
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN [$(Source_Data)].[Retail_External].[TransCodeMap] tcm
		ON tcm.TransCodeID = bta.TransCodeID
		AND tcm.TransCodeGroup = 'SREAT';

		UPDATE bta
		SET bta.AsIsSaleReasonCodeID = oipi.ReasonCodeID
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN #OrderItemProductInfo oipi
		ON oipi.OrderID = bta.SourceOrderID
		AND oipi.ItemID = bta.LineNumber
		WHERE oipi.ReasonCodeID IS NOT NULL;

		UPDATE bta
		SET bta.AsIsSaleReasonCodeID = iipi.ReasonCodeID
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN #InvoiceItemProductInfo iipi
		ON iipi.OrderID = bta.SourceOrderID
		AND iipi.ItemID = bta.LineNumber
		WHERE iipi.ReasonCodeID IS NOT NULL
		AND bta.Source = 'W';

		UPDATE bta
		SET bta.ItemCommCategory = oici.ItemCommCategory
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN
		(
			SELECT OrderID
				   , ItemID
				   , MAX(ItemCommCategory) AS ItemCommCategory
			FROM #OrderItemCommissionInfo
			WHERE ItemCommCategory IS NOT NULL
			GROUP BY OrderID
				   , ItemID
		 ) oici
		 ON bta.SourceOrderID = oici.OrderID
		 AND bta.LineNumber = oici.ItemID;

		UPDATE bta
		SET bta.ItemCommCategory = oici.ItemCommCategory
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN
		(
			SELECT OrderID
				   , ItemID
				   , MAX(ItemCommCategory) AS ItemCommCategory
			FROM #InvoiceItemCommissionInfo
			WHERE ItemCommCategory IS NOT NULL
			GROUP BY OrderID
				   , ItemID
		 ) oici
		 ON bta.SourceOrderID = oici.OrderID
		 AND bta.LineNumber = oici.ItemID;

		UPDATE bta
		SET bta.DeliveryStatus = oi.DeliveryStatus
			, bta.ProductDiscountCode = oi.ProductDiscountCode
			, bta.PriceVarianceExceptionReasonCodeID = oi.PriceVarianceExceptionReasonCodeID
			, bta.PriceOverrideStaffID = oi.PriceOverrideStaffID
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN #OrderItem oi
		ON bta.SourceOrderID = oi.OrderID
		AND bta.LineNumber = oi.ItemID;

		UPDATE bta
		SET bta.DeliveryStatus = ii.DeliveryStatus
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN #InvoiceItem ii
		ON bta.SourceOrderID = ii.OrderID
		AND bta.LineNumber = ii.ItemID
		WHERE bta.DeliveryStatus IS NULL;

		UPDATE bta
		SET bta.ProductDiscountCode = ii.ProductDiscountCode
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN #InvoiceItem ii
		ON bta.SourceOrderID = ii.OrderID
		AND bta.LineNumber = ii.ItemID
		WHERE bta.ProductDiscountCode IS NULL;

		UPDATE bta
		SET bta.PriceVarianceExceptionReasonCodeID = ii.PriceVarianceExceptionReasonCodeID
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN #InvoiceItem ii
		ON bta.SourceOrderID = ii.OrderID
		AND bta.LineNumber = ii.ItemID
		WHERE bta.PriceVarianceExceptionReasonCodeID IS NULL;

		UPDATE bta
		SET bta.PriceOverrideStaffID  = ii.PriceOverrideStaffID
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN #InvoiceItem ii
		ON bta.SourceOrderID = ii.OrderID
		AND bta.LineNumber = ii.ItemID
		WHERE bta.PriceOverrideStaffID IS NULL;

		UPDATE bta
		SET bta.OrderDate = o.OrderDate
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN #Orders o
		ON o.OrderID = bta.SourceOrderID

		UPDATE bta
		SET bta.OrderDateKey = CONVERT(VARCHAR(8), o.OrderDate, 112)
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN #Orders o
		ON o.OrderID = bta.SourceOrderID;

		/*Historical Orders*/
		UPDATE bta
		SET bta.OrderDateKey = odk.OrderDateKey
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN
		(
			SELECT 
				SourceOrderID
				, CONVERT(VARCHAR(8), MIN(bd.TransDate), 112) AS OrderDateKey
			FROM #SalesOrderLineHistoryHolding AS bd
			GROUP BY bd.SourceOrderID
		) odk
		ON odk.SourceOrderID = bta.SourceOrderID
		WHERE bta.OrderDateKey IS NULL;

		UPDATE bta
		SET bta.SuperOrderID = CONCAT(CONVERT(VARCHAR(8), OrderDate, 112), StoreID, CustomerID)
		FROM #SalesOrderLineHistoryHolding bta;

		/* Not Required
		/*UPDATE bd
		SET bd.SalesLeadSourceID = mc.SalesLeadSourceID
		FROM [Retail_Sales_Enh].[SalesOrderHeader] AS oh
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[MarketingCode] AS mc
		ON mc.MarketingCodeID = oh.MarketingCodeID
		INNER JOIN #SalesOrderLineHistoryHolding AS bd
		ON bd.OrderID = oh.OrderID;


		/*MarketingCodeID is updated in storis after order is placed*/
		UPDATE sales
		SET sales.SalesLeadSourceID = mc.SalesLeadSourceID
		FROM [Retail_Sales_Enh].[SalesOrderHeader] oh
		INNER JOIN #SalesOrderLineHistoryHolding sales
		ON sales.OrderID = oh.OrderID
		INNER JOIN [Enterprise_Lakehouse].[Retail_Corporate].[MarketingCode] mc
		ON oh.MarketingCodeID = mc.MarketingCodeID
		WHERE oh.MarketingCodeID IS NOT NULL
		AND sales.SalesLeadSourceID <> mc.SalesLeadSourceID
		AND sales.TransDateKey >= CONVERT(VARCHAR(8), DATEADD(DAY, -30, GETDATE()), 112);
		*/
		*/

		UPDATE bta
		SET bta.FRLocationID = bta.StoreID
		FROM #SalesOrderLineHistoryHolding bta;

		UPDATE bta
		SET bta.FRLocationID = fr.FRLocationID
		FROM #SalesOrderLineHistoryHolding bta
		INNER JOIN [$(Source_Data)].[Retail_External].[FrLocationMap] fr
		ON fr.LocationID = bta.StoreID
		AND fr.ShipLocationID = bta.DeliveryStoreID;
		
		/*****Update BTA gross Sales******/

		;WITH tot AS
		(
			SELECT	bd.StoreID
					, bd.CustomerID
					, bd.TransDate
					, SUM(bd.NetPrice) TotSales
			FROM #SalesOrderLineHistoryHolding AS bd
			WHERE Source = 'W'
			GROUP BY bd.StoreID
					, bd.CustomerID
					, bd.TransDate
		)

		UPDATE b
		SET b.GrossMultiplier = CASE WHEN tot.TotSales >= 0 THEN 1 ELSE 0 END
		FROM #SalesOrderLineHistoryHolding AS b
		INNER JOIN tot 
		ON tot.CustomerID = b.CustomerID
		AND	tot.TransDate = b.TransDate
		AND	tot.StoreID = b.StoreID;

		/*--------------Reselect Ordres -----------------------------------------*/
		UPDATE b
		SET b.GrossMultiplier = 1
		FROM #SalesOrderLineHistoryHolding  AS b
		INNER JOIN 
		(
			SELECT DISTINCT	SourceOrderID 
			FROM #SalesOrderLineHistoryHolding  AS b 
			WHERE b.SKU = 'RESEL'
		) RESEL 
		ON RESEL.SourceOrderID = b.SourceOrderID;
		
		UPDATE b
		SET b.GrossMultiplier = 1
		FROM #SalesOrderLineHistoryHolding AS b
		INNER JOIN 
		(
			SELECT DISTINCT	SourceOrderID 
			FROM #SalesOrderLineHistoryHolding AS b 
			WHERE b.SKU = 'RESEL'
		) RESEL 
		ON RESEL.SourceOrderID + 'e' = b.SourceOrderID;

		/*-----------Missing Voided Code-------------------------------*/
		UPDATE b
		SET b.VoidedReasonCodeID = rsn.rsnCode
		FROM #SalesOrderLineHistoryHolding  AS b
		INNER JOIN
		(
			SELECT SourceOrderID
				  , MAX(b.VoidedReasonCodeID) rsnCode
			FROM #SalesOrderLineHistoryHolding AS b
			WHERE VoidedReasonCodeID IS NOT NULL
			GROUP BY b.SourceOrderID
		) rsn 
		ON rsn.SourceOrderID = b.SourceOrderID
		WHERE b.VoidedReasonCodeID IS NULL;

		UPDATE b
		SET b.VoidedReasonCodeID = rsn.rsnCode
		FROM #SalesOrderLineHistoryHolding  AS b
		INNER JOIN
		(
			SELECT SourceOrderID
				   , MAX(b.VoidedReasonCodeID) rsnCode
			FROM #SalesOrderLineHistoryHolding AS b
			WHERE VoidedReasonCodeID IS NOT NULL
			GROUP BY b.SourceOrderID
		) rsn 
		ON rsn.SourceOrderID + 'e' = b.SourceOrderID
		WHERE b.VoidedReasonCodeID IS NULL;
		
		--/*-----------Missing Voided Code---------------------------------*/
		 /*
		 UPDATE bta
		 SET bta.GrossMultiplier = 0
		 FROM #SalesOrderLineHistoryHolding  bta
		 WHERE TransCodeID IN (30, 31)
		 AND UpdateTypeID IN ('V', 'D');
		 */

		UPDATE #SalesOrderLineHistoryHolding 
		SET REACCategory = 'Sales Adjustment'
		WHERE Source = 'W'
		AND TransCodeID IN (0, 1, 2)
		AND GrossMultiplier = 0
		AND UpdateTypeID NOT IN ('V', 'D');

		UPDATE #SalesOrderLineHistoryHolding 
		SET REACCategory = 'Sales Cancellation'
		WHERE Source = 'W'
		AND TransCodeID IN (0, 1, 2)
		AND GrossMultiplier = 0
		AND UpdateTypeID IN ('V', 'D');

		UPDATE #SalesOrderLineHistoryHolding 
		SET REACCategory = 'Sales Exchanges'
		WHERE Source = 'W'
		AND (TransCodeID = 7 OR (TransCodeID IN (30, 31) AND RIGHT(BaseOrderID, 1) = 'e'))
		AND GrossMultiplier = 0;

		UPDATE #SalesOrderLineHistoryHolding 
		SET REACCategory = 'Sales Returns'
		WHERE Source = 'W'
		AND TransCodeID IN (30, 31)
		AND RIGHT(BaseOrderID, 1) <> 'e'
		AND GrossMultiplier = 0;

		/* From ProtectionPlanSalesTrans SP
		UPDATE #SalesOrderLineHistoryHolding 
		SET REACCategory = 'Sales Adjustment'
		WHERE LineStatus = 'Written'
		--AND TransCodeID IN (0, 1, 2)
		AND GrossMultiplier = 0;
		*/

		INSERT INTO [Retail_Sales_Enh].[SalesOrderLineHistory]
		(
			Source
			, SourceSystem
			, BtaID
			, SalesDataTypeKey
			, AsIsSaleReasonCodeID
			, BaseOrderID
			, SourceOrderID
			, TransDate
			, TransDateKey
			, OrderDate
			, OrderDateKey
			, LineNumber
			, LineStatus
			, ItemDescription
			, SKU
			, QuantityOrdered
			, NetPrice
			, ProtectionPlanSKU
			, ProtectionPlanID
			, ProtectionPlanPrice
			, ProtectionPlanCost
			, IsServiceItem
			, HasProtectionPlan
			, WarrantyEndDate
			, StoreID
			, KitOrPackageQuantity
			, KitOrPackageSKU
			, NetCost
			, CategoryID
			, GroupID
			, CustomerID
			, DiscountCode
			, DeliveryStoreID
			, DeliveryTypeCodeID
			, SalesPersonID
			, ServiceTypeID
			, TransCodeID
			, VendorID
			, VoidedReasonCodeID
			, DateChanged
			, DateCreated
			, PurchaseStatusCodeID
			, SpecialOrder
			, UpdateDateTime
			, UpdateTypeID
			, SuperOrderID
			, TransCodeGroup
			, ItemCommCategory
			, DeliveryStatus
			, ProductDiscountCode
			, PriceVarianceExceptionReasonCodeID
			, PriceOverrideStaffID
			, FRLocationID
			, GrossMultiplier
			, REACCategory
		)

		SELECT  
			Source
			, SourceSystem
			, BtaID
			, SalesDataTypeKey
			, AsIsSaleReasonCodeID
			, BaseOrderID
			, SourceOrderID
			, TransDate
			, TransDateKey
			, OrderDate
			, OrderDateKey
			, LineNumber
			, LineStatus
			, ItemDescription
			, SKU
			, QuantityOrdered
			, NetPrice
			, ProtectionPlanSKU
			, ProtectionPlanID
			, ProtectionPlanPrice
			, ProtectionPlanCost
			, IsServiceItem
			, HasProtectionPlan
			, WarrantyEndDate
			, StoreID
			, KitOrPackageQuantity
			, KitOrPackageSKU
			, NetCost
			, CategoryID
			, GroupID
			, CustomerID
			, DiscountCode
			, DeliveryStoreID
			, DeliveryTypeCodeID
			, SalesPersonID
			, ServiceTypeID
			, TransCodeID
			, VendorID
			, VoidedReasonCodeID
			, DateChanged
			, DateCreated
			, PurchaseStatusCodeID
			, SpecialOrder
			, UpdateDateTime
			, UpdateTypeID
			, SuperOrderID
			, TransCodeGroup
			, ItemCommCategory
			, DeliveryStatus
			, ProductDiscountCode
			, PriceVarianceExceptionReasonCodeID
			, PriceOverrideStaffID
			, FRLocationID
			, GrossMultiplier
			, REACCategory
		FROM #SalesOrderLineHistoryHolding;

		UPDATE sdt
		SET sdt.ItemCommCategory = bd.ItemCommCategory
		FROM [Retail_Sales_Enh].[SalesOrderLineHistory] AS sdt
		INNER JOIN #SalesOrderLineHistoryHolding AS bd
		ON bd.BtaID = sdt.BtaID
		WHERE sdt.SalesDataTypeKey <> 2
		AND sdt.ItemCommCategory IS NULL;

		DROP TABLE #SalesOrderLineHistoryHolding;

		/* LastWrittenDate for SalesOrderLine */
		SELECT	
			sdt.SourceOrderID
			, sdt.LineNumber
			, MAX(sdt.TransDate) AS TransDate
		INTO #LWTD
		FROM [Retail_Sales_Enh].[SalesOrderLineHistory] AS sdt
		WHERE sdt.Source = 'W'
		GROUP BY sdt.SourceOrderID
				, sdt.LineNumber;

		UPDATE	od
		SET od.LastWrittenTransDate = TransDate
		FROM #LWTD AS l
		INNER JOIN [Retail_Sales_Enh].[SalesOrderLine] AS od 
		ON od.SourceOrderID = l.SourceOrderID
		AND	od.LineNumber = l.LineNumber;

		DROP TABLE #LWTD;

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