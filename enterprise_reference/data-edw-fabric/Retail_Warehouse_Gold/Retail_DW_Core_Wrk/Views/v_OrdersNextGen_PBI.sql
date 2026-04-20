CREATE       VIEW [Retail_DW_Core_Wrk].[v_OrdersNextGen_PBI]
AS
-- Orders
SELECT [Type], data.OrderBookedStoreID, data.region, data.SalesPersonID, data.OrderDate
  , SUM(data.SP_Def) Def
  , SUM(data.SP_Nextgen) NextGen
  , SUM(data.SP_Total) Total
FROM 
(
    SELECT 'Open Orders' [Type], o.OrderBookedStoreID
   , (SELECT MAX(WHGP) FROM [$(Source_Data)].[Retail_Miniapps].[WHGRP] w INNER JOIN [$(Source_Data)].[Retail_External].[RegionsInfo] r ON r.RegionID = w.WHGP WHERE WHID = o.OrderBookedStoreID) Region
    , o.OrderID, c.SalesPersonID, o.OrderDate  
    , 1.0 / COUNT(1) OVER(PARTITION BY o.OrderBookedStoreID, o.OrderID) SP_Total
    , (IIF(MAX(s.Code) = 'NEXTGEN', (1.0 / COUNT(1) OVER(PARTITION BY o.OrderBookedStoreID, o.OrderID)), 0)) SP_Nextgen
    , (IIF(MAX(s.Code) = 'NEXTGEN', 0, (1.0 / COUNT(1) OVER(PARTITION BY o.OrderBookedStoreID, o.OrderID)))) SP_Def
    FROM [$(Source_Data)].[Retail_Corporate].[Orders] o 
   INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem] i ON o.OrderID = i.OrderID
   INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem_CommissionInfo] c ON c.OrderID = i.OrderID AND c.ItemID = i.ItemID
   INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderSource] s ON o.OrderSourceID = s.OrderSourceID
    WHERE 1=1
    AND o.RecStatus <> 'D'
    AND i.RecStatus <> 'D'
    AND o.TransCodeID IN ('0')
    AND o.OrderDate > CAST(DATEADD(D, -180, GETDATE()) AS DATE)
    AND o.OrderBookedStoreID NOT IN ('101','010','401','939','600','610','176','275')
    AND o.OrderBookedStoreID NOT IN (SELECT WHID FROM [$(Source_Data)].[Retail_Miniapps].[WHGRP] WHERE WHGP = 'DC')
    GROUP BY o.OrderBookedStoreID, o.OrderID, o.OrderDate, c.SalesPersonID
) data 
GROUP BY data.[Type], data.OrderBookedStoreID, data.region, data.SalesPersonID, data.OrderDate

-- Invoices
UNION ALL

SELECT [Type], data.OrderBookedStoreID, data.region, data.SalesPersonID, data.OrderDate
  , SUM(data.SP_Def) Def
  , SUM(data.SP_Nextgen) NextGen
  , SUM(data.SP_Total) Total
FROM 
(
    SELECT 'Invoices' [Type], o.OrderBookedStoreID
    , (SELECT MAX(WHGP) FROM [$(Source_Data)].[Retail_Miniapps].[WHGRP] w INNER JOIN [$(Source_Data)].[Retail_External].[RegionsInfo] r ON r.RegionID = w.WHGP WHERE WHID = o.OrderBookedStoreID) Region
    , o.OrderID, c.SalesPersonID, o.OrderDate  
    , 1.0 / COUNT(1) OVER(PARTITION BY o.OrderBookedStoreID, o.OrderID) SP_Total
    , (IIF(MAX(s.Code) = 'NEXTGEN', (1.0 / COUNT(1) OVER(PARTITION BY o.OrderBookedStoreID, o.OrderID)), 0)) SP_Nextgen
    , (IIF(MAX(s.Code) = 'NEXTGEN', 0, (1.0 / COUNT(1) OVER(PARTITION BY o.OrderBookedStoreID, o.OrderID)))) SP_Def
    FROM [$(Source_Data)].[Retail_Corporate].[Invoice] o 
   INNER JOIN [$(Source_Data)].[Retail_Corporate].[InvoiceItem] i ON o.OrderID = i.OrderID
   INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderItem_CommissionInfo] c ON c.OrderID = i.OrderID AND c.ItemID = i.ItemID
   INNER JOIN [$(Source_Data)].[Retail_Corporate].[OrderSource] s ON o.OrderSourceID = s.OrderSourceID
    WHERE 1=1
    AND o.RecStatus <> 'D'
    AND i.RecStatus <> 'D'
    AND o.TransCodeID IN ('0')
    AND o.OrderDate > CAST(DATEADD(D, -180, GETDATE()) AS DATE)
    AND o.OrderBookedStoreID NOT IN ('101','010','401','939','600','610','176','275')
    AND o.OrderBookedStoreID NOT IN (SELECT WHID FROM [$(Source_Data)].[Retail_Miniapps].[WHGRP] WHERE WHGP = 'DC')
    GROUP BY o.OrderBookedStoreID, o.OrderID, o.OrderDate, c.SalesPersonID
) data 
GROUP BY data.[Type], data.OrderBookedStoreID, data.region, data.SalesPersonID, data.OrderDate
GO

