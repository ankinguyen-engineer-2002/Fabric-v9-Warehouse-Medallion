CREATE TABLE [AFISales_Enh].[DailyPlacements] (
    [CustomerNumber]  CHAR (8)     NOT NULL,
    [ShiptoNumber]    CHAR (4)     NOT NULL,
    [ItemSKU]         VARCHAR (15) NOT NULL,
    [DateOfPlacement] DATE         NOT NULL
)


GO
CREATE STATISTICS [Stat_DailyOrderPlacementsDate_ShiptoNumber]
    ON [AFISales_Enh].[DailyPlacements]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_DailyOrderPlacementsDate_ItemSKU]
    ON [AFISales_Enh].[DailyPlacements]([ItemSKU]);


GO
CREATE STATISTICS [Stat_DailyOrderPlacementsDate_DateOfPlacement]
    ON [AFISales_Enh].[DailyPlacements]([DateOfPlacement]);


GO
CREATE STATISTICS [Stat_DailyOrderPlacementsDate_CustomerNumber]
    ON [AFISales_Enh].[DailyPlacements]([CustomerNumber]);


GO
CREATE STATISTICS [Stat_DailyPlacements_DateOfPlacement]
    ON [AFISales_Enh].[DailyPlacements]([DateOfPlacement]);

-- Write your own SQL object definition here, and it'll be included in your package.
