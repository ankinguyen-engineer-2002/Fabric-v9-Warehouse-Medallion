CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_DimHREmployeeHistory]
AS
BEGIN

	DECLARE
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
		@DestinationDatabase VARCHAR(150),
		@DestinationSchema VARCHAR(150),
		@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_DW_Core.usp_Update_DimHREmployeeHistory';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_DW_Core'
	SET @DestinationTable = 'DimHREmployeeHistory';
	
	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @TransDate DATE = DATEADD(DAY, -1, GETDATE());

		DELETE FROM [Retail_DW_Core].[DimHREmployeeHistory]
		WHERE TransDate = @TransDate;

		INSERT INTO [Retail_DW_Core].[DimHREmployeeHistory]
		(
			PeopleID
			, EmployeeID
			, EmployeeNumber
			, SupervisorID
			, EmployeeFirstName
			, EmployeeLastName
			, EmployeeStatus
			, EmployeeEmail
			, EmployeeHourlySalary
			, EmployeeFTPT
			, HireDate
			, Generation
			, LocationID
			, JobID
			, DivisionID
			, DepartmentID
			, RegionID
			, EmployeeTypeID
			, SeparationCode
			, SeparationType
			, SeparationReason
			, SeparationDate
			, TransDate
			, TenureDays
			, TenureMonths
			, ActualSeparationDate
			, WeekEnding
			, ProcessedSeparationWeek
			, ActualSeparationWeek
			, SeparationCount
			, DataSource
		)

		SELECT
			eh1.PeopleID
			, eh1.EmployeeID
			, eh1.EmployeeNumber
			, eh1.SupervisorID
			, eh1.EmployeeFirstName
			, eh1.EmployeeLastName
			, eh1.EmployeeStatus
			, eh1.EmployeeEmail
			, eh1.EmployeeHourlySalary
			, eh1.EmployeeFTPT
			, eh1.HireDate
			, eh1.Generation
			, eh1.LocationID
			, eh1.JobID
			, eh1.DivisionID
			, eh1.DepartmentID
			, eh1.RegionID
			, eh1.EmployeeTypeID
			, eh1.SeparationCode
			, eh1.SeparationType
			, eh1.SeparationReason
			, eh1.SeparationDate
			, eh1.TransDate
			, CASE WHEN eh1.EmployeeStatus = 'T' THEN DATEDIFF(DAY, eh1.HireDate, eh1.SeparationDate) ELSE DATEDIFF(DAY, eh1.HireDate, eh1.TransDate) END AS TenureDays
			, CASE WHEN 
			CASE WHEN eh1.EmployeeStatus = 'T'  THEN DATEDIFF(DAY, eh1.HireDate, eh1.SeparationDate) ELSE DATEDIFF(DAY, HireDate, TransDate) END <= 7 THEN '000-007 Days'
			WHEN CASE WHEN eh1.EmployeeStatus = 'T'  THEN DATEDIFF(DAY, eh1.HireDate, eh1.SeparationDate) ELSE DATEDIFF(DAY, eh1.HireDate, eh1.TransDate) END BETWEEN 8 AND 14 THEN '008-0014 Days'
			WHEN CASE WHEN eh1.EmployeeStatus = 'T'  THEN DATEDIFF(DAY, eh1.HireDate, eh1.SeparationDate) ELSE DATEDIFF(DAY, eh1.HireDate, eh1.TransDate) END BETWEEN 15 AND 21 THEN '014-021 Days'
			WHEN CASE WHEN eh1.EmployeeStatus = 'T'  THEN DATEDIFF(DAY, eh1.HireDate, eh1.SeparationDate) ELSE DATEDIFF(DAY, eh1.HireDate, eh1.TransDate) END BETWEEN 22 AND 28 THEN '022-028 Days'
			WHEN CASE WHEN eh1.EmployeeStatus = 'T'  THEN DATEDIFF(DAY, eh1.HireDate, eh1.SeparationDate) ELSE DATEDIFF(DAY, eh1.HireDate, eh1.TransDate) END BETWEEN 29 AND 90 THEN '029-090 Days'
			WHEN CASE WHEN eh1.EmployeeStatus = 'T'  THEN DATEDIFF(DAY, eh1.HireDate, eh1.SeparationDate) ELSE DATEDIFF(DAY, eh1.HireDate, eh1.TransDate) END BETWEEN 91 AND 180 THEN '091-180 Days'
			WHEN CASE WHEN eh1.EmployeeStatus = 'T'  THEN DATEDIFF(DAY, eh1.HireDate, eh1.SeparationDate) ELSE DATEDIFF(DAY, eh1.HireDate, eh1.TransDate) END BETWEEN 181 AND 365 THEN '181-365 Days'
			ELSE '366+ Days' 
			END AS TenureMonths
			, CASE WHEN MAX(CASE WHEN eh1.EmployeeStatus = 'T' AND eh1.HireDate <= eh1.TransDate THEN eh1.SeparationDate END) OVER (PARTITION BY eh1.EmployeeNumber) >= eh1.HireDate
			THEN MAX(CASE WHEN eh1.EmployeeStatus = 'T' AND eh1.HireDate <= eh1.TransDate THEN eh1.SeparationDate END) OVER (PARTITION BY eh1.EmployeeNumber)
			ELSE NULL 
			END AS ActualSeparationDate
			, DATEADD(DAY, 7 - DATEPART(WEEKDAY, eh1.TransDate), eh1.TransDate) AS WeekEnding
			, DATEADD(DAY, 7, CASE WHEN eh1.EmployeeStatus = 'T' THEN 
			(
				SELECT MAX(DATEADD(DAY, 7 - DATEPART(WEEKDAY, eh2.TransDate), eh2.TransDate)) 
				FROM [$(Retail_Warehouse)].[MasterData_HR_UKG_Enh].[HREmployeeHistory] eh2 
				WHERE eh2.EmployeeNumber = eh1.EmployeeNumber 
				AND eh2.TransDate < eh1.TransDate 
				AND eh2.EmployeeStatus <> 'T'
			) 
			ELSE NULL END) AS ProcessedSeparationWeek
			, CASE WHEN (CASE WHEN MAX(CASE WHEN eh1.EmployeeStatus = 'T' AND eh1.HireDate <= eh1.TransDate THEN eh1.SeparationDate END) OVER (PARTITION BY eh1.EmployeeNumber) >= HireDate
			THEN MAX(CASE WHEN eh1.EmployeeStatus = 'T' AND eh1.HireDate <= eh1.TransDate THEN SeparationDate
			END) OVER (PARTITION BY eh1.EmployeeNumber) ELSE NULL END) IS NULL THEN NULL 
			ELSE DATEADD(DAY, 7 - DATEPART(WEEKDAY, CASE WHEN MAX(CASE WHEN eh1.EmployeeStatus = 'T' AND eh1.HireDate <= eh1.TransDate THEN eh1.SeparationDate END) OVER (PARTITION BY eh1.EmployeeNumber) >= HireDate
			THEN MAX(CASE WHEN eh1.EmployeeStatus = 'T' AND eh1.HireDate <= eh1.TransDate THEN eh1.SeparationDate END) OVER (PARTITION BY eh1.EmployeeNumber) ELSE NULL END), 
			CASE WHEN MAX(CASE WHEN eh1.EmployeeStatus = 'T' AND eh1.HireDate <= eh1.TransDate THEN eh1.SeparationDate END) OVER (PARTITION BY eh1.EmployeeNumber) >= HireDate
			THEN MAX(CASE WHEN eh1.EmployeeStatus = 'T' AND eh1.HireDate <= eh1.TransDate THEN eh1.SeparationDate END) OVER (PARTITION BY eh1.EmployeeNumber) ELSE NULL END) END AS ActualSeparationWeek
			, CASE WHEN (CASE WHEN MAX(CASE WHEN eh1.EmployeeStatus = 'T' AND eh1.HireDate <= eh1.TransDate THEN eh1.SeparationDate END) OVER (PARTITION BY eh1.EmployeeNumber) >= HireDate
			THEN MAX(CASE WHEN eh1.EmployeeStatus = 'T' AND eh1.HireDate <= eh1.TransDate THEN eh1.SeparationDate END) OVER (PARTITION BY eh1.EmployeeNumber) ELSE NULL END) IS NULL THEN 0
			WHEN DATEADD(DAY, 7 - DATEPART(WEEKDAY, CASE WHEN MAX(CASE WHEN EmployeeStatus = 'T' AND HireDate <= TransDate THEN SeparationDate END) OVER (PARTITION BY EmployeeNumber) >= HireDate
			THEN MAX(CASE WHEN eh1.EmployeeStatus = 'T' AND eh1.HireDate <= eh1.TransDate THEN eh1.SeparationDate END) OVER (PARTITION BY eh1.EmployeeNumber) ELSE NULL END), 
			CASE WHEN MAX(CASE WHEN EmployeeStatus = 'T' AND HireDate <= TransDate THEN SeparationDate END) OVER (PARTITION BY EmployeeNumber) >= HireDate 
			THEN MAX(CASE WHEN eh1.EmployeeStatus = 'T' AND eh1.HireDate <= eh1.TransDate THEN eh1.SeparationDate END) OVER (PARTITION BY eh1.EmployeeNumber) ELSE NULL
			END) = DATEADD(DAY, 7 - DATEPART(WEEKDAY, eh1.TransDate), eh1.TransDate) THEN 1  
			ELSE 0 
			END AS SeparationCount
			, eh1.DataSource
		FROM [$(Retail_Warehouse)].[MasterData_HR_UKG_Enh].[HREmployeeHistory] AS eh1
		WHERE eh1.TransDate = @TransDate;

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