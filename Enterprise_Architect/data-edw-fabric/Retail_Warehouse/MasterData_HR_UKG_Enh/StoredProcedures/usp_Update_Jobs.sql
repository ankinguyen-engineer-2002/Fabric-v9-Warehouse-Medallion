CREATE     PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_Jobs]
AS

BEGIN

	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_Jobs' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'Jobs';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		--update existing records (if changed)

		UPDATE j
		SET j.JobTitle = wj.title,
			j.IsActive = wj.isActive,
			j.JobFamilyCode = wj.jobFamilyCode,
			j.LongDescription = wj.longDescription
		FROM [MasterData_HR_UKG_Enh].[Jobs] j
		INNER JOIN [$(Source_Data)].[MasterData_HR_UKG_DSG].[Jobs] wj
		ON j.JobCode = wj.jobCode
		WHERE j.JobTitle <> wj.title
		OR j.IsActive <> wj.isActive
		OR j.JobFamilyCode <> wj.jobFamilyCode
		OR j.LongDescription <> wj.longDescription;

		--insert new records
	
		INSERT INTO [MasterData_HR_UKG_Enh].[Jobs] 
		(
			JobKey
			, DataSource
			, JobCode
			, JobTitle
			, IsActive
			, JobFamilyCode
			, LongDescription
		)
	
		SELECT 
			wj.[key]
			, wj.dataSource
			, wj.jobCode
			, wj.title
			, wj.isActive
			, wj.jobFamilyCode
			, wj.longDescription
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[Jobs] wj
		LEFT JOIN [MasterData_HR_UKG_Enh].[Jobs] j 
		ON j.JobCode = wj.jobCode 
		WHERE j.JobCode IS NULL;

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