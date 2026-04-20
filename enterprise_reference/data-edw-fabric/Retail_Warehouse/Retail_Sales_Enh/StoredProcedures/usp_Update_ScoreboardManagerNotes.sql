CREATE PROCEDURE [Retail_Sales_Enh].[usp_Update_ScoreboardManagerNotes]
AS

BEGIN
	
	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_Sales_Enh.usp_Update_ScoreboardManagerNotes' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_Sales_Enh'
	SET @DestinationTable = 'ScoreboardManagerNotes';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

	BEGIN TRY

		--TRUNCATE TABLE [Retail_Sales_Enh].[ScoreboardManagerNotes];

		DECLARE @StartDate DATE = GETDATE()-1
				, @EndDate DATE = GETDATE();

		DELETE FROM [Retail_Sales_Enh].[ScoreboardManagerNotes]
		WHERE StatusStartDate BETWEEN @StartDate AND @EndDate;

		INSERT INTO [Retail_Sales_Enh].[ScoreboardManagerNotes]
		(
			Source
			, IsUP
			, StatusName
			, SalesPersonID
			, SalesPersonName
			, StoreID
			, ScoreboardStoreID
			, StatusStartDate
			, StartTime
			, EndTime
			, ManagerNotes
			, IsClosed
			, StrikeCount
			, IsStrike
			, IsStrikeOut
			, ConsecutiveStrikes
			, ConsecutiveStrikeOuts
			, Shot
			, FinApp
		)

		SELECT
			a.Source
			, CASE a.isCountedAsUP WHEN 1 THEN 'Y' ELSE 'N' END AS isUP
			, s.StatusName
			, a.SalesPersonID AS SalespersonID
			, UPPER(a.SalesPersonName) AS SalesPersonName
			, a.StoreID
			, a.ScoreboardStoreID
			, a.StatusStartDate
			, CONVERT(VARCHAR(8), a.StatusStartTime, 114) AS StartTime
			, CONVERT(VARCHAR(8), a.StatusEndTime, 114) AS EndTime
			, CASE WHEN a.ReasonManagerAddWith IS NOT NULL THEN '<b>* Move ST to With:</b> ' + a.ReasonManagerAddWith
			  WHEN a.ReasonManagerAddSP IS NOT NULL THEN '<b>* Additional RU:</b> ' + ReasonManagerAddSP
			  WHEN a.ReasonManagerRemoveSP IS NOT NULL THEN '<b>* Remove Additional RU:</b> ' + a.ReasonManagerRemoveSP
			  ELSE NULL END AS ManagerNotes
			, CASE a.SPUBStatusID WHEN 98 THEN 'N/A' 
			  ELSE CASE a.isSale WHEN 1 THEN 'Y' ELSE 'N' END 
			  END AS isClosed
			, a.StrikeCount
			, CASE a.IsStrike WHEN 1 THEN 1 ELSE 0 END IsStrike
			, CASE a.IsStrikeOut WHEN 1 THEN 1 ELSE 0 END IsStrikeOut
			, a.ConsecutiveStrikes
			, a.ConsecutiveStrikeOuts
			, CASE a.Shot WHEN 0 THEN NULL ELSE a.Shot END Shot
			, CASE a.FinApp WHEN 0 THEN NULL ELSE a.FinApp END FinApp
		FROM [Retail_Sales_Enh].[SalesPersonUPBoardHistory] a
		INNER JOIN [Retail_Sales].[ScoreboardUpBoardStatuses] s 
		ON s.StatusID = a.SPUBStatusID
		WHERE a.SPUBStatusID <> 11
		AND a.RecordedUpDate BETWEEN @StartDate AND @EndDate
		ORDER BY 
			SalesPersonName
			, StatusEndTime;

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
		Exec [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase,@DestinationSchema,@DestinationTable
		
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