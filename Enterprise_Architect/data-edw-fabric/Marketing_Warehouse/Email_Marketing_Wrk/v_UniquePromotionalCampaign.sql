CREATE VIEW [Email_Marketing_Wrk].[v_UniquePromotionalCampaign]
AS SELECT CAST(MIN(CAST(CAST(base.ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, base.ActionTimestamp) AS FLOAT) / 24 ) AS DATETIME2(6)) AS [Delivered Start Date],
       base.MessageName,
       aggs.UnqOpens,
       aggs.UnqClick
  FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity] base
    LEFT JOIN
    (
        SELECT msgpvts.MessageName,
               SUM(msgpvts.[Open]) UnqOpens,
               SUM(msgpvts.Click) UnqClick
        FROM
        (
            SELECT MessageName,
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
            GROUP BY MessageName,
                     LEFT(LinkURL, CHARINDEX('?', LinkURL)),
                     DeviceCategory,
                     DeviceSubcategory,
                     DeviceType,
                     LinkName,
                     LinkTag,
                     EventName,
                     Action
        ) msgunpvts
        PIVOT
        (
            SUM(UnqRows)
            FOR Action IN ([Open], [Click])
        ) msgpvts
        GROUP BY msgpvts.MessageName
    ) aggs
        ON base.MessageName = aggs.MessageName
WHERE base.Action = 'Delivered'
      AND base.Email_Msg_Typ IN ( 'PROMOTIONAL', 'N/A' )
GROUP BY base.MessageName,
         aggs.UnqOpens,
         aggs.UnqClick
UNION ALL

SELECT CAST(MIN(CAST(CAST(base.ActivityDateTimeUtc AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, base.ActivityDateTimeUtc) AS FLOAT) / 24 ) AS DATETIME2(6)) AS [Delivered Start Date],
       base.CampaignName,
       aggs.UnqOpens,
       aggs.UnqClick
  FROM [$(databricks)].[retail_marketing].[marketingactivity] base
    LEFT JOIN
    (
        SELECT msgpvts.MessageName,
               SUM(msgpvts.campaign_opened) UnqOpens,
               SUM(msgpvts.campaign_clicked) UnqClick
        FROM
        (
            SELECT CampaignName AS MessageName,
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
            GROUP BY CampaignName,
                     LEFT(LinkUrl, CHARINDEX('?', LinkUrl)),
                     DeviceCategory,
                     DeviceSubcategory,
                     DeviceType,
                     LinkName,
                     LinkTag,
                     --EventName,
                     ChannelAction
        ) msgunpvts
        PIVOT
        (
            SUM(UnqRows)
            FOR Action IN ([campaign_opened], [campaign_clicked])
        ) msgpvts
        GROUP BY msgpvts.MessageName
    ) aggs
        ON base.CampaignName = aggs.MessageName
WHERE base.ChannelAction = 'campaign_delivered'
      AND base.CampaignType IN ( 'manual' )
GROUP BY base.CampaignName,
         aggs.UnqOpens,
         aggs.UnqClick

