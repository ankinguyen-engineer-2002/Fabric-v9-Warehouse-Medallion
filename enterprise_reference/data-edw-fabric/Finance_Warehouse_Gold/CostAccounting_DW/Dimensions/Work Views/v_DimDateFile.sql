create VIEW [CostAccounting_DW_Wrk].[v_DimDateFile]
AS
    SELECT
        df.DateID                                                                         AS [Transaction Date],
        CAST(df.FiscalYear as VARCHAR(4))                                                                                 AS [Fiscal Year],
        CAST(df.FiscalWeek as VARCHAR(2))                                                                                 AS [Fiscal Week],
        CAST(df.FiscalMonth as VARCHAR(2))                                                                                AS [Fiscal Month],
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
        END                                                                                                             AS [Fiscal Quarter],
        CAST(TRIM(CAST(DATEPART(yy, df.DateID) AS CHAR(4))) AS CHAR(4))                                                AS [Calendar Year],
        CAST(TRIM(CAST(SUBSTRING(' ' + CAST(DATEPART(mm, df.DateID) AS CHAR(2)), 2, 2) AS CHAR(2))) AS CHAR(2))        AS [Calendar Month],
        CAST(TRIM(CAST(SUBSTRING(' ' + CAST(DATEPART(ww, df.DateID) AS CHAR(2)), 2, 2) AS CHAR(2))) AS CHAR(2))        AS [Calendar Week],
        CAST(DATEPART(qq, df.DateID) AS CHAR(1))                                                                       AS [Calendar Quarter],
        CASE DATEPART(dw, df.DateID)
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
        END                                                                                                             AS [Week Day],

        -- Included for ordering the [week day] attribute in the cube

        CAST(SUBSTRING(' ' + CAST(DATEPART(dw, df.DateID) AS CHAR(1)), 2, 2) AS CHAR(2))                               AS [WeekdayID],
        CASE DATEPART(dw, df.DateID)
            WHEN 1
                THEN
                'Week Ended,  ' + CONVERT(VARCHAR(13), DATEADD(DAY, 2, df.DateID), 107)
            WHEN 2
                THEN
                'Week Ended,  ' + CONVERT(VARCHAR(13), DATEADD(DAY, 1, df.DateID), 107)
            WHEN 3
                THEN
                'Week Ended,  ' + CONVERT(VARCHAR(13), df.DateID, 107)
            WHEN 4
                THEN
                'Week Ended,  ' + CONVERT(VARCHAR(13), DATEADD(DAY, 6, df.DateID), 107)
            WHEN 5
                THEN
                'Week Ended,  ' + CONVERT(VARCHAR(13), DATEADD(DAY, 5, df.DateID), 107)
            WHEN 6
                THEN
                'Week Ended,  ' + CONVERT(VARCHAR(13), DATEADD(DAY, 4, df.DateID), 107)
            WHEN 7
                THEN
                'Week Ended,  ' + CONVERT(VARCHAR(13), DATEADD(DAY, 3, df.DateID), 107)
        END                                                                                                             AS [Simple Week],

        -- Included for ordering the [simple week] attribute

        CONVERT(
                   INT,
                   ((CAST(DATEPART(yy, df.DateID) AS CHAR(4))
                     + CASE DATEPART(dw, df.DateID)
                           WHEN 1
                               THEN
                               RIGHT(('0' + CAST(DATENAME(wk, df.DateID) AS VARCHAR(2))), 2)
                           WHEN 2
                               THEN
                               RIGHT(('0' + CAST(DATENAME(wk, df.DateID) AS VARCHAR(2))), 2)
                           WHEN 3
                               THEN
                               RIGHT(('0' + CAST(DATENAME(wk, df.DateID) AS VARCHAR(2))), 2)
                           WHEN 4
                               THEN
                               RIGHT(('0' + CAST(DATENAME(wk, df.DateID) + 1 AS VARCHAR(2))), 2)
                           WHEN 5
                               THEN
                               RIGHT(('0' + CAST(DATENAME(wk, df.DateID) + 1 AS VARCHAR(2))), 2)
                           WHEN 6
                               THEN
                               RIGHT(('0' + CAST(DATENAME(wk, df.DateID) + 1 AS VARCHAR(2))), 2)
                           WHEN 7
                               THEN
                               RIGHT(('0' + CAST(DATENAME(wk, df.DateID) + 1 AS VARCHAR(2))), 2)
                       END
                    )
                   )
               )                                                                                                        AS [Simple Week ID],
        CASE
            WHEN DATENAME(dd, df.DateID) < 16
                THEN
                CAST(DATEPART(mm, df.DateID) AS CHAR(2)) + '/1/' + CAST(DATEPART(yy, df.DateID) AS CHAR(4)) + ' - '
                + CAST(DATEPART(mm, df.DateID) AS CHAR(2)) + '/15/' + CAST(DATEPART(yy, df.DateID) AS CHAR(4))
            ELSE
                CAST(DATEPART(mm, df.DateID) AS CHAR(2)) + '/16/' + CAST(DATEPART(yy, df.DateID) AS CHAR(4)) + ' - '
                + CAST(DATEPART(mm, df.DateID) AS CHAR(2)) + CASE
                                                                  WHEN DATEPART(mm, df.DateID) IN (
                                                                                                       4, 6, 9, 11
                                                                                                   )
                                                                      THEN
                                                                      '/30/'
                                                                  WHEN DATEPART(mm, df.DateID) = 2
                                                                       AND DATEPART(yy, df.DateID) % 4 = 0
                                                                      THEN
                                                                      '/29/'
                                                                  WHEN DATEPART(mm, df.DateID) = 2
                                                                      THEN
                                                                      '/28/'
                                                                  ELSE
                                                                      '/31/'
                                                              END + CAST(DATEPART(yy, df.DateID) AS CHAR(4))
        END                                                                                                             AS [Commission Period],
        df.HolidayName                                                                                                      AS [Holiday],
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
                END + ', ' + CAST(df.FiscalYear AS CHAR(4))
             AS [Fiscal Month Desc],

        -- Included for ordering fiscal Month description

        CONVERT(INT, (CAST(df.FiscalYear AS CHAR(4)) + RIGHT(('0' + LTRIM(CAST(df.FiscalMonth AS VARCHAR(2)))), 2)))       AS [Fiscal Month Desc ID],
        CASE DATEPART(mm, df.DateID)
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
                END + ', ' + CAST(DATEPART(yy, df.DateID) AS CHAR(4))
              AS [Calendar Month Desc],
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
                END + ', ' + CAST(df.FiscalYear as CHAR(4))
             AS [Fiscal Quarter Desc],
        'Quarter ' + CAST(DATEPART(qq, df.DateID) AS CHAR(1)) + ', ' + CAST(DATEPART(yy, df.DateID) AS CHAR(4)) AS [Calendar Quarter Desc],
        'Week ' + CAST(df.FiscalWeek as CHAR(2)) + ', ' +cast(df.FiscalYear as CHAR(4))                                                             AS [Fiscal Week Desc],
         CASE DATEPART(dw, df.DateID)
                    WHEN 1
                        THEN
                        CONVERT(VARCHAR(13), DATEADD(DAY, 6, df.DateID), 107)
                    WHEN 2
                        THEN
                        CONVERT(VARCHAR(13), DATEADD(DAY, 5, df.DateID), 107)
                    WHEN 3
                        THEN
                        CONVERT(VARCHAR(13), DATEADD(DAY, 4, df.DateID), 107)
                    WHEN 4
                        THEN
                        CONVERT(VARCHAR(13), DATEADD(DAY, 3, df.DateID), 107)
                    WHEN 5
                        THEN
                        CONVERT(VARCHAR(13), DATEADD(DAY, 2, df.DateID), 107)
                    WHEN 6
                        THEN
                        CONVERT(VARCHAR(13), DATEADD(DAY, 1, df.DateID), 107)
                    WHEN 7
                        THEN
                        CONVERT(VARCHAR(13), df.DateID, 107)
                END
                           AS [Fiscal Week Description],

        -- Included for ordering calendar week description and fiscal week description

        CONVERT(
                   INT,
                   (CAST(DATEPART(yy, df.DateID) AS CHAR(4))
                    + RIGHT(('0' + CAST(DATENAME(wk, df.DateID) AS VARCHAR(2))), 2)
                   )
               )                                                                                                        AS [Calendar Week Desc ID],
        'Week ' + CAST(DATEPART(ww, df.DateID) AS CHAR(2)) + ', ' + CAST(DATEPART(yy, df.DateID) AS CHAR(4))    AS [Calendar Week Desc],

        -- gdm (6/26/18): use new table to get the correct last day of the week when the calendar year turns (keeping old code comented out for reference)

        [Calendar Week Description]      = 'Week Ended,  ' + CONVERT(VARCHAR(13), CalendarWeekLastDate, 107),


        --Included for representing a different date style for fiscal week ended
        CASE DATEPART(dw, df.DateID)
                    WHEN 1
                        THEN
                        CONVERT(VARCHAR(13), DATEADD(DAY, 6, df.DateID), 101)
                    WHEN 2
                        THEN
                        CONVERT(VARCHAR(13), DATEADD(DAY, 5, df.DateID), 101)
                    WHEN 3
                        THEN
                        CONVERT(VARCHAR(13), DATEADD(DAY, 4, df.DateID), 101)
                    WHEN 4
                        THEN
                        CONVERT(VARCHAR(13), DATEADD(DAY, 3, df.DateID), 101)
                    WHEN 5
                        THEN
                        CONVERT(VARCHAR(13), DATEADD(DAY, 2, df.DateID), 101)
                    WHEN 6
                        THEN
                        CONVERT(VARCHAR(13), DATEADD(DAY, 1, df.DateID), 101)
                    WHEN 7
                        THEN
                        CONVERT(VARCHAR(13), df.DateID, 101)
                END
                       AS [Fiscal Week Ended],
        CASE DATEPART(dw, df.DateID)
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
                END + ', ' + CAST(df.DateID AS VARCHAR(12))
           AS [Date Desc],
        'Fiscal ' + CAST(df.FiscalYear as CHAR(4))              AS [Fiscal Year Desc],
        'Calendar ' + CAST(DATEPART(yy, df.DateID) AS CHAR(4))    AS [Calendar Year Desc],
        df.[FiscalWeekYear]
    FROM
        [$(MasterData_Warehouse)].[MasterData_DW].[DimDate_NonRetail] df
    WHERE
     df.DateID  > DATEADD(DAY, -3657, CAST(GETDATE() as DATE)) and  df.FiscalYear is not Null;
