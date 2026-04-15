CREATE     PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_PayCodes]
AS

BEGIN

	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_PayCodes' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'PayCodes';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		UPDATE pc
		SET PayCodeName = wpc.[name],
			PayCodeVisibleToUser = IIF(wpc.visibleToUser = 1, 1 ,0)
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[PayCodes] wpc
		INNER JOIN [MasterData_HR_UKG_Enh].[PayCodes] pc 
		ON pc.PayCodeKey = wpc.id
		WHERE ISNULL(pc.PayCodeName, '') <> ISNULL(wpc.[name], '')
		OR ISNULL(pc.PayCodeProductivity, '') <> ISNULL(wpc.scheduledHoursType, '')
		OR ISNULL(pc.PayCodeUnit, '') <> ISNULL(wpc.unit, '')
		OR ISNULL(pc.PayCodeType, '') <> ISNULL(wpc.[type], '')
		OR ISNULL(CAST(pc.PayCodeVisibleToUser AS INT), -1) <> ISNULL(CAST(wpc.visibleToUser AS INT), -1);

		INSERT INTO [MasterData_HR_UKG_Enh].[PayCodes]
		(
			PayCodeKey
			, DataSource
			, PayCodeName
			, PayCodeProductivity
			, PayCodeUnit
			, PayCodeType
			, PayCodeVisibleToUser
		)
	
		SELECT
			wpc.id
			, wpc.dataSource
			, wpc.[name]
			, wpc.scheduledHoursType
			, wpc.unit
			, wpc.[type]
			, wpc.visibleToUser
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[PayCodes] wpc
		LEFT JOIN [MasterData_HR_UKG_Enh].[PayCodes] pc 
		ON pc.PayCodeKey = wpc.id
		WHERE pc.PayCodeKey IS NULL;

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