CREATE TABLE [AFISales_Enh].[InvoiceWeeklyPlacements] (
    [CustomerNumber] CHAR (8)        NOT NULL,
    [ShiptoNumber]   CHAR (4)        NOT NULL,
    [ItemSKU]        VARCHAR (15)    NOT NULL,
    [ItemStatus]     CHAR (1)        NULL,
    [Division]       CHAR (1)        NOT NULL,
    [YearWeek]       INT             NOT NULL,
    [Quantity]       DECIMAL (10, 2) NULL,
    [Amount]         DECIMAL(13, 3) NULL,
    [Placement]      SMALLINT        NULL,
    [Gained]         SMALLINT        NULL,
    [Lost]           SMALLINT        NULL,
    [AtRisk]         SMALLINT        NULL,
    [Current]        SMALLINT        NULL,
    [Year]           INT             NULL,
    [Week]           INT             NULL
)

GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_YearWeek]
    ON [AFISales_Enh].[InvoiceWeeklyPlacements]([YearWeek]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_ShiptoNumber]
    ON [AFISales_Enh].[InvoiceWeeklyPlacements]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_ItemStatus]
    ON [AFISales_Enh].[InvoiceWeeklyPlacements]([ItemStatus]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_ItemSKU]
    ON [AFISales_Enh].[InvoiceWeeklyPlacements]([ItemSKU]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_Division]
    ON [AFISales_Enh].[InvoiceWeeklyPlacements]([Division]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_CustomerNumber]
    ON [AFISales_Enh].[InvoiceWeeklyPlacements]([CustomerNumber]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_Year]
    ON [AFISales_Enh].[InvoiceWeeklyPlacements]([Year]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_Week]
    ON [AFISales_Enh].[InvoiceWeeklyPlacements]([Week]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_Quantity]
    ON [AFISales_Enh].[InvoiceWeeklyPlacements]([Quantity]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_Placement]
    ON [AFISales_Enh].[InvoiceWeeklyPlacements]([Placement]);

-- Write your own SQL object definition here, and it'll be included in your package.
