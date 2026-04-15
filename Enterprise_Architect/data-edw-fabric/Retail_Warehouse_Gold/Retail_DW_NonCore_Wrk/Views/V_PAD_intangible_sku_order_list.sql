-- Auto Generated (Do not modify) 49DA9D85A34818C2AF9CAC96935834E42CB20E9D29AAB11FFB1818062C8BA495
CREATE   VIEW [Retail_DW_NonCore_Wrk].[V_PAD_intangible_sku_order_list] AS (SELECT orderOrderID                   AS OrderID
	,OrderType						  AS OrderType
     , orderOrderBookedStoreID        AS StoreID
	 ,(SELECT s.Name FROM [$(Source_Data)].[Retail_Corporate].[Store] s WHERE s.StoreID =orderOrderBookedStoreID) StoreName
     , orderDlvyStoreID               AS DC
	 ,(SELECT s.Name FROM [$(Source_Data)].[Retail_Corporate].[Store] s WHERE s.StoreID =orderDlvyStoreID) orderDlvyStoreNM
     , CAST(orderDateCreated AS DATE) AS OrderDate
	 , GroupID, CategoryID, ProductID
	 , ProductDesc
	 ,CaseSellingPrice
	 --,OtherItems
	 --,invoiced
	 --,invoicedIntangible
FROM
(
    SELECT o.OrderID            orderOrderID 
		, tc.Description OrderType
         , o.DlvyStoreID        orderDlvyStoreID
         , o.OrderBookedStoreID orderOrderBookedStoreID
         , o.DateCreated        orderDateCreated
		 , oi.GroupID
		 , oi.CategoryID
		 , oi.ProductID
		 , oi.ProductDesc
		 ,oi.CaseSellingPrice
         , (
               SELECT COUNT(1)
               FROM [$(Source_Data)].[Retail_Corporate].[OrderItem] ooi
               WHERE ooi.OrderID = o.OrderID
			   AND ooi.RecStatus <> 'D'
			   AND ooi.GroupID NOT IN ('MSI','XFI')
           ) OtherItems
         , (
               SELECT COUNT(1)
               FROM [$(Source_Data)].[Retail_Corporate].[Invoice] v
               WHERE v.Base_OrderID = o.OrderID
			   AND v.RecStatus <> 'D'
                     --AND v.DeliveryOrderFulfillmentID IS NOT NULL
           )                    invoiced
         , (
               SELECT COUNT(1)
               FROM [$(Source_Data)].[Retail_Corporate].[Invoice] v INNER JOIN [$(Source_Data)].[Retail_Corporate].[InvoiceItem] vi ON v.OrderID = vi.OrderID
               WHERE v.Base_OrderID = o.OrderID
			   AND v.RecStatus <> 'D'
                     --AND v.DeliveryOrderFulfillmentID IS NOT NULL
           ) invoicedIntangible

    FROM [$(Source_Data)].[Retail_Corporate].[Orders] o
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] oi ON o.OrderID = oi.OrderID
        INNER JOIN [$(Source_Data)].[Retail_Corporate].[TransCode] tc
            ON o.TransCodeID = tc.TransCodeID
    WHERE 1 = 1
          AND o.RecStatus <> 'D' --OPEN PART
			AND oi.GroupID IN ('MSI','XFI')
			AND oi.RecStatus <> 'D'  --OPEN PART
          --AND o.DlvyChrg > 0 --DeliveryCharge pending to collect
) Data
WHERE invoiced > 0 --At leas one invoice with DeliveryOrderFulfillmentID IS NOT NULL
AND Data.OtherItems = 0)