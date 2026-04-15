CREATE TABLE [Retail_Sales_Enh].[SalesOrderHeader_DebugLog] (

	[ExecutionID] bigint NOT NULL, 
	[ExecutionDate] datetime2(3) NOT NULL, 
	[ExecutionUser] varchar(500) NULL, 
	[StepNumber] int NULL, 
	[StepName] varchar(500) NULL, 
	[RowsAffected] bigint NULL, 
	[ExecutionTime] datetime2(3) NULL, 
	[AdditionalInfo] varchar(max) NULL
);