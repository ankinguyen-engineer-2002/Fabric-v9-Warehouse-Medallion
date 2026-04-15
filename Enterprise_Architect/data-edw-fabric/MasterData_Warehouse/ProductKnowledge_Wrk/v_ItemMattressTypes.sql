CREATE view ProductKnowledge_Wrk.v_ItemMattressTypes
as
SELECT [imtItemNumber]
      ,[imtMattressType]
  FROM [$(Databricks)].[masterdata_productknowledge].[itemmattresstypes]