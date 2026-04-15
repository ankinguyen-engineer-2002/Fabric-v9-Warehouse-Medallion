CREATE TABLE [AFISales_DW].[FactOrderHistory_Type2] (
    [RowID]                     BIGINT          NOT NULL, --   IDENTITY (1, 1)
    [Order Change Date]         DATE            NULL,
    [Order Number]              VARCHAR (10)    NOT NULL,
    [Order Sequence]            INT             NOT NULL,
    [Account And Shipto Number] CHAR (13)       NULL,
    [Territory]                 CHAR (10)       NULL,
    [Item SKU]                  VARCHAR (15)    NULL,
    [item Key]                  VARCHAR (22)    NULL,
    [Store Address ID]          INT             NULL,
    [Shipto AddressID]          INT             NULL,
    [SalesTerritoryID]          BIGINT          NULL,
    [Goal ID]                   INT             NOT NULL,
    [Week End Date]             DATE            NULL,
    [Warehouse]                 CHAR (3)        NOT NULL,
    [Item Status]               CHAR (1)        NOT NULL,
    [Amount Cancelled]          DECIMAL (11, 3) NULL,
    [Quantity Ordered]          DECIMAL (7, 3)  NULL,
    [Amount Ordered]            DECIMAL (11, 3) NULL,
    [Order Freight]             DECIMAL (11, 3) NULL,
    [Total Freight]             DECIMAL (11, 3) NULL,
    [Allocated Order Freight]   DECIMAL (11, 3) NULL,
    [Order Discounts]           DECIMAL (11, 3) NULL,
    [Request Date]              DATE            NULL,
    [Quantity Cancelled]        DECIMAL (11, 3) NULL,
    [Reason Code]               VARCHAR (30)    NULL
)


GO
CREATE STATISTICS [Stat_FactOrderHistory_Type2_Territory]
    ON [AFISales_DW].[FactOrderHistory_Type2]([Territory]);


GO
CREATE STATISTICS [Stat_FactOrderHistory_Type2_Order_Change_date]
    ON [AFISales_DW].[FactOrderHistory_Type2]([Order Change Date]);


GO
CREATE STATISTICS [Stat_FactOrderHistory_Type2_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactOrderHistory_Type2]([Account And Shipto Number]);

