CREATE   VIEW [PowerBI_Retail_Wrk].[v_SalesAttachment]
AS
SELECT 
            [AttachamentKey] AS AttachmentKey,
			[AttachamentName] AS AttachmentName ,
			[PrimaryKeyName] AS PrimaryKeyName,
			[AttachedKeyName] AS AttachedKeyName,
			[StoredProcName] AS StoredProcName
FROM  [$(Source_Data)].[Retail_External].[SalesAttachment]
GO