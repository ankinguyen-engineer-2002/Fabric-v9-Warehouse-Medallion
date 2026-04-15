CREATE TABLE [Quality_DW].[DimInvoiceHeader]
    (
        [Invoice Date]             DATE        NULL,
        [Invoice Number]           DECIMAL(9)  NULL,
        [Order Number]             VARCHAR(10) NOT NULL,
        [Trip Number]              DECIMAL(7)  NOT NULL,
        [Purchase Order]           VARCHAR(25) NOT NULL,
        [Order Arrival Mode]       VARCHAR(25) NULL,
        [Primary Order Type]       VARCHAR(30) NULL,
        [Secondary Order Type]     VARCHAR(30) NULL,
        [Order Arrival Group]      VARCHAR(25) NULL,
        [Order Arrival Electronic] INT         NULL,
        [3rd Order Type]           VARCHAR(30) NULL,
        [4th Order Type]           VARCHAR(30) NULL,
        [Invoice Credit Code]      CHAR(1)     NULL
    );



GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Invoice_Date]
    ON [Quality_DW].[DimInvoiceHeader]
    (
        [Invoice Date]
    );


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Secondary_Order_Type]
    ON [Quality_DW].[DimInvoiceHeader]
    (
        [Secondary Order Type]
    );


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Primary_Order_Type]
    ON [Quality_DW].[DimInvoiceHeader]
    (
        [Primary Order Type]
    );


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Order_Number]
    ON [Quality_DW].[DimInvoiceHeader]
    (
        [Order Number]
    );


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_Order_Arrival_Group]
    ON [Quality_DW].[DimInvoiceHeader]
    (
        [Order Arrival Group]
    );


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_4th_Order_Type]
    ON [Quality_DW].[DimInvoiceHeader]
    (
        [4th Order Type]
    );


GO
CREATE STATISTICS [Stat_DimInvoiceHeader_3rd_Order_Type]
    ON [Quality_DW].[DimInvoiceHeader]
    (
        [3rd Order Type]
    );

