CREATE TABLE [Retail_DW_Core].[LEAS_FactLeaseTranscationCounts] (

	[LocationKey] int NULL, 
	[SalesPersonKey] int NULL, 
	[TransDateKey] int NULL, 
	[FinanceProviderID] varchar(8000) NULL, 
	[IsLeasedVendor] int NULL, 
	[SUClose] decimal(18,4) NULL, 
	[SPClose] decimal(18,4) NULL
);