CREATE PROCEDURE [Retail_DW_Core].[usp_Refresh_DimReasonCode]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Refresh_DimReasonCode';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'DimReasonCode';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(ReasonCodeKey),0) FROM [Retail_DW_Core].[DimReasonCode]);
		
		UPDATE rc
		SET ReasonCodeName = rsn.ReasonCodeName,
			ReasonType = rc.ReasonType,
			RollUpCode = rc.RollUpCode
		FROM [Retail_DW_Core].[DimReasonCode] rc
		INNER JOIN [$(Retail_Warehouse)].[MasterData_Ent].[ReasonCode] rsn
		ON rc.ReasonCodeID = rsn.ReasonCodeID;

		INSERT INTO [Retail_DW_Core].[DimReasonCode]
		(
			ReasonCodeKey,
			ReasonCodeID,
			ReasonCodeName,
			ReasonType,
			RollUpCode,
			DateCreated,
			DateChanged
		)

		SELECT	
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY rsn.ReasonCodeID) AS BIGINT) AS ReasonCodeKey,
			rsn.ReasonCodeID,
			rsn.ReasonCodeName,
			rsn.ReasonType,
			rsn.RollUpCode,
			rsn.DateCreated,
			rsn.DateChanged
		FROM [Retail_DW_Core].[DimReasonCode] rc
		RIGHT OUTER JOIN [$(Retail_Warehouse)].[MasterData_Ent].[ReasonCode] rsn
		ON rc.ReasonCodeID = rsn.ReasonCodeID
		WHERE rc.ReasonCodeID IS NULL;

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