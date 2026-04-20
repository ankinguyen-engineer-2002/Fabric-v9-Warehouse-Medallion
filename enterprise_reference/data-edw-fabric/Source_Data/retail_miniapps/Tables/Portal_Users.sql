CREATE TABLE [Retail_Miniapps].[Portal_Users] (

	[Operation] char(5) NULL, 
	[user_id] varchar(15) NOT NULL, 
	[user_name] varchar(50) NULL, 
	[user_pwd] varchar(15) NULL, 
	[user_brand] varchar(15) NULL, 
	[group_id] int NULL, 
	[Location_ID] varchar(10) NULL, 
	[Location_Selector_ID] int NULL, 
	[Employee_Number] varchar(15) NULL, 
	[People_ID] int NULL, 
	[user_type] int NULL, 
	[active_status] bit NULL, 
	[ChangedBy] varchar(10) NULL, 
	[ChangedDate] datetime2(6) NULL, 
	[CreatedBy] varchar(10) NULL, 
	[CreatedDate] datetime2(6) NULL, 
	[WindowsUserName] varchar(100) NULL, 
	[EmailAddress] varchar(100) NULL, 
	[NetUserIdentityName] varchar(100) NULL, 
	[last_login_date] datetime2(6) NULL
);