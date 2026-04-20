-- Auto Generated (Do not modify) C68BB49A216120DC3103FAC36482631E8C34BF0D6931FFB789655D9849547654
/*
2025-08-27 || Harshit S:  Created View
*/

CREATE   VIEW [Retail_DW_Core_Wrk].[v_STGQ_FactEmployeeHours] AS
SELECT D.LocationID
			, D.TransDate
			, SUM(D.MinutesWorked) / 60.0 AS EmployeeHours
			, COUNT(DISTINCT (D.EmployeeNumber)) AS RSAsWorking
	FROM [Retail_DW_Core].[DMTimeSheetHours] D
		LEFT JOIN
		(
			SELECT H.EmployeeNumber
			FROM [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] H 
			WHERE H.TransDate =
			(
				SELECT MAX(HH.TransDate)FROM [$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory] HH 
			)
			AND H.JobID IN ( 307,366,367,83,256,322,150,369) 
		)  E
			ON (D.EmployeeNumber = E.EmployeeNumber )  --or  concat('000',D.EmployeeNumber)= E.EmployeeNumber
	WHERE D.TransDate >= DATEFROMPARTS(YEAR(GETDATE()) - 1, 1, 1) --'2025-01-19'
			--AND D.IsOpen = 1  
			AND E.EmployeeNumber IS NOT NULL
			AND CAST(D.TransHour AS TIME) >= '09:00:00'
			AND CAST(D.TransHour AS TIME) <= '20:00:00'
			--AND LocationId = '057'
	GROUP BY D.LocationID, D.TransDate