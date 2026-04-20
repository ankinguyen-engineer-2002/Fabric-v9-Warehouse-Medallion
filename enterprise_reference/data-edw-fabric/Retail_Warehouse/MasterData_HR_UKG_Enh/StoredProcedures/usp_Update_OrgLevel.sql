CREATE     PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_OrgLevel]
AS

BEGIN

	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_OrgLevel' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'OrgLevel';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY
	
		IF OBJECT_ID('tempdb..#OrgLevel') IS NOT NULL 
		DROP TABLE #OrgLevel;

		SELECT *
		INTO #OrgLevel
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[OrgLevel];

		DELETE #OrgLevel
		WHERE code IS NULL OR [level] = 0;

		UPDATE #OrgLevel
		SET [description] = SUBSTRING([description], 5, LEN([description]))
		FROM #OrgLevel
		WHERE ISNUMERIC(LEFT([description], 3)) = 1

		--update existing records (if changed)

		UPDATE ol
		SET ol.OrgDescription = wol.[description]
			, ol.IsActive = wol.isActive
		FROM [MasterData_HR_UKG_Enh].[OrgLevel] ol
		INNER JOIN #OrgLevel wol 
		ON wol.[level] = ol.OrgLevel 
		AND wol.code = ol.OrgCode
		WHERE ol.OrgDescription <> wol.[description]
		OR ol.IsActive <> wol.isActive;
	
		INSERT INTO [MasterData_HR_UKG_Enh].[OrgLevel] 
		(
			OrgLevelKey
			, DataSource
			, OrgCode
			, OrgDescription
			, IsActive
			, OrgLevel
		)
	
		SELECT 
			wol.[key]
			, wol.dataSource
			, wol.code
			, wol.[description]
			, wol.isActive
			, wol.[level]
		FROM #OrgLevel wol
		LEFT JOIN [MasterData_HR_UKG_Enh].[OrgLevel] ol
		ON ol.OrgLevel = wol.[level] 
		AND ol.OrgCode = wol.code
		WHERE ol.OrgCode IS NULL
		ORDER BY wol.[level], wol.code;

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