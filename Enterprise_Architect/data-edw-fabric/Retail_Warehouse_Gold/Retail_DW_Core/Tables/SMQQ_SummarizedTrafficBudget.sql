CREATE TABLE [Retail_DW_Core].[SMQQ_SummarizedTrafficBudget] (

	[LocationID] varchar(8000) NULL, 
	[Act_Traffic_Last_3_Months] decimal(18,2) NULL, 
	[Bud_Traffic_Last_3_Months] decimal(18,4) NULL, 
	[Bud_Traffic_Next_3_Months] decimal(18,4) NULL, 
	[RSA_Hours_Last_3_Months] int NULL, 
	[RSA_Hours_per_Week_Last_3_Months] int NULL, 
	[FT_RSAs] int NULL, 
	[FT_RSAs_LOA] int NULL, 
	[PT_RSAs] int NULL, 
	[PT_RSAs_LOA] int NULL, 
	[Current_Headcount] int NULL
);