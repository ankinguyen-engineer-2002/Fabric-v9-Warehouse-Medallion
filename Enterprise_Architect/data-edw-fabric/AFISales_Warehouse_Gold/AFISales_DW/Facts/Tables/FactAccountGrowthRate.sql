CREATE TABLE [AFISales_DW].[FactAccountGrowthRate] (
    [AccountGrowthID]                VARCHAR (50)    NOT NULL,
    [AccountShiptoNumber]            CHAR (13)       NULL,
    [AddressID]                      INT             NULL,
    [SalesTerritoryID]               BIGINT          NULL,
    [CustomerAccountNumber]          CHAR (8)        NOT NULL,
    [RepID]                          CHAR (5)        NOT NULL,
    [PrevYearAmountOrdered]          DECIMAL (13,3)  NULL,  -- money
    [CurrentYearAmountOrdered]       DECIMAL (13,3)  NULL,  -- money
    [PrevYearMonthAmountOrdered]     DECIMAL (13,3)  NULL,  -- money
    [CurrentYearMonthAmountOrdered]  DECIMAL (13,3)  NULL,  -- money
    [PrevYearWeekAmountOrdered]      DECIMAL (13,3)  NULL,  -- money
    [CurrentYearWeekAmountOrdered]   DECIMAL (13,3)  NULL  -- money
)

GO
CREATE STATISTICS [Stat_FactAccountGrowthRate_SalesTerritoryID]
    ON [AFISales_DW].[FactAccountGrowthRate]([SalesTerritoryID]);


GO
CREATE STATISTICS [Stat_FactAccountGrowthRate_RepID]
    ON [AFISales_DW].[FactAccountGrowthRate]([RepID]);


GO
CREATE STATISTICS [Stat_FactAccountGrowthRate_AddressID]
    ON [AFISales_DW].[FactAccountGrowthRate]([AddressID]);


GO
CREATE STATISTICS [Stat_FactAccountGrowthRate_AccountShiptoNumber]
    ON [AFISales_DW].[FactAccountGrowthRate]([AccountShiptoNumber]);


GO
CREATE STATISTICS [Stat_FactAccountGrowthRate_AccountGrowthID]
    ON [AFISales_DW].[FactAccountGrowthRate]([AccountGrowthID]);

