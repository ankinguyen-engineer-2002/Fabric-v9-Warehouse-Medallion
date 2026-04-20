create view ProductKnowledge_Wrk.v_ParentStyleLookup
as
SELECT [plsCode]
      ,[plsDescription]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
  FROM [$(Databricks)].[masterdata_productknowledge].[parentstylelookup]