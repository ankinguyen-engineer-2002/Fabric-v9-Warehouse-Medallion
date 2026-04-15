Create view ProductKnowledge_Wrk.v_CatalogImages
As
SELECT [cimSeriesNumber]
      ,[cimImageType]
      ,[cimImageName]
      ,[cimMasterImage]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[cimAcRec]
  FROM [$(Databricks)].[masterdata_productknowledge].[catalogimages]