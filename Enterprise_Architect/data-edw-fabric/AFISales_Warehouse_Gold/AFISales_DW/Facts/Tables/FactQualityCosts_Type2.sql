CREATE TABLE [AFISales_DW].[FactQualityCosts_Type2] (
    [RowID]                      BIGINT         NOT NULL, --IDENTITY (1, 1)
    [Part Number]                VARCHAR (15)   NULL,
    [Defect Type]                VARCHAR (10)   NULL,
    [Purchase Order]             VARCHAR (25)   NULL,
    [Invoice Number]             DECIMAL (9)    NOT NULL,
    [Order Number]               VARCHAR (10)   NULL,
    [Item Sequence Number]       VARCHAR (7)    NULL,
    [Item SKU]                   VARCHAR (15)   NULL,
    [Item Key]                   VARCHAR (22)   NULL,
    [Defect Code]                CHAR (3)       NOT NULL,
    [Location Code]              CHAR (3)       NOT NULL,
    [Credit Code]                CHAR (4)       NULL,
    [Quality Code]               CHAR (4)       NULL,
    [Damage Type]                VARCHAR (25)   NOT NULL,
    [Damaged Location]           VARCHAR (20)   NOT NULL,
    [Percent Allowed]            INT            NOT NULL,
    [Serial Number]              VARCHAR (15)   NULL,
    [Trip Number]                INT            NULL,
    [Drop Number]                INT            NULL,
    [Original Invoice]           DECIMAL (9)    NULL,
    [Original Order]             VARCHAR (10)   NULL,
    [Order Date]                 DATE           NULL,
    [Order Mode]                 CHAR (2)       NULL,
    [Add User]                   VARCHAR (10)   NULL,
    [Carrier]                    VARCHAR (25)   NULL,
    [Truck Number]               VARCHAR (15)   NULL,
    [Delivery Date]              DATE           NULL,
    [Scan Name]                  VARCHAR (10)   NULL,
    [Load Date]                  DATE           NULL,
    [Order Type]                 CHAR (1)       NULL,
    [Transaction Date]           DATE           NULL,
    [Vendor Number]              CHAR (6)       NULL,
    [Where Made]                 VARCHAR (15)   NULL,
    [Manufacture Date]           DATE           NULL,
    [User Group]                 VARCHAR (12)   NULL,
    [Sales Number]               VARCHAR (5)    NOT NULL,
    [Item Type]                  CHAR (2)       NOT NULL,
    [Scrap Code]                 CHAR (4)       NULL,
    [Quality Category]           VARCHAR (20)   NULL,
    [SalesTerritoryID]           BIGINT         NULL,
    [Account And Shipto Number]  CHAR (13)      NULL,
    [Territory]                  CHAR (10)      NULL,
    [Item Status]                CHAR (1)       NULL,
    [Warehouse Code]             CHAR (3)       NULL,
    [Shipto AddressID]           INT            NULL,
    [Replacement Part Orders]    DECIMAL (7, 3) NULL,
    [Replacement Part Quantity]  DECIMAL (7, 3) NULL,
    [Replacement Part Cost]      DECIMAL (9, 3) NULL,
    [Total Quality Quantity]     DECIMAL (7, 3) NULL,
    [Quality Credit Quantity]    DECIMAL (9, 3) NULL,
    [Quality Credits]            DECIMAL (9, 3) NULL,
    [Replacement Part Incidents] DECIMAL (7, 3) NULL,
    [Return Quantity]            DECIMAL (9, 3) NULL,
    [Short Ship Quantity]        DECIMAL (7, 3) NULL,
    [Returns Amount]             DECIMAL (9, 3) NULL,
    [Short Ship Amount]          DECIMAL (9, 3) NULL,
    [Total Quality Costs]        DECIMAL (9, 3) NULL
)


GO
CREATE STATISTICS [Stat_FactQualityCosts_Type2_Transaction_Date]
    ON [AFISales_DW].[FactQualityCosts_Type2]([Transaction Date]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Type2_Territory]
    ON [AFISales_DW].[FactQualityCosts_Type2]([Territory]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Type2_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactQualityCosts_Type2]([Account And Shipto Number]);

