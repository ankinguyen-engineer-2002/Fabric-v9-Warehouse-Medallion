CREATE TABLE [MasterData_Retail_Wrk].[GLPostDetail] (

	[Operation] char(3) NULL, 
	[GLPostID] varchar(50) NULL, 
	[FisYear] int NULL, 
	[DetailID] int NULL, 
	[SourceID] varchar(50) NULL, 
	[RecStatus] char(5) NULL, 
	[GLAccountID] varchar(50) NULL, 
	[Root_GLAccountID] varchar(50) NULL, 
	[Parent_GLAccountID] varchar(50) NULL, 
	[CompanyID] varchar(50) NULL, 
	[GLSubAccountID] varchar(50) NULL, 
	[GLCostCenterID] varchar(50) NULL, 
	[TransDate] date NULL, 
	[GLSourceID] varchar(100) NULL, 
	[Debit] numeric(19,4) NULL, 
	[Credit] numeric(19,4) NULL, 
	[Remark] varchar(1024) NULL, 
	[PostingStatus] varchar(10) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[LastBatchID] int NULL
);