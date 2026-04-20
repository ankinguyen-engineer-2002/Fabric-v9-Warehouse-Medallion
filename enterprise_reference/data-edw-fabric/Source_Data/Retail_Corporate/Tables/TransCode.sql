CREATE TABLE [Retail_Corporate].[TransCode] (

	[Operation] varchar(15) NULL, 
	[CompanyID] varchar(50) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[Description] varchar(60) NULL, 
	[LastBatchID] int NULL, 
	[RecStatus] char(1) NULL, 
	[SourceID] varchar(50) NULL, 
	[TransCodeID] int NULL
);