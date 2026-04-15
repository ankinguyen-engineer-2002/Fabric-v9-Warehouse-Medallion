CREATE TABLE [CostAccounting_DW].[DimDateFile] (
    [Transaction Date]          DATE         NOT NULL,
    [Fiscal Year]               VARCHAR (4)  NOT NULL,
    [Fiscal Week]               VARCHAR (2)  NOT NULL,
    [Fiscal Month]              VARCHAR (2)  NOT NULL,
    [Fiscal Quarter]            INT          NOT NULL,
    [Calendar Year]             CHAR    (4)  NULL,
    [Calendar Month]            CHAR    (2)  NULL,
    [Calendar Week]             CHAR    (2)  NULL,
    [Calendar Quarter]          CHAR    (1)  NULL,
    [Week Day]                  VARCHAR (9)  NULL,
    [WeekdayID]                 CHAR    (2)  NULL,
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
    [Fiscal Week Ended]         VARCHAR (13) NULL,
    [Date Desc]                 VARCHAR (17) NULL,
    [Fiscal Year Desc]          VARCHAR (11) NOT NULL,
    [Calendar Year Desc]        VARCHAR (13) NULL,
    [FiscalWeekYear]            INT          NOT NULL
);


GO
CREATE STATISTICS [Stat_DimDateFile_TransactionDate]
    ON [CostAccounting_DW].[DimDateFile]([Transaction Date]);


GO
CREATE STATISTICS [Stat_DimDateFile_WeekdayID]
    ON [CostAccounting_DW].[DimDateFile]([WeekdayID]);


GO
CREATE STATISTICS [Stat_DimDateFile_Week_Day]
    ON [CostAccounting_DW].[DimDateFile]([Week Day]);


GO
CREATE STATISTICS [Stat_DimDateFile_Transaction_Date]
    ON [CostAccounting_DW].[DimDateFile]([Transaction Date]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Year_Desc]
    ON [CostAccounting_DW].[DimDateFile]([Fiscal Year Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Year]
    ON [CostAccounting_DW].[DimDateFile]([Fiscal Year]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Week_Description]
    ON [CostAccounting_DW].[DimDateFile]([Fiscal Week Description]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Week_Desc]
    ON [CostAccounting_DW].[DimDateFile]([Fiscal Week Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Week]
    ON [CostAccounting_DW].[DimDateFile]([Fiscal Week]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Quarter_Desc]
    ON [CostAccounting_DW].[DimDateFile]([Fiscal Quarter Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Quarter]
    ON [CostAccounting_DW].[DimDateFile]([Fiscal Quarter]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Month_Desc]
    ON [CostAccounting_DW].[DimDateFile]([Fiscal Month Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Month]
    ON [CostAccounting_DW].[DimDateFile]([Fiscal Month]);


GO
CREATE STATISTICS [Stat_DimDateFile_Date_Desc]
    ON [CostAccounting_DW].[DimDateFile]([Date Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Year_Desc]
    ON [CostAccounting_DW].[DimDateFile]([Calendar Year Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Year]
    ON [CostAccounting_DW].[DimDateFile]([Calendar Year]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Quarter_Desc]
    ON [CostAccounting_DW].[DimDateFile]([Calendar Quarter Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Quarter]
    ON [CostAccounting_DW].[DimDateFile]([Calendar Quarter]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Month_Desc]
    ON [CostAccounting_DW].[DimDateFile]([Calendar Month Desc]);


GO
CREATE STATISTICS [Stat_DimDateFile_Calendar_Month]
    ON [CostAccounting_DW].[DimDateFile]([Calendar Month]);


GO
CREATE STATISTICS [Stat_DimDateFile_Fiscal_Week_Ended]
    ON [CostAccounting_DW].[DimDateFile]([Fiscal Week Ended]);

