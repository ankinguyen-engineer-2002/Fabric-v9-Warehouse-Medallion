CREATE TABLE [MasterData_HR_UKG_Enh].[OrgLevel] (

	[OrgLevelKey] int NOT NULL, 
	[DataSource] varchar(5) NOT NULL, 
	[OrgCode] varchar(20) NULL, 
	[OrgDescription] varchar(100) NULL, 
	[IsActive] bit NULL, 
	[OrgLevel] int NULL
);