-- Auto Generated (Do not modify) 807E84DA1F6376EC6068ACC59108E72C3074E62E21938E39A5FC942BBB1F17D1
CREATE   VIEW [Retail_DW_Core_Wrk].[v_LEAS_DimDayMap] AS 
SELECT 
    lcNow.[TransDate],
    d1.CalendarDate AS LYDate,
    d2.CalendarDate AS LYLYDate
FROM [Retail_DW_Core].[DimStoreLocationCalendar] AS lcNow

INNER JOIN [$(MasterData_Warehouse)].MasterData_DW.DimDate d
    ON d.CalendarDate = lcNow.TransDate

LEFT JOIN [$(MasterData_Warehouse)].MasterData_DW.DimDate d1 
    ON d1.FiscalYear = d.FiscalYear - 1
    AND d1.FiscalDayOfYear = d.FiscalDayOfYear

LEFT JOIN [$(MasterData_Warehouse)].MasterData_DW.DimDate d2 
    ON d2.FiscalYear = d.FiscalYear - 2
    AND d2.FiscalDayOfYear = d.FiscalDayOfYear
WHERE lcNow.TransDate > CAST(CONCAT(YEAR(GETDATE())-2, '-12-01') AS DATE)
GROUP BY lcNow.[TransDate], d1.CalendarDate, d2.CalendarDate