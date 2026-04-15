CREATE PROCEDURE [Retail_DW_Core].[usp_Update_FactOrderDetail]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactOrderDetail';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactOrderDetail';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_DW_Core].[FactOrderDetail];

		DECLARE @StartDate DATE = GETDATE()-180
				, @EndDate DATE = GETDATE();

	    DROP TABLE IF EXISTS [Retail_DW_Core].[FactOrderDetailHolding];

		CREATE TABLE [Retail_DW_Core].[FactOrderDetailHolding]
		(
			[OrderDetailKey] [bigint] NOT NULL,
			[OrderKey] [bigint] NULL,
			[SourceSystem] [varchar](30) NOT NULL,
			[AsIsReasonCodeID] [varchar](50) NULL,
			[BaseOrderID] [varchar](20) NOT NULL,
			[SourceOrderID] [varchar](20) NOT NULL,
			[InvoiceID] [varchar](20) NOT NULL,
			[LineNumber] [int] NOT NULL,
			[PurchaseOrderID] [varchar](50) NULL,
			[PurchaseOrderLineID] [int] NULL,
			[AutoTransOrderItemID] [varchar](50) NULL,
			[InvoiceDate] [date] NULL,
			[ItemDescription] [varchar](255) NULL,
			[QuantityOrdered] [int] NULL,
			[QuantityCommitted] [int] NULL,
			[QuantityDelivered] [int] NULL,
			[QuantityUndelivered] [int] NULL,
			[RequestedDate] [date] NULL,
			[ProductKey] [bigint] NOT NULL,
			[SKU] [varchar](20) NOT NULL,
			[KitProductID] [varchar](50) NULL,
			[UnitSellPrice] [decimal](19, 4) NULL,
			[UnitListPrice] [decimal](19, 4) NULL,
			[UnitPromoPrice] [decimal](19, 4) NULL,
			[UnitCost] [decimal](19, 4) NULL,
			[TotalSaleAmount] [decimal](19, 4) NULL,
			[TotalInvoiceAmount] [decimal](19, 4) NULL,
			[LineStatus] [varchar](30) NOT NULL,
			[ProtectionPlanSKU] [varchar](20) NULL,
			[ProductTypeID] [varchar](4) NULL,
			[IsServiceItem] [bit] NULL,
			[ProtectionPlanID] [varchar](50) NULL,
			[HasProtectionPlan] [bit] NULL,
			[WarrantyEndDate] [date] NULL,
			[OrderDate] [datetime2](3) NOT NULL,
			[OrderFulfillmentID] [varchar](50) NULL,
			[KitOrPackageQuantity] [int] NULL,
			[KitOrPackageSKU] [varchar](20) NULL,
			[KitGroupNumber] [varchar](20) NULL,
			[StoreID] [int] NOT NULL,
			[OriginalInvoiceID] [varchar](50) NULL,
			[VendorModelNumber] [varchar](255) NULL,
			[TransCodeID] [int] NOT NULL,
			[DeliveryDate] [datetime2](3) NULL,
			[DeliveryStatus] [varchar](10) NULL,
			[DeliveryType] [varchar](50) NULL,
			[DelievryStoreID] [varchar](50) NULL,
			[DeliverySubTotal] [decimal](19, 4) NULL,
			[LineCost] [decimal](19, 4) NULL,
			[Addon1Cost] [decimal](19, 4) NULL,
			[Addon2Cost] [decimal](19, 4) NULL,
			[LandedFreight] [decimal](19, 4) NULL,
			[ProductDiscountAmount] [decimal](19, 4) NULL,
			[ProductDiscountCode] [varchar](50) NULL,
			[WrittenDate] [datetime2](3) NULL,
			[PriceVarianceExceptionReasonCodeID] [varchar](50) NULL,
			[VendorID] [varchar](50) NULL,
			[VoidedReasonCodeID] [varchar](50) NULL,
			[ProtectionPlanPrice] [decimal](19, 4) NULL,
			[ProtectionPlanCost] [decimal](19, 4) NULL,
			[ProtectionPlanRegisterID] [varchar](50) NULL,
			[PriceOverrideStaffID] [varchar](50) NULL,
			[PurchaseStatusCodeID] [varchar](50) NULL,
			[StockLocationID] [varchar](50) NULL,
			[ShipLocationID] [varchar](50) NULL,
			[ServiceMerchandiseOrderID] [varchar](50) NULL,
			[ServiceMerchandiseItemID] [int] NULL,
			[ServiceProblemCodeID] [varchar](50) NULL,
			[ServiceOrderOrderID] [varchar](50) NULL,
			[ServiceOrderItemID] [int] NULL,
			[ServiceStatusCodeID] [varchar](20) NULL,
			[ServiceTechStaffID] [varchar](50) NULL,
			[Comments] [varchar](255) NULL,
			[DateChanged] [datetime2](3) NULL,
			[DateCreated] [datetime2](3) NULL,
			[SerialNumber] [varchar](20) NULL,
			[ItemCommCategory] [varchar](10) NULL,
			[NewEntryFlag] [int] NULL,
			[SpecialOrderFlag] [bit] NULL,
			[SFMCLineFulfillmentStatus] [varchar](50) NULL,
			[SFMCLastFulfillmentDate] [date] NULL,
			[SFMCFulfillmentStatus] [varchar](50) NULL,
			[OriginalDeliveryDate] [date] NULL,
			[POSStockLocationID] [varchar](50) NULL,
			[LastWrittenTransDate] [date] NULL,
			[RecStatus] [char](1) NULL
		);

		INSERT INTO [Retail_DW_Core].[FactOrderDetailHolding]
		(	
			OrderDetailKey
			, OrderKey
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
			, ProductKey
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
			, ProductDiscountAmount
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
			od.OrderDetailKey
			, oh.OrderKey
			, od.SourceSystem
			, od.AsIsReasonCodeID
			, od.BaseOrderID
			, od.SourceOrderID
			, od.InvoiceID
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
			, ISNULL(pm.ProductKey, 0) AS ProductKey
			, od.SKU
			, od.KitProductID
			, od.UnitSellPrice
			, od.UnitListPrice
			, od.UnitPromoPrice
			, od.UnitCost
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
			, od.DateChanged
			, od.DateCreated
			, od.SerialNumber
			, od.ItemCommCategory
			, od.NewEntryFlag
			, od.SpecialOrderFlag
			, od.SFMCLineFulfillmentStatus
			, od.SFMCLastFulfillmentDate
			, od.SFMCFulfillmentStatus
			, od.OriginalDeliveryDate
			, od.POSStockLocationID
			, od.LastWrittenTransDate
			, od.RecStatus
		FROM [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderLine] od
		LEFT JOIN [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderHeader] oh
		ON od.SourceOrderID = oh.SourceOrderID
		LEFT JOIN [Retail_DW_Core].[DimProductMaster] pm
		ON od.SKU = pm.SKU
		WHERE COALESCE(CAST(od.DateChanged AS DATE), CAST(od.DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;

		/*Update AsIsReasonCodeID*/
		UPDATE od
		SET od.AsIsReasonCodeID = 'MFR'
		FROM [Retail_DW_Core].[FactOrderDetailHolding] AS od
		INNER JOIN [Retail_DW_Core].[DimProductMaster] AS pm
		ON pm.ProductKey = od.ProductKey
		WHERE pm.ProductStatus = 'MFR-DISCO'
		AND ProductStatusDate <= od.WrittenDate
		AND od.AsIsReasonCodeID IS NULL;

		DELETE FROM [Retail_DW_Core].[FactOrderDetail]
		WHERE COALESCE(CAST(DateChanged AS DATE), CAST(DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;

		INSERT INTO [Retail_DW_Core].[FactOrderDetail]
		(
			OrderDetailKey
			, OrderKey
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
			, ProductKey
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
			, ProductDiscountAmount
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
			, OrderKey
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
			, ProductKey
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
			, ProductDiscountAmount
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
		FROM [Retail_DW_Core].[FactOrderDetailHolding];

	    DROP TABLE [Retail_DW_Core].[FactOrderDetailHolding];

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