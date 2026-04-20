CREATE TABLE [AFISales_Enh].[CustomerProfitability]
    (
        [Item Number]                    VARCHAR(15)    NOT NULL,
        [Price_Current_FOBArc]           DECIMAL(8, 2)  NULL,
        [SeriesNumber]                   VARCHAR(5)     NULL,
        [AFIFinanceDivision]             VARCHAR(30)    NULL,
        [ItemGrouping]                   VARCHAR(35)    NULL,
        [ItemClassCode]                  CHAR(4)        NULL,
        [Account]                        VARCHAR(30)    NULL,
        [Shipto]                         VARCHAR(4)     NULL,
        [CustomerName_Shipto]            VARCHAR(25)    NULL,
        [BusinessType_Shipto]            VARCHAR(50)    NULL,
        [CustomerName_Parent]            VARCHAR(25)    NULL,
        [BusinessType_Parent]            VARCHAR(50)    NULL,
        [FiscalMonthYearName]            VARCHAR(20)    NULL,
        [FiscalYear]                     SMALLINT       NULL,
        [SCG_DC]                         VARCHAR(14)    NULL,
        [Total_NetAmount_Shipped]        DECIMAL(13, 3) NULL,
        [Total_NetQTY_Shipped]           DECIMAL(13, 3) NULL,
        [Total_Cubes]                    DECIMAL(13, 3) NULL,
        [ASP_Product]                    DECIMAL(13, 3) NULL,
        [Total_LandedCost_History]       DECIMAL(13, 3) NULL,
        [Total_LandedCost_FlexContainer] DECIMAL(13, 3) NULL,
        [Total_LandedCost_AllIn]         DECIMAL(13, 3) NULL,
        [NetMargin_History]              DECIMAL(13, 3) NULL,
        [NetMargin_FlexContainer]        DECIMAL(13, 3) NULL,
        [NetMargin_AllIn]                DECIMAL(13, 3) NULL,
        [SuggestPrice_History]           DECIMAL(13, 3) NULL,
        [SuggestPrice_FlexContainer]     DECIMAL(13, 3) NULL,
        [SuggestPrice_AllIn]             DECIMAL(13, 3) NULL,
        [Dom_MFG_Extended]               DECIMAL(13, 3) NULL,
        [Dom_MFG_Extended_LaborKitInc]   NUMERIC(13, 3) NULL,
        [FOB_Asia_Extended]              DECIMAL(13, 3) NULL,
        [OceanFreight_Ext]               DECIMAL(13, 3) NULL,
        [OceanFreight_Ext_Flex]          DECIMAL(13, 3) NULL,
        [Cost_Outbound_Xfer_Extended]    DECIMAL(13, 3) NULL,
        [Cost_Transp_Xfer_Extended]      DECIMAL(13, 3) NULL,
        [FOB_Asia_KitInc]                DECIMAL(13, 3) NULL,
        [OceanFreight_Ext_KitInc]        DECIMAL(13, 3) NULL,
        [OceanFreight_Ext_Flex_KitInc]   DECIMAL(13, 3) NULL,
        [Cost_FinalMileTransportation]   DECIMAL(13, 3) NULL,
        [Cost_InbHand_Shipping]          DECIMAL(13, 3) NULL,
        [Cost_OutbHand_Shipping]         DECIMAL(13, 3) NULL,
        [QTY_Wanek]                      INT            NULL,
        [QTY_Mill]                       INT            NULL,
        [QTY_3PV]                        INT            NULL,
        [QTY_Domestic]                   DECIMAL(13, 3) NULL,
        [NetAmount_FOBArcPrice]          DECIMAL(13, 3) NULL,
        [NetAmount_ContractPrice]        DECIMAL(13, 3) NULL,
        [NetAmount_BasePrice]            DECIMAL(13, 3) NULL,
        [NetQTY_PriceException]          DECIMAL(13, 3) NULL,
        [Cost_Commission]                DECIMAL(13, 3) NULL,
        [Total_AdvertisingAcrrual]       DECIMAL(13, 3) NULL,
        [Cost_QualityCredits]            DECIMAL(13, 3) NULL,
        [Total_FreightRevenue]           DECIMAL(13, 3) NULL
    );


GO
CREATE STATISTICS [Stat_CustomerProfitability_ItemNumber]
    ON [AFISales_Enh].[CustomerProfitability]
    (
        [Item Number]
    );


GO
CREATE STATISTICS [Stat_CustomerProfitability_Account]
    ON [AFISales_Enh].[CustomerProfitability]
    (
        [Account]
    );

