CREATE TABLE [AFISales_DW].[FactQualityCosts] (
    [RowID]                           BIGINT         NOT NULL, -- IDENTITY (1, 1) 
    [Part Number]                     VARCHAR (15)   NULL,
    [Defect Type]                     VARCHAR (10)   NULL,
    [Purchase Order]                  VARCHAR (25)   NULL,
    [Invoice Number]                  DECIMAL (9)    NOT NULL,
    [Order Number]                    VARCHAR (10)   NULL,
    [Item Sequence Number]            VARCHAR (7)    NULL,
    [Item SKU]                        VARCHAR (15)   NULL,
    [Item Key]                        VARCHAR (22)   NULL,
    [Defect Code]                     CHAR (3)       NOT NULL,
    [Location Code]                   CHAR (3)       NOT NULL,
    [Credit Code]                     CHAR (4)       NULL,
    [Quality Code]                    CHAR (4)       NULL,
    [Damage Type]                     VARCHAR (25)   NOT NULL,
    [Damaged Location]                VARCHAR (20)   NOT NULL,
    [Percent Allowed]                 INT            NOT NULL,
    [Serial Number]                   VARCHAR (15)   NULL,
    [Trip Number]                     INT            NULL,
    [Drop Number]                     INT            NULL,
    [Original Invoice]                DECIMAL (9)    NULL,
    [Original Order]                  VARCHAR (10)   NULL,
    [Order Date]                      DATE           NULL,
    [Order Mode]                      CHAR (2)       NULL,
    [Add User]                        VARCHAR (10)   NULL,
    [Carrier]                         VARCHAR (25)   NULL,
    [Truck Number]                    VARCHAR (15)   NULL,
    [Delivery Date]                   DATE           NULL,
    [Scan Name]                       VARCHAR (10)   NULL,
    [Load Date]                       DATE           NULL,
    [Order Type]                      CHAR (1)       NULL,
    [Transaction Date]                DATE           NULL,
    [Vendor Number]                   CHAR (8)       NULL,
    [Where Made]                      VARCHAR (15)   NULL,
    [Manufacture Date]                DATE           NULL,
    [User Group]                      VARCHAR (12)   NULL,
    [Sales Number]                    VARCHAR (5)    NOT NULL,
    [Item Type]                       CHAR (2)       NOT NULL,
    [Scrap Code]                      CHAR (4)       NULL,
    [Quality Category]                VARCHAR (20)   NULL,
    [SalesTerritoryID]                BIGINT         NULL,
    [Account And Shipto Number]       CHAR (13)      NULL,
    [Territory]                       CHAR (10)      NULL,
    [Item Status]                     CHAR (1)       NULL,
    [Warehouse Code]                  CHAR (3)       NULL,
    [Shipto AddressID]                INT            NULL,
    [Replacement Part Orders]         DECIMAL (7, 3) NULL,
    [Replacement Part Quantity]       DECIMAL (7, 3) NULL,
    [Replacement Part Cost]           DECIMAL (9, 3) NULL,
    [Total Quality Quantity]          DECIMAL (7, 3) NULL,
    [Quality Credit Quantity]         DECIMAL (9, 3) NULL,
    [Quality Credits]                 DECIMAL (9, 3) NULL,
    [Replacement Part Incidents]      DECIMAL (7, 3) NULL,
    [Return Quantity]                 DECIMAL (9, 3) NULL,
    [Short Ship Quantity]             DECIMAL (7, 3) NULL,
    [Returns Amount]                  DECIMAL (9, 3) NULL,
    [Short Ship Amount]               DECIMAL (9, 3) NULL,
    [Total Quality Costs]             DECIMAL (9, 3) NULL,
    [Customer Shipto Division Number] VARCHAR (15)   NULL
)

GO
CREATE STATISTICS [Stat_FactQualityCosts_Warehouse_Code]
    ON [AFISales_DW].[FactQualityCosts]([Warehouse Code]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Transaction_date]
    ON [AFISales_DW].[FactQualityCosts]([Transaction Date]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Territory]
    ON [AFISales_DW].[FactQualityCosts]([Territory]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Shipto_AddressID]
    ON [AFISales_DW].[FactQualityCosts]([Shipto AddressID]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_SalesTerritoryID]
    ON [AFISales_DW].[FactQualityCosts]([SalesTerritoryID]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Quality_Category]
    ON [AFISales_DW].[FactQualityCosts]([Quality Category]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Item_SKU]
    ON [AFISales_DW].[FactQualityCosts]([Item SKU]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactQualityCosts]([Account And Shipto Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Where_Made]
    ON [AFISales_DW].[FactQualityCosts]([Where Made]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Vendor_Number]
    ON [AFISales_DW].[FactQualityCosts]([Vendor Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_User_Group]
    ON [AFISales_DW].[FactQualityCosts]([User Group]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Type2_Serial_Number]
    ON [AFISales_DW].[FactQualityCosts]([Serial Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Type2_RowID]
    ON [AFISales_DW].[FactQualityCosts]([RowID]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Truck_Number]
    ON [AFISales_DW].[FactQualityCosts]([Truck Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Trip_Number]
    ON [AFISales_DW].[FactQualityCosts]([Trip Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Short_Ship_Quantity]
    ON [AFISales_DW].[FactQualityCosts]([Short Ship Quantity]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Short_Ship_Amount]
    ON [AFISales_DW].[FactQualityCosts]([Short Ship Amount]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Serial_Number]
    ON [AFISales_DW].[FactQualityCosts]([Serial Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Scrap_Code]
    ON [AFISales_DW].[FactQualityCosts]([Scrap Code]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Scan_Name]
    ON [AFISales_DW].[FactQualityCosts]([Scan Name]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Sales_Number]
    ON [AFISales_DW].[FactQualityCosts]([Sales Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_RowID]
    ON [AFISales_DW].[FactQualityCosts]([RowID]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Returns_Amount]
    ON [AFISales_DW].[FactQualityCosts]([Returns Amount]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Return_Quantity]
    ON [AFISales_DW].[FactQualityCosts]([Return Quantity]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Quality_Credits]
    ON [AFISales_DW].[FactQualityCosts]([Quality Credits]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Quality_Code]
    ON [AFISales_DW].[FactQualityCosts]([Quality Code]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Purchase_Order]
    ON [AFISales_DW].[FactQualityCosts]([Purchase Order]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Percent_Allowed]
    ON [AFISales_DW].[FactQualityCosts]([Percent Allowed]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Part_Number]
    ON [AFISales_DW].[FactQualityCosts]([Part Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Original_Order]
    ON [AFISales_DW].[FactQualityCosts]([Original Order]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Original_Invoice]
    ON [AFISales_DW].[FactQualityCosts]([Original Invoice]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Order_Type]
    ON [AFISales_DW].[FactQualityCosts]([Order Type]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Order_Number]
    ON [AFISales_DW].[FactQualityCosts]([Order Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Order_Mode]
    ON [AFISales_DW].[FactQualityCosts]([Order Mode]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Order_Date]
    ON [AFISales_DW].[FactQualityCosts]([Order Date]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Manufacture_Date]
    ON [AFISales_DW].[FactQualityCosts]([Manufacture Date]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Location_Code]
    ON [AFISales_DW].[FactQualityCosts]([Location Code]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Load_Date]
    ON [AFISales_DW].[FactQualityCosts]([Load Date]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Item_Type]
    ON [AFISales_DW].[FactQualityCosts]([Item Type]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Item_Status]
    ON [AFISales_DW].[FactQualityCosts]([Item Status]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Item_Sequence_Number]
    ON [AFISales_DW].[FactQualityCosts]([Item Sequence Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Invoice_Number]
    ON [AFISales_DW].[FactQualityCosts]([Invoice Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Drop_Number]
    ON [AFISales_DW].[FactQualityCosts]([Drop Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Delivery_Date]
    ON [AFISales_DW].[FactQualityCosts]([Delivery Date]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Defect_Type]
    ON [AFISales_DW].[FactQualityCosts]([Defect Type]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Defect_Code]
    ON [AFISales_DW].[FactQualityCosts]([Defect Code]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Damaged_Location]
    ON [AFISales_DW].[FactQualityCosts]([Damaged Location]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Damage_Type]
    ON [AFISales_DW].[FactQualityCosts]([Damage Type]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Customer_Shipto_Division_Number]
    ON [AFISales_DW].[FactQualityCosts]([Customer Shipto Division Number]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Credit_Code]
    ON [AFISales_DW].[FactQualityCosts]([Credit Code]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Carrier]
    ON [AFISales_DW].[FactQualityCosts]([Carrier]);


GO
CREATE STATISTICS [Stat_FactQualityCosts_Add_User]
    ON [AFISales_DW].[FactQualityCosts]([Add User]);

