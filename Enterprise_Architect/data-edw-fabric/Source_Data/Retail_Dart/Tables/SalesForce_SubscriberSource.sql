CREATE TABLE [Retail_Dart].[SalesForce_SubscriberSource] (

	[AcquisitionSource] varchar(50) NOT NULL, 
	[AcquisitionSourceDetail] varchar(100) NOT NULL, 
	[RecordDate] date NOT NULL, 
	[StoreID] char(3) NULL, 
	[SubscriberCount] int NULL, 
	[SFMCStoreBrandID] varchar(50) NOT NULL
);