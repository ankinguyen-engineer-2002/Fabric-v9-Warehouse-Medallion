CREATE view ProductKnowledge_Wrk.v_ItemPublishCodes
as
SELECT [ipcId]
      ,[ipcItnbr]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
  FROM [$(Databricks)].[masterdata_productknowledge].[itempublishcodes]