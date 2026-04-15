CREATE TABLE [AFISales_Enh].[TerritoryAllocationStatic]
    (
        [DivisionCode]           CHAR(1)       NULL,   --Division
        [RegionCode]             CHAR(3)       NULL,   --RegCode
        [SalesCategory]          CHAR(3)       NULL,   --SlsCat
        [TerritoryCode]          CHAR(5)       NULL,   --TerrCd
        [RepID]                  CHAR(5)       NULL,
        [CommissionSplitPercent] DECIMAL(8, 4) NULL,    --CPercent
        [SalesSplitPercent]      DECIMAL(8, 4) NULL    --SPercent
    );


GO
CREATE STATISTICS [Stat_TerritoryAllocationStatic_TerritoryCode]
    ON [AFISales_Enh].[TerritoryAllocationStatic]
    (
        [TerritoryCode]
    );


GO
CREATE STATISTICS [Stat_TerritoryAllocationStatic_SalesCategory]
    ON [AFISales_Enh].[TerritoryAllocationStatic]
    (
        [SalesCategory]
    );


GO
CREATE STATISTICS [Stat_TerritoryAllocationStatic_RepID]
    ON [AFISales_Enh].[TerritoryAllocationStatic]
    (
        [RepID]
    );


GO
CREATE STATISTICS [Stat_TerritoryAllocationStatic_RegionCode]
    ON [AFISales_Enh].[TerritoryAllocationStatic]
    (
        [RegionCode]
    );


GO
CREATE STATISTICS [Stat_TerritoryAllocationStatic_DivisionCode]
    ON [AFISales_Enh].[TerritoryAllocationStatic]
    (
        [DivisionCode]
    );


GO


