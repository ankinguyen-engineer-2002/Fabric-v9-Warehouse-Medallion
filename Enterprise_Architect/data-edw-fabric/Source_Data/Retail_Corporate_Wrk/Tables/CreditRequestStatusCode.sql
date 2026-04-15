CREATE TABLE [Retail_Corporate_Wrk].[CreditRequestStatusCode] (

	[Operation] varchar(15) NULL, 
	[CreditRequestStatusCodeID] int NOT NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[Description] varchar(255) NULL, 
	[IsCompleteCode] bit NULL, 
	[LastBatchID] int NULL, 
	[ReasonRequired] bit NULL, 
	[RecStatus] char(1) NULL, 
	[ShortDescription] varchar(100) NULL, 
	[SourceID] varchar(50) NOT NULL
);