CREATE TABLE [Retail_DW_Core_Wrk].[SanityData_Result] (
	[ReportDate] [date] NOT NULL,
	[Layer] [varchar](50) NULL,
	[TableName] [varchar](200) NULL,
	[MetricName] [varchar](100) NOT NULL,
	[StoreID] [int] NOT NULL,
	[TransDate] [date] NOT NULL,
	[SourceCount] [decimal](16,2) NULL,
	[DestinationCount] [decimal](16,2) NULL,
	[Difference] [decimal](16,2) NULL,
	[Result] [varchar](20) NULL,
	[Description] [varchar](50) NULL
);
GO

