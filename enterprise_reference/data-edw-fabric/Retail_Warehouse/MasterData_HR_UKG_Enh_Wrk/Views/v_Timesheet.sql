-- Auto Generated (Do not modify) 742EE47ED1C9063DD19F87B4F2C30146507A30FE901507A216D0C355523FC620
CREATE     VIEW [MasterData_HR_UKG_Enh_Wrk].[v_Timesheet]
AS
	SELECT	
		ts.SegmentID
		, ts.EmployeeNumber
		, ts.LocationID
		, ts.ApplyDate AS WorkDate
		, ts.StartDateTime AS TimeIn
		, ts.EndDateTime AS [TimeOut]
		, ts.WorkHours
		, ts.PayCodeID
		, pc.PayCodeName AS PayCodeName
		--, ISNULL(ts.ProjectID, 32) AS TaskID  -- default (32) Z	<None> None-Project
		, ISNULL(ts.ProjectID, -1) AS TaskID  -- default (32)	Z <None> None-Project
		, wr.WorkRuleName AS TaskCodeName
		, wr.WorkRuleName AS TaskCodeDesc
		, ts.Wage
		, ts.ApprovedByManager
		, ts.SegmentPaycodeIndex
		, ts.DataSource
	FROM [MasterData_HR_UKG_Enh].[WFMTimesheet] ts
	LEFT JOIN [MasterData_HR_UKG_Enh].[PayCodes] pc 
	ON pc.PayCodeKey = ts.PayCodeID
	LEFT JOIN [MasterData_HR_UKG_Enh].[WorkRules] wr
	ON wr.WorkRuleID = ts.ProjectID;