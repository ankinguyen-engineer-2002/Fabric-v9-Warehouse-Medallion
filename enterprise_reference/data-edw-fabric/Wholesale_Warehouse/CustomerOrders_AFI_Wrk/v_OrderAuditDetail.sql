Create VIEW [CustomerOrders_AFI_Wrk].[v_OrderAuditDetail]
As
SELECT 
       [OrderNo]
      ,[ItemNo]
      ,[ItemSequenceNo]
      ,[Quantity]
      ,[NetAmount]
      ,[ItemClass]
	  ,CASE WHEN CAST([PromiseDate] as INT)= 0 THEN NULL ELSE CAST(CAST(CAST([PromiseDate] as INT) AS CHAR(8)) AS DATE) END AS  [ADPRDT]
	  ,CASE WHEN CAST([RequestDate] as INT)= 0 THEN NULL ELSE CAST(CAST(CAST([RequestDate] as INT) AS CHAR(8)) AS DATE) END AS  [ADRQDT]
      ,[QtyDecreaseReason]
      ,[UserIdChanging]
	  ,CASE WHEN CAST([ChangeDate] as INT)= 0 THEN NULL ELSE CAST(CAST(CAST([ChangeDate] as INT) AS CHAR(8)) AS DATE) END AS  [ADCHGD]
      ,[ChangeTime]
      ,[CancRedFlag]
	  ,CASE WHEN CAST([OrderTakenDate] as INT)= 0 THEN NULL ELSE CAST(CAST(CAST([OrderTakenDate] as INT) AS CHAR(8)) AS DATE) END AS  [ADOTDT]
      ,[Freight]
      ,[AdditionalFreight]
      ,[Dicount]
      ,[DFIDiscount]
      ,[AdvertisingAccrual]
      ,[Packageid]
      ,[PacakgedIscAllocationPercentage]
      ,[PackagePrice]
      ,[ItmStatusCodeOrderTime]
      ,[PackageItemPrice]
      ,[PackageItemDiscount]
      ,[KeyAchorItem]
      ,[PackageDescription]
      ,[OrderPriority]
   FROM [$(Source_Data)].[Wholesale_SalesHistory_AFI].[ordaudd]
 




