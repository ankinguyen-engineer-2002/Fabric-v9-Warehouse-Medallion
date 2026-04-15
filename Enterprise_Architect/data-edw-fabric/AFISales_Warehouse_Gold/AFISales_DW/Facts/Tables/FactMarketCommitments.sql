CREATE TABLE [AFISales_DW].[FactMarketCommitments]
    (
        [RowID]                              BIGINT      NOT NULL, --IDENTITY (1,1)
        [MarketingSpecialist]                VARCHAR(15) NULL,
        [Item SKU]                           VARCHAR(30) NOT NULL,
        [Item Key]                           VARCHAR(30) NOT NULL,
        [CustomerNumber]                     CHAR(8)     NULL,
        [ShiptoNumber]                       CHAR(8)     NULL,
        [SalesTerritoryID]                   BIGINT      NULL,
        [Committed]                          INT         NULL,
        [Committed - NonHomestore]           INT         NULL,
        [Committed - Homestore]              INT         NULL,
        [Actual Placements]                  INT         NULL,
        [Original Commitment]                INT         NULL,
        [Original Commitment - NonHomestore] INT         NULL,
        [Original Commitment - Homestore]    INT         NULL,
        [Remaining Goal]                     INT         NULL,
        [AFI Sales RepID]                    CHAR(8)     NULL,
        [AFI Sales Category]                 CHAR(8)     NULL,
        [AFI Sales Region Code]              CHAR(8)     NULL,
        [RegionCode_RepID_Category]          VARCHAR(20) NULL,
        [MonthlyQuantity]                    INT         NULL
    );

GO
CREATE STATISTICS [Stat_FactMarketCommitments_SalesTerritoryID]
    ON [AFISales_DW].[FactMarketCommitments]
    (
        [SalesTerritoryID]
    );


GO
CREATE STATISTICS [Stat_FactMarketCommitments_Item_SKU]
    ON [AFISales_DW].[FactMarketCommitments]
    (
        [Item SKU]
    );


GO
CREATE STATISTICS [Stat_FactMarketCommitments_Item_Key]
    ON [AFISales_DW].[FactMarketCommitments]
    (
        [Item Key]
    );

