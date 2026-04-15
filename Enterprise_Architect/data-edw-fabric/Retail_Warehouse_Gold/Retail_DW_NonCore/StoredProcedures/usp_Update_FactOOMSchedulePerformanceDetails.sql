CREATE PROCEDURE [Retail_DW_NonCore].[usp_Update_FactOOMSchedulePerformanceDetails]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_NonCore.usp_Update_FactOOMSchedulePerformanceDetails';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_NonCore';
	SET @DestinationTable = 'FactOOMSchedulePerformanceDetails';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_DW_NonCore].[FactOOMSchedulePerformanceDetails];

		DECLARE @TransDate DATE = (GETDATE() - 1);

	    DROP TABLE IF EXISTS [Retail_DW_NonCore].[FactOOMSchedulePerformanceDetailsHolding];

		CREATE TABLE [Retail_DW_NonCore].[FactOOMSchedulePerformanceDetailsHolding]
		(
			[BookedStoreID] [varchar](50) NOT NULL,
			[DCStoreID] [varchar](50) NOT NULL,
			[TransDate] [date] NOT NULL,
			[WrittenSales] [decimal](19, 4) NULL,
			[TotalScheduleStore] [decimal](19, 4) NULL,
			[TotalScheduleStoreOrderCount] [int] NULL,
			[TotalScheduleGRT] [decimal](19, 4) NULL,
			[TotalScheduleGRTOrderCount] [int] NULL,
			[TotalScheduleDTR] [decimal](19, 4) NULL,
			[TotalScheduleDTROrderCount] [int] NULL,
			[TotalScheduleAudit] [decimal](19, 4) NULL,
			[TotalScheduleAuditOrderCount] [int] NULL,
			[TotalScheduleUnassigned] [decimal](19, 4) NULL,
			[TotalScheduleUnassignedOrderCount] [int] NULL,
			[TotalScheduleIVR] [decimal](19, 4) NULL,
			[TotalScheduleIVROrderCount] [int] NULL,
			[TotalScheduleSMS] [decimal](19, 4) NULL,
			[TotalScheduleSMSOrderCount] [int] NULL,
			[TotalScheduleChatBot] [decimal](19, 4) NULL,
			[TotalScheduleChatBotOrderCount] [int] NULL,
			[AttackTarget] [decimal](19, 4) NULL,
			[FilledCleanDelivery] [decimal](19, 4) NULL,
			[ScheduleAtPOS] [decimal](19, 4) NULL,
			[ScheduleAtPOSOrderCount] [int] NULL,
			[DaysToSchedule] [decimal](19, 4) NULL,
			[SMSMessagesSentCount] [int] NULL,
			[AutoScheduleOrderCount] [int] NULL
		);

		INSERT INTO [Retail_DW_NonCore].[FactOOMSchedulePerformanceDetailsHolding]
		(	
			TransDate
			, BookedStoreID
			, DCStoreID
			, WrittenSales
			, TotalScheduleStore
			, TotalScheduleGRT
			, TotalScheduleDTR
			, TotalScheduleAudit
			, TotalScheduleUnassigned
			, TotalScheduleIVR
			, TotalScheduleSMS
			, TotalScheduleChatBot
			, AttackTarget
			, FilledCleanDelivery
			, ScheduleAtPOS
			, DaysToSchedule
			, SMSMessagesSentCount
			, AutoScheduleOrderCount
			, TotalScheduleStoreOrderCount 
			, TotalScheduleGRTOrderCount
			, TotalScheduleDTROrderCount
			, TotalScheduleAuditOrderCount
			, TotalScheduleUnassignedOrderCount
			, TotalScheduleIVROrderCount
			, ScheduleAtPOSOrderCount
			, TotalScheduleSMSOrderCount
			, TotalScheduleChatBotOrderCount
		)

		SELECT 
			TransDate
			, BookedStoreID
			, DCStoreID
			, WrittenSales
			, TotalScheduleStore
			, TotalScheduleGRT
			, TotalScheduleDTR
			, TotalScheduleAudit
			, TotalScheduleUnassigned
			, TotalScheduleIVR
			, TotalScheduleSMS
			, TotalScheduleChatBot
			, AttackTarget
			, FilledCleanDelivery
			, ScheduleAtPOS
			, DaysToSchedule
			, SMSMessagesSentCount
			, AutoScheduleOrderCount
			, TotalScheduleStoreOrderCount 
			, TotalScheduleGRTOrderCount
			, TotalScheduleDTROrderCount
			, TotalScheduleAuditOrderCount
			, TotalScheduleUnassignedOrderCount
			, TotalScheduleIVROrderCount
			, ScheduleAtPOSOrderCount
			, TotalScheduleSMSOrderCount
			, TotalScheduleChatBotOrderCount
		FROM [$(Retail_Warehouse)].[Retail_OOM_Enh].[OOMSchedulePerformanceDetails]
		WHERE TransDate = @TransDate;

		DELETE FROM [Retail_DW_NonCore].[FactOOMSchedulePerformanceDetails]
		WHERE TransDate = @TransDate;

		INSERT INTO [Retail_DW_NonCore].[FactOOMSchedulePerformanceDetails]
		(
			TransDate
			, BookedStoreID
			, DCStoreID
			, WrittenSales
			, TotalScheduleStore
			, TotalScheduleGRT
			, TotalScheduleDTR
			, TotalScheduleAudit
			, TotalScheduleUnassigned
			, TotalScheduleIVR
			, TotalScheduleSMS
			, TotalScheduleChatBot
			, AttackTarget
			, FilledCleanDelivery
			, ScheduleAtPOS
			, DaysToSchedule
			, SMSMessagesSentCount
			, AutoScheduleOrderCount
			, TotalScheduleStoreOrderCount 
			, TotalScheduleGRTOrderCount
			, TotalScheduleDTROrderCount
			, TotalScheduleAuditOrderCount
			, TotalScheduleUnassignedOrderCount
			, TotalScheduleIVROrderCount
			, ScheduleAtPOSOrderCount
			, TotalScheduleSMSOrderCount
			, TotalScheduleChatBotOrderCount
		)

		SELECT 
			TransDate
			, BookedStoreID
			, DCStoreID
			, WrittenSales
			, TotalScheduleStore
			, TotalScheduleGRT
			, TotalScheduleDTR
			, TotalScheduleAudit
			, TotalScheduleUnassigned
			, TotalScheduleIVR
			, TotalScheduleSMS
			, TotalScheduleChatBot
			, AttackTarget
			, FilledCleanDelivery
			, ScheduleAtPOS
			, DaysToSchedule
			, SMSMessagesSentCount
			, AutoScheduleOrderCount
			, TotalScheduleStoreOrderCount 
			, TotalScheduleGRTOrderCount
			, TotalScheduleDTROrderCount
			, TotalScheduleAuditOrderCount
			, TotalScheduleUnassignedOrderCount
			, TotalScheduleIVROrderCount
			, ScheduleAtPOSOrderCount
			, TotalScheduleSMSOrderCount
			, TotalScheduleChatBotOrderCount
		FROM [Retail_DW_NonCore].[FactOOMSchedulePerformanceDetailsHolding];

	    DROP TABLE [Retail_DW_NonCore].[FactOOMSchedulePerformanceDetailsHolding];

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
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable
	
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