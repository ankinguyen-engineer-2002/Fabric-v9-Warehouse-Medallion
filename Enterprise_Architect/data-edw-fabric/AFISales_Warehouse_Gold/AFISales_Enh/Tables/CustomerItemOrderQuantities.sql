
CREATE TABLE [AFISales_Enh].[CustomerItemOrderQuantities] (
    [Item Sku]                  VARCHAR (15)   NOT NULL,
    [Order Number]              VARCHAR (10)   NULL,
    [Warehouse]                 CHAR (3)       NOT NULL,
    [Account And Shipto Number] VARCHAR (13)   NULL,
    [Customer Account Number]   CHAR (8)       NULL,
    [Customer Name]             VARCHAR (25)   NULL,
    [Order Type]                VARCHAR (30)   NULL,
    [Country]                   VARCHAR (30)   NULL,
    [Country Code]              VARCHAR (3)    NULL,
    [State]                     VARCHAR (25)   NULL,
    [State Code]                CHAR (2)       NULL,
    [ZipCode]                   VARCHAR (10)   NULL,
    [Quantity Type]             VARCHAR (64)   NULL,
    [Quantity]                  DECIMAL (38)   NULL,
    [Date Type]                 VARCHAR (64)   NULL,
    [Date]                      DATE           NULL,
    [Shipto Address ID]         INT            NULL,
    [Item Key]                  VARCHAR (22)   NOT NULL,
    [SalesTerritoryID]          BIGINT         NULL,
    [Item Sequence Number]      DECIMAL (7)    NULL
)


GO
CREATE STATISTICS [stat_CustomerItemOrderQuantities_UID]
    ON [AFISales_Enh].[CustomerItemOrderQuantities]([Item Sku]);


GO
CREATE STATISTICS [stat_CustomerItemOrderQuantities_SurveyEmployeeNumber]
    ON [AFISales_Enh].[CustomerItemOrderQuantities]([Order Number]);


GO
CREATE STATISTICS [stat_CustomerItemOrderQuantities_msfp_questionresponseid]
    ON [AFISales_Enh].[CustomerItemOrderQuantities]([Date]);

