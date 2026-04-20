CREATE TABLE [Retail_DW_Core].[DimHRJobs] (

	[JobID] [int] NOT NULL,
	[JobTitle] [varchar](100) NULL,
	[JobName] [varchar](100) NULL,
	[JobCode] [varchar](500) NULL,
	[JobFamilyCode] [varchar](200) NULL,
	[IsActive] [int] NULL,
	[IsRSA] [int] NULL,
	[DataSource] [varchar](5) NOT NULL
);