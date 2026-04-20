CREATE TABLE [MasterData_HR_UKG_DSG_Wrk].[TAPayCodeMap] (

	[SourceSystemID] int NOT NULL, 
	[SourcePayCodeID] varchar(10) NOT NULL, 
	[PayCodeID] int NOT NULL, 
	[PayCodeName] varchar(50) NULL, 
	[PayCodeType] int NULL
);