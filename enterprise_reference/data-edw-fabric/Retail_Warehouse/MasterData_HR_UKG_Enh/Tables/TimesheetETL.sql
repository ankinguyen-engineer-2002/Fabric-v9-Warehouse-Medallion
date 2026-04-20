CREATE TABLE [MasterData_HR_UKG_Enh].[TimesheetETL] (

	[SourceDataID] varchar(50) NULL, 
	[SourceSystemID] int NULL, 
	[PeopleID] int NULL, 
	[EmployeeNumber] varchar(100) NULL, 
	[PayPeriod] int NULL, 
	[TransDateKey] varchar(8) NULL, 
	[SourceLocationID] int NULL, 
	[TimeIn] datetime2(3) NULL, 
	[TimeOut] datetime2(3) NULL, 
	[Time] float NULL, 
	[SourcePayCodeID] int NULL, 
	[PaymentCodeName] varchar(50) NULL, 
	[SourceTaskCodeID] int NULL, 
	[TaskCodeName] varchar(100) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[ExtCost] decimal(18,0) NULL, 
	[LocationID] varchar(50) NULL, 
	[ApprovedByManager] bit NULL,
	[DataSource] [varchar](5) NOT NULL
);