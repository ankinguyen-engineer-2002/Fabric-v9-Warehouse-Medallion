CREATE TABLE [PowerBI_Retail].[FactSalesAttachmentSummary] (
    [AttachmentKey]  INT             NULL,
    [TransDate]      DATE            NULL,
    [SalesPersonKey] INT             NOT NULL,
    [LocationKey]    INT             NOT NULL,
    [AttachmentType] INT             NULL,
    [PrimaryValue]   DECIMAL (13, 2) NULL,
    [AttachedValue]  DECIMAL (13, 2) NULL,
    [DateChanged]    DATETIME2 (3)   NULL
);
GO

