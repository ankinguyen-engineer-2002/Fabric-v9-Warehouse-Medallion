CREATE VIEW [Email_Marketing_Wrk].[v_UniquePromotionalSegmentClickers]
AS 
SELECT MIN(CAST(CAST(base.ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, base.ActionTimestamp) AS FLOAT) / 24 ) Delivered_Startdate,
       CASE
           WHEN base.Audience IS NULL THEN
               'No Segment-RTM Emails'
           ELSE
               base.Audience
       END AS Audience,
       base.MessageName,
       base.Email_Msg_Typ,
       base.Email_Prod_Cat,
       aggs.Unique_Clickers
FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity]  base
    LEFT JOIN
    (
        SELECT audpvtCl.Audience,
               audpvtCl.MessageName,
               audpvtCl.Email_Msg_Typ,
               audpvtCl.Email_Prod_Cat,
               SUM(audpvtCl.[Click]) Unique_Clickers
        FROM
        (
            SELECT CASE
                       WHEN Audience IS NULL THEN
                           'No Segment-RTM Emails'
                       ELSE
                           Audience
                   END AS Audience,
                   MessageName,
                   Email_Msg_Typ,
                   Email_Prod_Cat,
                   Action,
                   COUNT(DISTINCT EmailAddress) AS UnqRowsClick
            FROM       
            [$(databricks)].[retail_marketing].[epsilonmarketingactivity] 
            WHERE Action = 'Click'
                  AND (Email_Msg_Typ IN ( 'PROMOTIONAL', 'N/A' ))
            GROUP BY CASE
                         WHEN Audience IS NULL THEN
                             'No Segment-RTM Emails'
                         ELSE
                             Audience
                     END,
                     MessageName,
                     Email_Msg_Typ,
                     Email_Prod_Cat,
                     [Action]
        ) audunpvtCl
        PIVOT
        (
            SUM(UnqRowsClick)
            FOR Action IN ([Click])
        ) audpvtCl
        GROUP BY audpvtCl.Audience,
                 audpvtCl.MessageName,
                 audpvtCl.Email_Msg_Typ,
                 audpvtCl.Email_Prod_Cat
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
WHERE base.Action = 'Delivered' AND base.Email_Msg_Typ IN ( 'PROMOTIONAL', 'N/A' )
     
GROUP BY CASE
           WHEN base.Audience IS NULL THEN
               'No Segment-RTM Emails'
           ELSE
               base.Audience
       END,
         base.MessageName,
         base.Email_Msg_Typ,
         base.Email_Prod_Cat,
         aggs.Unique_Clickers

UNION ALL
         

SELECT MIN(CAST(CAST(base.ActivityDateTimeUtc AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, base.ActivityDateTimeUtc) AS FLOAT) / 24 ) Delivered_Startdate,
       CASE
           WHEN base.Audience IS NULL THEN
               'No Segment-RTM Emails'
           ELSE
               base.Audience
       END AS Audience,
       base.CampaignName AS MessageName,
       base.CampaignType AS Email_Msg_Typ,
       base.CampaignTags AS Email_Prod_Cat,
       aggs.Unique_Clickers
FROM [$(databricks)].[retail_marketing].[marketingactivity]  base
    LEFT JOIN
    (
        SELECT audpvtCl.Audience,
               audpvtCl.MessageName,
               audpvtCl.Email_Msg_Typ,
               audpvtCl.Email_Prod_Cat,
               SUM(audpvtCl.[campaign_clicked]) Unique_Clickers
        FROM
        (
            SELECT CASE
                       WHEN Audience IS NULL THEN
                           'No Segment-RTM Emails'
                       ELSE
                           Audience
                   END AS Audience,
                   CampaignName AS MessageName,
                   CampaignType AS Email_Msg_Typ,
                   CampaignTags AS Email_Prod_Cat,
                   ChannelAction AS Action,
                   COUNT(DISTINCT ContactValue) AS UnqRowsClick
            FROM       
            [$(databricks)].[retail_marketing].[marketingactivity] 
            WHERE ChannelAction = 'campaign_clicked'
                  AND (CampaignType IN ( 'manual' ))  
            GROUP BY CASE
                         WHEN Audience IS NULL THEN
                             'No Segment-RTM Emails'
                         ELSE
                             Audience
                     END,
                     CampaignName,
                     CampaignType,
                     CampaignTags,
                     ChannelAction
        ) audunpvtCl
        PIVOT
        (
            SUM(UnqRowsClick)
            FOR Action IN ([campaign_clicked])
        ) audpvtCl
        GROUP BY audpvtCl.Audience,
                 audpvtCl.MessageName,
                 audpvtCl.Email_Msg_Typ,
                 audpvtCl.Email_Prod_Cat
    ) aggs
        ON CASE
           WHEN base.Audience IS NULL THEN
               'No Segment-RTM Emails'
           ELSE
               base.Audience
       END = aggs.Audience
           AND base.CampaignName = aggs.MessageName
           AND base.CampaignType = aggs.Email_Msg_Typ
           AND base.CampaignTags = aggs.Email_Prod_Cat
WHERE base.ChannelAction = 'Delivered' AND base.CampaignType IN ( 'manual' )
     
GROUP BY CASE
           WHEN base.Audience IS NULL THEN
               'No Segment-RTM Emails'
           ELSE
               base.Audience
       END,
         base.CampaignName,
         base.CampaignType,
         base.CampaignTags,
         aggs.Unique_Clickers;


