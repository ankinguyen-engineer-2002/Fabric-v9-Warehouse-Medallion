CREATE TABLE [Email_Marketing].[DimDate]
    (
        [FiscalDate]           [DATE]        NULL,
        [FiscalWeek]           [SMALLINT]    NULL,
        [FiscalDayOfWeek]      [SMALLINT]    NULL,
        [FiscalWeekYear]       [INT]         NULL,
        [FiscalWeekFirstDate]  [DATE]        NULL,
        [FiscalWeekLastDate]   [DATE]        NULL,
        [FiscalMonth]          [SMALLINT]    NULL,
        [FiscalMonthYear]      [INT]         NULL,
        [FiscalDayOfMonth]     [SMALLINT]    NULL,
        [FiscalWeekOfMonth]    [SMALLINT]    NULL,
        [FiscalMonthFirstDate] [DATE]        NULL,
        [FiscalMonthLastDate]  [DATE]        NULL,
        [FiscalYear]           [SMALLINT]    NULL,
        [FiscalDayOfYear]      [SMALLINT]    NULL,
        [FiscalYearFirstDate]  [DATE]        NULL,
        [FiscalYearLastDate]   [DATE]        NULL,
        [FiscalMonthName]      [VARCHAR](10) NULL,
        [FiscalQuarterName]    [CHAR](6)     NULL,
        [FiscalQuarterYear]    [SMALLINT]    NULL,
        [Thisyear]             [INT]         NOT NULL,
        [CalendarYear]         [SMALLINT]    NULL,
        [CalendarMonth]        [SMALLINT]    NULL,
        [CalendarWeek]         [SMALLINT]    NULL
    );



