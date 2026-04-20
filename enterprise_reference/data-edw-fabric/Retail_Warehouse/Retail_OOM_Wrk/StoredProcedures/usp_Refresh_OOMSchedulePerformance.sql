CREATE PROCEDURE [Retail_OOM_Wrk].[usp_Refresh_OOMSchedulePerformance]
AS 
BEGIN

	--DECLARE
	--		@String VARCHAR(5000),
	--		@DateValue DATETIME,
	--		@User VARCHAR(500),
	--		@DestinationDatabase VARCHAR(150),
	--		@DestinationSchema VARCHAR(150),
	--		@DestinationTable VARCHAR(150);
			      
	--SET @String = 'Retail_OOM_Enh.usp_Update_OOMSchedulePerformance';
	--SET @User = SYSTEM_USER;
	--SET @DateValue = GETDATE();
	--SET @DestinationDatabase = 'Retail_Warehouse';
	--SET @DestinationSchema = 'Retail_OOM_Enh';
	--SET @DestinationTable = 'OOMSchedulePerformance';

	--SELECT
	--	@DateValue = CSTDateValue
	--FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	--INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	--VALUES
	--(
	--	@String, @DateValue, @User, 'Process Start'
	--);

	--BEGIN TRY

		DECLARE @Today DATE = GETDATE();

		DECLARE @FromDate DATE = DATEADD(dd, -31, @Today)
				, @ToDate DATE = DATEADD(dd, -1, @Today)

		TRUNCATE TABLE [Retail_OOM_Wrk].[OOMSchedulePerformance];

		INSERT INTO [Retail_OOM_Wrk].[OOMSchedulePerformance]
		(
			TransDate
			, WrittenSales
			, TotalScheduleStore
			, TotalScheduleStoreOrderCount
			, TotalScheduleGRT
			, TotalScheduleGRTOrderCount
			, TotalScheduleDTR
			, TotalScheduleDTROrderCount
			, TotalScheduleAudit
			, TotalScheduleAuditOrderCount
			, TotalScheduleUnassigned
			, TotalScheduleUnassignedOrderCount
			, TotalScheduleIVR
			, TotalScheduleIVROrderCount
			, TotalScheduleSMS
			, TotalScheduleSMSOrderCount
			, TotalScheduleChatBot
			, TotalScheduleChatBotOrderCount
			, AttackTarget
			, FilledCleanDelivery
			, ScheduleAtPOS
			, ScheduleAtPOSOrderCount
			, DaysToSchedule
			, SMSMessagesSentCount
			, AutoScheduleOrderCount
		)

		SELECT 
			src.TransDate
			, src.WrittenSales
			, src.TotalScheduleStore
			, src.TotalScheduleStoreOrderCount
			, src.TotalScheduleGRT
			, src.TotalScheduleGRTOrderCount
			, src.TotalScheduleDTR
			, src.TotalScheduleDTROrderCount
			, src.TotalScheduleAudit
			, src.TotalScheduleAuditOrderCount
			, src.TotalScheduleUnassigned
			, src.TotalScheduleUnassignedOrderCount
			, src.TotalScheduleIVR
			, src.TotalScheduleIVROrderCount
			, src.TotalScheduleSMS
			, src.TotalScheduleSMSOrderCount
			, src.TotalScheduleChatBot
			, src.TotalScheduleChatBotOrderCount
			, src.AttackTarget
			, src.FilledCleanDelivery
			, src.ScheduleAtPOS
			, src.ScheduleAtPOSOrderCount
			, src.DaysToSchedule
			, src.SMSMessagesSentCount
			, src.AutoScheduleOrderCount
		FROM [Retail_OOM_Enh].[OOMSchedulePerformance] src
		WHERE src.TransDate BETWEEN @FromDate AND @ToDate;

	--	SET @DateValue = GETDATE();

	--	SELECT
	--		@DateValue = CSTDateValue
	--	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	--	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	--	VALUES
	--	(
	--		@String, @DateValue, @User, 'Process Complete'
	--	);

	--	--- Update last modified in Table Dictionary 
	--	EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable
	
	--END TRY

	--BEGIN CATCH
        
	--	DECLARE
	--		@ErrorMessage  VARCHAR(4000),
	--		@ErrorSeverity INT,
	--		@ErrorState    INT;

	--	SET @ErrorMessage = ERROR_MESSAGE();
	--	SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
	--	SET @ErrorState = ISNULL(ERROR_STATE(), 0);
	--	SET @DateValue = GETDATE();

	--	SELECT
	--		@DateValue = CSTDateValue
	--	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	--	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	--	VALUES
	--	(
	--		@String, @DateValue, @User, @ErrorMessage
	--	);

	--	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	--END CATCH

END