CREATE VIEW [AFISales_DW_Wrk].[v_DimMarketingAdFundsDetails]
AS
    SELECT
        [Ad Funds Key],
        CAST([Ad Funds Modified Date] AS DATE)           AS [Ad Funds Modified Date],
        [Ad Funds Modified By],
        [Ad Funds Division],
        CAST([Ad Funds Velocity Driver Name] AS CHAR(1)) AS [Ad Funds Velocity Driver Name],
        [Ad Funds Type],
        [Ad Funds Approval Status],
        CAST([Ad Funds Comments] AS VARCHAR(8000))       AS [Ad Funds Comments],
        [Ad Funds Special Discount Code],
        [Ad Funds Event Name],
        [Ad Funds VP],
        [Ad Used For],
        CAST([Ad Funds Requestor] AS VARCHAR(40))        AS [Ad Funds Requestor],
        CAST([Ad Funds Approver] AS VARCHAR(100))        AS [Ad Funds Approver],
        [Ad Funds Category focused on],
        CAST([Ad Funds Event Start Date] AS DATETIME)    AS [Ad Funds Event Start Date],
        CAST([Ad Funds Event End Date] AS DATETIME)      AS [Ad Funds Event End Date],
        CAST(CASE
                 WHEN dim_ad.[Ad Funds Comments] LIKE 'Invoice Date From AS400 :%'
                     THEN
                     SUBSTRING(
                                  dim_ad.[Ad Funds Comments], CHARINDEX(': ', dim_ad.[Ad Funds Comments], 1) + 1,
                                  CHARINDEX(
                                               '12:00:00 AM<br />', dim_ad.[Ad Funds Comments],
                                               CHARINDEX(': ', dim_ad.[Ad Funds Comments], 1) + 1
                                           ) - CHARINDEX(': ', dim_ad.[Ad Funds Comments], 1) - 1
                              )
             END AS DATE)                                AS [InvoiceDate],
        CAST(CASE
                 WHEN dim_ad.[Ad Funds Comments] LIKE 'Invoice Date From AS400 :%'
                     THEN
                     CASE
                         WHEN dim_ad.[Ad Funds Comments] LIKE '%Invoice Number From AS400 :%'
                             THEN
                             SUBSTRING(
                                          dim_ad.[Ad Funds Comments],
                                          CHARINDEX('Invoice Number From AS400 :', dim_ad.[Ad Funds Comments]) + 28,
                                          ABS(CHARINDEX(
                                                           '<br />AS400 Status is Complete So Auto Updated',
                                                           dim_ad.[Ad Funds Comments]
                                                       )
                                              - (CHARINDEX('Invoice Number From AS400 :', dim_ad.[Ad Funds Comments])
                                                 + 28
                                                )
                                             )
                                      )
                     END
             END AS CHAR(8))                             AS InvoiceNumber,
        CAST(CASE
                 WHEN dim_ad.[Ad Funds Comments] LIKE 'Invoice Date From AS400 :%'
                     THEN
                     CASE
                         WHEN dim_ad.[Ad Funds Comments] LIKE '%Order Number From AS400 :%'
                             THEN
                             SUBSTRING(
                                          dim_ad.[Ad Funds Comments],
                                          CHARINDEX('Order Number From AS400 :', dim_ad.[Ad Funds Comments]) + 26,
                                          ABS(CHARINDEX('<br />AS400 - Processed<br />', dim_ad.[Ad Funds Comments])
                                              - (CHARINDEX('Order Number From AS400 :', dim_ad.[Ad Funds Comments])
                                                 + 26
                                                )
                                             )
                                      )
                     END
             END AS CHAR(8))                             AS OrderNumber
    FROM
        (
            SELECT
                    FundRequest.RequestID                             AS [Ad Funds Key],
                    DATEADD(dd, 0, DATEDIFF(dd, 0, FundRequest.DateChange)) AS [Ad Funds Modified Date],
                    FundRequest.ChangeByUser                                  AS [Ad Funds Modified By],
                    FundRequest.Division                              AS [Ad Funds Division],
                    ''                                                AS [Ad Funds Velocity Driver Name],
                    (
                        SELECT
                            ValueDescription
                        FROM
                            [$(Wholesale_Warehouse)].Marketing.[AFValueList] ValueList
                        WHERE
                            (
                                ValueType = 'Funds Type'
                                OR ValueType = 'FundsType'
                            )
                            AND FundRequest.FundType = ValueList.ValueCode
                    )                                                 AS [Ad Funds Type],
                    (
                        SELECT
                            ValueDescription
                        FROM
                            [$(Wholesale_Warehouse)].Marketing.[AFValueList] ValueList
                        WHERE
                            (
                                ValueType = 'Fund Status'
                                OR ValueType = 'FundStatus'
                            )
                            AND FundRequest.Status = ValueList.ValueCode
                    )                                                 AS [Ad Funds Approval Status],
                    LEFT(FundRequest.Notes, 7999)                               AS [Ad Funds Comments],
                    FundRequest.SpecialDiscountCode                             AS [Ad Funds Special Discount Code],
                    FundRequest.EventName                                       AS [Ad Funds Event Name],
                    ISNULL(
                              (LTRIM(RTRIM(Profile1.LastName)) + ', ' + LTRIM(RTRIM(Profile1.FirstName))),
                              REPLACE(FundRequest.VicePresident, 'ASHLEYFURNITURE\', '')
                          )                                           AS [Ad Funds VP],
                    FundRequest.UsedFor                                         AS [Ad Used For],
                    ISNULL(
                              (LTRIM(RTRIM(Profile2.LastName)) + ', ' + LTRIM(RTRIM(Profile2.FirstName))),
                              REPLACE(FundRequest.Owner, 'ASHLEYFURNITURE\', '')
                          )                                           AS [Ad Funds Requestor],
                    ISNULL(
                              (LTRIM(RTRIM(Profile3.LastName)) + ', ' + LTRIM(RTRIM(Profile3.FirstName))),
                              REPLACE(FundRequest.ApprovedBy, 'ASHLEYFURNITURE\', '')
                          )                                           AS [Ad Funds Approver],
                    FundRequest.CategoryFocusedOn                               AS [Ad Funds Category focused on],
                    FundRequest.EventStartDate                                  AS [Ad Funds Event Start Date],
                    FundRequest.EventEndDate                                    AS [Ad Funds Event End Date]
            FROM
                    [$(Wholesale_Warehouse)].Marketing.[AdFundsRequest]         FundRequest
                LEFT JOIN
                    [$(MasterData_Warehouse)].[Security].[UserProfile] Profile1
                        ON REPLACE(FundRequest.VicePresident, 'ASHLEYFURNITURE\', '') = Profile1.UserLogin
                LEFT JOIN
                    [$(MasterData_Warehouse)].[Security].[UserProfile] Profile2
                        ON REPLACE(FundRequest.Owner, 'ASHLEYFURNITURE\', '') = Profile2.UserLogin
                LEFT JOIN
                    [$(MasterData_Warehouse)].[Security].[UserProfile] Profile3
                        ON REPLACE(FundRequest.ApprovedBy, 'ASHLEYFURNITURE\', '') = Profile3.UserLogin
        ) AS dim_ad;
GO


