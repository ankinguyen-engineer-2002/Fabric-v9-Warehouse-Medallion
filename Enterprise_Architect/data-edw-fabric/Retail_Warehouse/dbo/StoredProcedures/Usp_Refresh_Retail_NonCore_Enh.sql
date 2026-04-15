CREATE   PROC [dbo].[Usp_Refresh_Retail_NonCore_Enh] AS
BEGIN

    EXEC [Retail_OOM_Enh].[usp_Update_OrderChangeRegistry];

    EXEC [Retail_OOM_Enh].[usp_Update_OrderTransDetail];

    EXEC [Retail_OOM_Enh].[usp_Update_OrderTransDetailDailyStat];

    EXEC [Retail_OOM_Enh].[usp_Update_OOMSchedulePerformance];

    EXEC [Retail_OOM_Enh].[usp_Update_OOMSchedulePerformanceDetails];

    EXEC [Retail_OOM_Enh].[usp_OpenOrderSummary_Insert];
    
    EXEC [Retail_OOM_Enh].[usp_OpenOrderSummary_Insert_Detail];

END