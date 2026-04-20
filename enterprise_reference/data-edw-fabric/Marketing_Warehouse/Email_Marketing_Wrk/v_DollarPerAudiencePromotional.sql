CREATE VIEW [Email_Marketing_Wrk].[v_DollarPerAudiencePromotional]
AS 
SELECT MIN(CAST(CAST(base.ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, base.ActionTimestamp) AS FLOAT) / 24)  Delivered_Startdate,
       CASE
           WHEN base.Audience IS NULL THEN
               'No Segment-RTM Emails'
           ELSE
               base.Audience
       END AS Audience,
       base.Email_Prod_Cat,
       base.MessageName,
       aggs.Unique_Emails,
       aggs.Revenue
FROM [$(Databricks)].[retail_marketing].[epsilonmarketingactivity] base
    LEFT JOIN
    (
        SELECT CASE
                   WHEN Audience IS NULL THEN
                       'No Segment-RTM Emails'
                   ELSE
                       Audience
               END AS Audience,
               Email_Prod_Cat,
               MessageName,
               COUNT(DISTINCT EmailAddress) Unique_Emails,
               SUM(CAST(ConversionAmount AS FLOAT)) Revenue
        FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity]
        WHERE Email_Msg_Typ IN ( 'PROMOTIONAL', 'N/A' )
        GROUP BY CASE
                     WHEN Audience IS NULL THEN
                         'No Segment-RTM Emails'
                     ELSE
                         Audience
                 END,
                 Email_Prod_Cat,
                 MessageName
    ) aggs
        ON CASE
               WHEN base.Audience IS NULL THEN
                   'No Segment-RTM Emails'
               ELSE
                   base.Audience
           END = aggs.Audience
           AND base.Email_Prod_Cat = aggs.Email_Prod_Cat
           AND base.MessageName = aggs.MessageName
WHERE base.Action = 'Delivered'
      AND base.Email_Msg_Typ IN ( 'PROMOTIONAL', 'N/A' )
GROUP BY CASE
             WHEN base.Audience IS NULL THEN
                 'No Segment-RTM Emails'
             ELSE
                 base.Audience
         END,
         base.Email_Prod_Cat,
         base.MessageName,
         aggs.Unique_Emails,
         aggs.Revenue;


