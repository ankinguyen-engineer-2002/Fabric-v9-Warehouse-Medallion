-- Auto Generated (Do not modify) 5AA1CC24A7FC5C48BF11862D5D42DF75589D72E842B8BEF1EBA1418C8D504966
CREATE   VIEW [Retail_DW_NonCore_Wrk].[V_OpenOrderSummary] AS
SELECT BODTransDate
,StoreID
,ShipLocationID
,OrderType
,FulfillmentMethod
,FulfillmentStatus
,ContactStatus
,ContactDate
,PastDue
,Filled
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
,TotalTaxes
,TotalDeliveryCharges
 FROM [$(Retail_Warehouse)].[Retail_OOM_Enh].[OpenOrderSummary]