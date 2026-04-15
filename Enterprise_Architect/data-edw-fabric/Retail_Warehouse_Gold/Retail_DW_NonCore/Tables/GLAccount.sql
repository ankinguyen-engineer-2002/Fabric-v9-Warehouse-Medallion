CREATE TABLE [Retail_DW_NonCore].[GLAccount] (

	[Operation] varchar(10) NULL, 
	[DateChanged] datetime2(3) NULL, 
	[DateCreated] datetime2(3) NULL, 
	[Description] varchar(255) NULL, 
	[GLAccountID] varchar(50) NULL, 
	[GLAccountTypeID] varchar(10) NULL, 
	[GLClassID] varchar(10) NULL, 
	[GLCostCenterID] varchar(50) NULL, 
	[GLGroupID] varchar(50) NULL, 
	[GLSubAccountID] varchar(10) NULL, 
	[GLSubClassID] varchar(10) NULL, 
	[IsInactive] bit NULL, 
	[LastBatchID] int NULL, 
	[Parent_GLAccountID] varchar(50) NULL, 
	[RecStatus] varchar(10) NULL, 
	[Root_GLAccountID] varchar(50) NULL, 
	[SourceID] int NULL
);