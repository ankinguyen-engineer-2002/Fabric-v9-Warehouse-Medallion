CREATE VIEW [SSAS_AFISALES_OLAP].[FactAssociatesAccounts]
AS
    SELECT
        [Salesman Number],
        [Account And Shipto Number]
    FROM
        AFISales_DW.FactAssociateAccounts;