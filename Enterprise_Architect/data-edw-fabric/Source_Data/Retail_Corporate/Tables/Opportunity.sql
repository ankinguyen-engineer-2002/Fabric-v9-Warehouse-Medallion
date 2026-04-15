CREATE TABLE [Retail_Corporate].[Opportunity] (

	[Operation] varchar(15) NULL, 
	[CreatedAt] datetime2(6) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateClosed] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[Description] varchar(1500) NULL, 
	[ExpectedClose] datetime2(6) NULL, 
	[ExpectedValue] numeric(38,6) NULL, 
	[IsNewCustomer] bit NULL, 
	[IsReferred] bit NULL, 
	[LastActivity] datetime2(6) NULL, 
	[OpportunityId] varchar(50) NOT NULL, 
	[OpportunityProjectTypeId] varchar(50) NULL, 
	[OpportunityStageId] varchar(50) NOT NULL, 
	[OrderId] varchar(50) NULL, 
	[RecStatus] varchar(1) NOT NULL, 
	[RelationshipId] varchar(50) NULL, 
	[StorisAppUserId] varchar(50) NULL, 
	[Subject] varchar(250) NULL, 
	[UpdatedAt] datetime2(6) NULL
);