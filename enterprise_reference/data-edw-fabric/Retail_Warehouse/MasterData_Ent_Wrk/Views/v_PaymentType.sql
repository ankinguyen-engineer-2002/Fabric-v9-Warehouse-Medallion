-- Auto Generated (Do not modify) 242FDC8E4D32E32C756343E540A7C0590BE5653357FF9A8B41DB3E7CA3DF7210
CREATE VIEW [MasterData_Ent_Wrk].[v_PaymentType]
AS
SELECT
    CAST(pt.ID AS VARCHAR(50)) AS PaymentTypeID
    , CAST(pt.NAME AS VARCHAR(50)) AS PaymentTypeName
    , CAST(pt.CLASS AS VARCHAR(50)) AS PaymentClass
    , pt.FR_USE_FEE AS FinanceUseFee
    , pt.MULT AS IsFinanced
    , pt.TIER_LEVEL AS PaymentTierLevel
    , vp.FinanceProviderID AS VendorID
    , vp.FinanceProviderName
    , pt.PAYMENTTYPE_SUBGROUPID AS PaymentTypeSubGroupID
    , sg.PaymentTypeSubGroupName
    
    -- New TermsDuration field
    , CASE WHEN pt.NAME LIKE '% 36 %' THEN '36'
    WHEN pt.NAME LIKE '% 60 %' THEN '60'
    WHEN pt.NAME LIKE '% 96 %' THEN '96'
    WHEN pt.NAME LIKE '% 6 %' OR pt.NAME LIKE '% 6M %' THEN '6'
    WHEN pt.NAME LIKE '% 12 %' OR pt.NAME LIKE '% 12M %' THEN '12'
    WHEN pt.NAME LIKE '% 18 %' THEN '18'
    WHEN pt.NAME LIKE '% 48 %' THEN '48'
    WHEN pt.NAME LIKE '% 24 %' THEN '24'
    WHEN pt.NAME LIKE '% 72 %' THEN '72'
    WHEN pt.NAME LIKE '% 0 %' OR pt.NAME LIKE '% 0M %' THEN '0'
    WHEN pt.NAME LIKE '% 84 %' THEN '84'
    ELSE 'Other'
    END AS TermsDuration
    
    -- Updated PaymentTermsGrouping using TermsDuration
    , CASE 
    -- Synchrony with specific months
    WHEN TRIM(vp.FinanceProviderName) = 'SYNCHRONY' AND (pt.NAME LIKE '% 6 %' OR pt.NAME LIKE '% 6M %') THEN 'Synchrony 06M'
    WHEN TRIM(vp.FinanceProviderName) = 'SYNCHRONY' AND (pt.NAME LIKE '% 12 %' OR pt.NAME LIKE '% 12M %') THEN 'Synchrony 12M'
    WHEN TRIM(vp.FinanceProviderName) = 'SYNCHRONY' AND pt.NAME LIKE '% 18 %' THEN 'Synchrony 18M'
    WHEN TRIM(vp.FinanceProviderName) = 'SYNCHRONY' AND pt.NAME LIKE '% 24 %' THEN 'Synchrony 24M'
    WHEN TRIM(vp.FinanceProviderName) = 'SYNCHRONY' AND pt.NAME LIKE '% 36 %' THEN 'Synchrony 36M'
    WHEN TRIM(vp.FinanceProviderName) = 'SYNCHRONY' AND pt.NAME LIKE '% 48 %' THEN 'Synchrony 48M'
    WHEN TRIM(vp.FinanceProviderName) = 'SYNCHRONY' AND pt.NAME LIKE '% 60 %' THEN 'Synchrony 60M'
    WHEN TRIM(vp.FinanceProviderName) = 'SYNCHRONY' AND pt.NAME LIKE '% 72 %' THEN 'Synchrony 72M'
    WHEN TRIM(vp.FinanceProviderName) = 'SYNCHRONY' AND pt.NAME LIKE '% 84 %' THEN 'Synchrony 84M'
    WHEN TRIM(vp.FinanceProviderName) = 'SYNCHRONY' AND pt.NAME LIKE '% 96 %' THEN 'Synchrony 96M'
    WHEN TRIM(vp.FinanceProviderName) = 'SYNCHRONY' THEN 'Synchrony Other'
        
    -- Concora variations
    WHEN TRIM(vp.FinanceProviderName) IN ('GAFCO', 'Concora', 'Genesis', 'GENESIS FINANCING (MAN)', 'GENESIS CREDIT') AND 
    (pt.NAME LIKE '% 0 %' OR pt.NAME LIKE '% 0M %') THEN 'Concora 00M'
    WHEN TRIM(vp.FinanceProviderName) IN ('GAFCO', 'Concora', 'Genesis', 'GENESIS FINANCING (MAN)', 'GENESIS CREDIT') AND 
    (pt.NAME LIKE '% 6 %' OR pt.NAME LIKE '% 6M %') THEN 'Concora 06M'
    WHEN TRIM(vp.FinanceProviderName) IN ('GAFCO', 'Concora', 'Genesis', 'GENESIS FINANCING (MAN)', 'GENESIS CREDIT') AND 
    (pt.NAME LIKE '% 12 %' OR pt.NAME LIKE '% 12M %') THEN 'Concora 12M'
        
    -- Acima variations
    WHEN TRIM(vp.FinanceProviderName) IN ('Progressive', 'Rent A Center', 'Acima', 'Prog', 'Caddi', 'RAC') THEN 'Acima'
        
    -- Synchrony wildcard
    WHEN vp.FinanceProviderName LIKE '%SY%' OR pt.NAME LIKE '%SY%' THEN 'Synchrony Other'
        
    -- Cash
    WHEN sg.PaymentTypeSubGroupName IN ('Other Down Payment', 'Cash', 'Credit Cards') THEN 'Cash'
    ELSE 'Other'
    END AS PaymentTermsGrouping
    
    -- Updated PaymentTypeGroupID using TermsDuration
    , CASE 
    WHEN sg.PaymentTypeSubGroupName IN ('Other Down Payment', 'Cash', 'Credit Cards') THEN 'DP'
    WHEN CASE 
		WHEN pt.NAME LIKE '% 36 %' THEN '36'
		WHEN pt.NAME LIKE '% 60 %' THEN '60'
		WHEN pt.NAME LIKE '% 96 %' THEN '96'
		WHEN pt.NAME LIKE '% 6 %' OR pt.NAME LIKE '% 6M %' THEN '6'
		WHEN pt.NAME LIKE '% 12 %' OR pt.NAME LIKE '% 12M %' THEN '12'
		WHEN pt.NAME LIKE '% 18 %' THEN '18'
		WHEN pt.NAME LIKE '% 48 %' THEN '48'
		WHEN pt.NAME LIKE '% 24 %' THEN '24'
		WHEN pt.NAME LIKE '% 72 %' THEN '72'
		WHEN pt.NAME LIKE '% 0 %' OR pt.NAME LIKE '% 0M %' THEN '0'
		WHEN pt.NAME LIKE '% 84 %' THEN '84'
		ELSE 'Other'
	END IN ('0', '3', '6', '12') THEN 'ST'
    WHEN CASE 
		WHEN pt.NAME LIKE '% 36 %' THEN '36'
		WHEN pt.NAME LIKE '% 60 %' THEN '60'
		WHEN pt.NAME LIKE '% 96 %' THEN '96'
		WHEN pt.NAME LIKE '% 6 %' OR pt.NAME LIKE '% 6M %' THEN '6'
		WHEN pt.NAME LIKE '% 12 %' OR pt.NAME LIKE '% 12M %' THEN '12'
		WHEN pt.NAME LIKE '% 18 %' THEN '18'
		WHEN pt.NAME LIKE '% 48 %' THEN '48'
		WHEN pt.NAME LIKE '% 24 %' THEN '24'
		WHEN pt.NAME LIKE '% 72 %' THEN '72'
		WHEN pt.NAME LIKE '% 0 %' OR pt.NAME LIKE '% 0M %' THEN '0'
		WHEN pt.NAME LIKE '% 84 %' THEN '84'
		ELSE 'Other'
		END IN ('18', '24', '36', '48', '60', '72', '84', '96') THEN 'LT'
    ELSE 'OF'
    END AS PaymentTypeGroupID
    , CASE WHEN pls.PUSTID IN (300, 310, 311) THEN 'STFIN'
    WHEN pls.PUSTID IN (320, 330, 340, 350, 360, 370, 380, 390, 400, 401) THEN 'LTFIN'
    WHEN pls.PUSTID IN (410) THEN 'OFIN'
    ELSE COALESCE(g.PHDSC, 'OPAY')
    END AS GroupID
    , 1 AS RecordType
    , 'TDSG' AS StoreBrandID
    , CAST('1900-01-01' AS DATE) AS StartDate
    , CAST('2999-12-31' AS DATE) AS EndDate
    , pt.DateUpdated
FROM [$(Source_Data)].[Retail_External].[paymenttype] pt
LEFT JOIN 
(
    SELECT
        fpm.FinanceProviderMappingID
        , fp.FinanceProviderID
        , fp.Name
        , fpm.PaymentTypeVendorID
        , COALESCE(fpm.PaymentTypeVendorID, fp.Name) AS FinanceProviderName
        , fpm.Tier
        , fpm.Active
    FROM [$(Source_Data)].[Retail_Corporate].[FinanceProvider] fp
    LEFT OUTER JOIN [$(Source_Data)].[Retail_External].[FinanceProviderMapping] fpm
    ON fpm.FinanceProviderID = fp.FinanceProviderID
) vp 
ON pt.FR_VEND = vp.FinanceProviderID
LEFT OUTER JOIN [$(Source_Data)].[Retail_External].[PaymentTypeSubGroup] sg
ON pt.PAYMENTTYPE_SUBGROUPID = sg.PaymentTypeSubGroupID
LEFT JOIN [$(Source_Data)].[Retail_External].[plslin] pls
ON pls.PUSTID = pt.PLSCD
LEFT JOIN [$(Source_Data)].[Retail_External].[PLSGRP] g
ON g.PHGRP = pls.PUGRP;