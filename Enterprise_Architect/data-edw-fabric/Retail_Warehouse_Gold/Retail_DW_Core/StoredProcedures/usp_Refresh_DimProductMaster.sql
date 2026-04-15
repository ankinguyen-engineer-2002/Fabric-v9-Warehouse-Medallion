CREATE PROCEDURE [Retail_DW_Core].[usp_Refresh_DimProductMaster]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Refresh_DimProductMaster';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'DimProductMaster';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY
		
		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(ProductKey),0) FROM [Retail_DW_Core].[DimProductMaster]);

		UPDATE	dst
		SET dst.SKUName = CASE WHEN dst.SpecialOrderFlag = 1 AND dst.IsMaster = 0 THEN dst.SKUName
							ELSE src.SKUName END
			, dst.VendorModelNumber = CASE WHEN dst.SpecialOrderFlag = 1 AND dst.IsMaster = 0 THEN dst.VendorModelNumber
										ELSE src.VendorModelNumber END
			, dst.VendorID = src.VendorID
			, dst.GroupID = COALESCE(src.GroupID, '<No Value>')
			, dst.ListPrice = src.ListPrice
			, dst.SalePrice = src.SalePrice
			, dst.ReplacementCost = src.ReplacementCost
			, dst.LandedCost = src.LandedCost
			, dst.AverageLandedCost = src.AverageLandedCost
			, dst.PurchaseStatus = src.PurchaseStatus
			, dst.ProductStatus = src.ProductStatus
			, dst.SeriesID = src.SeriesID
			, dst.Depth = src.Depth
			, dst.Height = src.Height
			, dst.Width = src.Width
			, dst.StorageDepth = src.StorageDepth
			, dst.StorageHeight = src.StorageHeight
			, dst.StorageWidth = src.StorageWidth
			, dst.CubicFeet = src.CubicFeet
			, dst.DeliveryVolume = src.DeliveryVolume
			, dst.UnloadTime = src.UnloadTime
			, dst.SubGroupID = src.SubGroupID
			, dst.SubGroupName = src.SubGroupName
			, dst.CollectionName = src.CollectionName
			, dst.PPPGroupID = src.PPPGroupID
			, dst.ProductTypeID = src.ProductTypeID
			, dst.DateChanged = src.DateChanged
			, dst.IsKit = src.IsKit
			, dst.DefaultStoreBrandID = src.StoreBrandID
			, dst.StoreBrandID = src.StoreBrandID
			, dst.InventoryManagementStatusID = src.InventoryManagementStatusID
			, dst.VendorStyleID = src.VendorStyleID
			, dst.DominantProductID = src.DominantProductID
			, dst.PricePointSegmentation = src.PricePointSegmentation
			, dst.PricePoint = src.PricePoint
			, dst.ProductStatusDate = src.ProductStatusDate
			, dst.VendorStyle = src.VendorStyle
			, dst.InventoryTierID = src.InventoryTierID
			, dst.AverageCost = src.AverageCost
			, dst.CommCostAddonPercent = src.CommCostAddonPercent
			, dst.ServiceProductTypeID = src.ServiceProductTypeID
			, dst.PurchaseStatusCodeID = src.PurchaseStatusCodeID
			, dst.ItemCommCategory = src.ItemCommCategory
			, dst.IsDiscountable = src.IsDiscountable
		FROM [$(Retail_Warehouse)].[MasterData_Product_Enh].[ProductInfo] AS src
		INNER JOIN [Retail_DW_Core].[DimProductMaster] AS dst 
		ON src.SKU = dst.SKU;

		INSERT INTO [Retail_DW_Core].[DimProductMaster]
		(
			ProductKey
			, SKU
			, AFISKU
			, SKUName
			, VendorModelNumber
			, VendorID
			, GroupID
			, SubGroupID
			, SubGroupName
			, PPPGroupID
			, CollectionID
			, CollectionName
			, ListPrice
			, SalePrice
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
			, ProductTypeID
			, DateCreated
			, DateChanged
			, ProductCollectionLifestyle
			, IsKit
			, IsMaster
			, DefaultStoreBrandID
			, InventoryManagementStatusID
			, VendorStyleID
			, DominantProductID
			, PricePointSegmentation
			, PricePoint
			, ProductStatusDate
			, VendorStyle
			, InventoryTierID
			, AverageCost
			, CommCostAddonPercent
			, ServiceProductTypeID
			, PurchaseStatusCodeID
			, ItemCommCategory
			, RecordType
			, FinanceUseFee
			, IsDiscountable
		)

		SELECT	
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY wpm.SKU) AS BIGINT) AS ProductKey
			, wpm.SKU
			, wpm.AFISKU
			, wpm.SKUName
			, wpm.VendorModelNumber
			, wpm.VendorID
			, COALESCE(wpm.GroupID, '<No Value>') AS GroupID
			, wpm.SubGroupID
			, wpm.SubGroupName
			, wpm.PPPGroupID
			, wpm.CollectionID
			, wpm.CollectionName
			, wpm.ListPrice
			, wpm.SalePrice
			, wpm.ReplacementCost
			, wpm.LandedCost
			, wpm.AverageLandedCost
			, wpm.StoreBrandID
			, wpm.PurchaseStatus
			, wpm.ProductStatus
			, wpm.SeriesID
			, wpm.Depth
			, wpm.Height
			, wpm.Width
			, wpm.StorageDepth
			, wpm.StorageHeight
			, wpm.StorageWidth
			, wpm.CubicFeet
			, wpm.DeliveryVolume
			, wpm.UnloadTime
			, wpm.SpecialOrderFlag
			, wpm.ProductTypeID
			, wpm.DateCreated
			, wpm.DateChanged
			, wpm.ProductCollectionLifestyle
			, wpm.IsKit
			, CASE WHEN pm.SKU IS NULL THEN 1 ELSE 0 END AS IsMaster
			, wpm.StoreBrandID
			, wpm.InventoryManagementStatusID
			, wpm.VendorStyleID
			, wpm.DominantProductID
			, wpm.PricePointSegmentation
			, wpm.PricePoint
			, wpm.ProductStatusDate
			, wpm.VendorStyle
			, wpm.InventoryTierID
			, wpm.AverageCost
			, wpm.CommCostAddonPercent
			, wpm.ServiceProductTypeID
			, wpm.PurchaseStatusCodeID
			, wpm.ItemCommCategory
			, wpm.RecordType
			, wpm.FinanceUseFee
			, wpm.IsDiscountable
		FROM [$(Retail_Warehouse)].[MasterData_Product_Enh].[ProductInfo] AS wpm
		LEFT OUTER JOIN [Retail_DW_Core].[DimProductMaster] pm 
		ON wpm.SKU = pm.SKU 
		AND pm.IsMaster = 1
		WHERE wpm.SKU NOT IN 
		(
			SELECT SKU 
			FROM [Retail_DW_Core].[DimProductMaster] AS pm 
			WHERE pm.SKU = wpm.SKU 
			AND ISNULL(pm.StoreBrandID, 'TDSG') = ISNULL(wpm.StoreBrandID, 'TDSG')
		);

		UPDATE	pm
		SET pm.CubicFeet = gm.Cubes
		FROM [Retail_DW_Core].[DimProductMaster] pm
		INNER JOIN [Retail_DW_Core].[DimGroupMaster] gm 
		ON pm.GroupID = gm.GroupID
		WHERE (pm.CubicFeet IS NULL OR pm.CubicFeet = 0.00)
		AND (gm.Cubes <> 0.00);

		SET @DateValue = GETDATE();

		SELECT
			@DateValue = CSTDateValue
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, 'Process Complete'
		);

		--- Update last modified in Table Dictionary 
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable
	
	END TRY

	BEGIN CATCH
        
		DECLARE
			@ErrorMessage  VARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState    INT;

		SET @ErrorMessage = ERROR_MESSAGE();
		SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
		SET @ErrorState = ISNULL(ERROR_STATE(), 0);
		SET @DateValue = GETDATE();

		SELECT
			@DateValue = CSTDateValue
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, @ErrorMessage
		);

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	END CATCH

END