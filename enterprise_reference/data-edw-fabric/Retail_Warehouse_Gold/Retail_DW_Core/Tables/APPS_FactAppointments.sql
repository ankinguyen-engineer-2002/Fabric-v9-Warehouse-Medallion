CREATE TABLE [Retail_DW_Core].[APPS_FactAppointments] (

	[ID] int NULL, 
	[AppointmentDate] date NULL, 
	[AppointmentDateTime] datetime2(6) NULL, 
	[Calendar] varchar(8000) NULL, 
	[CalendarID] int NULL, 
	[Location] varchar(8000) NULL, 
	[Email] varchar(8000) NULL, 
	[Phone] varchar(8000) NULL, 
	[FirstName] varchar(8000) NULL, 
	[LastName] varchar(8000) NULL, 
	[AppointmentCategory] varchar(8000) NULL, 
	[LabelStatus] varchar(8000) NULL, 
	[AppointmentDateCreated] datetime2(6) NULL, 
	[MinutesDifference] int NULL, 
	[hour] int NULL
);