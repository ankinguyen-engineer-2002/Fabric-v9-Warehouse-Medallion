CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_FactSalesDetailTrans]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactSalesDetailTrans';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactSales';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_DW_Core].[FactSales];

		DECLARE @StartDate DATE = GETDATE()-180
				, @EndDate DATE = GETDATE();

		DECLARE @TransDateFromKey INT = CAST(CONVERT(VARCHAR(12), DATEADD(DAY, -60, GETDATE()), 112) AS INT);

	    DROP TABLE IF EXISTS [Retail_DW_Core].[FactSalesDetailTransHolding];

		CREATE TABLE [Retail_DW_Core].[FactSalesDetailTransHolding]
		(
			[SourceSystem] [varchar](30) NOT NULL,
			[Source] [char](1) NULL,
			[SourceDataID] [varchar](50) NOT NULL,
			[SalesDataTypeKey] [int] NOT NULL,
			[TransDateTime] [datetime2](3) NULL,
			[TransDateKey] [int] NOT NULL,
			[OrderDateKey] [int] NULL,
			[ProductKey] [bigint] NULL,
			[CustomerKey] [bigint] NULL,
			[SalesPersonKey] [bigint] NULL,
			[LocationKey] [bigint] NULL,
			[SUOrderID] [varchar](50) NULL,
			[BaseOrderID] [varchar](50) NOT NULL,
			[OrderID] [varchar](50) NOT NULL,
			[ItemID] [int] NULL,
			[GroupID] [varchar](50) NULL,
			[TransCodeID] [int] NOT NULL,
			[UpdateTypeID] [varchar](4) NOT NULL,
			[AsIsReasonCodeID] [varchar](50) NULL,
			[VoidedReasonCodeID] [varchar](50) NULL,
			[ItemCommCategory] [varchar](10) NULL,
			[DeliveryStatus] [varchar](20) NULL,
			[ProductDiscountCode] [varchar](50) NULL,
			[PVEReasonCodeID] [varchar](50) NULL,
			[Sales] [numeric](19, 2) NOT NULL,
			[Cost] [numeric](19, 2) NOT NULL,
			[Units] [numeric](19, 2) NOT NULL,
			[ProtectionPlanPrice] [decimal](19, 4) NULL,
			[ProtectionPlanCost] [decimal](19, 4) NULL,
			[PPPOpp] [decimal](19, 4) NULL,
			[PPPClose] [decimal](19, 4) NULL,
			[SalesType] [char](1) NOT NULL,
			[GrossMultiplier] [int] NULL,
			[REACCategory] [varchar](50) NULL,
			[DateCreated] [datetime2](3) NULL,
			[DateChanged] [datetime2](3) NULL,
			[IsFinanced] [int] NULL,
			[SalesLeadSourceID] [int] NULL,
			[ShipLocationID] [varchar](50) NULL,
			[FRLocationID] [varchar](50) NULL,
			[PriceOverrideStaffID] [varchar](50) NULL,
			[IsReturnCustomer] [int] NULL,
			[LYComp] [int] NULL,
			[TYComp] [int] NULL,
			[InvSubBucketID] [varchar](50) NULL
		)

		INSERT INTO [Retail_DW_Core].[FactSalesDetailTransHolding]
		(	
			SourceSystem
			, Source
			, SourceDataID
			, SalesDataTypeKey
			, TransDateTime
			, TransDateKey
			, OrderDateKey
			, ProductKey
			, CustomerKey
			, SalesPersonKey
			, LocationKey
			, BaseOrderID
			, OrderID
			, ItemID
			, GroupID
			, TransCodeID
			, UpdateTypeID
			, AsIsReasonCodeID
			, VoidedReasonCodeID
			, ItemCommCategory
			, DeliveryStatus
			, ProductDiscountCode
			, PVEReasonCodeID
			, Sales
			, Cost
			, Units
			, ProtectionPlanPrice
			, ProtectionPlanCost
			, SalesType
			, GrossMultiplier
			, REACCategory
			, DateCreated
			, DateChanged
			, SUOrderID
			, ShipLocationID
			, FRLocationID
			, PriceOverrideStaffID
			, InvSubBucketID
		)

		SELECT 
			bd.SourceSystem
			, bd.Source
			, bd.BtaID AS SourceDataID
			, bd.SalesDataTypeKey
			, bd.UpdateDateTime AS TransDateTime
			, bd.TransDateKey
			, bd.OrderDateKey
			, pm.ProductKey
			, cm.CustomerKey
			, sp.SalesPersonKey
			, lm.LocationKey
			, bd.SourceOrderID AS OrderID
			, bd.BaseOrderID
			, bd.LineNumber AS ItemID
			, bd.GroupID
			, bd.TransCodeID
			, bd.UpdateTypeID
			, bd.AsIsSaleReasonCodeID AS AsIsReasonCodeID
			, bd.VoidedReasonCodeID
			, bd.ItemCommCategory
			, bd.DeliveryStatus
			, bd.ProductDiscountCode
			, bd.PriceVarianceExceptionReasonCodeID AS PVEReasonCodeID
			, bd.NetPrice AS Sales
			, bd.NetCost AS Cost
			, bd.QuantityOrdered AS Units
			, bd.ProtectionPlanPrice
			, bd.ProtectionPlanCost  
			, bd.Source AS SalesType
			, bd.GrossMultiplier
			, bd.REACCategory
			, bd.DateCreated
			, bd.DateChanged
			, bd.SuperOrderID
			, bd.DeliveryStoreID
			, bd.FRLocationID
			, bd.PriceOverrideStaffID
			, NULL AS InvSubBucketID
		FROM [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderLineHistory] AS bd
		LEFT JOIN [Retail_DW_Core].[DimCustomerMaster] cm
		ON cm.CustomerID = bd.CustomerID
		LEFT JOIN [Retail_DW_Core].[DimStoreLocation] lm
		ON lm.StoreID = bd.StoreID
		LEFT JOIN [Retail_DW_Core].[DimProductMaster] pm
		ON pm.SKU = bd.SKU
		LEFT JOIN [Retail_DW_Core].[DimSalesPerson] sp
		ON sp.SalesPersonID = bd.SalesPersonID
		WHERE COALESCE(CAST(bd.DateChanged AS DATE), CAST(bd.DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;

		UPDATE sdttp
		SET sdttp.LYComp = lc.LYComp
			, sdttp.TYComp = lc.TYComp
		FROM [Retail_DW_Core].[FactSalesDetailTransHolding] sdttp
		INNER JOIN [Retail_DW_Core].[DimDMLocationCalendar] lc 
		ON lc.TransDateKey = sdttp.TransDateKey
		AND	lc.LocationKey = sdttp.LocationKey
		WHERE lc.TransDateKey >= @TransDateFromKey;

		/* Update PPP*/
		UPDATE bd
		SET bd.PPPOpp = bd.Units / ABS(bd.Units)
		FROM [Retail_DW_Core].[FactSalesDetailTransHolding] AS bd
		INNER JOIN [Retail_DW_Core].[DimCustomerMaster] AS cm
		ON cm.CustomerKey = bd.CustomerKey
		INNER JOIN [Retail_DW_Core].[DimProductMaster] AS pm
		ON pm.ProductKey = bd.ProductKey
		WHERE bd.Source = 'W'
		AND
		(
			cm.CustomerClass NOT IN ( 'COM', 'NOR' )
			OR cm.CustomerClass IS NULL
		)
		AND bd.TransCodeID <> 7
		AND RIGHT(bd.OrderID, 1) <> 'e'
		AND pm.PPPGroupID IS NOT NULL
		AND pm.PPPGroupID <> bd.GroupID
		AND bd.Units <> 0
		AND ABS(bd.Sales / bd.Units) >= 120
		AND pm.IsMaster = 1;

		UPDATE bd
		SET bd.PPPClose = bd.Units / ABS(bd.Units)
		FROM [Retail_DW_Core].[FactSalesDetailTransHolding] AS bd
		INNER JOIN [Retail_DW_Core].[DimCustomerMaster] AS cm
		ON cm.CustomerKey = bd.CustomerKey
		INNER JOIN [Retail_DW_Core].[DimProductMaster] AS pm
		ON pm.ProductKey = bd.ProductKey
		WHERE bd.Source = 'W'
		AND
		(
			cm.CustomerClass NOT IN ( 'COM', 'NOR' )
			OR cm.CustomerClass IS NULL
		)
		AND bd.TransCodeID <> 7
		AND RIGHT(bd.OrderID, 1) <> 'e'
		AND pm.PPPGroupID = bd.GroupID
		AND bd.Units <> 0
		AND pm.IsMaster = 1;

		DELETE FROM [Retail_DW_Core].[FactSales] 
		WHERE SalesDataTypeKey IN (1, 6)
		AND COALESCE(CAST(DateChanged AS DATE), CAST(DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;

		INSERT INTO [Retail_DW_Core].[FactSales]
		(
			SourceSystem
			, Source
			, SourceDataID
			, SalesDataTypeKey
			, TransDateTime
			, TransDateKey
			, OrderDateKey
			, ProductKey
			, CustomerKey
			, SalesPersonKey
			, LocationKey
			, BaseOrderID
			, OrderID
			, ItemID
			, GroupID
			, TransCodeID
			, UpdateTypeID
			, AsIsReasonCodeID
			, VoidedReasonCodeID
			, ItemCommCategory
			, DeliveryStatus
			, ProductDiscountCode
			, PVEReasonCodeID
			, Sales
			, Cost
			, Units
			, ProtectionPlanPrice
			, ProtectionPlanCost
			, SalesType
			, GrossMultiplier
			, REACCategory
			, DateCreated
			, DateChanged
			, SUOrderID
			, ShipLocationID
			, FRLocationID
			, PriceOverrideStaffID
			, InvSubBucketID
			, PPPOpp
			, PPPClose
			, LYComp 
			, TYComp
		)

		SELECT 
			SourceSystem
			, Source
			, SourceDataID
			, SalesDataTypeKey
			, TransDateTime
			, TransDateKey
			, OrderDateKey
			, ProductKey
			, CustomerKey
			, SalesPersonKey
			, LocationKey
			, BaseOrderID
			, OrderID
			, ItemID
			, GroupID
			, TransCodeID
			, UpdateTypeID
			, AsIsReasonCodeID
			, VoidedReasonCodeID
			, ItemCommCategory
			, DeliveryStatus
			, ProductDiscountCode
			, PVEReasonCodeID
			, Sales
			, Cost
			, Units
			, ProtectionPlanPrice
			, ProtectionPlanCost
			, SalesType
			, GrossMultiplier
			, REACCategory
			, DateCreated
			, DateChanged
			, SUOrderID
			, ShipLocationID
			, FRLocationID
			, PriceOverrideStaffID
			, InvSubBucketID
			, PPPOpp
			, PPPClose
			, LYComp 
			, TYComp
		FROM [Retail_DW_Core].[FactSalesDetailTransHolding];

	    DROP TABLE [Retail_DW_Core].[FactSalesDetailTransHolding];

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
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable;
	
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