CREATE TABLE [Retail_Dart].[UnifiedCommissonRateOverridesFLAT] (

	[Operation] char(5) NULL, 
	[Id] int NOT NULL, 
	[FromDate] date NOT NULL, 
	[ToDate] date NOT NULL, 
	[LocationGroupID] varchar(10) NOT NULL, 
	[ProductID] varchar(20) NOT NULL, 
	[OverrideRateHFS] float NOT NULL, 
	[OverrideRateASM] float NOT NULL
);