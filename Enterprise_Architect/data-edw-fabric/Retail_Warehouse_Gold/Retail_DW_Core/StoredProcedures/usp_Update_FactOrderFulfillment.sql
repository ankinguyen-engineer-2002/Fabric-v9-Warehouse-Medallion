CREATE PROCEDURE [Retail_DW_Core].[usp_Update_FactOrderFulfillment]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactOrderFulfillment';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactOrderFulfillment';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_DW_Core].[FactOrderFulfillment];
	
		DECLARE @StartDate DATE = GETDATE()-180 
				, @EndDate DATE = GETDATE();

		DROP TABLE IF EXISTS [Retail_DW_Core].[FactOrderFulfillmentHolding];

		CREATE TABLE [Retail_DW_Core].[FactOrderFulfillmentHolding]
		(
			[Address1] [varchar](100) NULL,
			[Address2] [varchar](100) NULL,
			[CellPhone] [varchar](15) NULL,
			[City] [varchar](100) NULL,
			[CODAmount] [decimal](19,4) NULL,
			[ContactName] [varchar](100) NULL,
			[CountryID] [varchar](50) NULL,
			[DateChanged] [datetime2](3) NULL,
			[DateCreated] [datetime2](3) NULL,
			[DeliverToID] [varchar](50) NULL,
			[DeliveryContactDate] [date] NULL,
			[DeliveryContactStatusID] [varchar](50) NULL,
			[DeliveryInstruction] [varchar](max) NULL,
			[DesiredDate] [date] NULL,
			[DispatchTrackDateTime] [datetime2](3) NULL,
			[DeliveryCharge] [decimal](19,4) NULL,
			[DeliveryChargeCalculated] [decimal](19,4) NULL,
			[DeliveryChargeOverride] [bit] NULL,
			[DeliveryChargeOverrideReasonCodeID] [varchar](50) NULL,
			[EmailAddress] [varchar](70) NULL,
			[FreightCompanyID] [varchar](50) NULL,
			[FulfillmentDate] [date] NULL,
			[FulfillmentMethod] [varchar](10) NULL,
			[FulfillmentStatus] [varchar](10) NULL,
			[FulfillmentStoreID] [varchar](50) NULL,
			[HandlingMethodCode] [varchar](50) NULL,
			[HandlingMethodOverride] [bit] NULL,
			[HomePhone] [varchar](15) NULL,
			[InstallationCharge] [decimal](19,4) NULL,
			[InstallationChargeOverride] [bit] NULL,
			[IsInvoiced] [bit] NULL,
			[ManifestNumber] [varchar](50) NULL,
			[ManifestStoreID] [varchar](50) NULL,
			[MerchSubTotal] [decimal](19,4) NULL,
			[Name] [varchar](100) NULL,
			[NumberOfPostponements] [int] NULL,
			[OrderFulfillmentID] [varchar](50) NOT NULL,
			[SourceOrderID] [varchar](50) NULL,
			[PostalCodeID] [varchar](50) NULL,
			[RecStatus] [varchar](1) NULL,
			[RouteCodeID] [varchar](50) NULL,
			[RoutingNumber] [int] NULL,
			[SalesTaxExemptNumber] [varchar](50) NULL,
			[StaffID] [varchar](50) NULL,
			[State] [varchar](50) NULL,
			[StopTime] [varchar](50) NULL,
			[StorisCreateDateTime] [datetime2](3) NULL,
			[TruckNumber] [varchar](10) NULL,
			[WmsShipped] [bit] NULL,
			[WmsTransmitted] [bit] NULL,
			[WorkPhone] [varchar](15) NULL,
			[WorkPhoneExt] [varchar](10) NULL			
		);

		INSERT INTO [Retail_DW_Core].[FactOrderFulfillmentHolding]
		(
			Address1
			, Address2
			, CellPhone
			, City
			, CODAmount
			, ContactName
			, CountryID
			, DateChanged
			, DateCreated
			, DeliverToID
			, DeliveryContactDate
			, DeliveryContactStatusID
			, DeliveryInstruction
			, DesiredDate
			, DispatchTrackDateTime
			, DeliveryCharge
			, DeliveryChargeCalculated
			, DeliveryChargeOverride
			, DeliveryChargeOverrideReasonCodeID
			, EmailAddress
			, FreightCompanyID
			, FulfillmentDate
			, FulfillmentMethod
			, FulfillmentStatus
			, FulfillmentStoreID
			, HandlingMethodCode
			, HandlingMethodOverride
			, HomePhone
			, InstallationCharge
			, InstallationChargeOverride
			, IsInvoiced
			, ManifestNumber
			, ManifestStoreID
			, MerchSubTotal
			, Name
			, NumberOfPostponements
			, OrderFulfillmentID
			, SourceOrderID
			, PostalCodeID
			, RecStatus
			, RouteCodeID
			, RoutingNumber
			, SalesTaxExemptNumber
			, StaffID
			, State
			, StopTime
			, StorisCreateDateTime
			, TruckNumber
			, WmsShipped
			, WmsTransmitted
			, WorkPhone
			, WorkPhoneExt
		)

		SELECT
			Address1
			, Address2
			, CellPhone
			, City
			, CODAmount
			, ContactName
			, CountryID
			, DateChanged
			, DateCreated
			, DeliverToID
			, DeliveryContactDate
			, DeliveryContactStatusID
			, DeliveryInstruction
			, DesiredDate
			, DispatchTrackDateTime
			, DeliveryCharge
			, DeliveryChargeCalculated
			, DeliveryChargeOverride
			, DeliveryChargeOverrideReasonCodeID
			, EmailAddress
			, FreightCompanyID
			, FulfillmentDate
			, FulfillmentMethod
			, FulfillmentStatus
			, FulfillmentStoreID
			, HandlingMethodCode
			, HandlingMethodOverride
			, HomePhone
			, InstallationCharge
			, InstallationChargeOverride
			, IsInvoiced
			, ManifestNumber
			, ManifestStoreID
			, MerchSubTotal
			, Name
			, NumberOfPostponements
			, OrderFulfillmentID
			, SourceOrderID
			, PostalCodeID
			, RecStatus
			, RouteCodeID
			, RoutingNumber
			, SalesTaxExemptNumber
			, StaffID
			, State
			, StopTime
			, StorisCreateDateTime
			, TruckNumber
			, WmsShipped
			, WmsTransmitted
			, WorkPhone
			, WorkPhoneExt
		FROM [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderFulfillment]
		WHERE COALESCE(CAST(DateChanged AS DATE), CAST(DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;

		DELETE FROM [Retail_DW_Core].[FactOrderFulfillment]
		WHERE COALESCE(CAST(DateChanged AS DATE), CAST(DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;

		INSERT INTO [Retail_DW_Core].[FactOrderFulfillment]
		(
			Address1
			, Address2
			, CellPhone
			, City
			, CODAmount
			, ContactName
			, CountryID
			, DateChanged
			, DateCreated
			, DeliverToID
			, DeliveryContactDate
			, DeliveryContactStatusID
			, DeliveryInstruction
			, DesiredDate
			, DispatchTrackDateTime
			, DeliveryCharge
			, DeliveryChargeCalculated
			, DeliveryChargeOverride
			, DeliveryChargeOverrideReasonCodeID
			, EmailAddress
			, FreightCompanyID
			, FulfillmentDate
			, FulfillmentMethod
			, FulfillmentStatus
			, FulfillmentStoreID
			, HandlingMethodCode
			, HandlingMethodOverride
			, HomePhone
			, InstallationCharge
			, InstallationChargeOverride
			, IsInvoiced
			, ManifestNumber
			, ManifestStoreID
			, MerchSubTotal
			, Name
			, NumberOfPostponements
			, OrderFulfillmentID
			, SourceOrderID
			, PostalCodeID
			, RecStatus
			, RouteCodeID
			, RoutingNumber
			, SalesTaxExemptNumber
			, StaffID
			, State
			, StopTime
			, StorisCreateDateTime
			, TruckNumber
			, WmsShipped
			, WmsTransmitted
			, WorkPhone
			, WorkPhoneExt
		)

		SELECT 
			Address1
			, Address2
			, CellPhone
			, City
			, CODAmount
			, ContactName
			, CountryID
			, DateChanged
			, DateCreated
			, DeliverToID
			, DeliveryContactDate
			, DeliveryContactStatusID
			, DeliveryInstruction
			, DesiredDate
			, DispatchTrackDateTime
			, DeliveryCharge
			, DeliveryChargeCalculated
			, DeliveryChargeOverride
			, DeliveryChargeOverrideReasonCodeID
			, EmailAddress
			, FreightCompanyID
			, FulfillmentDate
			, FulfillmentMethod
			, FulfillmentStatus
			, FulfillmentStoreID
			, HandlingMethodCode
			, HandlingMethodOverride
			, HomePhone
			, InstallationCharge
			, InstallationChargeOverride
			, IsInvoiced
			, ManifestNumber
			, ManifestStoreID
			, MerchSubTotal
			, Name
			, NumberOfPostponements
			, OrderFulfillmentID
			, SourceOrderID
			, PostalCodeID
			, RecStatus
			, RouteCodeID
			, RoutingNumber
			, SalesTaxExemptNumber
			, StaffID
			, State
			, StopTime
			, StorisCreateDateTime
			, TruckNumber
			, WmsShipped
			, WmsTransmitted
			, WorkPhone
			, WorkPhoneExt
		FROM [Retail_DW_Core].[FactOrderFulfillmentHolding];

		DROP TABLE [Retail_DW_Core].[FactOrderFulfillmentHolding];

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
GO

