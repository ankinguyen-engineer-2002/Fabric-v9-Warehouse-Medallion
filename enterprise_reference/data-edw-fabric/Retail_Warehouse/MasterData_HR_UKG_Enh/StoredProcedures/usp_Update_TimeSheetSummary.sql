-- no changes needed

CREATE   PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_TimeSheetSummary] 
AS
BEGIN

    DECLARE
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
		@DestinationDatabase VARCHAR(150),
		@DestinationSchema VARCHAR(150),
		@DestinationTable VARCHAR(150);

    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_TimeSheetSummary';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'MasterData_HR_UKG_Enh';
    SET @DestinationTable = 'TimeSheetSummary';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		DECLARE @FromDate DATE = CAST(GETDATE()-30 AS DATE)
				, @ToDate DATE = GETDATE()
				, @FromDateKey INT = CAST(CONVERT(VARCHAR(8), CAST(GETDATE()-30 AS DATE), 112) AS INT)
				, @ToDateKey INT = CAST(CONVERT(VARCHAR(8), GETDATE(), 112) AS INT);

		/* Pay Matrix */

        DELETE FROM [MasterData_HR_UKG_Enh].[TimeSheetSummary]
        WHERE TransDateKey IN 
		(
			SELECT TransDateKey 
			FROM [MasterData_HR_UKG_Enh].[PayMatrix]
		)
		AND SourceDataID = 4;

		INSERT INTO [MasterData_HR_UKG_Enh].[TimeSheetSummary]
		(
			SourceDataID
			, TransDateKey
			, SourceLocationID
			, PayCodeID
			, TaskCodeID
			, TimeCodeID
			, TotalTime
			, TotalCost
			, ApprovedByManager
			, DataSource
		)

		SELECT  
			4 AS SourceDataID
			, pm.TransDateKey
			, pm.SourceLocationID
			, pm.PayCodeID
			, pm.TaskCodeID
			, pm.TimeCodeID
			, SUM(pm.Hours) AS TotalTime
			, SUM(pm.PayAmount) AS TotalCost
			, pm.ApprovedByManager
			, pm.DataSource
		FROM [MasterData_HR_UKG_Enh].[PayMatrix] AS pm
		GROUP BY pm.TransDateKey
				, pm.SourceLocationID
				, pm.PayCodeID
				, pm.TaskCodeID
				, pm.TimeCodeID
				, pm.ApprovedByManager
				, pm.DataSource;

        /* DTRContractorData */

		DELETE FROM [MasterData_HR_UKG_Enh].[TimeSheetSummary]
		WHERE TransDateKey IN 
		(
			SELECT TransDateKey 
			FROM [MasterData_HR_UKG_Enh].[DTRContractorData]
		)
		AND SourceDataID = 3
		AND PayCodeID = 8;

        /*Regular Time and Cost*/

        INSERT INTO [MasterData_HR_UKG_Enh].[TimeSheetSummary]
        (
            SourceDataID
            , TransDateKey
            , SourceLocationID
            , PayCodeID
            , TaskCodeID
            , TimeCodeID
            , TotalTime
            , TotalCost
            , IsExternal
            , ApprovedByManager
			, DataSource
        )
        SELECT
            3 AS SourceDataID
            , CAST(CONVERT(VARCHAR(8), pm.TransDate, 112) AS INT) AS TransDateKey
            , pm.LocationID AS SourceLocationID
            , 8 AS PayCodeID
            , pm.TaskCodeID
            , 0 AS TimeCodeID
            , SUM(pm.RegularHours) AS TotalTime
            , SUM(pm.RegularCost) AS TotalCost
            , 1 AS IsExternal
            , 1 AS ApprovedByManager
			, 'DSG' AS DataSource
			--, CASE WHEN st.CompanyCode = 'DSG' THEN 'DSG'
			--WHEN st.CompanyCode = 'AGR' THEN 'AGR'
			--ELSE NULL
			--END AS DataSource
        FROM [MasterData_HR_UKG_Enh].[DTRContractorData] pm
		--INNER JOIN [MasterData_Retail_Ent].[StoreLocation] st
		--ON st.StoreID = pm.LocationID
        WHERE pm.ContractorTaskTypeID = 1
        GROUP BY CAST(CONVERT(VARCHAR(8), pm.TransDate, 112) AS INT)
				 , pm.LocationID
				 , pm.TaskCodeID;
				 --, st.CompanyCode;

        /*Over Time and Cost*/

        INSERT INTO [MasterData_HR_UKG_Enh].[TimeSheetSummary]
        (
            SourceDataID
            , TransDateKey
            , SourceLocationID
            , PayCodeID
            , TaskCodeID
            , TimeCodeID
            , TotalTime
            , TotalCost
            , IsExternal
            , ApprovedByManager
			, DataSource
        )

        SELECT
            3 AS SourceDataID
            , CAST(CONVERT(VARCHAR(8), pm.TransDate, 112) AS INT) AS TransDateKey
            , pm.LocationID AS SourceLocationID
            , 8 AS PayCodeID
            , pm.TaskCodeID
            , 1 AS TimeCodeID
            , SUM(pm.OvertimeHours) AS TotalTime
            , SUM(pm.OvertimeCost) AS TotalCost
            , 1 AS IsExternal
            , 1 AS ApprovedByManager
			, 'DSG' AS DataSource
			--, CASE WHEN st.CompanyCode = 'DSG' THEN 'DSG'
			--WHEN st.CompanyCode = 'AGR' THEN 'AGR'
			--ELSE NULL
			--END AS DataSource
        FROM [MasterData_HR_UKG_Enh].[DTRContractorData] pm
		--INNER JOIN [MasterData_Retail_Ent].[StoreLocation] st
		--ON st.StoreID = pm.LocationID
        WHERE pm.ContractorTaskTypeID = 1
        GROUP BY CAST(CONVERT(VARCHAR(8), pm.TransDate, 112) AS INT)
				 , pm.LocationID
				 , pm.TaskCodeID;
				 --, st.CompanyCode;

		/* Total DC Expenses */

		DELETE tss
		FROM [MasterData_HR_UKG_Enh].[TimeSheetSummary] tss
		WHERE tss.TransDateKey BETWEEN @FromDateKey AND @ToDateKey
		AND PayCodeID = 11;

		IF OBJECT_ID('tempdb..#MonthlyExpenses') IS NOT NULL 
		DROP TABLE #MonthlyExpenses;

        SELECT
		   d.TransDate AS MonthStartDate
		   , EOMONTH(d.TransDate) AS MonthEndDate
		   , d.LocationID
		   , d.TaskCodeID
		   , d.RegularCost * 1.0 / DAY(EOMONTH(d.TransDate)) AS DailyAvgExpense
		INTO #MonthlyExpenses
		FROM [MasterData_HR_UKG_Enh].[DTRContractorData] d
		WHERE d.TransDate BETWEEN @FromDate AND @ToDate
		AND d.EntryTypeID = 8;

		INSERT INTO [MasterData_HR_UKG_Enh].[TimeSheetSummary]
		(
			SourceDataID
			, TransDateKey
			, SourceLocationID
			, PayCodeID
			, TaskCodeID
			, TimeCodeID
			, TotalTime
			, TotalCost
			, DataSource
		)

		SELECT
		   3 AS SourceDataID
		   , CONVERT(VARCHAR(8), MonthStartDate, 112) AS TransDateKey
		   , LocationID
		   , 11 AS PayCodeID
		   , TaskCodeID
		   , 0 AS TimeCodeID
		   , NULL AS TotalTime
		   , DailyAvgExpense
		   , 'DSG' AS DataSource
		FROM #MonthlyExpenses me
		WHERE MonthStartDate BETWEEN MonthStartDate AND MonthEndDate;

		/* Benefits */
		
		UPDATE tss
        SET tss.Benefit = 0
        FROM [MasterData_HR_UKG_Enh].[TimeSheetSummary] tss
        INNER JOIN [MasterData_HR_UKG_Enh].[DTRContractorData] src
        ON LEFT(tss.TransDateKey, 4) = LEFT(src.TransDateKey, 4)
        AND tss.SourceLocationID = src.LocationID
        WHERE tss.SourceDataID = 2
        AND src.EntryTypeID = 10;

        UPDATE tss
        SET tss.Benefit = src.RegularCost
        FROM [MasterData_HR_UKG_Enh].[TimeSheetSummary] tss
        INNER JOIN [MasterData_HR_UKG_Enh].[DTRContractorData] src
        ON LEFT(tss.TransDateKey, 4) = LEFT(src.TransDateKey, 4)
        AND tss.SourceLocationID = src.LocationID
        WHERE tss.SourceDataID = 2
        AND src.EntryTypeID = 10;

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