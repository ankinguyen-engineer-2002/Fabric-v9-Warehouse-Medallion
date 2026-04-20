CREATE VIEW [Email_Marketing_Wrk].[v_UniqueTransactionalSegmentClickers]
AS

SELECT audpvtCl.Email_Date,
       audpvtCl.Audience,
       audpvtCl.MessageName,
       audpvtCl.Email_Msg_Typ,
       audpvtCl.Email_Prod_Cat,
       SUM(audpvtCl.[Click]) Unique_Clickers
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
           Action,
           COUNT(DISTINCT EmailAddress) AS UnqRowsClick
    FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity] 
    WHERE Action = 'Click'
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
             MessageName,
             Email_Msg_Typ,
             Email_Prod_Cat,
             Action
) audunpvtCl
PIVOT
(
    SUM(UnqRowsClick)
    FOR Action IN ([Click])
) audpvtCl

GROUP BY audpvtCl.Email_Date,
         audpvtCl.Audience,
         audpvtCl.MessageName,
         audpvtCl.Email_Msg_Typ,
         audpvtCl.Email_Prod_Cat


UNION ALL

SELECT audpvtCl.Email_Date,
       audpvtCl.Audience,
       audpvtCl.MessageName,
       audpvtCl.Email_Msg_Typ,
       audpvtCl.Email_Prod_Cat,
       SUM(audpvtCl.[campaign_clicked]) Unique_Clickers
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
           ChannelAction AS Action,
           COUNT(DISTINCT ContactValue) AS UnqRowsClick
    FROM [$(databricks)].[retail_marketing].[marketingactivity] 
    WHERE
          ChannelAction = 'campaign_clicked'
          AND
          CampaignType IN ( 'trigger' )
 
    GROUP BY CAST(CAST(ActivityDateTimeUtc AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActivityDateTimeUtc) AS FLOAT) / 24 ,
             CASE
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

GROUP BY audpvtCl.Email_Date,
         audpvtCl.Audience,
         audpvtCl.MessageName,
         audpvtCl.Email_Msg_Typ,
         audpvtCl.Email_Prod_Cat;

    