CREATE TABLE [AFISales_Enh].[DirectShipFreightAnalysis] (
    [Tracking Number]                      VARCHAR (40)   NULL,
    [AFI Order Number]                     VARCHAR (10)   NOT NULL,
    [Ashcomm Order Number]                 VARCHAR (20)   NULL,
    [AFI Invoice Number]                   DECIMAL (9)    NOT NULL,
    [AFI Ship Date]                        DATE           NOT NULL,
    [AFI Order Date]                       DATE           NULL,
    [SKU]                                  VARCHAR (15)   NOT NULL,
    [PIM Depth (in)]                       DECIMAL (9, 2) NULL,
    [PIM Width (in)]                       DECIMAL (9, 2) NULL,
    [PIM Height (in)]                      DECIMAL (9, 2) NULL,
    [PIM Weight (lb)]                      DECIMAL (9, 2) NULL,
    [Billed Freight (B2B)]                 DECIMAL (9, 2) NULL,
    [Billed Freight (B2C)]                 DECIMAL (9, 2) NULL,
    [Landed Shipping (component of price)] DECIMAL (6, 2) NULL,
    [Wholesale Customer #]                 CHAR (8)       NOT NULL,
    [Ashcomm Customer #]                   VARCHAR (20)   NULL,
    [Ship From Warehouse]                  VARCHAR (50)   NULL,
    [Ship From Zipcode]                    CHAR (8)       NULL,
    [Shipto Zipcode]                       VARCHAR (15)   NULL,
    [Carrier]                              VARCHAR (15)   NULL,
    [Overpack]                             INT            NULL,
    [ExpressFreight]                       DECIMAL (9, 2) NULL,
    [ExpressHandlingFee]                   DECIMAL (9, 2) NULL,
    [OtherFreight]                         DECIMAL (9, 2) NULL,
    [LoadDate]                             DATE           NULL
)

GO
CREATE STATISTICS [Stat_DirectShipFreightAnalysis_TrackingNumber]
    ON [AFISales_Enh].[DirectShipFreightAnalysis]([Tracking Number]);


GO
CREATE STATISTICS [Stat_DirectShipFreightAnalysis_SKU]
    ON [AFISales_Enh].[DirectShipFreightAnalysis]([SKU]);


GO
CREATE STATISTICS [Stat_DirectShipFreightAnalysis_LoadDate]
    ON [AFISales_Enh].[DirectShipFreightAnalysis]([LoadDate]);


GO
CREATE STATISTICS [Stat_DirectShipFreightAnalysis_Carrier]
    ON [AFISales_Enh].[DirectShipFreightAnalysis]([Carrier]);


GO
CREATE STATISTICS [Stat_DirectShipFreightAnalysis_Overpack]
    ON [AFISales_Enh].[DirectShipFreightAnalysis]([Overpack]);


GO
CREATE STATISTICS [Stat_DirectShipFreightAnalysis_Ashcomm_Customer_#]
    ON [AFISales_Enh].[DirectShipFreightAnalysis]([Ashcomm Customer #]);


GO
CREATE STATISTICS [Stat_DirectShipFreightAnalysis_AFI_Ship_Date]
    ON [AFISales_Enh].[DirectShipFreightAnalysis]([AFI Ship Date]);


GO
CREATE STATISTICS [Stat_DirectShipFreightAnalysis_AFI_Invoice_Number]
    ON [AFISales_Enh].[DirectShipFreightAnalysis]([AFI Invoice Number]);


GO


