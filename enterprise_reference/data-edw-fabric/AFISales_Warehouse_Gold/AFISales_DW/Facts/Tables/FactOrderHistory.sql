CREATE TABLE [AFISales_DW].[FactOrderHistory]
    (
        [RowID]                           BIGINT         NOT NULL, -- IDENTITY (1, 1)
        [Order Change Date]               DATE           NULL,
        [Order Number]                    VARCHAR(10)    NOT NULL,
        [Order Sequence]                  INT            NOT NULL,
        [Account And Shipto Number]       CHAR(13)       NULL,
        [Territory]                       CHAR(10)       NULL,
        [Item SKU]                        VARCHAR(15)    NULL,
        [Item Key]                        VARCHAR(22)    NULL,
        [Store Address ID]                INT            NULL,
        [Shipto AddressID]                INT            NULL,
        [SalesTerritoryID]                BIGINT         NULL,
        [Goal ID]                         INT            NOT NULL,
        [Week End Date]                   DATE           NULL,
        [Warehouse]                       CHAR(3)        NOT NULL,
        [Item Status]                     CHAR(1)        NOT NULL,
        [Amount Cancelled]                DECIMAL(11, 3) NULL,
        [Quantity Ordered]                DECIMAL(7, 3)  NULL,
        [Amount Ordered]                  DECIMAL(11, 3) NULL,
        [Order Freight]                   DECIMAL(11, 3) NULL,
        [Total Freight]                   DECIMAL(11, 3) NULL,
        [Allocated Order Freight]         DECIMAL(11, 3) NULL,
        [Order Discounts]                 DECIMAL(11, 3) NULL,
        [Request Date]                    DATE           NULL,
        [Order Date]                      DATE           NULL,
        [Order Arrival Mode]              VARCHAR(25)    NULL,
        [Primary Order Type]              VARCHAR(30)    NULL,
        [Secondary Order Type]            VARCHAR(30)    NULL,
        [3rd Order Type]                  VARCHAR(30)    NULL,
        [4th Order Type]                  VARCHAR(30)    NULL,
        [Customer Account Number]         CHAR(8)        NULL,
        [Customer Shipto Number]          CHAR(4)        NULL,
        [Sales Division Code]             CHAR(1)        NOT NULL,
        [Sales Region Code]               CHAR(3)        NOT NULL,
        [Sales RepID]                     CHAR(5)        NOT NULL,
        [RegionCode_RepID_Cat]            VARCHAR(13)    NULL,
        [Sales Category]                  CHAR(3)        NOT NULL,
        [Quantity Cancelled]              DECIMAL(7, 3)  NULL,
        [Reason Code]                     VARCHAR(30)    NULL,
        [Customer Shipto Division Number] VARCHAR(15)    NULL
    );

GO
CREATE STATISTICS [Stat_FactOrderHistory_Warehouse]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Warehouse]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Territory]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Territory]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Store_Address_ID]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Store Address ID]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Shipto_AddressID]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Shipto AddressID]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Request_Date]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Request Date]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Order_Change_Date]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Order Change Date]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Item_Status]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Item Status]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Item_SKU]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Item SKU]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Order_Date]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Order Date]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Account And Shipto Number]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Week_End_Date]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Week End Date]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Type2_RowID]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [RowID]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Secondary_Order_Type]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Secondary Order Type]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_SalesTerritoryID]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [SalesTerritoryID]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Sales_Division_Code]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Sales Division Code]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_RowID]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [RowID]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Quantity_Ordered]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Quantity Ordered]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Primary_Order_Type]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Primary Order Type]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Order_Sequence]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Order Sequence]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Order_Number]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Order Number]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Order_Arrival_Mode]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Order Arrival Mode]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Item_Key]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Item Key]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Customer_Shipto_Number]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Customer Shipto Number]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Customer_Account_Number]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Customer Account Number]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_Amount_Ordered]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Amount Ordered]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_AcctOwnership_SalesTerritoryID]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [SalesTerritoryID]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_AcctOwnership_Amount_Ordered]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [Amount Ordered]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_4th_Order_Type]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [4th Order Type]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_3rd_Order_Type]
    ON [AFISales_DW].[FactOrderHistory]
    (
        [3rd Order Type]
    );

