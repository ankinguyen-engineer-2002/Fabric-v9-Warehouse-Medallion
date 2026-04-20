CREATE TABLE [AFISales_DW].[DimInvoiceHeader] (
    [Invoice Date]             DATE         NULL,
    [Invoice Number]           DECIMAL (9)  NULL,
    [Order Number]             VARCHAR (10) NOT NULL,
    [Trip Number]              DECIMAL (7)  NOT NULL,
    [Purchase Order]           VARCHAR (25) NULL,
    [Order Arrival Mode]       VARCHAR (25) NULL,
    [Primary Order Type]       VARCHAR (30) NULL,
    [Secondary Order Type]     VARCHAR (30) NULL,
    [Order Arrival Group]      VARCHAR (25) NULL,
    [Order Arrival Electronic] INT          NULL,
    [3rd Order Type]           VARCHAR (30) NULL,
    [4th Order Type]           VARCHAR (30) NULL,
    [Invoice Credit Code]      CHAR (1)     NULL,
    [Order Sequence]           VARCHAR (11) NULL,
    [Request Date]             DATE         NULL,
    [Promise Date]             DATE         NULL,
    [Delivery Date]            DATE         NULL,
    [Original Invoice Number]  DECIMAL (9)  NULL,
    [Original Invoice Date]    DATE         NULL,
    [Original Order Number]    VARCHAR (10) NULL,
    [Original Order Date]      DATE         NULL,
    [Original Sequence Number] DECIMAL (7)  NULL,
    [Original Delivery Method] VARCHAR (30) NULL,
    [TruckLoad Trip Type]      CHAR (1)     NULL
)


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_TriprNumber]
    ON [AFISales_DW].[DimInvoiceHeader]([Trip Number]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_OrderNumber]
    ON [AFISales_DW].[DimInvoiceHeader]([Order Number]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_InvoiceNumber]
    ON [AFISales_DW].[DimInvoiceHeader]([Invoice Number]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_InvoiceDate]
    ON [AFISales_DW].[DimInvoiceHeader]([Invoice Date]);



GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Secondary_Order_Type]
    ON [AFISales_DW].[DimInvoiceHeader]([Secondary Order Type]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Request_Date]
    ON [AFISales_DW].[DimInvoiceHeader]([Request Date]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Purchase_Order]
    ON [AFISales_DW].[DimInvoiceHeader]([Purchase Order]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Promise_Date]
    ON [AFISales_DW].[DimInvoiceHeader]([Promise Date]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Primary_Order_Type]
    ON [AFISales_DW].[DimInvoiceHeader]([Primary Order Type]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Original_Invoice_Number]
    ON [AFISales_DW].[DimInvoiceHeader]([Original Invoice Number]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Original_Invoice_Date]
    ON [AFISales_DW].[DimInvoiceHeader]([Original Invoice Date]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Original_Delivery_Method]
    ON [AFISales_DW].[DimInvoiceHeader]([Original Delivery Method]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Order_Sequence]
    ON [AFISales_DW].[DimInvoiceHeader]([Order Sequence]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Order_Arrival_Mode]
    ON [AFISales_DW].[DimInvoiceHeader]([Order Arrival Mode]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Order_Arrival_Group]
    ON [AFISales_DW].[DimInvoiceHeader]([Order Arrival Group]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Order_Arrival_Electronic]
    ON [AFISales_DW].[DimInvoiceHeader]([Order Arrival Electronic]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Invoice_Credit_Code]
    ON [AFISales_DW].[DimInvoiceHeader]([Invoice Credit Code]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Delivery_Date]
    ON [AFISales_DW].[DimInvoiceHeader]([Delivery Date]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_4th_Order_Type]
    ON [AFISales_DW].[DimInvoiceHeader]([4th Order Type]);


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_3rd_Order_Type]
    ON [AFISales_DW].[DimInvoiceHeader]([3rd Order Type]);

