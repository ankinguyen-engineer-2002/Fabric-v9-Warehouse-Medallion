
CREATE VIEW [Email_Marketing_Wrk].[v_UniquePromotionalSegment]
AS
SELECT CAST(MIN(CAST(CAST(base.ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, base.ActionTimestamp) AS FLOAT)
           / 24
          ) AS DATETIME2(6)) AS Delivered_Startdate,
       CASE
           WHEN base.Audience IS NULL THEN
               'No Segment-RTM Emails'
           ELSE
               base.Audience
       END AS Audience,
       base.MessageName,
       base.Email_Msg_Typ,
       base.Email_Prod_Cat,
       aggs.Unique_Open,
       aggs.Unique_Clicks
  FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity] base
    LEFT JOIN
    (
        SELECT 
            audpvt.Audience,
            audpvt.MessageName,
            audpvt.Email_Msg_Typ,
            audpvt.Email_Prod_Cat,
            SUM(audpvt.[Open]) Unique_Open,
            SUM(audpvt.Click) Unique_Clicks
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
                   LEFT(LinkURL, CHARINDEX('?', LinkURL)) AS LinkURL,
                   DeviceCategory,
                   DeviceSubcategory,
                   DeviceType,
                   LinkName,
                   LinkTag,
                   EventName,
                   Action,
                   COUNT(DISTINCT EmailAddress) AS [UnqRows]
              FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity]
            WHERE Action IN ( 'Open', 'Click' )
                  AND (Email_Msg_Typ IN ( 'PROMOTIONAL', 'N/A' ))
            GROUP BY 
                CASE
                    WHEN Audience IS NULL THEN
                        'No Segment-RTM Emails'
                    ELSE
                        Audience
                END,
                LEFT(LinkURL, CHARINDEX('?', LinkURL)),
                MessageName,
                Email_Msg_Typ,
                Email_Prod_Cat,
                DeviceCategory,
                DeviceSubcategory,
                DeviceType,
                LinkName,
                LinkTag,
                EventName,
                Action
        ) audunpvt
        PIVOT
        (
            SUM([UnqRows])
            FOR Action IN ([Open], [Click])
        ) AS audpvt
        GROUP BY
            audpvt.Audience,
            audpvt.MessageName,
            audpvt.Email_Msg_Typ,
            audpvt.Email_Prod_Cat
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
         aggs.Unique_Open,
         aggs.Unique_Clicks

UNION ALL

SELECT CAST(MIN(CAST(CAST(base.ActivityDateTimeUtc AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, base.ActivityDateTimeUtc) AS FLOAT)
           / 24
          ) AS DATETIME2(6)) AS Delivered_Startdate,
       CASE
           WHEN base.Audience IS NULL THEN
               'No Segment-RTM Emails'
           ELSE
               base.Audience
       END AS Audience,
       base.CampaignName,
       base.CampaignType,
       base.CampaignTags,
       aggs.Unique_Open,
       aggs.Unique_Clicks
  FROM [$(databricks)].[retail_marketing].[marketingactivity] base
    LEFT JOIN
    (
        SELECT 
            audpvt.Audience,
            audpvt.MessageName,
            audpvt.Email_Msg_Typ,
            audpvt.Email_Prod_Cat,
            SUM(audpvt.campaign_opened) Unique_Open,
            SUM(audpvt.campaign_clicked) Unique_Clicks
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
                   LEFT(LinkUrl, CHARINDEX('?', LinkUrl)) AS LinkURL,
                   DeviceCategory,
                   DeviceSubcategory,
                   DeviceType,
                   LinkName,
                   LinkTag,
                   '' AS EventName,
                   ChannelAction AS Action,
                   COUNT(DISTINCT ContactValue) AS [UnqRows]
              FROM [$(databricks)].[retail_marketing].[marketingactivity]
            WHERE ChannelAction IN( 'campaign_opened', 'campaign_clicked' )
                  AND (CampaignType IN ( 'manual' ))
            GROUP BY 
                CASE
                    WHEN Audience IS NULL THEN
                        'No Segment-RTM Emails'
                    ELSE
                        Audience
                END,
                LEFT(LinkUrl, CHARINDEX('?', LinkUrl)),
                CampaignName,
                CampaignType,
                CampaignTags,
                DeviceCategory,
                DeviceSubcategory,
                DeviceType,
                LinkName,
                LinkTag,
                --EventName,
                ChannelAction
        ) audunpvt
        PIVOT
        (
            SUM([UnqRows])
            FOR Action IN ([campaign_opened], [campaign_clicked])
        ) AS audpvt
        GROUP BY
            audpvt.Audience,
            audpvt.MessageName,
            audpvt.Email_Msg_Typ,
            audpvt.Email_Prod_Cat
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
WHERE base.ChannelAction = 'campaign_delivered'
      AND base.CampaignType IN ( 'manual' )
      
GROUP BY CASE
             WHEN base.Audience IS NULL THEN
                 'No Segment-RTM Emails'
             ELSE
                 base.Audience
         END,
         base.CampaignName,
         base.CampaignType,
         base.CampaignTags,
         aggs.Unique_Open,
         aggs.Unique_Clicks


