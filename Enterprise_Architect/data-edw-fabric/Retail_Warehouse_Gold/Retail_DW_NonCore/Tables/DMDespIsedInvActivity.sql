CREATE TABLE [Retail_DW_NonCore].[DMDespIsedInvActivity] (

	[TransID] varchar(50) NULL, 
	[ActivityTypeID] varchar(10) NULL, 
	[Description] varchar(255) NULL, 
	[StoreBrandID] varchar(10) NULL, 
	[LocationID] varchar(50) NULL, 
	[ProductID] varchar(50) NULL, 
	[ReClassIn] varchar(10) NULL, 
	[ReClassOut] varchar(10) NULL, 
	[ReasonCodeID] varchar(10) NULL, 
	[TotalCost] decimal(18,4) NULL, 
	[Starting] int NULL, 
	[Created] int NULL, 
	[Adjust] int NULL, 
	[Transfer] int NULL, 
	[Sold] int NULL, 
	[SerialNo] varchar(100) NULL, 
	[InvSubBucketID] varchar(10) NULL, 
	[RefSubBucketID] varchar(10) NULL, 
	[TransDate] datetime2(3) NULL, 
	[PeriodDate] datetime2(3) NULL, 
	[TransQty] int NULL
);