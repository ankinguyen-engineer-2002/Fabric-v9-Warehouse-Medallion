CREATE TABLE [AFISales_DW].[FactNoraMonthlyQuantity]
    (
        [NoraMonthlyQuantity] [INT]         NULL,
        [MarketingSpecialist] [CHAR](5)     NULL,
        [Item SKU]            [VARCHAR](15) NOT NULL,
        [Account]             [VARCHAR](20) NULL,
        [SalesTerritoryID]    [BIGINT]      NULL,
        [Market]              [VARCHAR](10) NULL,
        [CustomerNumber]      [CHAR](8)     NULL,
        [MarketCode]          VARCHAR(30)   NOT NULL
    );


