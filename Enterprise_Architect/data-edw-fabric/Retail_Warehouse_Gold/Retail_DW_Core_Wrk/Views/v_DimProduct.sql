-- Auto Generated (Do not modify) D5E480661BBDAF38935E393345923E65E34883BC5E1464CACD48991C9DB76EED
CREATE   VIEW [Retail_DW_Core_Wrk].[v_DimProduct]
AS
SELECT
	pm.ProductKey
	, pm.SKU
	, pm.AFISKU
	, pm.StoreBrandID AS ProductBrandID
	, pm.SKUName
	, pm.VendorModelNumber
	, pm.VendorID
	, pm.VendorStyle
	, vm.VendorName
	, gm.GroupID
	, gm.CategoryID
	, gm.PrimaryCategory
	, pm.SubGroupID
	, pm.SubGroupName
	, pm.CollectionID
	, pm.CollectionName
	, pm.ListPrice
	, pm.SalePrice
	, pm.ReplacementCost
	, pm.PurchaseStatus
	, pm.ProductStatus
	, pm.SeriesID
	, pm.PPPGroupID
	, pm.ProductCollectionLifestyle
	, pm.VendorStyleID
	, pm.PricePointSegmentation
	, pm.PricePoint
	, pm.ProductStatusDate AS DespisedDate
	, pm.CubicFeet
	, pm.SpecialOrderFlag
FROM [Retail_DW_Core].[DimProductMaster] pm
INNER JOIN [Retail_DW_Core].[DimGroupMaster] gm
ON gm.GroupID = pm.GroupID
LEFT JOIN [Retail_DW_Core].[DimVendorMaster] vm
ON vm.VendorID = pm.VendorID;