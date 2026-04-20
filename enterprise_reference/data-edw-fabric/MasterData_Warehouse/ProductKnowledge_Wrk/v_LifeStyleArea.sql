CREATE view ProductKnowledge_Wrk.v_LifeStyleArea
as
SELECT [lfaID]
      ,[lfaDescription]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
  FROM [$(Databricks)].[masterdata_productknowledge].[lifestylearea]