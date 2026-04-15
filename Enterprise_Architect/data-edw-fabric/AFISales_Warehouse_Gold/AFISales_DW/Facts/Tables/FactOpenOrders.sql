CREATE TABLE [AFISales_DW].[FactOpenOrders] (
    [RowID]                           BIGINT          NULL,
    [Order Taken Date]                DATE            NULL,
    [Order Number]                    VARCHAR (10)    NULL,
    [Item Sequence Number]            DECIMAL (7)     NULL,
    [Account And Shipto Number]       CHAR (13)       NULL,
    [Customer Account Number]         CHAR (8)        NULL,
    [Customer Shipto Number]          CHAR (4)        NULL,
    [SalesTerritoryID]                BIGINT          NULL,
    [Territory]                       CHAR (10)       NULL,
    [Item Key]                        VARCHAR (22)    NOT NULL,
    [Item SKU]                        VARCHAR (15)    NOT NULL,
    [Sales Division Code]             CHAR (1)        NULL,
    [Billto Address ID]               INT             NULL,
    [Shipto Address ID]               INT             NULL,
    [Warehouse]                       CHAR (3)        NOT NULL,
    [Item Status]                     CHAR (3)        NULL,
    [Sales Category Code]             CHAR (3)        NULL,
    [Open Order Amount]               DECIMAL (13, 3) NULL,
    [Open Order Quantity]             DECIMAL (13, 3) NULL,
    [Back Order Amount]               DECIMAL (13, 3) NULL,  -- MONEY
    [Order Arrival Mode]              CHAR (2)        NULL,
    [Back Order Quantity]             DECIMAL (13, 3) NULL,
    [Original Promise Date]           DATE            NULL,
    [Current Promise Date]            DATE            NULL,
    [Estimated Delivery Date]         DATE            NULL,
    [Initial Promise Date]            DATE            NULL,
    [Original Request Date]           DATE            NULL,
    [Current Request Date]            DATE            NULL,
    [Primary Order Type]              VARCHAR (30)    NULL,
    [Secondary Order Type]            VARCHAR (30)    NULL,
    [3rd Order Type]                  VARCHAR (30)    NULL,
    [4th Order Type]                  VARCHAR (30)    NULL,
    [Inventory Allocated Flag]        DECIMAL (1)     NULL,
    [Current Load Date]               DATE            NULL,
    [Count of Load Date Changes]      DECIMAL (3)     NULL,
    [Load Lead Time]                  DECIMAL (2)     NULL,
    [Shipping Instructions]           VARCHAR (30)    NULL,
    [RegionCode_RepID_Cat]            VARCHAR (13)    NULL,
    [Sales Region Code]               CHAR (3)        NULL,
    [Sales Rep ID]                    CHAR (5)        NULL,
    [Customer SKU/Package]            VARCHAR (30)    NULL,
    [Customer Shipto Division Number] VARCHAR (15)    NULL,
    [Open Order Discounts]            DECIMAL (13, 3) NULL,
    [Open Order Freight]              DECIMAL (13, 3) NULL,
    [Trip Number(s)]                  VARCHAR (650)   NULL,
    [Customer PO]                     VARCHAR (22)    NULL
)
GO

CREATE STATISTICS [Stat_FactOpenOrders_SalesTerritoryID]
    ON [AFISales_DW].[FactOpenOrders]([SalesTerritoryID]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Order_Warehouse]
    ON [AFISales_DW].[FactOpenOrders]([Warehouse]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Order_Taken_Date]
    ON [AFISales_DW].[FactOpenOrders]([Order Taken Date]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Order_Shipto_Address_ID]
    ON [AFISales_DW].[FactOpenOrders]([Shipto Address ID]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Order_item_Key]
    ON [AFISales_DW].[FactOpenOrders]([Item Key]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Order_Billto_Address_ID]
    ON [AFISales_DW].[FactOpenOrders]([Billto Address ID]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Order_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactOpenOrders]([Account And Shipto Number]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Shipping_Instructions]
    ON [AFISales_DW].[FactOpenOrders]([Shipping Instructions]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Secondary_Order_Type]
    ON [AFISales_DW].[FactOpenOrders]([Secondary Order Type]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Primary_Order_Type]
    ON [AFISales_DW].[FactOpenOrders]([Primary Order Type]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Original_Request_Date]
    ON [AFISales_DW].[FactOpenOrders]([Original Request Date]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Original_Promise_Date]
    ON [AFISales_DW].[FactOpenOrders]([Original Promise Date]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Order_Number]
    ON [AFISales_DW].[FactOpenOrders]([Order Number]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Open_Order_Quantity]
    ON [AFISales_DW].[FactOpenOrders]([Open Order Quantity]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Open_Order_Amount]
    ON [AFISales_DW].[FactOpenOrders]([Open Order Amount]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Load_Lead_Time]
    ON [AFISales_DW].[FactOpenOrders]([Load Lead Time]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Item_Status]
    ON [AFISales_DW].[FactOpenOrders]([Item Status]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Item_SKU]
    ON [AFISales_DW].[FactOpenOrders]([Item SKU]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Item_Sequence_Number]
    ON [AFISales_DW].[FactOpenOrders]([Item Sequence Number]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Inventory_Allocated_Flag]
    ON [AFISales_DW].[FactOpenOrders]([Inventory Allocated Flag]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Customer_Shipto_Number]
    ON [AFISales_DW].[FactOpenOrders]([Customer Shipto Number]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Customer_Account_Number]
    ON [AFISales_DW].[FactOpenOrders]([Customer Account Number]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Current_Request_Date]
    ON [AFISales_DW].[FactOpenOrders]([Current Request Date]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Current_Promise_Date]
    ON [AFISales_DW].[FactOpenOrders]([Current Promise Date]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Current_Load_Date]
    ON [AFISales_DW].[FactOpenOrders]([Current Load Date]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_Count_of_Load_Date_Changes]
    ON [AFISales_DW].[FactOpenOrders]([Count of Load Date Changes]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_4th_Order_Type]
    ON [AFISales_DW].[FactOpenOrders]([4th Order Type]);


GO
CREATE STATISTICS [Stat_FactOpenOrders_3rd_Order_Type]
    ON [AFISales_DW].[FactOpenOrders]([3rd Order Type]);

