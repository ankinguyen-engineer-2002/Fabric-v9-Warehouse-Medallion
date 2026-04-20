CREATE TABLE [Retail_Corporate].[RouteDetail] (

	[Operation] varchar(15) NULL, 
	[ActualCubes] numeric(18,2) NULL, 
	[ActualPieces] int NULL, 
	[ActualStops] int NULL, 
	[ActualValue] numeric(19,4) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[IsDeliveryDate] bit NULL, 
	[LastBatchID] int NULL, 
	[MaxCubes] numeric(18,2) NULL, 
	[MaxPieces] int NULL, 
	[MaxStops] int NULL, 
	[MaxValue] numeric(19,4) NULL, 
	[RecStatus] char(5) NULL, 
	[RouteCodeID] varchar(50) NULL, 
	[RouteDate] date NULL, 
	[SourceID] varchar(50) NULL
);