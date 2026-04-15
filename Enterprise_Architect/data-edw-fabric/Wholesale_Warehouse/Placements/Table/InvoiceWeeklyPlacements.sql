CREATE TABLE [Placements].[InvoiceWeeklyPlacements] (
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
    ON [Placements].[InvoiceWeeklyPlacements]([YearWeek]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_ShiptoNumber]
    ON [Placements].[InvoiceWeeklyPlacements]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_ItemStatus]
    ON [Placements].[InvoiceWeeklyPlacements]([ItemStatus]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_ItemSKU]
    ON [Placements].[InvoiceWeeklyPlacements]([ItemSKU]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_Division]
    ON [Placements].[InvoiceWeeklyPlacements]([Division]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_CustomerNumber]
    ON [Placements].[InvoiceWeeklyPlacements]([CustomerNumber]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_Year]
    ON [Placements].[InvoiceWeeklyPlacements]([Year]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_Week]
    ON [Placements].[InvoiceWeeklyPlacements]([Week]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_Quantity]
    ON [Placements].[InvoiceWeeklyPlacements]([Quantity]);


GO
CREATE STATISTICS [Stat_InvoiceWeeklyPlacements_Placement]
    ON [Placements].[InvoiceWeeklyPlacements]([Placement]);

