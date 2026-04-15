CREATE TABLE [AFISales_DW].[DimBuyGroupDetails] (
    [Buying Group Code]        CHAR (3)     NULL,
    [Buying Group Description] VARCHAR (25) NULL
)



GO
CREATE STATISTICS [Stat_DimBuyGroupDetails_BuyingGroupCode]
    ON [AFISales_DW].[DimBuyGroupDetails]([Buying Group Code]);


GO
CREATE STATISTICS [Stat_DimBuyGroupDetails_Buying_Group_Description]
    ON [AFISales_DW].[DimBuyGroupDetails]([Buying Group Description]);


