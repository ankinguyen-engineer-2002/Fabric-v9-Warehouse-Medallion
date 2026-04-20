CREATE TABLE [Quality_DW].[FactOpenOrders] (
    [RowID]                        BIGINT          NOT NULL,
    [OrderTakenDate]               DATE            NULL,
    [OrderNumber]                  VARCHAR (10)    NULL,
    [ItemSequenceNumber]           DECIMAL (7)     NULL,
    [AccountAndShipToNumber]       CHAR (13)       NULL,
    [CustomerAccountNumber]        CHAR (8)        NULL,
    [CustomerShiptoNumber]         CHAR (4)        NULL,
    [SalesTerritoryID]             BIGINT          NULL,
    [Territory]                    VARCHAR (10)    NULL,
    [ItemKey]                      VARCHAR (22)    NOT NULL,
    [ItemSku]                      VARCHAR (15)    NOT NULL,
    [SalesDivisionCode]            CHAR (1)        NOT NULL,
    [BilltoAddressID]              INT             NULL,
    [ShiptAddressID]               INT             NULL,
    [Warehouse]                    CHAR (3)        NOT NULL,
    [ItemStatus]                   CHAR (3)        NULL,
    [SalesCategory Code]           VARCHAR (50)    NULL,
    [OpenOrderAmount]              DECIMAL (19, 2) NULL,
    [OpenOrderQuantity]            DECIMAL (13, 3) NULL,
    [BackOrderAmount]              Decimal(13,3)           NULL,
    [BackOrderQuantity]            DECIMAL (13, 3) NULL,
    [OriginalPromiseDate]          DATE            NULL,
    [CurrentPromiseDate]           DATE            NULL,
    [OriginalRequestDate]          DATE            NULL,
    [CurrentRequestDate]           DATE            NULL,
    [PrimaryOrderType]             VARCHAR (30)    NULL,
    [SecondaryOrderType]           VARCHAR (30)    NULL,
    [3rdOrderType]                 VARCHAR (30)    NULL,
    [4thOrderType]                 VARCHAR (30)    NULL,
    [InventoryAllocatedFlag]       DECIMAL (1)     NULL,
    [CurrentLoadDate]              DATE            NULL,
    [CountofLoadDateChanges]       DECIMAL (3)     NULL,
    [LoadLeadTime]                 DECIMAL (2)     NULL,
    [ShippingInstructions]         VARCHAR (30)    NULL,
    [RegionCodeRepIDCat]           VARCHAR (13)    NULL,
    [SalesRegionCode]              CHAR (3)        NOT NULL,
    [SalesRepID]                   CHAR (5)        NOT NULL,
    [CustomerSKUPackage]           VARCHAR (30)    NULL,
    [CustomerShiptoDivisionNumber] VARCHAR (15)    NULL,
    [OpenOrderDiscounts]           DECIMAL (13, 3) NULL,
    [OpenOrderFreight]             DECIMAL (13, 3) NULL
)
GO


CREATE STATISTICS [Stat_FactOpenOrders_3rd_Order_Type]
    ON [Quality_DW].[FactOpenOrders]([3rdOrderType]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_4th_Order_Type]
    ON [Quality_DW].[FactOpenOrders]([4thOrderType]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Count_of_Load_Date_Changes]
    ON [Quality_DW].[FactOpenOrders]([CountofLoadDateChanges]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Current_Load_Date]
    ON [Quality_DW].[FactOpenOrders]([CurrentLoadDate]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Current_Promise_Date]
    ON [Quality_DW].[FactOpenOrders]([CurrentPromiseDate]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Current_Request_Date]
    ON [Quality_DW].[FactOpenOrders]([CurrentRequestDate]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Customer_Account_Number]
    ON [Quality_DW].[FactOpenOrders]([CustomerAccountNumber]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Customer_Shipto_Number]
    ON [Quality_DW].[FactOpenOrders]([CustomerShiptoNumber]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Inventory_Allocated_Flag]
    ON [Quality_DW].[FactOpenOrders]([InventoryAllocatedFlag]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Item_Sequence_Number]
    ON [Quality_DW].[FactOpenOrders]([ItemSequenceNumber]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Item_Sku]
    ON [Quality_DW].[FactOpenOrders]([ItemSku]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Item_Status]
    ON [Quality_DW].[FactOpenOrders]([ItemStatus]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Load_Lead_Time]
    ON [Quality_DW].[FactOpenOrders]([LoadLeadTime]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Open_Order_Amount]
    ON [Quality_DW].[FactOpenOrders]([OpenOrderAmount]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Open_Order_Quantity]
    ON [Quality_DW].[FactOpenOrders]([OpenOrderQuantity]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Order_Account_And_ShipTo_Number]
    ON [Quality_DW].[FactOpenOrders]([AccountAndShipToNumber]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Order_Billto_Address_ID]
    ON [Quality_DW].[FactOpenOrders]([BilltoAddressID]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Order_item_Key]
    ON [Quality_DW].[FactOpenOrders]([ItemKey]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Order_Number]
    ON [Quality_DW].[FactOpenOrders]([OrderNumber]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Order_Taken_Date]
    ON [Quality_DW].[FactOpenOrders]([OrderTakenDate]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Order_Warehouse]
    ON [Quality_DW].[FactOpenOrders]([Warehouse]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Original_Promise_Date]
    ON [Quality_DW].[FactOpenOrders]([OriginalPromiseDate]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Original_Request_Date]
    ON [Quality_DW].[FactOpenOrders]([OriginalRequestDate]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Primary_Order_Type]
    ON [Quality_DW].[FactOpenOrders]([PrimaryOrderType]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_SalesTerritoryID]
    ON [Quality_DW].[FactOpenOrders]([SalesTerritoryID]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Secondary_Order_Type]
    ON [Quality_DW].[FactOpenOrders]([SecondaryOrderType]);
GO

CREATE STATISTICS [Stat_FactOpenOrders_Shipping_Instructions]
    ON [Quality_DW].[FactOpenOrders]([ShippingInstructions]);
GO

