CREATE TABLE [Quality_DW].[DimItemMaster]
    (
        [RowID]                          BIGINT       NOT NULL, --IDENTITY (1, 1)
        [ItemSKU]                        VARCHAR(15)  NOT NULL,
        [Item]                           VARCHAR(15)  NULL,
        [ItemClassCode]                  CHAR(4)      NULL,
        [Colors]                         VARCHAR(25)  NULL,
        [ItemKey]                        VARCHAR(22)  NOT NULL,
        [QtyInBox]                       DECIMAL(4)   NULL,
        [UOM]                            CHAR(2)      NULL,
        [SeriesName]                     VARCHAR(100) NULL,
        [SeriesColor]                    VARCHAR(60)  NULL,
        [ItemDescriptionSeries]          VARCHAR(131) NULL,
        [SHItemDescriptionSeries]        VARCHAR(147) NULL,
        [SHSeriesDescription]            VARCHAR(106) NULL,
        [ItemDescriptionSeriesItemColor] VARCHAR(173) NULL,
        [ResponsibleOffice]              VARCHAR(10)  NULL,
        [ItemClassName]                  VARCHAR(25)  NULL,
        [ItemClass]                      VARCHAR(32)  NULL,
        [ProductLine]                    VARCHAR(25)  NULL,
        [RetailCategoryCode]             CHAR(3)      NULL,
        [RetailCategoryDescription]      VARCHAR(30)  NULL,
        [AFIFinanceDivision]             VARCHAR(30)  NULL,
        [ItemDescription]                VARCHAR(30)  NULL,
        [ItemStyleCode]                  CHAR(3)      NULL,
        [ItemStyleGroup]                 VARCHAR(20)  NULL,
        [ItemStyle]                      VARCHAR(65)  NULL,
        [AFIItemStatus]                  CHAR(1)      NULL,
        [SalesClassCode]                 CHAR(2)      NULL,
        [SalesClassDescription]          VARCHAR(25)  NULL,
        [SalesClass]                     VARCHAR(30)  NULL,
        [DiscountClassCode]              CHAR(2)      NULL,
        [DiscountClassDescription]       VARCHAR(25)  NULL,
        [DiscountClass]                  VARCHAR(30)  NULL,
        [CommissionClassCode]            CHAR(2)      NULL,
        [CommissionClassDescription]     VARCHAR(25)  NULL,
        [CommissionClass]                VARCHAR(30)  NULL,
        [FreightClassCode]               CHAR(2)      NULL,
        [FreightClassDescription]        VARCHAR(25)  NULL,
        [FreightClass]                   VARCHAR(30)  NULL,
        [ManufacturingStatus]            VARCHAR(25)  NULL,
        [AFISalesCategoryCode]           CHAR(3)      NULL,
        [AFISalesCategory]               VARCHAR(25)  NULL,
        [ImportDomesticCode]             CHAR(1)      NULL,
        [CountryofOrigin]                VARCHAR(30)  NULL,
        [AFISalesDivisionCode]           CHAR(1)      NULL,
        [AFISalesDivision]               VARCHAR(25)  NULL,
        [CEXCode]                        CHAR(3)      NULL,
        [SeriesNumber]                   VARCHAR(5)   NULL,
        [ExtSeriesNumber]                VARCHAR(16)  NULL,
        [MainPieceItem]                  VARCHAR(5)   NULL,
        [CommodityItem]                  INT          NULL,
        [MarketIntroducedAt]             VARCHAR(30)  NULL,
        [MerchandisingCategory]          SMALLINT     NULL,
        [ChildStyleDescription]          VARCHAR(65)  NULL,
        [ParentStyleDescription]         VARCHAR(65)  NULL,
        [PricePoint]                     INT          NULL,
        [ItemCode]                       VARCHAR(25)  NULL,
        [ItemGrouping]                   VARCHAR(35)  NULL,
        [AssociationCode]                VARCHAR(35)  NULL,
        [MarketingItemStatus]            CHAR(1)      NULL,
        [MarketingStatusDescription]     VARCHAR(25)  NULL,
        [DefaultGroup]                   INT          NULL,
        [SeriesDescription]              VARCHAR(117) NULL,
        [GoodBetterBestForPricePoint]    VARCHAR(6)   NULL,
        [GBBSortId]                      INT          NULL,
        [PrimaryVendor]                  CHAR(8)      NULL,
        [SellableItemFlag]               CHAR(1)      NULL,
        [F123ProductFlag]                INT          NULL,
        [HSCoreProductFlag]              INT          NULL,
        [HSProprietaryProductFlag]       INT          NULL,
        [HSExclusiveFlag]                INT          NULL,
        [BerklineProductFlag]            INT          NULL,
        [BenchcraftProductFlag]          INT          NULL,
        [NewMillenniumProductFlag]       INT          NULL,
        [BardiniProductFlag]             INT          NULL,
        [ManufacturingStatusChangeDate]  DATE         NULL,
        [ShanghaiStore]                  INT          NULL,
        [InitialInvoicePeriod]           VARCHAR(7)   NULL,
        [InitialInvoiceQty]              DECIMAL(38)  NULL,
        [ItemForecastPlannerID]          VARCHAR(8)   NULL,
        [MarketBeginDate]                DATE         NULL,
        [MarketEndDate]                  DATE         NULL,
        [ItemConsumerDescription]        VARCHAR(100) NULL,
        [RetailTypeDescription]          VARCHAR(50)  NULL,
        [CommonCarrierFlag]              CHAR(1)      NULL,
        [ExpressShipFlag]                CHAR(1)      NULL
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_RowID]
    ON [Quality_DW].[DimItemMaster]
    (
        [RowID]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_UOM]
    ON [Quality_DW].[DimItemMaster]
    (
        [UOM]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_SHSeriesDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [SHSeriesDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_SHItemDescriptionSeries]
    ON [Quality_DW].[DimItemMaster]
    (
        [SHItemDescriptionSeries]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ShanghaiStore]
    ON [Quality_DW].[DimItemMaster]
    (
        [ShanghaiStore]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_SeriesNumber]
    ON [Quality_DW].[DimItemMaster]
    (
        [SeriesNumber]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_SeriesName]
    ON [Quality_DW].[DimItemMaster]
    (
        [SeriesName]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_SeriesDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [SeriesDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_SeriesColor]
    ON [Quality_DW].[DimItemMaster]
    (
        [SeriesColor]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_SellableItemFlag]
    ON [Quality_DW].[DimItemMaster]
    (
        [SellableItemFlag]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_SalesClassDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [SalesClassDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_SalesClassCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [SalesClassCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_SalesClass]
    ON [Quality_DW].[DimItemMaster]
    (
        [SalesClass]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_RetailTypeDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [RetailTypeDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_RetailCategoryDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [RetailCategoryDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_RetailCategoryCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [RetailCategoryCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ResponsibleOffice]
    ON [Quality_DW].[DimItemMaster]
    (
        [ResponsibleOffice]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_QtyInBox]
    ON [Quality_DW].[DimItemMaster]
    (
        [QtyInBox]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ProductLine]
    ON [Quality_DW].[DimItemMaster]
    (
        [ProductLine]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_PrimaryVendor]
    ON [Quality_DW].[DimItemMaster]
    (
        [PrimaryVendor]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_PricePoint]
    ON [Quality_DW].[DimItemMaster]
    (
        [PricePoint]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ParentStyleDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [ParentStyleDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_NewMillenniumProductFlag]
    ON [Quality_DW].[DimItemMaster]
    (
        [NewMillenniumProductFlag]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_MerchandisingCategory]
    ON [Quality_DW].[DimItemMaster]
    (
        [MerchandisingCategory]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_MarketIntroducedAt]
    ON [Quality_DW].[DimItemMaster]
    (
        [MarketIntroducedAt]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_MarketingStatusDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [MarketingStatusDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_MarketingItemStatus]
    ON [Quality_DW].[DimItemMaster]
    (
        [MarketingItemStatus]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_MarketEndDate]
    ON [Quality_DW].[DimItemMaster]
    (
        [MarketEndDate]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_MarketBeginDate]
    ON [Quality_DW].[DimItemMaster]
    (
        [MarketBeginDate]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ManufacturingStatusChangeDate]
    ON [Quality_DW].[DimItemMaster]
    (
        [ManufacturingStatusChangeDate]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ManufacturingStatus]
    ON [Quality_DW].[DimItemMaster]
    (
        [ManufacturingStatus]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_MainPieceItem]
    ON [Quality_DW].[DimItemMaster]
    (
        [MainPieceItem]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemStyleGroup]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemStyleGroup]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemStyleCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemStyleCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemStyle]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemStyle]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemSKU]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemSKU]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemKey]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemKey]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemGrouping]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemGrouping]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemForecastPlannerID]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemForecastPlannerID]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemDescriptionSeriesItemColor]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemDescriptionSeriesItemColor]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemDescriptionSeries]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemDescriptionSeries]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemConsumerDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemConsumerDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemClassName]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemClassName]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemClassCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemClassCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ItemClass]
    ON [Quality_DW].[DimItemMaster]
    (
        [ItemClass]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_Item]
    ON [Quality_DW].[DimItemMaster]
    (
        [Item]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_InitialInvoiceQty]
    ON [Quality_DW].[DimItemMaster]
    (
        [InitialInvoiceQty]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_InitialInvoicePeriod]
    ON [Quality_DW].[DimItemMaster]
    (
        [InitialInvoicePeriod]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ImportDomesticCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [ImportDomesticCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_HSProprietaryProductFlag]
    ON [Quality_DW].[DimItemMaster]
    (
        [HSProprietaryProductFlag]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_HSExclusiveFlag]
    ON [Quality_DW].[DimItemMaster]
    (
        [HSExclusiveFlag]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_HSCoreProductFlag]
    ON [Quality_DW].[DimItemMaster]
    (
        [HSCoreProductFlag]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_GoodBetterBestForPricePoint]
    ON [Quality_DW].[DimItemMaster]
    (
        [GoodBetterBestForPricePoint]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_GBBSortId]
    ON [Quality_DW].[DimItemMaster]
    (
        [GBBSortId]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_FreightClassDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [FreightClassDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_FreightClassCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [FreightClassCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_FreightClass]
    ON [Quality_DW].[DimItemMaster]
    (
        [FreightClass]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_F123ProductFlag]
    ON [Quality_DW].[DimItemMaster]
    (
        [F123ProductFlag]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ExtSeriesNumber]
    ON [Quality_DW].[DimItemMaster]
    (
        [ExtSeriesNumber]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ExpressShipFlag]
    ON [Quality_DW].[DimItemMaster]
    (
        [ExpressShipFlag]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_DiscountClassDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [DiscountClassDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_DiscountClassCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [DiscountClassCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_DiscountClass]
    ON [Quality_DW].[DimItemMaster]
    (
        [DiscountClass]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_DefaultGroup]
    ON [Quality_DW].[DimItemMaster]
    (
        [DefaultGroup]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_CountryofOrigin]
    ON [Quality_DW].[DimItemMaster]
    (
        [CountryofOrigin]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_CommonCarrierFlag]
    ON [Quality_DW].[DimItemMaster]
    (
        [CommonCarrierFlag]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_CommodityItem]
    ON [Quality_DW].[DimItemMaster]
    (
        [CommodityItem]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_CommissionClassDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [CommissionClassDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_CommissionClassCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [CommissionClassCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_CommissionClass]
    ON [Quality_DW].[DimItemMaster]
    (
        [CommissionClass]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_Colors]
    ON [Quality_DW].[DimItemMaster]
    (
        [Colors]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_ChildStyleDescription]
    ON [Quality_DW].[DimItemMaster]
    (
        [ChildStyleDescription]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_CEXCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [CEXCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_BerklineProductFlag]
    ON [Quality_DW].[DimItemMaster]
    (
        [BerklineProductFlag]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_BenchcraftProductFlag]
    ON [Quality_DW].[DimItemMaster]
    (
        [BenchcraftProductFlag]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_BardiniProductFlag]
    ON [Quality_DW].[DimItemMaster]
    (
        [BardiniProductFlag]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_AssociationCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [AssociationCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_AFISalesDivisionCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [AFISalesDivisionCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_AFISalesDivision]
    ON [Quality_DW].[DimItemMaster]
    (
        [AFISalesDivision]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_AFISalesCategoryCode]
    ON [Quality_DW].[DimItemMaster]
    (
        [AFISalesCategoryCode]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_AFISalesCategory]
    ON [Quality_DW].[DimItemMaster]
    (
        [AFISalesCategory]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_AFIItemStatus]
    ON [Quality_DW].[DimItemMaster]
    (
        [AFIItemStatus]
    );


GO
CREATE STATISTICS [stat_Quality_DW_DimItemMaster_LOAD_AFIFinanceDivision]
    ON [Quality_DW].[DimItemMaster]
    (
        [AFIFinanceDivision]
    );

