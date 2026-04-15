CREATE PROCEDURE [MasterData_Product_Enh].[usp_Refresh_ProductInfo]
AS

BEGIN 

	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_Product_Enh.usp_Refresh_ProductInfo';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_Product_Enh'
	SET @DestinationTable = 'ProductInfo';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		TRUNCATE TABLE [MasterData_Product_Enh].[ProductInfo]

		INSERT INTO [MasterData_Product_Enh].[ProductInfo]
		(
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
		FROM [MasterData_Product].[ProductInfo]
	
		UPDATE pr
		SET pr.CommCostAddonPercent = src.CommCostAddonPct
			, pr.ServiceProductTypeID = src.ServiceProductTypeID
		FROM [MasterData_Product_Enh].[ProductInfo] pr
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Product] src
		ON src.ProductID = pr.SKU;

		UPDATE	[MasterData_Product_Enh].[ProductInfo]
		SET PPPGroupID = gm.DefaultPPPGroupID
		FROM [MasterData_Product_Enh].[ProductInfo] AS wpm
		INNER JOIN [MasterData_Product].[ProductGroup] AS gm 
		ON gm.GroupID = wpm.GroupID
		WHERE (gm.DefaultPPPGroupID <> wpm.PPPGroupID)
		OR (wpm.PPPGroupID IS NULL AND gm.DefaultPPPGroupID IS NOT NULL);

		UPDATE	wpm
		SET wpm.VendorStyleID = sm.VendorStyleID
			, wpm.VendorStyle = sm.VendorStyle
			, wpm.DominantProductID = sm.DominantProductID
			, wpm.PricePointSegmentation = sm.PricePointSegmentation
		FROM [MasterData_Product_Enh].[ProductInfo] wpm
		INNER JOIN [MasterData_Product].[ProductSeries] sm 
		ON wpm.SeriesID = sm.SeriesID;

		/*New/Changed Product of an existing Series*/
		UPDATE dst
		SET dst.PricePoint = src.ListPrice
		FROM [MasterData_Product_Enh].[ProductInfo] dst
		INNER JOIN [MasterData_Product].[ProductInfo] src 
		ON src.SKU = dst.DominantProductID
		WHERE src.IsMaster = 1;

		/*New Product of a new Series*/
		UPDATE dst
		SET dst.PricePoint = src.ListPrice
		FROM [MasterData_Product_Enh].[ProductInfo] dst
		INNER JOIN [MasterData_Product].[ProductInfo] src 
		ON src.SKU = dst.DominantProductID;

		UPDATE wpm
		SET wpm.ProductStatusDate = p.Mfr_Disco_Date
			, wpm.IsKit = CASE WHEN Kit_Master = 'Y' THEN 1 ELSE 0 END
		FROM [MasterData_Product_Enh].[ProductInfo] wpm
		INNER JOIN [$(Source_Data)].[Retail_Miniapps].[Product] p
		ON wpm.SKU = p.Product_ID;

		/*in a batch, There are some products not in TDG but in Storis*/
		UPDATE wpm
		SET wpm.IsKit = CASE WHEN p.KitStatus = 'Y' THEN 1 ELSE 0 END
		FROM [MasterData_Product_Enh].[ProductInfo] wpm
		INNER JOIN [$(Source_Data)].[Retail_Corporate].[Product] p
		ON wpm.SKU = p.ProductID
		WHERE wpm.IsKit IS NULL;

		UPDATE pt 
		SET pt.VendorID = ISNULL(vm.VendorID, pt.VendorID)
		FROM [MasterData_Ent].[PaymentType] pt 
		LEFT JOIN [MasterData_Ent].[VendorInfo] vm
		ON vm.VendorID = pt.VendorID;

		UPDATE pm
		SET pm.SKUName = pt.PaymentTypeName
			, pm.StoreBrandID = pt.StoreBrandID
			, pm.RecordType = pt.RecordType
			, pm.VendorID = pt.VendorID
			, pm.GroupID = pt.GroupID
			, pm.FinanceUseFee = pt.FinanceUseFee
		FROM [MasterData_Ent].[PaymentType] pt
		INNER JOIN [MasterData_Product_Enh].[ProductInfo] pm
		ON pm.SKU = pt.PaymentTypeID;

		INSERT INTO [MasterData_Product_Enh].[ProductInfo]
		(
			SKU
			, StoreBrandID
			, SKUName
			, VendorID
			, GroupID
			, IsMaster
			, ProductTypeID
			, PurchaseStatus
			, DefaultStoreBrandID
			, RecordType
			, FinanceUseFee
			, DateCreated
		)

		SELECT 
			pt.PaymentTypeID AS SKU
			, pt.StoreBrandID
			, pt.PaymentTypeName AS SKUName
			, pt.VendorID
			, pt.GroupID
			, 1 AS IsMaster
			, 9999 AS ProductTypeID
			, 'A' AS PurchaseStatus
			, pt.StoreBrandID AS DefaultStoreBrandID
			, pt.RecordType
			, pt.FinanceUseFee
			, CAST('2023-12-31 00:00:00.000' AS DATETIME2(3)) AS DateCreated
		FROM [MasterData_Ent].[PaymentType] pt		
		WHERE pt.PaymentTypeID NOT IN
		(
			SELECT pm.SKU 
			FROM [MasterData_Product_Enh].[ProductInfo] pm
		);

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
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable;
		
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