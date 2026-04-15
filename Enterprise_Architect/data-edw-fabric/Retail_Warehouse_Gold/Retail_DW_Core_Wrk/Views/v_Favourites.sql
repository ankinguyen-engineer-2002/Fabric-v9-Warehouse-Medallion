-- Auto Generated (Do not modify) E40D4D910D7A4ABA5537B544544A91A1322E57A28EBFF0AE98479CC0F16ABE3D
CREATE      VIEW [Retail_DW_Core_Wrk].[v_Favourites] AS

SELECT 
    rel.RelationshipId,
    rel.CustomerId,
    rel.FullName,
    rel.Email,
   rel.PhoneNumber AS PhoneNumber,
    CONVERT(DATE, ch.DateCreated) AS DateCreated,
    rel.CartId,
    rel.DateCreated AS rDateCreated,
    ch.CartNumber,
    cd.ProductID,
    cd.Quantity
FROM [Retail_DW_Core].[Relationship] rel
INNER JOIN [Retail_DW_Core].[CartHeader] ch 
    ON rel.CartId = ch.ID
LEFT JOIN [Retail_DW_Core].[CartDetail] cd 
    ON ch.CartNumber = cd.CartNumber
WHERE 1=1  
    AND (rel.PhoneNumber IS NOT NULL OR rel.Email IS NOT NULL)
    AND rel.CartId IS NOT NULL
    AND rel.FullName IS NOT NULL
    AND rel.RecStatus <> 'D'
    AND rel.DateCreated >= '2026-01-01'