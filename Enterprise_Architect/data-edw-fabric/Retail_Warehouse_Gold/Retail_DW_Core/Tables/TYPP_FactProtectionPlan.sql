CREATE TABLE [Retail_DW_Core].[TYPP_FactProtectionPlan] (

	[OrderID] varchar(8000) NULL, 
	[LocationID] varchar(8000) NULL, 
	[SalesPersonID] varchar(8000) NULL, 
	[Name] varchar(8000) NULL, 
	[Title] varchar(8000) NULL, 
	[OrderDate] date NULL, 
	[Five_Year] int NULL, 
	[Three_Year] int NULL, 
	[MGR_3YR] int NULL, 
	[ProtectionPlanSold] varchar(8000) NULL, 
	[MGROnlySKU] varchar(8000) NULL
);