CREATE VIEW [Email_Marketing_Wrk].[v_AccountLevel]
AS SELECT msgpvt.ActionTimestamp,
       msgpvt.DeviceType,
       msgpvt.ConversionCategory,
       msgpvt.ConversionSubcategory,
       msgpvt.SpamComplaint,
       msgpvt.ISPLinkUnsubscribe,
       msgpvt.Delivered,
       msgpvt.Undelivered,
       msgpvt.ReplyUnsubscribe,
       msgpvt.[Open],
       msgpvt.EmailLinkUnsubscribe,
       msgpvt.Click,
       msgpvt.Conversion,
       msgpvt.AbandonedCart,
       msgpvt.Purchase,
       Rev.Revenue,
       Rev.Quantity
FROM
(
    SELECT CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24  ActionTimestamp,
           DeviceType,
           ConversionCategory,
           ConversionSubcategory,
           COALESCE(EventName, Action) AS NewAction,
           COUNT(*) AS [TotRows]
    FROM  [$(Databricks)].[retail_marketing].[epsilonmarketingactivity]
    GROUP BY CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24 ,
             DeviceType,
             ConversionCategory,
             ConversionSubcategory,
             COALESCE(EventName, Action)
) msgunpvt
PIVOT
(
    SUM(TotRows)
    FOR NewAction IN ([Conversion], [AbandonedCart], [Purchase], [Click], [EmailLinkUnsubscribe], [Open],
                      [ReplyUnsubscribe], [Undelivered], [Delivered], [ISPLinkUnsubscribe], [SpamComplaint]
                     )
) AS msgpvt
    LEFT JOIN
    (
        SELECT CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24  ActionTimestamp,
               DeviceType,
               ConversionCategory,
               ConversionSubcategory,
               SUM(CAST(ConversionAmount AS FLOAT)) Revenue,
               SUM(CAST(ConversionQuantity AS FLOAT)) Quantity
        FROM  [$(Databricks)].[retail_marketing].[epsilonmarketingactivity]
        GROUP BY CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24 ,
                 DeviceType,
                 ConversionCategory,
                 ConversionSubcategory
    ) Rev
        ON msgpvt.ActionTimestamp= Rev.ActionTimestamp
           AND msgpvt.DeviceType = Rev.DeviceType
           AND msgpvt.ConversionCategory = Rev.ConversionCategory
           AND msgpvt.ConversionSubcategory = Rev.ConversionSubcategory;