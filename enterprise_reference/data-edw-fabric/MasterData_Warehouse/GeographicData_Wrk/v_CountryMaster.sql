Create view GeographicData_Wrk.v_CountryMaster as
SELECT [ctrCountry]
      ,[ctrDescrip]
      ,[ctrTerrcd]
      ,[ctrEscheduleSession]
      ,[ctrDescartesCntryCd]
      ,[ctrRouteZone]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[acrec]
      ,[ctrCurrencyCode]
      ,[ctrCountryOfOriginShipLabel]
  FROM [$(Source_Data)].MasterData_GeographicData.CountryMaster
  