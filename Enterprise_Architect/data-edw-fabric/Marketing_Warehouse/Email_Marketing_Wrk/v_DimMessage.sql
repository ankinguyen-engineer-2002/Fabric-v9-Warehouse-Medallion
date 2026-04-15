CREATE VIEW [Email_Marketing_Wrk].v_DimMessage
AS
    SELECT DISTINCT
           MessageName,
           DeviceCategory,
           DeviceType,
           EventName,
           Email_Prod_Cat,
           Audience,
           ConversionCategory,
           ConversionSubcategory,
           CASE
               WHEN Email_Msg_Typ IN (
                                         'PROMOTIONAL', 'N/A'
                                     )
                   THEN
                   'Promotional'
               ELSE
                   'Transactional'
           END                                                                                            AS Type,
           YEAR(ActionTimestamp)                                                                          AS [Year],
           MONTH(ActionTimestamp)                                                                         AS [Month],
           DATEPART(WEEK, ActionTimestamp)                                                                AS [Week],
           CONCAT(YEAR(ActionTimestamp), CONCAT(MONTH(ActionTimestamp), DATEPART(WEEK, ActionTimestamp))) AS DateKey,
           CAST(ActionTimestamp AS DATE)                                                                  AS Date
    FROM
           [$(databricks)].[retail_marketing].[epsilonmarketingactivity]
    WHERE
           Email_Msg_Typ IN (
                                'TRIGGER', 'TRANSACTIONAL', 'PROMOTIONAL', 'N/A'
                            )
           OR Email_Msg_Typ IS NULL


UNION ALL

    SELECT DISTINCT
           CampaignName AS MessageName,
           DeviceCategory,
           DeviceType,
           '' AS EventName,
           CampaignTags AS Email_Prod_Cat,
           Audience,
           '' AS ConversionCategory,
           '' AS ConversionSubcategory,
           CASE
               WHEN CampaignType IN ('manual')
                   THEN
                   'Promotional'
               ELSE
                   'Transactional'
           END                                                                                                AS Type,
           YEAR(ActivityDateTimeUtc)                                                                          AS [Year],
           MONTH(ActivityDateTimeUtc)                                                                         AS [Month],
           DATEPART(WEEK, ActivityDateTimeUtc)                                                                AS [Week],
           CONCAT(YEAR(ActivityDateTimeUtc), CONCAT(MONTH(ActivityDateTimeUtc), DATEPART(WEEK, ActivityDateTimeUtc))) AS DateKey,
           CAST(ActivityDateTimeUtc AS DATE)                                                                  AS Date
    FROM
           [$(databricks)].[retail_marketing].[marketingactivity]
    WHERE    
           CampaignType IN ('manual', 'trigger') 