CREATE TABLE [Retail_Dart].[SalesAttachmentSummary] (

	[AttachmentKey] int NULL, 
	[TransDate] date NULL, 
	[SalesPersonKey] int NOT NULL, 
	[LocationKey] int NOT NULL, 
	[AttachmentType] int NULL, 
	[PrimaryValue] decimal(13,2) NULL, 
	[AttachedValue] decimal(13,2) NULL, 
	[DateChanged] datetime2(6) NOT NULL
);