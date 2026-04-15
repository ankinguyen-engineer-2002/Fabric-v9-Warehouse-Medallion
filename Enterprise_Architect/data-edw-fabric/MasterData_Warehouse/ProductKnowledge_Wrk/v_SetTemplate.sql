CREATE view ProductKnowledge_Wrk.v_SetTemplate
as
SELECT [stpTemplateId]
      ,[stpDescr]
      ,[stpRanking]
      ,[stpSort]
      ,[stpShortDescr]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
  FROM [$(Databricks)].[masterdata_productknowledge].[settemplate]