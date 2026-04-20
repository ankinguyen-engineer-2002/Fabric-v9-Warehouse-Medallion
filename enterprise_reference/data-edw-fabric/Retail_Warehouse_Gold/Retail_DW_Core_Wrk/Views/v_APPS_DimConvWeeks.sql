-- Auto Generated (Do not modify) 2BC26786826227C889921DA7D7ED2F720A3585F61F123F6E96B1F6177AEC7DFE
/*
2025-08-21 || Harshit S:  Created View
*/

CREATE     VIEW [Retail_DW_Core_Wrk].[v_APPS_DimConvWeeks] AS

SELECT Week
FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14)) AS ConvWeeks(Week)