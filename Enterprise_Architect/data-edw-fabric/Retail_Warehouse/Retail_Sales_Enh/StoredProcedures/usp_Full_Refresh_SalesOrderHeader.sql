

CREATE   PROCEDURE [Retail_Sales_Enh].[usp_Full_Refresh_SalesOrderHeader]
AS

BEGIN
	
	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_Sales_Enh.usp_Full_Refresh_SalesOrderHeader' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'Retail_Sales_Enh'
	SET @DestinationTable = 'SalesOrderHeader';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		TRUNCATE TABLE [Retail_Sales_Enh].[SalesOrderHeader];

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(OrderKey),0) FROM [Retail_Sales_Enh].[SalesOrderHeader]);

		--DECLARE @StartDate DATE = GETDATE()-3
		--		, @EndDate DATE = GETDATE();

		UPDATE [Retail_Sales].[SalesOrderHeader]
		SET MerchSubTotal = 0
			, InstallationCharge = 0
			, DeliveryCharge = 0
			, TotalAdditionalTaxAmount = 0
			, TotalStateTaxAmount = 0
			, FinanceAmount = 0
			, TotalInvoiceAmount = 0
			, DeliveryChargeCalculated = 0
		WHERE OrderStatus = 'Written' 
		AND RecStatus = 'D';

		SELECT oh.SourceOrderID
			   , SUM(ofmnt.MerchSubTot) ofMerchSubTotal
			   , SUM(ofmnt.DlvyChrg) AS DeliveryCharge
			   , SUM(ofmnt.InstallationChrg) AS InstallationCharge
			   , MAX(COALESCE(ofmnt.DlvyChrgCalculated, 0)) AS DeliveryChargeCalculated
		INTO #Ofment
		FROM [Retail_Sales].[SalesOrderHeader] oh
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderFulfillment] ofmnt
		ON ofmnt.OrderID = oh.SourceOrderID
		WHERE oh.OrderStatus = 'Written' 
		AND ofmnt.RecStatus <> 'D'
		GROUP BY oh.SourceOrderID;

		UPDATE o
		SET o.MerchSubTotal = ofmnt.ofMerchSubTotal
			, o.DeliveryCharge = ofmnt.DeliveryCharge
			, o.InstallationCharge = ofmnt.InstallationCharge
			, o.DeliveryChargeCalculated = ofmnt.DeliveryChargeCalculated
		FROM [Retail_Sales].[SalesOrderHeader] o
		INNER JOIN #Ofment ofmnt
		ON o.SourceOrderID = ofmnt.SourceOrderID
		WHERE o.OrderStatus = 'Written';

		IF OBJECT_ID('tempdb..#OrderData') IS NOT NULL 
		DROP TABLE #OrderData;

		SELECT 
			od.SourceSystem
			, od.SourceOrderID
			, od.BaseOrderID
			, MAX(od.SourceCustomerID) AS SourceCustomerID
			, MAX(od.CustomerName) AS CustomerName
			, MAX(od.OrderStatus) AS OrderStatus
			, MAX(od.SalesChannel) AS SalesChannel
			, MAX(od.OrderType) AS OrderType
			, MAX(od.CompanyCode) AS CompanyCode
			, MAX(CAST(od.IsOnHold AS INT)) AS IsOnHold
			, COALESCE(SUM(od.MerchSubTotal) * MAX(t.TransCodeMultiplier), 0) AS TotalSales
			, COALESCE(SUM(od.DeliveryCharge + od.InstallationCharge) * MAX(t.TransCodeMultiplier), 0) AS TotalCharges
			, COALESCE(SUM(od.TotalPayment) * MAX(t.TransCodeMultiplier), 0) AS TotalPayment
			, COALESCE(SUM(od.TotalAdditionalTaxAmount) * MAX(t.TransCodeMultiplier), 0) AS TotalAdditionalTaxAmount
			, COALESCE(SUM(od.TotalStateTaxAmount) * MAX(t.TransCodeMultiplier), 0) AS TotalStateTaxAmount
			, COALESCE(SUM(od.TotalAdditionalTaxAmount + od.TotalStateTaxAmount) * MAX(t.TransCodeMultiplier), 0) AS TotalTaxes
			, COALESCE(SUM(od.FinanceAmount) * MAX(t.TransCodeMultiplier), 0) AS FinanceAmount
			, 0 AS BalanceDue
			, MAX(od.PaymentTypeID) AS PaymentTypeID
			, MAX(od.BillToStreetAddress) AS BillToStreetAddress
			, MAX(od.BillToAddressLine2) AS BillToAddressLine2
			, MAX(od.BillToCity) AS BillToCity
			, MAX(od.BilltoStateOrProvinceCode) AS BilltoStateOrProvinceCode
			, MAX(od.BillToZipOrPostalCode) AS BillToZipOrPostalCode
			, MAX(od.BillToCountryCode) AS BillToCountryCode
			, MAX(od.ShipInstruction) AS ShipInstruction
			, MAX(od.OrderContactName) AS OrderContactName
			, MAX(od.OrderContactEmail) AS OrderContactEmail
			, MAX(od.OrderContactPhone) AS OrderContactPhone
			, MAX(od.CSLastContact) AS CSLastContact
			, MAX(od.CSNextContact) AS CSNextContact
			, MAX(od.StoreAccount) AS StoreAccount
			, MAX(od.StoreShipTo) AS StoreShipTo
			, MAX(od.StoreOperationID) AS StoreOperationID
			, MIN(od.StoreID) AS StoreID
			, MAX(lm.StoreBrandID) AS StoreBrandID
			, MAX(od.FulfillerID) AS FulfillerID
			, MAX(CAST(od.CartID AS INT)) AS CartID
			, MAX(CAST(od.IsWrittenOrder AS INT)) AS IsWrittenOrder
			, MIN(od.OrderDate) AS OrderDate
			, MAX(od.VoidedDate) AS VoidedDate
			, 1 * MAX(t.TransCodeMultiplier) AS OrderCount
			, MAX(od.OriginalInvoiceID) AS OriginalInvoiceID
			, MAX(od.MarketingCodeID) AS MarketingCodeID
			, MIN(od.TransCodeID) AS TransCodeID
			, MAX(CAST(od.TransCodeMultiplier AS INT)) AS TransCodeMultiplier
			, MAX(od.RouteCodeID) AS RouteCodeID
			, MAX(od.CreditHoldCodeID) AS CreditHoldCodeID
			, MAX(od.ServiceStaffID) AS ServiceStaffID
			, MAX(od.RequestedDate) AS RequestedDate
			, MAX(od.TransactionSaveTime) AS TransactionSaveTime
			, MAX(od.TransactionStartTime) AS TransactionStartTime
			, MAX(od.PriceExceptionComment) AS PriceExceptionComment
			, COALESCE(SUM(od.InstallationCharge) * MAX(t.TransCodeMultiplier), 0) AS InstallationCharge
			, COALESCE(SUM(od.DeliveryCharge) * MAX(t.TransCodeMultiplier), 0) AS DeliveryCharge
			, SUM(od.DeliveryChargeCalculated) AS DeliveryChargeCalculated
			, CAST(NULL AS VARCHAR(5)) AS DeliveryChargeOverUserID
			, MAX(DeliveryChargeOverride) AS DeliveryChargeOverride
			, MAX(DeliveryChoice) AS DeliveryChoice
			, MAX(DeliveryChargeCompliant) AS DeliveryChargeCompliant
			, CAST(NULL AS DATE) AS DeliveryCapAvailDate
			, CAST(NULL AS DATETIME2(3)) AS OriginalDeliveryDate
			, CAST(NULL AS VARCHAR(50)) AS OriginalDeliveryType
			, CAST(NULL AS VARCHAR(50)) AS SFMCFulfillmentStatus
			, CAST(NULL AS VARCHAR(50)) AS SFMCFulfillmentType
			, CAST(NULL AS DATETIME2(3)) AS SFMCLastFulfillmentDate
			, CAST(NULL AS VARCHAR(50)) AS SFMCPrimaryOrderCategory
			, 0 AS IsFinanced
			, CAST(NULL AS INT) AS OriginalTransCodeID
			, CAST(NULL AS DATETIME2(3)) AS OriginalTransDate
			, CAST(NULL AS VARCHAR(20)) AS SalesPersonID
			, CAST(NULL AS VARCHAR(50)) AS SuperOrderID
			, CAST(NULL AS DATETIME2(3)) AS LastActivityDate
			, CAST(NULL AS DATETIME2(3)) AS DateClosed
			, COALESCE(SUM(od.TotalInvoiceAmount) * MAX(t.TransCodeMultiplier), 0) AS TotalInvoiceAmount
			, od.LastUpdatedUTC
			, od.DateCreated
			, od.RecStatus
		INTO #OrderData
		FROM [Retail_Sales].[SalesOrderHeader] od
		INNER JOIN [$(Source_Data)].[Retail_External].[TransCodeMap] t
		ON CAST(t.TransCodeID AS INT) = od.TransCodeID
		LEFT JOIN [MasterData_Retail_Ent].[StoreLocation] AS lm
		ON lm.StoreID = od.StoreID
		WHERE t.TransCodeGroup = 'ALL'
		GROUP BY od.SourceSystem
				, od.SourceOrderID
				, od.BaseOrderID
				, od.LastUpdatedUTC
				, od.DateCreated
				, od.RecStatus;

		/* Don't reprocessed Completed Orders */
		DELETE FROM od
		FROM [Retail_Sales_Enh].[SalesOrderHeader] AS oh
		INNER JOIN #OrderData AS od
		ON od.SourceOrderID = oh.SourceOrderID
		WHERE oh.SFMCFulfillmentStatus = 'Completed';


        DELETE FROM [Retail_Sales_Enh].[SalesOrderHeader]
        WHERE SourceOrderID IN 
		(
			SELECT SourceOrderID 
			FROM #OrderData
		)

		--DELETE FROM [Retail_Sales_Enh].[SalesOrderHeader]
		--WHERE COALESCE(CAST(LastUpdatedUTC AS DATE), CAST(DateCreated AS DATE)) BETWEEN @StartDate AND @EndDate;

		/*
		UPDATE oh
		SET oh.StoreBrandID = o.StoreBrandID
			, oh.SourceCustomerID = o.SourceCustomerID
			, oh.StoreID = o.StoreID
			, oh.TransCodeID = o.TransCodeID
			, oh.TotalSales = o.TotalInvoiceAmount - o.TotalTaxes - o.TotalCharges
			, oh.TotalCharges = o.TotalCharges
			, oh.TotalTaxes = o.TotalTaxes
			, oh.TotalPayment = o.TotalPayment
			--, oh.BalanceDue = COALESCE((o.TotalSales + o.TotalCharges + o.TotalTaxes), 0) - o.TotalPayment
			, oh.FinanceAmount = o.FinanceAmount
			, oh.OrderDate = o.OrderDate
			, oh.VoidedDate = o.VoidedDate
			, oh.OrderCount = o.OrderCount
			, oh.PaymentTypeID = o.PaymentTypeID
			, oh.RouteCodeID = o.RouteCodeID
			, oh.DeliveryCharge = o.DeliveryCharge
			, oh.InstallationCharge = o.InstallationCharge
			, oh.TotalAdditionalTaxAmount = o.TotalAdditionalTaxAmount
			, oh.TotalStateTaxAmount = o.TotalStateTaxAmount
			, oh.LastUpdatedUTC = o.LastUpdatedUTC
			, oh.RequestedDate = o.RequestedDate
			, oh.ServiceStaffID = o.ServiceStaffID
			, oh.MarketingCodeID = o.MarketingCodeID
			, oh.CreditHoldCodeID = o.CreditHoldCodeID
			, oh.DeliveryChargeCalculated = o.DeliveryChargeCalculated
		FROM [Retail_Sales_Enh].[SalesOrderHeader] oh
		INNER JOIN #OrderData o
		ON o.SourceOrderID = oh.SourceOrderID
		WHERE oh.SourceOrderID IS NOT NULL;*/

		/*Flag Orders that are CustomerServiceOrders for CustomerServiceOrders process*/
		UPDATE o
		SET o.NewEntryFlag = 1
		FROM [Retail_Sales].[SalesOrderHeader] o
		LEFT OUTER JOIN [Retail_Sales_Enh].[SalesOrderHeader] oh
		ON oh.SourceOrderID = o.SourceOrderID
		AND oh.OrderStatus = o.OrderStatus
		WHERE o.OrderStatus IN ('Written', 'Invoiced')
		AND oh.OrderKey IS NULL;

		IF OBJECT_ID('tempdb..#SalesOrderHeaderHolding') IS NOT NULL 
		DROP TABLE #SalesOrderHeaderHolding;

		SELECT 
			o.SourceSystem
			, @MaxID + CAST(ROW_NUMBER() OVER (ORDER BY o.SourceOrderID) AS BIGINT) AS OrderKey
			, o.SourceOrderID
			, o.BaseOrderID
			, o.DateCreated
			, o.LastUpdatedUTC
			, o.SourceCustomerID
			, o.CustomerName
			, o.OrderStatus
			, o.SalesChannel
			, o.OrderType
			, o.CompanyCode
			, o.IsOnHold
			, o.TotalSales
			, o.TotalCharges
			, o.TotalPayment
			, o.TotalAdditionalTaxAmount
			, o.TotalStateTaxAmount
			, o.TotalTaxes
			, o.FinanceAmount
			, 0 AS BalanceDue
			, o.PaymentTypeID
			, o.BillToStreetAddress
			, o.BillToAddressLine2
			, o.BillToCity
			, o.BilltoStateOrProvinceCode
			, o.BillToZipOrPostalCode
			, o.BillToCountryCode
			, o.ShipInstruction
			, o.OrderContactName
			, o.OrderContactEmail
			, o.OrderContactPhone
			, o.CSLastContact
			, o.CSNextContact
			, o.StoreAccount
			, o.StoreShipTo
			, o.StoreOperationID
			, o.StoreID
			, o.StoreBrandID
			, o.FulfillerID
			, o.CartID
			, o.IsWrittenOrder
			, o.OrderDate
			, o.VoidedDate
			, o.OrderCount
			, o.OriginalInvoiceID
			, o.MarketingCodeID
			, o.TransCodeID
			, o.TransCodeMultiplier
			, o.RouteCodeID
			, o.CreditHoldCodeID
			, o.ServiceStaffID
			, o.RequestedDate
			, o.TransactionSaveTime
			, o.TransactionStartTime
			, o.PriceExceptionComment
			, o.InstallationCharge
			, o.DeliveryCharge
			, o.DeliveryChargeCalculated
			, o.DeliveryChargeOverUserID
			, o.DeliveryChargeOverride
			, o.DeliveryChoice
			, o.DeliveryChargeCompliant
			, o.DeliveryCapAvailDate
			, o.OriginalDeliveryDate
			, o.OriginalDeliveryType
			, o.SFMCFulfillmentStatus
			, o.SFMCFulfillmentType
			, o.SFMCLastFulfillmentDate
			, o.SFMCPrimaryOrderCategory
			, o.IsFinanced
			, o.OriginalTransCodeID
			, o.OriginalTransDate
			, o.SalesPersonID
			, o.SuperOrderID
			, o.LastActivityDate
			, o.DateClosed
			, o.RecStatus
		INTO #SalesOrderHeaderHolding
		FROM #OrderData o
		WHERE SourceOrderID IN 
		(
			SELECT SourceOrderID 
			FROM #OrderData
		);

		UPDATE oh
		SET oh.BillToStreetAddress = i.BillToStreetAddress
			, oh.BillToAddressLine2 = i.BillToAddressLine2
			, oh.BillToCity = i.BillToCity
			, oh.BilltoStateOrProvinceCode = i.BilltoStateOrProvinceCode
			, oh.BillToZipOrPostalCode = i.BillToZipOrPostalCode
			, oh.OriginalInvoiceID = i.OriginalInvoiceID
			, oh.PriceExceptionComment = i.PriceExceptionComment
			, oh.ShipInstruction = i.ShipInstruction
			, oh.OrderContactPhone = i.OrderContactPhone
			, oh.OrderContactEmail = i.OrderContactEmail
			, oh.CSLastContact = i.CSLastContact
			, oh.CSNextContact = i.CSNextContact
			, oh.TransactionSaveTime = i.TransactionSaveTime
			, oh.TransactionStartTime = i.TransactionStartTime
		FROM #SalesOrderHeaderHolding AS oh
		INNER JOIN [Retail_Sales_Enh].[SalesOrderHeader] AS i
		ON i.SourceOrderID = oh.SourceOrderID
		AND i.OrderStatus = oh.OrderStatus 
		WHERE oh.OrderStatus IN ('Invoiced', 'Written')
		AND COALESCE(oh.SFMCFulfillmentStatus, '') <> 'Completed';

		/*Last Activity Date*/
		SELECT 
			s.SourceOrderID,
			MAX(s.OrderDate) AS MaxSalesDate
		INTO #MLAD
		FROM [Retail_Sales_Enh].[SalesOrderLineHistory] s
		GROUP BY s.SourceOrderID;

		UPDATE oh
		SET oh.LastActivityDate = MaxSalesDate
		FROM #MLAD AS m
		INNER JOIN #SalesOrderHeaderHolding AS oh
		ON oh.SourceOrderID = m.SourceOrderID
		WHERE oh.LastActivityDate IS NULL;

		DROP TABLE #OrderData
				   , #Ofment
				   , #MLAD;

		UPDATE oh
		SET oh.SuperOrderID = CONVERT(VARCHAR(12), oh.OrderDate, 112) + CAST(lm.StoreID AS VARCHAR(20)) + CAST(oh.SourceCustomerID AS VARCHAR(20))
		FROM #SalesOrderHeaderHolding AS oh
		INNER JOIN [MasterData_Retail_Ent].[StoreLocation] AS lm
		ON oh.StoreID = lm.StoreID

		/*Update SFMC Fields to Null*/
		UPDATE oh
		SET oh.SFMCFulfillmentStatus = NULL
			, oh.SFMCFulfillmentType = NULL
			, oh.SFMCLastFulfillmentDate = NULL
			, oh.SFMCPrimaryOrderCategory = NULL
		FROM #SalesOrderHeaderHolding oh
		INNER JOIN [Retail_Sales_Enh].[SalesOrderHeader] o
		ON o.SourceOrderID = oh.SourceOrderID
		AND o.OrderStatus = oh.OrderStatus
		WHERE oh.OrderStatus IN ('Written', 'Invoiced')
		AND oh.SFMCFulfillmentStatus <> 'Completed';
	
		/*Virtual Stores*/
		UPDATE oh
		SET oh.MarketingCodeID = 'CHAT'
		FROM #SalesOrderHeaderHolding oh
		INNER JOIN [MasterData_Retail_Ent].[StoreLocation] AS lm
		ON oh.StoreID = lm.StoreID
		WHERE lm.IsVirtual = 1
		AND
		(
			oh.MarketingCodeID IS NULL OR oh.MarketingCodeID NOT IN
			(
				SELECT MapToValue
				FROM [$(Source_Data)].[Retail_External].[KpiDataMapDetails]
				WHERE KpiDataMapID = 9
				AND DataMapKey = 'VirtualStore'
			)
		);
	
		/*Physical Stores*/
		UPDATE oh
		SET oh.MarketingCodeID = 'OTHER'
		FROM #SalesOrderHeaderHolding oh
		INNER JOIN [MasterData_Retail_Ent].[StoreLocation] AS lm
		ON oh.StoreID = lm.StoreID
		WHERE lm.IsVirtual = 0
		AND oh.MarketingCodeID IS NULL;

		/* Sales PersonID*/
		SELECT 
			oici.SourceOrderID
			, oici.SalesPersonID
			, SUM(oici.PercentCommission) AS SpTotal
			, ROW_NUMBER() OVER (PARTITION BY oici.SourceOrderID, oici.SalesPersonID ORDER BY SUM(oici.PercentCommission) DESC) AS Pos
		INTO #SP
		FROM [Retail_Sales_Enh].[SalesAssociateCommission] AS oici
		WHERE CommissionStatus = 'Written'
		GROUP BY oici.SourceOrderID, oici.SalesPersonID;

		UPDATE oh
		SET oh.SalesPersonID = s.SalesPersonID
		FROM #SalesOrderHeaderHolding AS oh
		INNER JOIN #SP AS s
		ON s.SourceOrderID = oh.SourceOrderID
		WHERE s.Pos = 1;

		DROP TABLE #SP;

		SELECT oc.RecordID AS SourceOrderID
			   , oc.StaffID
		INTO #DlvyOvr
		FROM [$(Source_Data)].[Retail_Corporate].[OrderComments] AS oc
		WHERE oc.Comment LIKE 'Delivery charge override%';

		UPDATE oh
		SET oh.DeliveryChargeOverUserID = StaffID
		FROM #DlvyOvr AS do
		INNER JOIN #SalesOrderHeaderHolding AS oh
		ON oh.SourceOrderID = do.SourceOrderID;

		UPDATE oh
		SET oh.DeliveryChargeOverride = o.DeliveryChargeOverride
		FROM #SalesOrderHeaderHolding AS oh
		INNER JOIN [Retail_Sales_Enh].[SalesOrderHeader] AS o
		ON o.SourceOrderID = oh.SourceOrderID
		WHERE o.OrderStatus = 'Written'
		AND oh.OrderStatus = 'Written';

		DROP TABLE #DlvyOvr;

		UPDATE oh
		SET oh.DeliveryChargeCompliant = 1
		FROM #SalesOrderHeaderHolding AS oh
		WHERE oh.TransCodeID IN (0, 1, 7);

		UPDATE oh
		SET oh.DeliveryChargeCompliant = 0
		FROM #SalesOrderHeaderHolding AS oh
		WHERE oh.TransCodeID IN (0, 1, 7)
		AND oh.SFMCFulfillmentType IN ('Delivery', 'Mixed')
		AND COALESCE(oh.DeliveryChargeCalculated, 0) BETWEEN 1 AND 7776
		AND oh.TotalCharges < oh.DeliveryChargeCalculated;

		UPDATE oh
		SET oh.DeliveryChargeCompliant = 0
		FROM #SalesOrderHeaderHolding AS oh
		WHERE oh.TransCodeID IN (0, 1, 7)
		AND oh.SFMCFulfillmentType IN ('Delivery', 'Mixed')
		AND (oh.TotalCharges = 0)
		AND oh.DeliveryChoice <> 'AFHS-SS';

		UPDATE oh
		SET oh.DeliveryChargeCompliant = 0
		FROM #SalesOrderHeaderHolding AS oh
		WHERE oh.TransCodeID IN (0, 1, 7)
		AND oh.SFMCFulfillmentType IN ('Delivery', 'Mixed')
		AND (oh.TotalCharges = 0)
		AND oh.DeliveryChoice = 'AFHS-SS'
		AND oh.OrderDate > '2024-11-03'
		AND oh.TotalSales >= 300;

		/*Update Order SFMCFulfillmentStatus*/
		UPDATE oh
		SET oh.SFMCFulfillmentStatus = 'Cancelled'
		FROM #SalesOrderHeaderHolding AS oh
		WHERE oh.SFMCFulfillmentStatus IS NULL
		AND NOT EXISTS
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales_Enh].[SalesOrderLine] AS od
			WHERE oh.SourceOrderID = od.SourceOrderID
			AND od.LineStatus IN ('Written', 'Invoiced')
		);

		UPDATE oh
		SET oh.SFMCFulfillmentStatus = 'Completed'
		FROM #SalesOrderHeaderHolding AS oh
		WHERE oh.SFMCFulfillmentStatus IS NULL
		AND NOT EXISTS
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales_Enh].[SalesOrderLine] AS od
			WHERE oh.SourceOrderID = od.SourceOrderID
			AND od.LineStatus IN ('Written')
		);

		UPDATE oh
		SET oh.SFMCFulfillmentStatus = 'Partially Completed'
		FROM #SalesOrderHeaderHolding AS oh
		WHERE oh.SFMCFulfillmentStatus IS NULL
		AND EXISTS
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales_Enh].[SalesOrderLine] AS od
			WHERE oh.SourceOrderID = od.SourceOrderID
			AND od.LineStatus IN ('Invoiced')
		);

		UPDATE oh
		SET oh.SFMCFulfillmentStatus = 'Open-Scheduled'
		FROM #SalesOrderHeaderHolding AS oh
		WHERE oh.SFMCFulfillmentStatus IS NULL
		AND EXISTS
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales_Enh].[SalesOrderLine] AS od
			WHERE oh.SourceOrderID = od.SourceOrderID
			AND od.LineStatus IN ('Written')
			AND od.DeliveryStatus IN ('SCD')
		);

		UPDATE oh
		SET oh.SFMCFulfillmentStatus = 'Open-Estimated'
		FROM #SalesOrderHeaderHolding AS oh
		WHERE oh.SFMCFulfillmentStatus IS NULL
		AND EXISTS
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales_Enh].[SalesOrderLine] AS od
			WHERE oh.SourceOrderID = od.SourceOrderID
			AND od.LineStatus IN ('Written')
			AND od.DeliveryStatus NOT IN ('SCD')
		);

		/*Update Order 	SFMCFulfillmentTyp*/
		SELECT SourceOrderID
			   , COUNT(*) AS DeliveryTypeCount
			   , MIN(dl.DeliveryType) AS TypeCodeID
		INTO #DlvyTypeCode
		FROM
		(
			SELECT od.SourceOrderID
				   , od.DeliveryType
			FROM [Retail_Sales_Enh].[SalesOrderLine] AS od
			WHERE od.LineStatus NOT IN ('Cancelled')
			GROUP BY od.SourceOrderID
					 , od.DeliveryType
		) dl
		GROUP BY dl.SourceOrderID;

		UPDATE #SalesOrderHeaderHolding
		SET SFMCFulfillmentType = ft.FulFillmentType
		FROM #SalesOrderHeaderHolding oh
		INNER JOIN
		(
			SELECT SourceOrderID
				   , DeliveryTypeCount
				   , TypeCodeID
				   , CASE WHEN DeliveryTypeCount = 1 AND TypeCodeID = 'D' THEN 'Delivery'
						  WHEN DeliveryTypeCount = 1 AND TypeCodeID = 'P' THEN 'Pickup'
						  WHEN DeliveryTypeCount = 1 AND TypeCodeID = 'M' THEN 'Direct Ship'
						  WHEN DeliveryTypeCount = 1 AND TypeCodeID = 'T' THEN 'Take With'
						ELSE 'Mixed'
				   END FulFillmentType
			FROM #DlvyTypeCode
		) ft
		ON ft.SourceOrderID = oh.SourceOrderID

		UPDATE oh
		SET oh.DeliveryChoice = od.SKU
		FROM #SalesOrderHeaderHolding AS oh
		INNER JOIN [Retail_Sales_Enh].[SalesOrderLine] AS od
		ON od.SourceOrderID = oh.SourceOrderID
		WHERE od.SKU IN ('AFHS-DDS', 'AFHS-RC', 'AFHS-SS', 'AFHS-WG', 'DFA-DSP', 'DFA-FS', 'DFA-RC', 'DFA-WG')

		DROP TABLE #DlvyTypeCode;

		/*Update Order 	SFMCLastFulfillmentDate*/
		UPDATE #SalesOrderHeaderHolding
		SET SFMCLastFulfillmentDate = dlv.LastFulFillmentDate
		FROM #SalesOrderHeaderHolding AS oh
		INNER JOIN
		(
			SELECT od.SourceOrderID
				   , MAX(od.DeliveryDate) LastFulFillmentDate
			FROM [Retail_Sales_Enh].[SalesOrderLine] AS od
			WHERE od.LineStatus = 'Invoiced'
			GROUP BY od.SourceOrderID
		) dlv
		ON dlv.SourceOrderID = oh.SourceOrderID;


		/*Update Order SFMCPrimaryOrderCategory*/
		SELECT *
		INTO #TopCategory
		FROM
		(
			SELECT od.SourceOrderID
				   , gm.CategoryID
				   , SUM(od.UnitSellPrice * od.QuantityOrdered) CatSales
				   , ROW_NUMBER() OVER (PARTITION BY od.SourceOrderID ORDER BY SUM(od.UnitSellPrice * od.QuantityOrdered) DESC) TopCat
			FROM [Retail_Sales_Enh].[SalesOrderLine] AS od
			INNER JOIN [MasterData_Product_Enh].[ProductInfo] AS p
			ON p.SKU = od.SKU
			INNER JOIN [MasterData_Product].[ProductGroup] gm
			ON p.GroupID = gm.GroupID
			GROUP BY od.SourceOrderID
					 , gm.CategoryID
		) cat
		WHERE cat.TopCat = 1;

		UPDATE #SalesOrderHeaderHolding
		SET SFMCPrimaryOrderCategory = tc.CategoryID
		FROM #SalesOrderHeaderHolding AS oh
		INNER JOIN #TopCategory AS tc
		ON tc.SourceOrderID = oh.SourceOrderID;

		DROP TABLE #TopCategory;

		/*Update OH Missing Store Brand*/
		UPDATE oh
		SET StoreBrandID = sb.StoreBrandID
		FROM #SalesOrderHeaderHolding AS oh
		INNER JOIN
		(
			SELECT od.SourceOrderID
				   , MAX(pm.StoreBrandID) AS StoreBrandID
			FROM #SalesOrderHeaderHolding AS oh
			INNER JOIN [Retail_Sales_Enh].[SalesOrderLine] AS od
			ON od.SourceOrderID = oh.SourceOrderID
			INNER JOIN [MasterData_Product_Enh].[ProductInfo] AS pm
			ON pm.SKU = od.SKU
			WHERE oh.StoreBrandID IS NULL
			AND pm.IsMaster = 1
			GROUP BY od.SourceOrderID
		) sb
		ON sb.SourceOrderID = oh.SourceOrderID
		WHERE oh.StoreBrandID IS NULL;

		UPDATE #SalesOrderHeaderHolding
		SET DateClosed = GETDATE()
		WHERE SFMCFulfillmentStatus IN ('Completed', 'Cancelled')
		AND DateClosed IS NULL;

		/*DlvyCapAvailDate in OrderHeader with TransCodeID = 10*/
		SELECT 
			SourceOrderID, 
			RouteCodeID, 
			OrderDate, 
			QuantityOrdered
		INTO #DeliveryCapAvailData
		FROM 
		(
			SELECT o.OrderStatus, od.LineStatus,
				o.SourceOrderID,
				o.RouteCodeID,
				o.OrderDate, 
				SUM(od.QuantityOrdered) QuantityOrdered
			FROM [Retail_Sales_Enh].[SalesOrderLine] od 
			INNER JOIN [Retail_Sales].[SalesOrderHeader] o
			ON o.SourceOrderID = od.SourceOrderID
			WHERE o.OrderStatus = 'Written'
			AND od.LineStatus = 'Written'
			AND o.NewEntryFlag = 1
			AND od.TransCodeID = 10
			GROUP BY 
				o.SourceOrderID,
				o.RouteCodeID,
				o.OrderDate,
				o.OrderStatus, od.LineStatus
		) dta

		UPDATE oh
		SET oh.DeliveryCapAvailDate = [Retail_Sales].[fn_GetRouteATPDate](dta.RouteCodeID, dta.OrderDate, dta.QuantityOrdered)
		FROM #DeliveryCapAvailData dta
		INNER JOIN #SalesOrderHeaderHolding oh 
		ON dta.SourceOrderID = oh.SourceOrderID

		/*OrigDeliveryDate in OrderHeader with TransCodeID = 10*/
		--From InvoiceItem and OrderItem
		SELECT SourceOrderID
			   , OriginalDeliveryDate
		INTO #OrigDeliveryData 
		FROM
		(
			SELECT 
				od.SourceOrderID,
				MAX(od.OriginalDeliveryDate) AS OriginalDeliveryDate
			FROM [Retail_Sales].[SalesOrderLine] ii
			INNER JOIN [Retail_Sales_Enh].[SalesOrderLine] od
			ON od.SourceOrderID = ii.SourceOrderID
			AND ii.LineStatus = od.LineStatus
			WHERE ii.NewEntryFlag = 1
			AND od.TransCodeID = 10
			AND od.LineStatus IN ('Invoiced', 'Written')
			GROUP BY od.SourceOrderID
		) dta

		UPDATE oh
		SET oh.OriginalDeliveryDate = o.OriginalDeliveryDate
		FROM #OrigDeliveryData o
		INNER JOIN #SalesOrderHeaderHolding oh
		ON oh.SourceOrderID = o.SourceOrderID

		DROP TABLE #DeliveryCapAvailData
				   , #OrigDeliveryData;

		/*OriginalDeliveryType Update*/
		SELECT 
			ot.SourceOrderID,
			MIN(CASE WHEN od.DeliveryType = 'P' OR od .DeliveryType IS NULL THEN 'P' ELSE 'D' END) AS OrderDeliveryType
		INTO #ORD
		FROM [Retail_Sales_Enh].[SalesOrderHeader] AS ot
		INNER JOIN [Retail_Sales_Enh].[SalesOrderLine] AS od 
		ON od.SourceOrderID = ot.SourceOrderID
		GROUP BY ot.SourceOrderID;

		UPDATE	oh
		SET oh.OriginalDeliveryType = det.OrderDeliveryType
		FROM #SalesOrderHeaderHolding AS oh
		INNER JOIN #ORD AS det
		ON det.SourceOrderID = oh.SourceOrderID;

		DROP TABLE #ORD;

		INSERT INTO [Retail_Sales_Enh].[SalesOrderHeader]
		(
			SourceSystem
			, OrderKey
			, SourceOrderID
			, BaseOrderID
			, DateCreated
			, LastUpdatedUTC
			, SourceCustomerID
			, CustomerName
			, OrderStatus
			, SalesChannel
			, OrderType
			, CompanyCode
			, IsOnHold
			, TotalSales
			, TotalCharges
			, TotalPayment
			, TotalAdditionalTaxAmount
			, TotalStateTaxAmount
			, TotalTaxes
			, FinanceAmount
			, BalanceDue
			, PaymentTypeID
			, BillToStreetAddress
			, BillToAddressLine2
			, BillToCity
			, BilltoStateOrProvinceCode
			, BillToZipOrPostalCode
			, BillToCountryCode
			, ShipInstruction
			, OrderContactName
			, OrderContactEmail
			, OrderContactPhone
			, CSLastContact
			, CSNextContact
			, StoreAccount
			, StoreShipTo
			, StoreOperationID
			, StoreID
			, StoreBrandID
			, FulfillerID
			, CartID
			, IsWrittenOrder
			, OrderDate
			, VoidedDate
			, OrderCount
			, OriginalInvoiceID
			, MarketingCodeID
			, TransCodeID
			, TransCodeMultiplier
			, RouteCodeID
			, CreditHoldCodeID
			, ServiceStaffID
			, RequestedDate
			, TransactionSaveTime
			, TransactionStartTime
			, PriceExceptionComment
			, InstallationCharge
			, DeliveryCharge
			, DeliveryChargeCalculated
			, DeliveryChargeOverUserID
			, DeliveryChargeOverride
			, DeliveryChoice
			, DeliveryChargeCompliant
			, DeliveryCapAvailDate
			, OriginalDeliveryDate
			, OriginalDeliveryType
			, SFMCFulfillmentStatus
			, SFMCFulfillmentType
			, SFMCLastFulfillmentDate
			, SFMCPrimaryOrderCategory
			, IsFinanced
			, OriginalTransCodeID
			, OriginalTransDate
			, SalesPersonID
			, SuperOrderID
			, LastActivityDate
			, DateClosed
			, RecStatus
		)

		SELECT
			SourceSystem
			, OrderKey
			, SourceOrderID
			, BaseOrderID
			, DateCreated
			, LastUpdatedUTC
			, SourceCustomerID
			, CustomerName
			, OrderStatus
			, SalesChannel
			, OrderType
			, CompanyCode
			, IsOnHold
			, TotalSales
			, TotalCharges
			, TotalPayment
			, TotalAdditionalTaxAmount
			, TotalStateTaxAmount
			, TotalTaxes
			, FinanceAmount
			, BalanceDue
			, PaymentTypeID
			, BillToStreetAddress
			, BillToAddressLine2
			, BillToCity
			, BilltoStateOrProvinceCode
			, BillToZipOrPostalCode
			, BillToCountryCode
			, ShipInstruction
			, OrderContactName
			, OrderContactEmail
			, OrderContactPhone
			, CSLastContact
			, CSNextContact
			, StoreAccount
			, StoreShipTo
			, StoreOperationID
			, StoreID
			, StoreBrandID
			, FulfillerID
			, CartID
			, IsWrittenOrder
			, OrderDate
			, VoidedDate
			, OrderCount
			, OriginalInvoiceID
			, MarketingCodeID
			, TransCodeID
			, TransCodeMultiplier
			, RouteCodeID
			, CreditHoldCodeID
			, ServiceStaffID
			, RequestedDate
			, TransactionSaveTime
			, TransactionStartTime
			, PriceExceptionComment
			, InstallationCharge
			, DeliveryCharge
			, DeliveryChargeCalculated
			, DeliveryChargeOverUserID
			, DeliveryChargeOverride
			, DeliveryChoice
			, DeliveryChargeCompliant
			, DeliveryCapAvailDate
			, OriginalDeliveryDate
			, OriginalDeliveryType
			, SFMCFulfillmentStatus
			, SFMCFulfillmentType
			, SFMCLastFulfillmentDate
			, SFMCPrimaryOrderCategory
			, IsFinanced
			, OriginalTransCodeID
			, OriginalTransDate
			, SalesPersonID
			, SuperOrderID
			, LastActivityDate
			, DateClosed
			, RecStatus
		FROM #SalesOrderHeaderHolding;

		DROP TABLE #SalesOrderHeaderHolding;

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
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase,@DestinationSchema,@DestinationTable
		
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

