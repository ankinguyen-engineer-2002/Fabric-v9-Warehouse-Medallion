CREATE TABLE [Retail_DW_Core].[SMQQ_FactRSADetails] (

	[LocationID] varchar(8000) NULL, 
	[TransDate] date NULL, 
	[EmployeeNumber] varchar(8000) NULL, 
	[EmployeeName] varchar(8000) NULL, 
	[JobID] int NULL, 
	[JobName] varchar(8000) NULL, 
	[EmployeeHours] int NULL, 
	[TotalSales] decimal(18,6) NULL, 
	[RSATransCount] decimal(18,6) NULL
);