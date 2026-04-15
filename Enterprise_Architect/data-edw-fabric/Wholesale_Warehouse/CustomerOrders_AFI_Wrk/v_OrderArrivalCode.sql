CREATE VIEW [CustomerOrders_AFI_Wrk].[v_OrderArrivalCode] ---EXTORD
AS
SELECT  [oacOacode]
      ,[oacOadesc]
      ,[oacOatype]
      ,[oacSequenceNum]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[acrec]
      ,[oacModeGroup]
  FROM [$(Source_Data)].[Wholesale_Codis_AFI].[OrderArrivalCode]