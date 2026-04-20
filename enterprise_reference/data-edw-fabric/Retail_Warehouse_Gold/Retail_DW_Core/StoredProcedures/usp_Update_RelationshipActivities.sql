CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_RelationshipActivities]
AS
BEGIN

	DECLARE
		@String VARCHAR(5000),
		@DateValue DATETIME,
		@User VARCHAR(500),
		@DestinationDatabase VARCHAR(150),
		@DestinationSchema VARCHAR(150),
		@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_RelationshipActivities';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'RelationshipActivities';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		SET NOCOUNT ON;
		
		-- Drop temporary tables if they exist
		DROP TABLE IF EXISTS #RelationshipChangesPotentialNewLeads;
		DROP TABLE IF EXISTS #RelationshipChangesPotentialNewLeadsTemp;
		DROP TABLE IF EXISTS #RelationLastActivityPotentialNewLeads;
		DROP TABLE IF EXISTS #RelationStaff;
		DROP TABLE IF EXISTS #RelationshipActivities_LogUpdated;
		DROP TABLE IF EXISTS #RelationshipActivities_Log;
		DROP TABLE IF EXISTS #RelationshipActivities_LogInsertedNew;

		-- Changes last two days (Potential valid LEADs)
		SELECT  
			r.RelationshipId, 
			r.FullName, 
			r.Email, 
			r.PhoneNumber, 
			r.CartId, 
			r.CustomerId,
			r.LastActivity, 
			CAST(r.LastActivity AS DATE) AS LeadLastActivity, 
			CAST(GETDATE() AS DATETIME2(6)) AS DateCreated, 
			CAST(GETDATE() AS DATETIME2(6)) AS DateModified,
			(SELECT MAX(u.UpdatedAt) 
			 FROM [Retail_DW_Core].[StorisAppUser] u 
			 INNER JOIN [Retail_DW_Core].[Relationship_Assignee] ra 
			   ON ra.StorisAppUserId = u.StorisAppUserId
			 WHERE ra.RelationshipId = r.RelationshipId
			) AS LastSalesPersonDate 
		INTO #RelationshipChangesPotentialNewLeadsTemp
		FROM [Retail_DW_Core].[Relationship] r
		WHERE 1=1
			AND r.CartId IS NOT NULL  -- Has a CartID
			AND (r.Email IS NOT NULL OR r.PhoneNumber IS NOT NULL)  
			AND r.RecStatus <> 'D'  -- Not deleted
			AND r.LastActivity >= DATEADD(DAY, -2, GETDATE());

		-- Create the concatenated StaffIDs using STRING_AGG
		WITH StaffIdsCTE AS (
			SELECT
				r.RelationshipId,
				STRING_AGG(u2.StaffId, ', ') WITHIN GROUP (ORDER BY u2.StaffId) AS StaffIDs
			FROM #RelationshipChangesPotentialNewLeadsTemp r
			INNER JOIN [Retail_DW_Core].[Relationship_Assignee] ra2 
				ON r.RelationshipId = ra2.RelationshipId
			INNER JOIN [Retail_DW_Core].[StorisAppUser] u2 
				ON u2.StorisAppUserId = ra2.StorisAppUserId
			GROUP BY r.RelationshipId
		)
		-- Main query with aggregations
		SELECT  
			r.RelationshipId,
			MAX(u.LocationId) AS LocationId,
			MIN(u.StaffId) AS StaffId,
			s.StaffIDs
		INTO #RelationStaff
		FROM #RelationshipChangesPotentialNewLeadsTemp r
		INNER JOIN [Retail_DW_Core].[Relationship_Assignee] ra 
			ON r.RelationshipId = ra.RelationshipId
		INNER JOIN [Retail_DW_Core].[StorisAppUser] u
			ON u.StorisAppUserId = ra.StorisAppUserId
		INNER JOIN StaffIdsCTE s
			ON s.RelationshipId = r.RelationshipId
		WHERE u.UpdatedAt = r.LastSalesPersonDate
		GROUP BY r.RelationshipId, s.StaffIDs;

		-- Combine relationship data with staff data
		SELECT 
			t.RelationshipId, 
			t.FullName,
			t.Email, 
			t.PhoneNumber, 
			t.CartId, 
			t.CustomerId, 
			t.LastActivity,
			t.LeadLastActivity, 
			t.DateCreated, 
			t.DateModified,
			LEFT(s.StaffId, 20) AS StaffId,
			LEFT(s.StaffIDs, 500) AS StaffIDs,
			s.LocationId
		INTO #RelationshipChangesPotentialNewLeads
		FROM #RelationshipChangesPotentialNewLeadsTemp t
		LEFT JOIN #RelationStaff s ON s.RelationshipId = t.RelationshipId;

		-- Save raw data into the log
		SELECT * 
		INTO #RelationshipActivities_Log 
		FROM #RelationshipChangesPotentialNewLeads;

		-- LastActivity in the current tracking table of Potential Valid Leads
		SELECT 
			RelationshipId, 
			MAX(ra.LastActivity) AS LastActivity 
		INTO #RelationLastActivityPotentialNewLeads
		FROM [Retail_DW_Core].[RelationshipActivities] ra 
		WHERE RelationshipId IN (SELECT RelationshipId FROM #RelationshipChangesPotentialNewLeads)
		GROUP BY RelationshipId;

		-- CASE 1: Update last activity (no new Lead)
		SELECT chgs.* 
		INTO #RelationshipActivities_LogUpdated
		FROM [Retail_DW_Core].[RelationshipActivities] dest
		INNER JOIN #RelationLastActivityPotentialNewLeads la 
		  ON la.RelationshipId = dest.RelationshipId 
		  AND la.LastActivity = dest.LastActivity
		INNER JOIN #RelationshipChangesPotentialNewLeads chgs 
		  ON chgs.RelationshipId = dest.RelationshipId 
		WHERE la.LastActivity > DATEADD(DAY, -30, chgs.LastActivity)
		  AND la.LastActivity < chgs.LastActivity;

		UPDATE dest
		SET dest.LastActivity = chgs.LastActivity,
			dest.[StaffId] = chgs.StaffId,
			dest.[StaffIDs] = chgs.StaffIDs,
			dest.LocationId = chgs.LocationId,
			dest.[DateModified] = GETDATE()
		FROM [Retail_DW_Core].[RelationshipActivities] dest
		INNER JOIN #RelationLastActivityPotentialNewLeads la 
		  ON la.RelationshipId = dest.RelationshipId 
		  AND la.LastActivity = dest.LastActivity
		INNER JOIN #RelationshipChangesPotentialNewLeads chgs 
		  ON chgs.RelationshipId = dest.RelationshipId 
		WHERE la.LastActivity > DATEADD(DAY, -30, chgs.LastActivity)  
		  AND la.LastActivity < chgs.LastActivity;

		-- CASE 2: Insert new Leads (Not recorded before)
		SELECT * 
		INTO #RelationshipActivities_LogInsertedNew
		FROM #RelationshipChangesPotentialNewLeads chgs
		WHERE chgs.RelationshipId NOT IN (
			SELECT existing.RelationshipId 
			FROM #RelationLastActivityPotentialNewLeads existing
		);

		INSERT INTO [Retail_DW_Core].[RelationshipActivities]
		(
			Operation,
			RelationshipId,
			FullName,
			Email,
			PhoneNumber,
			CartId,
			StaffIDs,
			LocationId,
			CustomerId,
			LastActivity,
			LeadLastActivity,
			DateCreated,
			DateModified,
			StaffId
		)
		SELECT 
			'AGR' AS Operation,
			RelationshipId,
			FullName,
			Email,
			PhoneNumber,
			CartId,
			StaffIDs,
			LocationId,
			CustomerId,
			CAST(LastActivity AS DATETIME2(6)) AS LastActivity,
			CAST(LeadLastActivity AS DATETIME2(6)) AS LeadLastActivity,
			CAST(DateCreated AS DATETIME2(6)) AS DateCreated,
			CAST(DateModified AS DATETIME2(6)) AS DateModified,
			StaffId
		FROM #RelationshipChangesPotentialNewLeads chgs
		WHERE chgs.RelationshipId NOT IN (
			SELECT existing.RelationshipId 
			FROM #RelationLastActivityPotentialNewLeads existing
		);

		-- CASE 3: Insert new Leads (recorded before, BUT more than 30 days)
		INSERT INTO [Retail_DW_Core].[RelationshipActivities]
		(
			Operation,
			RelationshipId,
			FullName,
			Email,
			PhoneNumber,
			CartId,
			StaffIDs,
			LocationId,
			CustomerId,
			LastActivity,
			LeadLastActivity,
			DateCreated,
			DateModified,
			StaffId
		)
		SELECT 
			'AGR' AS Operation,
			chgs.RelationshipId,
			FullName,
			Email,
			PhoneNumber,
			CartId,
			StaffIDs,
			LocationId,
			CustomerId,
			CAST(chgs.LastActivity AS DATETIME2(6)) AS LastActivity,
			CAST(LeadLastActivity AS DATETIME2(6)) AS LeadLastActivity,
			CAST(DateCreated AS DATETIME2(6)) AS DateCreated,
			CAST(DateModified AS DATETIME2(6)) AS DateModified,
			StaffId
		FROM #RelationshipChangesPotentialNewLeads chgs
		INNER JOIN #RelationLastActivityPotentialNewLeads la 
		  ON la.RelationshipId = chgs.RelationshipId 
		WHERE la.LastActivity < DATEADD(DAY, -30, chgs.LastActivity);

		-- Clean up temporary tables
		DROP TABLE IF EXISTS #RelationshipChangesPotentialNewLeads;
		DROP TABLE IF EXISTS #RelationshipChangesPotentialNewLeadsTemp;
		DROP TABLE IF EXISTS #RelationLastActivityPotentialNewLeads;
		DROP TABLE IF EXISTS #RelationStaff;
		DROP TABLE IF EXISTS #RelationshipActivities_LogUpdated;
		DROP TABLE IF EXISTS #RelationshipActivities_Log;
		DROP TABLE IF EXISTS #RelationshipActivities_LogInsertedNew;

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
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] 
			@DestinationDatabase, @DestinationSchema, @DestinationTable;
	
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
GO

