CREATE TABLE [Retail_DW_Core].[Leads_v2_LOAD] (

	[LocationId] int NULL, 
	[SalePersonID] varchar(100) NULL, 
	[LeadName] varchar(255) NULL, 
	[email] varchar(320) NULL, 
	[CustomerId] varchar(100) NULL, 
	[PhoneNumber] varchar(50) NULL, 
	[RelationshipId] varchar(100) NULL, 
	[ActivityDate] datetime2(6) NULL, 
	[LastActivity] datetime2(6) NULL, 
	[StorisAppUserId] varchar(100) NULL, 
	[CartId] varchar(100) NULL, 
	[rel_created] datetime2(6) NULL, 
	[staffIds] varchar(500) NULL
);