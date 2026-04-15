-- no changes needed

CREATE   PROCEDURE [MasterData_HR_UKG_Enh].[usp_Refresh_DTRContractorData] 
AS
BEGIN

    DECLARE
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
		@DestinationDatabase VARCHAR(150),
		@DestinationSchema VARCHAR(150),
		@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Refresh_DTRContractorData' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'DTRContractorData';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		DECLARE @FromDate DATE = DATEADD(DAY, -1000, GETDATE())
				, @ToDate DATE = DATEFROMPARTS(YEAR(GETDATE()), 12, 31);

		TRUNCATE TABLE [MasterData_HR_UKG_Enh].[DTRContractorData];

		INSERT INTO [MasterData_HR_UKG_Enh].[DTRContractorData]
		(
			ID
			, LocationID
			, EntryTypeID
			, TransDate
			, TransDateKey
			, RegularCost
			, OvertimeCost
			, RegularHours
			, OvertimeHours
			, Pieces
			, ModifiedDate
			, ModifiedBy
			, TaskCodeID
			, ContractorTaskTypeID
			, DataSource
		)

		SELECT 
			cd.ID
			, cd.LocationID
			, cd.EntryTypeID
			, cd.TransDate
			, CONVERT(VARCHAR(8), cd.TransDate, 112) AS TransDateKey
			, cd.RegularCost
			, cd.OvertimeCost
			, cd.RegularHours
			, cd.OvertimeHours
			, cd.Pieces
			, cd.ModifiedDate
			, cd.ModifiedBy
			, ce.TaskCodeID
			, ce.ContractorTaskTypeID
			, 'DSG' AS DataSource
		FROM 
		(
			SELECT *
			FROM [$(Source_Data)].[Retail_Miniapps].[DTRContractorData]
			WHERE ISNUMERIC(LocationID) = 1
		) cd
		INNER JOIN [$(Source_Data)].[Retail_Miniapps].[DTRContractorEntry] ce 
		ON cd.EntryTypeID = ce.EntryTypeID
		WHERE cd.TransDate BETWEEN @FromDate AND @ToDate;

		SET @DateValue = GETDATE();

        SELECT
            @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES
        (
            @String, @DateValue, @User, 'Process Complete'
        );

        -- Update last modified in Table Dictionary
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