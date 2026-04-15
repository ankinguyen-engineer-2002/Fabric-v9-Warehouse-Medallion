
CREATE TABLE [AFISales_DW].[DimItemMaster] (
    [RowID]                          BIGINT         NOT NULL, -- IDENTITY (1, 1) 
    [ItemSKU]                        VARCHAR (15)   NOT NULL,
    [ItemKey]                        VARCHAR (22)   NOT NULL,
    [Item]                           VARCHAR (15)   NULL,
    [ItemCode]                       VARCHAR (25)   NULL,
    [SeriesCode]                     VARCHAR (5)    NULL,
    [ExtSeriesCode]                  VARCHAR (16)   NULL,
    [FrameNumber]                    VARCHAR (16)   NULL,
    [QtyInBox]                       DECIMAL (4)    NULL,
    [UOM]                            CHAR (2)       NULL,
    [Cubes]                          DECIMAL (5, 2) NULL,
    [Seats]                          DECIMAL (5, 2) NULL,
    [ItemDescription]                VARCHAR (30)   NULL,
    [SeriesName]                     VARCHAR (100)  NULL,
    [SeriesColor]                    VARCHAR (60)   NULL,
    [Colors]                         VARCHAR (25)   NULL,
    [ItemDescriptionSeries]          VARCHAR (131)  NULL,
    [SHItemDescriptionSeries]        VARCHAR (147)  NULL,
    [SHSeriesDescription]            VARCHAR (106)  NULL,
    [ItemDescriptionSeriesItemColor] VARCHAR (173)  NULL,
    [ChildStyleDescription]          VARCHAR (65)   NULL,
    [ParentStyleDescription]         VARCHAR (65)   NULL,
    [SeriesDescription]              VARCHAR (117)  NULL,
    [ItemConsumerDescription]        VARCHAR (100)  NULL,
    [RetailTypeDescription]          VARCHAR (50)   NULL,
    [MainPieceItem]                  VARCHAR (5)    NULL,
    [ItemClass]                      VARCHAR (32)   NULL,
    [ItemClassCode]                  CHAR (4)       NULL,
    [ItemClassName]                  VARCHAR (25)   NULL,
    [ProductLine]                    VARCHAR (25)   NULL,
    [RetailCategoryCode]             CHAR (3)       NULL,
    [RetailCategoryDescription]      VARCHAR (30)   NULL,
    [RetailCategoryName]             VARCHAR (50)   NULL,
    [RetailDepartmentName]           VARCHAR (50)   NULL,
    [RetailCategoryGroup]            VARCHAR (50)   NULL,
    [AFIFinanceDivision]             VARCHAR (30)   NULL,
    [AFISalesCategoryCode]           CHAR (3)       NULL,
    [AFISalesCategory]               VARCHAR (25)   NULL,
    [ItemStyleCode]                  CHAR (3)       NULL,
    [ItemStyleGroup]                 VARCHAR (20)   NULL,
    [ItemStyle]                      VARCHAR (65)   NULL,
    [Division]                       VARCHAR (25)   NULL,
    [AFISalesDivisionCode]           CHAR (1)       NULL,
    [AFISalesDivision]               VARCHAR (25)   NULL,
    [KeyItem]                        INT            NULL,
    [SalesClassCode]                 CHAR (2)       NULL,
    [SalesClassDescription]          VARCHAR (25)   NULL,
    [SalesClass]                     VARCHAR (30)   NULL,
    [DiscountClassCode]              CHAR (2)       NULL,
    [DiscountClassDescription]       VARCHAR (25)   NULL,
    [DiscountClass]                  VARCHAR (30)   NULL,
    [CommissionClassCode]            CHAR (2)       NULL,
    [CommissionClassDescription]     VARCHAR (25)   NULL,
    [CommissionClass]                VARCHAR (30)   NULL,
    [FreightClassCode]               CHAR (2)       NULL,
    [FreightClassDescription]        VARCHAR (25)   NULL,
    [FreightClass]                   VARCHAR (30)   NULL,
    [AFIItemStatus]                  CHAR (1)       NULL,
    [SellableItemFlag]               CHAR (1)       NULL,
    [ManufacturingStatus]            VARCHAR (25)   NULL,
    [ResponsibleOffice]              VARCHAR (10)   NULL,
    [ImportDomesticCode]             CHAR (1)       NULL,
    [CountryofOrigin]                VARCHAR (30)   NULL,
    [PrimaryVendor]                  CHAR (8)       NULL,
    [ManufacturingStatusChangeDate]  DATE           NULL,
    [ItemForecastPlannerID]          VARCHAR (8)    NULL,
    [NewItemFlag]                    INT            NULL,
    [DiscontinuedFlag]               INT            NULL,
    [DiscontinuedYearPeriod]         VARCHAR (7)    NULL,
    [CommonCarrierFlag]              CHAR (1)       NULL,
    [ExpressShipFlag]                CHAR (1)       NULL,
    [DiscontinuedDate]               DATE           NULL,
    [CEXCode]                        CHAR (3)       NULL,
    [MarketIntroducedAt]             VARCHAR (30)   NULL,
    [MerchandisingCategory]          SMALLINT       NULL,
    [PricePoint]                     INT            NULL,
    [ItemGrouping]                   VARCHAR (35)   NULL,
    [AssociationCode]                VARCHAR (35)   NULL,
    [MarketingItemStatus]            CHAR (1)       NULL,
    [MarketingStatusDescription]     VARCHAR (25)   NULL,
    [Lifestyle]                      VARCHAR (65)   NULL,
    [CommodityItem]                  INT            NULL,
    [F123ProductFlag]                INT            NULL,
    [HSCoreProductFlag]              INT            NULL,
    [HSProprietaryProductFlag]       INT            NULL,
    [HSExclusiveFlag]                INT            NULL,
    [BerklineProductFlag]            INT            NULL,
    [BenchcraftProductFlag]          INT            NULL,
    [NewMillenniumProductFlag]       INT            NULL,
    [BardiniProductFlag]             INT            NULL,
    [ShanghaiStore]                  INT            NULL,
    [DefaultGroup]                   INT            NULL,
    [GoodBetterBestForPricePoint]    VARCHAR (6)    NULL,
    [GBBSortID]                      INT            NULL,
    [InitialInvoicePeriod]           VARCHAR (7)    NULL,
    [InitialInvoiceQty]              DECIMAL (38)   NULL,
    [MarketBeginDate]                DATE           NULL,
    [MarketEndDate]                  DATE           NULL,
    [Showroom]                       VARCHAR (25)   NULL,
    [ItemImage]                      VARCHAR (50)   NULL,
    [FOBArcPrice]                    DECIMAL (8, 2) NULL,
    [TrendArrow]                     VARCHAR (20)   NULL,
    [ItemMerchGridOverridePhoto]     VARCHAR (8000) NULL,
    [ExclusiveComment]               VARCHAR (60)   NULL,
    [SeriesImage]                    VARCHAR (50)   NULL,
    [SofaTableSeriesFlag]            VARCHAR (5)    NULL,
    [ReclinerSeriesFlag]             VARCHAR (5)    NULL,
    [PowerMotionSeriesFlag]          VARCHAR (5)    NULL,
    [WedgeSeriesFlag]                VARCHAR (5)    NULL,
    [DiningSeriesFlag]               VARCHAR (5)    NULL,
    [ItemThirdPartyItem]             VARCHAR (100)  NULL,
    [ItemSupplierDirectShipOnly]     VARCHAR (100)  NULL,
    [ConsumerChoiceFlag]             VARCHAR (5)    NULL,
    [SeriesMainImage]                VARCHAR (100)  NULL,
    [CollectiveClass]                VARCHAR (100)  NULL,
    [CollectiveClassCode]            CHAR (4)       NULL,
    [DelayedProductFlag]             VARCHAR (1)    NULL,
    [ItemFluffAFI]                   VARCHAR (5000) NULL,
    [ItemMaterial]                   VARCHAR (300)  NULL,
    [ItemKnockout]                   VARCHAR (100)  NULL,
    [ItemStandAloneFlag]             VARCHAR (100)  NULL,
    [ItemScene7ImageSet]             VARCHAR (100)  NULL,
    [ItemUPC]                        VARCHAR (100)  NULL,
    [SeriesFeatures]                 VARCHAR (2500) NULL,
    [PrimariesLifestyle]             VARCHAR (100)  NULL,
    [ItemIsRTA]                      VARCHAR (6)    NULL,
    [PreviousStatusCode]             CHAR (1)       NULL
)


GO
CREATE STATISTICS [Stat_DimItemMaster_WedgeSeriesFlag]
    ON [AFISales_DW].[DimItemMaster]([WedgeSeriesFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_UOM]
    ON [AFISales_DW].[DimItemMaster]([UOM]);


GO
CREATE STATISTICS [Stat_DimItemMaster_TrendArrow]
    ON [AFISales_DW].[DimItemMaster]([TrendArrow]);


GO
CREATE STATISTICS [Stat_DimItemMaster_SofaTableSeriesFlag]
    ON [AFISales_DW].[DimItemMaster]([SofaTableSeriesFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_SHSeriesDescription]
    ON [AFISales_DW].[DimItemMaster]([SHSeriesDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_Showroom]
    ON [AFISales_DW].[DimItemMaster]([Showroom]);


GO
CREATE STATISTICS [Stat_DimItemMaster_SHItemDescriptionSeries]
    ON [AFISales_DW].[DimItemMaster]([SHItemDescriptionSeries]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ShanghaiStore]
    ON [AFISales_DW].[DimItemMaster]([ShanghaiStore]);


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesName]
    ON [AFISales_DW].[DimItemMaster]([SeriesName]);


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesImage]
    ON [AFISales_DW].[DimItemMaster]([SeriesImage]);


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesDescription]
    ON [AFISales_DW].[DimItemMaster]([SeriesDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_SeriesColor]
    ON [AFISales_DW].[DimItemMaster]([SeriesColor]);


GO
CREATE STATISTICS [Stat_DimItemMaster_SellableItemFlag]
    ON [AFISales_DW].[DimItemMaster]([SellableItemFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_Seats]
    ON [AFISales_DW].[DimItemMaster]([Seats]);


GO
CREATE STATISTICS [Stat_DimItemMaster_SalesClassDescription]
    ON [AFISales_DW].[DimItemMaster]([SalesClassDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_SalesClassCode]
    ON [AFISales_DW].[DimItemMaster]([SalesClassCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_SalesClass]
    ON [AFISales_DW].[DimItemMaster]([SalesClass]);


GO
CREATE STATISTICS [Stat_DimItemMaster_RowID]
    ON [AFISales_DW].[DimItemMaster]([RowID]);


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailTypeDescription]
    ON [AFISales_DW].[DimItemMaster]([RetailTypeDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailDepartmentName]
    ON [AFISales_DW].[DimItemMaster]([RetailDepartmentName]);


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailCategoryName]
    ON [AFISales_DW].[DimItemMaster]([RetailCategoryName]);


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailCategoryGroup]
    ON [AFISales_DW].[DimItemMaster]([RetailCategoryGroup]);


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailCategoryDescription]
    ON [AFISales_DW].[DimItemMaster]([RetailCategoryDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_RetailCategoryCode]
    ON [AFISales_DW].[DimItemMaster]([RetailCategoryCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ResponsibleOffice]
    ON [AFISales_DW].[DimItemMaster]([ResponsibleOffice]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ReclinerSeriesFlag]
    ON [AFISales_DW].[DimItemMaster]([ReclinerSeriesFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_QtyInBox]
    ON [AFISales_DW].[DimItemMaster]([QtyInBox]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ProductLine]
    ON [AFISales_DW].[DimItemMaster]([ProductLine]);


GO
CREATE STATISTICS [Stat_DimItemMaster_PrimaryVendor]
    ON [AFISales_DW].[DimItemMaster]([PrimaryVendor]);


GO
CREATE STATISTICS [Stat_DimItemMaster_PricePoint]
    ON [AFISales_DW].[DimItemMaster]([PricePoint]);


GO
CREATE STATISTICS [Stat_DimItemMaster_PowerMotionSeriesFlag]
    ON [AFISales_DW].[DimItemMaster]([PowerMotionSeriesFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ParentStyleDescription]
    ON [AFISales_DW].[DimItemMaster]([ParentStyleDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_NewMillenniumProductFlag]
    ON [AFISales_DW].[DimItemMaster]([NewMillenniumProductFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_MerchandisingCategory]
    ON [AFISales_DW].[DimItemMaster]([MerchandisingCategory]);


GO
CREATE STATISTICS [Stat_DimItemMaster_MarketIntroducedAt]
    ON [AFISales_DW].[DimItemMaster]([MarketIntroducedAt]);


GO
CREATE STATISTICS [Stat_DimItemMaster_MarketingStatusDescription]
    ON [AFISales_DW].[DimItemMaster]([MarketingStatusDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_MarketingItemStatus]
    ON [AFISales_DW].[DimItemMaster]([MarketingItemStatus]);


GO
CREATE STATISTICS [Stat_DimItemMaster_MarketEndDate]
    ON [AFISales_DW].[DimItemMaster]([MarketEndDate]);


GO
CREATE STATISTICS [Stat_DimItemMaster_MarketBeginDate]
    ON [AFISales_DW].[DimItemMaster]([MarketBeginDate]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ManufacturingStatusChangeDate]
    ON [AFISales_DW].[DimItemMaster]([ManufacturingStatusChangeDate]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ManufacturingStatus]
    ON [AFISales_DW].[DimItemMaster]([ManufacturingStatus]);


GO
CREATE STATISTICS [Stat_DimItemMaster_MainPieceItem]
    ON [AFISales_DW].[DimItemMaster]([MainPieceItem]);


GO
CREATE STATISTICS [Stat_DimItemMaster_Lifestyle]
    ON [AFISales_DW].[DimItemMaster]([Lifestyle]);


GO
CREATE STATISTICS [Stat_DimItemMaster_KeyItem]
    ON [AFISales_DW].[DimItemMaster]([KeyItem]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemThirdPartyItem]
    ON [AFISales_DW].[DimItemMaster]([ItemThirdPartyItem]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemSupplierDirectShipOnly]
    ON [AFISales_DW].[DimItemMaster]([ItemSupplierDirectShipOnly]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemStyleGroup]
    ON [AFISales_DW].[DimItemMaster]([ItemStyleGroup]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemStyleCode]
    ON [AFISales_DW].[DimItemMaster]([ItemStyleCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemSKU]
    ON [AFISales_DW].[DimItemMaster]([ItemSKU]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemMerchGridOverridePhoto]
    ON [AFISales_DW].[DimItemMaster]([ItemMerchGridOverridePhoto]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemKey]
    ON [AFISales_DW].[DimItemMaster]([ItemKey]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemImage]
    ON [AFISales_DW].[DimItemMaster]([ItemImage]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemGrouping]
    ON [AFISales_DW].[DimItemMaster]([ItemGrouping]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemForecastPlannerID]
    ON [AFISales_DW].[DimItemMaster]([ItemForecastPlannerID]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemDescriptionSeriesItemColor]
    ON [AFISales_DW].[DimItemMaster]([ItemDescriptionSeriesItemColor]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemDescriptionSeries]
    ON [AFISales_DW].[DimItemMaster]([ItemDescriptionSeries]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemDescription]
    ON [AFISales_DW].[DimItemMaster]([ItemDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemConsumerDescription]
    ON [AFISales_DW].[DimItemMaster]([ItemConsumerDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemCode]
    ON [AFISales_DW].[DimItemMaster]([ItemCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemClassName]
    ON [AFISales_DW].[DimItemMaster]([ItemClassName]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemClassCode]
    ON [AFISales_DW].[DimItemMaster]([ItemClassCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemClass]
    ON [AFISales_DW].[DimItemMaster]([ItemClass]);


GO
CREATE STATISTICS [Stat_DimItemMaster_Item]
    ON [AFISales_DW].[DimItemMaster]([Item]);


GO
CREATE STATISTICS [Stat_DimItemMaster_InitialInvoiceQty]
    ON [AFISales_DW].[DimItemMaster]([InitialInvoiceQty]);


GO
CREATE STATISTICS [Stat_DimItemMaster_InitialInvoicePeriod]
    ON [AFISales_DW].[DimItemMaster]([InitialInvoicePeriod]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ImportDomesticCode]
    ON [AFISales_DW].[DimItemMaster]([ImportDomesticCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_GoodBetterBestForPricePoint]
    ON [AFISales_DW].[DimItemMaster]([GoodBetterBestForPricePoint]);


GO
CREATE STATISTICS [Stat_DimItemMaster_GBBSortID]
    ON [AFISales_DW].[DimItemMaster]([GBBSortID]);


GO
CREATE STATISTICS [Stat_DimItemMaster_FreightClassDescription]
    ON [AFISales_DW].[DimItemMaster]([FreightClassDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_FreightClassCode]
    ON [AFISales_DW].[DimItemMaster]([FreightClassCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_FreightClass]
    ON [AFISales_DW].[DimItemMaster]([FreightClass]);


GO
CREATE STATISTICS [Stat_DimItemMaster_FrameNumber]
    ON [AFISales_DW].[DimItemMaster]([FrameNumber]);


GO
CREATE STATISTICS [Stat_DimItemMaster_FOBArcPrice]
    ON [AFISales_DW].[DimItemMaster]([FOBArcPrice]);


GO
CREATE STATISTICS [Stat_DimItemMaster_F123ProductFlag]
    ON [AFISales_DW].[DimItemMaster]([F123ProductFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ExtSeriesCode]
    ON [AFISales_DW].[DimItemMaster]([ExtSeriesCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ExpressShipFlag]
    ON [AFISales_DW].[DimItemMaster]([ExpressShipFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ExclusiveComment]
    ON [AFISales_DW].[DimItemMaster]([ExclusiveComment]);


GO
CREATE STATISTICS [Stat_DimItemMaster_DiscountClassDescription]
    ON [AFISales_DW].[DimItemMaster]([DiscountClassDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_DiscountClassCode]
    ON [AFISales_DW].[DimItemMaster]([DiscountClassCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_DiscountClass]
    ON [AFISales_DW].[DimItemMaster]([DiscountClass]);


GO
CREATE STATISTICS [Stat_DimItemMaster_DiscontinuedYearPeriod]
    ON [AFISales_DW].[DimItemMaster]([DiscontinuedYearPeriod]);


GO
CREATE STATISTICS [Stat_DimItemMaster_DiscontinuedDate]
    ON [AFISales_DW].[DimItemMaster]([DiscontinuedDate]);


GO
CREATE STATISTICS [Stat_DimItemMaster_DiningSeriesFlag]
    ON [AFISales_DW].[DimItemMaster]([DiningSeriesFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_DefaultGroup]
    ON [AFISales_DW].[DimItemMaster]([DefaultGroup]);


GO
CREATE STATISTICS [Stat_DimItemMaster_Cubes]
    ON [AFISales_DW].[DimItemMaster]([Cubes]);


GO
CREATE STATISTICS [Stat_DimItemMaster_CountryofOrigin]
    ON [AFISales_DW].[DimItemMaster]([CountryofOrigin]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ConsumerChoiceFlag]
    ON [AFISales_DW].[DimItemMaster]([ConsumerChoiceFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_CommonCarrierFlag]
    ON [AFISales_DW].[DimItemMaster]([CommonCarrierFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_CommodityItem]
    ON [AFISales_DW].[DimItemMaster]([CommodityItem]);


GO
CREATE STATISTICS [Stat_DimItemMaster_CommissionClassDescription]
    ON [AFISales_DW].[DimItemMaster]([CommissionClassDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_CommissionClassCode]
    ON [AFISales_DW].[DimItemMaster]([CommissionClassCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_CommissionClass]
    ON [AFISales_DW].[DimItemMaster]([CommissionClass]);


GO
CREATE STATISTICS [Stat_DimItemMaster_Colors]
    ON [AFISales_DW].[DimItemMaster]([Colors]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ChildStyleDescription]
    ON [AFISales_DW].[DimItemMaster]([ChildStyleDescription]);


GO
CREATE STATISTICS [Stat_DimItemMaster_CEXCode]
    ON [AFISales_DW].[DimItemMaster]([CEXCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_BerklineProductFlag]
    ON [AFISales_DW].[DimItemMaster]([BerklineProductFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_BardiniProductFlag]
    ON [AFISales_DW].[DimItemMaster]([BardiniProductFlag]);


GO
CREATE STATISTICS [Stat_DimItemMaster_AssociationCode]
    ON [AFISales_DW].[DimItemMaster]([AssociationCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_AFISalesDivisionCode]
    ON [AFISales_DW].[DimItemMaster]([AFISalesDivisionCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_AFISalesDivision]
    ON [AFISales_DW].[DimItemMaster]([AFISalesDivision]);


GO
CREATE STATISTICS [Stat_DimItemMaster_AFISalesCategoryCode]
    ON [AFISales_DW].[DimItemMaster]([AFISalesCategoryCode]);


GO
CREATE STATISTICS [Stat_DimItemMaster_AFISalesCategory]
    ON [AFISales_DW].[DimItemMaster]([AFISalesCategory]);


GO
CREATE STATISTICS [Stat_DimItemMaster_AFIItemStatus]
    ON [AFISales_DW].[DimItemMaster]([AFIItemStatus]);


GO
CREATE STATISTICS [Stat_DimItemMaster_AFIFinanceDivision]
    ON [AFISales_DW].[DimItemMaster]([AFIFinanceDivision]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemStyle]
    ON [AFISales_DW].[DimItemMaster]([ItemStyle]);


GO
CREATE STATISTICS [Stat_DimItemMaster_Division]
    ON [AFISales_DW].[DimItemMaster]([Division]);


GO
CREATE STATISTICS [Stat_DimItemMaster_ItemIsRTA]
    ON [AFISales_DW].[DimItemMaster]([ItemIsRTA]);

