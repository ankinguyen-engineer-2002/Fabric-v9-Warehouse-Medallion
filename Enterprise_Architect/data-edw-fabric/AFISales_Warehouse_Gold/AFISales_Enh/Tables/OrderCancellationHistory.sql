CREATE TABLE [AFISales_Enh].[OrderCancellationHistory]
    (
        [Order Taken Date]           DATE           NULL,
        [Order Number]               VARCHAR(10)    NULL,
        [Account And Shipto Number]  VARCHAR(13)    NULL,
        [Customer Account Number]    CHAR(8)        NULL,
        [Customer Shipto Number]     CHAR(4)        NULL,
        [Item SKU]                   VARCHAR(15)    NOT NULL,
        [Item Sequence Number]       DECIMAL(7)     NULL,
        [Warehouse]                  CHAR(3)        NOT NULL,
        [Open Order Quantity]        DECIMAL(10, 3) NULL,
        [Back Order Quantity]        DECIMAL(10, 3) NULL,
        [Cancelled Quantity]         INT            NULL,
        [Open Order Amount]          DECIMAL(10, 2) NULL, --- Money
        [Back Order Amount]          DECIMAL(10, 2) NULL, --- Money
        [Cancelled Amount]           DECIMAL(10, 2) NULL, --- Money
        [OrigReqWkEnded]             DATE           NULL,
        [Original Promise Date]      DATE           NULL,
        [Current Promise Date]       DATE           NULL,
        [Original Request Date]      DATE           NULL,
        [Current Request Date]       DATE           NULL,
        [Cancel Reason Code]         CHAR(2)        NULL,
        [Cancel Reason Description]  VARCHAR(25)    NULL,
        [Primary Order Type]         VARCHAR(30)    NULL,
        [Secondary Order Type]       VARCHAR(30)    NULL,
        [3rd Order Type]             VARCHAR(30)    NULL,
        [4th Order Type]             VARCHAR(30)    NULL,
        [Inserted Date]              DATETIME2(6)   NULL,
        [Inventory Allocated Flag]   DECIMAL(1)     NULL,
        [Current Load Date]          DATE           NULL,
        [Count of Load Date Changes] DECIMAL(3)     NULL,
        [Load Lead Time]             DECIMAL(2)     NULL,
        [Change Date]                DATE           NULL
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Change_Date]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Change Date]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Warehouse]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Warehouse]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Original_Request_Date]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Original Request Date]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Original_Promise_Date]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Original Promise Date]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Order_Taken_Date]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Order Taken Date]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Order_Number]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Order Number]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Open_Order_Quantity]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Open Order Quantity]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Open_Order_Amount]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Open Order Amount]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Item_SKU]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Item SKU]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Item_Sequence_Number]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Item Sequence Number]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Customer_Shipto_Number]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Customer Shipto Number]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Customer_Account_Number]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Customer Account Number]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Current_Request_Date]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Current Request Date]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Current_Promise_Date]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Current Promise Date]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Cancelled_Quantity]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Cancelled Quantity]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Cancelled_Amount]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Cancelled Amount]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Cancel_Reason_Description]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Cancel Reason Description]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Cancel_Reason_Code]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Cancel Reason Code]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_Account_And_Shipto_Number]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [Account And Shipto Number]
    );


GO
CREATE STATISTICS [Stat_OrderCancellationHistory_3rd_Order_Type]
    ON [AFISales_Enh].[OrderCancellationHistory]
    (
        [3rd Order Type]
    );

