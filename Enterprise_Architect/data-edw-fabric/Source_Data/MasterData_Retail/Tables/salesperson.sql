CREATE TABLE [MasterData_Retail].[Salesperson] (

	[SalesPersonID] int NULL, 
	[StoreID] int NULL, 
	[SalesPersonName] varchar(256) NULL, 
	[SalesPersonEmailAddress] varchar(64) NULL, 
	[SalesPersonMobilePhoneNumber] varchar(10) NULL, 
	[SalesPersonUserName] varchar(32) NULL, 
	[SalesPersonPassword] varchar(128) NULL, 
	[SalesPersonRole] varchar(32) NULL, 
	[DeletedIND] int NULL, 
	[EmployeeID] varchar(20) NULL
);