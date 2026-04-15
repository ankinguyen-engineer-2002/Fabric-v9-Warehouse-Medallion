CREATE TABLE [AFISales_DW].[FactOnTimeDelivery]
    (
        [RowID]                              BIGINT         NOT NULL, --IDENTITY(1, 1) 
        [Invoice Date]                       DATE           NULL,
        [AFI Warehouse]                      CHAR(3)        NULL,
        [Trip Number]                        DECIMAL(7)     NULL,
        [Account And Shipto Number]          CHAR(13)       NULL,
        [SalesTerritoryID]                   BIGINT         NULL,
        [Item Key]                           VARCHAR(22)    NOT NULL,
        [Billto AddressID]                   INT            NULL,
        [Shipto AddressID]                   INT            NULL,
        [Item Status]                        CHAR(1)        NULL,
        [Route Zone]                         CHAR(3)        NULL,
        [Route Region]                       CHAR(3)        NULL,
        [Order Type]                         VARCHAR(10)    NOT NULL,
        [Order Type3]                        VARCHAR(10)    NOT NULL,
        [Shipped Quantity]                   DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Order to Delivery]                  DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Originl Promise to Delivery]        DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Invoice To Delivery]                DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Current Request to Delivery]        DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [First Scan to Trip Close]           DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Trip Close to Delivery]             DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Original Request to Delivery]       DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Order to First Scan]                DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Trip Create to Trip Close]          DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Trip Create to First Scan]          DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Order to Trip Create]               DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Current Promise to Delivery]        DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Qty Ontime - Original Promise Day]  DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Qty Ontime - Original Promise Week] DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Qty Ontime - Current Request Day]   DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Qty Ontime - Current Request Week]  DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Qty Ontime - Original Request Day]  DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Qty Ontime - Original Request Week] DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Qty Ontime - Current Promise Day]   DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [Qty Ontime - Current Promise Week]  DECIMAL(13, 3) NULL, -- FLOAT (53)  
        [RegionCode_RepID_Category]          VARCHAR(13)    NULL,
        [AFI Sales Category]                 CHAR(3)        NOT NULL,
        [Customer Account Number]            CHAR(8)        NULL,
        [Customer Shipto Number]             CHAR(4)        NULL,
        [AFI Sales RepID]                    CHAR(5)        NOT NULL,
        [AFI Sales Region Code]              CHAR(3)        NOT NULL
    );

GO
CREATE STATISTICS [Stat_FactOnTimeDelivery_Trip_Number]
    ON [AFISales_DW].[FactOnTimeDelivery]
    (
        [Trip Number]
    );


GO
CREATE STATISTICS [Stat_FactOnTimeDelivery_Shipto_AddressID]
    ON [AFISales_DW].[FactOnTimeDelivery]
    (
        [Shipto AddressID]
    );


GO
CREATE STATISTICS [Stat_FactOnTimeDelivery_Invoice_Date]
    ON [AFISales_DW].[FactOnTimeDelivery]
    (
        [Invoice Date]
    );


GO
CREATE STATISTICS [Stat_FactOnTimeDelivery_Billto_AddressID]
    ON [AFISales_DW].[FactOnTimeDelivery]
    (
        [Billto AddressID]
    );


GO
CREATE STATISTICS [Stat_FactOnTimeDelivery_AFI_Warehouse]
    ON [AFISales_DW].[FactOnTimeDelivery]
    (
        [AFI Warehouse]
    );


GO
CREATE STATISTICS [Stat_FactOnTimeDelivery_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactOnTimeDelivery]
    (
        [Account And Shipto Number]
    );


GO
CREATE STATISTICS [Stat_FactOnTimeDelivery_SalesTerritoryID]
    ON [AFISales_DW].[FactOnTimeDelivery]
    (
        [SalesTerritoryID]
    );

