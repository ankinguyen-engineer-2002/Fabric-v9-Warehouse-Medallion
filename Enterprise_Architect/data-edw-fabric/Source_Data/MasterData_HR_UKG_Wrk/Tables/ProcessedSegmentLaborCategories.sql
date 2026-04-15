CREATE TABLE [MasterData_HR_UKG_Wrk].[ProcessedSegmentLaborCategories] (

	[employeeId] int NULL, 
	[segmentId] int NULL, 
	[applyDate] date NULL, 
	[laborCategoryId] int NULL, 
	[laborCategoryQualifier] varchar(10) NULL, 
	[laborCategoryName] varchar(50) NULL, 
	[laborCategoryOrderNum] int NULL, 
	[laborCategoryEntryId] int NULL, 
	[laborCategoryEntryQualifier] varchar(10) NULL, 
	[laborCategoryEntryName] varchar(50) NULL, 
	[laborCategoryEntryDescription] varchar(50) NULL, 
	[dwLoadDateTime] datetime2(6) NULL, 
	[dataSource] varchar(10) NULL
);