CREATE TABLE [Retail_Traffic].[RealTimeTraffic] (

	[ShopperTrakOrgID] decimal(11,0) NULL, 
	[LocationID] varchar(30) NULL, 
	[TransDate] date NULL, 
	[TransHour] decimal(6,2) NULL, 
	[Enter] int NULL, 
	[Exit] int NULL, 
	[Code] char(1) NULL
);