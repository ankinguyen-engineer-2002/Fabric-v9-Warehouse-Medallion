CREATE VIEW AFISales_DW_Wrk.v_DimDateFile 
AS
    SELECT
            CAST(df.DateID AS DATE)                                                                                     AS [Transaction Date],
            CAST(df.FiscalYear AS CHAR(4))                                                                              AS [Fiscal Year],
            CAST(df.FiscalWeek AS CHAR(2))                                                                              AS [Fiscal Week],
            CAST(df.FiscalMonth AS CHAR(2))                                                                              AS [Fiscal Month],
            CASE
                WHEN df.FiscalMonth
                     BETWEEN 1 AND 3
                    THEN
                    1
                WHEN df.FiscalMonth
                     BETWEEN 4 AND 6
                    THEN
                    2
                WHEN df.FiscalMonth
                     BETWEEN 7 AND 9
                    THEN
                    3
                ELSE
                    4
            END                                                                                                     AS [Fiscal Quarter],
            CAST(DATEPART(yy, df.DateKey) AS CHAR(4))                                                                AS [Calendar Year],
            CAST(SUBSTRING(' ' + CAST(DATEPART(mm, df.DateKey) AS CHAR(2)), 2, 2) AS CHAR(2))                        AS [Calendar Month],
            CAST(SUBSTRING(' ' + CAST(DATEPART(ww, df.DateKey) AS CHAR(2)), 2, 2) AS CHAR(2))                        AS [Calendar Week],
            CAST(DATEPART(qq, df.DateKey) AS CHAR(1))                                                                AS [Calendar Quarter],
            df.[CalendarWeekYear],
            df.[FiscalWeekYear],
            CASE DATEPART(dw, df.DateKey)
                WHEN 1
                    THEN
                    'Sunday'
                WHEN 2
                    THEN
                    'Monday'
                WHEN 3
                    THEN
                    'Tuesday'
                WHEN 4
                    THEN
                    'Wednesday'
                WHEN 5
                    THEN
                    'Thursday'
                WHEN 6
                    THEN
                    'Friday'
                WHEN 7
                    THEN
                    'Saturday'
            END                                                                                                     AS [Week Day],

            -- Included for ordering the [week day] attribute in the cube

            CAST(SUBSTRING(' ' + CAST(DATEPART(dw, df.DateKey) AS CHAR(1)), 2, 2) AS CHAR(2))                        AS [WeekdayID],
            CASE DATEPART(dw, df.DateKey)
                WHEN 1
                    THEN
                    'Week Ended,  ' + CONVERT(VARCHAR(13), DATEADD(day,2,df.DateKey), 107)
                WHEN 2
                    THEN
                    'Week Ended,  ' + CONVERT(VARCHAR(13), DATEADD(day,1,df.DateKey), 107)
                WHEN 3
                    THEN
                    'Week Ended,  ' + CONVERT(VARCHAR(13), df.DateKey, 107)
                WHEN 4
                    THEN
                    'Week Ended,  ' + CONVERT(VARCHAR(13), DATEADD(day,6,df.DateKey), 107)
                WHEN 5
                    THEN
                    'Week Ended,  ' + CONVERT(VARCHAR(13), DATEADD(day,5,df.DateKey), 107)
                WHEN 6
                    THEN
                    'Week Ended,  ' + CONVERT(VARCHAR(13), DATEADD(day,4,df.DateKey), 107)
                WHEN 7
                    THEN
                    'Week Ended,  ' + CONVERT(VARCHAR(13), DATEADD(day,3,df.DateKey), 107)
            END                                                                                                     AS [Simple Week],

            -- Included for ordering the [simple week] attribute

            CONVERT(
                       INT,
                       ((CAST(DATEPART(yy, df.DateKey) AS CHAR(4))
                         + CASE DATEPART(dw, df.DateKey)
                               WHEN 1
                                   THEN
                                   RIGHT(('0' + CAST(DATENAME(week, df.DateKey) AS VARCHAR(2))), 2)
                               WHEN 2
                                   THEN
                                   RIGHT(('0' + CAST(DATENAME(week, df.DateKey) AS VARCHAR(2))), 2)
                               WHEN 3
                                   THEN
                                   RIGHT(('0' + CAST(DATENAME(week, df.DateKey) AS VARCHAR(2))), 2)
                               WHEN 4
                                   THEN
                                   RIGHT(('0' + CAST(DATENAME(week, df.DateKey) + 1 AS VARCHAR(2))), 2)
                               WHEN 5
                                   THEN
                                   RIGHT(('0' + CAST(DATENAME(week, df.DateKey) + 1 AS VARCHAR(2))), 2)
                               WHEN 6
                                   THEN
                                   RIGHT(('0' + CAST(DATENAME(week, df.DateKey) + 1 AS VARCHAR(2))), 2)
                               WHEN 7
                                   THEN
                                   RIGHT(('0' + CAST(DATENAME(week, df.DateKey) + 1 AS VARCHAR(2))), 2)
                           END
                        )
                       )
                   )                                                                                                AS [Simple Week ID],
            CASE
                WHEN DATENAME(dd, df.DateKey) < 16
                    THEN
                    CAST(DATEPART(mm, df.DateKey) AS CHAR(2)) + '/1/' + CAST(DATEPART(yy, df.DateKey) AS CHAR(4)) + ' - '
                    + CAST(DATEPART(mm, df.DateKey) AS CHAR(2)) + '/15/' + CAST(DATEPART(yy, df.DateKey) AS CHAR(4))
                ELSE
                    CAST(DATEPART(mm, df.DateKey) AS CHAR(2)) + '/16/' + CAST(DATEPART(yy, df.DateKey) AS CHAR(4)) + ' - '
                    + CAST(DATEPART(mm, df.DateKey) AS CHAR(2)) + CASE
                                                                     WHEN DATEPART(mm, df.DateKey) IN (
                                                                                                         4, 6, 9, 11
                                                                                                     )
                                                                         THEN
                                                                         '/30/'
                                                                     WHEN DATEPART(mm, df.DateKey) = 2
                                                                          AND DATEPART(yy, df.DateKey) % 4 = 0
                                                                         THEN
                                                                         '/29/'
                                                                     WHEN DATEPART(mm, df.DateKey) = 2
                                                                         THEN
                                                                         '/28/'
                                                                     ELSE
                                                                         '/31/'
                                                                 END + CAST(DATEPART(yy, df.DateKey) AS CHAR(4))
            END                                                                                                     AS [Commission Period],
            df.HolidayName                                                                                          AS [Holiday],
            CASE df.FiscalMonth
                WHEN 1
                    THEN
                    'January'
                WHEN 2
                    THEN
                    'February'
                WHEN 3
                    THEN
                    'March'
                WHEN 4
                    THEN
                    'April'
                WHEN 5
                    THEN
                    'May'
                WHEN 6
                    THEN
                    'June'
                WHEN 7
                    THEN
                    'July'
                WHEN 8
                    THEN
                    'August'
                WHEN 9
                    THEN
                    'September'
                WHEN 10
                    THEN
                    'October'
                WHEN 11
                    THEN
                    'November'
                WHEN 12
                    THEN
                    'December'
            END + ', ' + df.FiscalYear                                                                                  AS [Fiscal Month Desc],

            -- Included for ordering fiscal Month description

            CONVERT(INT, (CAST(df.FiscalYear AS CHAR(4)) + RIGHT(('0' + LTRIM(CAST(df.FiscalMonth AS VARCHAR(2)))), 2)))     AS [Fiscal Month Desc ID],
            CASE DATEPART(mm, df.DateKey)
                WHEN 1
                    THEN
                    'January'
                WHEN 2
                    THEN
                    'February'
                WHEN 3
                    THEN
                    'March'
                WHEN 4
                    THEN
                    'April'
                WHEN 5
                    THEN
                    'May'
                WHEN 6
                    THEN
                    'June'
                WHEN 7
                    THEN
                    'July'
                WHEN 8
                    THEN
                    'August'
                WHEN 9
                    THEN
                    'September'
                WHEN 10
                    THEN
                    'October'
                WHEN 11
                    THEN
                    'November'
                WHEN 12
                    THEN
                    'December'
            END + ', ' + CAST(DATEPART(yy, df.DateKey) AS CHAR(4))                                                   AS [Calendar Month Desc],
            CASE
                WHEN df.FiscalMonth
                     BETWEEN 1 AND 3
                    THEN
                    'Quarter 1'
                WHEN df.FiscalMonth
                     BETWEEN 4 AND 6
                    THEN
                    'Quarter 2'
                WHEN df.FiscalMonth
                     BETWEEN 7 AND 9
                    THEN
                    'Quarter 3'
                ELSE
                    'Quarter 4'
            END + ', ' + df.FiscalYear                                                                                AS [Fiscal Quarter Desc],
            'Quarter ' + CAST(DATEPART(qq, df.DateKey) AS CHAR(1)) + ', ' + CAST(DATEPART(yy, df.DateKey) AS CHAR(4)) AS [Calendar Quarter Desc],
            'Week ' + df.FiscalWeek + ', ' + df.FiscalYear                                                            AS [Fiscal Week Desc],
            CASE DATEPART(dw, df.DateKey)
                WHEN 1
                    THEN
                    CONVERT(VARCHAR(13), DATEADD(day,6,df.DateKey), 107)
                WHEN 2
                    THEN
                    CONVERT(VARCHAR(13), DATEADD(day,5,df.DateKey), 107)
                WHEN 3
                    THEN
                    CONVERT(VARCHAR(13), DATEADD(day,4,df.DateKey), 107)
                WHEN 4
                    THEN
                    CONVERT(VARCHAR(13), DATEADD(day,3,df.DateKey), 107)
                WHEN 5
                    THEN
                    CONVERT(VARCHAR(13), DATEADD(day,2,df.DateKey), 107)
                WHEN 6
                    THEN
                    CONVERT(VARCHAR(13), DATEADD(day,1,df.DateKey), 107)
                WHEN 7
                    THEN
                    CONVERT(VARCHAR(13), df.DateKey, 107)
            END                                                                                                     AS [Fiscal Week Description],

            -- Included for ordering calendar week description and fiscal week description

            CONVERT(
                       INT,
                       (CAST(DATEPART(yy, df.DateKey) AS CHAR(4))
                        + RIGHT(('0' + CAST(DATENAME(wk, df.DateKey) AS VARCHAR(2))), 2)
                       )
                   )                                                                                                  AS [Calendar Week Desc ID],
            'Week ' + CAST(DATEPART(ww, df.DateKey) AS CHAR(2)) + ', ' + CAST(DATEPART(yy, df.DateKey) AS CHAR(4))    AS [Calendar Week Desc],

            [Calendar Week Description]                                                                             = 'Week Ended,  ' + CONVERT(VARCHAR(13), df.CalendarWeekLastDate, 107),
            df.FiscalWeekLastDate                                                                                        AS [Fiscal Week Ended],
            df.FiscalMonthLastDate                                                                                    AS [Fiscal Month Ended],
            CASE DATEPART(dw, df.DateKey)
                WHEN 1
                    THEN
                    'Sun'
                WHEN 2
                    THEN
                    'Mon'
                WHEN 3
                    THEN
                    'Tue'
                WHEN 4
                    THEN
                    'Wed'
                WHEN 5
                    THEN
                    'Thu'
                WHEN 6
                    THEN
                    'Fri'
                WHEN 7
                    THEN
                    'Sat'
            END + ', ' + CAST(df.DateKey AS VARCHAR(12))                                                         AS [Date Desc],
            'Fiscal ' + df.FiscalYear                                                                            AS [Fiscal Year Desc],
            'Calendar ' + CAST(DATEPART(yy, df.DateKey) AS CHAR(4))                                              AS [Calendar Year Desc],
            df.[FiscalWeekIndicator]                                                                             AS [Fiscal Week Indicator],
            df.[FiscalMonthIndicator]                                                                            AS [Fiscal Month Indicator],
            df.[FiscalQuarterIndicator]                                                                          AS [Fiscal Quarter Indicator],
            df.[FiscalYearIndicator]                                                                             AS [Fiscal Year Indicator],
            dl.[dfiYearPeriod]                                                                                   AS [FiscalYearPeriod] ,
            df.[MapicsDate]
    FROM
            [$(MasterData_Warehouse)].[MasterData_DW].[DimDate_NonRetail]  df
         INNER JOIN 
             [$(Databricks)].[enterprise_ods].[datefile] dl 
                ON df.DateID = dl.dfiInpsdt
    WHERE
            df.DateKey > '2008-01-01';