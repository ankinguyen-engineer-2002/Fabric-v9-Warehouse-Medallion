CREATE   PROCEDURE [Retail_Sales_Enh].[usp_Update_SalesOrderHeader]
AS

BEGIN
	
	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'Retail_Sales_Enh.usp_Update_SalesOrderHeader' ;
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

		--TRUNCATE TABLE [Retail_Sales_Enh].[SalesOrderHeader];

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(OrderKey),0) FROM [Retail_Sales_Enh].[SalesOrderHeader]);

		IF OBJECT_ID('tempdb..#OrderFulfillment') IS NOT NULL 
		DROP TABLE #OrderFulfillment;

		SELECT
			OrderID
			, MerchSubTot
			, DlvyChrg
			, InstallationChrg
			, DlvyChrgCalculated
			, RecStatus
			, DateChanged
			, DateCreated
		INTO #OrderFulfillment
		FROM [$(Source_Data)].[Retail_Corporate].[OrderFulfillment]
		WHERE OrderID IN
		(
			SELECT DataSetKeyValue
			FROM [MasterData_Retail_Ent].[DataSetKey]
		);

		IF OBJECT_ID('tempdb..#OrderItemCommissionInfo') IS NOT NULL 
		DROP TABLE #OrderItemCommissionInfo;

		SELECT *
		INTO #OrderItemCommissionInfo
		FROM [Retail_Sales].[SalesAssociateCommission]
		WHERE CommissionStatus = 'Written';

		IF OBJECT_ID('tempdb..#OrderComments') IS NOT NULL 
		DROP TABLE #OrderComments;

		SELECT 
			oc.RecordID AS SourceOrderID
			, oc.StaffID
		INTO #OrderComments
		FROM [$(Source_Data)].[Retail_Corporate].[OrderComments] AS oc
		WHERE oc.RecordID IN
		(
			SELECT DataSetKeyValue
			FROM [MasterData_Retail_Ent].[DataSetKey]
		)		
		AND oc.Comment LIKE 'Delivery charge override%';

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

		IF OBJECT_ID('tempdb..#Ofment') IS NOT NULL 
		DROP TABLE #Ofment;

		SELECT 
			oh.SourceOrderID
			, SUM(ofmnt.MerchSubTot) ofMerchSubTotal
			, SUM(ofmnt.DlvyChrg) AS DeliveryCharge
			, SUM(ofmnt.InstallationChrg) AS InstallationCharge
			, MAX(COALESCE(ofmnt.DlvyChrgCalculated, 0)) AS DeliveryChargeCalculated
		INTO #Ofment
		FROM [Retail_Sales].[SalesOrderHeader] oh
		INNER JOIN #OrderFulfillment ofmnt
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

		/*Flag Orders that are CustomerServiceOrders for CustomerServiceOrders process*/
		UPDATE o
		SET o.NewEntryFlag = 1
		FROM [Retail_Sales].[SalesOrderHeader] o
		LEFT OUTER JOIN [Retail_Sales_Enh].[SalesOrderHeader] oh
		ON oh.SourceOrderID = o.SourceOrderID
		WHERE oh.SourceOrderID IS NULL;

		IF OBJECT_ID('tempdb..#Written') IS NOT NULL 
		DROP TABLE #Written;

		SELECT *
		INTO #Written
		FROM [Retail_Sales].[SalesOrderHeader]
		WHERE OrderStatus = 'Written';

		IF OBJECT_ID('tempdb..#Invoiced') IS NOT NULL 
		DROP TABLE #Invoiced;

		SELECT *
		INTO #Invoiced
		FROM [Retail_Sales].[SalesOrderHeader]
		WHERE OrderStatus = 'Invoiced';

		IF OBJECT_ID('tempdb..#OrderData') IS NOT NULL 
		DROP TABLE #OrderData;

		SELECT 
			MAX(od.SourceSystem) AS SourceSystem
			, od.SourceOrderID
			, od.BaseOrderID
			, MAX(od.SourceCustomerID) AS SourceCustomerID
			, MAX(od.CustomerName) AS CustomerName
			, CASE WHEN MAX(CASE WHEN od.OrderStatus = 'Invoiced' THEN 1 ELSE 0 END) = 1 THEN 'Invoiced' ELSE 'Written' END AS OrderStatus
			, MAX(od.SalesChannel) AS SalesChannel
			, MAX(od.OrderType) AS OrderType
			, MAX(od.CompanyCode) AS CompanyCode
			, MAX(CAST(od.IsOnHold AS INT)) AS IsOnHold
			, COALESCE(SUM(od.MerchSubTotal) * MAX(t.TransCodeMultiplier), 0) AS TotalSales
			, COALESCE(SUM(od.TotalCharges) * MAX(t.TransCodeMultiplier), 0) AS TotalCharges
			, COALESCE(SUM(od.TotalPayment) * MAX(t.TransCodeMultiplier), 0) AS TotalPayment
			, COALESCE(SUM(od.TotalAdditionalTaxAmount) * MAX(t.TransCodeMultiplier), 0) AS TotalAdditionalTaxAmount
			, COALESCE(SUM(od.TotalStateTaxAmount) * MAX(t.TransCodeMultiplier), 0) AS TotalStateTaxAmount
			, COALESCE(SUM(od.TotalTax) * MAX(t.TransCodeMultiplier), 0) AS TotalTaxes
			, COALESCE(SUM(od.TotalInvoiceAmount) * MAX(t.TransCodeMultiplier), 0) AS TotalInvoiceAmount
			, COALESCE(SUM(od.FinanceAmount) * MAX(t.TransCodeMultiplier), 0) AS FinanceAmount
			, 0 AS BalanceDue
			, COALESCE(SUM(od.InstallationCharge) * MAX(t.TransCodeMultiplier), 0) AS InstallationCharge
			, COALESCE(SUM(od.DeliveryCharge) * MAX(t.TransCodeMultiplier), 0) AS DeliveryCharge
			, SUM(od.DeliveryChargeCalculated) AS DeliveryChargeCalculated
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
			, CAST(NULL AS VARCHAR(5)) AS DeliveryChargeOverUserID
			, MAX(od.DeliveryChargeOverride) AS DeliveryChargeOverride
			, MAX(od.DeliveryChoice) AS DeliveryChoice
			, MAX(od.DeliveryChargeCompliant) AS DeliveryChargeCompliant
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
			, CAST(NULL AS DATETIME2(3)) AS LastUpdatedUTC
			, CAST(NULL AS DATETIME2(3)) AS DateCreated
			, CAST(NULL AS CHAR(1)) AS RecStatus
		INTO #OrderData
		FROM
		(
			SELECT 
				 SourceSystem
				, SourceOrderID
				, BaseOrderID
				, SourceCustomerID
				, CustomerName
				, OrderStatus
				, SalesChannel
				, OrderType
				, CompanyCode
				, IsOnHold
				, MerchSubTotal
				, TotalOrderValue
				, TotalPayment
				, TotalAdditionalTaxAmount
				, TotalStateTaxAmount
				, TotalAdditionalTaxAmount + TotalStateTaxAmount AS TotalTax
				, TotalInvoiceAmount
				, FinanceAmount
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
				, FulfillerID
				, CartID
				, IsWrittenOrder
				, OrderDate
				, VoidedDate
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
				, DeliveryCharge + InstallationCharge AS TotalCharges
				, DeliveryCharge
				, DeliveryChargeCalculated
				, DeliveryChargeOverride
				, DeliveryChoice
				, DeliveryChargeCompliant
				, LastUpdatedUTC
				, DateCreated
				, RecStatus
			FROM [Retail_Sales].[SalesOrderHeader]
			WHERE OrderStatus = 'Written'
    
			UNION ALL
    
			SELECT 
				SourceSystem
				, SourceOrderID
				, BaseOrderID
				, SourceCustomerID
				, CustomerName
				, OrderStatus
				, SalesChannel
				, OrderType
				, CompanyCode
				, IsOnHold
				, MerchSubTotal
				, TotalOrderValue
				, TotalPayment
				, TotalAdditionalTaxAmount
				, TotalStateTaxAmount
				, TotalAdditionalTaxAmount + TotalStateTaxAmount AS TotalTax
				, TotalInvoiceAmount
				, FinanceAmount
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
				, FulfillerID
				, CartID
				, IsWrittenOrder
				, OrderDate
				, VoidedDate
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
				, DeliveryCharge + InstallationCharge AS TotalCharges
				, DeliveryCharge
				, 0 AS DeliveryChargeCalculated
				, DeliveryChargeOverride
				, DeliveryChoice
				, DeliveryChargeCompliant
				, LastUpdatedUTC
				, DateCreated
				, RecStatus
			FROM [Retail_Sales].[SalesOrderHeader]
			WHERE OrderStatus = 'Invoiced'
		) od
		INNER JOIN [$(Source_Data)].[Retail_External].[TransCodeMap] t
		ON CAST(t.TransCodeID AS INT) = od.TransCodeID
		LEFT JOIN [MasterData_Retail_Ent].[StoreLocation] AS lm
		ON lm.StoreID = od.StoreID
		WHERE t.TransCodeGroup = 'All'
		GROUP BY od.SourceOrderID
				 , od.BaseOrderID;

		IF OBJECT_ID('tempdb..#SourceData') IS NOT NULL 
		DROP TABLE #SourceData;

		SELECT 
			SourceOrderID
			, LastUpdatedUTC
			, DateCreated
			, RecStatus
			, ROW_NUMBER() OVER (PARTITION BY SourceOrderID ORDER BY CASE OrderStatus WHEN 'Invoiced' THEN 1 WHEN 'Written' THEN 2 END) AS rn
		INTO #SourceData
		FROM [Retail_Sales].[SalesOrderHeader];

		UPDATE o
		SET o.LastUpdatedUTC = so.LastUpdatedUTC
			, o.DateCreated = so.DateCreated
			, o.RecStatus = so.RecStatus
		FROM #OrderData o
		INNER JOIN #SourceData so
		ON o.SourceOrderID = so.SourceOrderID
		WHERE rn = 1;

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
			, o.TotalInvoiceAmount - o.TotalTaxes - o.TotalCharges AS TotalSales
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
		FROM #OrderData o
		LEFT OUTER JOIN [Retail_Sales_Enh].[SalesOrderHeader] oh
		ON o.SourceOrderID = oh.SourceOrderID
		WHERE oh.SourceOrderID IS NULL;

		IF OBJECT_ID('tempdb..#OrderHeader') IS NOT NULL 
		DROP TABLE #OrderHeader;

		SELECT *
		INTO #OrderHeader
		FROM [Retail_Sales_Enh].[SalesOrderHeader];

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
		FROM #OrderHeader oh
		INNER JOIN #OrderData o
		ON o.SourceOrderID = oh.SourceOrderID
		WHERE oh.SourceOrderID IS NOT NULL;

		IF OBJECT_ID('tempdb..#Billing') IS NOT NULL 
		DROP TABLE #Billing;

		SELECT
			SourceOrderID
			, BillToStreetAddress
			, BillToAddressLine2
			, BillToCity
			, BilltoStateOrProvinceCode
			, BillToZipOrPostalCode
			, OriginalInvoiceID
			, PriceExceptionComment
			, ShipInstruction
			, OrderContactPhone
			, OrderContactEmail
			, CSLastContact
			, CSNextContact
			, TransactionSaveTime
			, TransactionStartTime
			, ROW_NUMBER() OVER (PARTITION BY SourceOrderID ORDER BY CASE OrderStatus WHEN 'Invoiced' THEN 1 WHEN 'Written' THEN 2 END) AS rn
		INTO #Billing
		FROM [Retail_Sales].[SalesOrderHeader];

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
		FROM #OrderHeader AS oh
		INNER JOIN #Billing AS i
		ON i.SourceOrderID = oh.SourceOrderID
		WHERE COALESCE(oh.SFMCFulfillmentStatus, '') <> 'Completed';

		UPDATE oh
		SET oh.SuperOrderID = CONVERT(VARCHAR(12), oh.OrderDate, 112) + CAST(lm.StoreID AS VARCHAR(20)) + CAST(oh.SourceCustomerID AS VARCHAR(20))
		FROM #OrderHeader AS oh
		INNER JOIN [MasterData_Retail_Ent].[StoreLocation] AS lm
		ON oh.StoreID = lm.StoreID;
		--INNER JOIN [MasterData_Retail_Ent].[DataSetKey] ds
		--ON oh.SourceOrderID = ds.DataSetKeyValue;

		/*Update SFMC Fields to NULL*/
		UPDATE oh
		SET oh.SFMCFulfillmentStatus = NULL
			, oh.SFMCFulfillmentType = NULL
			, oh.SFMCLastFulfillmentDate = NULL
			, oh.SFMCPrimaryOrderCategory = NULL
		FROM #OrderHeader oh
		INNER JOIN #Written o
		ON o.SourceOrderID = oh.SourceOrderID
		WHERE oh.SFMCFulfillmentStatus <> 'Completed';

		UPDATE oh
		SET oh.SFMCFulfillmentStatus = NULL
			, oh.SFMCFulfillmentType = NULL
			, oh.SFMCLastFulfillmentDate = NULL
			, oh.SFMCPrimaryOrderCategory = NULL
		FROM #OrderHeader oh
		INNER JOIN #Invoiced i
		ON i.SourceOrderID = oh.SourceOrderID
		WHERE oh.SFMCFulfillmentStatus <> 'Completed';
	
		/*Virtual Stores*/
		UPDATE oh
		SET oh.MarketingCodeID = 'CHAT'
		FROM #OrderHeader oh
		INNER JOIN [MasterData_Retail_Ent].[StoreLocation] AS lm
		ON oh.StoreID = lm.StoreID
		WHERE lm.IsVirtual = 1
		AND (oh.MarketingCodeID IS NULL OR oh.MarketingCodeID NOT IN
		(
			SELECT MapToValue
			FROM [$(Source_Data)].[Retail_External].[KpiDataMapDetails]
			WHERE KpiDataMapID = 9
			AND DataMapKey = 'VirtualStore'
		));
	
		/*Physical Stores*/
		UPDATE oh
		SET oh.MarketingCodeID = 'OTHER'
		FROM #OrderHeader oh
		INNER JOIN [MasterData_Retail_Ent].[StoreLocation] AS lm
		ON oh.StoreID = lm.StoreID
		WHERE lm.IsVirtual = 0
		AND oh.MarketingCodeID IS NULL;

		/* Sales PersonID*/
		IF OBJECT_ID('tempdb..#SP') IS NOT NULL 
		DROP TABLE #SP;
		
		SELECT 
			oici.SourceOrderID
			, oici.SalesPersonID
			, SUM(oici.PercentCommission) AS SpTotal
			, ROW_NUMBER() OVER (PARTITION BY oici.SourceOrderID, oici.SalesPersonID ORDER BY SUM(oici.PercentCommission) DESC) AS Pos
		INTO #SP
		FROM #OrderItemCommissionInfo AS oici
		GROUP BY oici.SourceOrderID
				, oici.SalesPersonID;

		UPDATE oh
		SET oh.SalesPersonID = s.SalesPersonID
		FROM #OrderHeader AS oh
		INNER JOIN #SP AS s
		ON s.SourceOrderID = oh.SourceOrderID
		WHERE s.Pos = 1;

		UPDATE oh
		SET oh.DeliveryChargeOverUserID = StaffID
		FROM #OrderComments AS do
		INNER JOIN #OrderHeader AS oh
		ON oh.SourceOrderID = do.SourceOrderID;

		UPDATE oh
		SET oh.DeliveryChargeOverride = o.DeliveryChargeOverride
		FROM #OrderHeader AS oh
		INNER JOIN #Written AS o
		ON o.SourceOrderID = oh.SourceOrderID;

		UPDATE oh
		SET oh.DeliveryChargeCompliant = 1
		FROM #OrderHeader AS oh
		--INNER JOIN [MasterData_Retail_Ent].[DataSetKey] ds
		--ON oh.SourceOrderID = ds.DataSetKeyValue
		WHERE oh.TransCodeID IN (0, 1, 7);

		UPDATE oh
		SET oh.DeliveryChargeCompliant = 0
		FROM #OrderHeader AS oh
		--INNER JOIN [MasterData_Retail_Ent].[DataSetKey] ds
		--ON oh.SourceOrderID = ds.DataSetKeyValue
		WHERE oh.TransCodeID IN (0, 1, 7)
		AND oh.SFMCFulfillmentType IN ('Delivery', 'Mixed')
		AND COALESCE(oh.DeliveryChargeCalculated, 0) BETWEEN 1 AND 7776
		AND oh.TotalCharges < oh.DeliveryChargeCalculated;

		UPDATE oh
		SET oh.DeliveryChargeCompliant = 0
		FROM #OrderHeader AS oh
		--INNER JOIN [MasterData_Retail_Ent].[DataSetKey] ds
		--ON oh.SourceOrderID = ds.DataSetKeyValue
		WHERE oh.TransCodeID IN (0, 1, 7)
		AND oh.SFMCFulfillmentType IN ('Delivery', 'Mixed')
		AND (oh.TotalCharges = 0)
		AND oh.DeliveryChoice <> 'AFHS-SS';

		UPDATE oh
		SET oh.DeliveryChargeCompliant = 0
		FROM #OrderHeader AS oh
		--INNER JOIN [MasterData_Retail_Ent].[DataSetKey] ds
		--ON oh.SourceOrderID = ds.DataSetKeyValue
		WHERE oh.TransCodeID IN (0, 1, 7)
		AND oh.SFMCFulfillmentType IN ('Delivery', 'Mixed')
		AND (oh.TotalCharges = 0)
		AND oh.DeliveryChoice = 'AFHS-SS'
		AND oh.OrderDate > '2024-11-03'
		AND oh.TotalSales >= 300;

		/*Update Order SFMCFulfillmentStatus*/
		UPDATE oh
		SET oh.SFMCFulfillmentStatus = 'Cancelled'
		FROM #OrderHeader AS oh
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
		FROM #OrderHeader AS oh
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
		FROM #OrderHeader AS oh
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
		FROM #OrderHeader AS oh
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
		FROM #OrderHeader AS oh
		WHERE oh.SFMCFulfillmentStatus IS NULL
		AND EXISTS
		(
			SELECT DISTINCT SourceOrderID
			FROM [Retail_Sales_Enh].[SalesOrderLine] AS od
			WHERE oh.SourceOrderID = od.SourceOrderID
			AND od.LineStatus IN ('Written')
			AND od.DeliveryStatus NOT IN ('SCD')
		);

		/*Update Order SFMCFulfillmentType*/
		IF OBJECT_ID('tempdb..#DlvyTypeCode') IS NOT NULL 
		DROP TABLE #DlvyTypeCode;

		SELECT 
			BaseOrderID
			, COUNT(*) AS DeliveryTypeCount
			, MIN(dl.DeliveryType) AS TypeCodeID
		INTO #DlvyTypeCode
		FROM
		(
			SELECT 
				od.BaseOrderID
				, od.DeliveryType
			FROM [Retail_Sales_Enh].[SalesOrderLine] AS od
			--INNER JOIN [MasterData_Retail_Ent].[DataSetKey] ds
			--ON od.BaseOrderID = ds.DataSetKeyValue
			WHERE od.LineStatus NOT IN ('Cancelled')
			GROUP BY od.BaseOrderID
					 , od.DeliveryType
		) dl
		GROUP BY dl.BaseOrderID;

		UPDATE oh
		SET oh.SFMCFulfillmentType = ft.FulFillmentType
		FROM #OrderHeader oh
		INNER JOIN
		(
			SELECT
				BaseOrderID
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
		ON ft.BaseOrderID = oh.BaseOrderID;
		--INNER JOIN [MasterData_Retail_Ent].[DataSetKey] ds
		--ON oh.BaseOrderID = ds.DataSetKeyValue;

		UPDATE oh
		SET oh.DeliveryChoice = od.SKU
		FROM #OrderHeader AS oh
		INNER JOIN [Retail_Sales_Enh].[SalesOrderLine] AS od
		ON od.SourceOrderID = oh.SourceOrderID
		--INNER JOIN [MasterData_Retail_Ent].[DataSetKey] ds
		--ON oh.SourceOrderID = ds.DataSetKeyValue
		WHERE od.SKU IN ('AFHS-DDS', 'AFHS-RC', 'AFHS-SS', 'AFHS-WG', 'DFA-DSP', 'DFA-FS', 'DFA-RC', 'DFA-WG');

		/*Update Order 	SFMCLastFulfillmentDate*/
		UPDATE oh
		SET SFMCLastFulfillmentDate = dlv.LastFulFillmentDate
		FROM #OrderHeader AS oh
		INNER JOIN
		(
			SELECT
				od.BaseOrderID
				, MAX(od.DeliveryDate) LastFulFillmentDate
			FROM [Retail_Sales_Enh].[SalesOrderLine] AS od
			--INNER JOIN [MasterData_Retail_Ent].[DataSetKey] ds
			--ON od.BaseOrderID = ds.DataSetKeyValue
			WHERE od.LineStatus = 'Invoiced'
			GROUP BY od.BaseOrderID
		) dlv
		ON dlv.BaseOrderID = oh.BaseOrderID;

		/*Last Activity Date*/
		IF OBJECT_ID('tempdb..#MLAD') IS NOT NULL 
		DROP TABLE #MLAD;

		SELECT 
			s.SourceOrderID
			, MAX(s.OrderDate) AS MaxSalesDate
		INTO #MLAD
		FROM [Retail_Sales_Enh].[SalesOrderLineHistory] s
		INNER JOIN [MasterData_Retail_Ent].[DataSetKey] ds
		ON s.SourceOrderID = ds.DataSetKeyValue
		WHERE s.SalesDataTypeKey = 1
		GROUP BY s.SourceOrderID;

		UPDATE oh
		SET oh.LastActivityDate = m.MaxSalesDate
		FROM #MLAD AS m
		INNER JOIN #OrderHeader AS oh
		ON oh.SourceOrderID = m.SourceOrderID
		WHERE oh.LastActivityDate IS NULL;

		/*Update Order SFMCPrimaryOrderCategory*/
		IF OBJECT_ID('tempdb..#TopCategory') IS NOT NULL 
		DROP TABLE #TopCategory;

		SELECT *
		INTO #TopCategory
		FROM
		(
			SELECT 
				od.BaseOrderID
				, gm.CategoryID
				, SUM(od.UnitSellPrice * od.QuantityOrdered) CategorySales
				, ROW_NUMBER() OVER (PARTITION BY od.BaseOrderID ORDER BY SUM(od.UnitSellPrice * od.QuantityOrdered) DESC) TopCatagory
			FROM [Retail_Sales_Enh].[SalesOrderLine] AS od
			INNER JOIN [MasterData_Product_Enh].[ProductInfo] AS p
			ON p.SKU = od.SKU
			INNER JOIN [MasterData_Product].[ProductGroup] gm
			ON p.GroupID = gm.GroupID
			GROUP BY od.BaseOrderID
					 , gm.CategoryID
		) cat
		WHERE cat.TopCatagory = 1;

		UPDATE oh
		SET SFMCPrimaryOrderCategory = tc.CategoryID
		FROM #OrderHeader AS oh
		INNER JOIN #TopCategory AS tc
		ON tc.BaseOrderID = oh.BaseOrderID;

		/*Update OH Missing Store Brand*/
		UPDATE oh
		SET oh.StoreBrandID = sb.StoreBrandID
		FROM #OrderHeader AS oh
		INNER JOIN
		(
			SELECT 
				od.BaseOrderID
				, MAX(pm.StoreBrandID) AS StoreBrandID
			FROM #OrderHeader AS oh
			INNER JOIN [Retail_Sales_Enh].[SalesOrderLine] AS od
			ON od.BaseOrderID = oh.BaseOrderID
			INNER JOIN [MasterData_Product_Enh].[ProductInfo] AS pm
			ON pm.SKU = od.SKU
			WHERE oh.StoreBrandID IS NULL
			AND pm.IsMaster = 1
			GROUP BY od.BaseOrderID
		) sb
		ON sb.BaseOrderID = oh.BaseOrderID
		WHERE oh.StoreBrandID IS NULL;

		UPDATE #OrderHeader
		SET DateClosed = GETDATE()
		WHERE SFMCFulfillmentStatus IN ('Completed', 'Cancelled')
		AND DateClosed IS NULL;

		/*DlvyCapAvailDate in OrderHeader with TransCodeID = 10*/
		/*
		IF OBJECT_ID('tempdb..#DeliveryCapAvailData') IS NOT NULL 
		DROP TABLE #DeliveryCapAvailData;

		SELECT 
			SourceOrderID
			, RouteCodeID
			, OrderDate
			, QuantityOrdered
		INTO #DeliveryCapAvailData
		FROM 
		(
			SELECT 
				o.OrderStatus
				, od.LineStatus
				, o.SourceOrderID
				, o.RouteCodeID
				, o.OrderDate
				, SUM(od.QuantityOrdered) QuantityOrdered
			FROM [Retail_Sales_Enh].[SalesOrderLine] od 
			INNER JOIN [Retail_Sales].[SalesOrderHeader] o
			ON o.SourceOrderID = od.SourceOrderID
			WHERE o.OrderStatus = 'Written'
			AND od.LineStatus = 'Written'
			AND o.NewEntryFlag = 1
			AND od.TransCodeID = 10
			GROUP BY o.SourceOrderID
					, o.RouteCodeID
					, o.OrderDate
					, o.OrderStatus
					, od.LineStatus
		) dta
        */
		
		/*commented on 27-11-2025 and have added the same by replacing the function call with the actual query in the following update stmt */
		/* UPDATE oh
		SET oh.DeliveryCapAvailDate = [Retail_Sales].[fn_GetRouteATPDate](dta.RouteCodeID, dta.OrderDate, dta.QuantityOrdered)
		FROM #DeliveryCapAvailData dta
		INNER JOIN #OrderHeader oh 
		ON dta.SourceOrderID = oh.SourceOrderID 
		*/
        /*
		UPDATE oh
        SET oh.DeliveryCapAvailDate =
        (
			SELECT MIN(RouteDate)
			FROM [$(Source_Data)].[Retail_corporate].[Routedetail] rd
			WHERE rd.RouteDate >= dta.OrderDate
			AND rd.RouteCodeID = dta.RouteCodeID
			AND ((rd.MaxPieces - rd.ActualPieces >= dta.QuantityOrdered OR rd.MaxPieces IS NULL)
			AND (rd.MaxCubes - rd.ActualCubes > 0 OR rd.MaxCubes IS NULL)
			AND (rd.MaxStops - rd.ActualStops > 0 OR rd.MaxStops IS NULL)
			AND (rd.MaxValue - rd.ActualValue > 0 OR rd.MaxValue IS NULL))
        )
        FROM #DeliveryCapAvailData dta
        INNER JOIN #OrderHeader oh
        ON dta.SourceOrderID = oh.SourceOrderID
		 */
        
		/* Logic from Pradeep for DeliveryCapAvailDate */
		UPDATE oh
		SET oh.DeliveryCapAvailDate = CASE WHEN bo.TotalPieces = 0 THEN oh.OrderDate ELSE
        (
            SELECT MIN(RouteDate)
            FROM [$(Source_Data)].[Retail_Corporate].[RouteDetail]  rd
            WHERE rd.RouteDate >= DATEADD(DAY, 1, oh.OrderDate)
            AND rd.RouteCodeID = oh.RouteCodeID
            AND ((rd.MaxPieces - rd.ActualPieces >= bo.TotalPieces OR rd.MaxPieces IS NULL)
            AND (rd.MaxCubes - rd.ActualCubes > 0 OR rd.MaxCubes IS NULL)
            AND (rd.MaxStops - rd.ActualStops > 0 OR rd.MaxStops IS NULL)
            AND (rd.MaxValue - rd.ActualValue > 0 OR rd.MaxValue IS NULL))
        )
        END
        FROM #OrderHeader AS oh
        INNER JOIN
		(
			SELECT
			OrderID
			, SUM(CASE WHEN DlvyTypeCodeID = 'D' THEN QtyOrdered ELSE 0 END) AS TotalPieces
			FROM
			(
				SELECT
				OrderID
				, QtyOrdered
				, DlvyTypeCodeID
				, RANK() OVER(PARTITION BY OrderID ORDER BY DateChanged ASC) as rnk
				FROM [$(Source_Data)].[Retail_Corporate_SCD].[OrderItem]
				WHERE ProductTypeID = '1'
				AND RecStatus <> 'D'
			) AS SubQuery
			WHERE rnk = 1
			GROUP BY OrderID
		) bo
		ON bo.OrderID = oh.SourceOrderID
        INNER JOIN [$(Source_Data)].[Retail_Corporate_SCD].[Orders] AS o  
		ON o.OrderID = oh.SourceOrderID
		AND o.RecStatus <> 'D'
        WHERE DeliveryCapAvailDate IS NULL
		AND oh.TransCodeID NOT IN (2, 3, 6);

		/*OrigDeliveryDate in OrderHeader with TransCodeID = 10*/

		--From InvoiceItem and OrderItem

		IF OBJECT_ID('tempdb..#OrigDeliveryDate') IS NOT NULL 
		DROP TABLE #OrigDeliveryDate;

		SELECT 
			BaseOrderID
			, OriginalDeliveryDate
		INTO #OrigDeliveryDate
		FROM
		(
			SELECT
				od.BaseOrderID
				, MAX(od.OriginalDeliveryDate) AS OriginalDeliveryDate
			FROM [Retail_Sales].[SalesOrderLine] ii
			INNER JOIN [Retail_Sales_Enh].[SalesOrderLine] od
			ON od.BaseOrderID = ii.BaseOrderID
			AND ii.LineStatus = od.LineStatus
			WHERE ii.NewEntryFlag = 1
			AND od.TransCodeID = 10
			AND od.LineStatus IN ('Invoiced', 'Written')
			GROUP BY od.BaseOrderID
		) dta

		UPDATE oh
		SET oh.OriginalDeliveryDate = o.OriginalDeliveryDate
		FROM #OrigDeliveryDate o
		INNER JOIN #OrderHeader oh
		ON oh.BaseOrderID = o.BaseOrderID

		/*OriginalDeliveryType Update*/
		IF OBJECT_ID('tempdb..#ORD') IS NOT NULL 
		DROP TABLE #ORD;

		SELECT 
			ot.BaseOrderID
			, MIN(CASE WHEN od.DeliveryType = 'P' OR od.DeliveryType IS NULL THEN 'P' ELSE 'D' END) AS OrderDeliveryType
		INTO #ORD
		FROM [Retail_Sales_Enh].[SalesOrderHeader] AS ot
		INNER JOIN [Retail_Sales_Enh].[SalesOrderLine] AS od 
		ON od.BaseOrderID = ot.BaseOrderID
		GROUP BY ot.BaseOrderID;

		UPDATE oh
		SET oh.OriginalDeliveryType = det.OrderDeliveryType
		FROM #OrderHeader AS oh
		INNER JOIN #ORD AS det
		ON det.BaseOrderID = oh.BaseOrderID;

		DELETE soh
		FROM [Retail_Sales_Enh].[SalesOrderHeader] soh
		INNER JOIN #OrderHeader od
		ON soh.SourceOrderID = od.SourceOrderID;

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
		FROM #OrderHeader;

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