CREATE PROCEDURE [Retail_DW_Core].[usp_Refresh_DimSalesPerson]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Refresh_DimSalesPerson';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'DimSalesPerson';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(SalesPersonKey),0) FROM [Retail_DW_Core].[DimSalesPerson]);
		
		UPDATE sp
		SET sp.SalesPersonName = spt.SalesPersonName
			, sp.Address1 = spt.Address1
			, sp.Address2 = spt.Address2
			, sp.City = spt.City
			, sp.CommissionRate = spt.CommissionRate
			, sp.PhoneNumber = spt.PhoneNumber
			, sp.State = spt.State
			, sp.PostalCode = spt.PostalCode
			, sp.HomeStore = spt.HomeStore
			, sp.CommissionStore = spt.CommissionStore
			, sp.SalesPersonTypeID = spt.SalesPersonTypeID
			, sp.ManagerID = spt.ManagerID
			, sp.PeopleID = spt.PeopleID
			, sp.ActiveStatus = spt.ActiveStatus
			, sp.PrimaryID = spt.PrimaryID
			, sp.InitialPrimaryID = spt.InitialPrimaryID
			, sp.DateChanged = spt.DateChanged
			, sp.DateCreated = spt.DateCreated
			, sp.HireDate = spt.HireDate
		FROM [Retail_DW_Core].[DimSalesPerson] sp
		INNER JOIN [$(Retail_Warehouse)].[MasterData_Retail_Ent].[SalesPerson] spt
		ON sp.SalesPersonID = spt.SalesPersonID;

		INSERT INTO [Retail_DW_Core].[DimSalesPerson]
		(
			SalesPersonKey
			, SalesPersonID
			, StaffID
			, EmployeeNumber
			, StaffTypeID
			, SalesPersonName
			, SalesPersonTypeID
			, ActiveStatus
			, ManagerID
			, Address1
			, Address2
			, City
			, State
			, PostalCode
			, PhoneNumber
			, HomeStore
			, CommissionStore
			, CommissionRate
			, PeopleID
			, PrimaryID
			, InitialPrimaryID
			, DateCreated
			, DateChanged
			, HireDate
		)

		SELECT
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY spt.SalesPersonID) AS BIGINT) AS SalesPersonKey
			, spt.SalesPersonID
			, spt.StaffID
			, spt.EmployeeNumber
			, spt.StaffTypeID
			, spt.SalesPersonName
			, spt.SalesPersonTypeID
			, spt.ActiveStatus
			, spt.ManagerID
			, spt.Address1
			, spt.Address2
			, spt.City
			, spt.State
			, spt.PostalCode
			, spt.PhoneNumber
			, spt.HomeStore
			, spt.CommissionStore
			, spt.CommissionRate
			, spt.PeopleID
			, spt.PrimaryID
			, spt.InitialPrimaryID
			, spt.DateCreated
			, spt.DateChanged
			, spt.HireDate
		FROM [$(Retail_Warehouse)].[MasterData_Retail_Ent].[SalesPerson] spt
		LEFT JOIN [Retail_DW_Core].[DimSalesPerson] sp
		ON sp.SalesPersonID = spt.SalesPersonID
		WHERE sp.SalesPersonID IS NULL;

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