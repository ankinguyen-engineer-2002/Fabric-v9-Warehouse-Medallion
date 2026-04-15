CREATE TABLE [AFISales_DW].[DimTerritory] (
    [Territory] CHAR (10) NULL
)


GO
CREATE STATISTICS [Stat_DimTerritory]
    ON [AFISales_DW].[DimTerritory]([Territory]);

