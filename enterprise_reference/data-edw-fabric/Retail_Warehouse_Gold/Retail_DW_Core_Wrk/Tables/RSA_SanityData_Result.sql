CREATE TABLE [Retail_DW_Core_Wrk].[RSA_SanityData_Result] (
	[ReportDate] [date] NOT NULL,
	[MetricName] [varchar](100) NOT NULL,
	[SalesPersonKey] [int] NOT NULL,
	[SalesPersonID] [varchar](20) NOT NULL,
	[BronzeValue] [varchar](100) NULL,
	[SilverValue] [varchar](100) NULL,
	[GoldValue] [varchar](100) NULL,
	[Result] [varchar](20) NULL,
	[Priority] [int] NULL,
	[Description] [varchar](100) NULL
);
GO

