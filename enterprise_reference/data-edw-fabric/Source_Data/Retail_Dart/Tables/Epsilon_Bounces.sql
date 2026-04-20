CREATE TABLE [Retail_Dart].[Epsilon_Bounces] (

	[OrgID] varchar(50) NOT NULL, 
	[DeploymentID] varchar(50) NULL, 
	[MessageID] varchar(50) NOT NULL, 
	[CustomerKey] varchar(50) NOT NULL, 
	[SubscriberKey] varchar(254) NOT NULL, 
	[EventDate] datetime2(6) NOT NULL, 
	[Domain] varchar(128) NOT NULL, 
	[BounceCategoryID] int NULL, 
	[BounceCategory] varchar(50) NULL, 
	[BounceSubcategoryID] int NULL, 
	[BounceSubcategory] varchar(50) NULL, 
	[BounceTypeID] int NULL, 
	[BounceType] varchar(50) NULL, 
	[SMTPCode] int NULL, 
	[TriggererSendDefinitionObjectID] varchar(36) NULL, 
	[TriggeredSendCustomerKey] varchar(36) NULL, 
	[StoreBrandID] varchar(50) NOT NULL, 
	[Audience] varchar(100) NULL, 
	[ServiceTransactionID] varchar(50) NULL, 
	[ServiceCommunicationID] varchar(50) NULL, 
	[JobID] varchar(50) NULL
);