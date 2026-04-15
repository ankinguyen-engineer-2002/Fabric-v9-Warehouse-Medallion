CREATE VIEW [Email_Marketing_Wrk].[v_TotalPromotionalSegments]
 AS 
 SELECT MIN(CAST(CAST(base.ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, base.ActionTimestamp) AS FLOAT)
           / 24
          ) AS [Delivered_StartDate],
       CASE
           WHEN base.Audience IS NULL THEN
               'No Segment-RTM Emails'
           ELSE
               base.Audience
       END AS Audience,
       base.MessageName,
       base.Email_Msg_Typ,
       base.Email_Prod_Cat,
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
FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity]  base
    LEFT JOIN
    (
        SELECT audpvt.Audience,
               audpvt.MessageName,
               audpvt.Email_Msg_Typ,
               audpvt.Email_Prod_Cat,
               audpvt.SpamComplaint,
               audpvt.ISPLinkUnsubscribe,
               audpvt.Delivered,
               audpvt.Undelivered,
               audpvt.ReplyUnsubscribe,
               audpvt.[Open],
               audpvt.EmailLinkUnsubscribe,
               audpvt.Click,
               audpvt.Conversion,
               audpvt.AbandonedCart,
               audpvt.Purchase,
               Rev.Revenue,
               Rev.Quantity
        FROM
        (
            SELECT --CAST(ActionTimestamp AS DATE) Email_Date,
                CASE
                    WHEN Audience IS NULL THEN
                        'No Segment-RTM Emails'
                    ELSE
                        Audience
                END AS Audience,
                MessageName,
                Email_Msg_Typ,
                Email_Prod_Cat,
                COALESCE(EventName, Action) AS NewAction,
                COUNT(*) AS [TotRows]
            FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity] 
            WHERE Email_Msg_Typ IN ( 'PROMOTIONAL', 'N/A' )
            GROUP BY CASE
                         WHEN Audience IS NULL THEN
                             'No Segment-RTM Emails'
                         ELSE
                             Audience
                     END,
                     COALESCE(EventName, Action),
                     MessageName,
                     Email_Msg_Typ,
                     Email_Prod_Cat
        ) audunpvt
        PIVOT
        (
            SUM(TotRows)
            FOR NewAction IN ([Conversion], [AbandonedCart], [Purchase], [Click], [EmailLinkUnsubscribe], [Open],
                              [ReplyUnsubscribe], [Undelivered], [Delivered], [ISPLinkUnsubscribe], [SpamComplaint]
                             )
        ) AS audpvt
            LEFT JOIN
            (
                SELECT --CAST(ActionTimestamp AS DATE) Email_Date,
                    CASE
                        WHEN Audience IS NULL THEN
                            'No Segment-RTM Emails'
                        ELSE
                            Audience
                    END AS Audience,
                    MessageName,
                    Email_Msg_Typ,
                    Email_Prod_Cat,
                    SUM(CAST(ConversionAmount AS FLOAT)) Revenue,
                    SUM(CAST(ConversionQuantity AS FLOAT)) Quantity
                FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity] 
                WHERE Email_Msg_Typ IN ( 'PROMOTIONAL', 'N/A' )
                GROUP BY CASE
                             WHEN Audience IS NULL THEN
                                 'No Segment-RTM Emails'
                             ELSE
                                 Audience
                         END,
                         MessageName,
                         Email_Msg_Typ,
                         Email_Prod_Cat
            ) Rev
                ON audpvt.Audience = Rev.Audience
                   AND audpvt.MessageName = Rev.MessageName
                   AND audpvt.Email_Msg_Typ = Rev.Email_Msg_Typ
                   AND audpvt.Email_Prod_Cat = Rev.Email_Prod_Cat
    ) aggs
        ON CASE
               WHEN base.Audience IS NULL THEN
                   'No Segment-RTM Emails'
               ELSE
                   base.Audience
           END = aggs.Audience
           AND base.MessageName = aggs.MessageName
           AND base.Email_Msg_Typ = aggs.Email_Msg_Typ
           AND base.Email_Prod_Cat = aggs.Email_Prod_Cat
WHERE base.Action = 'Delivered'
      AND base.Email_Msg_Typ IN ( 'PROMOTIONAL', 'N/A' )
GROUP BY CASE
             WHEN base.Audience IS NULL THEN
                 'No Segment-RTM Emails'
             ELSE
                 base.Audience
         END,
         base.MessageName,
         base.Email_Msg_Typ,
         base.Email_Prod_Cat,
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