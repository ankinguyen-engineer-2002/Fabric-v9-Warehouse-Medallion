CREATE VIEW [CustomerOrders_AFI_Wrk].[v_OpenOrderDiscounts]
AS
SELECT 
      [dcoOrderNumber]
      ,[dcoItemSequence]
      ,[dcoDiscountType]
      ,[dcoDiscountAdjustmentCode]
      ,[dcoItemNumber]
     ,[dcoAmount]
      ,[dcoRatioAmount]
      ,[dcoDiscountPercent]
      ,[dcoExceptionID]
      ,[dcoDiscountCode]
      ,[dcoDiscountSalesClass]
  FROM [$(Source_Data)].[Wholesale_Codis_AFI].[dscadjoo]




     