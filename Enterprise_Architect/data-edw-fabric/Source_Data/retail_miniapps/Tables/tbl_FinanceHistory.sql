CREATE TABLE [Retail_Miniapps].[tbl_FinanceHistory] (

	[Operation] varchar(50) NOT NULL, 
	[TransDate] date NULL, 
	[StoreID] varchar(5) NULL, 
	[SalesPersonID] varchar(50) NULL, 
	[ApplicationCount] float NULL, 
	[ApprovedCount] float NULL, 
	[ApprovedAmount] float NULL
);