CREATE  PROCEDURE [Retail_Traffic].[Usp_Refresh_StoreTraffic]
AS
BEGIN 

DECLARE
    @String    VARCHAR(5000),
    @DateValue DATETIME2(6),
    @User      VARCHAR(500);

SET @String = 'Retail_Traffic.Usp_Refresh_StoreTraffic'
SET @User = SYSTEM_USER;
SET @DateValue = GETDATE();
SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

BEGIN TRY



-- Default in any missing locations in ShopperTrakStores

INSERT INTO [$(Source_Data)].[Retail_Miniapps].[ShopperTrakStores]
      ([Operation],
       [StoreID],
       [StoreName],
       [IsActive],
       [AFHS],
       [DivideBy],
       [APIStoreID],
       [APIEntranceID],
       [IPAddress])
select OperationID,
       RetailSystemNumber,
       SiteName,
       CASE WHEN OperationalStatus='Active' then 1 else 0 End,
       1 as [AFHS],
       2 as DivideBy,
       sttLocID,
       NULL, NULL
   
from (SELECT DISTINCT sttShopperTrakOrgID,sttLocID 
from [$(Source_Data)].[Retail_Shoppertrack].[EnterpriseSFTPTrafficCount] where sttShopperTrakOrgID != '80030783' and sttLocID!='0055') t1 
join [$(Source_Data)].[MasterData_Retail].[SiteMasterLocations] on sttSHopperTrakOrgID=[ShopperTrakLocID]
LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[ShopperTrakStores] T3 on T1.sttLocID=T3.APIStoreID
where [EnterpriseStore]=1
and APIStoreID IS NULL


TRUNCATE TABLE [Retail_Traffic_Wrk].[StoreTraffic]

SELECT  
    [DeviceSourceID],
    [DataSource],
    [StoreID], 
    [TransDate],
    [TransHour], 
    [TransCount], 
    [IsOpen], 
    [RSAMinutes],
    [IsOverride] ,
    [LastUpdated]
INTO #temp 
FROM [Retail_Traffic_Wrk].[StoreTraffic]

;WITH CTE_OverrideTraffic AS
(
SELECT 
    TrafficRequestsID as DeviceSourceID, 
    'REPL' as DataSource,
    LocationID AS StoreID, 
    TransDate, 
    TransHour, 
    ChangeCount AS TransCount, 
    1 AS [IsOpen],
    0 AS [RSAMinutes], 
    1 AS [IsOverride],
    ChangeDate as LastUpdated
 
FROM [Retail_Traffic].[OverrideTraffic]
WHERE TransDate >= DATEADD(DAY,-30,CAST(@DateValue AS DATE))
    AND ReasonCode = 'REPLACE'
),
CTE_ActualTraffic AS
(
SELECT  st.ShopperTrakOrgID as DeviceSourceID,
        st.Code as DataSource,
        st.LocationID AS StoreID, 
        st.TransDate, 
        CAST(st.TransHour as INT) AS TransHour, 
        SUM(st.Enter) as TransCount, 
        0 AS [IsOpen],
        0 AS [RSAMinutes],
        0 AS [IsOverride],
        NULL as LastUpdated
FROM [Retail_Traffic].[EnterpriseActualTraffic] st
WHERE st.TransDate >=DATEADD(DAY,-30,CAST(@DateValue AS DATE))
AND st.LocationID IS NOT NULL   -- filter out licensees (NULL locationIDs)
Group By 
        st.ShopperTrakOrgID ,
        st.Code ,
        st.LocationID , 
        st.TransDate, 
        CAST(st.TransHour as INT)  
)
INSERT INTO #temp
   ([DeviceSourceID],
    [DataSource],
    [StoreID], 
    [TransDate],
    [TransHour], 
    [TransCount], 
    [IsOpen], 
    [RSAMinutes],
    [IsOverride] ,
    [LastUpdated])
SELECT 
    O.DeviceSourceID, 
    O.DataSource,
    O.StoreID, 
    O.TransDate, 
    O.TransHour, 
    O.TransCount, 
    O.[IsOpen],
    O.[RSAMinutes], 
    O.[IsOverride],
    O.LastUpdated
   FROM CTE_OverrideTraffic O -- 1st Priority
UNION
SELECT 
    A.[DeviceSourceID],
    A.[DataSource],
    A.[StoreID], 
    A.[TransDate],
    A.[TransHour], 
    A.[TransCount], 
    A.[IsOpen], 
    A.[RSAMinutes],
    A.[IsOverride] ,
    A.[LastUpdated]
   FROM CTE_ActualTraffic A 
LEFT JOIN CTE_OverrideTraffic B -- 2nd Priority
    ON A.StoreID = B.StoreID 
    AND A.TransDate = B.TransDate 
    --AND  CAST(A.TransHour AS INT) = B.TransHour   (Once we get a flag for Hourly vs Daily orveride and a Case for each)
WHERE B.StoreID IS NULL


--3rd Priority
;WITH CTE_Plug AS
(
SELECT 
    TrafficRequestsID as DeviceSourceID, 
    'PLUG' as DataSource,
    LocationID AS StoreID, 
    TransDate, 
    TransHour, 
    ChangeCount AS TransCount, 
    1 AS [IsOpen],
    0 AS [RSAMinutes], 
    1 AS [IsOverride],
    ChangeDate as LastUpdated
FROM [Retail_Traffic].[OverrideTraffic]
WHERE TransDate >=  DATEADD(DAY,-30,CAST(@DateValue AS DATE))
AND ReasonCode = 'PLUG'
)
INSERT INTO #temp
   ([DeviceSourceID],
    [DataSource],
    [StoreID], 
    [TransDate],
    [TransHour], 
    [TransCount], 
    [IsOpen], 
    [RSAMinutes],
    [IsOverride] ,
    [LastUpdated])
SELECT 
    P.DeviceSourceID, 
    P.DataSource,
    P.StoreID, 
    P.TransDate, 
    P.TransHour, 
    P.TransCount, 
    P.[IsOpen],
    P.[RSAMinutes], 
    P.[IsOverride],
    P.LastUpdated
FROM CTE_Plug P 
LEFT JOIN #temp B -- 2nd Priority
    ON P.StoreID = B.StoreID 
    AND P.TransDate = B.TransDate 
 --   AND A.TransHour = B.TransHour  (Plug doesn't exist yet but likely will only be by day)
WHERE B.StoreID IS NULL


--4th Priority
INSERT INTO #temp
   ([DeviceSourceID],
    [DataSource],
    [StoreID], 
    [TransDate],
    [TransHour], 
    [TransCount], 
    [IsOpen], 
    [RSAMinutes],
    [IsOverride] ,
    [LastUpdated])
SELECT DISTINCT 
    A.ShopperTrakOrgID as DeviceSourceID, 
    'REALT' as DataSource,
    A.LocationID as StoreID, 
    A.TransDate,
    CAST(A.TransHour AS INT) AS TransHour, 
    SUM(A.Enter) AS TransCount,
    0 AS [IsOpen], 
    0 AS [RSAMinutes],
    0 AS [IsOverride],
    NULL AS LastUpdated 
FROM [Retail_Traffic].[RealTimeTraffic]  A
LEFT JOIN #temp B
    ON A.LocationID = B.StoreID 
    AND A.TransDate = B.TransDate 
   -- AND CAST(A.TransHour AS INT) = B.TransHour  (Don't mix Realtime hours with data from another sourceon same day)
WHERE A.LocationID IS NOT NULL and B.StoreID IS NULL   -- filter out licensees (NULL locationIDs)
AND A.TransDate >= DATEADD(DAY,-30,CAST(@DateValue AS DATE))
GROUP BY
    A.ShopperTrakOrgID , 
    A.LocationID , 
    A.TransDate,
    CAST(A.TransHour AS INT)


/*  business doesn't want to mix different hours from Actual and Realtime in the same day
--Update zero values from non-zero Realtime
UPDATE B
SET B.TransCount = A.Enter
FROM #temp B
INNER JOIN [Retail_Traffic].[RealTimeTraffic] A
     ON A.StoreID = B.StoreID 
    AND A.TransDate = B.TransDate 
    AND A.TransHour = B.TransHour
 WHERE B.DataSource NOT in ('REPL','PLUG')
    AND A.Enter <> 0 and B.TransCount <> 0
*/



INSERT INTO [Retail_Traffic_Wrk].[StoreTraffic] 
    ([DeviceSourceID],
    [DataSource],
    [StoreID], 
    [TransDate],
    [TransDay],
    [TransHour], 
    [TransCount], 
    [IsOpen], 
    [LastUpdated], 
    [TrafficCount],
    [RSAMinutes], 
    [IsOverride])
SELECT A.[DeviceSourceID], 
    A.[DataSource],
    A.[StoreID], 
    A.TransDate, 
    DAY(A.TransDate) AS TransDay,
    TransHour, 
    SUM(CASE WHEN A.[IsOverride]=1 
         THEN A.[TransCount] 
         ELSE A.[TransCount] / CASE WHEN B.DivideBy IS NULL THEN 2 ELSE B.DivideBy END 
    END) AS [TransCount],
    A.[IsOpen],
    @DateValue, 
    SUM(CASE WHEN A.[IsOverride]=1 
         THEN A.[TransCount] 
         ELSE A.[TransCount] / CASE WHEN B.DivideBy IS NULL THEN 2 ELSE B.DivideBy END 
    END) AS  [TrafficCount], 
    A.[RSAMinutes], 
    A.[IsOverride]
FROM #temp A
LEFT JOIN [$(Source_Data)].Retail_Miniapps.ShopperTrakStores B
ON A.StoreID = CAST(B.StoreID AS INT)
Group BY
    A.[DeviceSourceID],
    A.[DataSource],
    A.[StoreID], 
    A.[TransDate],
    A.[TransHour], 
    A.[IsOpen], 
    A.[LastUpdated], 
    A.[RSAMinutes], 
    A.[IsOverride]


--Update IsOpen Flag
UPDATE st
SET st.IsOpen = 1
FROM [Retail_Traffic_Wrk].[StoreTraffic] st
INNER JOIN [$(Source_Data)].[Retail_External].[StoreDailyOpenHours] sdoh
    ON st.StoreID = CAST(sdoh.StoreID as INT)
    AND st.TransDate  = CAST(sdoh.TransDate AS DATE)
    AND st.TransHour >= sdoh.OpenTime
    AND st.TransHour < sdoh.CloseTime


--Upsert to main table

DELETE from [Retail_Traffic].[StoreTraffic] 
where TransDate >= DATEADD(DAY,-30,CAST(@DateValue AS DATE))
AND TransDate >= '2025-12-28'   -- data prior to this date should never be deleted... it was backfilled from Dart


INSERT INTO [Retail_Traffic].[StoreTraffic]
   ([DeviceSourceID],
    [DataSource],
    [StoreID], 
    [TransDate],
    [TransDay],
    [TransHour], 
    [TransCount], 
    [IsOpen], 
    [LastUpdated], 
    [TrafficCount],
    [RSAMinutes], 
    [IsOverride])
SELECT 
    A.[DeviceSourceID],
    A.[DataSource],
    A.[StoreID], 
    A.[TransDate],
    A.[TransDay],
    A.[TransHour], 
    A.[TransCount], 
    A.[IsOpen], 
    A.[LastUpdated], 
    A.[TrafficCount],
    A.[RSAMinutes], 
    A.[IsOverride] 
FROM [Retail_Traffic_Wrk].[StoreTraffic] A 


DROP TABLE #temp

END TRY

BEGIN CATCH
    DECLARE
        @ErrorMessage  VARCHAR(4000),
        @ErrorSeverity INT,
        @ErrorState    INT;
    SET @ErrorMessage = ERROR_MESSAGE();
    SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
    SET @ErrorState = ISNULL(ERROR_STATE(), 0);
    SET @DateValue = GETDATE();
    SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


    INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
    VALUES
        (
            @String, @DateValue, @User, @ErrorMessage
        );

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;


SET @DateValue = GETDATE();
SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

EXEC [$(ETL_Framework)].DW_Developer.usp_UpdateTableDictionary_ModifiedDate 
    'Retail_Warehouse', 'Retail_Traffic', 'StoreTraffic', @String, @DateValue;


END