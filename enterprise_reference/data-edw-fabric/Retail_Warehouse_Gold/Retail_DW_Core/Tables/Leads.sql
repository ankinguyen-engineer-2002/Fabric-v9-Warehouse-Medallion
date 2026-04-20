CREATE TABLE [Retail_DW_Core].[Leads] (

	[LocationId] int NULL, 
	[SalePersonID] varchar(100) NULL, 
	[LeadName] varchar(255) NULL, 
	[email] varchar(320) NULL, 
	[CustomerId] varchar(100) NULL, 
	[PhoneNumber] varchar(50) NULL, 
	[RelationshipId] varchar(100) NULL, 
	[DateCreated] date NULL, 
	[StorisAppUserId] varchar(100) NULL, 
	[CartId] varchar(100) NULL, 
	[Cart_DateCreated] datetime2(6) NULL, 
	[rDateCreated] datetime2(6) NULL, 
	[Cart_Updated] date NULL, 
	[DateUpdated] datetime2(6) NULL
);