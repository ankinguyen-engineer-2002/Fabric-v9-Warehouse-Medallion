-- Auto Generated (Do not modify) 5CF828689FE4C16DAFE7C2B690674312F893341815B0649829DFE12C9B08D120
CREATE   VIEW [Retail_DW_Core_Wrk].[v_RelationshipActivities] AS

SELECT 
    [Operation],
    [RelationshipId],
    [FullName],
    [Email],
    [PhoneNumber],
    [CartId],
    [StaffIDs],
    [LocationId],
    [CustomerId],
    [LastActivity],
    [LeadLastActivity],
    [DateCreated],
    [DateModified],
    [StaffId]
FROM [$(Source_Data)].[Retail_Dart].[RelationshipActivities];