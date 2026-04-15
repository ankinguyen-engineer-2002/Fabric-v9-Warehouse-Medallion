CREATE     VIEW [PowerBI_Retail_Wrk].[v_CoSales_VIPCustCommLog]
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
	  ,es.SupervisorFullName AS Agent_SupervisorName
	  ,ed.SupervisorFullName AS DirectorName
	  ,CASE WHEN (o.SourceOrderID IS NOT NULL AND i.BaseOrderID IS NULL) THEN 'Open'
		  	WHEN (o.SourceOrderID IS NOT NULL AND i.BaseOrderID IS NOT NULL) THEN 'Partial'
			WHEN (o.SourceOrderID IS NULL AND i.BaseOrderID IS NOT NULL) THEN 'Completed'
			WHEN (o.SourceOrderID IS NULL AND i.BaseOrderID IS NULL) THEN 'Deleted'
			ELSE NULL
		END AS OrderStatus
  FROM [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog] l 
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog_MasterData] r 
    ON r.MasterDataID = l.Results AND r.Type = 'Results'
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog_MasterData] n 
    ON n.MasterDataID = l.NATCRCode AND n.Type = 'NotATrueCancellationRequest'
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog_MasterData] c 
    ON c.MasterDataID = l.ReasonIfCancelled AND c.Type = 'ReasonIfCancelled'
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog_MasterData] rf 
    ON rf.MasterDataID = l.RequestFrom AND rf.Type = 'RequestFrom'
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog_MasterData] sd 
    ON sd.MasterDataID = l.StatusOfDelivery AND sd.Type = 'StatusOfDelivery'
  LEFT JOIN (SELECT MasterDataID, Value AS ReasonCodeDrillDown
             FROM [$(Source_Data)].[Retail_Miniapps].[VIPCustCommLog_MasterData] 
			 WHERE Type IN ('ReasonCodeDrillDown41', 'ReasonCodeDrillDown44', 'ReasonCodeDrillDown54')) dd 
    ON dd.MasterDataID = l.SubCategReasonIfCancelled
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[Portal_Users] pu 
    ON pu.user_id = l.IssueLastCompletedBy
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[Portal_Users] pu2 
    ON pu2.user_id = l.IssueLoggedBy
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[StoreManagers] sm 
    ON sm.Store = l.LocationID
  LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[PeopleRecords] pr 
    ON pr.PeopleID = pu.People_ID
LEFT JOIN [$(Databricks)].[masterdata_hr_ukg_dsg].[employeesupervisor] es 
  ON RIGHT('000000000' + ISNULL(es.EmployeeNumber, ''), 9) = pr.EmployeeNumber
  LEFT JOIN [$(Databricks)].[masterdata_hr_ukg_dsg].[employeesupervisor] ed 
    ON ed.EmployeeNumber = es.SupervisorEmployeeNumber
  LEFT JOIN [Retail_DW_Core].[FactOrderDetail] o 
    ON o.SourceOrderID = l.[SalesOrder] AND o.LineStatus = 'Written'
  LEFT JOIN [Retail_DW_Core].[FactOrderDetail] i 
    ON i.BaseOrderID = l.[SalesOrder] AND i.LineStatus = 'Invoiced'
  WHERE ISNULL(l.RowDeleted, 0) = 0
    AND Results IS NOT NULL and l.LocationID not LIKE '%[a-zA-Z]%';