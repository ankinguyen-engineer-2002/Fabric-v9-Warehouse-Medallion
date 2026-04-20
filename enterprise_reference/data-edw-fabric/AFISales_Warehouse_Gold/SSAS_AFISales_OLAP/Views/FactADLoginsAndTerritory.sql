CREATE VIEW [SSAS_AFISALES_OLAP].[FactADLoginsAndTerritory]
AS
    SELECT
        ADLogins,
        Territory
    FROM
        AFISales_DW.FactADLoginsAndTerritory;