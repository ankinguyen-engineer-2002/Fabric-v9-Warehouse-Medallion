CREATE VIEW [PowerBI_Retail_Wrk].[v_SalesAttachmentSummary]
AS
SELECT 
    [AttachmentKey],
    [TransDate],
    [SalesPersonKey],
    [LocationKey],
    [AttachmentType],
    ISNULL([PrimaryValue], 0) AS [PrimaryValue],
    ISNULL([AttachedValue], 0) AS [AttachedValue],
    ISNULL([DateChanged], GETDATE()) AS [DateChanged]
FROM [PowerBI_Retail].[FactSalesAttachmentSummary]
GO

