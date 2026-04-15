CREATE VIEW [Email_Marketing_Wrk].[v_UniqueTransactionalSegment]
AS SELECT audpvt.Email_Date,
       audpvt.Audience,
       audpvt.MessageName,
       audpvt.Email_Msg_Typ,
       audpvt.Email_Prod_Cat,
       SUM(audpvt.[Open]) Unique_Open,
       SUM(audpvt.Click) Unique_Clicks
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
          AND
          (
              Email_Msg_Typ IN ( 'TRIGGER', 'TRANSACTIONAL' )
              OR Email_Msg_Typ IS NULL
          )
    GROUP BY CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24 ,
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
GROUP BY audpvt.Email_Date,
         audpvt.Audience,
         audpvt.MessageName,
         audpvt.Email_Msg_Typ,
         audpvt.Email_Prod_Cat

UNION ALL

SELECT audpvt.Email_Date,
       audpvt.Audience,
       audpvt.MessageName,
       audpvt.Email_Msg_Typ,
       audpvt.Email_Prod_Cat,
       SUM(audpvt.campaign_opened) Unique_Open,
       SUM(audpvt.campaign_clicked) Unique_Clicks
FROM
(
    SELECT CAST(CAST(ActivityDateTimeUtc AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActivityDateTimeUtc) AS FLOAT) / 24  Email_Date,
           CASE
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
    WHERE ChannelAction IN ( 'campaign_opened', 'campaign_clicked' )
          AND
          CampaignType IN ( 'trigger' )

    GROUP BY CAST(CAST(ActivityDateTimeUtc AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActivityDateTimeUtc) AS FLOAT) / 24 ,
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
GROUP BY audpvt.Email_Date,
         audpvt.Audience,
         audpvt.MessageName,
         audpvt.Email_Msg_Typ,
         audpvt.Email_Prod_Cat;