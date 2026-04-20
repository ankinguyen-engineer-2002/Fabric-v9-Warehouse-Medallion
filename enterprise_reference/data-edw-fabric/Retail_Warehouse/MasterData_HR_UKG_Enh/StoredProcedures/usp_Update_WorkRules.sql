CREATE     PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_WorkRules]
AS

BEGIN
	
	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_WorkRules' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'WorkRules';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		UPDATE wr
		SET wr.WorkRuleName = wwr.[name]
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[WorkRules] wwr
		INNER JOIN [MasterData_HR_UKG_Enh].[WorkRules] wr 
		ON wr.WorkRuleID = wwr.workRuleId;
		 

		INSERT INTO [MasterData_HR_UKG_Enh].[WorkRules]
		(
			WorkRuleID
			, WorkRuleName
			, DataSource
		)
	
		SELECT 
			wwr.workRuleId
			, wwr.[name]
			, wwr.dataSource
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[WorkRules] wwr 
		LEFT JOIN [MasterData_HR_UKG_Enh].[WorkRules] wr 
		ON wr.WorkRuleID = wwr.workRuleId
		WHERE wr.WorkRuleID IS NULL;

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