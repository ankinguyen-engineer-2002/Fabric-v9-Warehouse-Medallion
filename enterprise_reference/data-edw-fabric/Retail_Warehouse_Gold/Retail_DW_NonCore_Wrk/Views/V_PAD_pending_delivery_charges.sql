-- Auto Generated (Do not modify) 1DEC6E593BC8651CFB63C78D9EF127CC49784DFD29D83E5E51FEB5C0F14DCF52
CREATE VIEW [Retail_DW_NonCore_Wrk].[V_PAD_pending_delivery_charges] AS (SELECT orderOrderID                   AS OrderID
     , orderDlvyStoreID               AS DC
     , orderOrderBookedStoreID        AS StoreID
     , CAST(orderDateCreated AS DATE) AS OrderDate
     , orderDlvyChrg                  AS DeliveryCharge
     , fulOpenDlvyChrgCnt             AS OpenFullfillmentDeliveryCharges
     , invoiceDlvyChrgCnt             AS OpenInvoiceDeliveryCharges
     , invoiceDlvyChrg                AS InvoiceDeliveryCharges
FROM
(
    SELECT o.OrderID            orderOrderID
         , o.DlvyStoreID        orderDlvyStoreID
         , o.OrderBookedStoreID orderOrderBookedStoreID
         , o.DateCreated        orderDateCreated
         , o.DlvyChrg           orderDlvyChrg
         , (
               SELECT COUNT(f.DlvyChrg)
               FROM [$(Source_Data)].[Retail_Corporate].[OrderFulfillment] f
               WHERE f.OrderID = o.OrderID
                     AND f.RecStatus = 'U'
           )                    fulOpenDlvyChrgCnt
         , (
               SELECT COUNT(1)
               FROM [$(Source_Data)].[Retail_Corporate].[Invoice] v
               WHERE v.Base_OrderID = o.OrderID
                     AND v.DeliveryOrderFulfillmentID IS NOT NULL
           )                    invoiceDlvyChrgCnt
         , (
               SELECT SUM(v.DlvyChrg)
               FROM [$(Source_Data)].[Retail_Corporate].[Invoice] v
               WHERE v.Base_OrderID = o.OrderID
                     AND v.DeliveryOrderFulfillmentID IS NOT NULL
           )                    invoiceDlvyChrg
    FROM [$(Source_Data)].[Retail_Corporate].[Orders]             o
        INNER JOIN [$(Source_Data)].[Retail_Corporate].[TransCode] tc
            ON o.TransCodeID = tc.TransCodeID
    WHERE 1 = 1
          AND o.RecStatus <> 'D'
          AND o.DlvyChrg > 0 
) Data
WHERE invoiceDlvyChrgCnt > 0 
)