 Create view Quality_AFI_Wrk.v_ScrapCodes
as
  SELECT [PSCRCD]
      ,[PSCDSC]
  FROM [$(Source_Data)].[Wholesale_Quality_AFI].[ASCRPRT]
GO

