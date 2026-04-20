CREATE VIEW [AFISales_DW_Wrk].[v_FactNoraMonthlyQuantity]
AS
    SELECT
        CASE
            WHEN CustomerNumber = '2972900'
                THEN
                [MonthlyQuantity]
            ELSE
                0
        END + CASE
                  WHEN CustomerNumber = '3352200'
                      THEN
                      [MonthlyQuantity]
                  ELSE
                      0
              END + CASE
                        WHEN MarketingSpecialist = '2616'
                            THEN
                            [MonthlyQuantity]
                        ELSE
                            0
                    END AS [NoraMonthlyQuantity],
        [MarketingSpecialist],
        [Item SKU],
        [Account],
        [SalesTerritoryID],
        [Market],
        [CustomerNumber],
        [MarketCode]
    FROM
        AFISales_DW.FactMarketCommitments_Current;
GO


