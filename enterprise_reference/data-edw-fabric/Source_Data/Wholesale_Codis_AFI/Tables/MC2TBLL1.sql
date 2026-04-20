CREATE TABLE [Wholesale_Codis_AFI].[MC2TBLL1] (

	[MajorCategory] char(6) NULL, 
	[MajorDescription] varchar(30) NULL, 
	[MinorCategory] char(6) NULL, 
	[ReservedCode] char(1) NULL, 
	[DescriptionOfCode] varchar(30) NULL, 
	[CodeComment1] varchar(30) NULL, 
	[CodeComment2] varchar(30) NULL, 
	[CodeComment3] varchar(30) NULL, 
	[IncludeComments] char(1) NULL, 
	[RulesAgingFlag] char(1) NULL, 
	[CollectionAgingFlag] char(1) NULL, 
	[JdeDocumentType] char(1) NULL, 
	[ExcludeFromDbt] char(1) NULL, 
	[UserMaintainedRecord] varchar(10) NULL, 
	[UserUpdateDate] numeric(8,0) NULL, 
	[UserUpdateTime] numeric(6,0) NULL
);