CREATE TABLE [Retail_DW_Core].[SMQQ_FactTrafficBudget] (

	[LocationID] varchar(8000) NULL, 
	[TransDate] date NULL, 
	[TUGoal] decimal(19,4) NULL, 
	[Year_Field] int NULL, 
	[Week_Ending] date NULL, 
	[Week_of_Year] int NULL, 
	[WeekNum_of_Year] int NULL, 
	[Week_Ending_Location_Key] varchar(8000) NULL, 
	[TransDate_Filter] int NULL, 
	[Key_Field] varchar(8000) NULL, 
	[Start_End_Filter] int NULL, 
	[Quarter_of_Year] varchar(8000) NULL, 
	[Month_of_Year] varchar(8000) NULL, 
	[RSA_Hours] int NULL, 
	[Number_of_RSAs] int NULL, 
	[Display_Field] int NULL, 
	[Traffic] decimal(19,2) NULL, 
	[Hours_per_RSA] int NULL, 
	[Current_Headcount] int NULL
);