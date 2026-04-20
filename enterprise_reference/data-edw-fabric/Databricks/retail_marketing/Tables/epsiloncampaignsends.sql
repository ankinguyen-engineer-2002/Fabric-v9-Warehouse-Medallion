CREATE TABLE [retail_marketing].[epsiloncampaignsends] (

	[OrgID] varchar(max) NULL, 
	[DeploymentID] varchar(max) NULL, 
	[MessageID] varchar(max) NULL, 
	[CustomerKey] varchar(max) NULL, 
	[SubscriberKey] varchar(max) NULL, 
	[EventDate] datetime2(6) NULL, 
	[Domain] varchar(max) NULL, 
	[StoreBrandID] varchar(max) NULL, 
	[Audience] varchar(max) NULL, 
	[EmailSubject] varchar(max) NULL, 
	[EmailName] varchar(max) NULL, 
	[ServiceTransactionID] varchar(max) NULL
);