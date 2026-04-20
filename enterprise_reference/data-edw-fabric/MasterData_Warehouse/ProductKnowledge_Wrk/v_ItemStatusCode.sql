CREATE view ProductKnowledge_Wrk.v_ItemStatusCode
as
SELECT [iscCode]
      ,[iscDescrip]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[acrec]
      ,[iscMapicsStatus]
      ,[iscStatusDescription]
  FROM [$(Databricks)].[masterdata_productknowledge].[itemstatuscode]