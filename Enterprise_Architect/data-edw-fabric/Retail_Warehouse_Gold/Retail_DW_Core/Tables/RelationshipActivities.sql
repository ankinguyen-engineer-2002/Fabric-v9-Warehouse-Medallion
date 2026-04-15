CREATE TABLE [Retail_DW_Core].[RelationshipActivities] (

	[Operation] varchar(50) NULL, 
	[RelationshipId] varchar(100) NULL, 
	[FullName] varchar(255) NULL, 
	[Email] varchar(320) NULL, 
	[PhoneNumber] varchar(50) NULL, 
	[CartId] varchar(100) NULL, 
	[StaffIDs] varchar(500) NULL, 
	[LocationId] int NULL, 
	[CustomerId] varchar(100) NULL, 
	[LastActivity] datetime2(6) NULL, 
	[LeadLastActivity] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[DateModified] datetime2(6) NULL, 
	[StaffId] varchar(100) NULL
);