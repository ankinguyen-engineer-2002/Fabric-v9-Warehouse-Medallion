CREATE TABLE [wholesale_codis].[btitscn] (
        [ltd_DropTimestamp] datetime2(6) NULL, 
	    [ltd_ID] int NULL, 
	    [ltd_mergeIgnore] bit NULL, 
	    [ltd_count1] bigint NULL,
	    [BSRSTS] varchar(8000) NULL,
      	[BSTRP#] decimal(38,18) NULL,
      	[BSDRP#] decimal(38,18) NULL,
      	[BSORD#] varchar(8000) NULL,
      	[BSISEQ] decimal(38,18) NULL,
      	[BSITM#] varchar(8000) NULL,
      	[BSREF#] decimal(38,18) NULL,
      	[BSITQT] decimal(38,18) NULL,
      	[BSITQN] decimal(38,18) NULL
)