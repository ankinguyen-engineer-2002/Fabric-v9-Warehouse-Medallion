-- Auto Generated (Do not modify) EF0656EAD4DDF804729179E4C783395E76C0D961616BB931EA67006CE65E1A1B
CREATE   VIEW [Retail_DW_Core_Wrk].[v_CartDetail] AS

SELECT 
    [CartNumber],
    [ProductID],
    [Price],
    [DiscountedPrice],
    [Quantity]
FROM [$(Source_Data)].[Retail_External].[CartDetail];