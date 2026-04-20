CREATE TABLE [Retail_DW_Core].[DimGroupMaster] (

	[GroupKey] bigint NOT NULL, 
	[GroupID] varchar(50) NOT NULL, 
	[CategoryID] varchar(40) NOT NULL, 
	[CategoryDescription] varchar(50) NULL, 
	[GroupDescription] varchar(50) NULL, 
	[FamilyName] varchar(50) NULL, 
	[PrimaryCategory] int NOT NULL, 
	[DefaultPPPGroupID] varchar(50) NULL, 
	[Cubes] decimal(18,10) NULL
);