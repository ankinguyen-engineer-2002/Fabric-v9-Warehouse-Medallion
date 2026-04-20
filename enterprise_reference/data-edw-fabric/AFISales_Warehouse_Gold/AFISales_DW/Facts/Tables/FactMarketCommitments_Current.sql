CREATE TABLE [AFISales_DW].[FactMarketCommitments_Current]
    (
        [RowID]                            BIGINT        NOT NULL, --IDENTITY (1,1) 
        [Market]                           VARCHAR(10)   NULL,
        [MarketingSpecialist]              CHAR(5)       NULL,
        [Item SKU]                         VARCHAR(15)   NOT NULL,
        [Item Key]                         VARCHAR(22)   NOT NULL,
        [CustomerNumber]                   CHAR(8)       NULL,
        [ShiptoNumber]                     CHAR(4)       NULL,
        [Territory]                        CHAR(5)       NULL,
        [SalesTerritoryID]                 BIGINT        NULL,
        [MarketCode]                       VARCHAR(30)   NOT NULL,
        [User ID]                          VARCHAR(30)   NOT NULL,
        [Market Commitment]                INT           NULL,
        [Market Commitment - NonHomestore] INT           NOT NULL,
        [Market Commitment - Homestore]    INT           NOT NULL,
        [Monthly Estimate]                 DECIMAL(5, 2) NOT NULL,
        [MonthlyQuantity]                  INT           NULL,
        [Account]                          VARCHAR(20)   NULL
    );


GO
CREATE STATISTICS [Stat_FactMarketCommitments_Current_SalesTerritoryID]
    ON [AFISales_DW].[FactMarketCommitments_Current]
    (
        [SalesTerritoryID]
    );


GO
CREATE STATISTICS [Stat_FactMarketCommitments_Current_Item_SKU]
    ON [AFISales_DW].[FactMarketCommitments_Current]
    (
        [Item SKU]
    );


GO
CREATE STATISTICS [Stat_FactMarketCommitments_Current_Item_Key]
    ON [AFISales_DW].[FactMarketCommitments_Current]
    (
        [Item Key]
    );

