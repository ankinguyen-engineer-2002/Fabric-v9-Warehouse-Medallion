CREATE VIEW [MasterData_Product_Wrk].[v_ProductGroup]
AS
SELECT
	cat.CategoryID
	, cat.Description AS CategoryDescription
	, grp.GroupID
	, grp.Description AS GroupDescription
	, cat.Family AS FamilyName
	, 1 AS PrimaryCategory
	, ppp.DefaultPPPGroupID
	, grp.Cubes
FROM [$(Source_Data)].[Retail_Corporate].[Groups] grp
INNER JOIN [$(Source_Data)].[Retail_Corporate].[Category] cat
ON grp.CategoryID = cat.CategoryID
LEFT JOIN [$(Source_Data)].[Retail_ExternalFiles].[DeafaultPPPGroupID] ppp
ON ppp.GroupID = grp.GroupID 
AND ppp.CategoryID = cat.CategoryID

UNION ALL

SELECT
	'DLVY' AS CategoryID
	, 'Delivery Fees' AS CategoryDescription
	, 'DLVY' AS GroupID
	, 'Delivery Fees' AS GroupDescription
	, 'OTHER' AS FamilyName
	, 0 AS PrimaryCategory
	, NULL AS DefaultPPPGroupID
	, NULL AS Cubes

UNION ALL

SELECT
	'Payments' AS CategoryID
	, 'Payment' AS CategoryDescription
	, 'OFIN' AS GroupID
	, 'Other Financing' AS GroupDescription
	, 'Financing' AS FamilyName
	, 1 AS PrimaryCategory
	, NULL AS DefaultPPPGroupID
	, NULL AS Cubes;