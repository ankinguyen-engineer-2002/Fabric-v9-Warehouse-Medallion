CREATE VIEW [Email_Marketing_Wrk].[v_TotalTransactionalSegment]
AS 
SELECT audpvt.Email_Date,
       audpvt.Audience,
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
    SELECT CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24  Email_Date,
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
    WHERE Email_Msg_Typ IN ( 'TRIGGER', 'TRANSACTIONAL' )
          OR Email_Msg_Typ IS NULL
    GROUP BY CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24 ,
             CASE
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
        SELECT CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24  Email_Date,
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
        WHERE Email_Msg_Typ IN ( 'TRIGGER', 'TRANSACTIONAL' )
              OR Email_Msg_Typ IS NULL
        GROUP BY CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24 ,
                 CASE
                    WHEN Audience IS NULL THEN
                        'No Segment-RTM Emails'
                    ELSE
                        Audience
                END,
                 MessageName,
                 Email_Msg_Typ,
                 Email_Prod_Cat
    ) Rev
        ON audpvt.Email_Date = Rev.Email_Date
           AND audpvt.Audience = Rev.Audience
           AND audpvt.MessageName = Rev.MessageName
           AND audpvt.Email_Msg_Typ = Rev.Email_Msg_Typ
           AND audpvt.Email_Prod_Cat = Rev.Email_Prod_Cat;


