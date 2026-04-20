CREATE TABLE [Retail_Corporate].[OpportunityStage] (

	[Operation] varchar(15) NULL, 
	[Color] varchar(50) NULL, 
	[CreatedAt] datetime2(6) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[Description] varchar(50) NULL, 
	[IsActive] bit NULL, 
	[OpportunityStageId] varchar(50) NULL, 
	[RecStatus] varchar(1) NULL, 
	[SortOrder] int NULL, 
	[Status] varchar(50) NOT NULL, 
	[UpdatedAt] datetime2(6) NOT NULL
);