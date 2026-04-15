CREATE TABLE [Retail_Dart].[RelationshipActivities] (

	[Operation] char(5) NULL, 
	[RelationshipId] varchar(50) NOT NULL, 
	[FullName] varchar(250) NULL, 
	[Email] varchar(250) NULL, 
	[PhoneNumber] varchar(20) NULL, 
	[CartId] varchar(50) NULL, 
	[CustomerId] varchar(50) NULL, 
	[LastActivity] datetime2(6) NULL, 
	[LeadLastActivity] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[DateModified] datetime2(6) NULL, 
	[StaffId] varchar(20) NULL, 
	[StaffIDs] varchar(500) NULL, 
	[LocationId] varchar(20) NULL
);