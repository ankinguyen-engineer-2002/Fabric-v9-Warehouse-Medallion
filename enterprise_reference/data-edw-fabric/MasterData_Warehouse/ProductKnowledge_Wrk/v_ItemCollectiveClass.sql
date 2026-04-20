Create view ProductKnowledge_Wrk.v_ItemCollectiveClass
As
SELECT [itcItemClass]
      ,[itcCollectiveClass]
      ,[clvCollClassDesc]
  FROM [$(Databricks)].[masterdata_productknowledge].[itemcollectiveclass]