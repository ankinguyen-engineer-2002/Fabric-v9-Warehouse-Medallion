-- Auto Generated (Do not modify) 86555BEB09629383E74B3D5C1EB7D0B1C726C4390C53ED940FC653D1160FA67F
CREATE       VIEW [Retail_DW_Core_Wrk].[v_DimDate]
AS
SELECT
	d.DateKey,
	d.MapicsDate,
	d.DateID,
	d.DateTimeID,
	d.CalendarDate,
	d.CalendarDateName,
	d.FiscalYearFirstDate,
	d.FiscalYearLastDate,
	d.HolidayIndicator,
	d.HolidayName,
	d.WorkingDayIndicator,
	d.WeekdayWeekend,
	d.FiscalSemester,
	d.FiscalSemesterYear,
	d.FiscalYear,
	d.FiscalYearName,
	d.FiscalYearIndicator,
	d.FiscalDayOfYear,
	d.FiscalMonthLastDate,
	d.FiscalQuarter,
	d.FiscalQuarterName,
	d.FiscalQuarterIndicator,
	d.FiscalQuarterYear,
	d.FiscalQuarterYearName,
	d.FiscalMonthYear,
	d.FiscalMonthName,
	d.FiscalMonthYearName,
	d.FiscalDayOfMonth,
	d.FiscalWeekOfMonth,
	d.FiscalMonthFirstDate,
	d.FiscalWeekYear,
	d.FiscalWeekYearName,
	d.FiscalWeekFirstDate,
	d.FiscalWeekLastDate,
	d.FiscalMonth,
	d.FiscalMonthIndicator,
	d.FiscalDateName,
	d.FiscalDateIndicator,
	d.FiscalWeek,
	d.FiscalWeekIndicator,
	d.FiscalDayOfWeek,
	d.FiscalDayOfWeekName,
	d.CalendarSemesterYear,
	d.CalendarYear,
	d.CalendarYearName,
	d.CalendarYearIndicator,
	d.CalendarDayOfYear,
	d.FiscalDate,
	d.CalendarQuarter,
	d.CalendarQuarterName,
	d.CalendarQuarterIndicator,
	d.CalendarQuarterYear,
	d.CalendarQuarterYearName,
	d.CalendarSemester,
	d.CalendarMonthName,
	d.CalendarMonthYearName,
	d.CalendarDayOfMonth,
	d.CalendarWeekOfMonth,
	d.CalendarMonthFirstDate,
	d.CalendarMonthLastDate,
	d.CalendarDayOfWeekName,
	d.CalendarWeekFirstDate,
	d.CalendarWeekLastDate,
	d.CalendarMonth,
	d.CalendarMonthIndicator,
	d.CalendarMonthYear,
	d.CalendarDateIndicator,
	d.CalendarWeek,
	d.CalendarWeekIndicator,
	d.CalendarWeekYear,
	d.CalendarWeekYearName,
	d.CalendarDayOfWeek,
	d1.CalendarDate AS LYDate,
	d2.CalendarDate AS LYLYDate,
	d3.CalendarDate AS NYDate,
	-- P13 Flag: Last 13 weeks (FiscalWeekIndicator between 0 and -12)
	CASE
		WHEN d.FiscalWeekIndicator BETWEEN -12 AND 0 THEN 1
		ELSE 0
	END AS P13Flag,
	-- Previous P13 Flag: Prior 13 weeks (FiscalWeekIndicator between -13 and -25)
	CASE
		WHEN d.FiscalWeekIndicator BETWEEN -25 AND -13 THEN 1
		ELSE 0
	END AS PreviousP13Flag
FROM [$(MasterData_Warehouse)].MasterData_DW.DimDate d
LEFT JOIN [$(MasterData_Warehouse)].MasterData_DW.DimDate d1 
	ON d1.FiscalYear = d.FiscalYear - 1
	-- AND d1.CalendarWeek = d.CalendarWeek
	AND d1.FiscalDayOfYear = d.FiscalDayOfYear
LEFT JOIN [$(MasterData_Warehouse)].MasterData_DW.DimDate d2 
	ON d2.FiscalYear = d.FiscalYear - 2
	-- AND d2.CalendarWeek = d.CalendarWeek
	AND d2.FiscalDayOfYear = d.FiscalDayOfYear
LEFT JOIN [$(MasterData_Warehouse)].MasterData_DW.DimDate d3
	ON d3.FiscalYear = d.FiscalYear + 1
	-- AND d3.CalendarWeek = d.CalendarWeek
	AND d3.FiscalDayOfYear = d.FiscalDayOfYear
WHERE d.FiscalDate >= '2023-01-01';