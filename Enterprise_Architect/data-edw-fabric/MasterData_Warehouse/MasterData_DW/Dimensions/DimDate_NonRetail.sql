	CREATE TABLE [MasterData_DW].[DimDate_NonRetail] (
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
CREATE STATISTICS [Stat_DimDate_NonRetail_WorkingDayIndicator]
    ON [MasterData_DW].[DimDate_NonRetail]([WorkingDayIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_WeekdayWeekend]
    ON [MasterData_DW].[DimDate_NonRetail]([WeekdayWeekend]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_MapicsDate]
    ON [MasterData_DW].[DimDate_NonRetail]([MapicsDate]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_HolidayName]
    ON [MasterData_DW].[DimDate_NonRetail]([HolidayName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_HolidayIndicator]
    ON [MasterData_DW].[DimDate_NonRetail]([HolidayIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalYearName]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalYearName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalYearLastDate]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalYearLastDate]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalYearIndicator]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalYearIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalYearFirstDate]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalYearFirstDate]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalYear]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalYear]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalWeekYearName]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalWeekYearName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalWeekYear]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalWeekYear]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalWeekLastDate]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalWeekLastDate]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalWeekIndicator]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalWeekIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalWeekFirstDate]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalWeekFirstDate]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalWeek]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalWeek]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalQuarterYearName]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalQuarterYearName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalQuarterYear]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalQuarterYear]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalQuarterIndicator]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalQuarterIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalQuarter]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalQuarter]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalMonthYearName]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalMonthYearName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalMonthYear]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalMonthYear]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalMonthName]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalMonthName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalMonthLastDate]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalMonthLastDate]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalMonthIndicator]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalMonthIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalMonthFirstDate]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalMonthFirstDate]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalMonth]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalMonth]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalDayOfWeekName]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalDayOfWeekName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalDayOfWeek]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalDayOfWeek]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalDayOfMonth]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalDayOfMonth]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalDateName]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalDateName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalDateIndicator]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalDateIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_FiscalDate]
    ON [MasterData_DW].[DimDate_NonRetail]([FiscalDate]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_DateTimeID]
    ON [MasterData_DW].[DimDate_NonRetail]([DateTimeID]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_DateKey]
    ON [MasterData_DW].[DimDate_NonRetail]([DateKey]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_DateID]
    ON [MasterData_DW].[DimDate_NonRetail]([DateID]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarYearName]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarYearName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarYearIndicator]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarYearIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarYear]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarYear]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarWeekYearName]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarWeekYearName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarWeekYear]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarWeekYear]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarWeekLastDate]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarWeekLastDate]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarWeekIndicator]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarWeekIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarWeekFirstDate]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarWeekFirstDate]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarWeek]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarWeek]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarSemesterYear]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarSemesterYear]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarSemester]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarSemester]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarQuarterYearName]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarQuarterYearName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarQuarterYear]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarQuarterYear]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarQuarterName]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarQuarterName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarQuarterIndicator]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarQuarterIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarQuarter]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarQuarter]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarMonthYearName]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarMonthYearName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarMonthYear]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarMonthYear]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarMonthName]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarMonthName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarMonthLastDate]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarMonthLastDate]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarMonthIndicator]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarMonthIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarMonthFirstDate]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarMonthFirstDate]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarMonth]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarMonth]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarDayOfWeekName]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarDayOfWeekName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarDayOfWeek]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarDayOfWeek]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarDateName]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarDateName]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarDateIndicator]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarDateIndicator]);


GO
CREATE STATISTICS [Stat_DimDate_NonRetail_CalendarDate]
    ON [MasterData_DW].[DimDate_NonRetail]([CalendarDate]);

