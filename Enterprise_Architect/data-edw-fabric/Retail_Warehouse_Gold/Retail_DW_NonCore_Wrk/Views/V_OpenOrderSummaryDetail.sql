-- Auto Generated (Do not modify) A83667BBA4567E9702BE12A9B7FD52CEAB4A0BD312F6618220A7E0766F2B7CC3
CREATE   VIEW [Retail_DW_NonCore_Wrk].[V_OpenOrderSummaryDetail] AS
SELECT BODTransDate
,OrderID
,OrderDate
,StoreID
,ShipLocationID
,OrderType
,FulfillmentMethod
,FulfillmentStatus
,ContactStatus
,ContactDate
,FulfillmentDate
,PastDue
,Filled
,CustomerID
,CustomerName
,SalesPerson
,MerchSubTot
,TaxAmt
,DlvyChrg
,TotalFulfilment
,TotalPieces
,ReservedPieces
,TotalCost
,ReservedCost
,TotalSales
,ReservedSales
,TotalVolume
,ReservedVolume
,TotalWeight
,ReservedWeight
 FROM  [$(Retail_Warehouse)].[Retail_OOM_Enh].[OpenOrderSummaryDetail]