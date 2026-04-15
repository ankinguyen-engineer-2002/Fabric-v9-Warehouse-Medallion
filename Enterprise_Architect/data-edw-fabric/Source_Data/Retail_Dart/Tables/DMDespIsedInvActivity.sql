CREATE TABLE [Retail_Dart].[DMDespIsedInvActivity] (

	[TransID] bigint NOT NULL, 
	[ActivityTypeID] varchar(50) NULL, 
	[Description] varchar(50) NULL, 
	[StoreBrandID] varchar(20) NULL, 
	[LocationID] varchar(50) NULL, 
	[ProductID] varchar(50) NULL, 
	[SerialNo] varchar(50) NULL, 
	[InvSubBucketID] varchar(50) NULL, 
	[RefSubBucketID] varchar(50) NULL, 
	[TransDate] date NULL, 
	[PeriodDate] date NULL, 
	[TransQty] int NULL, 
	[TotalCost] float NULL, 
	[Starting] float NULL, 
	[Created] float NULL, 
	[Adjust] float NULL, 
	[Transfer] float NULL, 
	[Sold] float NULL, 
	[ReClassIn] float NULL, 
	[ReClassOut] float NULL, 
	[ReasonCodeID] varchar(50) NULL
);