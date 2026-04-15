CREATE TABLE [masterdata_productknowledge].[lifestylearea_multilanguage] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[lfaID] int NULL, 
	[lfaDescription] varchar(8000) NULL, 
	[lfaLanguageCode] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[lfaSendTranslation] bit NULL, 
	[lfaTranslationRec] bit NULL, 
	[lfaTranslationSentTime] datetime2(6) NULL
);

