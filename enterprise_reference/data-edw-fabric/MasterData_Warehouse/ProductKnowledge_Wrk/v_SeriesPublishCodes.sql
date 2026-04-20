CREATE view ProductKnowledge_Wrk.v_SeriesPublishCodes
as
SELECT [spuId]
      ,[spuSeriesNum]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
  FROM [$(Databricks)].[masterdata_productknowledge].[seriespublishcodes]