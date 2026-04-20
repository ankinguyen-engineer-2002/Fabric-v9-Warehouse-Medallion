CREATE TABLE [Manufacturing_ProductionPlanning_AFI_Wrk].[DailyProdMoDetail] (

	[mSiteId] char(3) NULL, 
	[mWarehouse] char(3) NULL, 
	[mASPSection] decimal(1,0) NULL, 
	[mASPLine] char(5) NULL, 
	[mScheduledDate] datetime2(6) NULL, 
	[mDepartment] char(4) NULL, 
	[mWorkCenter] char(5) NULL, 
	[mActualShift] decimal(1,0) NULL, 
	[mItemNumber] varchar(15) NULL, 
	[mManufacturingOrder] char(7) NULL, 
	[mOperationSequence] char(4) NULL, 
	[mScheduledQuantity] decimal(10,3) NULL, 
	[mEarlyQuantity] decimal(10,3) NULL, 
	[mProductionQuantity] decimal(10,3) NULL, 
	[mOnTimeQuantity] decimal(10,3) NULL, 
	[mScheduledRunSequence] decimal(6,0) NULL, 
	[mPiecesRunOutOfSequence] decimal(10,3) NULL, 
	[mFOBDolEachAssemblyOnly] decimal(15,3) NULL, 
	[mSnapShotDateTimeStamp] datetime2(6) NULL
);