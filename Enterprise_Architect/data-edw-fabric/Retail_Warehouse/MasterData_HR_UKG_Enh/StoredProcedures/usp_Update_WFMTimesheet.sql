-- no changes needed

CREATE   PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_WFMTimesheet] 
AS
BEGIN

    DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);
                  
    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_WFMTimesheet';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
    SET @DestinationDatabase = 'Retail_Warehouse'
    SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
    SET @DestinationTable = 'WFMTimesheet';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

        DECLARE @MinDate DATE = CAST(DATEADD(DAY, -30, GETDATE()) AS DATE)
                , @MaxDate DATE = CAST(GETDATE() AS DATE)
                , @Today DATE = GETDATE();

        IF OBJECT_ID('tempdb..#Paycodes_PTOs') IS NOT NULL
        DROP TABLE #Paycodes_PTOs;

        SELECT *
        INTO #Paycodes_PTOs
        FROM 
        (
            SELECT 401 PayCodeID
            UNION
            SELECT 301 PayCodeID
            UNION
            SELECT 362 PayCodeID
            UNION
            SELECT 354 PayCodeID
            UNION
            SELECT 251 PayCodeID
            UNION
            SELECT 357 PayCodeID
            UNION
            SELECT 360 PayCodeID
            UNION
            SELECT 253 PayCodeID
            UNION
            SELECT 352 PayCodeID
            UNION
            SELECT 701 PayCodeID
        ) AS Paycodes_PTOs;

        --SEGMENTS
        IF OBJECT_ID('tempdb..#segments') IS NOT NULL
        DROP TABLE #segments;

        SELECT  
            segmentId AS SegmentID
            , itemId AS WorkShiftID
            , employeeQualifier AS EmployeeNumber
            , CAST(roundedStartDateTime AS DATETIME2(3)) AS StartDateTime
            , CAST(roundedEndDateTime AS DATETIME2(3)) AS EndDateTime
            , CAST(applyDate AS DATE) ApplyDate
            , durationInSeconds AS DurationInSeconds
            , segmentTypeId AS SegmentTypeID
            , inProgress AS InProgress
            , CAST(NULL AS VARCHAR(10)) AS LocationID
            , workRuleId AS ProjectID
            , dataSource AS DataSource
        INTO #segments
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[TimecardProcessedSegment]
        WHERE NOT (segmentTypeId IN (1,6) AND roundedStartDateTime = roundedEndDateTime AND durationinseconds = 0)
        AND segmentTypeId NOT IN (4,9);

        --PAYCODES RAW - data manipulation
        IF OBJECT_ID('tempdb..#paycodes_raw') IS NOT NULL
        DROP TABLE #paycodes_raw;

        SELECT DISTINCT
            peoplePersonNumberValue AS EmployeeNumber
            , CAST(dayQualifier AS DATE) AS ApplyDate
            , CAST(timecardTransStartDateTimeRawValue AS DATETIME2(3)) AS StartDateTime
            , CAST(timecardTransEndDateTimeRawValue AS DATETIME2(3)) AS EndDateTime
            , corePayCodeValue AS PayCodeName
            , CAST(timecardTransActualHoursRawValue AS DECIMAL(18,2)) AS WorkHours
            , CAST(REPLACE(timecardTransActualWagesValue,',','') AS DECIMAL(18,2)) Wage
            , dataSource AS DataSource
        INTO #paycodes_raw
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[CommonDataApprovals] -- DSG && AGR
        WHERE timecardTransActualWagesValue IS NOT NULL 
        AND corePayCodeValue IS NOT NULL
        AND dwLoadDateTime IN 
		(
			SELECT MAX(dwLoadDateTime) 
			FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[CommonDataApprovals]
		);

        DELETE FROM #paycodes_raw
        WHERE (WorkHours = 0 AND Wage = 0)
        OR StartDateTime IS NULL;

        DELETE FROM pcr
        FROM #paycodes_raw pcr
        INNER JOIN [MasterData_HR_UKG_Enh].[PayCodes] pc
        ON pc.PayCodeName = pcr.PayCodeName
        WHERE pc.PayCodeUnit <> 'HOUR'
        OR pc.PayCodeVisibleToUser = 0;
        
        UPDATE #paycodes_raw
        SET PayCodeName = REPLACE(PayCodeName, ' - Carryover','')
        WHERE PayCodeName LIKE '% - Carryover';
        UPDATE #paycodes_raw
        SET WorkHours = 0.0
        WHERE PayCodeName IN ('FMLA');

        --forcing same timestamp standard for PTO (paid time off) paycodes
        UPDATE #segments
        SET EndDateTime = DATEADD(MINUTE, ABS(CAST(DurationInSeconds/60.0 AS INT)), StartDateTime)
            , StartDateTime = DATEADD(SECOND, 1, StartDateTime)
        WHERE SegmentTypeID = 6
        AND DurationInSeconds <> 0;

        UPDATE pc
        SET EndDateTime = DATEADD(HOUR, ABS(WorkHours), StartDateTime)
            , StartDateTime = DATEADD(SECOND, 1, StartDateTime)
        FROM #paycodes_raw pc
        INNER JOIN [$(Source_Data)].[MasterData_HR_UKG_DSG].[PayCodes] wpc 
        ON wpc.name = pc.PayCodeName
        INNER JOIN #Paycodes_PTOs pto 
        ON pto.PayCodeID = wpc.id
        WHERE (WorkHours <> 0 OR pc.PayCodeName IN ('FMLA'));

        --PAYCODES
        IF OBJECT_ID('tempdb..#paycodes') IS NOT NULL 
        DROP TABLE #paycodes;

        SELECT DISTINCT
            pcr.EmployeeNumber
            , 0 AS SegmentID
            , CAST(pcr.ApplyDate AS DATE) ApplyDate
            , pcr.StartDateTime
            , pcr.EndDateTime
            , pc.PayCodeKey AS PayCodeID
            , pcr.WorkHours
            , pcr.Wage
            , 0 AS SegmentPaycodeIndex
            , CAST(0 AS BIT) AS doesMatchFully
            , CAST(0 AS BIT) AS doesMatchPartially
            , pcr.DataSource AS DataSource
        INTO #paycodes
        FROM #paycodes_raw pcr
        INNER JOIN [MasterData_HR_UKG_Enh].[PayCodes] pc 
        ON pc.PayCodeName = pcr.PayCodeName;
		
		/*
        IF OBJECT_ID('tempdb..#payperiod') IS NOT NULL 
        DROP TABLE #payperiod;
        SELECT
            EmployeeNumber
            , SegmentID
            , ApplyDate
            , StartDateTime
            , EndDateTime
            , PayCodeID
            , WorkHours
            , Wage
            , DataSource
        INTO #payperiod
        FROM 
        (
            SELECT 
                EmployeeNumber
                , SegmentID
                , ApplyDate
                , StartDateTime
                , EndDateTime
                , PayCodeID
                , WorkHours
                , Wage
                , DataSource
                , ROW_NUMBER() OVER (PARTITION BY EmployeeNumber, ApplyDate, PayCodeID, StartDateTime ORDER BY EndDateTime DESC) AS rn
                , LAG(EndDateTime) OVER (PARTITION BY EmployeeNumber, ApplyDate, PayCodeID ORDER BY StartDateTime) AS PrevEndTime
            FROM #dedup_paycodes
        ) s
        WHERE rn = 1
        AND (PrevEndTime IS NULL OR EndDateTime > PrevEndTime);

        IF OBJECT_ID('tempdb..#paycodes') IS NOT NULL 
        DROP TABLE #paycodes;

        SELECT
            EmployeeNumber
            , SegmentID
            , ApplyDate
            , StartDateTime
            , CASE WHEN NextPayCodeID <> PayCodeID AND NextStartDateTime < EndDateTime THEN NextStartDateTime
            ELSE EndDateTime END AS EndDateTime
            , PayCodeID
            , WorkHours
            , Wage
            , 0 AS SegmentPaycodeIndex
            , 0 AS doesMatchFully
            , 0 AS doesMatchPartially
            , DataSource
        INTO #paycodes
        FROM
        (
            SELECT *
                , LEAD(PayCodeID) OVER (PARTITION BY EmployeeNumber, ApplyDate ORDER BY StartDateTime) AS NextPayCodeID
                , LEAD(StartDateTime) OVER (PARTITION BY EmployeeNumber, ApplyDate ORDER BY StartDateTime) AS NextStartDateTime
            FROM #payperiod
        ) s;
		*/

        --SEGMENTS & PAYCODES - data manipulations
        --Delete other SEGMENTs and PAYCODEs that cancelling each other
        DELETE pc
        FROM #paycodes pc
        INNER JOIN 
        (
            SELECT 
                EmployeeNumber
                , StartDateTime
                , EndDateTime
                , PayCodeID
            FROM #paycodes
            WHERE WorkHours <> 0
            GROUP BY EmployeeNumber
                    , StartDateTime
                    , EndDateTime
                    , PayCodeID
            HAVING SUM(WorkHours) = 0
        ) c 
        ON c.EmployeeNumber = pc.EmployeeNumber 
        AND c.StartDateTime = pc.StartDateTime 
        AND c.EndDateTime = pc.EndDateTime 
        AND c.PayCodeID = pc.PayCodeID;
        
        UPDATE #segments
        SET ApplyDate = CAST(StartDateTime AS DATE)
        WHERE ApplyDate <> CAST(StartDateTime AS DATE);

        UPDATE #paycodes
        SET ApplyDate = CAST(StartDateTime AS DATE)
        WHERE ApplyDate <> CAST(StartDateTime AS DATE);

        DELETE FROM #segments
        WHERE ApplyDate > @MaxDate;

        DELETE FROM #paycodes 
        WHERE ApplyDate > @MaxDate;

        --Delete duplicated SEGMENTs with the same time
        IF OBJECT_ID('tempdb..#duplicated_segments') IS NOT NULL 
        DROP TABLE #duplicated_segments;

        SELECT 
            SegmentID
            , ROW_NUMBER() OVER(PARTITION BY s.EmployeeNumber, s.StartDateTime, s.EndDateTime, s.DurationInSeconds ORDER BY s.SegmentTypeID, s.SegmentID) AS ix
            , DataSource
        INTO #duplicated_segments
        FROM #segments s
        INNER JOIN 
        (
            SELECT 
                EmployeeNumber
                , StartDateTime
                , EndDateTime
                , DurationInSeconds
            FROM #segments
            GROUP BY EmployeeNumber
                    , StartDateTime
                    , EndDateTime
                    , DurationInSeconds
            HAVING COUNT(DISTINCT SegmentID) > 1
        ) dup 
        ON dup.EmployeeNumber = s.EmployeeNumber
        AND dup.StartDateTime = s.StartDateTime 
        AND dup.EndDateTime = s.EndDateTime;

        DELETE s
        FROM #segments s
        INNER JOIN #duplicated_segments ds 
        ON ds.SegmentID = s.SegmentID
        WHERE ix > 1;

        --GET Project ID
        UPDATE #segments 
        SET ProjectID = -1 
        WHERE ProjectID BETWEEN 0 AND 400;

        --GET Location ID
        UPDATE s
        SET s.LocationID = e.LocationID
        FROM #segments s
        INNER JOIN [MasterData_HR_UKG_Enh].[Employees] e 
        ON e.EmployeeNumber = s.EmployeeNumber;

        --APPROVALS
        IF OBJECT_ID('tempdb..#approvals') IS NOT NULL
        DROP TABLE #approvals;

        ;WITH apps AS 
        (
            SELECT DISTINCT
                peoplePersonNumberValue as EmployeeNumber
                , CAST(tkApprovalDateRawValue AS DATE) as ApplyDate
                , CASE WHEN tkIsMgrApprovedValue = 'True' THEN 1
                     WHEN tkIsMgrApprovedValue = 'False' THEN 0
                     ELSE -1 END as ApprovedByManager
                , ROW_NUMBER() OVER(PARTITION BY peoplePersonNumberValue, CAST(tkApprovalDateRawValue AS DATE) 
                ORDER BY CASE WHEN tkIsMgrApprovedValue = 'True' THEN 1 WHEN tkIsMgrApprovedValue = 'False' THEN 0 ELSE -1 END DESC) AS ixAPP
                , dataSource AS DataSource
                FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[CommonDataApprovals]
                WHERE tkApprovalDateRawValue IS NOT NULL AND tkIsMgrApprovedValue IS NOT NULL
        )
        
        SELECT 
            EmployeeNumber
            , ApplyDate
            , ApprovedByManager
            , DataSource
        INTO #approvals
        FROM apps
        WHERE ixAPP = 1;

        --MATCH SEGMENTS to PAYCODES
        --first PTO segments

        UPDATE pc
        SET SegmentID = s.SegmentID
            , doesMatchFully = 1
        FROM #segments s
        INNER JOIN #paycodes pc 
        ON pc.EmployeeNumber = s.EmployeeNumber
        AND pc.ApplyDate = s.ApplyDate
        AND pc.StartDateTime = s.StartDateTime
        AND pc.EndDateTime = s.EndDateTime
        INNER JOIN #Paycodes_PTOs pto
        ON pto.PayCodeID = pc.PayCodeID
        WHERE SegmentTypeID = 6;

        UPDATE pc
        SET SegmentID = s.SegmentID
            , doesMatchPartially = 1
        FROM #segments s
        INNER JOIN #paycodes pc 
        ON pc.EmployeeNumber = s.EmployeeNumber
        AND pc.ApplyDate = s.ApplyDate
        AND pc.StartDateTime >= s.StartDateTime
        AND pc.EndDateTime <= s.EndDateTime
        INNER JOIN #Paycodes_PTOs pto 
        ON pto.PayCodeID = pc.PayCodeID
        WHERE SegmentTypeID = 6
        AND pc.SegmentID = 0;

        UPDATE pc
        SET SegmentID = s.SegmentID
            , doesMatchFully = 1
        FROM #segments s
        INNER JOIN #paycodes pc 
        ON pc.EmployeeNumber = s.EmployeeNumber
        AND pc.ApplyDate = s.ApplyDate
        AND pc.StartDateTime = s.StartDateTime
        AND pc.EndDateTime = s.EndDateTime
        WHERE pc.SegmentID = 0;

        UPDATE pc
        SET SegmentID = s.SegmentID
            , doesMatchPartially = 1
        FROM #segments s
        INNER JOIN #paycodes pc
        ON pc.EmployeeNumber = s.EmployeeNumber
        AND pc.ApplyDate = s.ApplyDate
        AND pc.StartDateTime >= s.StartDateTime
        AND pc.EndDateTime <= s.EndDateTime
        WHERE pc.SegmentID = 0;

        --delete cancelled records
        DELETE pc
        FROM #paycodes pc
        INNER JOIN #segments s 
        ON s.SegmentID = pc.SegmentID
        WHERE s.SegmentTypeID IN (24,17);

        DELETE FROM #segments 
        WHERE SegmentTypeID IN (24,17);

        --SET SegmentPaycodeIndex for multiple same paycodes in the one segment
        UPDATE pc
        SET SegmentPaycodeIndex = ix
        FROM #paycodes pc
        INNER JOIN 
        (
            SELECT
                SegmentID
                , PayCodeID
                , StartDateTime
                , ROW_NUMBER() OVER (PARTITION BY SegmentID, PayCodeID ORDER BY StartDateTime) ix
            FROM #paycodes
            WHERE doesMatchPartially = 1
        ) ipc
        ON ipc.SegmentID = pc.SegmentID
        AND ipc.PayCodeID = pc.PayCodeID 
        AND ipc.StartDateTime = pc.StartDateTime;

        --VALIDATE for unmatched segments
        --orphan segments
        IF EXISTS
        (
            SELECT s.* 
            FROM #segments s 
            LEFT JOIN #paycodes pc 
            ON pc.SegmentID = s.SegmentID
            WHERE pc.SegmentID IS NULL 
            AND s.DurationInSeconds > 0 
        )

        BEGIN

            --remove/ignore completely any orphan segment (usually it's being fixed later)
            DELETE FROM [MasterData_HR_UKG_Enh].[ProcessedSegmentErrors] 
            WHERE ReportDate = @Today;
            
            INSERT INTO [MasterData_HR_UKG_Enh].[ProcessedSegmentErrors]
            SELECT
                @Today ReportDate
                , s.*
            FROM #segments s
            LEFT JOIN #paycodes pc
            ON pc.SegmentID = s.SegmentID
            WHERE pc.SegmentID IS NULL
            AND s.DurationInSeconds > 0;
                    
            DELETE s
            FROM #segments s
            INNER JOIN [MasterData_HR_UKG_Enh].[ProcessedSegmentErrors] e 
            ON e.EmployeeNumber = s.EmployeeNumber 
            AND e.ApplyDate = s.ApplyDate 
            AND e.StartDateTime = s.StartDateTime 
            AND e.SegmentTypeID = s.SegmentTypeID
            WHERE e.ReportDate = @Today;

        END

        --orphan paycodes
        IF EXISTS 
        (
            SELECT 1 FROM #paycodes p 
            WHERE SegmentID = 0
        )

        BEGIN

            -- remove/ignore completely the paycodes without same employee+date segments (usually it's being fixed later)
            DELETE FROM [MasterData_HR_UKG_Enh].[ProcessedPaycodesErrors] 
            WHERE ReportDate = @Today;

            INSERT INTO [MasterData_HR_UKG_Enh].[ProcessedPaycodesErrors]
            SELECT 
                @Today AS ReportDate
                , pc.*
            FROM #paycodes pc
            LEFT JOIN #segments s 
            ON s.EmployeeNumber = pc.EmployeeNumber 
            AND s.ApplyDate = pc.ApplyDate
            WHERE s.SegmentID IS NULL OR pc.SegmentID = 0;

            DELETE pc
            FROM #paycodes pc
            INNER JOIN [MasterData_HR_UKG_Enh].[ProcessedPaycodesErrors] e 
            ON e.EmployeeNumber = pc.EmployeeNumber 
			AND e.ApplyDate = pc.ApplyDate
            WHERE e.ReportDate = @Today;
        
            --if there's still a problem - RAISE ERROR
            IF EXISTS 
            (
                SELECT * 
                FROM #paycodes 
                WHERE SegmentID = 0
            )
            
            DELETE FROM #paycodes 
            WHERE SegmentID = 0;

        END

        DELETE FROM [MasterData_HR_UKG_Enh].[WFMTimesheet]
        WHERE ApplyDate BETWEEN @MinDate AND @MaxDate;
        
		INSERT INTO [MasterData_HR_UKG_Enh].[WFMTimesheet]
		(
			SegmentID
			, WorkShiftID
			, EmployeeNumber
			, ApplyDate
			, StartDateTime
			, EndDateTime
			, PayCodeID
			, WorkHours
			, Wage
			, LocationID
			, ProjectID
			, ApprovedByManager
			, SegmentPaycodeIndex
			, DataSource
		)

        SELECT  
            s.SegmentID
            , s.WorkShiftID
            , pc.EmployeeNumber
            , pc.ApplyDate
            , pc.StartDateTime
            , pc.EndDateTime
            , pc.PayCodeID
            , pc.WorkHours
            , pc.Wage
            , s.LocationID
            , s.ProjectID
            , CASE WHEN w.INVPC = 'S' THEN 1 ELSE ISNULL(app.ApprovedByManager, 0) END AS ApprovedByManager -- in-store timesheet entries are being approved automatically
            , pc.SegmentPaycodeIndex
            , pc.DataSource  
        FROM #paycodes pc
        INNER JOIN #segments s 
        ON s.SegmentID = pc.SegmentID
        LEFT JOIN #approvals app 
        ON app.EmployeeNumber = pc.EmployeeNumber 
        AND app.ApplyDate = pc.ApplyDate
        LEFT JOIN 
        (
            SELECT
                LTRIM(ID, '0') AS ID
                , INVPC
            FROM [$(Source_Data)].[Retail_Miniapps].[WarehouseLocation]
            WHERE ISNUMERIC(ID) = 1
        ) w 
        ON w.ID = s.LocationID
        GROUP BY s.SegmentID
                 , s.WorkShiftID
                 , pc.EmployeeNumber
                 , pc.ApplyDate
                 , pc.StartDateTime
                 , pc.EndDateTime
                 , pc.PayCodeID
                 , pc.WorkHours
                 , pc.Wage
                 , s.LocationID
                 , s.ProjectID
                 , CASE WHEN w.INVPC = 'S' THEN 1 ELSE ISNULL(app.ApprovedByManager, 0) END
                 , pc.SegmentPaycodeIndex
                 , pc.DataSource;

        EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'MasterData_HR_UKG_Enh', 'Timesheet';

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