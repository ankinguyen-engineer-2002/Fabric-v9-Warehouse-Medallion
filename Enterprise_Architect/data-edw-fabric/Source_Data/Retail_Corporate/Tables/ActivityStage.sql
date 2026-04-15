CREATE TABLE [Retail_Corporate].[ActivityStage] (

	[Operation] char(5) NULL, 
	[ActivityStageId] varchar(50) NOT NULL, 
	[Description] varchar(250) NOT NULL, 
	[Status] varchar(50) NOT NULL, 
	[IsActive] bit NOT NULL, 
	[SortOrder] int NOT NULL, 
	[Color] varchar(50) NULL, 
	[CreatedAt] datetime2(6) NOT NULL, 
	[UpdatedAt] datetime2(6) NOT NULL, 
	[NxtGenBatchId] bigint NOT NULL, 
	[RecStatus] char(1) NOT NULL, 
	[DateCreated] datetime2(6) NULL, 
	[DateChanged] datetime2(6) NULL
);