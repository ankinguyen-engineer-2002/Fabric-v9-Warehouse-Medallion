CREATE TABLE [Placements].[CustItemWeeklyPlacements] (
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
    ON [Placements].[CustItemWeeklyPlacements]([YearWeek]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_ShiptoNumber]
    ON [Placements].[CustItemWeeklyPlacements]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_ItemStatus]
    ON [Placements].[CustItemWeeklyPlacements]([ItemStatus]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_ItemSKU]
    ON [Placements].[CustItemWeeklyPlacements]([ItemSKU]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_Division]
    ON [Placements].[CustItemWeeklyPlacements]([Division]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_CustomerNumber]
    ON [Placements].[CustItemWeeklyPlacements]([CustomerNumber]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_Year]
    ON [Placements].[CustItemWeeklyPlacements]([Year]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_Week]
    ON [Placements].[CustItemWeeklyPlacements]([Week]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_Quantity]
    ON [Placements].[CustItemWeeklyPlacements]([Quantity]);


GO
CREATE STATISTICS [Stat_CustItemWeeklyPlacements_Placement]
    ON [Placements].[CustItemWeeklyPlacements]([Placement]);

