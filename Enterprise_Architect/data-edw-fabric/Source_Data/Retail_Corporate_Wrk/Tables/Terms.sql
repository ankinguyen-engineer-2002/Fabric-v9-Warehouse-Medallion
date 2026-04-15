CREATE TABLE [Retail_Corporate_Wrk].[Terms] (

	[Operation] varchar(15) NULL, 
	[CompanyID] varchar(50) NOT NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[Description] varchar(255) NULL, 
	[DueDays] int NULL, 
	[LastBatchID] int NULL, 
	[NoPayMonths] int NULL, 
	[NumberOfPayments] int NULL, 
	[POAddendumForm] varchar(10) NULL, 
	[RecStatus] char(1) NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[Terms1Days] int NULL, 
	[Terms1Percent] decimal(18,2) NULL, 
	[Terms2Days] int NULL, 
	[Terms2Percent] decimal(18,2) NULL, 
	[TermsID] varchar(50) NOT NULL, 
	[TPACode] varchar(50) NULL
);