CREATE TABLE [Retail_Corporate].[GLPost_SUM] (

	[Operation] char(3) NULL, 
	[CompanyID] varchar(50) NOT NULL, 
	[Credit] numeric(19,4) NULL, 
	[Debit] numeric(19,4) NULL, 
	[EndingBalance] numeric(19,4) NULL, 
	[FisPeriod] int NOT NULL, 
	[FisYear] int NOT NULL, 
	[GLAccountID] varchar(50) NOT NULL, 
	[GLClassID] varchar(50) NULL, 
	[GLCostCenterID] varchar(50) NULL, 
	[GLGroupID] varchar(50) NULL, 
	[GLSubAccountID] varchar(50) NULL, 
	[GLSubClassID] varchar(50) NOT NULL, 
	[OpeningBalance] numeric(19,4) NULL, 
	[Parent_GLAccountID] varchar(50) NULL, 
	[Root_GLAccountID] varchar(50) NOT NULL, 
	[SourceID] varchar(50) NOT NULL
);