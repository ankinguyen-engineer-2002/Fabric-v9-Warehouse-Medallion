CREATE PROCEDURE [Retail_DW_Core].[usp_Refresh_DimGroupMaster]
AS

BEGIN 

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Refresh_DimGroupMaster';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'DimGroupMaster';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(GroupKey),0) FROM [Retail_DW_Core].[DimGroupMaster]);
		
		UPDATE dst
		SET dst.Cubes = src.Cubes
		FROM [$(Retail_Warehouse)].[MasterData_Product].[ProductGroup] src
		INNER JOIN [Retail_DW_Core].[DimGroupMaster] dst
		ON src.CategoryID = dst.CategoryID 
		AND src.GroupID = dst.GroupID
		WHERE dst.Cubes <> src.Cubes;

		INSERT INTO [Retail_DW_Core].[DimGroupMaster]
		(
			GroupKey
			, CategoryID
			, CategoryDescription
			, GroupID
			, GroupDescription
			, FamilyName
			, PrimaryCategory
			, DefaultPPPGroupID
			, Cubes
		)

		SELECT 
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY src.CategoryID, src.GroupID) AS BIGINT) AS GroupKey
			, src.CategoryID
			, src.CategoryDescription
			, src.GroupID 
			, src.GroupDescription
			, src.FamilyName
			, src.PrimaryCategory
			, src.DefaultPPPGroupID
			, src.Cubes
		FROM [$(Retail_Warehouse)].[MasterData_Product].[ProductGroup] src
		LEFT JOIN 
		(
			SELECT CategoryID, FamilyName
			FROM [Retail_DW_Core].[DimGroupMaster]
			GROUP BY CategoryID, FamilyName
		) fmly 
		ON src.CategoryID = fmly.CategoryID
		LEFT JOIN [Retail_DW_Core].[DimGroupMaster] dst 
		ON src.CategoryID = dst.CategoryID 
		AND src.GroupID = dst.GroupID
		WHERE dst.GroupID IS NULL
		AND src.CategoryID <> '<No Value>';

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