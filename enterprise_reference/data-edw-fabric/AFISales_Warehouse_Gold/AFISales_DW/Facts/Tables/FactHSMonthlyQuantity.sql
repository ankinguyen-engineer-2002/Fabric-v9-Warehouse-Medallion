CREATE TABLE [AFISales_DW].[FactHSMonthlyQuantity]
    (
        [HSMonthlyQuantity]   [INT]         NULL,
        [MarketingSpecialist] [CHAR](5)     NULL,
        [Item SKU]            [VARCHAR](15) NOT NULL,
        [Account]             [VARCHAR](20) NULL,
        [SalesTerritoryID]    [BIGINT]      NULL,
        [Market]              [VARCHAR](10) NULL,
        [CustomerNum]         [CHAR](8)     NULL,
        [MarketCode]          VARCHAR(30)   NOT NULL
    );




