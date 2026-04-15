CREATE   PROCEDURE [Retail_DW_Core].[usp_Refresh_DimHRJobs]
AS
BEGIN

	DECLARE
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
		@DestinationDatabase VARCHAR(150),
		@DestinationSchema VARCHAR(150),
		@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_DW_Core.usp_Refresh_DimHRJobs';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_DW_Core'
	SET @DestinationTable = 'DimHRJobs';
	
	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

    BEGIN TRY

		TRUNCATE TABLE [Retail_DW_Core].[DimHRJobs];

		INSERT INTO [Retail_DW_Core].[DimHRJobs]
		(
			JobID
			, JobTitle
			, JobName
			, JobCode
			, JobFamilyCode
			, IsActive
			, IsRSA
			, DataSource
		)
	
		SELECT 
			JobKey AS JobID
			, JobTitle
			, LongDescription AS JobName
			, JobCode
			, JobFamilyCode
			, IsActive
			, CAST(CASE WHEN JobCode = 'RSA' THEN 1 ELSE 0 END AS BIT) AS IsRSA
			, DataSource
		FROM [$(Retail_Warehouse)].[MasterData_HR_UKG_Enh].[Jobs];

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