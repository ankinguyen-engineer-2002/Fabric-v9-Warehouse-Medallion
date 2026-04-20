-- Auto Generated (Do not modify) E467A51FC4C69628A3FA6DA0BA572C9B5E797D1EDAF76B3E1E1744CF14B0009F
/*
2025-08-27 || Harshit S:  Created View
*/

CREATE     VIEW [Retail_DW_Core_Wrk].[v_STGQ_FactTimeSheetDataCheck] AS
SELECT D.LocationID
		, D.TransDate
		, D.EmployeeNumber AS EmployeeNumber
		, E.FirstName, E.LastName, E.JobID, J.JobName, E.EmpStatus, E.EmpHourlySalary
		, D.TransHour
		, D.MinutesWorked AS MinutesWorked
		,D.ApprovedByManager
		,D.IsOpen AS TimeSheetIsOpen
		,Traffic.TransHour AS TrafficTransHour
		,Traffic.Traffic 
		,Traffic.IsOpen AS TrafficIsOpen
FROM [Retail_DW_Core].[DMTimeSheetHours] D 
	LEFT JOIN
	(
		SELECT H.EmployeeNumber, H.FirstName, H.LastName, H.JobID, H.EmpStatus, H.EmpHourlySalary
		FROM [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] H 
		INNER JOIN [$(Source_data)].[Retail_Miniapps].[PeopleRecords] p on p.EmployeeNumber = H.EmployeeNumber
		WHERE H.TransDate =
		(
			SELECT MAX(HH.TransDate) FROM [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] HH 
		)
		AND H.JobID IN (307,366,367,83,256,322,150,369)-- and  p.InHRSystem = 1 
	)  E ON D.EmployeeNumber = E.EmployeeNumber
	LEFT JOIN  [Retail_DW_Core].[DimHRJobs]  J  ON E.JobID = J.JobID
	LEFT JOIN
	(
	SELECT T.StoreID AS [LocationID]
				, dat.DateID AS [TransDate]
				, T.[TransHour]
				, T.IsOpen
				, SUM(T.[TrafficCount]) AS Traffic
		FROM [Retail_DW_Core].[FactTraffic] T
		INNER JOIN [Retail_DW_Core].[DimDate] as dat on T.TransDateKey= dat.DateKey
		WHERE 1=1
				--and T.IsOpen = 1    ---1) Employees are working before the Store is considered open
				AND dat.DateID >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1) -- '2025-01-19'
				AND T.TransHour >= 9
				AND T.TransHour <= 20
		GROUP BY T.[StoreID]
				, dat.[DateID]
				, T.[TransHour]
				,T.IsOpen
	) Traffic ON Traffic.[TransDate] = D.TransDate and Traffic.[TransHour] = DATEPART(hour, D.TransHour) and D.LocationID = Traffic.LocationID
WHERE D.TransDate >=  DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1) -- '2025-01-19'
		--AND D.IsOpen = 1  -- 3) Timesheet when the store is not open are not considered.
		AND E.EmployeeNumber IS NOT NULL
		AND DATEPART(hour, D.TransHour) >= 9
		AND DATEPART(hour, D.TransHour) <= 20
		--AND D.LocationId = '057'


		--select top 100 D.TransHour, DATEPART(hour, D.TransHour) from [Retail_DW_Core].[DMTimeSheetHours] D