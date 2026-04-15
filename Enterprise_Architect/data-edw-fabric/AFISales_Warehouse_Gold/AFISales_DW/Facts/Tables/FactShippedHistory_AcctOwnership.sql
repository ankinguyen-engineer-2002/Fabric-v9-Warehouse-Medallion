CREATE TABLE [AFISales_DW].[FactShippedHistory_AcctOwnership] (
    [RowID]                              BIGINT          NOT NULL, --IDENTITY (1, 1) 
    [Invoice Date]                       DATE            NULL,
    [Invoice Number]                     DECIMAL (9)     NOT NULL,
    [Invoice Sequence]                   VARCHAR (7)     NOT NULL,
    [Account And Shipto Number]          CHAR (13)       NULL,
    [Territory]                          CHAR (10)       NULL,
    [SalesTerritoryID]                   BIGINT          NULL,
    [Item SKU]                           VARCHAR (15)    NOT NULL,
    [item Key]                           VARCHAR (22)    NOT NULL,
    [Store Address ID]                   INT             NULL,
    [Shipto AddressID]                   INT             NULL,
    [Warehouse]                          CHAR (3)        NULL,
    [Item Status]                        CHAR (1)        NULL,
    [Order Item Status]                  CHAR (1)        NULL,
    [Quantity Shipped]                   DECIMAL (7, 3)  NULL,
    [Invoice Discount]                   DECIMAL (11, 3) NULL,
    [Amount Shipped]                     DECIMAL (11, 3) NULL,
    [Other Allowances]                   DECIMAL (11, 3) NULL,
    [Allocated Freight]                  DECIMAL (11, 3) NULL,
    [Invoiced Line Item Freight]         DECIMAL (11, 3) NULL,
    [Other Freight]                      DECIMAL (11, 3) NULL,
    [Cubes]                              DECIMAL (9, 3)  NULL,
    [Seats]                              DECIMAL (9, 3)  NULL,
    [Advertising Accrual]                DECIMAL (11, 3) NULL,
    [Invoice DFI Discount]               DECIMAL (11, 3) NULL,
    [Contract Price Amount]              DECIMAL (11, 3) NULL,
    [Bonded Warehouse Transfer Quantity] DECIMAL (7, 3)  NULL,
    [Bonded Warehouse Transfer Amount]   DECIMAL (11, 3) NULL,
    [Order Number]                       VARCHAR (10)    NOT NULL,
    [Trip Number]                        DECIMAL (7)     NOT NULL,
    [Purchase Order]                     VARCHAR (25)    NULL,
    [Order Arrival Mode]                 VARCHAR (25)    NULL,
    [Primary Order Type]                 VARCHAR (30)    NULL,
    [Secondary Order Type]               VARCHAR (30)    NULL,
    [Order Arrival Group]                VARCHAR (25)    NULL,
    [Order Arrival Electronic]           BIT             NULL,
    [3rd Order Type]                     VARCHAR (30)    NULL,
    [4th Order Type]                     VARCHAR (30)    NULL,
    [Invoice Credit Code]                CHAR (1)        NULL,
    [Order Sequence]                     VARCHAR (11)    NULL,
    [Request Date]                       DATE            NULL,
    [Promise Date]                       DATE            NULL,
    [Delivery Date]                      DATE            NULL,
    [Order Date]                         DATE            NULL,
    [Delivery Days - Promised]           INT             NULL,
    [Speed To Market Base]               INT             NULL,
    [Speed to Market]                    INT             NULL,
    [Delivery Days]                      INT             NULL,
    [Stm Base Calc]                      DECIMAL (13,3)  NULL, -- FLOAT (53)
    [Stm Count]                          DECIMAL (13,3)  NULL, -- FLOAT (53)
    [Early]                              DECIMAL (13,3)  NULL, -- FLOAT (53)
    [On Time]                            DECIMAL (13,3)  NULL, -- FLOAT (53)
    [1 Day Late]                         DECIMAL (13,3)  NULL, -- FLOAT (53)
    [2 Days Late]                        DECIMAL (13,3)  NULL, -- FLOAT (53)
    [3 Days Late]                        DECIMAL (13,3)  NULL, -- FLOAT (53)
    [4 Days Late]                        DECIMAL (13,3)  NULL, -- FLOAT (53)
    [5 Days Late]                        DECIMAL (13,3)  NULL, -- FLOAT (53)
    [6 Days Late]                        DECIMAL (13,3)  NULL, -- FLOAT (53)
    [7 Days Late]                        DECIMAL (13,3)  NULL, -- FLOAT (53)
    [8 to 14 Days Late]                  DECIMAL (13,3)  NULL, -- FLOAT (53)
    [15 to 21 Days Late]                 DECIMAL (13,3)  NULL, -- FLOAT (53)
    [22 to 28 Days Late]                 DECIMAL (13,3)  NULL, -- FLOAT (53)
    [Over 28 Days Late]                  DECIMAL (13,3)  NULL, -- FLOAT (53)
    [Early - Promised]                   DECIMAL (13,3)  NULL, -- FLOAT (53)
    [On Time - Promised]                 DECIMAL (13,3)  NULL, -- FLOAT (53)
    [1 Day Late - Promised]              DECIMAL (13,3)  NULL, -- FLOAT (53)
    [2 Days Late - Promised]             DECIMAL (13,3)  NULL, -- FLOAT (53)
    [3 Days Late - Promised]             DECIMAL (13,3)  NULL, -- FLOAT (53)
    [4 Days Late - Promised]             DECIMAL (13,3)  NULL, -- FLOAT (53)
    [5 Days Late - Promised]             DECIMAL (13,3)  NULL, -- FLOAT (53)
    [6 Days Late - Promised]             DECIMAL (13,3)  NULL, -- FLOAT (53)
    [7 Days Late - Promised]             DECIMAL (13,3)  NULL, -- FLOAT (53)
    [8 to 14 Days Late - Promised]       DECIMAL (13,3)  NULL, -- FLOAT (53)
    [15 to 21 Days Late - Promised]      DECIMAL (13,3)  NULL, -- FLOAT (53)
    [22 to 28 Days Late - Promised]      DECIMAL (13,3)  NULL, -- FLOAT (53)
    [Over 28 Days Late - Promised]       DECIMAL (13,3)  NULL, -- FLOAT (53)
    [AFI Sales Category]                 CHAR (3)        NULL,
    [Division Code]                      CHAR (1)        NULL,
    [Sales Region Code]                  CHAR (3)        NULL,
    [Sales Repid]                        CHAR (5)        NULL,
    [Marketing Specialist ID]            CHAR (5)        NULL,
    [RegionCode_RepID_Category]          VARCHAR (13)    NULL,
    [Account Number]                     CHAR (8)        NOT NULL,
    [Shipto Number]                      CHAR (4)        NOT NULL,
    [Customer Shipto Division Number]    VARCHAR (15)    NULL,
    [TruckLoad Trip Type]                CHAR (1)        NULL,
    [Customer SKU/Package]               VARCHAR (30)    NULL

)

GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Warehouse]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Warehouse]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Type2_Warehouse]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Warehouse]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Type2_TruckLoad_Trip_Type]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([TruckLoad Trip Type]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Type2_Shipto_AddressID]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Shipto AddressID]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Type2_Secondary_Order_Type]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Secondary Order Type]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Type2_RowID]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([RowID]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Type2_Request_Date]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Request Date]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Type2_Quantity_Shipped]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Quantity Shipped]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Type2_Order_Number]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Order Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Type2_Amount_Shipped]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Amount Shipped]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Type2_Account_Number]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Account Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_TruckLoad_Trip_Type]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([TruckLoad Trip Type]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Trip_Number]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Trip Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Territory]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Territory]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Shipto_Number]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Shipto Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Shipto_AddressID]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Shipto AddressID]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Secondary_Order_Type]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Secondary Order Type]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_SalesTerritoryID]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([SalesTerritoryID]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Request_Date]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Request Date]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Quantity_Shipped]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Quantity Shipped]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Purchase_Order]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Purchase Order]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Promise_Date]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Promise Date]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Primary_Order_Type]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Primary Order Type]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Other_Freight]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Other Freight]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Other_Allowances]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Other Allowances]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Order_Sequence]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Order Sequence]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Order_Number]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Order Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Order_Item_Status]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Order Item Status]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Order_Date]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Order Date]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Order_Arrival_Mode]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Order Arrival Mode]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Order_Arrival_Group]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Order Arrival Group]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Order_Arrival_Electronic]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Order Arrival Electronic]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Item_Status]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Item Status]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Item_SKU]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Item SKU]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Item_Key]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([item Key]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Invoiced_Line_Item_Freight]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Invoiced Line Item Freight]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Invoice_Sequence]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Invoice Sequence]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Invoice_Number]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Invoice Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Invoice_Discount]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Invoice Discount]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Invoice_DFI_Discount]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Invoice DFI Discount]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Invoice_Date]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Invoice Date]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Invoice_Credit_Code]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Invoice Credit Code]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Delivery_Date]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Delivery Date]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Customer_Shipto_Division_Number]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Customer Shipto Division Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Cubes]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Cubes]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Contract_Price_Amount]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Contract Price Amount]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Amount_Shipped]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Amount Shipped]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Allocated_Freight]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Allocated Freight]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Account_Number]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Account Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([Account And Shipto Number]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_4th_Order_Type]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([4th Order Type]);


GO
CREATE STATISTICS [Stat_FactShippedHistory_AcctOwnership_3rd_Order_Type]
    ON [AFISales_DW].[FactShippedHistory_AcctOwnership]([3rd Order Type]);

