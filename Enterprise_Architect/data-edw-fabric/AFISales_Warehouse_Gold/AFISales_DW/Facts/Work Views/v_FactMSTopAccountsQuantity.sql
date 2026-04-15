CREATE VIEW [AFISales_DW_Wrk].[v_FactMSTopAccountsQuantity]
AS
    SELECT
        [MonthlyQuantity] AS [MSTopAccountsQuantity],
        [MarketingSpecialist],
        [Item SKU] as [Item Sku],
        [Account],
        [SalesTerritoryID],
        [Market],
        [CustomerNumber],
        [MarketCode]
    FROM
        AFISales_DW.FactMarketCommitments_Current
    WHERE
        [CustomerNumber] NOT IN (
                                 '2972900', '3352200'
                             )
        AND MarketingSpecialist <> '4014'
        AND [Account] NOT LIKE 'All Customers';
GO
