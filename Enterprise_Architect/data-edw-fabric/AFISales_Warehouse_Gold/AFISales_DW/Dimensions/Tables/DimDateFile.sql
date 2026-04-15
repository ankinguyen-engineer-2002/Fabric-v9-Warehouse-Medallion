CREATE TABLE [AFISales_DW].[DimDateFile] (
    [Transaction Date]          DATE         NULL,
    [Fiscal Year]               CHAR (4)     NULL,
    [Fiscal Week]               CHAR (2)     NULL,
    [Fiscal Month]              CHAR (2)     NULL,
    [Fiscal Quarter]            INT          NOT NULL,
    [Calendar Year]             CHAR (4)     NULL,
    [Calendar Month]            CHAR (2)     NULL,
    [Calendar Week]             CHAR (2)     NULL,
    [Calendar Quarter]          CHAR (1)     NULL,
    [CalendarWeekYear]          INT          NULL,
    [FiscalWeekYear]            INT          NULL,
    [Week Day]                  VARCHAR (9)  NULL,
    [WeekdayID]                 CHAR (2)     NULL,
    [Simple Week]               VARCHAR (26) NULL,
    [Simple Week ID]            INT          NULL,
    [Commission Period]         VARCHAR (23) NULL,
    [Holiday]                   VARCHAR (25) NULL,
    [Fiscal Month Desc]         VARCHAR (15) NULL,
    [Fiscal Month Desc ID]      INT          NULL,
    [Calendar Month Desc]       VARCHAR (15) NULL,
    [Fiscal Quarter Desc]       VARCHAR (15) NOT NULL,
    [Calendar Quarter Desc]     VARCHAR (15) NULL,
    [Fiscal Week Desc]          VARCHAR (13) NOT NULL,
    [Fiscal Week Description]   VARCHAR (13) NULL,
    [Calendar Week Desc ID]     INT          NULL,
    [Calendar Week Desc]        VARCHAR (13) NULL,
    [Calendar Week Description] VARCHAR (26) NULL,
    [Fiscal Week Ended]         DATE         NULL,
    [Fiscal Month Ended]        DATE         NULL,
    [Date Desc]                 VARCHAR (17) NULL,
    [Fiscal Year Desc]          VARCHAR (11) NOT NULL,
    [Calendar Year Desc]        VARCHAR (13) NULL,
    [Fiscal Week Indicator]     INT          NULL,
    [Fiscal Month Indicator]    INT          NULL,
    [Fiscal Quarter Indicator]  INT          NULL,
    [Fiscal Year Indicator]     INT          NULL,
    [FiscalYearPeriod]          CHAR (6)     NULL,
    [MapicsDate]                INT          NULL
)


GO
CREATE STATISTICS [Stat_DimADNoticeDetails_TransactionDate]
    ON [AFISales_DW].[DimDateFile]([Transaction Date]);


GO
CREATE STATISTICS [Stat_DimDateFile_WeekdayID]
    ON [AFISales_DW].[DimDateFile]([WeekdayID]);


GO
CREATE STATISTICS [Stat_DimDateFile_Week_Day]
    ON [AFISales_DW].[DimDateFile]([Week Day]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Year_Desc]
    ON [AFISales_DW].[DimDateFile]([Fiscal Year Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Year]
    ON [AFISales_DW].[DimDateFile]([Fiscal Year]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Week_Ended]
    ON [AFISales_DW].[DimDateFile]([Fiscal Week Ended]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Week_Description]
    ON [AFISales_DW].[DimDateFile]([Fiscal Week Description]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Week_Desc]
    ON [AFISales_DW].[DimDateFile]([Fiscal Week Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Week]
    ON [AFISales_DW].[DimDateFile]([Fiscal Week]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Quarter_Desc]
    ON [AFISales_DW].[DimDateFile]([Fiscal Quarter Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Quarter]
    ON [AFISales_DW].[DimDateFile]([Fiscal Quarter]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Month_Desc]
    ON [AFISales_DW].[DimDateFile]([Fiscal Month Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Month]
    ON [AFISales_DW].[DimDateFile]([Fiscal Month]);


GO
CREATE STATISTICS [Stat_DimDateFile_Date_Desc]
    ON [AFISales_DW].[DimDateFile]([Date Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Year_Desc]
    ON [AFISales_DW].[DimDateFile]([Calendar Year Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Year]
    ON [AFISales_DW].[DimDateFile]([Calendar Year]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Week_Description]
    ON [AFISales_DW].[DimDateFile]([Calendar Week Description]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Week_Desc_ID]
    ON [AFISales_DW].[DimDateFile]([Calendar Week Desc ID]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Week_Desc]
    ON [AFISales_DW].[DimDateFile]([Calendar Week Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Week]
    ON [AFISales_DW].[DimDateFile]([Calendar Week]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Quarter_Desc]
    ON [AFISales_DW].[DimDateFile]([Calendar Quarter Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Quarter]
    ON [AFISales_DW].[DimDateFile]([Calendar Quarter]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Month_Desc]
    ON [AFISales_DW].[DimDateFile]([Calendar Month Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Month]
    ON [AFISales_DW].[DimDateFile]([Calendar Month]);

