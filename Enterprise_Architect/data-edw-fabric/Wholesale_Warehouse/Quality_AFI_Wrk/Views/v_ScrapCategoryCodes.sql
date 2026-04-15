Create view Quality_AFI_Wrk.v_ScrapCategoryCodes
as
  SELECT [QCCSCRAPCODE]
      ,[QCCCATEGORY]
  FROM [$(Source_Data)].[Wholesale_Quality_AFI].[ScrapQualityCategoryCodes]
GO

