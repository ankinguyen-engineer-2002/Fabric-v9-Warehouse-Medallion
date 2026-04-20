CREATE TABLE [AFISales_DW].[FactOpenOrdersPriceAudit] (
    [RowID]                              BIGINT          NOT NULL, -- IDENTITY (1, 1)
    [Order Taken Date]                   DATE            NULL,
    [Order Number]                       VARCHAR (10)    NULL,
    [Item Sequence Number]               DECIMAL (7)     NULL,
    [Account And Shipto Number]          CHAR (13)       NULL,
    [Customer Account Number]            CHAR (8)        NULL,
    [Customer Shipto Number]             CHAR (4)        NULL,
    [Item Key]                           VARCHAR (22)    NOT NULL,
    [Item Sku]                           VARCHAR (15)    NOT NULL,
    [Warehouse]                          CHAR (3)        NOT NULL,
    [Order Amount Without Freight]       DECIMAL (8, 2)  NULL,
    [Order Quantity]                     DECIMAL (6, 3)  NULL,
    [Order Freight]                      DECIMAL (8, 2)  NULL,
    [Order Item Unit Price]              DECIMAL (8, 2)  NULL,
    [Current Item Unit Price]            DECIMAL (8, 2)  NULL,
    [Discrepency Count]                  INT             NULL,
    [Line Item Count]                    INT             NULL,
    [Order Discrepancy]                  DECIMAL (8, 2)  NULL,
    [Base Price Discrepancy]             DECIMAL (8, 2)  NULL,
    [Unit Price Discrepancy]             DECIMAL (8, 2)  NULL,
    [Current Amount Without Freight]     DECIMAL (8, 2)  NULL,
    [Current Base Price]                 DECIMAL (8, 2)  NULL,
    [Current Volume Disc1]               DECIMAL (6, 2)  NULL,
    [Current Hidden Disc2]               DECIMAL (6, 2)  NULL,
    [Current Volume Disc3]               DECIMAL (6, 2)  NULL,
    [Current Coop Accrual]               DECIMAL (6, 2)  NULL,
    [Current Hidden Prem5]               DECIMAL (6, 2)  NULL,
    [Current DFI Disc6]                  DECIMAL (6, 2)  NULL,
    [Current Premium Disc7]              DECIMAL (6, 2)  NULL,
    [Current BuyGroup Exception ID]      BIGINT          NULL,
    [Current BuyGroup Code]              CHAR (3)        NULL,
    [Current Exception ID (order)]       BIGINT          NULL,
    [Current Exception ID (Shipto/Whse)] BIGINT          NULL,
    [Current Exception ID (Shipto)]      BIGINT          NULL,
    [Current Exception ID (Cust/Whse)]   BIGINT          NULL,
    [Current Exception ID (Cust)]        BIGINT          NULL,
    [Current Discount Code]              VARCHAR (3)     NULL,
    [Current Discount Class]             VARCHAR (3)     NULL,
    [Current Price Code]                 VARCHAR (6)     NULL,
    [Current Container Direct Flag]      VARCHAR (1)     NULL,
    [Order Discount]                     DECIMAL (8, 2)  NULL,
    [Order DFI Discount]                 DECIMAL (8, 2)  NULL,
    [Order Exception ID]                 BIGINT          NULL,
    [Order Discount Code]                VARCHAR (3)     NULL,
    [Order Discount Class]               VARCHAR (3)     NULL,
    [Order Price Code]                   VARCHAR (6)     NULL,
    [Order Total Discount]               DECIMAL (8, 2)  NULL,
    [Order BuyGroup Code]                CHAR (3)        NULL,
    [Order BuyGroup Exception ID]        BIGINT          NULL,
    [Order Base Price]                   DECIMAL (6, 2)  NULL,  -- MONEY
    [Order FOB Price]                    DECIMAL (6, 2)  NULL   -- MONEY
)


GO
CREATE STATISTICS Stat_FactOpenOrdersPriceAudit_Taken_Date ON AFISales_DW.FactOpenOrdersPriceAudit([Order Taken Date]);
GO

CREATE STATISTICS Stat_FactOpenOrdersPriceAudit_Account_And_Shipto_Number ON AFISales_DW.FactOpenOrdersPriceAudit([Account And Shipto Number]);
GO

CREATE STATISTICS Stat_FactOpenOrdersPriceAudit_item_Key ON AFISales_DW.FactOpenOrdersPriceAudit([Item Key]);

GO
CREATE STATISTICS Stat_FactOpenOrdersPriceAudit_Warehouse ON AFISales_DW.FactOpenOrdersPriceAudit([Warehouse]);


GO
CREATE STATISTICS [Stat_FactOpenOrdersPriceAudit_Item_Sequence_Number]
    ON [AFISales_DW].[FactOpenOrdersPriceAudit]([Item Sequence Number]);
