CREATE TABLE [CostAccounting_DW].[DimShippedHistoryDetails]
([ShippedHistoryDetailKey]                   INT                NOT NULL,
    [Invoice Number]                         DECIMAL   (9)      NOT NULL,
    [Invoice Date]                           DATE               NOT NULL,
    [Order Number]                           VARCHAR   (10)     NOT NULL,
    [Item Number]                            VARCHAR   (25)     NOT NULL,
    [Item Sequence Number]                   DECIMAL   (7)      NOT NULL,
    [Order Date]                             DATE               NULL    ,
    [Credit Code]                            CHAR      (1)      NOT NULL,
    [Special Promotion]                      VARCHAR   (25)     NOT NULL,
    [Customer PO Number]                     VARCHAR   (22)     NOT NULL,
    [Trip Number]                            DECIMAL   (7)      NOT NULL,
    [Drop Number]                            DECIMAL   (29)     NOT NULL,
    [Order Type 1]                           CHAR      (1)      NOT NULL,
    [Order Type 2]                           CHAR      (1)      NOT NULL,
    [Order Type 3]                           CHAR      (1)      NOT NULL,
    [Order Type 4]                           CHAR      (1)      NOT NULL,
    [Bill To Marketing Specialist]           DECIMAL   (29)     NOT NULL,
    [Bill To Commission Rate]                DECIMAL   (29, 10) NOT NULL,
    [Ship To Marketing Specialist]           DECIMAL   (29, 4)  NOT NULL,
    [Ship To Commission Rate]                DECIMAL   (29, 10) NOT NULL,
    [Price Exception Record ID]              DECIMAL   (29)     NOT NULL,
    [Volume Percent]                         DECIMAL   (29, 4)  NOT NULL,
    [DFI Percent]                            DECIMAL   (29, 4)  NOT NULL,
    [Co-Op Ad Allowance Percent]             DECIMAL   (29, 4)  NOT NULL,
    [No Show Discount Percent]               DECIMAL   (29, 4)  NOT NULL,
    [Price Adder Percent]                    DECIMAL   (29, 4)  NOT NULL,
    [Exception Volume Percent]               DECIMAL   (29, 4)  NOT NULL,
    [Exception DFI Percent]                  DECIMAL   (29, 4)  NOT NULL,
    [Exception Co-Op Ad Allowance Percent]   DECIMAL   (29, 4)  NOT NULL,
    [Exception No Show Discount Percent]     DECIMAL   (29, 4)  NOT NULL,
    [Exception Price Adder Percent]          DECIMAL   (29, 4)  NOT NULL,
    [Special Charge Code]                    DECIMAL   (1)      NOT NULL,
    [Special Charge Description]             VARCHAR   (30)     NOT NULL,
    [Special Charge Credit Code]             CHAR      (3)      NOT NULL,
    [Special Charge Credit Code Description] VARCHAR   (30)     NOT NULL,
    [Special Charge Type Code]               VARCHAR   (30)     NULL    ,
    [Defect Code]                            CHAR      (2)      NOT NULL,
    [Location Code]                          CHAR      (2)      NOT NULL,
    [Invoice Type]                           CHAR      (7)      NOT NULL
);



GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Volume_Percent]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Volume Percent]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Trip_Number]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Trip Number]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Special_Promotion]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Special Promotion]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Special_Charge_Description]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Special Charge Description]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Special_Charge_Credit_Code_Description]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Special Charge Credit Code Description]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Special_Charge_Credit_Code]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Special Charge Credit Code]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Special_Charge_Code]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Special Charge Code]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_ShippedHistoryDetailKey]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([ShippedHistoryDetailKey]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Ship_To_Marketing_Specialist]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Ship To Marketing Specialist]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Ship_To_Commission_Rate]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Ship To Commission Rate]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Price_Exception_Record_ID]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Price Exception Record ID]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Price_Adder_Percent]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Price Adder Percent]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Order_Type_4]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Order Type 4]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Order_Type_3]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Order Type 3]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Order_Type_2]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Order Type 2]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Order_Type_1]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Order Type 1]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Order_Number]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Order Number]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Order_Date]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Order Date]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_No_Show_Discount_Percent]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([No Show Discount Percent]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Location_Code]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Location Code]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Item_Sequence_Number]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Item Sequence Number]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Invoice_Number]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Invoice Number]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Exception_Volume_Percent]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Exception Volume Percent]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Exception_Price_Adder_Percent]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Exception Price Adder Percent]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Exception_No_Show_Discount_Percent]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Exception No Show Discount Percent]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Exception_DFI_Percent]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Exception DFI Percent]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Exception_Co_Op_Ad_Allowance_Percent]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Exception Co-Op Ad Allowance Percent]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Drop_Number]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Drop Number]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_DFI_Percent]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([DFI Percent]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Defect_Code]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Defect Code]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Customer_PO_Number]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Customer PO Number]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Credit_Code]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Credit Code]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Co_Op_Ad_Allowance_Percent]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Co-Op Ad Allowance Percent]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Bill_To_Marketing_Specialist]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Bill To Marketing Specialist]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Bill_To_Commission_Rate]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Bill To Commission Rate]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Invoice_Date]
    ON [CostAccounting_DW].[DimShippedHistoryDetails]([Invoice Date]);


GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Special_Charge_Type_Code] 
    ON [CostAccounting_DW].[DimShippedHistoryDetails] ([Special Charge Type Code]);

GO
CREATE STATISTICS [Stat_DimShippedHistoryDetail_Invoice_Type] 
    ON [CostAccounting_DW].[DimShippedHistoryDetails] ([Invoice Type]);


