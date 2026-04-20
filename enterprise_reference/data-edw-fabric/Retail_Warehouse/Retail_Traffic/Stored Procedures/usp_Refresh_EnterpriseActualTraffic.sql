CREATE PROCEDURE [Retail_Traffic].[usp_Refresh_EnterpriseActualTraffic]
AS
BEGIN 
DECLARE
    @String    VARCHAR(5000),
    @DateValue DATETIME2(6),
    @User      VARCHAR(500);

SET @String = 'Retail_Warehouse.Retail_Traffic.usp_Refresh_EnterpriseActualTraffic';
SET @User = SYSTEM_USER;
SET @DateValue = GETDATE();
SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

BEGIN TRY



TRUNCATE TABLE Retail_Traffic_Wrk.[EnterpriseActualTraffic] 

-- Merging the API and SFTP data and inserting into wrk table

   --- currently have an overlap of licenee and corporate sites with not way to identify them....
   ---API is not exposing sttShopperTrakOrgID
;
WITH CTE_ZeroCountCheck as 
(SELECT
 Sum(sttEnter) as [Enter],
 sttShopperTrakOrgID as ShopperTrakOrgID,
 TransDate=Cast(Cast(sttTransDate as char(8)) as Date)
FROM [$(Source_Data)].[Retail_Shoppertrack].EnterpriseSFTPTrafficCount 
WHERE sttDataTypeIndicator = 'A' AND Cast(Cast(sttTransDate as char(8)) as Date) >= GETDATE()-30
Group by Cast(Cast(sttTransDate as char(8)) as Date), sttShopperTrakOrgID
Having Sum(sttEnter) > 0
)

INSERT INTO Retail_Traffic_Wrk.[EnterpriseActualTraffic] 
    ([ShopperTrakOrgID],
    [LocationID] , 
    [TransDate] , 
    [TransHour] , 
    [Enter], 
    [Exit] , 
    [Code])
  /*SELECT 
    ShopperTrakOrgID=sttShopperTrakOrgID,
     LocationID=sl.StoreID, 
    TransDate=sttTransDate, 
    TransHour=sttTransTime/10000, 
    [Enter]=sttEnter, 
    [Exit]=sttExit, 
    [Code]=CAST(sttCode AS CHAR(1))
FROM [$(Source_data)].[Retail_Shoppertrack].EnterpriseAPITrafficCount A
LEFT JOIN MasterData_Retail_Ent.StoreLocation sl
 ON A.sttShopperTrakOrgID = sl.ShopperTrakLocID   --ttShopperTrakOrgID doesn't exist yet
 WHERE sttCode = 1 
AND CAST(sttTransDate AS DATE) >= CAST(GETDATE() - 30 AS DATE)

UNION 
*/
SELECT DISTINCT
    ShopperTrakOrgID=A.sttShopperTrakOrgID,
    LocationID=sl.StoreID, 
    TransDate=Cast(Cast(A.sttTransDate as char(8)) as Date), 
    TransHour=  FLOOR((A.sttTransTime-1500)/10000) + CAST(DATEPART(MINUTE, DATEADD(MINUTE, -15,CAST(DATEADD(MINUTE, (FLOOR((A.sttTransTime/10000)) * 60) 
                + (((A.sttTransTime/10000) - FLOOR((A.sttTransTime/10000))) * 100),0) AS TIME))) AS DECIMAL(5,2)) / 100.0,
    [Enter]=A.sttEnter, 
    [Exit]=A.sttExit, 
    [Code]=A.sttDataTypeIndicator 
FROM [$(Source_data)].[Retail_Shoppertrack].EnterpriseSFTPTrafficCount A
LEFT JOIN MasterData_Retail_Ent.StoreLocation sl
 ON A.sttShopperTrakOrgID = sl.ShopperTrakLocID
INNER JOIN CTE_ZeroCountCheck z
 ON z.ShopperTrakOrgID = A.sttShopperTrakOrgID and z.TransDate = Cast(Cast(A.sttTransDate as char(8)) as Date) 
--LEFT JOIN [$(Source_data)].[Retail_Shoppertrack].EnterpriseAPITrafficCount  B
--    ON A.sttLocID = B.sttLocID 
--    AND Cast(Cast(A.sttTransDate as char(8)) as Date) = B.sttTransDate  
 --   AND A.sttTransTime = B.sttTransTime
WHERE a.sttDataTypeIndicator = 'A' AND Cast(Cast(A.sttTransDate as char(8)) as Date) >= GETDATE()-30
--and  B.sttLocID IS NULL




--Upsert to main table

DELETE FROM  [Retail_Traffic].[EnterpriseActualTraffic] WHERE TransDate >= GETDATE() - 30

INSERT INTO [Retail_Traffic].[EnterpriseActualTraffic]
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
       A.[Code]
FROM Retail_Traffic_Wrk.[EnterpriseActualTraffic]  A 



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
    'Retail_Warehouse', 'Retail_Traffic', 'EnterpriseActualTraffic', @String, @DateValue;

END