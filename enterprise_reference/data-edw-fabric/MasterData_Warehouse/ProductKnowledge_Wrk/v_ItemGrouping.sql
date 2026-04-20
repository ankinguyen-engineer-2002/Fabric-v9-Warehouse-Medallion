CREATE view ProductKnowledge_Wrk.v_ItemGrouping
as
SELECT [itgSku]
      ,[itgGroupId]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[acrec]
      ,[itgDefaultGroup]
  FROM [$(Databricks)].[masterdata_productknowledge].[itemgrouping]