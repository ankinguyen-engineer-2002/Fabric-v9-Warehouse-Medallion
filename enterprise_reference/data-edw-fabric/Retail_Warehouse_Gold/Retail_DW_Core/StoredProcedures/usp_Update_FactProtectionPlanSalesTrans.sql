CREATE PROCEDURE [Retail_DW_Core].[usp_Update_FactProtectionPlanSalesTrans]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactProtectionPlanSalesTrans';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactProtectionPlanSalesTrans';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		--TRUNCATE TABLE [Retail_DW_Core].[FactProtectionPlanSalesTrans];

		DECLARE @TransDate DATE = GETDATE();

		IF OBJECT_ID('tempdb..#ProtectionPlanSales') IS NOT NULL 
		DROP TABLE #ProtectionPlanSales;

		SELECT 
			PPSalesKey
			, SalesDataTypeKey
			, ProtectionPlanID
			, OrderID
			, ItemID
			, BaseOrderID AS BaseOrderID
			, LocationID AS StoreID
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
			, CAST(NULL AS BIGINT) AS LocationKey
			, CAST(NULL AS BIGINT) AS ProductKey
			, CAST(NULL AS BIGINT) AS SalesPersonKey
			, CAST(NULL AS BIGINT) AS CustomerKey
			, CAST(NULL AS VARCHAR(50)) AS SuperOrderID
			, CAST(NULL AS VARCHAR(50)) AS ShipLocationID
			, CAST(NULL AS VARCHAR(50)) AS FRLocationID
			, CAST(NULL AS BIGINT) AS TransDateKey
			, CAST(NULL AS VARCHAR(10)) AS ItemCommCategory
			, CAST(NULL AS BIGINT) AS OrderDateKey
			, CAST(NULL AS INT) AS PPPOpp
			, CAST(NULL AS INT) AS PPPClose
			, CAST(NULL AS VARCHAR(4)) AS UpdateTypeID
			, CAST(NULL AS VARCHAR(50)) AS DeliveryStoreID
			, CAST(NULL AS INT) AS GrossMultiplier
			, CAST(NULL AS INT) AS SalesLeadSourceID
		INTO #ProtectionPlanSales
		FROM [$(Retail_Warehouse)].[Retail_Sales_Enh].[ProtectionPlanSalesTrans]
		WHERE CAST(DateCreated AS DATE) >= @TransDate;

		UPDATE bta
		SET bta.TransDateKey = CONVERT(VARCHAR(8), bta.TransDate, 112)
		FROM #ProtectionPlanSales AS bta;

		UPDATE bta
		SET bta.LocationKey = lm.LocationKey
		FROM #ProtectionPlanSales bta
		INNER JOIN [Retail_DW_Core].[DimStoreLocation] lm
		ON lm.StoreID = bta.StoreID;

		UPDATE bta
		SET bta.SalesPersonKey = sp.SalesPersonKey
		FROM #ProtectionPlanSales bta
		INNER JOIN [Retail_DW_Core].[DimSalesPerson] sp
		ON sp.SalesPersonID = bta.SalesPersonID;

		UPDATE bta
		SET bta.CustomerKey = cm.CustomerKey
		FROM #ProtectionPlanSales bta
		INNER JOIN [Retail_DW_Core].[DimCustomerMaster] cm
		ON cm.CustomerID = bta.CustomerID;

		UPDATE bta
		SET bta.ProductKey = pm.ProductKey
		FROM #ProtectionPlanSales bta
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[ProtectionPlan] AS pp
		ON pp.ProtectionPlanID = bta.ProtectionPlanID
		INNER JOIN [Retail_DW_Core].[DimProductMaster] AS pm
		ON pm.SKU = pp.PlanID
		INNER JOIN [Retail_DW_Core].[DimStoreLocation] AS lm
		ON lm.StoreID = bta.StoreID
		AND lm.StoreBrandID = pm.StoreBrandID;

		UPDATE bta
		SET bta.ProductKey = pm.ProductKey
		FROM #ProtectionPlanSales bta
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[ProtectionPlan] AS pp
		ON pp.ProtectionPlanID = bta.ProtectionPlanID
		INNER JOIN [Retail_DW_Core].[DimProductMaster] AS pm
		ON pm.SKU = pp.PlanID
		WHERE bta.ProductKey IS NULL
		AND pm.IsMaster = 1;

		UPDATE bta
		SET bta.ItemCommCategory = 'EW'
		FROM #ProtectionPlanSales bta;

		UPDATE bd
		SET bd.PPPClose = bd.Units / ABS(bd.Units)
		FROM #ProtectionPlanSales AS bd
		INNER JOIN [Retail_DW_Core].[DimCustomerMaster] AS cm
		ON cm.CustomerKey = bd.CustomerKey
		INNER JOIN [Retail_DW_Core].[DimProductMaster] AS pm
		ON pm.ProductKey = bd.ProductKey
		WHERE bd.Source = 'W'
		AND
		(
			cm.CustomerClass NOT IN ( 'COM', 'NOR' )
			OR cm.CustomerClass IS NULL
		)
		AND bd.TransCodeID <> 7
		AND RIGHT(bd.OrderID, 1) <> 'e'
		--AND pm.PPPGroupID = bd.GroupID
		AND bd.Units <> 0;
		--AND pm.IsMaster = 1;

		UPDATE bta
		SET bta.OrderDateKey = CONVERT(VARCHAR(8), o.OrderDate, 112)
		FROM #ProtectionPlanSales bta
		INNER JOIN [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderHeader] o
		ON o.SourceOrderID = bta.OrderID;

		UPDATE bta
		SET bta.DeliveryStoreID = o.ShipLocationID
		FROM #ProtectionPlanSales bta
		INNER JOIN [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderLine] o
		ON o.SourceOrderID = bta.OrderID
		AND o.LineNumber = bta.ItemID;

		UPDATE bta
		SET bta.SuperOrderID = CAST(bta.OrderDateKey AS VARCHAR(10)) + CAST(bta.StoreID AS VARCHAR(10)) + bta.CustomerID
		FROM #ProtectionPlanSales bta;

		/*
		UPDATE bd
		SET bd.SalesLeadSourceID = mc.SalesLeadSourceID
		FROM [Enterprise_Lakehouse].[Retail_Sales_Enh].[SalesOrderHeader] AS oh
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[MarketingCode] AS mc
		ON mc.MarketingCodeID = oh.MarketingCodeID
		INNER JOIN #ProtectionPlanSales AS bd
		ON bd.BaseOrderID = oh.OrderID;
		*/

		UPDATE bta
		SET bta.FRLocationID = bta.StoreID
		FROM #ProtectionPlanSales bta;

		UPDATE bta
		SET bta.FRLocationID = fr.FRLocationID
		FROM #ProtectionPlanSales bta
		INNER JOIN [Retail_DW_Core].[DimFRLocationMap] fr
		ON fr.StoreID = bta.StoreID
		AND fr.ShipLocationID = bta.DeliveryStoreID;

		UPDATE #ProtectionPlanSales
		SET UpdateTypeID = CASE WHEN OrderDateKey = TransDateKey THEN 'N' ELSE 'U' END;

		WITH tot AS
		(
			SELECT	
				bd.StoreID,
				bd.CustomerID,
				bd.TransDate,
				SUM(bd.Sales) TotSales
				FROM #ProtectionPlanSales AS bd
				WHERE bd.Source = 'W'
				GROUP BY 
					bd.StoreID,
					bd.CustomerID,
					bd.TransDate
		)

		UPDATE b
		SET b.GrossMultiplier = CASE WHEN tot.TotSales >= 0 THEN 1 ELSE 0 END
		FROM #ProtectionPlanSales AS b
		INNER JOIN tot ON tot.CustomerID = b.CustomerID
		AND	tot.TransDate = b.TransDate
		AND	tot.StoreID = b.StoreID
		AND b.Source = 'W';

		DELETE FROM [Retail_DW_Core].[FactProtectionPlanSalesTrans]
		WHERE CAST(DateCreated AS DATE) >= @TransDate;

		INSERT INTO [Retail_DW_Core].[FactProtectionPlanSalesTrans]
		(	
			PPSalesKey
			, SalesDataTypeKey
			, ProtectionPlanID
			, OrderID
			, ItemID
			, BaseOrderID
			, StoreID
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
			, LocationKey
			, ProductKey
			, SalesPersonKey
			, CustomerKey
			, SuperOrderID
			, ShipLocationID
			, FRLocationID
			, TransDateKey
			, ItemCommCategory
			, OrderDateKey
			, PPPOpp
			, PPPClose
			, UpdateTypeID
			, DeliveryStoreID
			, GrossMultiplier
			, SalesLeadSourceID
		)

		SELECT
			PPSalesKey
			, SalesDataTypeKey
			, ProtectionPlanID
			, OrderID
			, ItemID
			, BaseOrderID
			, StoreID
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
			, LocationKey
			, ProductKey
			, SalesPersonKey
			, CustomerKey
			, SuperOrderID
			, ShipLocationID
			, FRLocationID
			, TransDateKey
			, ItemCommCategory
			, OrderDateKey
			, PPPOpp
			, PPPClose
			, UpdateTypeID
			, DeliveryStoreID
			, GrossMultiplier
			, SalesLeadSourceID
		FROM #ProtectionPlanSales;

		DROP TABLE #ProtectionPlanSales;

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