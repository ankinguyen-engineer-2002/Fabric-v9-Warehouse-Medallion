CREATE  PROCEDURE [Retail_Traffic].[Usp_Refresh_RealTimeTraffic]
AS
BEGIN 
DECLARE
    @String    VARCHAR(5000),
    @DateValue DATETIME2(6),
    @User      VARCHAR(500);

SET @String = 'Retail_Warehouse.Retail_Traffic.Usp_Refresh_RealTimeTraffic';
SET @User = SYSTEM_USER;
SET @DateValue = GETDATE();
SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

BEGIN TRY
TRUNCATE TABLE [Retail_Traffic_Wrk].[RealTimeTraffic]

INSERT INTO [Retail_Traffic_Wrk].[RealTimeTraffic]
 (  [ShopperTrakOrgID],
    [LocationID] , 
    [TransDate] , 
    [TransHour] , 
    [Enter], 
    [Exit] , 
    [Code])


SELECT [ShopperTrakLocID],
    [LocationID] , 
    [TransDate] , 
    [TransHour] , 
    [Enter], 
    [Exit] , 
    [Code]
 FROM
(SELECT 
   sl.ShopperTrakLocID,
   LocationID=Coalesce(sl.StoreID, sts.StoreID),
   TransDate=Cast(Cast(sttTransDate as char(8)) as Date), 
   TransHour= sttTransTime/10000,  [Enter]=sttEnter, 
   [Exit]=sttExit, 
   Code=sttDataTypeIndicator,  
   ROW_NUMBER() OVER(PARTITION BY sl.ShopperTrakLocID, Coalesce(sl.StoreID, sts.StoreID), sttTransDate, sttTransTime
                       ORDER BY sttLoadDate DESC) AS RowID
FROM [$(Source_Data)].Retail_Shoppertrack.RealTimeTrafficCount rtt
LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[ShopperTrakStores] sts
  ON  sts.APIStoreID = rtt.sttLocID
LEFT JOIN MasterData_Retail_Ent.StoreLocation sl
  ON sl.StoreID = cast(sts.StoreID as INT)
WHERE Cast(Cast(sttTransDate as char(8)) as Date) >= DATEADD(DAY,-30,CAST(@DateValue AS DATE))
 AND  (ISNULL(sttEnter, 0) <> 0 OR ISNULL(sttExit, 0) <> 0 )) T2
WHERE RowID = 1

--Upsert to main table

DELETE FROM [Retail_Traffic].[RealTimeTraffic] WHERE [TransDate] >= DATEADD(DAY,-30,CAST(@DateValue AS DATE))

INSERT INTO [Retail_Traffic].[RealTimeTraffic]
   ([ShopperTrakOrgID],
    [LocationID] , 
    [TransDate] , 
    [TransHour] , 
    [Enter], 
    [Exit] , 
    [Code])
SELECT A.ShopperTrakOrgID,
       A.LocationID  ,
       A.TransDate,
       A.TransHour,
       A.[Enter],
       A.[Exit],
       A.Code
FROM  [Retail_Traffic_Wrk].[RealTimeTraffic] A 

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
    'Retail_Warehouse', 'Retail_Traffic', 'RealTimeTraffic', @String, @DateValue;

END