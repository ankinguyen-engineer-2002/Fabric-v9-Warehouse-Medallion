CREATE TABLE [Retail_DW_Core].[LeadAppointments] (

	[LocationId] int NULL, 
	[SalePersonID] varchar(100) NULL, 
	[user_name] varchar(255) NULL, 
	[ApptType] varchar(255) NULL, 
	[Subject] varchar(500) NULL, 
	[Status] varchar(50) NULL, 
	[DateCreated] date NULL, 
	[DueDate] date NULL, 
	[ActivityId] varchar(100) NULL, 
	[RelationshipId] varchar(100) NULL, 
	[Email] varchar(320) NULL, 
	[CustomerId] varchar(100) NULL, 
	[CustomerName] varchar(255) NULL
);