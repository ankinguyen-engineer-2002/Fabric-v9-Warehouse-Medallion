-- Auto Generated (Do not modify) 56D42A311456B3DA8038F5F80D38AE2DF2D16D32F75FF6218EB564BFD7CF2B11
CREATE   VIEW [Retail_DW_Core_Wrk].[v_LeadAppointments] AS

SELECT 
    u.LocationId,
    u.StaffId AS SalePersonID,
    pu.user_name,
    astg.Description AS ApptType,
    a.Subject,
    astg.Status,
    CONVERT(DATE, a.DateCreated) AS DateCreated,
    CASE 
        WHEN a.DueDate IS NULL THEN NULL
        WHEN CONVERT(DATE, a.DueDate) <= '1899-12-30' THEN NULL  -- Invalid dates become NULL
        WHEN CONVERT(DATE, a.DueDate) >= '9999-12-31' THEN NULL  -- Invalid dates become NULL
        ELSE DATEADD(DAY, -1, CONVERT(DATE, a.DueDate))
    END AS DueDate, /* UTC minus 1 Sec. Need to be adjust in the ETL from NextGen to DW. JCO */
    a.ActivityId,
    r.RelationshipId,
    r.Email,
    r.CustomerId,
    c.FullName AS CustomerName
FROM [$(Source_Data)].[Retail_Corporate].[Activity] a
    INNER JOIN [$(Source_Data)].[Retail_Corporate].[ActivityStage] astg 
        ON astg.ActivityStageId = a.ActivityStageId
    INNER JOIN [$(Source_Data)].[Retail_Corporate].[StorisAppUser] u 
        ON u.StorisAppUserId = a.StorisAppUserId
    LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Relationship] r 
        ON r.RelationshipId = a.RelationshipId
    LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Customer] c 
        ON c.CustomerID = r.CustomerId
    LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[Portal_Users] pu 
        ON pu.user_id = u.StaffId
WHERE 1=1
    AND astg.Description LIKE 'Appointment%'
    AND a.RecStatus <> 'D'
    AND CONVERT(DATE, a.DateCreated) > '2024-04-15';