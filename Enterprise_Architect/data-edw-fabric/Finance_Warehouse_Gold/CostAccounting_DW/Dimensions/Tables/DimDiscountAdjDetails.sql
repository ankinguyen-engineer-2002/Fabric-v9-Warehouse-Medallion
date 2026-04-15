CREATE TABLE [CostAccounting_DW].[DimDiscountAdjDetails]
 (
    [DiscountAdjDetailsKey]    INT         NOT NULL,
    [Discount Type]            VARCHAR (3) NOT NULL,
    [Discount Adjustment Code] VARCHAR (3) NOT NULL
);



GO
CREATE STATISTICS [Stat_DimDiscountAdjDetails_DiscountAdjDetailsKey]
    ON [CostAccounting_DW].[DimDiscountAdjDetails]([DiscountAdjDetailsKey]);


GO
CREATE STATISTICS [Stat_DimDiscountAdjDetails_Discount_Adjustment_Code]
    ON [CostAccounting_DW].[DimDiscountAdjDetails]([Discount Adjustment Code]);

