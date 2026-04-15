CREATE TABLE [Retail_DW_Core].[STGQ_FactTraffic] (

	[LocationID] varchar(8000) NULL, 
	[TransDate] date NULL, 
	[TransHour] decimal(18,4) NULL, 
	[Traffic] decimal(18,4) NULL, 
	[EmployeeHours] int NULL, 
	[RSAsWorking] int NULL, 
	[Hours_Key] varchar(8000) NULL, 
	[Key_Field] varchar(8000) NULL, 
	[Location] varchar(8000) NULL, 
	[RSAs_Working] float NULL, 
	[Trans_Day_of_Week] varchar(8000) NULL, 
	[Trans_Day_of_Week_Num] int NULL, 
	[Trans_Year] int NULL, 
	[Week_of_Year] int NULL, 
	[WeekNum_of_Year] varchar(8000) NULL
);