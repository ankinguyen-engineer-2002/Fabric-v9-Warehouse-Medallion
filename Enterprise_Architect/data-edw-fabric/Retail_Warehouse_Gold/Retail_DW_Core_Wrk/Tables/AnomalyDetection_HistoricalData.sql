CREATE TABLE [Retail_DW_Core_Wrk].[AnomalyDetection_HistoricalData]
(
	[TransDate] [date] NOT NULL,
	[MetricName] [varchar](100) NOT NULL,
	[StoreID] [int] NOT NULL,
	[GoldValue] [decimal](19,4) NULL,
	[LoadDate] [date] NOT NULL
);