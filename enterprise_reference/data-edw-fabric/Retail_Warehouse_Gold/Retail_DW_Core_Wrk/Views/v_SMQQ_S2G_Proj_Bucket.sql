-- Auto Generated (Do not modify) 7E8F97988E281B7DF43123DB8797201044981927CC3CE0F7F69D02E0F0FD469C
/* 
09/09/2025 || Harshit S: Created View
*/
CREATE       VIEW [Retail_DW_Core_Wrk].[v_SMQQ_S2G_Proj_Bucket] AS

SELECT DISTINCT
    r.RollUp,
    lm.LocationID

FROM [Retail_DW_Core].[DimRollUps] r
CROSS JOIN [Retail_DW_Core].[SMQQ_FactLocationMaster] lm
WHERE r.RollUpFilter = 'Division'