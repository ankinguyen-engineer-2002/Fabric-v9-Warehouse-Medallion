CREATE TABLE [AFISales_DW].[FactOrderHistory_AcctOwnership]
    (
        [RowID]                           [BIGINT]         NOT NULL, --IDENTITY(1, 1)
        [Order Change Date]               [DATE]           NULL,
        [Order Number]                    [VARCHAR](10)    NOT NULL,
        [Order Sequence]                  [INT]            NOT NULL,
        [Account And Shipto Number]       [CHAR](13)       NULL,
        [Territory]                       [CHAR](10)       NULL,
        [Item SKU]                        [VARCHAR](15)    NULL,
        [item Key]                        [VARCHAR](22)    NULL,
        [Store Address ID]                [INT]            NULL,
        [Shipto AddressID]                [INT]            NULL,
        [SalesTerritoryID]                [BIGINT]         NULL,
        [Goal ID]                         [INT]            NOT NULL,
        [Week End Date]                   [DATE]           NULL,
        [Warehouse]                       [CHAR](3)        NOT NULL,
        [Item Status]                     [CHAR](1)        NOT NULL,
        [Amount Cancelled]                [DECIMAL](11, 3) NULL,
        [Quantity Ordered]                [DECIMAL](7, 3)  NULL,
        [Amount Ordered]                  [DECIMAL](11, 3) NULL,
        [Order Freight]                   [DECIMAL](11, 3) NULL,
        [Total Freight]                   [DECIMAL](11, 3) NULL,
        [Allocated Order Freight]         [DECIMAL](11, 3) NULL,
        [Order Discounts]                 [DECIMAL](11, 3) NULL,
        [Request Date]                    [DATE]           NULL,
        [AHORDT_Date]                     [DATE]           NULL,
        [Order Arrival Mode]              [VARCHAR](25)    NULL,
        [Primary Order Type]              [VARCHAR](30)    NULL,
        [Secondary Order Type]            [VARCHAR](30)    NULL,
        [3rd Order Type]                  [VARCHAR](30)    NULL,
        [4th Order Type]                  [VARCHAR](30)    NULL,
        [Customer Account Number]         [CHAR](8)        NULL,
        [Customer Shipto Number]          [CHAR](4)        NULL,
        [Sales Division Code]             [CHAR](1)        NOT NULL,
        [Sales Region Code]               [CHAR](3)        NOT NULL,
        [Sales RepID]                     [CHAR](5)        NOT NULL,
        [RegionCode_RepID_Cat]            [VARCHAR](13)    NULL,
        [Sales Category]                  [CHAR](3)        NOT NULL,
        [Quantity Cancelled]              [DECIMAL](7, 3)  NULL,
        [Reason Code]                     [VARCHAR](30)    NULL,
        [Customer Shipto Division Number] [VARCHAR](15)    NULL
    );



GO
CREATE STATISTICS [Stat_FactOrderHistory_AcctOwnership_Warehouse]
    ON [AFISales_DW].[FactOrderHistory_AcctOwnership]
    (
        [Warehouse]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_AcctOwnership_Territory]
    ON [AFISales_DW].[FactOrderHistory_AcctOwnership]
    (
        [Territory]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_AcctOwnership_Store_Address_ID]
    ON [AFISales_DW].[FactOrderHistory_AcctOwnership]
    (
        [Store Address ID]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_AcctOwnership_Shipto_AddressID]
    ON [AFISales_DW].[FactOrderHistory_AcctOwnership]
    (
        [Shipto AddressID]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_AcctOwnership_Request_Date]
    ON [AFISales_DW].[FactOrderHistory_AcctOwnership]
    (
        [Request Date]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_AcctOwnership_Order_Change_Date]
    ON [AFISales_DW].[FactOrderHistory_AcctOwnership]
    (
        [Order Change Date]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_AcctOwnership_Item_Status]
    ON [AFISales_DW].[FactOrderHistory_AcctOwnership]
    (
        [Item Status]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_AcctOwnership_Item_SKU]
    ON [AFISales_DW].[FactOrderHistory_AcctOwnership]
    (
        [Item SKU]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_AcctOwnership_AHORDT_Date]
    ON [AFISales_DW].[FactOrderHistory_AcctOwnership]
    (
        [AHORDT_Date]
    );


GO
CREATE STATISTICS [Stat_FactOrderHistory_AcctOwnership_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactOrderHistory_AcctOwnership]
    (
        [Account And Shipto Number]
    );

