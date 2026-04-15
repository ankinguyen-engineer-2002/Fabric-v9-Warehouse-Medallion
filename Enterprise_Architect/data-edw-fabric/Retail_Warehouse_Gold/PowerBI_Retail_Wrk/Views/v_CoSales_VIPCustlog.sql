-- Auto Generated (Do not modify) 7687025261B1B6565A5D9DDC8F70B0762B899A1932DA40BE9444F2A0D557B8A6
CREATE    VIEW [PowerBI_Retail_Wrk].[v_CoSales_VIPCustlog]
AS
SELECT DISTINCT
	   l.ID
      ,l.SalesOrder
	  ,l.LocationID
      ,l.CustomerID
      ,UPPER(l.CustomerFirstName) AS CustomerFirstName
      ,UPPER(l.CustomerLastName) AS CustomerLastName
      ,UPPER(l.CustomerFirstName + ' ' + l.CustomerLastName) AS CustomerName
      ,l.CustomerPhoneNumber
      ,l.ReasonForCancellationRequest
      ,l.WhatHasBeenDoneToSaveSale
      ,l.AmountAtRisk
      ,l.AdditionalInformation
	  ,rf.Value AS RequestFrom
      ,r.Value AS IssueStatus
      ,n.Value AS NotATrueCancellationRequest
      ,l.NATCRComment
      ,l.[Followed Date] AS FollowUpDate
      ,l.PendingComment
      ,l.FullOrderSaved
      ,l.PartialSavedAmount
      ,l.Discount
      ,l.AmountOfDiscount
      ,l.FreeDelivery
      ,l.AmountDelivery
      ,l.ProductLocated
      ,l.EarlierDelivery
      ,l.CorrectedOrder
      ,l.PartOrdered
      ,l.ServiceSet
      ,l.Reselected
      ,l.Communication
      ,l.Other
      ,l.OtherComment
      ,l.DiscountAmount
      ,l.AmountSaved
      ,l.OriginalAmount
      ,l.Taxes
      ,c.Value AS ReasonIfCancelled
      ,dd.ReasonCodeDrillDown
      ,sd.Value AS StatusOfDelivery
      ,l.WhyCouldItNotBeSaved
	  ,l.LastCancelledDate
      ,l.CoSalesComments
      ,l.IssueLoggedBy
      ,l.IssueLoggedDate
      ,l.IssueLastCompletedBy AS LastUpdatedBy
      ,l.IssueLastCompletedDate AS LastUpdatedDate
	  ,pu.user_name AS NameLastUpdate
	  ,pu2.user_name AS NameLoggedBy
	  ,sm.DirectorManager
	  ,sm.DistrictManager
	  ,es.SupervisorFullName AS Agent_SupervisorName --pe.SupervisorFullName
	  ,ed.SupervisorFullName AS DirectorName  --pe2.SupervisorFullName
	  -- ,CASE WHEN (o.OrderID IS NOT NULL AND i.Base_OrderID IS NULL) THEN 'Open'
		--   	WHEN (o.OrderID IS NOT NULL AND i.Base_OrderID IS NOT NULL) THEN 'Partial'
		-- 	WHEN (o.OrderID IS NULL AND i.Base_OrderID IS NOT NULL) THEN 'Completed'
		-- 	WHEN (o.OrderID IS NULL AND i.Base_OrderID IS NULL) THEN 'Deleted'
		-- 	ELSE NULL
		-- END AS OrderStatus
  FROM [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog] l 
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog_MasterData] r ON r.MasterDataID = l.Results
											   AND r.Type = 'Results'
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog_MasterData] n ON n.MasterDataID = l.NATCRCode
											   AND n.Type = 'NotATrueCancellationRequest'
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog_MasterData] c ON c.MasterDataID = l.ReasonIfCancelled
											   AND c.Type = 'ReasonIfCancelled'
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog_MasterData] rf ON rf.MasterDataID = l.RequestFrom
											   AND rf.Type = 'RequestFrom'
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog_MasterData] sd ON sd.MasterDataID = l.StatusOfDelivery
											   AND sd.Type = 'StatusOfDelivery'
  LEFT JOIN (SELECT MasterDataID, Value AS ReasonCodeDrillDown
             FROM [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog_MasterData] 
			 WHERE Type IN ('ReasonCodeDrillDown41',
			                'ReasonCodeDrillDown44',
							'ReasonCodeDrillDown54')) dd ON dd.MasterDataID = l.SubCategReasonIfCancelled
  LEFT JOIN [PowerBI_Retail_Wrk].[v_CoSales_PortalUsers] pu ON pu.user_id = l.IssueLastCompletedBy
  LEFT JOIN [PowerBI_Retail_Wrk].[v_CoSales_PortalUsers] pu2 ON pu2.user_id = l.IssueLoggedBy
  LEFT JOIN [PowerBI_Retail_Wrk].[v_CoSales_StoreManagers] sm ON sm.Store = l.LocationID
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[PeopleRecords] pr ON pr.PeopleID = pu.People_ID
  -- LEFT JOIN [PowerBI_Retail_Wrk].[v_CoSales_employeesupervisor] es ON tdg.sfn_EmployeeNumberLongNumber(es.EmployeeNumber) = pr.EmployeeNumber
    LEFT JOIN [PowerBI_Retail_Wrk].[v_CoSales_employeesupervisor] es ON es.EmployeeNumber = pr.EmployeeNumber
  LEFT JOIN [PowerBI_Retail_Wrk].[v_CoSales_employeesupervisor] ed ON ed.EmployeeNumber = es.SupervisorEmployeeNumber

--   LEFT JOIN storis.Orders o  ON o.OrderID = [SalesOrder]
--   LEFT JOIN storis.Invoice i  ON i.Base_OrderID = [SalesOrder]
  WHERE ISNULL(l.RowDeleted,0) = 0
  AND Results IS NOT NULL;