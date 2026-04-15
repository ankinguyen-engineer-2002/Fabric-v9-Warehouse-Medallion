CREATE VIEW [Email_Marketing_Wrk].[v_UniqueAccountDateLevel]
AS
SELECT msgpvts.ActionTimestamp,
       SUM(msgpvts.[Open]) UnqOpens,
       SUM(msgpvts.Click) UnqClick
FROM
(
    SELECT CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24 ActionTimestamp,
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
    GROUP BY CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24,
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
GROUP BY msgpvts.ActionTimestamp

UNION ALL

SELECT msgpvts.ActionTimestamp,
       SUM(msgpvts.campaign_opened) UnqOpens,
       SUM(msgpvts.campaign_clicked) UnqClick
FROM
(
    SELECT CAST(CAST(ActivityDateTimeUtc AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActivityDateTimeUtc) AS FLOAT) / 24 ActionTimestamp,
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
    WHERE ChannelAction IN ('campaign_opened', 'campaign_clicked')         
    GROUP BY CAST(CAST(ActivityDateTimeUtc AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActivityDateTimeUtc) AS FLOAT) / 24,
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
GROUP BY msgpvts.ActionTimestamp

