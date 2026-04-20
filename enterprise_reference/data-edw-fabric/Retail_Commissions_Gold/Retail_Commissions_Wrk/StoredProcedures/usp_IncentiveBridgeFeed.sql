--select top 1000 * from  [Retail_Commissions_Wrk].[v_IncentiveBridgeFeed] 
--where TransDateKey between 20251201 and 20251215

--EXEC [Retail_Commissions_Wrk].[usp_IncentiveBridgeFeed] '2025-12-01', '2025-12-02'



CREATE PROC [Retail_Commissions_Wrk].[usp_IncentiveBridgeFeed] 
  @FromDate Date,
  @ToDate Date
AS   

DECLARE @FromDateInt Int,
        @ToDateInt Int

Set @FromDateInt = CAST(CONVERT(VARCHAR(8), @FromDate, 112) AS INT)
Set @ToDateInt = CAST(CONVERT(VARCHAR(8), @ToDate, 112) AS INT);

-- Convert all temp tables to CTEs
WITH CTE_WrkOrders AS (
	SELECT
		sdt.SourceDataID,
		sdt.OrderID,
		sdt.ItemID,
        sdt.TransDateKey ,
	    cast(cast(sdt.TransDateKey as char(8) )as Date) AS TransDate,
	    COALESCE(cast(cast(sdt.OrderDateKey as char(8) )as Date),cast(cast(sdt.[TransDateKey] as char(8) )as Date)) AS OrderDate, 
		sdt.TransCodeID,
		COALESCE(pm.SKU, pr.ProductID) AS ProductID,
		pm.SKUName AS ProductName,
        pm.VendorID,
		--COALESCE(pm.VendorID, pr.VendorID) as VendorID,
		pm.SubGroupID,
		sp.SalesPersonID,
        cm.CustomerID,
        cm.Address1,
        cm.Address2,
		cm.FullName AS CustomerName,
		sp.SalesPersonName,
		sp.HomeStore,
		COALESCE(gm.CategoryID,grp.CategoryID) AS CategoryID,
		COALESCE(gm.GroupID,pr.GroupID) AS GroupID,
		Right('000'+lm.StoreID,3) AS StoreID,
		lm.LocationName AS StoreName,
		lm.HomestoreOwnerGroup AS OwnerGroup,
		sdt.AsIsReasonCodeID,
		CASE
			WHEN sdt.SalesType = 'W' AND sdt.SalesDataTypeKey IN (1, 10) THEN sdt.Sales
			ELSE 0
		END AS WrittenSales,
		CASE
			WHEN sdt.SalesType = 'W' THEN sdt.Cost
			ELSE 0
		END AS WrittenCost,
		CASE
			WHEN sdt.SalesType = 'W' THEN sdt.Units
			ELSE 0
		END AS WrittenUnits,
		0 AS WrittenTaxes,
		CASE
			WHEN sdt.SalesType = 'W'  AND sdt.SalesDataTypeKey = 2 THEN sdt.Sales
			ELSE 0
		END AS WrittenCharges,
		0 AS WrittenRebates,
		CASE
			WHEN sdt.SalesType = 'D' THEN sdt.Sales
			ELSE 0
		END AS DeliveredSales,
		CASE
			WHEN sdt.SalesType = 'D' THEN sdt.Cost
			ELSE 0
		END AS DeliveredCost,
		CASE
			WHEN sdt.SalesType = 'D' THEN sdt.Units
			ELSE 0
		END AS DeliveredUnits,
		sdt.DeliveryStatus,
		sdt.ProductDiscountCode AS ProdDiscntCode,
		sdt.PVEReasonCodeID AS PriceVarianceExceptionReasonCodeID,
		cm.LastName AS CustomerLastName,
		sdt.SalesDataTypeKey,
		sdt.InvSubBucketID,
        i.DlvyChrgOverride as InvoiceDlvyChrgOverride,  
        o.DlvyChrgOverride as OrderDlvyChrgOverride ,
        COALESCE(oi.PurchaseStatusID,ii.PurchaseStatusID) as [PurchaseStatusID]

 
   FROM [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[FactSales] sdt 
	    INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimSalesPerson] sp
            ON sdt.SalesPersonKey = sp.SalesPersonKey
	    INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimStoreLocation] lm
            ON lm.LocationKey = sdt.LocationKey
	    INNER JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimCustomerMaster] cm 
            ON cm.CustomerKey = sdt.CustomerKey
   
        --Get Delivery Charge Overrides
        LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Orders] o
            ON o.OrderID = sdt.OrderID
        LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Invoice] i 
            ON i.OrderID = sdt.OrderID
        -- Get PurchaseStatusID
        LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Invoice] i2 
            ON i.Base_OrderID = i2.OrderID
        LEFT JOIN [$(Source_Data)].[Retail_Corporate].[InvoiceItem] ii 
            ON ii.OrderID = i2.OrderID 
            AND ii.ItemID = sdt.ItemID

        -- Get  PurchaseStatusID (use as default)
        LEFT JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] oi 
            ON  oi.OrderID  =sdt.OrderID  
            AND  oi.ItemID = sdt.ItemID 

        -- Get for Product/Group Attributes
        LEFT JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimProduct] pm 
            ON pm.ProductKey = sdt.ProductKey
        LEFT JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimGroupMaster] gm 
            on pm.GroupID = gm.GroupID
        LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Product] pr 
            ON pr.ProductID = COALESCE(ii.ProductID, oi.ProductID)
   	    LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Groups] grp 
            on grp.GroupID = pr.GroupID

	WHERE sdt.TransCodeID <> 3
          AND sdt.TransDateKey Between  @FromDateInt and @ToDateInt
          --and COALESCE(pm.SKU, pr.ProductID) is null
),

-- Get Issue Flags
CTE_Flags AS (
    SELECT  oc.RecordID   as OrderID,
        MAX(CASE WHEN Comment LIKE 'Payment Type %'                   THEN 1 ELSE 0 END) as [PaymentTypeIssue],
        MAX(CASE WHEN Comment LIKE '% is not valid %'                 THEN 1 ELSE 0 END) as [IsNotValidIssue],
        MAX(CASE WHEN Comment LIKE '%The minimum deposit amount of%'  THEN 1 ELSE 0 END) as [MinimumDepositIssue],
        MAX(CASE WHEN Comment LIKE '%The minimum purchase amount of%' THEN 1 ELSE 0 END) as [MinimumPurchaseIssue]

        FROM
        [$(Source_Data)].[Retail_Corporate].[OrderComments] oc

        INNER JOIN [$(Source_Data)].[Retail_Miniapps].[CommentsSearchMatches] m
            ON m.CommentsID = oc.CommentsID AND m.SearchSettingID = 1
            WHERE
                    oc.SourceID = '01'
                AND oc.RecStatus <> 'D'

        GROUP BY oc.RecordID
),

--- Get Management Override Approvals
CTE_Approvals AS (
        SELECT OrderID, Max(DelChrgExcptnMgrApproval) as DelChrgExcptnMgrApproval
             FROM (
              SELECT oc.RecordID as OrderID  ,
                     DelChrgExcptnMgrApproval=1

                FROM [$(Source_Data)].[Retail_Corporate].[OrderComments] oc
                    INNER JOIN [$(Source_Data)].[Retail_Corporate].[Staff] s
                        ON s.StaffID = oc.StaffID   --- Manager entered Comment
                            OR  --- Delegated Manager Approval, manager's StaffID would be in the comment field
                           s.StaffID = TRIM(REPLACE(SUBSTRING(Comment, CHARINDEX('by user ', Comment) + LEN('by user '), LEN(Comment)), '.', ''))
                            OR  --- Match approving manager by name (fallback)
                           s.[Name] = TRIM(REPLACE(SUBSTRING(Comment, CHARINDEX('by user ', Comment) + LEN('by user '), LEN(Comment)), '.', ''))

                WHERE
                    oc.SourceID = '01'
                    AND oc.RecStatus <> 'D'
                    AND Comment LIKE '%Override%'
                    AND Comment LIKE '%delivery charge%'
                    AND StaffTypeID = 'STRMGR'  -- Store Manager
                 ) AppComments
             GROUP BY OrderID
),

--- Get Finance Data
CTE_fin_base AS (
   SELECT
        [OrderID],
        [SalespersonID],
        SUM([Payments]) AS Payments,
        SUM([FinanceFees]) AS FinanceFees,
        pt.Months
    FROM [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[FactPayments] ptc
        LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[PaymentTypeExt] pt
            ON pt.TypeID = ptc.PaymentTypeID
    WHERE
        -- Filter for finance payment transactions only
        ptc.SalesDataTypeKey = 5
        AND ptc.IsFinanced = 1
        AND ptc.TransDate BETWEEN @FromDate AND @ToDate
        AND ptc.SalespersonID NOT IN ('HOU','ZZZ','APM','ASHC')     -- Exclude system/test salesperson ID
    GROUP BY
        ptc.OrderID,
        ptc.SalespersonID,
        pt.Months
    HAVING
        -- Only include orders with meaningful payment amounts
        ABS(SUM(ptc.Payments)) > 0.02
),

CTE_fin AS (
   SELECT
       OrderID,
       SalesPersonID,
       -- Categorize financing terms based on longest term in the order
        CASE
            WHEN MAX(Months) >= 48 THEN 'long'   -- 48+ months = Long term financing
            WHEN MAX(Months) > 12  THEN 'mid'    -- 13-47 months = Mid term financing
            ELSE 'short'                         -- =12 months = Short term financing
        END AS TermsCategory,
        --SUM([Payments]) AS Payments,
        SUM([FinanceFees]) AS FinanceFees
    FROM CTE_fin_base f
    GROUP BY
        f.OrderID,
        f.SalesPersonID
)

--- Return Results
SELECT
      Orders.[SourceDataID],
      Orders.[OrderID],
      Orders.[ItemID],
      Orders.[TransDateKey],
      Orders.[TransDate],
      Orders.[OrderDate],
      Orders.[TransCodeID],
      Orders.[ProductID],
      Orders.[ProductName],
      Orders.[VendorID],
      Orders.[SubGroupID],
      Orders.[SalesPersonID],
      Orders.[CustomerID],
      Orders.[Address1],
      Orders.[Address2],
      Orders.[CustomerName],
      Orders.[SalesPersonName],
      Orders.[HomeStore],
      Orders.[CategoryID],
      Orders.[GroupID],
      RIGHT('000'+Orders.[StoreID],3) AS StoreID,
      Orders.[StoreName],
      Orders.[OwnerGroup],
      Orders.[AsIsReasonCodeID],
      Orders.[WrittenSales],
      Orders.[WrittenCost],
      Orders.[WrittenUnits],
      Orders.[WrittenTaxes],
      Orders.[WrittenCharges],
      Orders.[WrittenRebates],
      Orders.[DeliveredSales],
      Orders.[DeliveredCost],
      Orders.[DeliveredUnits],
      Orders.[DeliveryStatus],
      Orders.[ProdDiscntCode],
      Orders.[PriceVarianceExceptionReasonCodeID],
      Orders.[CustomerLastName],
      Orders.[SalesDataTypeKey],
      Orders.[InvSubBucketID],
      Orders.[PurchaseStatusID] ,
      Flags.[PaymentTypeIssue],
      Flags.[IsNotValidIssue],
      Flags.[MinimumDepositIssue],
      Flags.[MinimumPurchaseIssue],
      Orders.InvoiceDlvyChrgOverride,
      Orders.OrderDlvyChrgOverride,
      Approvals.DelChrgExcptnMgrApproval,
      Finance.FinanceFees,
      Finance.TermsCategory

  FROM CTE_WrkOrders Orders


        --- Get Non-Compliant flags
            LEFT JOIN CTE_Flags flags
               ON Orders.OrderID = flags.OrderID

        --- Get Delivery Charge Exception Manager Overide Approvals
           LEFT JOIN CTE_Approvals Approvals
               ON Approvals.OrderID = Orders.[OrderID]

        -- Get Terms category
        LEFT JOIN CTE_fin Finance
            ON Finance.OrderID = Orders.OrderID
             AND Finance.SalesPersonID = Orders.SalesPersonID
    WHERE Orders.ProductID is not null