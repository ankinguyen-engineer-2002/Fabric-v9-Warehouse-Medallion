
Create view Quality_AFI_Wrk.v_DamageCodes
as
SELECT [DSCRCD]
      ,[DSCDSC]
    from [$(Source_Data)].[Wholesale_Quality_AFI].[ASCRDEF]
GO

