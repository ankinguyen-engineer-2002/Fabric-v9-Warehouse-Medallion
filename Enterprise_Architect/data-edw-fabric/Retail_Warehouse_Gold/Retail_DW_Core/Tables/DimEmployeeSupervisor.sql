CREATE TABLE [Retail_DW_Core].[DimEmployeeSupervisor] (
	[EmployeeNumber] [varchar](10) NULL,
	[SupervisorEmployeeNumber] [varchar](10) NULL,
	[SupervisorFullName] [varchar](302) NULL,
	[DataSource] [varchar](5) NOT NULL
);