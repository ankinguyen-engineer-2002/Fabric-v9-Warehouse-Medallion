
CREATE VIEW [Email_Marketing_Wrk].[v_UniqueTransactionalCampaign]
AS
SELECT msgpvts.Email_Date,
       msgpvts.MessageName,
       SUM(msgpvts.[Open]) UnqOpens,
       SUM(msgpvts.Click) UnqClick
FROM
(
    SELECT CAST(CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24 as DATETIME2(6)) as Email_Date,
           MessageName,
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
          AND Email_Msg_Typ IN ( 'TRIGGER', 'TRANSACTIONAL' )
          OR Email_Msg_Typ IS NULL
    GROUP BY CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24,
             MessageName,
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
GROUP BY msgpvts.Email_Date,
         msgpvts.MessageName

 UNION ALL

SELECT msgpvts.Email_Date,
       msgpvts.MessageName,
       SUM(msgpvts.campaign_opened) UnqOpens,
       SUM(msgpvts.campaign_clicked) UnqClick
FROM
(
    SELECT CAST(CAST(CAST(ActivityDateTimeUtc AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActivityDateTimeUtc) AS FLOAT) / 24 as DATETIME2(6)) as Email_Date,
           CampaignName AS MessageName,
           LEFT(LinkUrl, CHARINDEX('?', LinkUrl)) AS LinkURL,
           DeviceCategory,
           DeviceSubcategory,
           DeviceType,
           LinkName,
           LinkTag,
           '' as EventName,
           ChannelAction AS Action,
           COUNT(DISTINCT ContactValue) AS [UnqRows]
      FROM [$(databricks)].[retail_marketing].[marketingactivity]
    WHERE ChannelAction IN( 'campaign_opened', 'campaign_clicked' )
          AND CampaignType IN ( 'trigger' )
          
    GROUP BY CAST(CAST(ActivityDateTimeUtc AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActivityDateTimeUtc) AS FLOAT) / 24,
             CampaignName,
             LEFT(LinkUrl, CHARINDEX('?', LinkUrl)),
             DeviceCategory,
             DeviceSubcategory,
             DeviceType,
             LinkName,
             LinkTag,
            -- EventName,
             ChannelAction
) msgunpvts
PIVOT
(
    SUM(UnqRows)
    FOR Action IN ([campaign_opened], [campaign_clicked])
) msgpvts
GROUP BY msgpvts.Email_Date,
         msgpvts.MessageName;




        


