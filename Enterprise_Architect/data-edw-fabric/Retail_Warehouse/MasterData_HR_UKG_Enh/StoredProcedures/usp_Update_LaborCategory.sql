CREATE     PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_LaborCategory]
AS

BEGIN

	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_LaborCategory' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'LaborCategory';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		IF OBJECT_ID('tempdb..#LaborCategory') IS NOT NULL 
		DROP TABLE #LaborCategory;

		SELECT DISTINCT 
			laborCategoryId
			, laborCategoryName
		INTO #LaborCategory
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[ProcessedSegmentLaborCategories];
 
		UPDATE lc
		SET lc.LaborCategoryName = wlc.laborCategoryName 
		FROM #LaborCategory wlc
		INNER JOIN [MasterData_HR_UKG_Enh].[LaborCategory] lc 
		ON lc.LaborCategoryID = wlc.laborCategoryId;
		 

		INSERT INTO [MasterData_HR_UKG_Enh].[LaborCategory]
		(
			LaborCategoryID
			, LaborCategoryName
		)
	
		SELECT
			w.laborCategoryId
			, w.laborCategoryName 
		FROM #LaborCategory w 
		LEFT JOIN [MasterData_HR_UKG_Enh].[LaborCategory] lc
		ON lc.LaborCategoryID = w.laborCategoryId
		WHERE lc.LaborCategoryID IS NULL;

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