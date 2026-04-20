-- Auto Generated (Do not modify) 8D0E4582856E640D5C7AD6C9326D2981623F4A20F10E2EC8694AB44F171C1FF7

CREATE view [Retail_Commissions_Wrk].[v_IncentiveBridgeFeed] AS

	SELECT
		sdt.SourceDataID,
		sdt.OrderID,
		sdt.ItemID,
        sdt.TransDateKey ,
	    cast(cast(sdt.[TransDateKey] as char(8) )as Date) AS TransDate,
	    cast(cast(sdt.OrderDateKey as char(8) )as Date) AS OrderDate, 
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
		RIGHT('000' + lm.StoreID,3) AS StoreID,
		lm.LocationName AS StoreName,
		lm.HomestoreOwnerGroup AS OwnerGroup,
		sdt.AsIsReasonCodeID,
		sdt.DeliveryStatus,
		sdt.ProductDiscountCode AS ProdDiscntCode,
		sdt.PVEReasonCodeID AS PriceVarianceExceptionReasonCodeID,
		cm.LastName AS CustomerLastName,
		sdt.SalesDataTypeKey,
		sdt.InvSubBucketID,
        COALESCE(oi.PurchaseStatusID,ii.PurchaseStatusID) as [PurchaseStatusID],
        Flags.[PaymentTypeIssue],
        Flags.[IsNotValidIssue],
        Flags.[MinimumDepositIssue],
        Flags.[MinimumPurchaseIssue],
        i.DlvyChrgOverride as InvoiceDlvyChrgOverride,  
        o.DlvyChrgOverride as OrderDlvyChrgOverride,     
        Approvals.DelChrgExcptnMgrApproval
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
            LEFT JOIN [$(Source_Data)].Retail_Corporate.[Invoice] i2 
                ON i.Base_OrderID = i2.OrderID
            LEFT JOIN [$(Source_Data)].Retail_Corporate.[InvoiceItem] ii 
                ON ii.OrderID = i2.OrderID 
                AND ii.ItemID = sdt.ItemID

        -- Get  PurchaseStatusID (use as default)
            LEFT JOIN [$(Source_Data)].Retail_Corporate.[OrderItem] oi 
                ON oi.OrderID = sdt.OrderID 
                AND oi.ItemID = sdt.ItemID

        -- Get for Product/Group Attributes
    		LEFT JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimProduct] pm 
               ON pm.ProductKey = sdt.ProductKey
      		LEFT JOIN [$(Retail_Warehouse_Gold)].[Retail_DW_Core].[DimGroupMaster] gm 
               on pm.GroupID = gm.GroupID
            LEFT JOIN [$(Source_Data)].Retail_Corporate.[Product] pr 
               ON pr.ProductID = COALESCE(ii.ProductID, oi.ProductID)
   		    LEFT JOIN [$(Source_Data)].Retail_Corporate.[Groups] grp 
               on grp.GroupID = pr.GroupID


       --- Get Non-Compliant flags    
  
            LEFT JOIN 
  
          (
             SELECT  oc.RecordID   as OrderID,
                MAX(CASE WHEN Comment LIKE 'Payment Type %'                   THEN 1 ELSE 0 END) as [PaymentTypeIssue],
                MAX(CASE WHEN Comment LIKE '% is not valid %'                 THEN 1 ELSE 0 END) as [IsNotValidIssue],
                MAX(CASE WHEN Comment LIKE '%The minimum deposit amount of%'  THEN 1 ELSE 0 END) as [MinimumDepositIssue],
                MAX(CASE WHEN Comment LIKE '%The minimum purchase amount of%' THEN 1 ELSE 0 END) as [MinimumPurchaseIssue]
      
                FROM
                [$(Source_Data)].Retail_Corporate.[OrderComments] oc
             
                INNER JOIN [$(Source_Data)].[Retail_Miniapps].[CommentsSearchMatches] m 
                    ON m.CommentsID = oc.CommentsID AND m.SearchSettingID = 1
                    WHERE 
                         oc.SourceID = '01' 
                     AND oc.RecStatus <> 'D' 
 
                GROUP BY oc.RecordID
                ) flags
                       ON sdt.OrderID = flags.OrderID


           --- Get Delivery Charge Exception Manager Overide Approvals

           LEFT JOIN

          (SELECT OrderID, Max(DelChrgExcptnMgrApproval) as DelChrgExcptnMgrApproval
             FROM (
              SELECT oc.RecordID as OrderID  ,                
                     DelChrgExcptnMgrApproval=1

                FROM [$(Source_Data)].Retail_Corporate.[OrderComments] oc
                    INNER JOIN [$(Source_Data)].Retail_Corporate.[Staff] s 
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

           ) Approvals
           ON Approvals.OrderID = sdt.[OrderID]


	WHERE sdt.TransCodeID <> 3