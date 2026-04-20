Create view ProductKnowledge_Wrk.v_ChildStyleLookup
As
SELECT [cslCode]
      ,[cslDescription]
      ,[cslParentCode]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
  FROM [$(Databricks)].[masterdata_productknowledge].[childstylelookup]