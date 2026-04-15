CREATE VIEW [SSAS_AFISALES_OLAP].[FactADLoginsAndCustomer]
AS
    SELECT
        ADLogins,
        [Account And Shipto Number]
    FROM
        AFISales_DW.FactADLoginsAndCustomer;