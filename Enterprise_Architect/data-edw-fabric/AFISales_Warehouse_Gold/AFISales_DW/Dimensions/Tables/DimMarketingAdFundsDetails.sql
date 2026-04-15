CREATE TABLE [AFISales_DW].[DimMarketingAdFundsDetails] (
    [Ad Funds Key]                   INT            NULL,
    [Ad Funds Modified Date]         DATE           NULL,
    [Ad Funds Modified By]           VARCHAR (30)   NULL,
    [Ad Funds Division]              VARCHAR (50)   NULL,
    [Ad Funds Velocity Driver Name]  CHAR (1)       NULL,
    [Ad Funds Type]                  VARCHAR (100)  NULL,
    [Ad Funds Approval Status]       VARCHAR (100)  NULL,
    [Ad Funds Comments]              VARCHAR (8000) NULL,
    [Ad Funds Special Discount Code] VARCHAR (200)  NULL,
    [Ad Funds Event Name]            VARCHAR (50)   NULL,
    [Ad Funds VP]                    VARCHAR (62)   NULL,
    [Ad Used For]                    VARCHAR (30)   NULL,
    [Ad Funds Requestor]             VARCHAR (40)   NULL,
    [Ad Funds Approver]              VARCHAR (100)  NULL,
    [Ad Funds Category focused on]   VARCHAR (50)   NULL,
    [Ad Funds Event Start Date]      DATETIME2 (6)  NULL,  --DATETIME
    [Ad Funds Event End Date]        DATETIME2 (6)  NULL,  --DATETIME 
    [InvoiceDate]                    DATE           NULL,
    [InvoiceNumber]                  CHAR (8)       NULL,
    [OrderNumber]                    CHAR (8)       NULL
)


GO
CREATE STATISTICS [Stat_DimMarketingAdFundsDetails_AdFundsModiedDate]
    ON [AFISales_DW].[DimMarketingAdFundsDetails]([Ad Funds Modified Date]);


GO
CREATE STATISTICS [Stat_DimMarketingAdFundsDetails_AdFundsKey]
    ON [AFISales_DW].[DimMarketingAdFundsDetails]([Ad Funds Key]);


GO
CREATE STATISTICS [Stat_DimMarketingAdFundsDetails_Ad_Used_For]
    ON [AFISales_DW].[DimMarketingAdFundsDetails]([Ad Used For]);


GO
CREATE STATISTICS [Stat_DimMarketingAdFundsDetails_Ad_Funds_VP]
    ON [AFISales_DW].[DimMarketingAdFundsDetails]([Ad Funds VP]);


GO
CREATE STATISTICS [Stat_DimMarketingAdFundsDetails_Ad_Funds_Type]
    ON [AFISales_DW].[DimMarketingAdFundsDetails]([Ad Funds Type]);


GO
CREATE STATISTICS [Stat_DimMarketingAdFundsDetails_Ad_Funds_Special_Discount_Code]
    ON [AFISales_DW].[DimMarketingAdFundsDetails]([Ad Funds Special Discount Code]);


GO
CREATE STATISTICS [Stat_DimMarketingAdFundsDetails_Ad_Funds_Event_Name]
    ON [AFISales_DW].[DimMarketingAdFundsDetails]([Ad Funds Event Name]);


GO
CREATE STATISTICS [Stat_DimMarketingAdFundsDetails_Ad_Funds_Division]
    ON [AFISales_DW].[DimMarketingAdFundsDetails]([Ad Funds Division]);


GO
CREATE STATISTICS [Stat_DimMarketingAdFundsDetails_Ad_Funds_Comments]
    ON [AFISales_DW].[DimMarketingAdFundsDetails]([Ad Funds Comments]);


GO
CREATE STATISTICS [Stat_DimMarketingAdFundsDetails_Ad_Funds_Approval_Status]
    ON [AFISales_DW].[DimMarketingAdFundsDetails]([Ad Funds Approval Status]);


GO
CREATE STATISTICS Stat_DimMarketingAdFundsDetails_Ad_Funds_Requestor 
ON AFISales_DW.DimMarketingAdFundsDetails([Ad Funds Requestor]);


GO
CREATE STATISTICS Stat_DimMarketingAdFundsDetails_Ad_Funds_Approver 
ON AFISales_DW.DimMarketingAdFundsDetails ([Ad Funds Approver]);


GO
CREATE STATISTICS Stat_DimMarketingAdFundsDetails_Ad_Funds_Category_focused_on 
ON AFISales_DW.DimMarketingAdFundsDetails([Ad Funds Category focused on]);

GO
CREATE STATISTICS Stat_DimMarketingAdFundsDetails_Ad_Funds_Event_Start_Date 
ON AFISales_DW.DimMarketingAdFundsDetails ([Ad Funds Event Start Date]);

GO
CREATE STATISTICS Stat_DimMarketingAdFundsDetails_Ad_Funds_Event_End_Date 
ON AFISales_DW.DimMarketingAdFundsDetails([Ad Funds Event End Date])


