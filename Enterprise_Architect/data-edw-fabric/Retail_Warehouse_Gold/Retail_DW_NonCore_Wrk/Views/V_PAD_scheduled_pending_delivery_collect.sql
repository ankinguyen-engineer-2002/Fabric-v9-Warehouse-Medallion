-- Auto Generated (Do not modify) EC097348B7692CCB8B5E317B39C1DA76F66105A5CD144B732BD6D74BB7E8465B
CREATE VIEW [Retail_DW_NonCore_Wrk].[V_PAD_scheduled_pending_delivery_collect] AS (-- Scheduled Pending Delivery Collect
SELECT OrderID
     , FulfillmentDate AS [Fulfillment Date]
     , MerchSubTot AS [Merch Subtotal]
     , fullfilmentsDlvyChrg AS [Fulfillment Dlvy Charge]
     , CASE
           WHEN fulOtherSCDNotZeroLatest > 0
                AND fulOtherStatuDlvChrg = 0 THEN
               'Other SCD'
           WHEN fulOtherSCDNotZeroLatest = 0
                AND fulOtherStatuDlvChrg > 0 THEN
               'Other STATUS'
           WHEN fulOtherSCDNotZeroLatest > 0
                AND fulOtherStatuDlvChrg > 0 THEN
               'Other SCD and Other STATUS'
           ELSE
               ''
       END                                                AS Scenario
     , oDlvyChrg AS [Order Dlvy Charge]
     , ISNULL(SumOtherStatus, 0) + ISNULL(sumOtherSCD, 0) AS [Total Delivery Charges]
     , orderDlvyStoreID AS [DC]
     , orderOrderBookedStoreID AS [StoreID]
FROM
(
    SELECT o.OrderID
         , o.DlvyChrg           oDlvyChrg
         , f.OrderFulfillmentID
         , f.FulfillmentMethod
         , f.FulfillmentStatus
         , f.FulfillmentDate
         , f.MerchSubTot
         , f.DlvyChrg           fullfilmentsDlvyChrg
         ------ Other fulfillments in SCD and DlvrChr > 0  and OtherFulfillmentDate < F.FulfillmentDate
         , (
               SELECT COUNT(1)
               FROM [$(Source_Data)].[Retail_Corporate].[OrderFulfillment] fl
               WHERE fl.OrderID = o.OrderID
                     AND fl.RecStatus <> 'D'
                     AND fl.FulfillmentMethod = 'D'
                     AND fl.OrderFulfillmentID <> f.OrderFulfillmentID
                     AND fl.FulfillmentStatus = 'SCD'
                     AND fl.DlvyChrg > 0
                     AND fl.FulfillmentDate > f.FulfillmentDate
           )                    fulOtherSCDNotZeroLatest
         , (
               SELECT SUM(fl.DlvyChrg)
               FROM [$(Source_Data)].[Retail_Corporate].[OrderFulfillment] fl
               WHERE fl.OrderID = o.OrderID
                     AND fl.RecStatus <> 'D'
                     AND fl.FulfillmentMethod = 'D'
                     AND fl.OrderFulfillmentID <> f.OrderFulfillmentID
                     AND fl.FulfillmentStatus = 'SCD'
                     AND fl.DlvyChrg > 0
                     AND fl.FulfillmentDate > f.FulfillmentDate
           )                    sumOtherSCD

         -- Other fulfillments diferent SCD and DlvrChr > 0
         , (
               SELECT COUNT(1)
               FROM [$(Source_Data)].[Retail_Corporate].[OrderFulfillment] fl
               WHERE fl.OrderID = o.OrderID
                     AND fl.RecStatus <> 'D'
                     AND fl.FulfillmentMethod = 'D'
                     AND fl.FulfillmentStatus IN ( 'ASAP', 'CWC', 'EST' )
                     AND fl.DlvyChrg > 0
           )                    fulOtherStatuDlvChrg
         , (
               SELECT SUM(fl.DlvyChrg)
               FROM [$(Source_Data)].[Retail_Corporate].[OrderFulfillment] fl
               WHERE fl.OrderID = o.OrderID
                     AND fl.RecStatus = 'U'
                     AND fl.FulfillmentMethod = 'D'
                     AND fl.FulfillmentStatus IN ( 'ASAP', 'CWC', 'EST' )
                     AND fl.DlvyChrg > 0
           )                    SumOtherStatus
         , o.DlvyStoreID        orderDlvyStoreID
         , o.OrderBookedStoreID orderOrderBookedStoreID
    FROM [$(Source_Data)].[Retail_Corporate].[Orders]                         o
        INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderFulfillment] f
            ON f.OrderID = o.OrderID
               AND f.RecStatus = 'U'
    WHERE 1 = 1
          AND o.RecStatus <> 'D'
          AND f.FulfillmentMethod = 'D'
          AND f.FulfillmentStatus = 'SCD'
          AND o.DlvyChrg > 0
          AND f.DlvyChrg = 0
) dat
WHERE 1 = 1
      AND
      (
          dat.fulOtherSCDNotZeroLatest > 0
          OR fulOtherStatuDlvChrg > 0
      )
)