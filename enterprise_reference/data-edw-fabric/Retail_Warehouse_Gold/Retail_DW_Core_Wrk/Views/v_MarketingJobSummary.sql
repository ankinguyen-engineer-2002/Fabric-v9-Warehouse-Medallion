
CREATE   VIEW [Retail_DW_Core_Wrk].[v_MarketingJobSummary]
AS
SELECT
	[MessageID]
	,[EventDate]
    ,REPLACE(cast([EventDate] as date), '-','') AS EventDateKey
	,[AttributedWrittenSales]
	,[AttributedWrittenSalesOpenClick]
	,[AttributedWrittenSalesSends]
	,[SFMCStoreBrandId]
	,[Sends]
	,[UniqueSends]
	,[OpenCount3Day]
	,[UniqueOpenCount3Day]
	,[BounceCount3Day]
	,[UniqueBounceCount3Day]
	,[ClickCount3Day] [bigint]
	,[UniqueClickCount3Day]
	,[UnsubscribeCount3Day]
	,[UniqueUnsubscribeCount3Day]
	,[Journey]
	,[DeploymentId]
	,[EmailSubject]
	,[EmailName]
	,[JobId]
	,[SourceSystem]
	,[CreatedDate]
	,[CreatedBy]
	,[UpdatedDate]
	,[UpdatedBy]
FROM [$(Databricks)].retail_marketing.marketingjobsummary;
GO

