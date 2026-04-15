CREATE PROCEDURE [Retail_OOM_Enh].[usp_Update_OrderChangeRegistry]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_OOM_Enh.usp_Update_OrderChangeRegistry';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_OOM_Enh';
	SET @DestinationTable = 'OrderChangeRegistry';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @FromDate DATETIME = NULL,
				@ToDate DATETIME = NULL;

		IF @FromDate IS NULL

		BEGIN

			SELECT @FromDate = MAX(DateCreated)
			FROM [Retail_OOM_Enh].[OrderChangeRegistry];

		END

		SET @ToDate = GETDATE();

		TRUNCATE TABLE [Retail_OOM_Wrk].[OrderComments];

		--TRUNCATE TABLE [Retail_OOM_Enh].[OrderChangeRegistry];

		INSERT INTO [Retail_OOM_Wrk].[OrderComments]
		(
			Comment
			, CommentDate
			, CommentDateTime
			, CommentScope
			, CommentsID
			, CommentSourceID
			, DateChanged
			, DateCreated
			, IsEncrypted
			, LastBatchID
			, ManualEntry
			, RecordID
			, RecStatus
			, Sequence
			, SourceID
			, StaffID
		)

		SELECT	
			Comment
			, CommentDate
			, CommentDateTime
			, CommentScope
			, CommentsID
			, CommentSourceID
			, DateChanged
			, DateCreated
			, IsEncrypted
			, LastBatchID
			, ManualEntry
			, RecordID
			, RecStatus
			, Sequence
			, SourceID
			, StaffID
			--, CAST(NULL AS INT) AS OrderChangeRegistryTypeID
			--, CAST(NULL AS VARCHAR(100)) AS FromValue
			--, CAST(NULL AS VARCHAR(100)) AS ToValue
			--, CAST(NULL AS INT) AS RowType
			--, CAST(NULL AS INT) AS ItemID
			--, CAST(NULL AS BIT) AS IsChangeOrder
		FROM [$(Source_Data)].[Retail_Corporate].[OrderComments]
		WHERE SourceID = '01' 
		AND RecStatus <> 'D'
		AND DateCreated BETWEEN @FromDate AND @ToDate;

		UPDATE	src
		SET src.IsChangeOrder = 1
		FROM [Retail_OOM_Wrk].[OrderComments] src
		LEFT OUTER JOIN [Retail_OOM_Enh].[OrderChangeRegistry] dst 
		ON src.CommentsID = dst.OrderChangeRegistryID
		WHERE dst.OrderChangeRegistryID IS NULL;

		UPDATE	dst
		SET dst.ItemID = SUBSTRING(dst.Comment, 5, CHARINDEX(',', dst.Comment, 5) - 5)
			, dst.OrderChangeRegistryTypeID = 1
			, dst.FromValue = CASE WHEN CHARINDEX('Delivery Dates 1 Was Added As', dst.Comment, 5) > 0 THEN
							  SUBSTRING(dst.Comment, CHARINDEX('Delivery Dates 1 Was Added As', dst.Comment, 5) + LEN('Delivery Dates 1 Was Added As') + 1, 8)
							  WHEN CHARINDEX('Delivery Dates 1 Was', dst.Comment, 5) > 0 THEN
							  SUBSTRING(dst.Comment, CHARINDEX('Delivery Dates 1 Was', dst.Comment, 5) + LEN('Delivery Dates 1 Was') + 1, 9)
							  ELSE NULL END
			, dst.ToValue = CASE WHEN CHARINDEX('Changed To', SUBSTRING(dst.Comment, CHARINDEX('Delivery Dates 1 Was', dst.Comment, 5), LEN(dst.Comment) - CHARINDEX('Delivery Dates 1 Was', dst.Comment, 5))) > 0 
							THEN SUBSTRING(SUBSTRING(dst.Comment, CHARINDEX('Delivery Dates 1 Was', dst.Comment, 5), LEN(dst.Comment) - CHARINDEX('Delivery Dates 1 Was', dst.Comment, 5)),
							CHARINDEX('Changed To', SUBSTRING(dst.Comment, CHARINDEX('Delivery Dates 1 Was', dst.Comment, 5), LEN(dst.Comment) - CHARINDEX('Delivery Dates 1 Was', dst.Comment, 5)), 5) + 
							LEN('Changed To') + 1, 9) END
		FROM [Retail_OOM_Wrk].[OrderComments] dst
		WHERE dst.IsChangeOrder = 1
		AND dst.Comment LIKE '%Delivery Dates%'
		AND LEFT(dst.Comment, 4) = 'Line';

		UPDATE [Retail_OOM_Wrk].[OrderComments]
		SET RowType = 1
		WHERE ItemID IS NOT NULL
		AND IsChangeOrder = 1
		AND OrderChangeRegistryTypeID = 1;

		UPDATE [Retail_OOM_Wrk].[OrderComments]
		SET FromValue = CASE WHEN RIGHT(FromValue, 1) = '.' THEN SUBSTRING(FromValue, 0, LEN(FromValue)) ELSE RTRIM(LTRIM(FromValue)) END
			, ToValue = CASE WHEN RIGHT(ToValue, 1) = '.' THEN SUBSTRING(ToValue, 0, LEN(ToValue)) ELSE RTRIM(LTRIM(ToValue)) END
		WHERE OrderChangeRegistryTypeID = 1
		AND IsChangeOrder = 1;

		UPDATE [Retail_OOM_Wrk].[OrderComments] 
		SET ToValue = NULL 
		WHERE ISDATE(ToValue) = 0 
		AND IsChangeOrder = 1;


		UPDATE [Retail_OOM_Wrk].[OrderComments]
		SET OrderChangeRegistryTypeID = 3 --Fulfillment Status * Changed To SCD with Automation
		WHERE (Comment LIKE '%Scheduled by Twilio IVR%' OR Comment LIKE '%Scheduled by Twilio MsgFlow%')
		AND OrderChangeRegistryTypeID IS NULL;

		UPDATE [Retail_OOM_Wrk].[OrderComments]
		SET OrderChangeRegistryTypeID = 2 --Fulfillment Status * Changed To SCD
		WHERE Comment LIKE '%Changed To SCD%'
		AND OrderChangeRegistryTypeID IS NULL;

		UPDATE [Retail_OOM_Wrk].[OrderComments]
		SET OrderChangeRegistryTypeID = 4 --Fulfillment Status * Changed To SCD
		WHERE Comment LIKE '%Scheduled by OCQAutomation Filled Clean%'
		AND OrderChangeRegistryTypeID IS NULL;

		UPDATE [Retail_OOM_Wrk].[OrderComments]
		SET OrderChangeRegistryTypeID = 5 --Scheduled by ChatBot
		WHERE Comment LIKE '%Customer Scheduled Order through Acquire webchat.%'
		AND OrderChangeRegistryTypeID IS NULL;

		/*Customer Scheduled Order through Acquire webchat.*/

		INSERT INTO [Retail_OOM_Enh].[OrderChangeRegistry]
		(
			OrderChangeRegistryID
			, Comment
			, CommentDate
			, CommentDateTime
			, CommentScope
			, CommentSourceID
			, DateChanged
			, DateCreated
			, IsEncrypted
			, LastBatchID
			, ManualEntry
			, OrderID
			, ItemID
			, Sequence
			, SourceID
			, StaffID
			, OrderChangeRegistryTypeID
			, FromValue
			, ToValue
			, RowType
			, RecStatus
		)
	
		SELECT	
			src.CommentsID
			, src.Comment
			, src.CommentDate
			, src.CommentDateTime
			, src.CommentScope
			, src.CommentSourceID
			, src.DateChanged
			, src.DateCreated
			, src.IsEncrypted
			, src.LastBatchID
			, src.ManualEntry
			, src.RecordID
			, src.ItemID
			, src.Sequence
			, src.SourceID
			, src.StaffID
			, src.OrderChangeRegistryTypeID
			, src.FromValue
			, src.ToValue
			, src.RowType
			, src.RecStatus
		FROM [Retail_OOM_Wrk].[OrderComments] src
		WHERE src.IsChangeOrder = 1;

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