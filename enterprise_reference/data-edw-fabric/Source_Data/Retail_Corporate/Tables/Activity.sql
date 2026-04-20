CREATE TABLE [Retail_Corporate].[Activity] (

	[Operation] char(5) NULL, 
	[ActivityId] varchar(50) NOT NULL, 
	[ActivityStageId] varchar(50) NULL, 
	[CreatedAt] datetime2(6) NOT NULL, 
	[CreatedByAppId] varchar(50) NULL, 
	[CreatedBySource] varchar(50) NULL, 
	[CreatedByStorisAppUserId] varchar(50) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[DueDate] datetime2(6) NOT NULL, 
	[IsOverDue] bit NOT NULL, 
	[RecStatus] char(1) NOT NULL, 
	[RelationshipId] varchar(50) NULL, 
	[StorisAppUserId] varchar(50) NULL, 
	[Subject] varchar(250) NOT NULL, 
	[UpdatedAt] datetime2(6) NOT NULL
);