CREATE VIEW [Email_Marketing_Wrk].[v_TotalTransactionalCampaign]
AS   SELECT msgpvt.Email_Date,
       msgpvt.MessageName,
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
    SELECT CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24  Email_Date,
           MessageName,
           COALESCE(EventName, Action) AS NewAction,
           COUNT(*) AS [TotRows]
    FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity] 
    WHERE Email_Msg_Typ IN ( 'TRIGGER', 'TRANSACTIONAL' )
          OR Email_Msg_Typ IS NULL
    GROUP BY CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24,
             COALESCE(EventName, Action),
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
        SELECT CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24  Email_Date,
               MessageName,
               SUM(CAST(ConversionAmount AS FLOAT)) Revenue,
               SUM(CAST(ConversionQuantity AS FLOAT)) Quantity
        FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity] 
        WHERE Email_Msg_Typ IN ( 'TRIGGER', 'TRANSACTIONAL' )
              OR Email_Msg_Typ IS NULL
        GROUP BY CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24 ,
                 MessageName
    ) Rev
        ON msgpvt.Email_Date = Rev.Email_Date
           AND msgpvt.MessageName = Rev.MessageName

