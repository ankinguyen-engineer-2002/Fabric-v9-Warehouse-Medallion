CREATE VIEW [PowerBI_Retail_Wrk].[v_PPH_TimeSheetSummary] 
AS 
SELECT pts.PayCodeID,
       tpc.PayCodeName,
       pts.TaskCodeID,
       tac.TaskCodeName,
       lm.StoreID as LocationID,
       lm.LocationType,
       lm.LocationName,
       pts.TotalTime AS TotalHours,
       pts.TotalTime * (1 - pts.TimeCodeID) AS RegHours,
       pts.TotalTime * pts.TimeCodeID AS OTHours,
       pts.TotalCost AS TotalCost,
       pts.TotalCost * (1 - pts.TimeCodeID) AS RegCost,
       pts.TotalCost * pts.TimeCodeID AS OTCost,
       CASE
           WHEN tpc.PayCodeType in (1,2,7)
                AND tac.TaskCodeType = 1 THEN
               1
           ELSE
               0
       END AS Productive,
       pts.TotalCost * pts.IsExternal AS ExternalCost, 
       pts.TotalTime * pts.IsExternal AS ExternalHours, 
       pts.TotalCost * ((pts.IsExternal+1)%2) AS InternalCost, 
       pts.TotalTime * ((pts.IsExternal+1)%2) AS InternalHours,
       dm.DateID as TransDate,
       pts.ApprovedByManager 
FROM [$(Retail_Warehouse)].[MasterData_HR_UKG_Enh].[TimeSheetSummary] AS pts 
    INNER JOIN [Retail_DW_Core].[DimStoreLocation] AS lm 
        ON lm.StoreID = pts.SourceLocationID
    INNER JOIN [Retail_DW_Core].[DimDate] AS dm 
        ON dm.DateKey = pts.TransDateKey
    INNER JOIN [$(Source_Data)].[Retail_External].[TATaskCodes] tac 
        ON tac.TaskCodeID = pts.TaskCodeID
    INNER JOIN [$(Source_Data)].[Retail_External].[TAPayCodes] tpc 
        ON tpc.PayCodeID = pts.PayCodeID;