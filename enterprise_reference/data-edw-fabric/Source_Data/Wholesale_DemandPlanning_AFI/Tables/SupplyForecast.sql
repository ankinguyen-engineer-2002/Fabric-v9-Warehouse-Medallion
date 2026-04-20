CREATE TABLE [Wholesale_DemandPlanning_AFI].[SupplyForecast] (

	[FCST_1_ID] varchar(40) NULL, 
	[FCST_2_ID] varchar(40) NULL, 
	[FCST_YR_PRD] decimal(6,0) NOT NULL, 
	[FCST_RSLT_QTY] decimal(9,0) NOT NULL, 
	[PROMO_LIFT_QTY] decimal(9,0) NOT NULL, 
	[usra] varchar(40) NULL, 
	[dtea] datetime2(6) NULL
);