CREATE TABLE [AFISales_DW].[FactShippedHistory_Type2]
    (
        [RowID]                              BIGINT         NOT NULL, --IDENTITY (1, 1)
        [Invoice Date]                       DATE           NULL,
        [Invoice Number]                     DECIMAL(9)     NOT NULL,
        [Invoice Sequence]                   VARCHAR(7)     NOT NULL,
        [Account And Shipto Number]          CHAR(13)       NULL,
        [Territory]                          CHAR(10)       NULL,
        [SalesTerritoryID]                   BIGINT         NULL,
        [Item SKU]                           VARCHAR(15)    NOT NULL,
        [item Key]                           VARCHAR(22)    NOT NULL,
        [Store Address ID]                   INT            NULL,
        [Shipto AddressID]                   INT            NULL,
        [Warehouse]                          CHAR(3)        NULL,
        [Item Status]                        CHAR(1)        NULL,
        [Order Item Status]                  CHAR(1)        NULL,
        [Quantity Shipped]                   DECIMAL(7, 3)  NULL,
        [Invoice Discount]                   DECIMAL(11, 3) NULL,
        [Amount Shipped]                     DECIMAL(11, 3) NULL,
        [Other Allowances]                   DECIMAL(11, 3) NULL,
        [Allocated Freight]                  DECIMAL(11, 3) NULL,
        [Invoiced Line Item Freight]         DECIMAL(11, 3) NULL,
        [Other Freight]                      DECIMAL(11, 3) NULL,
        [Cubes]                              DECIMAL(10, 3) NULL,
        [Seats]                              DECIMAL(9, 3)  NULL,
        [Advertising Accrual]                DECIMAL(11, 3) NULL,
        [Invoice DFI Discount]               DECIMAL(11, 3) NULL,
        [Contract Price Amount]              DECIMAL(11, 3) NULL,
        [Bonded Warehouse Transfer Quantity] DECIMAL(7, 3)  NULL,
        [Bonded Warehouse Transfer Amount]   DECIMAL(11, 3) NULL,
        [Order Number]                       VARCHAR(10)    NOT NULL,
        [Trip Number]                        DECIMAL(7)     NOT NULL,
        [Purchase Order]                     VARCHAR(25)    NULL,
        [Order Arrival Mode]                 VARCHAR(25)    NULL,
        [Primary Order Type]                 VARCHAR(30)    NULL,
        [Secondary Order Type]               VARCHAR(30)    NULL,
        [Order Arrival Group]                VARCHAR(25)    NULL,
        [Order Arrival Electronic]           BIT            NULL,
        [3rd Order Type]                     VARCHAR(30)    NULL,
        [4th Order Type]                     VARCHAR(30)    NULL,
        [Invoice Credit Code]                CHAR(1)        NULL,
        [Order Sequence]                     VARCHAR(11)    NULL,
        [Request Date]                       DATE           NULL,
        [Promise Date]                       DATE           NULL,
        [Delivery Date]                      DATE           NULL,
        [Order Date]                         DATE           NULL,
        [Delivery Days - Promised]           INT            NULL,
        [Speed To Market Base]               INT            NULL,
        [Speed to Market]                    INT            NULL,
        [Delivery Days]                      INT            NULL,
        [Stm Base Calc]                      DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [Stm Count]                          DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [Early]                              DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [On Time]                            DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [1 Day Late]                         DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [2 Days Late]                        DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [3 Days Late]                        DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [4 Days Late]                        DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [5 Days Late]                        DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [6 Days Late]                        DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [7 Days Late]                        DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [8 to 14 Days Late]                  DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [15 to 21 Days Late]                 DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [22 to 28 Days Late]                 DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [Over 28 Days Late]                  DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [Early - Promised]                   DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [On Time - Promised]                 DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [1 Day Late - Promised]              DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [2 Days Late - Promised]             DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [3 Days Late - Promised]             DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [4 Days Late - Promised]             DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [5 Days Late - Promised]             DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [6 Days Late - Promised]             DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [7 Days Late - Promised]             DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [8 to 14 Days Late - Promised]       DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [15 to 21 Days Late - Promised]      DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [22 to 28 Days Late - Promised]      DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [Over 28 Days Late - Promised]       DECIMAL(13, 3) NULL,     -- FLOAT (53)
        [AFI Sales Category]                 CHAR(3)        NULL,
        [Division Code]                      CHAR(1)        NULL,
        [Sales Region Code]                  CHAR(3)        NULL,
        [Sales Repid]                        CHAR(5)        NULL,
        [Marketing Specialist ID]            CHAR(5)        NULL,
        [RegionCode_RepID_Category]          VARCHAR(13)    NULL,
        [Account Number]                     CHAR(8)        NULL,
        [Shipto Number]                      CHAR(4)        NULL,
        [Customer Shipto Division Number]    VARCHAR(15)    NULL,
        [TruckLoad Trip Type]                CHAR(1)        NULL
    );



GO
CREATE STATISTICS [Stat_FactShippedHistory_Type2_Territory]
    ON [AFISales_DW].[FactShippedHistory_Type2]
    (
        [Territory]
    );


GO
CREATE STATISTICS [Stat_FactShippedHistory_Type2_Item_SKU]
    ON [AFISales_DW].[FactShippedHistory_Type2]
    (
        [Item SKU]
    );


GO
CREATE STATISTICS [Stat_FactShippedHistory_Type2_Invoice_Sequence]
    ON [AFISales_DW].[FactShippedHistory_Type2]
    (
        [Invoice Sequence]
    );


GO
CREATE STATISTICS [Stat_FactShippedHistory_Type2_Invoice_Number]
    ON [AFISales_DW].[FactShippedHistory_Type2]
    (
        [Invoice Number]
    );


GO
CREATE STATISTICS [Stat_FactShippedHistory_Type2_Invoice_Date]
    ON [AFISales_DW].[FactShippedHistory_Type2]
    (
        [Invoice Date]
    );


GO
CREATE STATISTICS [Stat_FactShippedHistory_Type2_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactShippedHistory_Type2]
    (
        [Account And Shipto Number]
    );

