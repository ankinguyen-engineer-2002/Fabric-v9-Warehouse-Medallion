CREATE PROCEDURE [Retail_DW_Core].[usp_Refresh_DimVendorMaster]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Refresh_DimVendorMaster';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'DimVendorMaster';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(VendorKey),0) FROM [Retail_DW_Core].[DimVendorMaster]);

		UPDATE vm
		SET VendorID = vi.VendorID
			, VendorName = vi.VendorName
			, VendorClass = vi.VendorClass
			, Address1 = vi.Address1
			, Address2 = vi.Address2
			, City = vi.City
			, State = vi.State
			, PostalCode = vi.PostalCode
			, CountryID = vi.CountryID
		FROM [Retail_DW_Core].[DimVendorMaster] vm
		INNER JOIN [$(Retail_Warehouse)].[MasterData_Ent].[VendorInfo] vi
		ON vi.VendorID = vm.VendorID;

		INSERT INTO [Retail_DW_Core].[DimVendorMaster]
		(
			VendorKey
			, VendorID
			, VendorName
			, VendorClass
			, Address1
			, Address2
			, City
			, State
			, PostalCode
			, CountryID
		)

		SELECT	
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY vi.VendorID) AS BIGINT) AS VendorKey
			, vi.VendorID
			, vi.VendorName
			, vi.VendorClass
			, vi.Address1
			, vi.Address2
			, vi.City
			, vi.State
			, vi.PostalCode
			, vi.CountryID
		FROM [Retail_DW_Core].[DimVendorMaster] vm
		RIGHT OUTER JOIN [$(Retail_Warehouse)].[MasterData_Ent].[VendorInfo] vi
		ON vm.VendorID = vi.VendorID
		WHERE vm.VendorID IS NULL;

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