-- Auto Generated (Do not modify) 07873FADF296DB417E34E7CABF892AD15C29AC04AA95BEAE41F42002FDC1B0B8
CREATE   VIEW [Retail_DW_Core_Wrk].[v_StorisAppUser] AS

SELECT 
    [Operation],
    [DateChanged],
    [DateCreated],
    [First],
    [Last],
    [LastLogin],
    [StorisAppUserId],
    [Suffix],
    [UpdatedAt],
    [LocationId],
    [Middle],
    [Prefix],
    [RecStatus],
    [SalespersonId],
    [StaffId]
FROM [$(Source_Data)].[Retail_Corporate].[StorisAppUser];