-- Auto Generated (Do not modify) 389E5A3D53D53582B7C8F5AF8D6313EC3C0F66D52F9D6153175483605C827450
CREATE   VIEW [Retail_DW_Core_Wrk].[v_Relationship_Assignee] AS

SELECT 
    [Operation],
    [AssigneeId],
    [DateChanged],
    [DateCreated],
    [RecStatus],
    [RelationshipId],
    [StorisAppUserId]
FROM [$(Source_Data)].[Retail_Corporate].[Relationship_Assignee];