CREATE TABLE [Placements].[DailyPlacements] (
    [CustomerNumber]  CHAR (8)     NOT NULL,
    [ShiptoNumber]    CHAR (4)     NOT NULL,
    [ItemSKU]         VARCHAR (15) NOT NULL,
    [DateOfPlacement] DATE         NOT NULL
)


GO
CREATE STATISTICS [Stat_DailyOrderPlacementsDate_ShiptoNumber]
    ON [Placements].[DailyPlacements]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_DailyOrderPlacementsDate_ItemSKU]
    ON [Placements].[DailyPlacements]([ItemSKU]);


GO
CREATE STATISTICS [Stat_DailyOrderPlacementsDate_DateOfPlacement]
    ON [Placements].[DailyPlacements]([DateOfPlacement]);


GO
CREATE STATISTICS [Stat_DailyOrderPlacementsDate_CustomerNumber]
    ON [Placements].[DailyPlacements]([CustomerNumber]);


GO
CREATE STATISTICS [Stat_DailyPlacements_DateOfPlacement]
    ON [Placements].[DailyPlacements]([DateOfPlacement]);

