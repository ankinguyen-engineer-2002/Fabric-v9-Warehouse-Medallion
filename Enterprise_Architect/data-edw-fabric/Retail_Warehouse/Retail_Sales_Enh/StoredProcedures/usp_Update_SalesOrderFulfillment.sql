CREATE PROCEDURE [Retail_Sales_Enh].[usp_Update_SalesOrderFulfillment]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Enh.usp_Update_SalesOrderFulfillment';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_Sales_Enh';
	SET @DestinationTable = 'SalesOrderFulfillment';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_Sales_Enh].[SalesOrderFulfillment];

		UPDATE dst
		SET dst.SourceOrderID = src.SourceOrderID
			, dst.FulfillmentMethod = src.FulfillmentMethod
			, dst.FulfillmentDate = src.FulfillmentDate
			, dst.FulfillmentStatus = src.FulfillmentStatus
			, dst.FulfillmentStoreID = src.FulfillmentStoreID
			, dst.RouteCodeID = src.RouteCodeID
			, dst.DeliveryContactStatusID = src.DeliveryContactStatusID
			, dst.DeliveryContactDate = src.DeliveryContactDate
			, dst.DeliveryCharge = src.DeliveryCharge
			, dst.InstallationCharge = src.InstallationCharge
			, dst.IsInvoiced = src.IsInvoiced
			, dst.RoutingNumber = src.RoutingNumber
			, dst.MerchSubTotal = src.MerchSubTotal
			, dst.HandlingMethodCode = src.HandlingMethodCode
			FROM [Retail_Sales_Enh].[SalesOrderFulfillment] AS dst
			INNER JOIN [Retail_Sales].[SalesOrderFulfillment] AS src 
			ON dst.OrderFulfillmentID = src.OrderFulfillmentID;

		INSERT INTO [Retail_Sales_Enh].[SalesOrderFulfillment]
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
			src.Address1
			, src.Address2
			, src.CellPhone
			, src.City
			, src.CODAmount
			, src.ContactName
			, src.CountryID
			, src.DateChanged
			, src.DateCreated
			, src.DeliverToID
			, src.DeliveryContactDate
			, src.DeliveryContactStatusID
			, src.DeliveryInstruction
			, src.DesiredDate
			, src.DispatchTrackDateTime
			, src.DeliveryCharge
			, src.DeliveryChargeCalculated
			, src.DeliveryChargeOverride
			, src.DeliveryChargeOverrideReasonCodeID
			, src.EmailAddress
			, src.FreightCompanyID
			, src.FulfillmentDate
			, src.FulfillmentMethod
			, src.FulfillmentStatus
			, src.FulfillmentStoreID
			, src.HandlingMethodCode
			, src.HandlingMethodOverride
			, src.HomePhone
			, src.InstallationCharge
			, src.InstallationChargeOverride
			, src.IsInvoiced
			, src.ManifestNumber
			, src.ManifestStoreID
			, src.MerchSubTotal
			, src.Name
			, src.NumberOfPostponements
			, src.OrderFulfillmentID
			, src.SourceOrderID
			, src.PostalCodeID
			, src.RecStatus
			, src.RouteCodeID
			, src.RoutingNumber
			, src.SalesTaxExemptNumber
			, src.StaffID
			, src.State
			, src.StopTime
			, src.StorisCreateDateTime
			, src.TruckNumber
			, src.WmsShipped
			, src.WmsTransmitted
			, src.WorkPhone
			, src.WorkPhoneExt
		FROM [Retail_Sales].[SalesOrderFulfillment] AS src
		LEFT OUTER JOIN [Retail_Sales_Enh].[SalesOrderFulfillment] AS dst 
		ON src.OrderFulfillmentID = dst.OrderFulfillmentID
		WHERE dst.OrderFulfillmentID IS NULL;

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