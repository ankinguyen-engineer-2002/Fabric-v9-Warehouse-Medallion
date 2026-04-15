CREATE     PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_CompanyDetails]
AS

BEGIN

	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_CompanyDetails' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'CompanyDetails';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		--Update existing records (if changed)
    
		UPDATE cd
		SET CompanyCode = wcd.companyCode,
			CompanyName = wcd.companyName
		FROM [MasterData_HR_UKG_Enh].[CompanyDetails] cd
		INNER JOIN [$(Source_Data)].[MasterData_HR_UKG_DSG].[CompanyDetails] wcd 
		ON wcd.companyId = cd.CompanyID
		WHERE cd.CompanyCode <> wcd.companyCode
		OR cd.CompanyName <> wcd.companyName;

		INSERT INTO [MasterData_HR_UKG_Enh].[CompanyDetails]
		(
			CompanyDetailKey
			, DataSource
			, CompanyID
			, CompanyCode
			, CompanyGLSegment
			, CompanyName
		)
	
		SELECT 
			wcd.[key]
			, wcd.dataSource
			, wcd.companyId
			, wcd.companyCode
			, wcd.companyGLSegment
			, wcd.companyName
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[CompanyDetails] wcd
		LEFT JOIN [MasterData_HR_UKG_Enh].[CompanyDetails] cd 
		ON cd.CompanyID = wcd.companyId
		WHERE cd.CompanyID IS NULL
		ORDER BY wcd.companyCode;

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