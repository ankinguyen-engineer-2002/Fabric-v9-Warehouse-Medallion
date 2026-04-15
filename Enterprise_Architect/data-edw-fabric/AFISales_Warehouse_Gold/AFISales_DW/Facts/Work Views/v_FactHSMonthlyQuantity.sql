CREATE VIEW [AFISales_DW_Wrk].[v_FactHSMonthlyQuantity]
AS
    SELECT
        [MonthlyQuantity] AS [HSMonthlyQuantity],
        [MarketingSpecialist],
        [Item SKU] ,
        [Account],
        [SalesTerritoryID],
        [Market],
        [CustomerNumber],
        [MarketCode]
    FROM
        AFISales_DW.FactMarketCommitments_Current
    WHERE
        [CustomerNumber] NOT IN (
                                 '9946600', '8888600', '8888300'
                             )
        AND MarketingSpecialist = '4014';
GO
