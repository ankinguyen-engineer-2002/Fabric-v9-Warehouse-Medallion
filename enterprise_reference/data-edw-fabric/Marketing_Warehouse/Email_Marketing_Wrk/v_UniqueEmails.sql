
CREATE VIEW [Email_Marketing_Wrk].[v_UniqueEmails]
AS
SELECT YEAR(ActionTimestamp) [Year],
       MONTH(ActionTimestamp) [Month],
       DATEPART(WEEK, ActionTimestamp) [Week],
       'Promotional' AS Type,
       MessageName,
       Audience,
       Email_Prod_Cat,
       COUNT(DISTINCT EmailAddress) emails
  FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity]
WHERE Email_Msg_Typ IN ( 'PROMOTIONAL', 'N/A' )
GROUP BY YEAR(ActionTimestamp),
         MONTH(ActionTimestamp),
         DATEPART(WEEK, ActionTimestamp),
         MessageName,
         Audience,
         Email_Prod_Cat
UNION ALL
SELECT YEAR(ActionTimestamp) [Year],
       MONTH(ActionTimestamp) [Month],
       DATEPART(WEEK, ActionTimestamp) [Week],
       'Transactional' AS Type,
       MessageName,
       Audience,
       Email_Prod_Cat,
       COUNT(DISTINCT EmailAddress) emails
 FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity]
WHERE (
          Email_Msg_Typ IN ( 'TRIGGER', 'TRANSACTIONAL' )
          OR Email_Msg_Typ IS NULL
      )
GROUP BY YEAR(ActionTimestamp),
         MONTH(ActionTimestamp),
         DATEPART(WEEK, ActionTimestamp),
         MessageName,
         Audience,
         Email_Prod_Cat

UNION ALL

SELECT YEAR(ActivityDateTimeUtc) [Year],
       MONTH(ActivityDateTimeUtc) [Month],
       DATEPART(WEEK, ActivityDateTimeUtc) [Week],
       'Promotional' AS Type,
       CampaignName AS MessageName,
       Audience,
       CampaignTags AS Email_Prod_Cat,
       COUNT(DISTINCT ContactValue) emails
  FROM [$(databricks)].[retail_marketing].[marketingactivity]
WHERE CampaignType IN ( 'manual' )
GROUP BY YEAR(ActivityDateTimeUtc),
         MONTH(ActivityDateTimeUtc),
         DATEPART(WEEK, ActivityDateTimeUtc),
         CampaignName,
         Audience,
         CampaignTags 
UNION ALL
SELECT YEAR(ActivityDateTimeUtc) [Year],
       MONTH(ActivityDateTimeUtc) [Month],
       DATEPART(WEEK, ActivityDateTimeUtc) [Week],
       'Transactional' AS Type,
       CampaignName AS MessageName,
       Audience,
       CampaignTags AS Email_Prod_Cat,
       COUNT(DISTINCT ContactValue) emails
 FROM [$(databricks)].[retail_marketing].[marketingactivity]
WHERE  CampaignType IN ( 'trigger' )

GROUP BY YEAR(ActivityDateTimeUtc),
         MONTH(ActivityDateTimeUtc),
         DATEPART(WEEK, ActivityDateTimeUtc),
         CampaignName,
         Audience,
         CampaignTags

