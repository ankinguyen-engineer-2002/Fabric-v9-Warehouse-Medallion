CREATE VIEW Customers_Wrk.v_DeliveryWindow
AS
    SELECT
        [cdwCusno]                                       AS [CustomerNumber],
        [cdwShpno]                                       AS [ShiptoNumber],
        [cdwRc]                                          AS [RC],
        [cdwWin_ID]                                      AS [Window_ID],
        [cdw_Open]                                       AS [Open],
        [cdw_Close]                                      AS [Close],
        [cdwDays]                                        AS [Days],
        [cdwPrim_Sec]                                    AS [Prim_Sec],
        [cdwBefore]                                      AS [Before],
        [cdwAfter]                                       AS [After],
        CAST([cdwLstverDte] AS [DATE])                   AS [LastVerDate],
        [cdwType]                                        AS [Type],
        CAST([cdwExceptionSDate] AS [DATE])              AS [ExceptionSDate],
        CAST([cdwExceptionEDate] AS [DATE])              AS [ExceptionEDate],
        CAST([cdwCompanyNum] AS [INT])                   AS [CompanyNum],
        CAST([cdwLastDeliveryDate] AS [DATE])            AS [LastDeliveryDate],
        [usra]                                           AS [AddedByUser],
        CAST([dtea] AS [DATETIME2](6))                   AS [DateAdded],
        [usrc]                                           AS [ChangeByUser],
        CAST([dtec] AS [DATETIME2](6))                   AS [DateChange],
        CAST([acrec] AS [CHAR](1))                       AS [ActiveRecord],
        CAST([cdwWindowProfitFactor] AS [DECIMAL](3, 2)) AS [WindowProfitFactor],
        [cdwUserId]                                      AS [UserId],
        CAST([cdwRecordID] AS [BIGINT])                  AS [RecordID],
        CAST([cdwRowVer] AS VARBINARY(20))               AS [RowVer], 
        CAST([cdwRecordVersion] AS [BIGINT])             AS [RecordVersion]
    FROM
        [$(Source_Data)].[Wholesale_Customers].[DeliveryWindow]
