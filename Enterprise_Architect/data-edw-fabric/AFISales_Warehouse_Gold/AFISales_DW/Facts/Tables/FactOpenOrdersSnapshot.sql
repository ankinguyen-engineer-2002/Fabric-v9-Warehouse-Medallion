CREATE TABLE [AFISales_DW].[FactOpenOrdersSnapshot] (
    [RowID]                      BIGINT          NOT NULL,   --- Was Identity
    [Order Taken Date]           DATE            NULL,
    [Order Number]               VARCHAR (10)    NULL,
    [Item Sequence Number]       DECIMAL (7)     NULL,
    [Account And Shipto Number]  CHAR (13)       NULL,
    [Customer Account Number]    CHAR (8)        NULL,
    [Customer Shipto Number]     CHAR (4)        NULL,
    [SalesTerritoryID]           BIGINT          NULL,
    [Territory]                  CHAR (10)       NULL,
    [Item Key]                   VARCHAR (22)    NOT NULL,
    [Item SKU]                   VARCHAR (15)    NOT NULL,
    [Billto Address ID]          INT             NULL,
    [Shipto Address ID]          INT             NULL,
    [Warehouse]                  CHAR (3)        NOT NULL,
    [Open Order Amount]          DECIMAL (13, 3) NULL,  -- was money
    [Open Order Quantity]        DECIMAL (13, 3) NULL,
    [Back Order Amount]          DECIMAL (13, 3) NULL,  -- was money
    [Back Order Quantity]        DECIMAL (13, 3) NULL,  
    [Original Promise Date]      DATE            NULL,
    [Current Promise Date]       DATE            NULL,
    [Original Request Date]      DATE            NULL,
    [Current Request Date]       DATE            NULL,
    [Estimated Delivery Date]    DATE            NULL,
    [Initial Request Date]       DATE            NULL,
    [Primary Order Type]         VARCHAR (30)    NULL,
    [Secondary Order Type]       VARCHAR (30)    NULL,
    [3rd Order Type]             VARCHAR (30)    NULL,
    [4th Order Type]             VARCHAR (30)    NULL,
    [Inserted Date]              DATETIME2 (6)   NULL,  -- was datetime
    [Inventory Allocated Flag]   DECIMAL (1)     NULL,
    [Current Load Date]          DATE            NULL,
    [Count of Load Date Changes] DECIMAL (3)     NULL,
    [Load Lead Time]             DECIMAL (2)     NULL,
    [Shipping Instructions]      VARCHAR (30)    NULL,
    [Order Arrival Mode]         CHAR (2)        NULL
)

GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_3rd_Order_Type]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([3rd Order Type]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_4th_Order_Type]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([4th Order Type]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Account And Shipto Number]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Back_Order_Amount]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Back Order Amount]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Back_Order_Quantity]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Back Order Quantity]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Billto_Address_ID]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Billto Address ID]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Count_of_Load_Date_Changes]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Count of Load Date Changes]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Current_Load_Date]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Current Load Date]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Current_Promise_Date]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Current Promise Date]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Current_Request_Date]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Current Request Date]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Customer_Account_Number]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Customer Account Number]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Customer_Shipto_Number]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Customer Shipto Number]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Inserted_Date]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Inserted Date]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Inventory_Allocated_Flag]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Inventory Allocated Flag]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Item_Key]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Item Key]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Item_Sequence_Number]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Item Sequence Number]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Item_SKU]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Item SKU]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Load_Lead_Time]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Load Lead Time]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Open_Order_Amount]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Open Order Amount]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Open_Order_Quantity]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Open Order Quantity]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Order_Number]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Order Number]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Order_Taken_Date]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Order Taken Date]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Original_Promise_Date]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Original Promise Date]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Original_Request_Date]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Original Request Date]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Primary_Order_Type]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Primary Order Type]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_SalesTerritoryID]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([SalesTerritoryID]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Secondary_Order_Type]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Secondary Order Type]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Shipping_Instructions]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Shipping Instructions]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Shipto_Address_ID]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Shipto Address ID]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Territory]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Territory]);
GO

CREATE STATISTICS [Stat_FactOpenOrdersSnapshot_Warehouse]
    ON [AFISales_DW].[FactOpenOrdersSnapshot]([Warehouse]);
GO

