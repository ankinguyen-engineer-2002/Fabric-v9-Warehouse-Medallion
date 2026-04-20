Create view GeographicData_Wrk.v_StateMaster
as
SELECT [staState]
      ,[staDescrip]
      ,[staCountry]
      ,[staTerrcd]
      ,[staState_fips]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[acrec]
  FROM [$(Source_Data)].MasterData_GeographicData.StateMaster