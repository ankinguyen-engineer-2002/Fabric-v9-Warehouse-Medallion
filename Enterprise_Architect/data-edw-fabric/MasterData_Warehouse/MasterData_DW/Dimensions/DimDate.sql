CREATE TABLE [MasterData_DW].[DimDate] (
    [DateKey]                  INT          NOT NULL,
    [MapicsDate]               INT          NULL,
    [DateID]                   DATE         NOT NULL,
    [DateTimeID]               DATE         NOT NULL,
    [CalendarDate]             DATE         NOT NULL,
    [CalendarDateName]         VARCHAR (20) NULL,
    [CalendarDateIndicator]    INT          NULL,
    [CalendarWeek]             INT      NULL,
    [CalendarWeekIndicator]    INT          NULL,
    [CalendarWeekYear]         INT          NULL,
    [CalendarWeekYearName]     VARCHAR (25) NULL,
    [CalendarDayOfWeek]        INT      NULL,
    [CalendarDayOfWeekName]    VARCHAR (10) NULL,
    [CalendarWeekFirstDate]    DATE         NULL,
    [CalendarWeekLastDate]     DATE         NULL,
    [CalendarMonth]            INT      NULL,
    [CalendarMonthIndicator]   INT          NULL,
    [CalendarMonthYear]        INT          NULL,
    [CalendarMonthName]        VARCHAR (10) NULL,
    [CalendarMonthYearName]    VARCHAR (20) NULL,
    [CalendarDayOfMonth]       INT      NULL,
    [CalendarWeekOfMonth]      INT      NULL,
    [CalendarMonthFirstDate]   DATE         NULL,
    [CalendarMonthLastDate]    DATE         NULL,
    [CalendarQuarter]          INT      NULL,
    [CalendarQuarterName]      CHAR (6)     NULL,
    [CalendarQuarterIndicator] INT          NULL,
    [CalendarQuarterYear]      SMALLINT     NULL,
    [CalendarQuarterYearName]  CHAR (16)    NULL,
    [CalendarSemester]         INT      NULL,
    [CalendarSemesterYear]     SMALLINT     NULL,
    [CalendarYear]             SMALLINT     NULL,
    [CalendarYearName]         CHAR (13)    NULL,
    [CalendarYearIndicator]    INT          NULL,
    [CalendarDayOfYear]        SMALLINT     NULL,
    [FiscalDate]               DATE         NULL,
    [FiscalDateName]           VARCHAR (20) NULL,
    [FiscalDateIndicator]      INT          NULL,
    [FiscalWeek]               INT      NULL,
    [FiscalWeekIndicator]      INT          NULL,
    [FiscalDayOfWeek]          INT      NULL,
    [FiscalDayOfWeekName]      VARCHAR (10) NULL,
    [FiscalWeekYear]           INT          NULL,
    [FiscalWeekYearName]       VARCHAR (25) NULL,
    [FiscalWeekFirstDate]      DATE         NULL,
    [FiscalWeekLastDate]       DATE         NULL,
    [FiscalMonth]              INT      NULL,
    [FiscalMonthIndicator]     INT          NULL,
    [FiscalMonthYear]          INT          NULL,
    [FiscalMonthName]          VARCHAR (10) NULL,
    [FiscalMonthYearName]      VARCHAR (20) NULL,
    [FiscalDayOfMonth]         INT      NULL,
    [FiscalWeekOfMonth]        INT      NULL,
    [FiscalMonthFirstDate]     DATE         NULL,
    [FiscalMonthLastDate]      DATE         NULL,
    [FiscalQuarter]            INT      NULL,
    [FiscalQuarterName]        CHAR (6)     NULL,
    [FiscalQuarterIndicator]   INT          NULL,
    [FiscalQuarterYear]        SMALLINT     NULL,
    [FiscalQuarterYearName]    CHAR (16)    NULL,
    [FiscalSemester]           INT      NULL,
    [FiscalSemesterYear]       SMALLINT     NULL,
    [FiscalYear]               SMALLINT     NULL,
    [FiscalYearName]           CHAR (11)    NULL,
    [FiscalYearIndicator]      INT          NULL,
    [FiscalDayOfYear]          SMALLINT     NULL,
    [FiscalYearFirstDate]      DATE         NULL,
    [FiscalYearLastDate]       DATE         NULL,
    [HolidayIndicator]         VARCHAR (11) NULL,
    [HolidayName]              VARCHAR (50) NULL,
    [WorkingDayIndicator]      VARCHAR (15) NULL,
    [WeekdayWeekend]           VARCHAR (7)  NULL
)


GO
CREATE STATISTICS [Stat_DimDate_FiscalYear]
    ON [MasterData_DW].[DimDate]([FiscalYear]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalWeekYear]
    ON [MasterData_DW].[DimDate]([FiscalWeekYear]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalWeek]
    ON [MasterData_DW].[DimDate]([FiscalWeek]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalQuarterYear]
    ON [MasterData_DW].[DimDate]([FiscalQuarterYear]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalQuarter]
    ON [MasterData_DW].[DimDate]([FiscalQuarter]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalMonthYear]
    ON [MasterData_DW].[DimDate]([FiscalMonthYear]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalMonth]
    ON [MasterData_DW].[DimDate]([FiscalMonth]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalDate]
    ON [MasterData_DW].[DimDate]([FiscalDate]);


GO
CREATE STATISTICS [Stat_DimDate_DateKey]
    ON [MasterData_DW].[DimDate]([DateKey]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarYear]
    ON [MasterData_DW].[DimDate]([CalendarYear]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarWeekYear]
    ON [MasterData_DW].[DimDate]([CalendarWeekYear]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarWeek]
    ON [MasterData_DW].[DimDate]([CalendarWeek]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarQuarterYear]
    ON [MasterData_DW].[DimDate]([CalendarQuarterYear]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarQuarter]
    ON [MasterData_DW].[DimDate]([CalendarQuarter]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarMonthYear]
    ON [MasterData_DW].[DimDate]([CalendarMonthYear]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarMonth]
    ON [MasterData_DW].[DimDate]([CalendarMonth]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarDate]
    ON [MasterData_DW].[DimDate]([CalendarDate]);


GO
CREATE STATISTICS [Stat_DimDate_WorkingDayIndicator]
    ON [MasterData_DW].[DimDate]([WorkingDayIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_WeekdayWeekend]
    ON [MasterData_DW].[DimDate]([WeekdayWeekend]);


GO
CREATE STATISTICS [Stat_DimDate_MapicsDate]
    ON [MasterData_DW].[DimDate]([MapicsDate]);


GO
CREATE STATISTICS [Stat_DimDate_HolidayName]
    ON [MasterData_DW].[DimDate]([HolidayName]);


GO
CREATE STATISTICS [Stat_DimDate_HolidayIndicator]
    ON [MasterData_DW].[DimDate]([HolidayIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalYearName]
    ON [MasterData_DW].[DimDate]([FiscalYearName]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalYearLastDate]
    ON [MasterData_DW].[DimDate]([FiscalYearLastDate]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalYearIndicator]
    ON [MasterData_DW].[DimDate]([FiscalYearIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalYearFirstDate]
    ON [MasterData_DW].[DimDate]([FiscalYearFirstDate]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalWeekYearName]
    ON [MasterData_DW].[DimDate]([FiscalWeekYearName]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalWeekLastDate]
    ON [MasterData_DW].[DimDate]([FiscalWeekLastDate]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalWeekIndicator]
    ON [MasterData_DW].[DimDate]([FiscalWeekIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalWeekFirstDate]
    ON [MasterData_DW].[DimDate]([FiscalWeekFirstDate]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalQuarterYearName]
    ON [MasterData_DW].[DimDate]([FiscalQuarterYearName]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalQuarterIndicator]
    ON [MasterData_DW].[DimDate]([FiscalQuarterIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalMonthYearName]
    ON [MasterData_DW].[DimDate]([FiscalMonthYearName]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalMonthName]
    ON [MasterData_DW].[DimDate]([FiscalMonthName]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalMonthLastDate]
    ON [MasterData_DW].[DimDate]([FiscalMonthLastDate]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalMonthIndicator]
    ON [MasterData_DW].[DimDate]([FiscalMonthIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalMonthFirstDate]
    ON [MasterData_DW].[DimDate]([FiscalMonthFirstDate]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalDayOfWeekName]
    ON [MasterData_DW].[DimDate]([FiscalDayOfWeekName]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalDayOfWeek]
    ON [MasterData_DW].[DimDate]([FiscalDayOfWeek]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalDayOfMonth]
    ON [MasterData_DW].[DimDate]([FiscalDayOfMonth]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalDateName]
    ON [MasterData_DW].[DimDate]([FiscalDateName]);


GO
CREATE STATISTICS [Stat_DimDate_FiscalDateIndicator]
    ON [MasterData_DW].[DimDate]([FiscalDateIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_DateTimeID]
    ON [MasterData_DW].[DimDate]([DateTimeID]);


GO
CREATE STATISTICS [Stat_DimDate_DateID]
    ON [MasterData_DW].[DimDate]([DateID]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarYearName]
    ON [MasterData_DW].[DimDate]([CalendarYearName]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarYearIndicator]
    ON [MasterData_DW].[DimDate]([CalendarYearIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarWeekYearName]
    ON [MasterData_DW].[DimDate]([CalendarWeekYearName]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarWeekLastDate]
    ON [MasterData_DW].[DimDate]([CalendarWeekLastDate]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarWeekIndicator]
    ON [MasterData_DW].[DimDate]([CalendarWeekIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarWeekFirstDate]
    ON [MasterData_DW].[DimDate]([CalendarWeekFirstDate]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarSemesterYear]
    ON [MasterData_DW].[DimDate]([CalendarSemesterYear]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarSemester]
    ON [MasterData_DW].[DimDate]([CalendarSemester]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarQuarterYearName]
    ON [MasterData_DW].[DimDate]([CalendarQuarterYearName]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarQuarterName]
    ON [MasterData_DW].[DimDate]([CalendarQuarterName]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarQuarterIndicator]
    ON [MasterData_DW].[DimDate]([CalendarQuarterIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarMonthYearName]
    ON [MasterData_DW].[DimDate]([CalendarMonthYearName]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarMonthName]
    ON [MasterData_DW].[DimDate]([CalendarMonthName]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarMonthLastDate]
    ON [MasterData_DW].[DimDate]([CalendarMonthLastDate]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarMonthIndicator]
    ON [MasterData_DW].[DimDate]([CalendarMonthIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarMonthFirstDate]
    ON [MasterData_DW].[DimDate]([CalendarMonthFirstDate]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarDayOfWeekName]
    ON [MasterData_DW].[DimDate]([CalendarDayOfWeekName]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarDayOfWeek]
    ON [MasterData_DW].[DimDate]([CalendarDayOfWeek]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarDateName]
    ON [MasterData_DW].[DimDate]([CalendarDateName]);


GO
CREATE STATISTICS [Stat_DimDate_CalendarDateIndicator]
    ON [MasterData_DW].[DimDate]([CalendarDateIndicator]);

