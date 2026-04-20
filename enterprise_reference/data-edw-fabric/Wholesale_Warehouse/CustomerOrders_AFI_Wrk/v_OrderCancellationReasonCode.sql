CREATE VIEW [CustomerOrders_AFI_Wrk].[v_OrderCancellationReasonCode] ---EXTORD
AS
SELECT  [cnlActiveCode]
      ,[cnlReasonCode]
      ,[cnlReasonDescription]
      ,[cnlMaintainDate]
      ,[cnlMaintainTime]
      ,[cnlMaintainUser]
      ,[cnlTrueCancel]
      ,[cnlCancelCategory]
      ,[cnlAvailToAshleyDirect]
      ,[cnlAshleyDirectDesc]
  FROM  [$(Source_Data)].[Wholesale_Codis_AFI].[OrderCancellationReasonCode];