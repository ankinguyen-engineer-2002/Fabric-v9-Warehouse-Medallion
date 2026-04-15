CREATE TABLE [Retail_DW_Core].[LEAS_FactLeaseOppsAttempts] (

	[LocationKey] int NULL, 
	[SalesPersonKey] int NULL, 
	[TransDate] date NULL, 
	[FinanceProviderID] varchar(8000) NULL, 
	[AppCount] int NULL, 
	[LeaseAttempt] int NULL, 
	[LeaseOpp] int NULL
);