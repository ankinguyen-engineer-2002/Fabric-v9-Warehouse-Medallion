CREATE TABLE [AFISales_DW].[DimSpecialChargeDetails] (
    [Credit Code]                CHAR (3)     NULL,
    [Credit Code Description]    VARCHAR (30) NULL,
    [Credit ID Code]             CHAR (1)     NULL,
    [Finance Code]               CHAR (3)     NULL,
    [Apply To Commission]        CHAR (1)     NULL,
    [Accrual Credit]             CHAR (1)     NULL,
    [Special Charge Code]        CHAR (1)     NULL,
    [Sales Tax Flag]             CHAR (1)     NULL,
    [Type Code]                  VARCHAR (10) NULL,
    [Allocation Code]            VARCHAR (10) NULL,
    [Commission Adjustment Flag] CHAR (1)     NULL
)


GO
CREATE STATISTICS [Stat_DimSpecialChargeDetails_CreditCode]
    ON [AFISales_DW].[DimSpecialChargeDetails]([Credit Code]);


GO
CREATE STATISTICS [Stat_DimSpecialChargeDetails_Type_Code]
    ON [AFISales_DW].[DimSpecialChargeDetails]([Type Code]);


GO
CREATE STATISTICS [Stat_DimSpecialChargeDetails_Special_Charge_Code]
    ON [AFISales_DW].[DimSpecialChargeDetails]([Special Charge Code]);


GO
CREATE STATISTICS [Stat_DimSpecialChargeDetails_Sales_Tax_Flag]
    ON [AFISales_DW].[DimSpecialChargeDetails]([Sales Tax Flag]);


GO
CREATE STATISTICS [Stat_DimSpecialChargeDetails_Finance_Code]
    ON [AFISales_DW].[DimSpecialChargeDetails]([Finance Code]);


GO
CREATE STATISTICS [Stat_DimSpecialChargeDetails_Credit_ID_Code]
    ON [AFISales_DW].[DimSpecialChargeDetails]([Credit ID Code]);


GO
CREATE STATISTICS [Stat_DimSpecialChargeDetails_Credit_Code_Description]
    ON [AFISales_DW].[DimSpecialChargeDetails]([Credit Code Description]);


GO
CREATE STATISTICS [Stat_DimSpecialChargeDetails_Commission_Adjustment_Flag]
    ON [AFISales_DW].[DimSpecialChargeDetails]([Commission Adjustment Flag]);


GO
CREATE STATISTICS [Stat_DimSpecialChargeDetails_Apply_To_Commission]
    ON [AFISales_DW].[DimSpecialChargeDetails]([Apply To Commission]);


GO
CREATE STATISTICS [Stat_DimSpecialChargeDetails_Allocation_Code]
    ON [AFISales_DW].[DimSpecialChargeDetails]([Allocation Code]);


GO
CREATE STATISTICS [Stat_DimSpecialChargeDetails_Accrual_Credit]
    ON [AFISales_DW].[DimSpecialChargeDetails]([Accrual Credit]);



