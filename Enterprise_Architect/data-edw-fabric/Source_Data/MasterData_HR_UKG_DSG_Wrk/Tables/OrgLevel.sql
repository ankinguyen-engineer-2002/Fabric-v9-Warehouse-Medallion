CREATE TABLE [MasterData_HR_UKG_DSG_Wrk].[OrgLevel] (

	[budgetGroup] varchar(50) NULL, 
	[code] varchar(20) NULL, 
	[currentYearBudgetFTE] decimal(10,2) NULL, 
	[currentYearBudgetSalary] decimal(10,2) NULL, 
	[description] varchar(50) NULL, 
	[glSegment] varchar(20) NULL, 
	[isActive] bit NULL, 
	[lastYearBudgetFTE] decimal(10,2) NULL, 
	[lastYearBudgetSalary] decimal(10,2) NULL, 
	[level] int NULL, 
	[levelDescription] varchar(50) NULL, 
	[reportingCategory] varchar(50) NULL, 
	[key] int NULL, 
	[dwLoadDateTime] datetime2(6) NULL, 
	[dataSource] varchar(10) NULL
);