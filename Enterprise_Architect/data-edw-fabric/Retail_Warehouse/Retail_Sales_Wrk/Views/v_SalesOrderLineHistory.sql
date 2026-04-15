-- Auto Generated (Do not modify) 5BBB49A46D527594E2ADF181CBB6651BA40B10206CDB3AA81B36EEEFB04C6343
CREATE VIEW [Retail_Sales_Wrk].[v_SalesOrderLineHistory]
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
 
, CTE_BtaData AS (
	SELECT
		CASE WHEN bta.OrderID NOT LIKE '%[A-Z][A-Z][0-9]%' THEN 'STORIS_DSG'
		WHEN bta.OrderID LIKE '%[A-Z][A-Z][0-9]%' THEN 'HOMES_CORPORATE'
		ELSE 'Unknown' END AS SourceSystem
		, bta.BtaID
		, bta.AsIsSale_ReasonCodeID AS AsIsSaleReasonCodeID
		, bta.Base_OrderID AS BaseOrderID
		, bta.OrderID AS SourceOrderID
		, bta.TransDate
		, bta.OrderItemID AS LineNumber
		, CASE WHEN bta.Source = 'W' THEN 'Written'
		  WHEN bta.Source = 'D' THEN 'Invoiced'
		  ELSE NULL END AS LineStatus
		, p.Description as ItemDescription
		, bta.ProductID AS SKU
		, bta.NetUnits AS QuantityOrdered
		, bta.NetSales AS NetPrice
		, pp.PlanID AS ProtectionPlanSKU
		, pp.ProtectionPlanID
		, bta.ProtectionPlan_SlsPrice AS ProtectionPlanPrice
		, bta.ProtectionPlan_SlsCost AS ProtectionPlanCost
		, CASE WHEN bta.ProductTypeID = 3 THEN 1 ELSE 0 END AS IsServiceItem
		, CASE WHEN bta.ProtectionPlanID IS NOT NULL THEN 1 ELSE 0 END AS HasProtectionPlan
		, CAST(NULL AS DATE) AS WarrantyEndDate
		, bta.StoreID
		, 0 AS KitOrPackageQuantity
		, '' AS KitOrPackageSKU
		, bta.NetCost AS NetCost
		, bta.CategoryID
		, bta.GroupID
		, bta.CustomerID
		, bta.DiscntCode AS DiscountCode
		, bta.DlvyStoreID AS DeliveryStoreID
		, bta.DlvyTypeCodeID AS DeliveryTypeCodeID
		, bta.SalespersonID AS SalesPersonID
		, bta.ServiceTypeID
		, bta.TransCodeID
		, bta.VendorID
		, bta.VoidedReasonCodeID
		, bta.DateChanged
		, bta.DateCreated
		, bta.PurchaseStatusCodeID
		, bta.SpecialOrder
		, bta.UpdateDateTime
		, bta.UpdateTypeID
		, bta.Source
		-- , bta.RecStatus
	FROM [$(Source_Data)].[Retail_Corporate].[BtaData] bta
	LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Product] p
	ON bta.ProductID = p.ProductID
	LEFT JOIN [$(Source_Data)].[Retail_Corporate].[ProtectionPlan] pp
	ON bta.ProtectionPlanID = pp.ProtectionPlanID
	LEFT JOIN CTE_SiteData sm
	ON sm.RetailSystemNumber = CAST(bta.StoreID AS INT)
	WHERE ISNUMERIC(bta.StoreID) = 1
	AND sm.RN = 1
	AND COALESCE(CAST(bta.DateChanged AS DATE), CAST(bta.DateCreated AS DATE)) BETWEEN CAST(GETDATE()-3 AS DATE) AND CAST(GETDATE() AS DATE)
	--AND bta.OrderID NOT LIKE '%[A-Z][A-Z][0-9]%'
)

SELECT
	bd.*
FROM CTE_BtaData bd;