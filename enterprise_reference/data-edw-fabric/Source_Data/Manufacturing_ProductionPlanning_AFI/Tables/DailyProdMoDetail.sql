CREATE TABLE [Manufacturing_ProductionPlanning_AFI].[DailyProdMoDetail] (

	[MSiteID] char(3) NULL, 
	[MWarehouse] char(3) NULL, 
	[MAspSection] decimal(1,0) NULL, 
	[MASPLine] char(5) NULL, 
	[MScheduledDate] datetime2(6) NULL, 
	[MDepartment] char(4) NULL, 
	[MWorkCenter] char(5) NULL, 
	[MActualShift] decimal(1,0) NULL, 
	[MItemNumber] varchar(15) NULL, 
	[MManufacturingOrder] char(7) NULL, 
	[MOperationSequence] char(4) NULL, 
	[MScheduledQuantity] decimal(10,3) NULL, 
	[MEarlyQuantity] decimal(10,3) NULL, 
	[MProductionQuantity] decimal(10,3) NULL, 
	[MOntimeQuantity] decimal(10,3) NULL, 
	[MScheduledRunSequence] decimal(6,0) NULL, 
	[MPiecesRunOutOfSequence] decimal(10,3) NULL, 
	[MFOBDolEachAssemblyOnly] decimal(15,3) NULL, 
	[MSnapshotDatetimeStamp] datetime2(6) NULL
);