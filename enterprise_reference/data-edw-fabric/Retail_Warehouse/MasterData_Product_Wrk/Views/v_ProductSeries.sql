-- Auto Generated (Do not modify) 3195A7E5B97B3D67C92D93BFA07BE187C63D90ED1A6C49E52502114FBD6B633C
CREATE VIEW [MasterData_Product_Wrk].[v_ProductSeries]
AS
SELECT
	sm.Series_ID AS SeriesID
	, sm.LifeStyle_ID AS LifeStyleID
	, sm.Group_ID AS GroupID
	, sm.StoreBrand_ID AS StoreBrandID
	, sm.dominant_product_id AS DominantProductID
	, sm.PricePointSegmentation
	, ls.LifeStyle_Desc AS LifeStyleDescription
	, sm.Vendor_ID AS VendorID
	, sm.Vendor_Style AS VendorStyle
	, sm.VendorStyle_ID AS VendorStyleID
FROM [$(Source_Data)].[Retail_Miniapps].[SeriesMaster] sm
LEFT OUTER JOIN [$(Source_Data)].[Retail_Miniapps].[LifeStyle] ls
ON sm.LifeStyle_ID = ls.LifeStyle_ID;