CREATE      PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_TimeSheetHours]
AS
BEGIN

DECLARE
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
		@DestinationDatabase VARCHAR(150),
		@DestinationSchema VARCHAR(150),
		@DestinationTable VARCHAR(150);

    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_TimeSheetWorkHours';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'MasterData_HR_UKG_Enh';
    SET @DestinationTable = 'TimeSheetHours';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		DECLARE @LastDate DATE;
		SET @LastDate = 
		(
			SELECT MIN(CONVERT(DATE, CAST(TransDateKey AS VARCHAR(8)), 112)) 
			FROM [MasterData_HR_UKG_Enh].[TimesheetETL]
		);

		IF OBJECT_ID('tempdb..#Dates') IS NOT NULL 
		DROP TABLE #Dates;

		SELECT 
			CONVERT(VARCHAR(8), TransDate, 112) AS TransDateKey 
		INTO #Dates
		FROM [Retail_Traffic].[StoreTraffic]
		WHERE LastUpdated >= @LastDate
		GROUP BY CONVERT(VARCHAR(8), TransDate, 112);

		IF OBJECT_ID('tempdb..#Traffic') IS NOT NULL 
		DROP TABLE #Traffic;

		SELECT 
			*
			, CONVERT(VARCHAR(8), TransDate, 112) AS TransDateKey 
		INTO #Traffic
		FROM [Retail_Traffic].[StoreTraffic];

		IF OBJECT_ID('tempdb..#TC') IS NOT NULL 
		DROP TABLE #TC;

		SELECT
			tt.StoreID AS LocationID
			, tt.TransDateKey
			, DATEADD(HOUR, tt.TransHour, CONVERT(DATETIME2(3), CAST(tt.TransDateKey AS VARCHAR(8)), 112)) AS StartWindow
			--, CAST(LEFT(tt.TransDateKey, 4) + '-' + RIGHT(LEFT(tt.TransDateKey, 6), 2) + '-' + RIGHT(tt.TransDateKey, 2) + ' ' + CAST(tt.TransHour AS VARCHAR(20)) AS DATETIME2(3)) AS StartWindow
			, MAX(tt.IsOpen) AS IsOpen
		INTO #TC
		FROM #Traffic tt
		INNER JOIN #Dates AS d 
		ON d.TransDateKey = tt.TransDateKey
		GROUP BY tt.StoreID
				 , tt.TransDateKey
				 , tt.TransHour;

		IF OBJECT_ID('tempdb..#TS') IS NOT NULL 
		DROP TABLE #TS;

		SELECT	
			pr.EmployeeNumber
			, tpts.SourceLocationID AS LocationID
			, tpts.TransDateKey
			, tpts.TimeIn
			, tpts.[TimeOut]
			, tpts.ApprovedByManager
			, tpts.DataSource
		INTO #TS
		FROM [MasterData_HR_UKG_Enh].[PeopleTimeSheet] tpts
		INNER JOIN [MasterData_HR_UKG_Enh].[PeopleRecords] AS pr 
		ON pr.EmployeeNumber = tpts.EmployeeNumber
		INNER JOIN #Dates AS d 
		ON d.TransDateKey = tpts.TransDateKey
		WHERE tpts.[Time] IS NOT NULL;

		IF OBJECT_ID('tempdb..#RASM') IS NOT NULL 
		DROP TABLE #RASM;

		SELECT	
			rsa.EmployeeNumber
			, rsa.LocationID
			, rsa.TransDateKey
			, rsa.StartWindow
			, rsa.TimeIn
			, rsa.[TimeOut]
			, rsa.IsOpen
			, rsa.ApprovedByManager
			, rsa.DataSource
			, SUM(CASE WHEN rsa.MinWorked < 0 THEN 0 ELSE rsa.MinWorked END) AS MinutesWorked
		INTO #RASM
		FROM 
		(
			SELECT	
				t2.EmployeeNumber
				, t.LocationID
				, t.TransDateKey
				, t.StartWindow
				, t2.TimeIn
				, t2.TimeOut
				, t.IsOpen
				, t2.ApprovedByManager
				, t2.DataSource
				, DATEDIFF(MINUTE, CASE WHEN t2.TimeIn <= t.StartWindow THEN t.StartWindow ELSE t2.TimeIn END,
				CASE WHEN t2.TimeOut >= DATEADD(MINUTE, 60, t.StartWindow) THEN DATEADD(MINUTE, 60, t.StartWindow) ELSE t2.TimeOut END ) MinWorked
				FROM #TC AS t
				INNER JOIN #TS AS t2 
				ON t2.TransDateKey = t.TransDateKey
				AND t2.LocationID = t.LocationID
			) rsa
			GROUP BY rsa.EmployeeNumber
					 , rsa.LocationID
					 , rsa.TransDateKey
					 , rsa.StartWindow
					 , rsa.TimeIn
					 , rsa.[TimeOut]
					 , rsa.IsOpen
					 , rsa.ApprovedByManager
					 , rsa.DataSource;
					 
		DELETE FROM tsh 
		FROM [MasterData_HR_UKG_Enh].[TimeSheetHours] tsh 
		INNER JOIN #Dates AS d 
		ON d.TransDateKey = tsh.TransDateKey;

		DELETE FROM #RASM 
		WHERE MinutesWorked = 0;

		INSERT INTO [MasterData_HR_UKG_Enh].[TimeSheetHours]
		(
			EmployeeNumber
			, LocationID
			, TransDateKey
			, TransHour
			, TimeIn
			, [TimeOut]
			, MinutesWorked
			, IsOpen
			, ApprovedByManager
			, DataSource
		)
		
		SELECT	
			r.EmployeeNumber
			, r.LocationID
			, r.TransDateKey
			, CAST(r.StartWindow AS SMALLDATETIME) AS TransHour
			, CAST(r.TimeIn AS SMALLDATETIME) AS TimeIn
			, CAST(r.TimeOut AS SMALLDATETIME) AS TimeOut
			, r.MinutesWorked
			, r.IsOpen
			, r.ApprovedByManager
			, r.DataSource
		FROM #RASM AS r;

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