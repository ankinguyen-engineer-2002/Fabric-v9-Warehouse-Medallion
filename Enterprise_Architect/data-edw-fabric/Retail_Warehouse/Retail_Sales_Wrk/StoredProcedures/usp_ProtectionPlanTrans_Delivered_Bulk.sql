CREATE PROCEDURE [Retail_Sales_Wrk].[usp_ProtectionPlanTrans_Delivered_Bulk]
AS
BEGIN

	/*
	INSERT INTO dbo.ErrorLog (PageId, MethodName, ErrorDetails)
	VALUES (0,'proc_ProtectionPlanSalesTrans_Delivered','-')
	*/

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Wrk.usp_ProtectionPlanTrans_Delivered_Bulk';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(PPSalesKey), 0) FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans]);

		WITH CTE_TransCode AS 
		(
			SELECT 
				Description
				, TransCodeID
				, CASE WHEN TransCodeID <= 20 then 1 ELSE -1 END AS CodeMultiplier
				, CASE WHEN TransCodeID IN (0, 1, 2, 7, 30, 31, 37, 20, 50) THEN 1 Else 0 END as TransCodeInvoiceFlag
			FROM [$(Source_Data)].[Retail_Corporate].[TransCode]
		)

		INSERT INTO [Retail_Sales_Enh].[ProtectionPlanSalesTrans]
		(	
			PPSalesKey
			, SalesDataTypeKey
			, ProtectionPlanID
			, OrderID
			, ItemID
			, BaseOrderID
			, LocationID
			, SalesPersonID
			, TransDate
			, TransCodeID
			, Sales
			, Cost
			, Units
			, Source
			, CurrentRec
			, DateCreated
			, CustomerID
		)

		SELECT @MaxID + ROW_NUMBER() OVER (ORDER BY OrderID, ItemID, ProtectionPlanID) AS PPSalesKey, * 
		FROM 
		(
			SELECT	
				11 AS SalesDataTypeKey
				, oi.ProtectionPlanID
				, o.OrderID
				, oi.ItemID
				, o.Base_OrderID
				, LTRIM(o.OrderBookedStoreID, '0') AS LocationID
				, oici.SalesPersonID
				, o.InvoiceDate AS TransDate
				, oi.TransCodeID
				, ISNULL(oi.ProtectionPlanPrice * oici.SplitPct / 100 * tc.CodeMultiplier,0) AS Sales
				, ISNULL(oi.ProtectionPlanCost * oici.SplitPct / 100 * tc.CodeMultiplier,0) AS Cost
				, ISNULL(oi.QtyCommitted * oici.SplitPct / 100 * tc.CodeMultiplier,0) AS Units
				, 'D' AS Source
				, 1 AS CurrentRec
				, GETDATE() AS DateCreated
				, o.CustomerID
				FROM [$(Source_Data)].[Retail_Corporate].[Invoice] AS o
				INNER JOIN [$(Source_Data)].[Retail_Corporate].[InvoiceItem] AS oi 
				ON oi.OrderID = o.OrderID
				INNER JOIN [$(Source_Data)].[Retail_Corporate].[InvoiceItem_CommissionInfo] AS oici
				ON oici.OrderID = oi.OrderID
				AND oici.ItemID = oi.ItemID
				INNER JOIN CTE_TransCode AS tc 
				ON tc.TransCodeID = oi.TransCodeID
				WHERE oi.ProtectionPlanID IS NOT NULL
				AND NOT EXISTS 
				(
					SELECT
						OrderID
					FROM [Retail_Sales_Enh].[ProtectionPlanSalesTrans] pst
					WHERE pst.OrderID = o.OrderID
					AND pst.ItemID = oi.ItemID
					AND pst.Source = 'D'
				)
				AND oi.ProtectionPlanCost IS NOT NULL
			) AS a;

		SET @DateValue = GETDATE();

		SELECT
			@DateValue = CSTDateValue
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, 'Process Complete'
		);
	
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