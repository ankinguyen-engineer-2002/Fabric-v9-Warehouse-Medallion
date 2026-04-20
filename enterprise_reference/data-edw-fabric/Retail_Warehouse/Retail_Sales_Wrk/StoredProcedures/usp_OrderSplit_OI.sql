CREATE PROCEDURE [Retail_Sales_Wrk].[usp_OrderSplit_OI]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_Sales_Wrk.usp_OrderSplit_OI';
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

		DECLARE @DataSetName VARCHAR(50) = 'ORDERS'
				, @DataSetType VARCHAR(5) = 'PROD';

		IF OBJECT_ID('tempdb..#OrderItem') IS NOT NULL 
		DROP TABLE #OrderItem;

		SELECT
			oi.OrderID
			, oi.ItemID
			, oi.QtyOrdered
			, oi.CaseSellingPrice
			, oi.DateCreated
			, oi.DateChanged
			, oi.TransCodeID
			, oi.RecStatus
		INTO #OrderItem
		FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] AS oi
		INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
        ON oi.OrderID = dwi.DataSetKeyValue
		WHERE dwi.DataSetName = @DataSetName
        AND dwi.DataSetType = @DataSetType;

		IF OBJECT_ID('tempdb..#OrderItemCommissionInfo') IS NOT NULL 
		DROP TABLE #OrderItemCommissionInfo;

		SELECT
			oici.OrderID
			, oici.ProductID
			, oici.ItemID
			, oici.ItemCommCategory
			, oici.OrderCommCategory
			, oici.SalesPersonID
			, oici.SplitPct
			, oici.DateChanged
		    , oici.DateCreated
			, oici.RecStatus
			, oici.PosID
			, oici.SourceID	
		INTO #OrderItemCommissionInfo
		FROM [$(Source_Data)].[Retail_Corporate].[OrderItem_CommissionInfo] oici 
		INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
        ON dwi.DataSetKeyValue = oici.OrderID
		WHERE dwi.DataSetName = @DataSetName
		AND dwi.DataSetType = @DataSetType;
		
		IF OBJECT_ID('tempdb..#Invoice') IS NOT NULL 
		DROP TABLE #Invoice;
		
		SELECT
			i.Base_OrderID
			, i.OrderID
			, i.OrderDate
			, i.TransCodeID
			, i.OrderBookedStoreID
			, i.DateChanged
		    , i.DateCreated
			, i.RecStatus
		INTO #Invoice
		FROM [$(Source_Data)].[Retail_Corporate].[Invoice] i
		INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
		ON i.Base_OrderID = dwi.DataSetKeyValue
		WHERE dwi.DataSetName = @DataSetName
		AND dwi.DataSetType = @DataSetType;
		
		IF OBJECT_ID('tempdb..#InvoiceItem') IS NOT NULL 
		DROP TABLE #InvoiceItem;

		SELECT
			i.Base_OrderID
			, ii.OrderID
			, ii.ItemID
			, ii.QtyCommitted
			, ii.CaseSellingPrice
			, ii.DateCreated
			, ii.DateChanged
			, ii.TransCodeID
			, ii.RecStatus
		INTO #InvoiceItem
		FROM [$(Source_Data)].[Retail_Corporate].[InvoiceItem] AS ii
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Invoice] AS i
        ON i.OrderID = ii.OrderID
		INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
        ON i.Base_OrderID = dwi.DataSetKeyValue
		WHERE dwi.DataSetName = @DataSetName
        AND dwi.DataSetType = @DataSetType;

		IF OBJECT_ID('tempdb..#InvoiceItemCommissionInfo') IS NOT NULL 
		DROP TABLE #InvoiceItemCommissionInfo;
		
		SELECT 
			iici.OrderID
			, iici.ProductID
			, iici.ItemID
			, iici.ItemCommCategory
			, iici.OrderCommCategory
			, iici.SalesPersonID
			, iici.SplitPct
			, iici.DateChanged
		    , iici.DateCreated
			, iici.RecStatus
			, iici.PosID
			, iici.SourceID		    
		INTO #InvoiceItemCommissionInfo
		FROM [$(Source_Data)].[Retail_Corporate].[Invoice] i
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[InvoiceItem_CommissionInfo] iici 
		ON iici.OrderID = i.OrderID
		INNER JOIN [MasterData_Retail_Ent].[DataSetKey] dwi
        ON dwi.DataSetKeyValue = i.Base_OrderID
		WHERE dwi.DataSetName = @DataSetName
		AND dwi.DataSetType = @DataSetType;

		IF OBJECT_ID('tempdb..#Split') IS NOT NULL 
		DROP TABLE #Split;

		SELECT 
			splt.OrderID
            , splt.SalesPersonID
            , splt.TransCodeID
            , SUM(NetSales) NetSales
            , SUM(splt.NetUnits) AS NetUnits
		INTO #Split
		FROM
		(
			SELECT 
				oi.OrderID
				, oic.SalesPersonID
				, oi.TransCodeID
				, SUM(oi.QtyOrdered * oi.CaseSellingPrice * oic.SplitPct / 100) AS NetSales
				, SUM(oi.QtyOrdered * oic.SplitPct / 100) AS NetUnits
			FROM #OrderItem AS oi
			INNER JOIN #OrderItemCommissionInfo AS oic
			ON oi.OrderID = oic.OrderID
			AND oi.ItemID = oic.ItemID
			GROUP BY oi.OrderID
					 , oic.SalesPersonID
					 , oi.TransCodeID
			
			UNION ALL
			
			SELECT 
				o.Base_OrderID AS OrderID
				, oic.SalesPersonID
				, oi.TransCodeID
				, SUM(oi.QtyCommitted * oi.CaseSellingPrice * oic.SplitPct / 100) AS NetSales
				, SUM(oi.QtyCommitted * oic.SplitPct / 100) AS NetUnits
			FROM #InvoiceItem AS oi
			INNER JOIN #InvoiceItemCommissionInfo oic
			ON oi.OrderID = oic.OrderID
			AND oi.ItemID = oic.ItemID
			INNER JOIN #Invoice o
			ON o.OrderID = oi.OrderID
			GROUP BY o.Base_OrderID
					 , oic.SalesPersonID
					 , oi.TransCodeID
		) splt
		GROUP BY splt.OrderID
				 , splt.SalesPersonID
				 , splt.TransCodeID;

		DELETE FROM #Split
		WHERE OrderID IN
		(
			SELECT OrderID
			FROM [Retail_Sales_Wrk].[OrderSplit] AS wos
		);

		INSERT INTO [Retail_Sales_Wrk].[OrderSplit]
		(
			OrderID
			, SalesPersonID
			, TransDateKey
			, DataSource
			, TransCodeID
			, SalesType
			, NetSales
			, NetUnits
		)

		SELECT 
			s.OrderID
			, s.SalesPersonID
			, 0 AS TransDateKey
			, 'oi' AS DataSource
			, s.TransCodeID
			, 'W' AS SalesType
			, s.NetSales
			, s.NetUnits
		FROM #Split AS s;

		DROP TABLE #Split;

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