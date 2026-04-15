CREATE TABLE [Placements].[CustItemMonthlyPlacements] (
    [CustomerNumber] VARCHAR (8)     NOT NULL,
    [ShiptoNumber]   VARCHAR (4)     NOT NULL,
    [ItemSKU]        VARCHAR (15)    NOT NULL,
    [ItemStatus]     CHAR (1)        NULL,
    [Division]       CHAR (1)        NOT NULL,
    [YearMonth]      INT             NOT NULL,
    [Quantity]       DECIMAL (10, 2) NULL,
    [Amount]         DECIMAL (10, 2) NULL,
    [Placement]      SMALLINT        NULL,
    [Gained]         SMALLINT        NULL,
    [lost]           SMALLINT        NULL,
    [AtRisk]         SMALLINT        NULL,
    [Current]        SMALLINT        NULL,
    [Year]           INT             NULL,
    [Month]          INT             NULL
)



GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_YearMonth]
    ON [Placements].[CustItemMonthlyPlacements]([YearMonth]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_ShiptoNumber]
    ON [Placements].[CustItemMonthlyPlacements]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_ItemStatus]
    ON [Placements].[CustItemMonthlyPlacements]([ItemStatus]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_ItemSKU]
    ON [Placements].[CustItemMonthlyPlacements]([ItemSKU]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Division]
    ON [Placements].[CustItemMonthlyPlacements]([Division]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_CustomerNumber]
    ON [Placements].[CustItemMonthlyPlacements]([CustomerNumber]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Year]
    ON [Placements].[CustItemMonthlyPlacements]([Year]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Quantity]
    ON [Placements].[CustItemMonthlyPlacements]([Quantity]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Placement]
    ON [Placements].[CustItemMonthlyPlacements]([Placement]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Month]
    ON [Placements].[CustItemMonthlyPlacements]([Month]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Gained]
    ON [Placements].[CustItemMonthlyPlacements]([Gained]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Current]
    ON [Placements].[CustItemMonthlyPlacements]([Current]);

