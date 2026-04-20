CREATE VIEW [Retail_Sales_Wrk].[v_SalesOrderHeader]
AS
WITH CTE_SiteData AS (
    SELECT 
		ErpDatabaseName
		, OperationID
		, AccountNumber
		, ShipToNum
		, AcctShipTo
		, ProfitCenter
		, CAST(RetailSystemNumber AS INT) AS RetailSystemNumber
		, SiteName
		, SiteCountryCode AS CountryCode
		, MigratedtoStoris
		, CAST(DATE AS DATE) AS MigrationDate
		, ROW_NUMBER() OVER(PARTITION BY RetailSystemNumber ORDER BY RetailSystemNumber) AS RN
    FROM [$(Source_Data)].[MasterData_Retail].[SiteMasterLocations]
	WHERE RetailSystemNumber IS NOT NULL
	AND CompanyCode IN ('DSG', 'AGR')
)

,CTE_Customer AS (
	SELECT
		CustomerID
		, FullName
		, Address1
		, Address2
		, City
		, State
		, PostalCodeID
		, EmailAddress
		, HomePhone
		, CellPhone
		, WorkPhone
		, ShipInstr AS ShipInstruction
	FROM [$(Source_Data)].[Retail_Corporate].[Customer]
)

,CTE_TransCode AS (
    SELECT 
		Description
		, TransCodeID
		, CASE WHEN TransCodeID <= 20 then 1 ELSE -1 END AS TransCodeMultiplier
		, CASE WHEN TransCodeID IN (0, 1, 2, 7, 30, 31, 37, 20, 50) THEN 1 Else 0 END as TransCodeInvoiceFlag
    FROM [$(Source_Data)].[Retail_Corporate].[TransCode]
)

,CTE_OrderHeader AS (
	SELECT
		CASE WHEN o.OrderID NOT LIKE '%[A-Z][A-Z][0-9]%' THEN 'STORIS_DSG'
		WHEN o.OrderID LIKE '%[A-Z][A-Z][0-9]%' THEN 'HOMES_CORPORATE'
		ELSE 'Unknown' END AS SourceSystem
		, o.OrderID AS SourceOrderID
		, CASE WHEN CHARINDEX('*', o.OrderID) > 0 
		THEN LEFT(o.OrderID, CHARINDEX('*', o.OrderID) - 1)
		ELSE o.OrderID END AS BaseOrderID
		, o.DateCreated
		, o.DateChanged AS LastUpdatedUTC
		, TRIM(o.CustomerID) AS SourceCustomerID
		, ISNULL(c.FullName,'') AS CustomerName
		, 'Written' AS OrderStatus
		, 'In-Store' AS SalesChannel
		, CASE    
			WHEN o.TransCodeID = '0' THEN 'Sale'
			WHEN o.TransCodeID = '7' THEN 'Exchange'
			WHEN o.TransCodeID LIKE '3%' AND LEN(o.TransCodeID) = 2 THEN 'Return'
			WHEN o.TransCodeID = '6' THEN 'Quote'
			WHEN o.TransCodeID LIKE '1%' AND LEN(o.TransCodeID) = 2 THEN 'Service'
			WHEN o.TransCodeID LIKE '6%' AND LEN(o.TransCodeID) = 2 AND o.TransCodeID <> '6' THEN 'Transfer'
			WHEN o.TransCodeID = '3' THEN 'Layaway'
			ELSE ''
			END AS OrderType
		, 'AGR' AS CompanyCode
		, CASE WHEN o.TotPaymentAmt > 0 THEN 1 ELSE 0 END AS IsOnHold
		, o.MerchSubTot AS MerchSubTotal
		, o.TotOrderValue AS TotalOrderValue
		, o.TotPaymentAmt AS TotalPayment
		, o.TotAddlTaxAmt AS TotalAdditionalTaxAmount
		, o.TotStateTaxAmt AS TotalStateTaxAmount
		, o.TotInvcAmt AS TotalInvoiceAmount
		, o.FinanceAmt AS FinanceAmount
		, o.FinancePaymentTypeID AS PaymentTypeID
		, ISNULL(c.Address1,'') AS BillToStreetAddress
		, ISNULL(c.Address2,'') AS BillToAddressLine2
		, ISNULL(c.City,'') AS BillToCity
		, CAST(TRIM(ISNULL(c.State,'')) AS CHAR(2)) AS BillToStateOrProvinceCode
		, TRIM(c.PostalCodeID) AS BillToZipOrPostalCode
		, sm.CountryCode AS BillToCountryCode
		, c.ShipInstruction
		, ISNULL(c.FullName,'') AS OrderContactName
		, TRIM((c.EmailAddress)) AS OrderContactEmail
		, COALESCE(c.HomePhone, c.CellPhone, c.WorkPhone) AS OrderContactPhone
		, o.CSLastContact
		, o.CSNextContact
		, sm.AccountNumber AS StoreAccount
		, sm.ShipToNum AS StoreShipTo
		, sm.OperationID AS StoreOperationID
		, sm.RetailSystemNumber AS StoreID
		, sm.AcctShipTo AS FulfillerID
		, NULL AS CartID
		, NULL AS IsWrittenOrder
		, o.OrderDate
		, o.VoidedDate
		, o.OriginalInvoiceID
		, o.MarketingCodeID
		, o.TransCodeID
		, tr.TransCodeMultiplier
		, o.RouteCodeID
		, o.CreditHoldCodeID
		, o.ServiceStaffID
		, o.DesiredDate AS RequestedDate
		, o.TransactionSaveTime
		, o.TransactionStartTime
		, o.PriceExceptionComment
		, o.InstallationChrg AS InstallationCharge
		, o.DlvyChrg AS DeliveryCharge
		, NULL AS DeliveryChargeCalculated
		, o.DlvyChrgOverride AS DeliveryChargeOverride
		, NULL AS DeliveryChoice
		, NULL AS DeliveryChargeCompliant
		, NULL AS NewEntryFlag
		, o.RecStatus
	FROM [$(Source_Data)].[Retail_Corporate].[Orders] o
	LEFT JOIN CTE_Customer c
	ON o.CustomerID = c.CustomerID
	LEFT JOIN CTE_TransCode tr
	ON tr.TransCodeID = o.TransCodeID
	INNER JOIN CTE_SiteData sm
	ON sm.RetailSystemNumber = CAST(o.OrderBookedStoreID AS INT)
	WHERE o.OrderID IN
	(
		SELECT DataSetKeyValue
		FROM [MasterData_Retail_Ent].[DataSetKey]
	)
	AND ISNUMERIC(o.OrderBookedStoreID) = 1
	AND sm.RN = 1

	UNION ALL

	SELECT
		CASE WHEN i.OrderID NOT LIKE '%[A-Z][A-Z][0-9]%' THEN 'STORIS_DSG'
		WHEN i.OrderID LIKE '%[A-Z][A-Z][0-9]%' THEN 'HOMES_CORPORATE'
		ELSE 'Unknown' END AS SourceSystem
		, i.OrderID AS SourceOrderID
		, i.Base_OrderID AS BaseOrderID
		, i.DateCreated
		, i.DateChanged AS LastUpdatedUTC
		, TRIM(i.CustomerID) AS SourceCustomerID
		, ISNULL(c.FullName,'') AS CustomerName
		, 'Invoiced' AS OrderStatus
		, 'In-Store' AS SalesChannel
		, CASE    
			WHEN i.TransCodeID = '0' THEN 'Sale'
			WHEN i.TransCodeID = '7' THEN 'Exchange'
			WHEN i.TransCodeID LIKE '3%' AND LEN(i.TransCodeID) = 2 THEN 'Return'
			WHEN i.TransCodeID = '6' THEN 'Quote'
			WHEN i.TransCodeID LIKE '1%' AND LEN(i.TransCodeID) = 2 THEN 'Service'
			WHEN i.TransCodeID LIKE '6%' AND LEN(i.TransCodeID) = 2 AND i.TransCodeID <> '6' THEN 'Transfer'
			WHEN i.TransCodeID = '3' THEN 'Layaway'
			ELSE ''
			END AS OrderType
		, 'AGR' AS CompanyCode
		, CASE WHEN i.TotPaymentAmt > 0 THEN 1 ELSE 0 END AS IsOnHold
		, i.MerchSubTot AS MerchSubTotal
		, i.TotOrderValue AS TotalOrderValue
		, i.TotPaymentAmt AS TotalPayment
		, i.TotAddlTaxAmt AS TotalAdditionalTaxAmount
		, i.TotStateTaxAmt AS TotalStateTaxAmount
		, i.TotInvcAmt AS TotalInvoiceAmount
		, i.FinanceAmt AS FinanceAmount
		, i.FinancePaymentTypeID AS PaymentTypeID
		, TRIM(c.Address1) AS BillToStreetAddress
		, ISNULL(c.Address2,'') AS BillToAddressLine2
		, TRIM(c.City) AS BillToCity
		, CAST(TRIM(c.State) AS CHAR(2)) AS BillToStateOrProvinceCode
		, TRIM(c.PostalCodeID) AS BillToZipOrPostalCode
		, sm.CountryCode AS BillToCountryCode
		, c.ShipInstruction
		, ISNULL(c.FullName,'') AS OrderContactName
		, TRIM((c.EmailAddress)) AS OrderContactEmail
		, COALESCE(c.HomePhone, c.CellPhone, c.WorkPhone) AS OrderContactPhone
		, i.CSLastContact
		, i.CSNextContact	
		, ISNULL(sm.AccountNumber,'') AS StoreAccount
		, sm.ShipToNum AS StoreShipTo
		, sm.OperationID AS StoreOperationID
		, sm.RetailSystemNumber AS StoreID
		, sm.AcctShipTo AS FulfillerID
		, NULL AS CartID
		, NULL AS IsWrittenOrder
		, i.OrderDate
		, i.VoidedDate
		, i.OriginalInvoiceID
		, i.MarketingCodeID
		, i.TransCodeID
		, tr.TransCodeMultiplier
		, i.RouteCodeID
		, i.CreditHoldCodeID
		, i.ServiceStaffID
		, i.DesiredDate AS RequestedDate
		, i.TransactionSaveTime
		, i.TransactionStartTime
		, i.PriceExceptionComment
		, i.InstallationChrg AS InstallationCharge
		, i.DlvyChrg AS DeliveryCharge
		, i.DlvyChrgCalculated AS DeliveryChargeCalculated
		, i.DlvyChrgOverride AS DeliveryChargeOverride
		, NULL AS DeliveryChoice
		, NULL AS DeliveryChargeCompliant
		, NULL AS NewEntryFlag
		, i.RecStatus
	FROM [$(Source_Data)].[Retail_Corporate].[Invoice] i
	LEFT JOIN CTE_Customer c
	ON i.CustomerID = c.CustomerID
	LEFT JOIN CTE_TransCode tr
	ON tr.TransCodeID = i.TransCodeID
	--AND tr.TransCodeInvoiceFlag = 1
	INNER JOIN CTE_SiteData sm
	ON sm.RetailSystemNumber = CAST(i.OrderBookedStoreID AS INT)
	WHERE i.Base_OrderID IN
	(
		SELECT DataSetKeyValue
		FROM [MasterData_Retail_Ent].[DataSetKey]
	)
	AND ISNUMERIC(i.OrderBookedStoreID) = 1 
	AND sm.RN = 1
	AND i.OrderID NOT IN ('919950482*ˆ', '919951412*^', '919951412*ž', '919951412*Š', '919950482*Š', '919951412*Œ', '919950482*Œ')
)

SELECT
	oh.*
FROM CTE_OrderHeader oh;

