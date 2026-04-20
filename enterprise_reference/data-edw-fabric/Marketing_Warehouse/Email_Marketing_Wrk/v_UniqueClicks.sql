

CREATE VIEW [Email_Marketing_Wrk].[v_UniqueClicks]
AS
SELECT A.Audience AS Audience,
       MessageName,
       SUM(A.UniqueClickers) UniqueClickers,
       SUM(A.UniqueOpen) UniqueOpeners
FROM
(
    SELECT Audience,
           MessageName,
           CASE
               WHEN Action = 'Click' THEN
                   COUNT(DISTINCT EmailAddress)
               ELSE
                   0
           END UniqueClickers,
           CASE
               WHEN Action = 'Open' THEN
                   COUNT(DISTINCT EmailAddress)
               ELSE
                   0
           END UniqueOpen
    FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity] a
    GROUP BY Audience,
             Action,
             MessageName
) A
GROUP BY Audience,
         MessageName

UNION ALL


SELECT A.Audience AS Audience,
       MessageName,
       SUM(A.UniqueClickers) UniqueClickers,
       SUM(A.UniqueOpen) UniqueOpeners
FROM
(
    SELECT Audience,
           CampaignName AS MessageName,
           CASE
               WHEN ChannelAction = 'campaign_clicked' THEN
                   COUNT(DISTINCT ContactValue)
               ELSE
                   0
           END UniqueClickers,
           CASE
               WHEN ChannelAction = 'campaign_opened' THEN
                   COUNT(DISTINCT ContactValue)
               ELSE
                   0
           END UniqueOpen
    FROM [$(databricks)].[retail_marketing].[marketingactivity] a
    GROUP BY Audience,
             ChannelAction,
             CampaignName
) A
GROUP BY Audience,
         MessageName



