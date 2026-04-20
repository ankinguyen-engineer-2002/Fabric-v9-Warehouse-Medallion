CREATE TABLE [Retail_Miniapps].[SPCommissionCategories] (

	[SPCommissionCategoryID] int NULL, 
	[StoreID] varchar(10) NULL, 
	[SalesPersonID] varchar(10) NULL, 
	[CommissionCategory] varchar(10) NULL, 
	[CategoryStartDate] datetime2(6) NULL, 
	[CategoryEndDate] datetime2(6) NULL, 
	[CommissionEndDate] datetime2(6) NULL, 
	[SPClass] int NULL, 
	[CreatedDate] datetime2(6) NULL, 
	[CreatedBy] varchar(10) NULL, 
	[ChangedDate] datetime2(6) NULL, 
	[ChangedBy] varchar(10) NULL
);