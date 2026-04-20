-- Auto Generated (Do not modify) 656384704B6788CAA9B43F6062CE02ED3108372D26525DBA889639FDBDCE4FDA
CREATE   VIEW [Retail_DW_Core_Wrk].[v_Leads] AS

SELECT 
    u.LocationId,
    u.StaffId AS SalePersonID,
    r.FullName AS LeadName,
    r.Email AS email, -- CHANGED: Use Email from Relationship table (check if col is 'Email' or 'EmailAddress')
    r.CustomerId,
    r.PhoneNumber,
    r.RelationshipId,
    CONVERT(DATE, ch.DateCreated) AS DateCreated,
    ra.StorisAppUserId,
    r.CartId,
    ch.DateCreated AS Cart_DateCreated,
    r.DateCreated AS rDateCreated,
    CONVERT(DATE, COALESCE(ch.DateUpdated, ch.DateCreated)) AS Cart_Updated,
    ch.DateUpdated
FROM [$(Source_Data)].[Retail_Corporate].[Relationship] r
    INNER JOIN [$(Source_Data)].[Retail_Corporate].[Relationship_Assignee] ra 
        ON r.RelationshipId = ra.RelationshipId
    INNER JOIN [$(Source_Data)].[Retail_Corporate].[StorisAppUser] u 
        ON u.StorisAppUserId = ra.StorisAppUserId
    INNER JOIN [$(Source_Data)].[Retail_Dart].[CartHeader] ch 
        ON ch.ID = r.CartId
    -- REMOVED: LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Customer] c 
WHERE 1=1  
    -- CHANGED: Filter on Relationship table email, not Customer table email
    AND (r.Email IS NOT NULL OR r.PhoneNumber IS NOT NULL) 
    AND r.CartId IS NOT NULL
    AND r.FullName IS NOT NULL
    AND r.DateCreated >= '2024-01-01'
    AND u.StaffId NOT IN ('ZZZ', 'STOP')
    AND r.RecStatus <> 'D';