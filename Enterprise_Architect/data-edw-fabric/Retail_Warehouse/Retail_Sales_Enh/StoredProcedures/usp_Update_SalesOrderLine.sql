CREATE PROCEDURE [Retail_Sales_Enh].[usp_Update_SalesOrderLine]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Enh.usp_Update_SalesOrderLine';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_Sales_Enh';
	SET @DestinationTable = 'SalesOrderLine';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; --For Snapshot Isolation and Update Conflict Error

	BEGIN TRY

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(OrderDetailKey),0) FROM [Retail_Sales_Enh].[SalesOrderLine]);

		--TRUNCATE TABLE [Retail_Sales_Enh].[SalesOrderLine];

		IF OBJECT_ID('tempdb..#OrderItemProductInfo') IS NOT NULL 
		DROP TABLE #OrderItemProductInfo;

		SELECT *
		INTO #OrderItemProductInfo
		FROM [Retail_Sales].[SalesOrderProductInfo]
		WHERE InfoStatus = 'Written';

		IF OBJECT_ID('tempdb..#InvoiceItemProductInfo') IS NOT NULL 
		DROP TABLE #InvoiceItemProductInfo;

		SELECT *
		INTO #InvoiceItemProductInfo
		FROM [Retail_Sales].[SalesOrderProductInfo]
		WHERE InfoStatus = 'Invoiced';

		IF OBJECT_ID('tempdb..#OrderItemCommissionInfo') IS NOT NULL 
		DROP TABLE #OrderItemCommissionInfo;

		SELECT *
		INTO #OrderItemCommissionInfo
		FROM [Retail_Sales].[SalesAssociateCommission]
		WHERE CommissionStatus = 'Written';

		IF OBJECT_ID('tempdb..#InvoiceItemCommissionInfo') IS NOT NULL 
		DROP TABLE #InvoiceItemCommissionInfo;

		SELECT *
		INTO #InvoiceItemCommissionInfo
		FROM [Retail_Sales].[SalesAssociateCommission]
		WHERE CommissionStatus = 'Invoiced';

		UPDATE w
		SET w.SerialNumber = CASE WHEN w.TransCodeID = 1 THEN oip.SerialNumber ELSE w.SerialNumber END
			, w.AsIsReasonCodeID = CASE WHEN w.TransCodeID = 1 THEN oip.ReasonCodeID ELSE w.AsIsReasonCodeID END
			, w.DeliveryStatus = ISNULL(w.DeliveryStatus, 'EST')
		FROM 
		(
			SELECT
				SourceOrderID
				, LineNumber
				, SerialNumber
				, AsIsReasonCodeID
				, TransCodeID
				, ItemCommCategory
				, DeliveryStatus
			FROM [Retail_Sales].[SalesOrderLine]
			WHERE LineStatus = 'Written'
		) w
		LEFT JOIN #OrderItemProductInfo oip 
		ON w.SourceOrderID = oip.SourceOrderID 
		AND w.LineNumber = oip.LineNumber
		LEFT JOIN 
		(
			SELECT
				SourceOrderID
				, LineNumber
				, MAX(ItemCommCategory) AS ItemCommCategory
			FROM #OrderItemCommissionInfo
			GROUP BY SourceOrderID
					, LineNumber
		) ci 
		ON w.SourceOrderID = ci.SourceOrderID 
		AND w.LineNumber = ci.LineNumber;

		UPDATE i
		SET i.SerialNumber = CASE WHEN i.TransCodeID = 1 THEN iip.SerialNumber ELSE i.SerialNumber END
			, i.AsIsReasonCodeID = CASE WHEN i.TransCodeID = 1 THEN iip.ReasonCodeID ELSE i.AsIsReasonCodeID END
			, i.ItemCommCategory = ci.ItemCommCategory
		FROM 
		(
			SELECT
				SourceOrderID
				, LineNumber
				, SerialNumber
				, AsIsReasonCodeID
				, TransCodeID
				, ItemCommCategory
				, DeliveryStatus
			FROM [Retail_Sales].[SalesOrderLine]
			WHERE LineStatus = 'Invoiced'
		) i
		LEFT JOIN #InvoiceItemProductInfo iip 
		ON i.SourceOrderID = iip.SourceOrderID 
		AND i.LineNumber = iip.LineNumber
		LEFT JOIN 
		(
			SELECT
				SourceOrderID
				, LineNumber
				, MAX(ItemCommCategory) AS ItemCommCategory
			FROM #InvoiceItemCommissionInfo
			GROUP BY SourceOrderID
					, LineNumber
		) ci 
		ON i.SourceOrderID = ci.SourceOrderID 
		AND i.LineNumber = ci.LineNumber;

		/*Flag Orders that are CustomerServiceOrders for CustomerServiceOrders process*/
		UPDATE t
		SET t.NewEntryFlag = 1
		FROM [Retail_Sales].[SalesOrderLine] t
		LEFT JOIN [Retail_Sales_Enh].[SalesOrderLine] od 
		ON t.SourceOrderID = od.SourceOrderID 
		AND t.LineNumber = od.LineNumber 
		AND t.LineStatus = od.LineStatus
		WHERE t.RecStatus <> 'D' 
		AND od.SourceOrderID IS NULL;

		IF OBJECT_ID('tempdb..#Written') IS NOT NULL 
		DROP TABLE #Written;

		SELECT *
		INTO #Written
		FROM [Retail_Sales].[SalesOrderLine]
		WHERE LineStatus = 'Written';

		IF OBJECT_ID('tempdb..#Invoiced') IS NOT NULL 
		DROP TABLE #Invoiced;

		SELECT *
		INTO #Invoiced
		FROM [Retail_Sales].[SalesOrderLine]
		WHERE LineStatus = 'Invoiced';

		--DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(OrderDetailKey),0) FROM [Retail_Sales_Enh].[SalesOrderLine]);

		IF OBJECT_ID('tempdb..#SalesOrderLine') IS NOT NULL 
		DROP TABLE #SalesOrderLine;

		SELECT	
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY ii.SourceOrderID, ii.LineNumber) AS BIGINT) AS OrderDetailKey
			, ii.SourceSystem
			, ii.AsIsReasonCodeID
			, ii.BaseOrderID
			, ii.SourceOrderID
			, ii.SourceOrderID AS InvoiceID
			, ii.LineNumber
			, ii.PurchaseOrderID
			, ii.PurchaseOrderLineID
			, ii.AutoTransOrderItemID
			, ii.InvoiceDate
			, ii.ItemDescription
			, ii.QuantityOrdered
			, ii.QuantityCommitted
			, ii.QuantityDelivered
			, ii.QuantityUndelivered
			, ii.RequestedDate
			, ii.SKU
			, ii.KitProductID
			, ii.UnitSellPrice
			, ii.UnitListPrice
			, ii.LineCost / NULLIF(ii.QuantityCommitted, 0) AS UnitCost
			, ii.TotalSaleAmount
			, ii.TotalInvoiceAmount
			, ii.LineStatus
			, ii.ProtectionPlanSKU
			, ii.ProductTypeID
			, ii.IsServiceItem
			, ii.ProtectionPlanID
			, ii.HasProtectionPlan
			, ii.WarrantyEndDate
			, ii.OrderDate
			, ii.OrderFulfillmentID
			, ii.KitOrPackageQuantity
			, ii.KitOrPackageSKU
			, ii.KitGroupNumber
			, ii.StoreID
			, ii.OriginalInvoiceID
			, ii.VendorModelNumber
			, ii.TransCodeID
			, ii.DeliveryDate
			, ii.DeliveryStatus
			, ii.DeliveryType
			, ii.DelievryStoreID
			, ii.DeliverySubTotal
			, ii.LineCost
			, ii.Addon1Cost
			, ii.Addon2Cost
			, ii.LandedFreight
			, ii.OtherDiscount
			, ii.ProductDiscountCode
			, ii.WrittenDate
			, ii.PriceVarianceExceptionReasonCodeID
			, ii.VendorID
			, ii.VoidedReasonCodeID
			, ii.ProtectionPlanPrice
			, ii.ProtectionPlanCost
			, ii.ProtectionPlanRegisterID
			, ii.PriceOverrideStaffID
			, ii.PurchaseStatusCodeID
			, ii.StockLocationID
			, ii.ShipLocationID
			, ii.ServiceMerchandiseOrderID
			, ii.ServiceMerchandiseItemID
			, ii.ServiceProblemCodeID
			, ii.ServiceOrderOrderID
			, ii.ServiceOrderItemID
			, ii.ServiceStatusCodeID
			, ii.ServiceTechStaffID
			, ii.Comments
			, ii.DateCreated
			, ii.DateChanged
			, ii.SerialNumber
			, ii.ItemCommCategory
			, ii.NewEntryFlag
			, ii.SpecialOrderFlag
			, ii.RecStatus
			, CAST(NULL AS DECIMAL(19, 4)) AS UnitPromoPrice
			, CAST(NULL AS VARCHAR(50)) AS SFMCLineFulfillmentStatus
			, CAST(NULL AS DATE) AS SFMCLastFulfillmentDate
			, CAST(NULL AS VARCHAR(50)) AS SFMCFulfillmentStatus
			, CAST(NULL AS DATE) AS OriginalDeliveryDate
			, CAST(NULL AS VARCHAR(50)) AS POSStockLocationID
			, CAST(NULL AS DATE) AS LastWrittenTransDate
		INTO #SalesOrderLine
		FROM [Retail_Sales].[SalesOrderLine] ii
		INNER JOIN [$(Source_Data)].[Retail_External].[TransCodeMap] t 
		ON CAST(t.TransCodeID AS INT) = ii.TransCodeID
		WHERE t.TransCodeGroup = 'ALL'
		AND ii.RecStatus <> 'D';

		DELETE sol
		FROM [Retail_Sales_Enh].[SalesOrderLine] sol
		INNER JOIN #SalesOrderLine od
		ON sol.SourceOrderID = od.SourceOrderID
		AND sol.LineNumber = od.LineNumber;

		INSERT INTO [Retail_Sales_Enh].[SalesOrderLine]
		(
			OrderDetailKey
			, SourceSystem
			, AsIsReasonCodeID
			, BaseOrderID
			, SourceOrderID
			, InvoiceID
			, LineNumber
			, PurchaseOrderID
			, PurchaseOrderLineID
			, AutoTransOrderItemID
			, InvoiceDate
			, ItemDescription
			, QuantityOrdered
			, QuantityCommitted
			, QuantityDelivered
			, QuantityUndelivered
			, RequestedDate
			, SKU
			, KitProductID
			, UnitSellPrice
			, UnitListPrice
			, UnitPromoPrice
			, UnitCost
			, TotalSaleAmount
			, TotalInvoiceAmount
			, LineStatus
			, ProtectionPlanSKU
			, ProductTypeID
			, IsServiceItem
			, ProtectionPlanID
			, HasProtectionPlan
			, WarrantyEndDate
			, OrderDate
			, OrderFulfillmentID
			, KitOrPackageQuantity
			, KitOrPackageSKU
			, KitGroupNumber
			, StoreID
			, OriginalInvoiceID
			, VendorModelNumber
			, TransCodeID
			, DeliveryDate
			, DeliveryStatus
			, DeliveryType
			, DelievryStoreID
			, DeliverySubTotal
			, LineCost
			, Addon1Cost
			, Addon2Cost
			, LandedFreight
			, OtherDiscount
			, ProductDiscountCode
			, WrittenDate
			, PriceVarianceExceptionReasonCodeID
			, VendorID
			, VoidedReasonCodeID
			, ProtectionPlanPrice
			, ProtectionPlanCost
			, ProtectionPlanRegisterID
			, PriceOverrideStaffID
			, PurchaseStatusCodeID
			, StockLocationID
			, ShipLocationID
			, ServiceMerchandiseOrderID
			, ServiceMerchandiseItemID
			, ServiceProblemCodeID
			, ServiceOrderOrderID
			, ServiceOrderItemID
			, ServiceStatusCodeID
			, ServiceTechStaffID
			, Comments
			, DateChanged
			, DateCreated
			, SerialNumber
			, ItemCommCategory
			, NewEntryFlag
			, SpecialOrderFlag
			, SFMCLineFulfillmentStatus
			, SFMCLastFulfillmentDate
			, SFMCFulfillmentStatus
			, OriginalDeliveryDate
			, POSStockLocationID
			, LastWrittenTransDate
			, RecStatus
		)

		SELECT	
			OrderDetailKey
			, SourceSystem
			, AsIsReasonCodeID
			, BaseOrderID
			, SourceOrderID
			, InvoiceID
			, LineNumber
			, PurchaseOrderID
			, PurchaseOrderLineID
			, AutoTransOrderItemID
			, InvoiceDate
			, ItemDescription
			, QuantityOrdered
			, QuantityCommitted
			, QuantityDelivered
			, QuantityUndelivered
			, RequestedDate
			, SKU
			, KitProductID
			, UnitSellPrice
			, UnitListPrice
			, UnitPromoPrice
			, UnitCost
			, TotalSaleAmount
			, TotalInvoiceAmount
			, LineStatus
			, ProtectionPlanSKU
			, ProductTypeID
			, IsServiceItem
			, ProtectionPlanID
			, HasProtectionPlan
			, WarrantyEndDate
			, OrderDate
			, OrderFulfillmentID
			, KitOrPackageQuantity
			, KitOrPackageSKU
			, KitGroupNumber
			, StoreID
			, OriginalInvoiceID
			, VendorModelNumber
			, TransCodeID
			, DeliveryDate
			, DeliveryStatus
			, DeliveryType
			, DelievryStoreID
			, DeliverySubTotal
			, LineCost
			, Addon1Cost
			, Addon2Cost
			, LandedFreight
			, OtherDiscount
			, ProductDiscountCode
			, WrittenDate
			, PriceVarianceExceptionReasonCodeID
			, VendorID
			, VoidedReasonCodeID
			, ProtectionPlanPrice
			, ProtectionPlanCost
			, ProtectionPlanRegisterID
			, PriceOverrideStaffID
			, PurchaseStatusCodeID
			, StockLocationID
			, ShipLocationID
			, ServiceMerchandiseOrderID
			, ServiceMerchandiseItemID
			, ServiceProblemCodeID
			, ServiceOrderOrderID
			, ServiceOrderItemID
			, ServiceStatusCodeID
			, ServiceTechStaffID
			, Comments
			, DateChanged
			, DateCreated
			, SerialNumber
			, ItemCommCategory
			, NewEntryFlag
			, SpecialOrderFlag
			, SFMCLineFulfillmentStatus
			, SFMCLastFulfillmentDate
			, SFMCFulfillmentStatus
			, OriginalDeliveryDate
			, POSStockLocationID
			, LastWrittenTransDate
			, RecStatus
		FROM #SalesOrderLine;

		IF OBJECT_ID('tempdb..#Cancelled') IS NOT NULL 
		DROP TABLE #Cancelled;

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY od.SourceOrderID, od.LineNumber) AS BIGINT) AS OrderDetailKey
			, od.SourceSystem
			, od.AsIsReasonCodeID
			, od.BaseOrderID
			, od.SourceOrderID
			, od.SourceOrderID AS InvoiceID
			, od.LineNumber
			, od.PurchaseOrderID
			, od.PurchaseOrderLineID
			, od.AutoTransOrderItemID
			, od.InvoiceDate
			, od.ItemDescription
			, od.QuantityOrdered
			, od.QuantityCommitted
			, od.QuantityDelivered
			, od.QuantityUndelivered
			, od.RequestedDate
			, od.SKU
			, od.KitProductID
			, od.UnitSellPrice
			, od.UnitListPrice
			, od.LineCost / NULLIF(od.QuantityCommitted, 0) AS UnitCost
			, od.TotalSaleAmount
			, od.TotalInvoiceAmount
			, od.LineStatus
			, od.ProtectionPlanSKU
			, od.ProductTypeID
			, od.IsServiceItem
			, od.ProtectionPlanID
			, od.HasProtectionPlan
			, od.WarrantyEndDate
			, od.OrderDate
			, od.OrderFulfillmentID
			, od.KitOrPackageQuantity
			, od.KitOrPackageSKU
			, od.KitGroupNumber
			, od.StoreID
			, od.OriginalInvoiceID
			, od.VendorModelNumber
			, od.TransCodeID
			, od.DeliveryDate
			, od.DeliveryStatus
			, od.DeliveryType
			, od.DelievryStoreID
			, od.DeliverySubTotal
			, od.LineCost
			, od.Addon1Cost
			, od.Addon2Cost
			, od.LandedFreight
			, od.OtherDiscount
			, od.ProductDiscountCode
			, od.WrittenDate
			, od.PriceVarianceExceptionReasonCodeID
			, od.VendorID
			, od.VoidedReasonCodeID
			, od.ProtectionPlanPrice
			, od.ProtectionPlanCost
			, od.ProtectionPlanRegisterID
			, od.PriceOverrideStaffID
			, od.PurchaseStatusCodeID
			, od.StockLocationID
			, od.ShipLocationID
			, od.ServiceMerchandiseOrderID
			, od.ServiceMerchandiseItemID
			, od.ServiceProblemCodeID
			, od.ServiceOrderOrderID
			, od.ServiceOrderItemID
			, od.ServiceStatusCodeID
			, od.ServiceTechStaffID
			, od.Comments
			, od.DateCreated
			, od.DateChanged
			, od.SerialNumber
			, od.ItemCommCategory
			, od.NewEntryFlag
			, od.SpecialOrderFlag
			, od.RecStatus
			, CAST(NULL AS DECIMAL(19, 4)) AS UnitPromoPrice
			, CAST(NULL AS VARCHAR(50)) AS SFMCLineFulfillmentStatus
			, CAST(NULL AS DATE) AS SFMCLastFulfillmentDate
			, CAST(NULL AS VARCHAR(50)) AS SFMCFulfillmentStatus
			, CAST(NULL AS DATE) AS OriginalDeliveryDate
			, CAST(NULL AS VARCHAR(50)) AS POSStockLocationID
			, CAST(NULL AS DATE) AS LastWrittenTransDate
		INTO #Cancelled
		FROM [Retail_Sales].[SalesOrderLine] od
		WHERE od.LineStatus = 'Written'
		AND od.RecStatus = 'D'
		AND NOT EXISTS
		(
			SELECT *
			FROM [Retail_Sales_Enh].[SalesOrderLine] sol
			WHERE sol.BaseOrderID = od.BaseOrderID
			AND sol.LineNumber = od.LineNumber
		);

		DELETE sol
		FROM [Retail_Sales_Enh].[SalesOrderLine] sol
		INNER JOIN #Cancelled od
		ON sol.SourceOrderID = od.SourceOrderID
		AND sol.LineNumber = od.LineNumber;

		INSERT INTO [Retail_Sales_Enh].[SalesOrderLine]
		(
			OrderDetailKey
			, SourceSystem
			, AsIsReasonCodeID
			, BaseOrderID
			, SourceOrderID
			, InvoiceID
			, LineNumber
			, PurchaseOrderID
			, PurchaseOrderLineID
			, AutoTransOrderItemID
			, InvoiceDate
			, ItemDescription
			, QuantityOrdered
			, QuantityCommitted
			, QuantityDelivered
			, QuantityUndelivered
			, RequestedDate
			, SKU
			, KitProductID
			, UnitSellPrice
			, UnitListPrice
			, UnitPromoPrice
			, UnitCost
			, TotalSaleAmount
			, TotalInvoiceAmount
			, LineStatus
			, ProtectionPlanSKU
			, ProductTypeID
			, IsServiceItem
			, ProtectionPlanID
			, HasProtectionPlan
			, WarrantyEndDate
			, OrderDate
			, OrderFulfillmentID
			, KitOrPackageQuantity
			, KitOrPackageSKU
			, KitGroupNumber
			, StoreID
			, OriginalInvoiceID
			, VendorModelNumber
			, TransCodeID
			, DeliveryDate
			, DeliveryStatus
			, DeliveryType
			, DelievryStoreID
			, DeliverySubTotal
			, LineCost
			, Addon1Cost
			, Addon2Cost
			, LandedFreight
			, OtherDiscount
			, ProductDiscountCode
			, WrittenDate
			, PriceVarianceExceptionReasonCodeID
			, VendorID
			, VoidedReasonCodeID
			, ProtectionPlanPrice
			, ProtectionPlanCost
			, ProtectionPlanRegisterID
			, PriceOverrideStaffID
			, PurchaseStatusCodeID
			, StockLocationID
			, ShipLocationID
			, ServiceMerchandiseOrderID
			, ServiceMerchandiseItemID
			, ServiceProblemCodeID
			, ServiceOrderOrderID
			, ServiceOrderItemID
			, ServiceStatusCodeID
			, ServiceTechStaffID
			, Comments
			, DateChanged
			, DateCreated
			, SerialNumber
			, ItemCommCategory
			, NewEntryFlag
			, SpecialOrderFlag
			, SFMCLineFulfillmentStatus
			, SFMCLastFulfillmentDate
			, SFMCFulfillmentStatus
			, OriginalDeliveryDate
			, POSStockLocationID
			, LastWrittenTransDate
			, RecStatus
		)

		SELECT	
			OrderDetailKey
			, SourceSystem
			, AsIsReasonCodeID
			, BaseOrderID
			, SourceOrderID
			, InvoiceID
			, LineNumber
			, PurchaseOrderID
			, PurchaseOrderLineID
			, AutoTransOrderItemID
			, InvoiceDate
			, ItemDescription
			, QuantityOrdered
			, QuantityCommitted
			, QuantityDelivered
			, QuantityUndelivered
			, RequestedDate
			, SKU
			, KitProductID
			, UnitSellPrice
			, UnitListPrice
			, UnitPromoPrice
			, UnitCost
			, TotalSaleAmount
			, TotalInvoiceAmount
			, LineStatus
			, ProtectionPlanSKU
			, ProductTypeID
			, IsServiceItem
			, ProtectionPlanID
			, HasProtectionPlan
			, WarrantyEndDate
			, OrderDate
			, OrderFulfillmentID
			, KitOrPackageQuantity
			, KitOrPackageSKU
			, KitGroupNumber
			, StoreID
			, OriginalInvoiceID
			, VendorModelNumber
			, TransCodeID
			, DeliveryDate
			, DeliveryStatus
			, DeliveryType
			, DelievryStoreID
			, DeliverySubTotal
			, LineCost
			, Addon1Cost
			, Addon2Cost
			, LandedFreight
			, OtherDiscount
			, ProductDiscountCode
			, WrittenDate
			, PriceVarianceExceptionReasonCodeID
			, VendorID
			, VoidedReasonCodeID
			, ProtectionPlanPrice
			, ProtectionPlanCost
			, ProtectionPlanRegisterID
			, PriceOverrideStaffID
			, PurchaseStatusCodeID
			, StockLocationID
			, ShipLocationID
			, ServiceMerchandiseOrderID
			, ServiceMerchandiseItemID
			, ServiceProblemCodeID
			, ServiceOrderOrderID
			, ServiceOrderItemID
			, ServiceStatusCodeID
			, ServiceTechStaffID
			, Comments
			, DateChanged
			, DateCreated
			, SerialNumber
			, ItemCommCategory
			, NewEntryFlag
			, SpecialOrderFlag
			, SFMCLineFulfillmentStatus
			, SFMCLastFulfillmentDate
			, SFMCFulfillmentStatus
			, OriginalDeliveryDate
			, POSStockLocationID
			, LastWrittenTransDate
			, RecStatus
		FROM #Cancelled;

		IF OBJECT_ID('tempdb..#OrderDetail') IS NOT NULL 
		DROP TABLE #OrderDetail;

		SELECT *
		INTO #OrderDetail
		FROM [Retail_Sales_Enh].[SalesOrderLine];

		UPDATE od
		SET DeliveryDate = oi.DeliveryDate
			, DeliveryStatus = oi.DeliveryStatus
			, DeliveryType = oi.DeliveryType
			, QuantityOrdered = oi.QuantityOrdered
			, QuantityCommitted = oi.QuantityCommitted
			, UnitSellPrice = oi.UnitSellPrice
			, UnitCost = CASE WHEN oi.QuantityOrdered = 0 THEN 0 ELSE oi.LineCost / NULLIF(oi.QuantityOrdered,0) END
			, StockLocationID = oi.StockLocationID
			, ShipLocationID = oi.ShipLocationID
			, TransCodeID = oi.TransCodeID
			, ProductDiscountCode = oi.ProductDiscountCode
			, KitGroupNumber = oi.KitGroupNumber
			, KitProductID = oi.KitProductID
			, DateChanged = oi.DateChanged
			, AutoTransOrderItemID = oi.AutoTransOrderItemID
			, SerialNumber = oi.SerialNumber
			, AsIsReasonCodeID = oi.AsIsReasonCodeID
			, ItemCommCategory = oi.ItemCommCategory
			, PriceVarianceExceptionReasonCodeID = oi.PriceVarianceExceptionReasonCodeID
			, ServiceMerchandiseOrderID = oi.ServiceMerchandiseOrderID
			, ServiceMerchandiseItemID = oi.ServiceMerchandiseItemID
			, ServiceProblemCodeID = oi.ServiceProblemCodeID
			, ServiceOrderOrderID = oi.ServiceOrderOrderID
			, ServiceOrderItemID = oi.ServiceOrderItemID
			, Addon1Cost = oi.Addon1Cost
			, Addon2Cost = oi.Addon2Cost
			, LandedFreight = oi.LandedFreight
			, PriceOverrideStaffID = oi.PriceOverrideStaffID
			, PurchaseOrderID = oi.PurchaseOrderID
			, PurchaseOrderLineID = oi.PurchaseOrderLineID
			, OrderFulfillmentID = oi.OrderFulfillmentID
			, ProtectionPlanID = oi.ProtectionPlanID
			, ProtectionPlanRegisterID = oi.ProtectionPlanRegisterID
			, ProtectionPlanPrice = oi.ProtectionPlanPrice
			, ProtectionPlanCost = oi.ProtectionPlanCost
			, ServiceStatusCodeID = oi.ServiceStatusCodeID
			, ServiceTechStaffID = oi.ServiceTechStaffID
			, WrittenDate = oi.WrittenDate
		FROM #OrderDetail AS od
		INNER JOIN #Written AS oi
		ON oi.SourceOrderID = od.SourceOrderID
		AND	oi.LineNumber = od.LineNumber
		WHERE od.LineStatus = 'Written';

		IF OBJECT_ID('tempdb..#LWTD') IS NOT NULL 
		DROP TABLE #LWTD;

		SELECT	
			sdt.SourceOrderID
			, sdt.LineNumber
			, MAX(sdt.TransDate) AS TransDate
		INTO #LWTD
		FROM [Retail_Sales].[SalesOrderLineHistory] AS sdt
		WHERE sdt.Source = 'W'
		GROUP BY sdt.SourceOrderID
				, sdt.LineNumber;

		UPDATE od
		SET od.LastWrittenTransDate = TransDate
		FROM #LWTD AS l
		INNER JOIN #OrderDetail AS od 
		ON od.SourceOrderID = l.SourceOrderID
		AND	od.LineNumber = l.LineNumber;

		UPDATE od
		SET od.UnitCost = (CASE WHEN pc.AverageCost > 0 THEN pc.AverageCost ELSE pc.ReplacementCost END + pc.Addon1Cost + pc.Addon2Cost + pc.Addon3Cost + pc.Addon4Cost + pc.LandedFreight)
		FROM #OrderDetail od
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[ProductCosts] pc 
		ON pc.ProductID = od.SKU
		INNER JOIN [$(Source_Data)].[Retail_External].[TransCodeMap] tcm 
		ON tcm.TransCodeID = od.TransCodeID
		WHERE (tcm.TransCodeGroup = 'Transfers' OR (tcm.TransCodeGroup = 'Service' AND tcm.OutputValue = 'Customer Service Order'))
		AND od.UnitCost = 0;

		/*Update Deleted Lines*/
		UPDATE od
		SET od.LineStatus = 'Deleted'
		FROM #OrderDetail AS od
		INNER JOIN #Written AS oi
		ON oi.SourceOrderID = od.SourceOrderID
		AND oi.LineNumber = od.LineNumber
		WHERE od.LineStatus = 'Written'
		AND oi.RecStatus = 'D';

		/*Status Lookup*/
		IF OBJECT_ID('tempdb..#StatusLookup') IS NOT NULL 
		DROP TABLE #StatusLookup;

		SELECT 
			SourceOrderID
			, LineNumber
			, MAX(CASE WHEN LineStatus = 'Invoiced' THEN 1 ELSE 0 END) AS HasInvoiced
			, MAX(CASE WHEN LineStatus = 'Written' THEN 1 ELSE 0 END) AS HasWritten
			, MAX(CASE WHEN LineStatus = 'Cancelled' THEN 1 ELSE 0 END) AS HasCancelled
		INTO #StatusLookup
		FROM #OrderDetail
		GROUP BY SourceOrderID
				, LineNumber;

		/*Remove Open Lines that got Invoiced*/
		DELETE od
		FROM #OrderDetail od
		INNER JOIN #StatusLookup s
		ON od.SourceOrderID = s.SourceOrderID
		AND od.LineNumber = s.LineNumber
		WHERE od.LineStatus = 'Deleted'
		AND s.HasInvoiced = 1;

		/*Process Cancelled Lines*/
		UPDATE od
		SET od.LineStatus = 'Cancelled'
		FROM #OrderDetail od
		INNER JOIN #StatusLookup s
		ON od.SourceOrderID = s.SourceOrderID
		AND od.LineNumber = s.LineNumber
		WHERE od.LineStatus = 'Deleted'
		AND s.HasInvoiced = 0;

		DELETE od
		FROM #OrderDetail AS od
		INNER JOIN #StatusLookup s
		ON od.SourceOrderID = s.SourceOrderID
		AND od.LineNumber = s.LineNumber
		WHERE od.LineStatus <> 'Cancelled'
		AND s.HasCancelled = 1;

		/*Update Date Changed, SFMC Fields to NULL*/
		UPDATE od
		SET od.DateChanged = oi.DateChanged
			, od.SFMCLineFulfillmentStatus = NULL
			, od.SFMCLastFulfillmentDate = NULL
			, od.SFMCFulfillmentStatus = NULL
		FROM #OrderDetail AS od
		INNER JOIN #Written AS oi
		ON oi.SourceOrderID = od.SourceOrderID
		AND oi.LineNumber = od.LineNumber;

		/*Update SFMCLineFulfillmentStatus*/
		UPDATE odi
		SET SFMCLineFulfillmentStatus = CASE 
			WHEN odi.LineStatus = 'Invoiced' AND s.HasWritten = 0 THEN 'Completed'
			WHEN s.HasInvoiced = 1 AND s.HasWritten = 1 THEN 'Partially Completed'
			WHEN odi.LineStatus = 'Written' AND s.HasInvoiced = 0 AND odi.DeliveryStatus = 'SCD' THEN 'Open-Scheduled'
			WHEN odi.LineStatus = 'Written' AND s.HasInvoiced = 0 AND odi.DeliveryStatus <> 'SCD' THEN 'Open-Estimated'
			WHEN odi.LineStatus = 'Cancelled' AND s.HasWritten = 0 AND s.HasInvoiced = 0 THEN 'Cancelled'
			ELSE odi.SFMCLineFulfillmentStatus END
		FROM #OrderDetail AS odi
		INNER JOIN #StatusLookup s
		ON odi.SourceOrderID = s.SourceOrderID
		AND odi.LineNumber = s.LineNumber
		WHERE odi.SFMCLineFulfillmentStatus IS NULL;

		IF OBJECT_ID('tempdb..#InvoicedDates') IS NOT NULL 
		DROP TABLE #InvoicedDates;

		SELECT
			BaseOrderID
			, LineNumber
			, MAX(InvoiceDate) AS SFMCLastFulfillmentDate
		INTO #InvoicedDates
		FROM #OrderDetail
		WHERE LineStatus = 'Invoiced'
		GROUP BY BaseOrderID
				, LineNumber;

		/*Update Line SFMCLastFulfillmentDate*/
		UPDATE odi
		SET SFMCLastFulfillmentDate = sfmc.SFMCLastFulfillmentDate
		FROM #OrderDetail odi
		INNER JOIN #InvoicedDates sfmc
		ON sfmc.BaseOrderID = odi.BaseOrderID
		AND sfmc.LineNumber = odi.LineNumber
		WHERE odi.SFMCLastFulfillmentDate IS NULL;

		/*Update Line SFMCFulfillmentStatus*/
		UPDATE od
		SET SFMCFulfillmentStatus = CASE od.LineStatus
			WHEN 'Written' THEN od.DeliveryStatus
			WHEN 'Invoiced' THEN 'SCD'
			WHEN 'Cancelled' THEN 'CXL' END
			FROM #OrderDetail od
		WHERE od.SFMCFulfillmentStatus IS NULL
		AND od.LineStatus IN ('Written','Invoiced','Cancelled');

		/*OrigDeliveryDate, DlvyStatAtPOS in OrderDetain with TransCodeID = 10*/
		UPDATE od
		SET OriginalDeliveryDate = CASE WHEN od.TransCodeID = 10 AND sol.NewEntryFlag = 1 THEN sol.DeliveryDate ELSE od.OriginalDeliveryDate END
			, POSStockLocationID = sol.StockLocationID
			, UnitListPrice = sol.UnitListPrice
		FROM #OrderDetail od
		INNER JOIN [Retail_Sales].[SalesOrderLine] sol
		ON sol.SourceOrderID = od.SourceOrderID
		AND sol.LineNumber = od.LineNumber
		AND sol.LineStatus = od.LineStatus;
 
		DELETE sol
		FROM [Retail_Sales_Enh].[SalesOrderLine] sol
		INNER JOIN #OrderDetail od
		ON sol.SourceOrderID = od.SourceOrderID
		AND sol.LineNumber = od.LineNumber;

		INSERT INTO [Retail_Sales_Enh].[SalesOrderLine]
		(
			OrderDetailKey
			, SourceSystem
			, AsIsReasonCodeID
			, BaseOrderID
			, SourceOrderID
			, InvoiceID
			, LineNumber
			, PurchaseOrderID
			, PurchaseOrderLineID
			, AutoTransOrderItemID
			, InvoiceDate
			, ItemDescription
			, QuantityOrdered
			, QuantityCommitted
			, QuantityDelivered
			, QuantityUndelivered
			, RequestedDate
			, SKU
			, KitProductID
			, UnitSellPrice
			, UnitListPrice
			, UnitPromoPrice
			, UnitCost
			, TotalSaleAmount
			, TotalInvoiceAmount
			, LineStatus
			, ProtectionPlanSKU
			, ProductTypeID
			, IsServiceItem
			, ProtectionPlanID
			, HasProtectionPlan
			, WarrantyEndDate
			, OrderDate
			, OrderFulfillmentID
			, KitOrPackageQuantity
			, KitOrPackageSKU
			, KitGroupNumber
			, StoreID
			, OriginalInvoiceID
			, VendorModelNumber
			, TransCodeID
			, DeliveryDate
			, DeliveryStatus
			, DeliveryType
			, DelievryStoreID
			, DeliverySubTotal
			, LineCost
			, Addon1Cost
			, Addon2Cost
			, LandedFreight
			, OtherDiscount
			, ProductDiscountCode
			, WrittenDate
			, PriceVarianceExceptionReasonCodeID
			, VendorID
			, VoidedReasonCodeID
			, ProtectionPlanPrice
			, ProtectionPlanCost
			, ProtectionPlanRegisterID
			, PriceOverrideStaffID
			, PurchaseStatusCodeID
			, StockLocationID
			, ShipLocationID
			, ServiceMerchandiseOrderID
			, ServiceMerchandiseItemID
			, ServiceProblemCodeID
			, ServiceOrderOrderID
			, ServiceOrderItemID
			, ServiceStatusCodeID
			, ServiceTechStaffID
			, Comments
			, DateChanged
			, DateCreated
			, SerialNumber
			, ItemCommCategory
			, NewEntryFlag
			, SpecialOrderFlag
			, SFMCLineFulfillmentStatus
			, SFMCLastFulfillmentDate
			, SFMCFulfillmentStatus
			, OriginalDeliveryDate
			, POSStockLocationID
			, LastWrittenTransDate
			, RecStatus
		)

		SELECT	
			OrderDetailKey
			, SourceSystem
			, AsIsReasonCodeID
			, BaseOrderID
			, SourceOrderID
			, InvoiceID
			, LineNumber
			, PurchaseOrderID
			, PurchaseOrderLineID
			, AutoTransOrderItemID
			, InvoiceDate
			, ItemDescription
			, QuantityOrdered
			, QuantityCommitted
			, QuantityDelivered
			, QuantityUndelivered
			, RequestedDate
			, SKU
			, KitProductID
			, UnitSellPrice
			, UnitListPrice
			, UnitPromoPrice
			, UnitCost
			, TotalSaleAmount
			, TotalInvoiceAmount
			, LineStatus
			, ProtectionPlanSKU
			, ProductTypeID
			, IsServiceItem
			, ProtectionPlanID
			, HasProtectionPlan
			, WarrantyEndDate
			, OrderDate
			, OrderFulfillmentID
			, KitOrPackageQuantity
			, KitOrPackageSKU
			, KitGroupNumber
			, StoreID
			, OriginalInvoiceID
			, VendorModelNumber
			, TransCodeID
			, DeliveryDate
			, DeliveryStatus
			, DeliveryType
			, DelievryStoreID
			, DeliverySubTotal
			, LineCost
			, Addon1Cost
			, Addon2Cost
			, LandedFreight
			, OtherDiscount
			, ProductDiscountCode
			, WrittenDate
			, PriceVarianceExceptionReasonCodeID
			, VendorID
			, VoidedReasonCodeID
			, ProtectionPlanPrice
			, ProtectionPlanCost
			, ProtectionPlanRegisterID
			, PriceOverrideStaffID
			, PurchaseStatusCodeID
			, StockLocationID
			, ShipLocationID
			, ServiceMerchandiseOrderID
			, ServiceMerchandiseItemID
			, ServiceProblemCodeID
			, ServiceOrderOrderID
			, ServiceOrderItemID
			, ServiceStatusCodeID
			, ServiceTechStaffID
			, Comments
			, DateChanged
			, DateCreated
			, SerialNumber
			, ItemCommCategory
			, NewEntryFlag
			, SpecialOrderFlag
			, SFMCLineFulfillmentStatus
			, SFMCLastFulfillmentDate
			, SFMCFulfillmentStatus
			, OriginalDeliveryDate
			, POSStockLocationID
			, LastWrittenTransDate
			, RecStatus
		FROM #OrderDetail;

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