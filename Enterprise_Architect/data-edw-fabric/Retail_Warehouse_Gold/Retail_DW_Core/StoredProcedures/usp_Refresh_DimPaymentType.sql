CREATE PROCEDURE [Retail_DW_Core].[usp_Refresh_DimPaymentType]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Refresh_DimPaymentType';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'DimPaymentType';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(PaymentTypeKey),0) FROM [Retail_DW_Core].[DimPaymentType]);
		
		UPDATE tgt
		SET tgt.PaymentTypeName = src.PaymentTypeName
			, tgt.PaymentClass = src.PaymentClass
			, tgt.FinanceUseFee = src.FinanceUseFee
			, tgt.IsFinanced = src.IsFinanced
			, tgt.PaymentTypeGroupID = src.PaymentTypeGroupID
			, tgt.PaymentTypeSubGroupID = src.PaymentTypeSubGroupID
			, tgt.PaymentTypeSubGroupName = src.PaymentTypeSubGroupName
			, tgt.TermsDuration = src.TermsDuration
			, tgt.PaymentTermsGrouping = src.PaymentTermsGrouping
			, tgt.PaymentTierLevel = src.PaymentTierLevel
			, tgt.FinanceProviderName = src.FinanceProviderName
			, tgt.VendorID = src.VendorID
		FROM [Retail_DW_Core].[DimPaymentType] tgt
		INNER JOIN [$(Retail_Warehouse)].[MasterData_Ent].[PaymentType] src
		ON tgt.PaymentTypeID = src.PaymentTypeID;

		INSERT INTO [Retail_DW_Core].[DimPaymentType]
		(
			PaymentTypeKey
			, PaymentTypeID
			, PaymentTypeName
			, PaymentClass
			, FinanceUseFee
			, PaymentTypeGroupID
			, IsFinanced
			, PaymentTypeSubGroupID
			, PaymentTypeSubGroupName
			, TermsDuration
			, PaymentTermsGrouping
			, PaymentTierLevel
			, VendorID
			, FinanceProviderName
			, StartDate
			, EndDate
		)
		SELECT
	
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY src.PaymentTypeID) AS BIGINT) AS PaymentTypeKey
			, src.PaymentTypeID
			, src.PaymentTypeName
			, src.PaymentClass
			, src.FinanceUseFee
			, src.PaymentTypeGroupID
			, src.IsFinanced
			, src.PaymentTypeSubGroupID 
			, src.PaymentTypeSubGroupName
			, src.TermsDuration
			, src.PaymentTermsGrouping
			, src.PaymentTierLevel
			, src.VendorID
			, src.FinanceProviderName
			, src.StartDate
			, src.EndDate
		FROM [Retail_DW_Core].[DimPaymentType] tgt
		RIGHT OUTER JOIN [$(Retail_Warehouse)].[MasterData_Ent].[PaymentType] src
		ON tgt.PaymentTypeID = src.PaymentTypeID
		WHERE tgt.PaymentTypeID IS NULL;

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