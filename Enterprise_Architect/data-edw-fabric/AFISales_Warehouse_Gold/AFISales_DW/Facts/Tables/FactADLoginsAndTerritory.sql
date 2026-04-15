CREATE TABLE [AFISales_DW].[FactADLoginsAndTerritory] (
    [RowID]     BIGINT       NOT NULL, --  IDENTITY (1, 1)
    [ADLogins]  VARCHAR (25) NOT NULL,
    [Territory] CHAR (10)    NOT NULL
)



GO
CREATE STATISTICS [Stat_FactADLoginsAndTerritory_Territory]
    ON [AFISales_DW].[FactADLoginsAndTerritory]([Territory]);


GO
CREATE STATISTICS [Stat_FactADLoginsAndTerritory_RowID]
    ON [AFISales_DW].[FactADLoginsAndTerritory]([RowID]);


GO
CREATE STATISTICS [Stat_FactADLoginsAndTerritory_ADLogins]
    ON [AFISales_DW].[FactADLoginsAndTerritory]([ADLogins]);

