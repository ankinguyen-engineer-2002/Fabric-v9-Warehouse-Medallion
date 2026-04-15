-- Auto Generated (Do not modify) E07D9A66DA4F3708ED6A4DA48EFD322EC0CEA72DB4862187B634F09C2B096F7C
CREATE VIEW [Retail_Sales_Wrk].[v_SalesOrderLine]
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

,CTE_TransCodes AS (
	SELECT
		Description
		, TransCodeID
		, CASE WHEN TransCodeID <= 20 then 1 ELSE -1 END AS TransCodeMultiplier
		, CASE WHEN TransCodeID IN (0, 1, 2, 7, 30, 31, 37, 20, 50) THEN 1 Else 0 END as TransCodeInvoiceFlag
	FROM [$(Source_Data)].[Retail_Corporate].[TransCode]
)

,CTE_OrderData AS (
	SELECT
		o.AsIsReasonCodeID
		--, CASE WHEN CHARINDEX('*', o.OrderID) > 0 
		--  THEN LEFT(o.OrderID, CHARINDEX('*', o.OrderID) - 1)
		--  ELSE o.OrderID END AS Base_OrderID
		, o.OrderID
		, CAST(o.OrderDate AS DATE) AS OrderDate
		, CAST(o.OrderBookedStoreID AS INT) AS OrderBookedStoreID
		, o.DlvyChrg
		, o.DlvySubTot
		, o.TotSaleAmt 
		, o.TotInvcAmt
		, o.DlvyStoreID
		, o.TransCodeID
		, o.RecStatus
		, tr.TransCodeMultiplier
		, o.DesiredDate
		, o.VoidedOrderReasonCodeID
		, o.OriginalInvoiceID
		, o.Comments
		, o.DateChanged
		, o.DateCreated
	FROM [$(Source_Data)].[Retail_Corporate].[Orders] o
	INNER JOIN CTE_TransCodes tr
	ON tr.TransCodeID = o.TransCodeID
	WHERE ISNUMERIC(o.OrderBookedStoreID) = 1
	AND o.OrderID IN
	(
		SELECT DataSetKeyValue
		FROM [MasterData_Retail_Ent].[DataSetKey]
	)
)

,CTE_InvoiceData AS (
	SELECT
		i.AsIsReasonCodeID
		, i.Base_OrderID
		, i.OrderID
		, CAST(i.OrderDate AS DATE) AS OrderDate
		, CAST(i.InvoiceDate AS DATE) AS InvoiceDate
		, CAST(i.OrderBookedStoreID AS INT) AS OrderBookedStoreID
		, i.DlvyChrg
		, i.DlvySubTot
		, i.TotSaleAmt 
		, i.TotInvcAmt
		, i.DlvyStoreID
		, i.TransCodeID
		, i.RecStatus
		, tr.TransCodeMultiplier
		, i.DesiredDate
		, i.OriginalInvoiceID
		, i.VoidedOrderReasonCodeID
		, i.Comments
		, i.DateChanged
		, i.DateCreated
	FROM [$(Source_Data)].[Retail_Corporate].[Invoice] i
	INNER JOIN CTE_TransCodes tr
	ON tr.TransCodeID = i.TransCodeID
	WHERE ISNUMERIC(i.OrderBookedStoreID) = 1
	AND i.Base_OrderID IN
	(
		SELECT DataSetKeyValue
		FROM [MasterData_Retail_Ent].[DataSetKey]
	)
	AND i.OrderID NOT IN ('919950482*ˆ', '919951412*^', '919951412*ž', '919951412*Š', '919950482*Š', '919951412*Œ', '919950482*Œ')
	--AND tr.TransCodeInvoiceFlag = 1
)

,CTE_OrderLine AS (
	SELECT
		CASE WHEN oi.OrderID NOT LIKE '%[A-Z][A-Z][0-9]%' THEN 'STORIS_DSG'
		WHEN oi.OrderID LIKE '%[A-Z][A-Z][0-9]%' THEN 'HOMES_CORPORATE'
		ELSE 'Unknown' END AS SourceSystem
		, od.AsIsReasonCodeID
		, od.OrderID AS BaseOrderID
		, oi.OrderID AS SourceOrderID
		, oi.ItemID AS LineNumber
		, oi.PurchaseOrderID
		, oi.POLineID AS PurchaseOrderLineID
		, oi.AutoTransOrderItemID
		, CAST(NULL AS DATE) InvoiceDate
		, oi.ProductDesc AS ItemDescription
		, oi.QtyOrdered AS QuantityOrdered
		, oi.QtyCommitted AS QuantityCommitted
		, 0 AS QuantityDelivered
		, oi.QtyUndelivered AS QuantityUndelivered
		, od.DesiredDate AS RequestedDate
		, oi.ProductID AS SKU
		, oi.SoftKit_ProductID AS KitProductID
		, oi.CaseSellingPrice AS UnitSellPrice
		, oi.CasePriceDefault AS UnitListPrice
		, od.TotSaleAmt AS TotalSaleAmount
		, od.TotInvcAmt AS TotalInvoiceAmount
		, 'Written' AS LineStatus
		--, CASE WHEN oi.RecStatus = 'D' THEN 'Cancelled'
		--  ELSE 'Written' END AS LineStatus
		, pp.PlanID AS ProtectionPlanSKU
		, oi.ProductTypeID
		, CASE WHEN oi.ProductTypeID = 3 THEN 1 ELSE 0 END AS IsServiceItem
		, pp.ProtectionPlanID
		, CASE WHEN oi.ProtectionPlanID IS NOT NULL THEN 1 ELSE 0 END AS HasProtectionPlan
		, CAST(NULL AS DATETIME2(3)) AS WarrantyEndDate
		, od.OrderDate
		, oi.OrderFulfillmentID
		, NULL AS KitOrPackageQuantity
		, '' AS KitOrPackageSKU
		, oi.KitGroupNumber
		, oi.BookedStoreID AS StoreID
		, od.OriginalInvoiceID
		, oi.VendorModelNbr AS VendorModelNumber
		, oi.TransCodeID
		, oi.DlvyDate AS DeliveryDate
		, oi.DlvyStatus AS DeliveryStatus
		, oi.DlvyTypeCodeID AS DeliveryType
		, od.DlvyStoreID AS DelievryStoreID
		, od.DlvySubTot AS DeliverySubTotal
		, oi.LineCost
		, oi.Addon1Cost
		, oi.Addon2Cost
		, oi.LandedFreight
		, oi.ProdDiscntAmt AS OtherDiscount
		, oi.ProdDiscntCode AS ProductDiscountCode
		, oi.WrittenDate
		, oi.PriceVarianceExceptionReasonCodeID
		, oi.VendorID
		, od.VoidedOrderReasonCodeID AS VoidedReasonCodeID
		, oi.ProtectionPlanPrice
		, oi.ProtectionPlanCost
		, oi.ProtectionPlanRegisterID
		, oi.PriceOverrideStaffID
		, oi.PurchaseStatusCodeID
		, oi.StoreID AS StockLocationID
		, oi.ShipLocnID AS ShipLocationID
		, oi.ServiceMerchandise_OrderID AS ServiceMerchandiseOrderID
		, oi.ServiceMerchandise_ItemID AS ServiceMerchandiseItemID
		, oi.ServiceProblemCodeID
		, oi.ServiceOrder_OrderID AS ServiceOrderOrderID
		, oi.ServiceOrder_ItemID AS ServiceOrderItemID
		, oi.ServiceStatusCodeID
		, oi.ServiceTech_StaffID AS ServiceTechStaffID
		, od.Comments
		, od.DateChanged
		, od.DateCreated
		, NULL AS SerialNumber
		, NULL AS ItemCommCategory
		, NULL AS NewEntryFlag
		, oi.SpecOrderFlg AS SpecialOrderFlag
		, oi.RecStatus
	FROM CTE_OrderData od
	INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] oi
	ON od.OrderID = oi.OrderID
	LEFT JOIN [$(Source_Data)].[Retail_Corporate].[ProtectionPlan] pp
	ON oi.ProtectionPlanID = pp.ProtectionPlanID
	LEFT JOIN CTE_TransCodes otr
	ON otr.TransCodeID = oi.TransCodeID
	LEFT JOIN CTE_SiteData sm
	ON sm.RetailSystemNumber = CAST(oi.BookedStoreID AS INT)
	AND sm.RN = 1
	WHERE ISNUMERIC(oi.BookedStoreID) = 1
	AND oi.OrderID IN
	(
		SELECT DataSetKeyValue
		FROM [MasterData_Retail_Ent].[DataSetKey]
	)

	UNION ALL

	SELECT
		CASE WHEN ii.OrderID NOT LIKE '%[A-Z][A-Z][0-9]%' THEN 'STORIS_DSG'
		WHEN ii.OrderID LIKE '%[A-Z][A-Z][0-9]%' THEN 'HOMES_CORPORATE'
		ELSE 'Unknown' END AS SourceSystem
		, id.AsIsReasonCodeID
		, id.Base_OrderID AS BaseOrderID
		, ii.OrderID AS SourceOrderID
		, ii.ItemID AS LineNumber
		, ii.PurchaseOrderID
		, ii.POLineID AS PurchaseOrderLineID
		, ii.AutoTransOrderItemID
		, id.InvoiceDate AS InvoiceDate
		, ii.ProductDesc AS ItemDescription
		, ii.QtyOrdered AS QuantityOrdered
		, ii.QtyCommitted AS QuantityCommitted
		, ii.QtyCommitted AS QuantityDelivered
		, ii.QtyUndelivered AS QuantityUndelivered
		, id.DesiredDate AS RequestedDate
		, ii.ProductID AS SKU
		, ii.SoftKit_ProductID AS KitProductID
		, ii.CaseSellingPrice AS UnitSellPrice
		, ii.CasePriceDefault AS UnitListPrice
		, id.TotSaleAmt AS TotalSaleAmount
		, id.TotInvcAmt AS TotalInvoiceAmount
		, 'Invoiced' AS LineStatus
		, pp.PlanID AS ProtectionPlanSKU
		, ii.ProductTypeID
		, CASE WHEN ii.ProductTypeID = 3 THEN 1 ELSE 0 END AS IsServiceItem
		, pp.ProtectionPlanID
		, CASE WHEN ii.ProtectionPlanID IS NOT NULL THEN 1 ELSE 0 END AS HasProtectionPlan
		, CAST(NULL AS DATETIME2(3)) AS WarrantyEndDate
		, id.OrderDate
		, ii.OrderFulfillmentID
		, NULL AS KitOrPackageQuantity
		, '' AS KitOrPackageSKU
		, ii.KitGroupNumber
		, ii.BookedStoreID AS StoreID
		, id.OriginalInvoiceID
		, ii.VendorModelNbr AS VendorModelNumber
		, ii.TransCodeID
		, ii.DlvyDate AS DeliveryDate
		, ii.DlvyStatus AS DeliveryStatus
		, ii.DlvyTypeCodeID AS DeliveryType
		, id.DlvyStoreID AS DelievryStoreID
		, id.DlvySubTot AS DeliverySubTotal
		, ii.LineCost
		, ii.Addon1Cost
		, ii.Addon2Cost
		, ii.LandedFreight
		, ii.ProdDiscntAmt AS OtherDiscount
		, ii.ProdDiscntCode AS ProductDiscountCode
		, ii.WrittenDate
		, ii.PriceVarianceExceptionReasonCodeID
		, ii.VendorID
		, id.VoidedOrderReasonCodeID AS VoidedReasonCodeID
		, ii.ProtectionPlanPrice
		, ii.ProtectionPlanCost
		, ii.ProtectionPlanRegisterID
		, ii.PriceOverrideStaffID
		, ii.PurchaseStatusCodeID
		, ii.StoreID AS StockLocationID
		, ii.ShipLocnID AS ShipLocationID
		, ii.ServiceMerchandise_OrderID AS ServiceMerchandiseOrderID
		, ii.ServiceMerchandise_ItemID AS ServiceMerchandiseItemID
		, ii.ServiceProblemCodeID
		, ii.ServiceOrder_OrderID AS ServiceOrderOrderID
		, ii.ServiceOrder_ItemID AS ServiceOrderItemID
		, ii.ServiceStatusCodeID
		, ii.ServiceTech_StaffID AS ServiceTechStaffID
		, id.Comments
		, id.DateChanged
		, id.DateCreated
		, NULL AS SerialNumber
		, NULL AS ItemCommCategory
		, NULL AS NewEntryFlag
		, ii.SpecOrderFlg AS SpecialOrderFlag
		, ii.RecStatus
	FROM CTE_InvoiceData id
	INNER JOIN [$(Source_Data)].[Retail_Corporate].[InvoiceItem] ii
	ON id.OrderID = ii.OrderID
	LEFT JOIN [$(Source_Data)].[Retail_Corporate].[ProtectionPlan] pp
	ON ii.ProtectionPlanID = pp.ProtectionPlanID
	LEFT JOIN CTE_TransCodes itr
	ON itr.TransCodeID = ii.TransCodeID
	LEFT JOIN CTE_SiteData sm
	ON sm.RetailSystemNumber = CAST(ii.BookedStoreID AS INT)
	AND sm.RN = 1
	WHERE ISNUMERIC(ii.BookedStoreID) = 1
	AND id.Base_OrderID IN
	(
		SELECT DataSetKeyValue
		FROM [MasterData_Retail_Ent].[DataSetKey]
	)
)

SELECT
	ol.*
FROM CTE_OrderLine ol;