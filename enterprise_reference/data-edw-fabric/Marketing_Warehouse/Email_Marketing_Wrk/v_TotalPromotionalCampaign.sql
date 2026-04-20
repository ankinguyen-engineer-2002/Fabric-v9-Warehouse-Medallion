CREATE VIEW [Email_Marketing_Wrk].v_TotalPromotionalCampaign
as

SELECT 
    MIN(CAST(CAST(base.ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, base.ActionTimestamp) AS FLOAT) / 24 ) AS [Delivered Start Date],
    base.MessageName,
    aggs.SpamComplaint,
    aggs.ISPLinkUnsubscribe,
    aggs.Delivered,
    aggs.Undelivered,
    aggs.ReplyUnsubscribe,
    aggs.[Open],
    aggs.EmailLinkUnsubscribe,
    aggs.Click,
    aggs.Conversion,
    aggs.AbandonedCart,
    aggs.Purchase,
    aggs.Revenue,
    aggs.Quantity
FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity] base
    LEFT JOIN
    (
        SELECT msgpvt.MessageName,
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
            SELECT MessageName,
                   COALESCE(EventName, Action) AS NewAction,
                   COUNT(*) AS [TotRows]
            FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity]
            GROUP BY COALESCE(EventName, Action),
                     MessageName
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
                SELECT MessageName,
                       SUM(CAST(ConversionAmount AS FLOAT)) Revenue,
                       SUM(CAST(ConversionQuantity AS FLOAT)) Quantity
                FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity]
                GROUP BY MessageName
            ) Rev
                ON msgpvt.MessageName = Rev.MessageName
    ) aggs
        ON base.MessageName = aggs.MessageName
WHERE base.Action = 'Delivered'
      AND base.Email_Msg_Typ IN ( 'PROMOTIONAL', 'N/A' )
GROUP BY base.MessageName,
         aggs.SpamComplaint,
         aggs.ISPLinkUnsubscribe,
         aggs.Delivered,
         aggs.Undelivered,
         aggs.ReplyUnsubscribe,
         aggs.[Open],
         aggs.EmailLinkUnsubscribe,
         aggs.Click,
         aggs.Conversion,
         aggs.AbandonedCart,
         aggs.Purchase,
         aggs.Revenue,
         aggs.Quantity;
