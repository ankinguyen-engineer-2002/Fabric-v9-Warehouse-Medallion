CREATE TABLE [AFISales_DW].[FactOrderMinimum] (
    [RowID]                     BIGINT       NOT NULL,  -- IDENTITY (1, 1) 
    [Invoice Date]              DATE         NOT NULL,
    [Account And Shipto Number] CHAR (13)    NULL,
    [Invoice Number]            DECIMAL (9)  NOT NULL,
    [Order Minimum $]           DECIMAL (10) NULL,
    [Order Minimum]             CHAR (1)     NOT NULL,
    [Order Minimum Met]         INT          NOT NULL,
    [OM Base Calc]              INT          NOT NULL,
    [Warehouse]                 CHAR (3)     NOT NULL,
    [Store Address ID]          INT          NULL,
    [Shipto AddressID]          INT          NULL,
    [Territory]                 CHAR (10)    NULL,
    [State]                     VARCHAR (16) NOT NULL
)

GO
CREATE STATISTICS [Stat_FactOrderMinimum_InvoiceDate]
    ON [AFISales_DW].[FactOrderMinimum]([Invoice Date]);

