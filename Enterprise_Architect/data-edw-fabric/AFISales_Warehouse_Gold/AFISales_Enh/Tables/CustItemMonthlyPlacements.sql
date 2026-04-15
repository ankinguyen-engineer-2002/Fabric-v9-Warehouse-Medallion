CREATE TABLE [AFISales_Enh].[CustItemMonthlyPlacements] (
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
    ON [AFISales_Enh].[CustItemMonthlyPlacements]([YearMonth]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_ShiptoNumber]
    ON [AFISales_Enh].[CustItemMonthlyPlacements]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_ItemStatus]
    ON [AFISales_Enh].[CustItemMonthlyPlacements]([ItemStatus]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_ItemSKU]
    ON [AFISales_Enh].[CustItemMonthlyPlacements]([ItemSKU]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Division]
    ON [AFISales_Enh].[CustItemMonthlyPlacements]([Division]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_CustomerNumber]
    ON [AFISales_Enh].[CustItemMonthlyPlacements]([CustomerNumber]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Year]
    ON [AFISales_Enh].[CustItemMonthlyPlacements]([Year]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Quantity]
    ON [AFISales_Enh].[CustItemMonthlyPlacements]([Quantity]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Placement]
    ON [AFISales_Enh].[CustItemMonthlyPlacements]([Placement]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Month]
    ON [AFISales_Enh].[CustItemMonthlyPlacements]([Month]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Gained]
    ON [AFISales_Enh].[CustItemMonthlyPlacements]([Gained]);


GO
CREATE STATISTICS [Stat_CustItemMonthlyPlacements_Current]
    ON [AFISales_Enh].[CustItemMonthlyPlacements]([Current]);

-- Write your own SQL object definition here, and it'll be included in your package.
