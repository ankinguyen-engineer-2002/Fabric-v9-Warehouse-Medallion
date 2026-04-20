CREATE TABLE [Retail_DW_Core].[SMQQ_FactRSAHours] (

	[LocationID] varchar(8000) NULL, 
	[TransDate] date NULL, 
	[EmployeeHours] int NULL, 
	[TotalEmployees] int NULL, 
	[Date_Location_Key] varchar(8000) NULL, 
	[Week_Ending] date NULL, 
	[Week_Ending_Location_Key] varchar(8000) NULL, 
	[Week_of_Year] int NULL, 
	[WeekNum_of_Year] int NULL
);