CREATE TABLE [MasterData_HR_UKG_DSG_Wrk].[TATaskCodeMap] (

	[SourceSystemID] int NOT NULL, 
	[SourceTaskCodeID] varchar(50) NOT NULL, 
	[TaskCodeID] int NOT NULL, 
	[TaskCodeName] varchar(50) NULL, 
	[TaskCodeType] char(4) NULL
);