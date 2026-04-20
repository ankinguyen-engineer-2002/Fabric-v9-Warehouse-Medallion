CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_FactSalesOrderHeader]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactSalesOrderHeader';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactSalesOrderHeader';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		TRUNCATE TABLE [Retail_DW_Core].[FactSalesOrderHeader]

		 --DECLARE @StartDate DATE = GETDATE()-1
		 --		, @EndDate DATE = GETDATE();

	    DROP TABLE IF EXISTS [Retail_DW_Core].[FactSalesOrderHeaderHolding];

		CREATE TABLE [Retail_DW_Core].[FactSalesOrderHeaderHolding]
		(
			[SourceSystem] [varchar](30) NOT NULL,
			[OrderKey] [bigint] NOT NULL,
			[SourceOrderID] [varchar](20) NOT NULL,
			[BaseOrderID] [varchar](20) NOT NULL,
			[DateCreated] [datetime2](3) NULL,
			[LastUpdatedUTC] [datetime2](3) NULL,
			[CustomerKey] [bigint] NOT NULL,
			[CustomerID] [varchar](128) NOT NULL,
			[CustomerName] [varchar](150) NULL,
			[OrderStatus] [varchar](30) NOT NULL,
			[SalesChannel] [varchar](30) NOT NULL,
			[OrderType] [varchar](10) NOT NULL,
			[CompanyCode] [varchar](5) NOT NULL,
			[IsOnHold] [bit] NOT NULL,
			[TotalSales] [decimal](19, 4) NULL,
			[TotalCharges] [decimal](19, 4) NULL,
			[TotalPayment] [decimal](19, 4) NULL,
			[TotalAdditionalTaxAmount] [decimal](19, 4) NULL,
			[TotalStateTaxAmount] [decimal](19, 4) NULL,
			[TotalTaxes] [decimal](19, 4) NULL,
			[FinanceAmount] [decimal](19, 4) NULL,
			[BalanceDue] [decimal](19, 4) NULL,
			[PaymentTypeID] [varchar](50) NULL,
			[BillToStreetAddress] [varchar](255) NULL,
			[BillToAddressLine2] [varchar](128) NULL,
			[BillToCity] [varchar](128) NULL,
			[BilltoStateOrProvinceCode] [char](2) NULL,
			[BillToZipOrPostalCode] [varchar](10) NULL,
			[BillToCountryCode] [char](2) NULL,
			[ShipInstruction] [varchar](255) NULL,
			[OrderContactName] [varchar](150) NOT NULL,
			[OrderContactEmail] [varchar](128) NULL,
			[OrderContactPhone] [varchar](20) NULL,
			[CSLastContact] [date] NULL,
			[CSNextContact] [date] NULL,
			[StoreAccount] [varchar](8) NULL,
			[StoreShipTo] [varchar](4) NULL,
			[StoreOperationID] [int] NULL,
			[StoreID] [int] NOT NULL,
			[StoreBrandID] [varchar](20) NULL,
			[FulfillerID] [varchar](20) NULL,
			[CartID] [varchar](40) NULL,
			[IsWrittenOrder] [bit] NULL,
			[OrderDate] [date] NULL,
			[VoidedDate] [date] NULL,
			[OrderCount] [char](10) NULL,
			[OriginalInvoiceID] [varchar](30) NULL,
			[MarketingCodeID] [varchar](30) NULL,
			[TransCodeID] [int] NULL,
			[TransCodeMultiplier] [bit] NULL,
			[RouteCodeID] [varchar](30) NULL,
			[CreditHoldCodeID] [varchar](5) NULL,
			[ServiceStaffID] [varchar](20) NULL,
			[RequestedDate] [date] NULL,
			[TransactionSaveTime] [datetime2](3) NULL,
			[TransactionStartTime] [datetime2](3) NULL,
			[PriceExceptionComment] [varchar](600) NULL,
			[InstallationCharge] [decimal](19, 4) NULL,
			[DeliveryCharge] [decimal](19, 4) NULL,
			[DeliveryChargeCalculated] [decimal](19, 4) NULL,
			[DeliveryChargeOverUserID] [varchar](5) NULL,
			[DeliveryChargeOverride] [varchar](5) NULL,
			[DeliveryChoice] [varchar](10) NULL,
			[DeliveryChargeCompliant] [int] NULL,
			[DeliveryCapAvailDate] [date] NULL,
			[OriginalDeliveryDate] [datetime2](3) NULL,
			[OriginalDeliveryType] [varchar](50) NULL,
			[SFMCFulfillmentStatus] [varchar](50) NULL,
			[SFMCFulfillmentType] [varchar](50) NULL,
			[SFMCLastFulfillmentDate] [datetime2](3) NULL,
			[SFMCPrimaryOrderCategory] [varchar](50) NULL,
			[IsFinanced] [int] NULL,
			[OriginalTransCodeID] [int] NULL,
			[OriginalTransDate] [datetime2](3) NULL,
			[SalesPersonID] [varchar](20) NULL,
			[SuperOrderID] [varchar](50) NULL,
			[LastActivityDate] [datetime2](3) NULL,
			[DateClosed] [datetime2](3) NULL,
			[RecStatus] [char](1) NULL
		);

		INSERT INTO [Retail_DW_Core].[FactSalesOrderHeaderHolding]
		(	
			SourceSystem
			, OrderKey
			, SourceOrderID
			, BaseOrderID
			, DateCreated
			, LastUpdatedUTC
			, CustomerKey
			, CustomerID
			, CustomerName
			, OrderStatus
			, SalesChannel
			, OrderType
			, CompanyCode
			, IsOnHold
			, TotalSales
			, TotalCharges
			, TotalPayment
			, TotalAdditionalTaxAmount
			, TotalStateTaxAmount
			, TotalTaxes
			, FinanceAmount
			, BalanceDue
			, PaymentTypeID
			, BillToStreetAddress
			, BillToAddressLine2
			, BillToCity
			, BilltoStateOrProvinceCode
			, BillToZipOrPostalCode
			, BillToCountryCode
			, ShipInstruction
			, OrderContactName
			, OrderContactEmail
			, OrderContactPhone
			, CSLastContact
			, CSNextContact
			, StoreAccount
			, StoreShipTo
			, StoreOperationID
			, StoreID
			, StoreBrandID
			, FulfillerID
			, CartID
			, IsWrittenOrder
			, OrderDate
			, VoidedDate
			, OrderCount
			, OriginalInvoiceID
			, MarketingCodeID
			, TransCodeID
			, TransCodeMultiplier
			, RouteCodeID
			, CreditHoldCodeID
			, ServiceStaffID
			, RequestedDate
			, TransactionSaveTime
			, TransactionStartTime
			, PriceExceptionComment
			, InstallationCharge
			, DeliveryCharge
			, DeliveryChargeCalculated
			, DeliveryChargeOverUserID
			, DeliveryChargeOverride
			, DeliveryChoice
			, DeliveryChargeCompliant
			, DeliveryCapAvailDate
			, OriginalDeliveryDate
			, OriginalDeliveryType
			, SFMCFulfillmentStatus
			, SFMCFulfillmentType
			, SFMCLastFulfillmentDate
			, SFMCPrimaryOrderCategory
			, IsFinanced
			, OriginalTransCodeID
			, OriginalTransDate
			, SalesPersonID
			, SuperOrderID
			, LastActivityDate
			, DateClosed
			, RecStatus
		)

		SELECT 
			oh.SourceSystem
			, oh.OrderKey
			, oh.SourceOrderID
			, oh.BaseOrderID
			, oh.DateCreated
			, oh.LastUpdatedUTC
			, ISNULL(cm.CustomerKey, 0) AS CustomerKey
			, oh.SourceCustomerID AS CustomerID
			, oh.CustomerName
			, oh.OrderStatus
			, oh.SalesChannel
			, oh.OrderType
			, oh.CompanyCode
			, oh.IsOnHold
			, oh.TotalSales
			, oh.TotalCharges
			, oh.TotalPayment
			, oh.TotalAdditionalTaxAmount
			, oh.TotalStateTaxAmount
			, oh.TotalTaxes
			, oh.FinanceAmount
			, oh.BalanceDue
			, oh.PaymentTypeID
			, oh.BillToStreetAddress
			, oh.BillToAddressLine2
			, oh.BillToCity
			, oh.BilltoStateOrProvinceCode
			, oh.BillToZipOrPostalCode
			, oh.BillToCountryCode
			, oh.ShipInstruction
			, oh.OrderContactName
			, oh.OrderContactEmail
			, oh.OrderContactPhone
			, oh.CSLastContact
			, oh.CSNextContact
			, oh.StoreAccount
			, oh.StoreShipTo
			, oh.StoreOperationID
			, oh.StoreID
			, oh.StoreBrandID
			, oh.FulfillerID
			, oh.CartID
			, oh.IsWrittenOrder
			, oh.OrderDate
			, oh.VoidedDate
			, oh.OrderCount
			, oh.OriginalInvoiceID
			, oh.MarketingCodeID
			, oh.TransCodeID
			, oh.TransCodeMultiplier
			, oh.RouteCodeID
			, oh.CreditHoldCodeID
			, oh.ServiceStaffID
			, oh.RequestedDate
			, oh.TransactionSaveTime
			, oh.TransactionStartTime
			, oh.PriceExceptionComment
			, oh.InstallationCharge
			, oh.DeliveryCharge
			, oh.DeliveryChargeCalculated
			, oh.DeliveryChargeOverUserID
			, oh.DeliveryChargeOverride
			, oh.DeliveryChoice
			, oh.DeliveryChargeCompliant
			, oh.DeliveryCapAvailDate
			, oh.OriginalDeliveryDate
			, oh.OriginalDeliveryType
			, oh.SFMCFulfillmentStatus
			, oh.SFMCFulfillmentType
			, oh.SFMCLastFulfillmentDate
			, oh.SFMCPrimaryOrderCategory
			, oh.IsFinanced
			, oh.OriginalTransCodeID
			, oh.OriginalTransDate
			, oh.SalesPersonID
			, oh.SuperOrderID
			, oh.LastActivityDate
			, oh.DateClosed
			, oh.RecStatus
		FROM [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderHeader] oh
		LEFT JOIN [Retail_DW_Core].[DimCustomerMaster] AS cm
		ON cm.CustomerID = oh.SourceCustomerID;
		--WHERE
		--(
		--	CAST(oh.DateCreated AS DATE) BETWEEN @StartDate AND @EndDate
		--	OR CAST(oh.LastUpdatedUTC AS DATE) BETWEEN @StartDate AND @EndDate
		--);
		--WHERE COALESCE(CAST(oh.LastUpdatedUTC AS DATE), CAST(oh.DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;

		UPDATE oh
		SET StoreBrandID = sb.StoreBrandID
		FROM [Retail_DW_Core].[FactSalesOrderHeaderHolding] AS oh
		INNER JOIN
		(
			SELECT od.SourceOrderID
				   , MAX(pm.StoreBrandID) AS StoreBrandID
			FROM [Retail_DW_Core].[FactSalesOrderHeaderHolding] AS oh
			INNER JOIN [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderLine] AS od
			ON od.SourceOrderID = oh.SourceOrderID
			INNER JOIN [Retail_DW_Core].[DimProductMaster] AS pm
			ON pm.SKU = od.SKU
			WHERE oh.StoreBrandID IS NULL
			AND pm.IsMaster = 1
			GROUP BY od.SourceOrderID
		) sb
		ON sb.SourceOrderID = oh.SourceOrderID
		WHERE oh.StoreBrandID IS NULL;

		UPDATE oh
		SET oh.IsFinanced = 1
		FROM [Retail_DW_Core].[FactSalesOrderHeaderHolding] AS oh
		INNER JOIN [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderHist] AS sot
		ON oh.SourceOrderID = sot.OrderID
		INNER JOIN [Retail_DW_Core].[DimPaymentType] AS pt 
		ON pt.PaymentTypeID = sot.TransKey
		WHERE sot.SalesDataTypeKey = 5
		AND pt.IsFinanced = 1;

		-- DELETE FROM [Retail_DW_Core].[FactSalesOrderHeader]
		-- WHERE
		--(
		--	CAST(DateCreated AS DATE) BETWEEN @StartDate AND @EndDate
		--	OR CAST(LastUpdatedUTC AS DATE) BETWEEN @StartDate AND @EndDate
		--);
		 --WHERE COALESCE(CAST(LastUpdatedUTC AS DATE), CAST(DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;
		

		INSERT INTO [Retail_DW_Core].[FactSalesOrderHeader]
		(
			SourceSystem
			, OrderKey
			, SourceOrderID
			, BaseOrderID
			, DateCreated
			, LastUpdatedUTC
			, CustomerKey
			, CustomerID
			, CustomerName
			, OrderStatus
			, SalesChannel
			, OrderType
			, CompanyCode
			, IsOnHold
			, TotalSales
			, TotalCharges
			, TotalPayment
			, TotalAdditionalTaxAmount
			, TotalStateTaxAmount
			, TotalTaxes
			, FinanceAmount
			, BalanceDue
			, PaymentTypeID
			, BillToStreetAddress
			, BillToAddressLine2
			, BillToCity
			, BilltoStateOrProvinceCode
			, BillToZipOrPostalCode
			, BillToCountryCode
			, ShipInstruction
			, OrderContactName
			, OrderContactEmail
			, OrderContactPhone
			, CSLastContact
			, CSNextContact
			, StoreAccount
			, StoreShipTo
			, StoreOperationID
			, StoreID
			, StoreBrandID
			, FulfillerID
			, CartID
			, IsWrittenOrder
			, OrderDate
			, VoidedDate
			, OrderCount
			, OriginalInvoiceID
			, MarketingCodeID
			, TransCodeID
			, TransCodeMultiplier
			, RouteCodeID
			, CreditHoldCodeID
			, ServiceStaffID
			, RequestedDate
			, TransactionSaveTime
			, TransactionStartTime
			, PriceExceptionComment
			, InstallationCharge
			, DeliveryCharge
			, DeliveryChargeCalculated
			, DeliveryChargeOverUserID
			, DeliveryChargeOverride
			, DeliveryChoice
			, DeliveryChargeCompliant
			, DeliveryCapAvailDate
			, OriginalDeliveryDate
			, OriginalDeliveryType
			, SFMCFulfillmentStatus
			, SFMCFulfillmentType
			, SFMCLastFulfillmentDate
			, SFMCPrimaryOrderCategory
			, IsFinanced
			, OriginalTransCodeID
			, OriginalTransDate
			, SalesPersonID
			, SuperOrderID
			, LastActivityDate
			, DateClosed
			, RecStatus
		)

		SELECT 
			SourceSystem
			, OrderKey
			, SourceOrderID
			, BaseOrderID
			, DateCreated
			, LastUpdatedUTC
			, CustomerKey
			, CustomerID
			, CustomerName
			, OrderStatus
			, SalesChannel
			, OrderType
			, CompanyCode
			, IsOnHold
			, TotalSales
			, TotalCharges
			, TotalPayment
			, TotalAdditionalTaxAmount
			, TotalStateTaxAmount
			, TotalTaxes
			, FinanceAmount
			, BalanceDue
			, PaymentTypeID
			, BillToStreetAddress
			, BillToAddressLine2
			, BillToCity
			, BilltoStateOrProvinceCode
			, BillToZipOrPostalCode
			, BillToCountryCode
			, ShipInstruction
			, OrderContactName
			, OrderContactEmail
			, OrderContactPhone
			, CSLastContact
			, CSNextContact
			, StoreAccount
			, StoreShipTo
			, StoreOperationID
			, StoreID
			, StoreBrandID
			, FulfillerID
			, CartID
			, IsWrittenOrder
			, OrderDate
			, VoidedDate
			, OrderCount
			, OriginalInvoiceID
			, MarketingCodeID
			, TransCodeID
			, TransCodeMultiplier
			, RouteCodeID
			, CreditHoldCodeID
			, ServiceStaffID
			, RequestedDate
			, TransactionSaveTime
			, TransactionStartTime
			, PriceExceptionComment
			, InstallationCharge
			, DeliveryCharge
			, DeliveryChargeCalculated
			, DeliveryChargeOverUserID
			, DeliveryChargeOverride
			, DeliveryChoice
			, DeliveryChargeCompliant
			, DeliveryCapAvailDate
			, OriginalDeliveryDate
			, OriginalDeliveryType
			, SFMCFulfillmentStatus
			, SFMCFulfillmentType
			, SFMCLastFulfillmentDate
			, SFMCPrimaryOrderCategory
			, IsFinanced
			, OriginalTransCodeID
			, OriginalTransDate
			, SalesPersonID
			, SuperOrderID
			, LastActivityDate
			, DateClosed
			, RecStatus
		FROM [Retail_DW_Core].[FactSalesOrderHeaderHolding];

	    DROP TABLE [Retail_DW_Core].[FactSalesOrderHeaderHolding];

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