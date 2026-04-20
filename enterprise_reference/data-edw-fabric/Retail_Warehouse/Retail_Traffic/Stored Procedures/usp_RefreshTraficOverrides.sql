Create PROCEDURE [Retail_Traffic].[Usp_Refresh_OverrideTraffic]
AS
BEGIN 

DECLARE
    @String    VARCHAR(5000),
    @DateValue DATETIME2(6),
    @User      VARCHAR(500);

SET @String = 'Retail_Traffic.Usp_Refresh_OverrideTraffic'
SET @User = SYSTEM_USER;
SET @DateValue = GETDATE();
SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

BEGIN TRY

TRUNCATE TABLE [Retail_Traffic_Wrk].[OverrideTraffic]

INSERT INTO [Retail_Traffic_Wrk].[OverrideTraffic]
(
    TrafficRequestsID, 
    LocationID, 
    TransDate, 
    TransHour, 
    SubmittedBy, 
    RequestDate, 
    OriginalCount, 
    RequestedCount, 
    RecordedGuests, 
    CaptureRate, 
    CaptureRateLastYear, 
    Average,
    ChangedBy, 
    ChangeDate, 
    ChangeCount, 
    Closed, 
    ReasonCode 
)
SELECT  TrafficRequestsID, 
    LocationID, 
    TransDate, 
    TransHour, 
    SubmittedBy, 
    RequestDate, 
    OriginalCount, 
    RequestedCount, 
    RecordedGuests, 
    CaptureRate, 
    CaptureRateLastYear, 
    Average,
    ChangedBy, 
    ChangeDate, 
    ChangeCount, 
    Closed, 
    ReasonCode
FROM (
SELECT 
    TrafficRequestsID, 
    cast(cast(LocationID as Int) as varchar(5) ) as LocationID, 
    TransDate, 
    TransHour, 
    SubmittedBy, 
    RequestDate, 
    OriginalCount, 
    RequestedCount, 
    RecordedGuests, 
    CaptureRate, 
    CaptureRateLastYear, 
    Average,
    ChangedBy, 
    ChangeDate, 
    ChangeCount, 
    Closed, 
    'REPLACE' AS ReasonCode, 
    ROW_NUMBER() OVER(PARTITION BY LocationID, TransDate, TransHour 
                       ORDER BY RequestDate DESC) AS RowID
FROM [$(Source_Data)].Retail_Miniapps.TrafficRequests
WHERE TransDate >= GETDATE() - 30) T1
WHERE RowID=1


--Upsert to main table
DELETE FROM  [Retail_Traffic].[OverrideTraffic] WHERE TransDate >= GETDATE() - 30

INSERT INTO [Retail_Traffic].[OverrideTraffic]
SELECT
    A.TrafficRequestsID, 
    A.LocationID, 
    A.TransDate, 
    A.TransHour, 
    A.SubmittedBy, 
    A.RequestDate, 
    A.OriginalCount,
    A.RequestedCount, 
    A.RecordedGuests, 
    A.CaptureRate, 
    A.CaptureRateLastYear, 
    A.Average,
    A.ChangedBy,
    A.ChangeDate,
    A.ChangeCount,
    A.Closed, 
    A.ReasonCode 

FROM [Retail_Traffic_Wrk].[OverrideTraffic] A 



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
    'Retail_Warehouse', 'Retail_Traffic', 'OverrideTraffic', @String, @DateValue;

END
