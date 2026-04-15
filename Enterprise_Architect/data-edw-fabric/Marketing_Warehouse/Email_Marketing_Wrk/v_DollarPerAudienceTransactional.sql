CREATE VIEW [Email_Marketing_Wrk].[v_DollarPerAudienceTransactional]
AS 
SELECT CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24  Email_Date,
       CASE
           WHEN Audience IS NULL THEN
               'No Segment-RTM Emails'
           ELSE Audience
		   END AS Audience,Email_Prod_Cat,MessageName,COUNT(DISTINCT EmailAddress) Unique_Emails,
       SUM(CAST(ConversionAmount AS FLOAT)) Revenue
FROM [$(databricks)].[retail_marketing].[epsilonmarketingactivity]
WHERE Email_Msg_Typ IN ( 'TRIGGER', 'TRANSACTIONAL' ) OR Email_Msg_Typ IS NULL
GROUP BY CAST(CAST(ActionTimestamp AS DATE) AS DATETIME) + CAST(DATEPART(HOUR, ActionTimestamp) AS FLOAT) / 24 ,
         CASE
         WHEN Audience IS NULL THEN
         'No Segment-RTM Emails'
         ELSE
         Audience
         END,
         Email_Prod_Cat,
         MessageName