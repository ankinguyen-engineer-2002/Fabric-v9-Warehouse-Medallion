create view ProductKnowledge_Wrk.v_ItemStyle
as
SELECT [istStyle]
      ,[istGroup]
      ,[istDescrip]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[acrec]
  FROM [$(Databricks)].[masterdata_productknowledge].[itemstyle]