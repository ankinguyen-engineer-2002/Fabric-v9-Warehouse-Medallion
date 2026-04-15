-- Auto Generated (Do not modify) F277624108FF32A6AAE2458F5DAAFD8FBC29BE233690A636D3E40F10C5744DD8
CREATE     VIEW [Retail_DW_Core_Wrk].[v_DMTimeSheetHours] AS

SELECT [EmployeeNumber],
       [LocationID],
       dm.DateID as TransDate,
       [TransHour],
       [MinutesWorked],
       [IsOpen], 
	   tsh.ApprovedByManager
FROM [$(Source_Data)].[Retail_Dart].[TimeSheetHours] tsh
    LEFT JOIN [Retail_DW_Core].[DimDate] AS dm ON dm.DateKey = tsh.TransDateKey;