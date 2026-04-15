CREATE TABLE [Retail_Corporate].[Leads] (

	[Operation] char(5) NULL, 
	[LocationId] varchar(50) NULL, 
	[SalePersonId] varchar(50) NULL, 
	[LeadName] varchar(75) NULL, 
	[Email] varchar(250) NULL, 
	[CustomerId] varchar(50) NULL, 
	[PhoneNumber] varchar(50) NULL, 
	[RelationshipId] varchar(50) NULL, 
	[DateCreated] date NULL, 
	[StoriesAppUserId] varchar(50) NULL, 
	[CartId] varchar(50) NULL, 
	[CartDateCreated] datetime2(6) NULL, 
	[RDateCreated] datetime2(6) NULL, 
	[CartUpdated] date NULL, 
	[DateUpdated] datetime2(6) NULL
);