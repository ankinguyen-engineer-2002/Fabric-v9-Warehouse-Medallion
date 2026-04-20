CREATE VIEW [Email_Marketing_Wrk].v_DimDate
AS
    SELECT
        FiscalDate,
        FiscalWeek,
        FiscalDayOfWeek,
        FiscalWeekYear,
        FiscalWeekFirstDate,
        FiscalWeekLastDate,
        FiscalMonth,
        FiscalMonthYear,
        FiscalDayOfMonth,
        FiscalWeekOfMonth,
        FiscalMonthFirstDate,
        FiscalMonthLastDate,
        FiscalYear,
        FiscalDayOfYear,
        FiscalYearFirstDate,
        FiscalYearLastDate,
        FiscalMonthName,
        FiscalQuarterName,
        FiscalQuarterYear,
        1                   AS Thisyear,
        CalendarYear,
        CalendarMonth,
        CalendarWeek
    FROM
        [$(MasterData_Warehouse)].[MasterData_DW].[DimDate]

    WHERE
        ISNULL(FiscalDate, '') <> ''
        AND [FiscalYear] =
            (
                SELECT
                    MIN([FiscalYear])
                FROM
                    [$(MasterData_Warehouse)].[MasterData_DW].[DimDate]

                WHERE
                    CAST([FiscalDate] AS DATE) = CAST(GETDATE() AS DATE)
            )
        AND [FiscalDayOfYear] <=
            (
                SELECT
                    [FiscalDayOfYear]
                FROM
                    [$(MasterData_Warehouse)].[MasterData_DW].[DimDate]

                WHERE
                    CAST([FiscalDate] AS DATE) = CAST(GETDATE() AS DATE)
            )
    UNION
    SELECT
        FiscalDate,
        FiscalWeek,
        FiscalDayOfWeek,
        FiscalWeekYear,
        FiscalWeekFirstDate,
        FiscalWeekLastDate,
        FiscalMonth,
        FiscalMonthYear,
        FiscalDayOfMonth,
        FiscalWeekOfMonth,
        FiscalMonthFirstDate,
        FiscalMonthLastDate,
        FiscalYear,
        FiscalDayOfYear,
        FiscalYearFirstDate,
        FiscalYearLastDate,
        FiscalMonthName,
        FiscalQuarterName,
        FiscalQuarterYear,
        0                   AS ThisYear,
        CalendarYear,
        CalendarMonth,
        CalendarWeek
    FROM
        [$(MasterData_Warehouse)].[MasterData_DW].[DimDate]

    WHERE
        ISNULL(FiscalDate, '') <> ''
        AND [FiscalYear] =
            (
                SELECT
                    MIN([FiscalYear]) - 1
                FROM
                    [$(MasterData_Warehouse)].[MasterData_DW].[DimDate]

                WHERE
                    CAST([FiscalDate] AS DATE) = CAST(GETDATE() AS DATE)
            )
    UNION
    SELECT
        FiscalDate,
        FiscalWeek,
        FiscalDayOfWeek,
        FiscalWeekYear,
        FiscalWeekFirstDate,
        FiscalWeekLastDate,
        FiscalMonth,
        FiscalMonthYear,
        FiscalDayOfMonth,
        FiscalWeekOfMonth,
        FiscalMonthFirstDate,
        FiscalMonthLastDate,
        FiscalYear,
        FiscalDayOfYear,
        FiscalYearFirstDate,
        FiscalYearLastDate,
        FiscalMonthName,
        FiscalQuarterName,
        FiscalQuarterYear,
        0                   AS ThisYear,
        CalendarYear,
        CalendarMonth,
        CalendarWeek
    FROM
        [$(MasterData_Warehouse)].[MasterData_DW].[DimDate]

    WHERE
        ISNULL(FiscalDate, '') <> ''
        AND [FiscalYear] =
            (
                SELECT
                    MIN([FiscalYear]) - 2
                FROM
                     [$(MasterData_Warehouse)].[MasterData_DW].[DimDate]

                WHERE
                    CAST([FiscalDate] AS DATE) = CAST(GETDATE() AS DATE)
            );