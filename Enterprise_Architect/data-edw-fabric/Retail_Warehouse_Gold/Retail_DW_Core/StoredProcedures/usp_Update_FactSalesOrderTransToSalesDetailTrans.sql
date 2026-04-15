CREATE PROCEDURE [Retail_DW_Core].[usp_Update_FactSalesOrderTransToSalesDetailTrans]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Update_FactSalesOrderTransToSalesDetailTrans';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactSales';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @TransDateKey AS INT = CONVERT(VARCHAR(8), DATEADD(DAY, -1, GETDATE()), 112);

		DELETE [Retail_DW_Core].[FactSales]
		WHERE SalesDataTypeKey = 2
		AND TransDateKey >= @TransDateKey;

		INSERT INTO [Retail_DW_Core].[FactSales]
		(
			SourceSystem
			, SourceDataID
			, SalesDataTypeKey
			, TransDateKey
			, ProductKey
			, CustomerKey
			, SalesPersonKey
			, LocationKey
			, OrderDateKey
			, SUOrderID
			, BaseOrderID
			, OrderID
			, ItemID
			, TransCodeID
			, TransDateTime
			, UpdateTypeID
			, AsIsReasonCodeID
			, VoidedReasonCodeID
			, Sales
			, Cost
			, Units
			, PPPOpp
			, PPPClose
			, SalesType
			, DateCreated
			, SalesLeadSourceID
		)

		SELECT	
			oh.SourceSystem
			, soh.SalesOrderHistKey AS SourceDataID
			, soh.SalesDataTypeKey
			, soh.TransDateKey
			, pm.ProductKey
			, cm.CustomerKey CustomerKey
			, sp.SalesPersonKey
			, lm.LocationKey
			, CONVERT(VARCHAR(8), oh.OrderDate, 112) AS OrderDateKey
			, CONVERT(VARCHAR(8), oh.OrderDate, 112) + CAST(lm.StoreID AS VARCHAR(20)) + CAST(cm.CustomerID AS VARCHAR(20)) SUOrderID
			, oh.BaseOrderID
			, oh.SourceOrderID
			, 0 AS ItemID
			, oh.TransCodeID TransCodeID
			, soh.DateCreated AS TransDateTime
			, 'O' AS UpdateTypeID
			, NULL AS AsIsReasonCodeID
			, NULL AS VoidedReasonCodeID
			, soh.TransValue AS Sales
			, 0.00 AS Cost
			, 0.00 AS Units
			, 0 AS PPPOpp
			, 0 AS PPPClose
			, 'W' AS SalesType
			, soh.DateCreated AS DateCreated
			, NULL AS SalesLeadSourceID
		FROM [Retail_DW_Core].[FactSalesOrderTrans] soh
		INNER JOIN [Retail_DW_Core].[DimSalesPerson] sp 
		ON sp.SalesPersonID = soh.SalesPersonID
		INNER JOIN [Retail_DW_Core].[FactSalesOrderHeader] oh 
		ON oh.OrderKey = soh.OrderKey
		INNER JOIN [Retail_DW_Core].[DimStoreLocation] lm 
		ON lm.StoreID = oh.StoreID
		INNER JOIN [Retail_DW_Core].[DimCustomerMaster] cm 
		ON cm.CustomerID = oh.CustomerID
		INNER JOIN [Retail_DW_Core].[DimProductMaster] pm 
		ON pm.SKU = 'DLVY'
		INNER JOIN [Retail_DW_Core].[DimGroupMaster] gm 
		ON gm.GroupID = pm.GroupID
		--LEFT OUTER JOIN [$(Source_Data)].[Retail_Corporate].[MarketingCode] AS mc 
		--ON mc.MarketingCodeID = oh.MarketingCodeID
		WHERE soh.SalesDataTypeKey = 2
		AND soh.SalesOrderHistKey NOT IN 
		(
			SELECT SourceDataID
			FROM [Retail_DW_Core].[FactSales] AS tsdt
			WHERE tsdt.SalesDataTypeKey = 2
		);

		/*Update FRLocationID for Deliveries*/
		UPDATE sdt
		SET sdt.ShipLocationID = lm.StoreID,
			sdt.FRLocationID = lm.StoreID
		FROM [Retail_DW_Core].[FactSales] sdt
		INNER JOIN [Retail_DW_Core].[DimStoreLocation] lm 
		ON sdt.LocationKey = lm.LocationKey
		WHERE SalesDataTypeKey = 2
		AND TransDateKey = @TransDateKey
		AND lm.HasTrafficCounter = 1; --NonEcom Stores only

		UPDATE sdt
		SET sdt.ShipLocationID = dta.ShipLocationID
		FROM [Retail_DW_Core].[FactSales] sdt
		INNER JOIN
		(
			SELECT
				sdt.OrderID,
				sdt.ItemID,
				MAX(od.ShipLocationID) ShipLocationID
				FROM [Retail_DW_Core].[FactSales] sdt
				INNER JOIN [Retail_DW_Core].[DimStoreLocation] lm 
				ON sdt.LocationKey = lm.LocationKey
				INNER JOIN [Retail_DW_Core].[FactOrderDetail] od 
				ON sdt.OrderID = od.SourceOrderID
				WHERE sdt.SalesDataTypeKey = 1
				AND sdt.TransDateKey = @TransDateKey
				AND lm.HasTrafficCounter = 0 --EcomStores only
				GROUP BY sdt.OrderID,
						 sdt.ItemID,
						 sdt.LocationKey
		) dta 
		ON sdt.OrderID = dta.OrderID
		AND	sdt.ItemID = dta.ItemID
		WHERE sdt.SalesDataTypeKey = 2
		AND sdt.TransDateKey = @TransDateKey;

		UPDATE sdt
		SET sdt.FRLocationID = fr.FRLocationID
		FROM [Retail_DW_Core].[FactSales] sdt
		INNER JOIN [Retail_DW_Core].[DimStoreLocation] lm 
		ON sdt.LocationKey = lm.LocationKey
		INNER JOIN [Retail_DW_Core].[DimFRLocationMap] fr 
		ON lm.StoreID = fr.StoreID
		AND sdt.ShipLocationID = fr.ShipLocationID
		WHERE sdt.SalesDataTypeKey = 2
		AND sdt.TransDateKey = @TransDateKey;

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