CREATE TABLE [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [RowID]                           [BIGINT]        NOT NULL, --IDENTITY(1, 1) 
        [Part Number]                     [VARCHAR](15)   NULL,
        [Defect Type]                     [VARCHAR](10)   NULL,
        [Purchase Order]                  [VARCHAR](25)   NULL,
        [Invoice Number]                  [DECIMAL](9, 0) NOT NULL,
        [Order Number]                    [VARCHAR](10)   NULL,
        [Item Sequence Number]            [VARCHAR](7)    NULL,
        [Item SKU]                        [VARCHAR](15)   NULL,
        [Item Key]                        [VARCHAR](22)   NULL,
        [Defect Code]                     [CHAR](3)       NOT NULL,
        [Location Code]                   [CHAR](3)       NOT NULL,
        [Credit Code]                     [CHAR](4)       NULL,
        [Quality Code]                    [CHAR](4)       NULL,
        [Damage Type]                     [VARCHAR](25)   NOT NULL,
        [Damaged Location]                [VARCHAR](20)   NOT NULL,
        [Percent Allowed]                 [INT]           NOT NULL,
        [Serial Number]                   [VARCHAR](15)   NULL,
        [Trip Number]                     [INT]           NULL,
        [Drop Number]                     [INT]           NULL,
        [Original Invoice]                [DECIMAL](9, 0) NULL,
        [Original Order]                  [VARCHAR](10)   NULL,
        [Order Date]                      [DATE]          NULL,
        [Order Mode]                      [CHAR](2)       NULL,
        [Add User]                        [VARCHAR](10)   NULL,
        [Carrier]                         [VARCHAR](25)   NULL,
        [Truck Number]                    [VARCHAR](15)   NULL,
        [Delivery Date]                   [DATE]          NULL,
        [Scan Name]                       [VARCHAR](10)   NULL,
        [Load Date]                       [DATE]          NULL,
        [Order Type]                      [CHAR](1)       NULL,
        [Transaction Date]                [DATE]          NULL,
        [Vendor Number]                   [CHAR](8)       NULL,
        [Where Made]                      [VARCHAR](15)   NULL,
        [Manufacture Date]                [DATE]          NULL,
        [User Group]                      [VARCHAR](12)   NULL,
        [Sales Number]                    [VARCHAR](5)    NOT NULL,
        [Item Type]                       [CHAR](2)       NOT NULL,
        [Scrap Code]                      [CHAR](4)       NULL,
        [Quality Category]                [VARCHAR](20)   NULL,
        [SalesTerritoryID]                [BIGINT]        NULL,
        [Account And Shipto Number]       [CHAR](13)      NULL,
        [Territory]                       [CHAR](10)      NULL,
        [Item Status]                     [CHAR](1)       NULL,
        [Warehouse Code]                  [CHAR](3)       NULL,
        [Shipto AddressID]                [INT]           NULL,
        [Replacement Part Orders]         [DECIMAL](7, 3) NULL,
        [Replacement Part Quantity]       [DECIMAL](7, 3) NULL,
        [Replacement Part Cost]           [DECIMAL](9, 3) NULL,
        [Total Quality Quantity]          [DECIMAL](7, 3) NULL,
        [Quality Credit Quantity]         [DECIMAL](9, 3) NULL,
        [Quality Credits]                 [DECIMAL](9, 3) NULL,
        [Replacement Part Incidents]      [DECIMAL](7, 3) NULL,
        [Return Quantity]                 [DECIMAL](9, 3) NULL,
        [Short Ship Quantity]             [DECIMAL](7, 3) NULL,
        [Returns Amount]                  [DECIMAL](9, 3) NULL,
        [Short Ship Amount]               [DECIMAL](9, 3) NULL,
        [Total Quality Costs]             [DECIMAL](9, 3) NULL,
        [Customer Shipto Division Number] [VARCHAR](15)   NULL
    );

GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Where_Made]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Where Made]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Warehouse_Code]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Warehouse Code]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Vendor_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Vendor Number]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_User_Group]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [User Group]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Type2_Serial_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Serial Number]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Type2_RowID]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [RowID]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Truck_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Truck Number]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Trip_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Trip Number]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Transaction_date]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Transaction Date]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Territory]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Territory]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Short_Ship_Quantity]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Short Ship Quantity]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Short_Ship_Amount]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Short Ship Amount]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Shipto_AddressID]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Shipto AddressID]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Serial_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Serial Number]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Scrap_Code]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Scrap Code]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Scan_Name]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Scan Name]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_SalesTerritoryID]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [SalesTerritoryID]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Sales_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Sales Number]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_RowID]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [RowID]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Returns_Amount]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Returns Amount]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Return_Quantity]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Return Quantity]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Quality_Credits]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Quality Credits]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Quality_Code]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Quality Code]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Quality_Category]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Quality Category]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Purchase_Order]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Purchase Order]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Percent_Allowed]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Percent Allowed]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Part_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Part Number]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Original_Order]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Original Order]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Original_Invoice]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Original Invoice]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Order_Type]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Order Type]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Order_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Order Number]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Order_Mode]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Order Mode]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Order_Date]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Order Date]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Manufacture_Date]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Manufacture Date]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Location_Code]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Location Code]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Load_Date]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Load Date]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Item_Type]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Item Type]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Item_Status]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Item Status]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Item_SKU]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Item SKU]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Item_Sequence_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Item Sequence Number]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Invoice_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Invoice Number]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Drop_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Drop Number]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Delivery_Date]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Delivery Date]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Defect_Type]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Defect Type]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Defect_Code]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Defect Code]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Damaged_Location]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Damaged Location]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Damage_Type]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Damage Type]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Customer_Shipto_Division_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Customer Shipto Division Number]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Credit_Code]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Credit Code]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Carrier]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Carrier]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Add_User]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Add User]
    );


GO
CREATE STATISTICS [Stat_FactQualityCosts_AcctOwnership_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactQualityCosts_AcctOwnership]
    (
        [Account And Shipto Number]
    );

