-- Auto Generated (Do not modify) D8C3EC92ABF08C96A81C6E47174F178EC6E956C386E204DB582964FDACDA9775
CREATE VIEW [MasterData_Product_Wrk].[v_ProductInfo]
AS
WITH CTE_Product AS
(
	SELECT
		pd.ProductID AS SKU
		, CASE WHEN LEFT(pd.ProductID,5) = 'AFHS-' THEN RIGHT(pd.ProductID, LEN(pd.ProductID)-5)
			ELSE '' END AS AFISKU
		, pd.Description1 AS SKUDescription1
		, pd.Description2 AS SKUDescription2
		, CASE WHEN pd.Description2 IS NULL THEN pd.Description1 ELSE pd.Description1 + ' ' + pd.Description2 END AS SKUName
		, pd.VEND_PROD_NO AS VendorModelNumber
		, pd.Vendor_ID AS VendorID
		, pd.Selling_Price AS SalePrice
		, pd.Selling_Price AS ListPrice
		, pd.REP_COST AS ReplacementCost
		, pd.Landed_Cost AS LandedCost
		, pd.Lnd_Avg_Cost AS AverageLandedCost
		, pd.StoreBrand_ID AS StoreBrandID
		, pd.OBSStatus_ID AS PurchaseStatus
		, pd.Status_ID AS ProductStatus
		, pd.Series_ID AS SeriesID
		, pd.DEPTH AS Depth
		, pd.Length AS Height
		, pd.WIDTH AS Width
		, pd.CartonDepth AS StorageDepth
		, pd.CartonHeight AS StorageHeight
		, pd.CartonWidth AS StorageWidth
		, pd.CUBIC_FEET AS CubicFeet
		, pd.DeliveryVolume
		, CAST(CAST(pd.UNLOAD_TIME AS VARCHAR(8)) AS DATETIME2(3)) AS UnloadTime
		, CASE WHEN pd.SPEC_ORD = 'Y' THEN 1 ELSE 0 END AS SpecialOrderFlag
		, pd.Group_ID AS GroupID
		, pd.SubgroupID AS SubGroupID
		, NULL AS SubGroupName
		, pd.PPPGroup AS PPPGroupID
		, NULL AS CollectionID
		, NULL AS CollectionName
		, NULL AS ProductCollectionLifestyle
		, CAST(pd.Prod_Type AS INT) AS ProductTypeID
		, NULL AS ServiceProductTypeID
		, pd.InventoryManagementStatusID
		, pd.InvTier_ID AS InventoryTierID
		, NULL AS AverageCost
		, cd.ComDsc AS CommonDescription
		, pd.OBSStatus_ID AS PurchaseStatusCodeID
		, pd.Comission_Cat AS ItemCommCategory
		, pd.CommissionPercent AS CommCostAddonPercent
		, CASE WHEN pd.Discountable = 0 THEN 'N' ELSE 'Y' END AS IsDiscountable
		, NULL AS IsMaster
		, pd.DATE_CREATED AS DateCreated
		, pd.DATE_UPDATED AS DateChanged
	FROM [$(Source_Data)].[Retail_Miniapps].[Product] pd
	LEFT OUTER JOIN [$(Source_Data)].[Retail_Miniapps].[CommonDesc] cd
	ON cd.CommDesc_ID = pd.CommDesc_ID
	AND cd.Group_ID = pd.Group_ID
	AND cd.StoreBrand_ID = pd.StoreBrand_ID

	UNION ALL

	SELECT
		p.ProductID AS SKU
		, CASE WHEN LEFT(p.ProductID,5) = 'AFHS-' THEN RIGHT(p.ProductID, LEN(p.ProductID)-5)
		  ELSE '' END AS AFISKU
		, p.Description AS SKUDescription1
		, p.Description2 AS SKUDescription2
		, CASE WHEN p.Description2 IS NULL THEN p.Description ELSE p.Description + ' ' + p.Description2 END AS SKUName
		, p.VendorModelNbr AS VendorModelNumber
		, p.VendorID
		, p.CaseSellPrice AS SalePrice
		, p.CaseSellPrice AS ListPrice
		, p.ReplacementCost
		, NULL AS LandedCost
		, NULL AS AverageLandedCost
		, 'TDSG' AS StoreBrandID
		, p.PurchaseStatusID AS PurchaseStatus
		, p.Status AS ProductStatus
		, NULL AS SeriesID
		, p.DepthDimension AS Depth
		, p.HeightDimension AS Height
		, p.WidthDimension AS Width
		, p.StorageDepth
		, p.StorageHeight
		, p.StorageWidth
		, p.CubicFeet
		, p.DeliveryCubicFeet AS DeliveryVolume
		, CAST(CAST(p.UnloadTime AS VARCHAR(8)) AS DATETIME2(3)) AS UnloadTime
		, p.SpecialOrder AS SpecialOrderFlag
		, p.GroupID
		, NULL AS SubGroupID
		, NULL AS SubGroupName
		, NULL AS PPPGroupID
		, NULL AS CollectionID
		, NULL AS CollectionName
		, NULL AS ProductCollectionLifestyle
		, CAST(p.ProductTypeID AS INT) AS ProductTypeID
		, p.ServiceProductTypeID
		, NULL AS InventoryManagementStatusID
		, NULL AS InventoryTierID
		, p.AverageCost
		, p.Description AS CommonDescription
		, p.PurchaseStatusCodeID
		, p.CommCategory AS ItemCommCategory
		, p.CommCostAddonPct AS CommCostAddonPercent
		, CASE WHEN p.Discountable = 0 THEN 'N' ELSE 'Y' END AS IsDiscountable
		, NULL AS IsMaster
		, p.DateCreated
		, p.DateChanged
	FROM [$(Source_Data)].[Retail_Corporate].[Product] p
	WHERE NOT EXISTS
	(
		SELECT 1
		FROM [$(Source_Data)].[Retail_Miniapps].[Product] pm
		WHERE pm.ProductID = p.ProductID
		AND pm.StoreBrand_ID IS NOT NULL
	)
)

, CTE_Final AS
(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY SKU ORDER BY StoreBrandID DESC) RowNum
	FROM CTE_Product
)

SELECT
	SKU
	, AFISKU
	, SKUDescription1
	, SKUDescription2
	, SKUName
	, VendorModelNumber
	, VendorID
	, SalePrice
	, ListPrice
	, ReplacementCost
	, LandedCost
	, AverageLandedCost
	, StoreBrandID
	, PurchaseStatus
	, ProductStatus
	, SeriesID
	, Depth
	, Height
	, Width
	, StorageDepth
	, StorageHeight
	, StorageWidth
	, CubicFeet
	, DeliveryVolume
	, UnloadTime
	, SpecialOrderFlag
	, GroupID
	, SubGroupID
	, SubGroupName
	, PPPGroupID
	, CollectionID
	, CollectionName
	, ProductCollectionLifestyle
	, ProductTypeID
	, ServiceProductTypeID
	, InventoryManagementStatusID
	, InventoryTierID
	, AverageCost
	, CommonDescription
	, PurchaseStatusCodeID
	, ItemCommCategory
	, CommCostAddonPercent
	, IsDiscountable
	, IsMaster
	, DateCreated
	, DateChanged
FROM CTE_Final
WHERE RowNum = 1

UNION ALL
 
SELECT
    'DLVY' AS SKU
    , '' AS AFISKU
    , 'Delivery Charges' AS SKUDescription1
    , NULL AS SKUDescription2
    , 'Delivery Charges' AS SKUName
    , NULL AS VendorModelNumber
    , 'TDSG' AS VendorID
    , NULL AS SalePrice
    , NULL AS ListPrice
    , NULL AS ReplacementCost
    , NULL AS LandedCost
    , NULL AS AverageLandedCost
    , 'TDSG' AS StoreBrandID
    , 'A' AS PurchaseStatus
    , NULL AS ProductStatus
    , NULL AS SeriesID
    , NULL AS Depth
    , NULL AS Height
    , NULL AS Width
    , NULL AS StorageDepth
    , NULL AS StorageHeight
    , NULL AS StorageWidth
    , NULL AS CubicFeet
    , NULL AS DeliveryVolume
    , NULL AS UnloadTime
    , NULL AS SpecialOrderFlag
    , 'DLVY' AS GroupID
    , NULL AS SubGroupID
    , NULL AS SubGroupName
    , NULL AS PPPGroupID
    , NULL AS CollectionID
    , NULL AS CollectionName
    , NULL AS ProductCollectionLifestyle
    , 9999 AS ProductTypeID
    , NULL AS ServiceProductTypeID
    , NULL AS InventoryManagementStatusID
    , NULL AS InventoryTierID
    , NULL AS AverageCost
    , NULL AS CommonDescription
    , 'A' AS PurchaseStatusCodeID
    , NULL AS ItemCommCategory
    , NULL AS CommCostAddonPercent
    , NULL AS IsDiscountable
    , 1 AS IsMaster
    , CAST('2023-12-31 00:00:00.000' AS DATETIME2(3)) AS DateCreated
    , CAST(NULL AS DATETIME2(3)) AS DateChanged;