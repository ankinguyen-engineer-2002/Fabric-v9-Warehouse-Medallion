CREATE TABLE [Retail_Corporate_Wrk].[ReasonCode] (

	[Operation] varchar(15) NULL, 
	[CommCategory] varchar(20) NULL, 
	[CompanyID] varchar(50) NOT NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[Description] varchar(255) NULL, 
	[FloorSampleFlg] int NULL, 
	[LastBatchID] int NULL, 
	[MasterReasonCodeID] varchar(50) NULL, 
	[NonSellable] bit NULL, 
	[NotInLocnFlg] int NULL, 
	[ReasonCodeID] varchar(50) NOT NULL, 
	[ReasonType] varchar(20) NULL, 
	[ReceivableAccountStatus] varchar(50) NULL, 
	[RecStatus] char(1) NULL, 
	[RevolvingBalanceAdj_GLAccountID] varchar(50) NULL, 
	[SourceID] varchar(50) NOT NULL
);