CREATE view ProductKnowledge_Wrk.v_SetApplications
as
SELECT [staSetNumber]
      ,[staApplication]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
  FROM [$(Databricks)].[masterdata_productknowledge].[setapplications]