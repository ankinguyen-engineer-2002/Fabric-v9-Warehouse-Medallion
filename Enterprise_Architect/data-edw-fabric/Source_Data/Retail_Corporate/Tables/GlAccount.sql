CREATE TABLE [Retail_Corporate].[GLAccount] (

	[Operation] char(3) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[Description] varchar(512) NULL, 
	[GLAccountID] varchar(100) NOT NULL, 
	[GLAccountTypeID] varchar(50) NOT NULL, 
	[GLClassID] varchar(50) NULL, 
	[GLCostCenterID] varchar(50) NULL, 
	[GLGroupID] varchar(50) NULL, 
	[GLSubAccountID] varchar(50) NULL, 
	[GLSubClassID] varchar(50) NOT NULL, 
	[IsInactive] bit NULL, 
	[LastBatchID] int NULL, 
	[Parent_GLAccountID] varchar(50) NULL, 
	[RecStatus] varchar(50) NULL, 
	[Root_GLAccountID] varchar(50) NULL, 
	[SourceID] varchar(50) NOT NULL
);