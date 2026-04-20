CREATE TABLE [MasterData_Product].[ProductGroup] (

	[CategoryID] varchar(40) NOT NULL, 
	[CategoryDescription] varchar(50) NULL, 
	[GroupID] varchar(50) NOT NULL, 
	[GroupDescription] varchar(50) NULL, 
	[FamilyName] varchar(50) NULL, 
	[PrimaryCategory] int NOT NULL, 
	[DefaultPPPGroupID] varchar(50) NULL, 
	[Cubes] decimal(18,10) NULL
);