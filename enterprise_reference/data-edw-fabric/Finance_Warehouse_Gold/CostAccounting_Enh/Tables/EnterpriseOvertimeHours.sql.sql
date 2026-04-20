CREATE TABLE [CostAccounting_Enh].[EnterpriseOvertimeHours]
(
	[Date_WeekEnding] [date] NULL,
	[EmployeeNmbr] [varchar](10) NULL,
	[EmployeeName] [varchar](100) NULL,
	[Facility] [varchar](10) NULL,
	[Department_OT] [varchar](20) NULL,
	[Dept_Desc] [varchar](500) NULL,
	[Location] [varchar](50) NULL,
	[LegalEntity] [varchar](20) NULL,
	[LegalEntity_Desc] [varchar](1000) NULL,
	[Type] [varchar](10) NULL,
	[Div] [varchar](10) NULL,
	[VP_Hierarchy] [varchar](100) NULL,
	[VP_HRO] [varchar](100) NULL,
	[VP_Final] [varchar](50) NULL,
	[Total_Hrs] [varchar](50) NULL,
	[OT_hrs] [varchar](50) NULL,
	[OT_Hrs_Check] [varchar](50) NULL,
	[Week_Index] [varchar](20) NULL
)