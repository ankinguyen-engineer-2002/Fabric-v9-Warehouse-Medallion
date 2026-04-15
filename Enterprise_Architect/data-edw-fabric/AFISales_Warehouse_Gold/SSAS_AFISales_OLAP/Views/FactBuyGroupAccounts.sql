CREATE VIEW [SSAS_AFISALES_OLAP].[FactBuyGroupAccounts]
AS
    select
        AccountAndShipto, bmebgcode
    FROM AFISales_DW.FactBuyGroupAccounts;