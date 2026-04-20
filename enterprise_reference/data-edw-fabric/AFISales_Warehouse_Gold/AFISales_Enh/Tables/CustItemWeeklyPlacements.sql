CREATE TABLE [AFISales_Enh].[CustItemWeeklyPlacements] (
    [CustomerNumber] CHAR (8)        NOT NULL,
    [ShiptoNumber]   CHAR (4)        NOT NULL,
    [ItemSKU]        VARCHAR (15)    NOT NULL,
    [ItemStatus]     CHAR (1)        NULL,
    [Division]       CHAR (1)        NOT NULL,
    [YearWeek]       INT             NOT NULL,
    [Quantity]       DECIMAL (10, 2) NULL,
    [Amount]         DECIMAL (10, 2) NULL,
    [Placement]      SMALLINT        NULL,
    [Gained]         SMALLINT        NULL,
    [Lost]           SMALLINT        NULL,
    [AtRisk]         SMALLINT        NULL,
    [Current]        SMALLINT        NULL,
    [Year]           INT             NULL,
    [Week]           INT             NULL
)


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_YearWeek]
    ON [AFISales_Enh].[CustItemWeeklyPlacements]([YearWeek]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_ShiptoNumber]
    ON [AFISales_Enh].[CustItemWeeklyPlacements]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_ItemStatus]
    ON [AFISales_Enh].[CustItemWeeklyPlacements]([ItemStatus]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_ItemSKU]
    ON [AFISales_Enh].[CustItemWeeklyPlacements]([ItemSKU]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_Division]
    ON [AFISales_Enh].[CustItemWeeklyPlacements]([Division]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_CustomerNumber]
    ON [AFISales_Enh].[CustItemWeeklyPlacements]([CustomerNumber]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_Year]
    ON [AFISales_Enh].[CustItemWeeklyPlacements]([Year]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_Week]
    ON [AFISales_Enh].[CustItemWeeklyPlacements]([Week]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_Quantity]
    ON [AFISales_Enh].[CustItemWeeklyPlacements]([Quantity]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_Placement]
    ON [AFISales_Enh].[CustItemWeeklyPlacements]([Placement]);

-- Write your own SQL object definition here, and it'll be included in your package.
