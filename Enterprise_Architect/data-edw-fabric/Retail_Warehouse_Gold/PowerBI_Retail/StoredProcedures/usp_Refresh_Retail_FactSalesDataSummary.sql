CREATE     PROCEDURE [PowerBI_Retail].[usp_Refresh_Retail_FactSalesDataSummary]
AS
BEGIN
    DECLARE @TransDate DATE = DATEADD(DAY, -7, GETDATE());

    EXEC [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryBedsBedroom] @TransDate;
    EXEC [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryLoadPPPDataOverall] @TransDate;
    EXEC [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryLoadPPPDataXFI] @TransDate;
    EXEC [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryMbsPbs] @TransDate;
    EXEC [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryMbsPil] @TransDate;
    EXEC [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryMbsXmt] @TransDate;

    EXEC [PowerBI_Retail].[usp_Refresh_Retail_FactSalesEmailCapture] @TransDate;
    EXEC [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryMbsCount] @TransDate, 1;
    EXEC [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryMbsCount] @TransDate, 2;
    EXEC [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryLoadPPP3YR] @TransDate;
    EXEC [PowerBI_Retail].[usp_Refresh_Retail_FactSalesAttachmentSummaryLoadPPP5YR] @TransDate;
END;
GO

