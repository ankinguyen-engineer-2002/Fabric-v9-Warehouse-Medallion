CREATE TABLE [Retail_Miniapps].[BudgetDaily] (

	[OperationName] varchar(10) NOT NULL, 
	[Store] varchar(5) NOT NULL, 
	[strwd] varchar(1) NOT NULL, 
	[Sls_date] datetime2(6) NOT NULL, 
	[grp] varchar(10) NOT NULL, 
	[bgt_sales] float NULL, 
	[bgt_gm] float NULL, 
	[bgt_fees] float NULL, 
	[BudgetID] int NULL, 
	[bgt_sales_2] float NULL, 
	[bgt_fees_2] float NULL, 
	[bgt_sales_1] float NULL, 
	[bgt_fees_1] float NULL
);