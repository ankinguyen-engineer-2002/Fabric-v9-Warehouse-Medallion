CREATE TABLE [MasterData_HR_UKG_Enh].[PayCodes] (

	[PayCodeKey] int NOT NULL, 
	[DataSource] varchar(5) NOT NULL, 
	[PayCodeName] varchar(50) NULL, 
	[PayCodeProductivity] varchar(20) NULL, 
	[PayCodeUnit] varchar(10) NULL, 
	[PayCodeType] varchar(10) NULL, 
	[PayCodeVisibleToUser] bit NULL
);