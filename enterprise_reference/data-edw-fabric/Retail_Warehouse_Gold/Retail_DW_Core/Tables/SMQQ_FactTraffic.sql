CREATE TABLE [Retail_DW_Core].[SMQQ_FactTraffic] (

	[LocationID] varchar(8000) NULL, 
	[TransDate] date NULL, 
	[TransHour] decimal(6,0) NULL, 
	[Traffic] decimal(18,4) NULL, 
	[Hours_Key] varchar(8000) NULL, 
	[Key_Field] varchar(8000) NULL, 
	[Trans_Day_of_Week] varchar(8000) NULL, 
	[Trans_Day_of_Week_Number] int NULL, 
	[Trans_Year] int NULL, 
	[Week_of_Year] int NULL, 
	[WeekNum_of_Year] int NULL, 
	[Start_Stop_Filter] int NULL
);