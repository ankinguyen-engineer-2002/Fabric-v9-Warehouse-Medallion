CREATE TABLE [Retail_ProfitSystems].[ITEM_PRICING] (

	[item_database] varchar(20) NULL, 
	[item_id] varchar(12) NOT NULL, 
	[item_prc_1] decimal(9,2) NULL, 
	[item_prc_2] decimal(9,2) NULL, 
	[item_prc_3] decimal(9,2) NULL, 
	[item_lst_lnd_cost] decimal(13,3) NULL, 
	[item_bo_cod] char(1) NULL, 
	[item_avg_cost] decimal(13,3) NULL, 
	[item_lst_cost] decimal(13,3) NULL
);