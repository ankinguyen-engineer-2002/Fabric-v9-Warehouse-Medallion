CREATE VIEW [GeographicData_Wrk].[v_MSA_Master]
AS
SELECT
	[msaFips], 
	[msaDesc], 
	[Usra], 
	[Dtea], 
	[Usrc], 
	[Dtec], 
	[Acrec]
  
FROM [$(Source_Data)].MasterData_GeographicData.[MSAMaster]  
