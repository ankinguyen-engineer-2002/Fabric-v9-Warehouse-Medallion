CREATE TABLE [Retail_DW_Core].[LEAS_DimSalesperson] (

	[SalespersonID] varchar(8000) NULL, 
	[SalesPersonKey] int NULL, 
	[Name] varchar(8000) NULL, 
	[SalesPersonTypeID] varchar(8000) NULL, 
	[ActiveStatus] bit NULL, 
	[ManagerID] varchar(8000) NULL, 
	[HomeStore] varchar(8000) NULL, 
	[Store] varchar(8000) NULL, 
	[HireDate] date NULL, 
	[JobName] varchar(8000) NULL, 
	[Email] varchar(8000) NULL, 
	[Salesperson] varchar(8000) NULL
);