CREATE TABLE [MasterData_HR_UKG_Enh].[Jobs] (

	[JobKey] int NOT NULL, 
	[DataSource] varchar(5) NOT NULL, 
	[JobCode] varchar(50) NULL, 
	[JobTitle] varchar(100) NULL, 
	[IsActive] bit NULL, 
	[JobFamilyCode] varchar(50) NULL, 
	[LongDescription] varchar(100) NULL
);