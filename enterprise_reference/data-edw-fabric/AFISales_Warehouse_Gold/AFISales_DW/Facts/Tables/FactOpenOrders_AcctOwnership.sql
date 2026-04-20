CREATE TABLE [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [RowID]                      [BIGINT]         NOT NULL,   --- Was Identity
        [Order Taken Date]           [DATE]           NULL,
        [Order Number]               [VARCHAR](10)    NULL,
        [Item Sequence Number]       [DECIMAL](7, 0)  NULL,
        [Account And ShipTo Number]  [CHAR](13)       NULL,
        [Customer Account Number]    [CHAR](8)        NULL,
        [Customer Shipto Number]     [CHAR](4)        NULL,
        [SalesTerritoryID]           [BIGINT]         NULL,
        [Territory]                  [CHAR](10)       NULL,
        [Item Key]                   [VARCHAR](22)    NOT NULL,
        [Item Sku]                   [VARCHAR](15)    NOT NULL,
        [Sales Division Code]        [CHAR](1)        NOT NULL,
        [Billto Address ID]          [INT]            NULL,
        [Shipto Address ID]          [INT]            NULL,
        [Warehouse]                  [CHAR](3)        NOT NULL,
        [Item Status]                [CHAR](3)        NULL,
        [Sales Category Code]        [VARCHAR](50)    NULL,
        [Open Order Amount]          [DECIMAL](13, 3) NULL,
        [Open Order Quantity]        [DECIMAL](13, 3) NULL,
        [Back Order Amount]          [DECIMAL](13, 3) NULL,
        [Back Order Quantity]        [DECIMAL](13, 3) NULL,
        [Original Promise Date]      [DATE]           NULL,
        [Current Promise Date]       [DATE]           NULL,
        [Original Request Date]      [DATE]           NULL,
        [Current Request Date]       [DATE]           NULL,
        [Primary Order Type]         [VARCHAR](30)    NULL,
        [Secondary Order Type]       [VARCHAR](30)    NULL,
        [3rd Order Type]             [VARCHAR](30)    NULL,
        [4th Order Type]             [VARCHAR](30)    NULL,
        [Inventory Allocated Flag]   [DECIMAL](1, 0)  NULL,
        [Current Load Date]          [DATE]           NULL,
        [Count of Load Date Changes] [DECIMAL](3, 0)  NULL,
        [Load Lead Time]             [DECIMAL](2, 0)  NULL,
        [Shipping Instructions]      [VARCHAR](30)    NULL,
        [RegionCode_RepID_Cat]       [VARCHAR](13)    NULL,
        [Sales Region Code]          [CHAR](3)        NOT NULL,
        [Sales Rep ID]               [CHAR](5)        NOT NULL,
        [Sku Number]                 [VARCHAR](60)    NULL,
        [Open Order Freight]         [DECIMAL](13, 3) NULL
    );





GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Shipping_Instructions]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Shipping Instructions]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Secondary_Order_Type]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Secondary Order Type]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_SalesTerritoryID]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [SalesTerritoryID]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Primary_Order_Type]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Primary Order Type]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Original_Request_Date]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Original Request Date]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Original_Promise_Date]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Original Promise Date]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Order_Warehouse]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Warehouse]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Order_Taken_Date]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Order Taken Date]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Order_Shipto_Address_ID]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Shipto Address ID]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Order_Number]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Order Number]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Order_item_Key]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Item Key]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Order_Billto_Address_ID]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Billto Address ID]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Order_Account_And_ShipTo_Number]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Account And ShipTo Number]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Open_Order_Quantity]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Open Order Quantity]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Open_Order_Freight]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Open Order Freight]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Open_Order_Amount]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Open Order Amount]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Load_Lead_Time]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Load Lead Time]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Item_Status]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Item Status]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Item_Sku]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Item Sku]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Item_Sequence_Number]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Item Sequence Number]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Inventory_Allocated_Flag]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Inventory Allocated Flag]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Customer_Shipto_Number]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Customer Shipto Number]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Customer_Account_Number]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Customer Account Number]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Current_Request_Date]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Current Request Date]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Current_Promise_Date]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Current Promise Date]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Current_Load_Date]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Current Load Date]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_Count_of_Load_Date_Changes]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [Count of Load Date Changes]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_4th_Order_Type]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [4th Order Type]
    );


GO
CREATE STATISTICS [Stat_FactOpenOrders_AcctOwnership_3rd_Order_Type]
    ON [AFISales_DW].[FactOpenOrders_AcctOwnership]
    (
        [3rd Order Type]
    );

