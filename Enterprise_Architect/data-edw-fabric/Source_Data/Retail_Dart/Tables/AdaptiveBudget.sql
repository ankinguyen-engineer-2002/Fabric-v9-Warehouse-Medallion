CREATE TABLE [Retail_Dart].[AdaptiveBudget] (

	[Company] varchar(20) NULL, 
	[GLAccountID] varchar(30) NULL, 
	[GLCostCenterID] varchar(10) NULL, 
	[GLSubAccountID] varchar(20) NULL, 
	[Parent_GLAccountID] varchar(30) NULL, 
	[RecStatus] char(3) NULL, 
	[Root_GLAccountID] varchar(10) NULL, 
	[Period] varchar(10) NULL, 
	[Value] float NULL
);