-- Auto Generated (Do not modify) 457A196603FB9085A154599D825E3753B8F3139119FC771EF4AACFDF7A9E8AAD
CREATE   VIEW [Retail_DW_Core_Wrk].[v_Relationship] AS

SELECT 
    [Prefix],
    [RecStatus],
    [RelationshipId],
    [Suffix],
    [UpdatedAt],
    [Last],
    [LastActivity],
    [Middle],
    [PhoneExt],
    [PhoneNumber],
    [PhoneType],
    [DateChanged],
    [DateCreated],
    [DeliveryAddressID],
    [Description],
    [First],
    [FullName],
    [Operation],
    [BillingAddressID],
    [CartId],
    [CreatedAt],
    [CustomerId],
    [Email],           
    [NxtGenBatchId]    
FROM [$(Source_Data)].[Retail_Corporate].[Relationship];