CREATE TABLE [MasterData_DW].[DimItemMaster]
    (
        [RowID]                          BIGINT         NOT NULL,  --not null
        [ItemSKU]                        VARCHAR(15)    NOT NULL,
        [ItemKey]                        VARCHAR(22)    NOT NULL,
        [Item]                           VARCHAR(15)    NULL,
        [ItemCode]                       VARCHAR(25)    NULL,
        [SeriesNumber]                   VARCHAR(5)     NULL,
        [ExtSeriesNumber]                VARCHAR(16)    NULL,
        [FrameNumber]                    VARCHAR(16)    NULL,
        [QtyInBox]                       DECIMAL(4, 0)  NULL,
        [UOM]                            CHAR(2)        NULL,
        [ProductHeightMeters]            DECIMAL(7, 2)  NULL,
        [ProductWidthMeters]             DECIMAL(7, 2)  NULL,
        [ProductDepthMeters]             DECIMAL(7, 2)  NULL,
        [CartonHeightMeters]             DECIMAL(7, 2)  NULL,
        [CartonWidthMeters]              DECIMAL(7, 2)  NULL,
        [CartonDepthMeters]              DECIMAL(7, 2)  NULL,
        [ProductHeightInches]            DECIMAL(7, 2)  NULL,
        [ProductWidthInches]             DECIMAL(7, 2)  NULL,
        [ProductDepthInches]             DECIMAL(7, 2)  NULL,
        [CartonHeightInches]             DECIMAL(7, 2)  NULL,
        [CartonWidthInches]              DECIMAL(7, 2)  NULL,
        [CartonDepthInches]              DECIMAL(7, 2)  NULL,
        [Cubes]                          DECIMAL(5, 2)  NULL,
        [Seats]                          DECIMAL(5, 2)  NULL,
        [ItemDescription]                VARCHAR(30)    NULL,
        [SeriesName]                     VARCHAR(100)   NULL,
        [SeriesColor]                    VARCHAR(60)    NULL,
        [Colors]                         VARCHAR(25)    NULL,
        [ItemDescriptionSeries]          VARCHAR(131)   NULL,
        [SHItemDescriptionSeries]        VARCHAR(147)   NULL,
        [SHSeriesDescription]            VARCHAR(106)   NULL,
        [ItemDescriptionSeriesItemColor] VARCHAR(173)   NULL,
        [ChildStyleDescription]          VARCHAR(65)    NULL,
        [ParentStyleDescription]         VARCHAR(65)    NULL,
        [SeriesDescription]              VARCHAR(117)   NULL,
        [ItemName]                       VARCHAR(100)   NULL,
        [ItemConsumerDescription]        VARCHAR(250)   NULL,
        [RetailTypeDescription]          VARCHAR(50)    NULL,
        [MainPieceItem]                  VARCHAR(5)     NULL,
        [ItemClass]                      VARCHAR(32)    NULL,
        [ItemClassCode]                  CHAR(4)        NULL,
        [ItemClassName]                  VARCHAR(25)    NULL,
        [ProductLine]                    VARCHAR(25)    NULL,
        [RetailCategoryCode]             CHAR(3)        NULL,
        [RetailCategoryDescription]      VARCHAR(30)    NULL,
        [RetailCategoryName]             VARCHAR(50)    NULL,
        [RetailDepartmentName]           VARCHAR(50)    NULL,
        [RetailCategoryGroup]            VARCHAR(50)    NULL,
        [RetailCategoryChargeType]       VARCHAR(50)    NULL,
        [AFIFinanceDivision]             VARCHAR(30)    NULL,
        [AFIFinanceDivisionCode]         CHAR(1)        NULL,
        [AFISalesCategoryCode]           CHAR(3)        NULL,
        [AFISalesCategory]               VARCHAR(25)    NULL,
        [ItemStyleCode]                  CHAR(3)        NULL,
        [ItemStyleGroup]                 VARCHAR(20)    NULL,
        [ItemStyle]                      VARCHAR(65)    NULL,
        [Division]                       VARCHAR(25)    NULL,
        [AFISalesDivisionCode]           CHAR(1)        NULL,
        [AFISalesDivision]               VARCHAR(25)    NULL,
        [KeyItem]                        BIT            NULL,
        [ItemType]                       CHAR(1)        NULL,
        [SalesClassCode]                 CHAR(2)        NULL,
        [SalesClassDescription]          VARCHAR(25)    NULL,
        [SalesClass]                     VARCHAR(30)    NULL,
        [DiscountClassCode]              CHAR(2)        NULL,
        [DiscountClassDescription]       VARCHAR(25)    NULL,
        [DiscountClass]                  VARCHAR(30)    NULL,
        [CommissionClassCode]            CHAR(2)        NULL,
        [CommissionClassDescription]     VARCHAR(25)    NULL,
        [CommissionClass]                VARCHAR(30)    NULL,
        [FreightClassCode]               CHAR(2)        NULL,
        [FreightClassDescription]        VARCHAR(25)    NULL,
        [FreightClass]                   VARCHAR(30)    NULL,
        [AFIItemStatus]                  CHAR(1)        NULL,
        [SellableItemFlag]               CHAR(1)        NULL,
        [ManufacturingStatus]            VARCHAR(25)    NULL,
        [ResponsibleOffice]              VARCHAR(10)    NULL,
        [ResponsibleOfficeName]          VARCHAR(25)    NULL,
        [ImportDomesticCode]             CHAR(1)        NULL,
        [CountryofOrigin]                VARCHAR(30)    NULL,
        [PrimaryVendor]                  CHAR(8)        NULL,
        [ManufacturingStatusChangeDate]  DATE           NULL,
        [ItemForecastPlannerID]          VARCHAR(25)    NULL,
        [NewItemFlag]                    BIT            NULL,
        [DiscontinuedFlag]               BIT            NULL,
        [DiscontinuedYearPeriod]         VARCHAR(7)     NULL,
        [CommonCarrierFlag]              CHAR(1)        NULL,
        [ExpressShipFlag]                CHAR(1)        NULL,
        [DiscontinuedDate]               DATE           NULL,
        [SeriesDateArchived]             DATE           NULL,
        [SeriesDiscontinuedFlag]         BIT            NULL,
        [PreviousStatusCode]             CHAR(1)        NULL,
        [StatusCodeChangeDate]           DATE           NULL,
        [CurrentUnitCost]                DECIMAL(19, 8) NULL,
        [CEXCode]                        CHAR(3)        NULL,
        [MarketIntroducedAt]             VARCHAR(30)    NULL,
        [MerchandisingCategory]          SMALLINT       NULL,
        [PricePoint]                     INT            NULL,
        [ItemGrouping]                   VARCHAR(35)    NULL,
        [SeriesGrouping]                 SMALLINT       NULL,
        [MasterGroupCode]                VARCHAR(10)    NULL,
        [AssociationCode]                VARCHAR(35)    NULL,
        [MarketingItemStatus]            CHAR(1)        NULL,
        [MarketingStatusDescription]     VARCHAR(25)    NULL,
        [Lifestyle]                      VARCHAR(65)    NULL,
                                                              --[MattressType] varchar(255)  NULL, 
        [CommodityItem]                  BIT            NULL,
        [F123ProductFlag]                BIT            NULL,
        [HSCoreProductFlag]              BIT            NULL,
        [HSProprietaryProductFlag]       BIT            NULL,
        [HSExclusiveFlag]                BIT            NULL,
        [BerklineProductFlag]            BIT            NULL,
        [BenchcraftProductFlag]          BIT            NULL,
        [NewMillenniumProductFlag]       BIT            NULL,
        [BardiniProductFlag]             BIT            NULL,
        [ShanghaiStore]                  BIT            NULL,
        [DefaultGroup]                   BIT            NULL,
        [GoodBetterBestForPricePoint]    VARCHAR(6)     NULL,
        [GBBSortId]                      INT            NULL,
        [InitialInvoicePeriod]           VARCHAR(7)     NULL,
        [InitialInvoiceQty]              DECIMAL(38, 0) NULL,
        [MarketBeginDate]                DATE           NULL,
        [MarketEndDate]                  DATE           NULL,
        [Showroom]                       VARCHAR(25)    NULL,
        [ItemImage]                      VARCHAR(50)    NULL,
        [FOBArcPrice]                    DECIMAL(8, 2)  NULL,
        [DivisionRanking]                INT            NULL,
                                                              -- [ConsumerChoiceFlag] int NULL, 
        [TrendArrow]                     VARCHAR(20)    NULL,
                                                              -- [ConsumerChoiceMaxRanking] int NULL, 
        [ItemMerchGridOverridePhoto]     VARCHAR(8000)  NULL,
        [GroupPriceIncr]                 DECIMAL(5, 0)  NULL,
        [GroupPricePointType]            CHAR(1)        NULL,
        [ExclusiveComment]               VARCHAR(60)    NULL,
        [SeriesImage]                    VARCHAR(50)    NULL,
        [SofaTableSeriesFlag]            VARCHAR(5)     NULL,
        [ReclinerSeriesFlag]             VARCHAR(5)     NULL,
        [PowerMotionSeriesFlag]          VARCHAR(5)     NULL,
        [WedgeSeriesFlag]                VARCHAR(5)     NULL,
        [DiningSeriesFlag]               VARCHAR(5)     NULL,
        [ItemThirdPartyItem]             VARCHAR(100)   NULL,
        [SeriesThirdParty]               VARCHAR(100)   NULL, /* New attribute */
        [ItemHomeStoreProductLine]       VARCHAR(24)    NULL, /* New attribute */
        [ItemEcomMerchantNotes]          VARCHAR(300)   NULL, /* New attribute */
        [ItemAmazonBrandOwner]           VARCHAR(300)   NULL, /* New attribute */
        [ItemSupplierDirectShipOnly]     VARCHAR(100)   NULL,
        [ConsumerChoiceFlag]             VARCHAR(5)     NULL,
        [EligibleForProtectionPlan]      VARCHAR(5)     NULL,
        [IsProtectionPlan]               VARCHAR(5)     NULL,
        [CollectiveClass]                VARCHAR(100)   NULL,
        [FriendlyDimensions]             VARCHAR(100)   NULL,
        [Knockout]                       VARCHAR(100)   NULL,
        [Scene7ImageSet]                 VARCHAR(100)   NULL,
        [FluffAFI]                       VARCHAR(5000)  NULL,
        [SeriesPrimary]                  VARCHAR(100)   NULL,
        [SeriesMainImage]                VARCHAR(100)   NULL,
        [StandAloneFlag]                 VARCHAR(100)   NULL,
        [SuppWeightNetWeightLbs]         VARCHAR(100)   NULL,
        [UnitWeightLbs]                  VARCHAR(100)   NULL,
        [UPC]                            VARCHAR(100)   NULL,
        [RetailBrandName]                VARCHAR(100)   NULL,
        [MfgWarranty]                    VARCHAR(100)   NULL,
        [Material]                       VARCHAR(300)   NULL,
        [SeriesFeatures]                 VARCHAR(2500)  NULL,
        [ItemIsRTA]                      VARCHAR(6)     NULL,
        [PrimaryChannelSku]              VARCHAR(20)    NULL,
        [PrimarySeriesName]              VARCHAR(100)   NULL,
        [PrimarySeriesNumber]            VARCHAR(7)     NULL,
        [ERetailChannelSku]              VARCHAR(20)    NULL,
        [ERetailSeriesName]              VARCHAR(100)   NULL,
        [ERetailSeriesNumber]            VARCHAR(7)     NULL,
        [ItemTableShapeType]             VARCHAR(30)    NULL,
        [ItemBedSizeType]                VARCHAR(30)    NULL,
        [ItemBedStyleType]               VARCHAR(100)    NULL,
        [ItemGeneralColor]               VARCHAR(300)   NULL,
        [ItemPricePointRating]           VARCHAR(10)    NULL
    );

GO
CREATE STATISTICS [Stat_DimItemMaster_WedgeSeriesFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [WedgeSeriesFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_UOM]
    ON [MasterData_DW].[DimItemMaster]
    (
        [UOM]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_TrendArrow]
    ON [MasterData_DW].[DimItemMaster]
    (
        [TrendArrow]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_StatusCodeChangeDate]
    ON [MasterData_DW].[DimItemMaster]
    (
        [StatusCodeChangeDate]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SofaTableSeriesFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SofaTableSeriesFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SHSeriesDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SHSeriesDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_Showroom]
    ON [MasterData_DW].[DimItemMaster]
    (
        [Showroom]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SHItemDescriptionSeries]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SHItemDescriptionSeries]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ShanghaiStore]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ShanghaiStore]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesThirdParty]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SeriesThirdParty]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesName]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SeriesName]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesImage]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SeriesImage]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesGrouping]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SeriesGrouping]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesDiscontinuedFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SeriesDiscontinuedFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SeriesDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesDateArchived]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SeriesDateArchived]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesColor]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SeriesColor]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SellableItemFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SellableItemFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_Seats]
    ON [MasterData_DW].[DimItemMaster]
    (
        [Seats]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SalesClassDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SalesClassDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SalesClassCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SalesClassCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SalesClass]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SalesClass]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_RowID]
    ON [MasterData_DW].[DimItemMaster]
    (
        [RowID]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailTypeDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [RetailTypeDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailDepartmentName]
    ON [MasterData_DW].[DimItemMaster]
    (
        [RetailDepartmentName]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailCategoryName]
    ON [MasterData_DW].[DimItemMaster]
    (
        [RetailCategoryName]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailCategoryGroup]
    ON [MasterData_DW].[DimItemMaster]
    (
        [RetailCategoryGroup]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailCategoryDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [RetailCategoryDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailCategoryCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [RetailCategoryCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailCategoryChargeType]
    ON [MasterData_DW].[DimItemMaster]
    (
        [RetailCategoryChargeType]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ResponsibleOfficeName]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ResponsibleOfficeName]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ResponsibleOffice]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ResponsibleOffice]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ReclinerSeriesFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ReclinerSeriesFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_QtyInBox]
    ON [MasterData_DW].[DimItemMaster]
    (
        [QtyInBox]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ProductWidthMeters]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ProductWidthMeters]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ProductWidthInches]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ProductWidthInches]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ProductLine]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ProductLine]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ProductHeightMeters]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ProductHeightMeters]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ProductHeightInches]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ProductHeightInches]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ProductDepthMeters]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ProductDepthMeters]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ProductDepthInches]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ProductDepthInches]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_PrimaryVendor]
    ON [MasterData_DW].[DimItemMaster]
    (
        [PrimaryVendor]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_PricePoint]
    ON [MasterData_DW].[DimItemMaster]
    (
        [PricePoint]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_PreviousStatusCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [PreviousStatusCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_PowerMotionSeriesFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [PowerMotionSeriesFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ParentStyleDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ParentStyleDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_NewMillenniumProductFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [NewMillenniumProductFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_NewItemFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [NewItemFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_MerchandisingCategory]
    ON [MasterData_DW].[DimItemMaster]
    (
        [MerchandisingCategory]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_MasterGroupCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [MasterGroupCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_MarketIntroducedAt]
    ON [MasterData_DW].[DimItemMaster]
    (
        [MarketIntroducedAt]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_MarketingStatusDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [MarketingStatusDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_MarketingItemStatus]
    ON [MasterData_DW].[DimItemMaster]
    (
        [MarketingItemStatus]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_MarketEndDate]
    ON [MasterData_DW].[DimItemMaster]
    (
        [MarketEndDate]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_MarketBeginDate]
    ON [MasterData_DW].[DimItemMaster]
    (
        [MarketBeginDate]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ManufacturingStatusChangeDate]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ManufacturingStatusChangeDate]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ManufacturingStatus]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ManufacturingStatus]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_MainPieceItem]
    ON [MasterData_DW].[DimItemMaster]
    (
        [MainPieceItem]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_Lifestyle]
    ON [MasterData_DW].[DimItemMaster]
    (
        [Lifestyle]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_KeyItem]
    ON [MasterData_DW].[DimItemMaster]
    (
        [KeyItem]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemType]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemType]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemThirdPartyItem]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemThirdPartyItem]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemSupplierDirectShipOnly]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemSupplierDirectShipOnly]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemStyleGroup]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemStyleGroup]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemStyleCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemStyleCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemStyle]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemStyle]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemSKU]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemSKU]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemName]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemName]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemMerchGridOverridePhoto]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemMerchGridOverridePhoto]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemKey]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemKey]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemImage]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemImage]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemHomeStoreProductLine]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemHomeStoreProductLine]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemGrouping]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemGrouping]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemForecastPlannerID]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemForecastPlannerID]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemEcomMerchantNotes]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemEcomMerchantNotes]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemDescriptionSeriesItemColor]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemDescriptionSeriesItemColor]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemDescriptionSeries]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemDescriptionSeries]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemConsumerDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemConsumerDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemClassName]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemClassName]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemClassCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemClassCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemClass]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemClass]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemAmazonBrandOwner]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemAmazonBrandOwner]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_Item]
    ON [MasterData_DW].[DimItemMaster]
    (
        [Item]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_InitialInvoiceQty]
    ON [MasterData_DW].[DimItemMaster]
    (
        [InitialInvoiceQty]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_InitialInvoicePeriod]
    ON [MasterData_DW].[DimItemMaster]
    (
        [InitialInvoicePeriod]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ImportDomesticCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ImportDomesticCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_HSProprietaryProductFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [HSProprietaryProductFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_HSExclusiveFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [HSExclusiveFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_HSCoreProductFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [HSCoreProductFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_GroupPricePointType]
    ON [MasterData_DW].[DimItemMaster]
    (
        [GroupPricePointType]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_GroupPriceIncr]
    ON [MasterData_DW].[DimItemMaster]
    (
        [GroupPriceIncr]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_GoodBetterBestForPricePoint]
    ON [MasterData_DW].[DimItemMaster]
    (
        [GoodBetterBestForPricePoint]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_GBBSortId]
    ON [MasterData_DW].[DimItemMaster]
    (
        [GBBSortId]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_FreightClassDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [FreightClassDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_FreightClassCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [FreightClassCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_FreightClass]
    ON [MasterData_DW].[DimItemMaster]
    (
        [FreightClass]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_FrameNumber]
    ON [MasterData_DW].[DimItemMaster]
    (
        [FrameNumber]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_FOBArcPrice]
    ON [MasterData_DW].[DimItemMaster]
    (
        [FOBArcPrice]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_F123ProductFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [F123ProductFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ExtSeriesNumber]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ExtSeriesNumber]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ExpressShipFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ExpressShipFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ExclusiveComment]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ExclusiveComment]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_Division]
    ON [MasterData_DW].[DimItemMaster]
    (
        [Division]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_DiscountClassDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [DiscountClassDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_DiscountClassCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [DiscountClassCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_DiscountClass]
    ON [MasterData_DW].[DimItemMaster]
    (
        [DiscountClass]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_DiscontinuedYearPeriod]
    ON [MasterData_DW].[DimItemMaster]
    (
        [DiscontinuedYearPeriod]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_DiscontinuedFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [DiscontinuedFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_DiscontinuedDate]
    ON [MasterData_DW].[DimItemMaster]
    (
        [DiscontinuedDate]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_DiningSeriesFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [DiningSeriesFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_DefaultGroup]
    ON [MasterData_DW].[DimItemMaster]
    (
        [DefaultGroup]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CurrentUnitCost]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CurrentUnitCost]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_Cubes]
    ON [MasterData_DW].[DimItemMaster]
    (
        [Cubes]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CountryofOrigin]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CountryofOrigin]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ConsumerChoiceFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ConsumerChoiceFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CommonCarrierFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CommonCarrierFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CommodityItem]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CommodityItem]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CommissionClassDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CommissionClassDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CommissionClassCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CommissionClassCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CommissionClass]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CommissionClass]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_Colors]
    ON [MasterData_DW].[DimItemMaster]
    (
        [Colors]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CollectiveClass]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CollectiveClass]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ChildStyleDescription]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ChildStyleDescription]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CEXCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CEXCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CartonWidthMeters]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CartonWidthMeters]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CartonWidthInches]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CartonWidthInches]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CartonHeightMeters]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CartonHeightMeters]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CartonHeightInches]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CartonHeightInches]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CartonDepthMeters]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CartonDepthMeters]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_BerklineProductFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [BerklineProductFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_BenchcraftProductFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [BenchcraftProductFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_BardiniProductFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [BardiniProductFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_AssociationCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [AssociationCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_AFISalesDivisionCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [AFISalesDivisionCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_AFISalesDivision]
    ON [MasterData_DW].[DimItemMaster]
    (
        [AFISalesDivision]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_AFISalesCategoryCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [AFISalesCategoryCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_AFISalesCategory]
    ON [MasterData_DW].[DimItemMaster]
    (
        [AFISalesCategory]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_AFIItemStatus]
    ON [MasterData_DW].[DimItemMaster]
    (
        [AFIItemStatus]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_AFIFinanceDivisionCode]
    ON [MasterData_DW].[DimItemMaster]
    (
        [AFIFinanceDivisionCode]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_AFIFinanceDivision]
    ON [MasterData_DW].[DimItemMaster]
    (
        [AFIFinanceDivision]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesPrimary]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SeriesPrimary]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesMainImage]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SeriesMainImage]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesFeatures]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SeriesFeatures]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemUPC]
    ON [MasterData_DW].[DimItemMaster]
    (
        [UPC]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemUnitWeightLbs]
    ON [MasterData_DW].[DimItemMaster]
    (
        [UnitWeightLbs]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemSuppWeightNetWeightLbs]
    ON [MasterData_DW].[DimItemMaster]
    (
        [SuppWeightNetWeightLbs]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemStandAloneFlag]
    ON [MasterData_DW].[DimItemMaster]
    (
        [StandAloneFlag]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemScene7ImageSet]
    ON [MasterData_DW].[DimItemMaster]
    (
        [Scene7ImageSet]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemRetailBrandName]
    ON [MasterData_DW].[DimItemMaster]
    (
        [RetailBrandName]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemMfgWarranty]
    ON [MasterData_DW].[DimItemMaster]
    (
        [MfgWarranty]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemMaterial]
    ON [MasterData_DW].[DimItemMaster]
    (
        [Material]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemKnockout]
    ON [MasterData_DW].[DimItemMaster]
    (
        [Knockout]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemFriendlyDimensions]
    ON [MasterData_DW].[DimItemMaster]
    (
        [FriendlyDimensions]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemFluffAFI]
    ON [MasterData_DW].[DimItemMaster]
    (
        [FluffAFI]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemIsRTA]
    ON [MasterData_DW].[DimItemMaster]
    (
        [ItemIsRTA]
    );


GO
CREATE STATISTICS [Stat_DimItemMaster_CartonDepthInches]
    ON [MasterData_DW].[DimItemMaster]
    (
        [CartonDepthInches]
    );

