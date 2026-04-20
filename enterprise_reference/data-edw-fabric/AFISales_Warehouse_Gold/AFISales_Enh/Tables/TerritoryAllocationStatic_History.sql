CREATE TABLE [AFISales_Enh].[TerritoryAllocationStatic_History] (
    [SnapshotDate]           DATETIME2 (6) NULL,   --DATETIME
    [DivisionCode]           CHAR(1)       NULL,   --Division
    [RegionCode]             CHAR(3)       NULL,   --RegCode
    [SalesCategory]          CHAR(3)       NULL,   --SlsCat
    [TerritoryCode]          CHAR(5)       NULL,   --TerrCd
    [RepID]                  CHAR(5)       NULL,
    [CommissionSplitPercent] DECIMAL(8, 4) NULL,    --CPercent
    [SalesSplitSpercent]     DECIMAL(8, 4) NULL    --SPercent
)


GO
CREATE STATISTICS [Stat_TerritoryAllocationStatic_History_RepID]
    ON [AFISales_Enh].[TerritoryAllocationStatic_History]([RepID]);


GO
CREATE STATISTICS [Stat_TerritoryAllocationStatic_History_SnapshotDate]
    ON [AFISales_Enh].[TerritoryAllocationStatic_History]([SnapshotDate]);

