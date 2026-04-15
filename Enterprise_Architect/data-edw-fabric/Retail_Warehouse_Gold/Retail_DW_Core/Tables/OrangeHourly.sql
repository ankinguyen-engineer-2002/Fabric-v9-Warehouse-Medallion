CREATE TABLE [Retail_DW_Core].[OrangeHourly] (

	[storelocation] varchar(255) NULL, 
	[locationkey] int NOT NULL, 
	[Division] varchar(50) NULL, 
	[HSType] varchar(9) NOT NULL, 
	[sls] decimal(38,2) NULL, 
	[socount] decimal(38,2) NULL, 
	[sls_other] decimal(38,4) NULL, 
	[wrtsls_Fpp] decimal(38,2) NULL, 
	[wrtsls_Bedding] decimal(38,2) NULL, 
	[wrtcogs] decimal(38,2) NULL, 
	[DerivedUps] decimal(38,4) NULL, 
	[Recorded_Guest] int NULL, 
	[wrtslsBud] decimal(38,4) NULL, 
	[wrtslsotherBud] decimal(38,4) NULL, 
	[wrtsoBud] decimal(38,9) NULL, 
	[wrtcogsBud] decimal(38,4) NULL, 
	[DerivedUpsBud] decimal(18,4) NULL, 
	[CloseGoal] decimal(38,9) NULL, 
	[SaleCountGoal] decimal(38,6) NULL, 
	[CompLocation] varchar(3) NOT NULL, 
	[FinApp] int NULL
);