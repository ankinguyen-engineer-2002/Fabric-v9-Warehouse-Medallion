CREATE   PROCEDURE [Retail_DW_Core].[usp_Refresh_DimCustomerMaster]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Refresh_DimCustomerMaster';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'DimCustomerMaster';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY
		
		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(CustomerKey),0) FROM [Retail_DW_Core].[DimCustomerMaster]);
		
		/*Update Existing CustomerMaster*/

		UPDATE tgt
		SET tgt.FirstName = src.FirstName
			, tgt.LastName = src.LastName
			, tgt.FullName = src.FullName
			, tgt.HomePhone = src.HomePhone
			, tgt.CellPhone = src.CellPhone
			, tgt.WorkPhone = src.WorkPhone
			, tgt.WorkPhoneExt = src.WorkPhoneExt
			, tgt.EmailAddress = src.EmailAddress
			, tgt.Address1 = src.Address1
			, tgt.Address2 = src.Address2
			, tgt.City = src.City
			, tgt.State = src.State
			, tgt.PostalCode = src.PostalCode
			, tgt.CustomerClass = src.CustomerClass
			, tgt.StoreID = src.StoreID
			, tgt.DateChanged = src.DateChanged
			, tgt.ProcessStatus = 0
			, tgt.IsRetail = src.IsRetail
			, tgt.MembershipActive = src.MembershipActive
			, tgt.MembershipCancellationDate = src.MembershipCancellationDate
			, tgt.MembershipCard = src.MembershipCard
			, tgt.MembershipFee = src.MembershipFee
			, tgt.MembershipLinkedCustomerID = src.MembershipLinkedCustomerID
			, tgt.MembershipPaymentTypeID = src.MembershipPaymentTypeID
			, tgt.MembershipProductID = src.MembershipProductID
			, tgt.MembershipRenewal = src.MembershipRenewal
			, tgt.MembershipRenewDate = src.MembershipRenewDate
			, tgt.MembershipReviewDate = src.MembershipReviewDate
			, tgt.MembershipStartDate = src.MembershipStartDate
			, tgt.MembershipStoreID = src.MembershipStoreID
			, tgt.MembershipTerms = src.MembershipTerms
		FROM [Retail_DW_Core].[DimCustomerMaster] tgt
		INNER JOIN [$(Retail_Warehouse)].[MasterData_Ent].[CustomerInfo] AS src
		ON src.CustomerID = tgt.CustomerID;


		/*Insert New CustomerMaster*/
		INSERT INTO [Retail_DW_Core].[DimCustomerMaster]
		(
			CustomerKey
			, ParentKey
			, SFCurrentKey
			, CustomerID
			, FirstName
			, LastName
			, FullName
			, HomePhone
			, CellPhone
			, WorkPhone
			, WorkPhoneExt
			, EmailAddress
			, Address1
			, Address2
			, City
			, State
			, PostalCode
			, CustomerClass
			, StoreID
			, OpenDate
			, IsRetail
			, MembershipActive
			, MembershipCancellationDate
			, MembershipCard
			, MembershipFee
			, MembershipLinkedCustomerID
			, MembershipPaymentTypeID
			, MembershipProductID
			, MembershipRenewal
			, MembershipRenewDate
			, MembershipReviewDate
			, MembershipStartDate
			, MembershipStoreID
			, MembershipTerms
			, DateChanged
			, DateCreated
		)

		SELECT 
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY CustomerID) AS BIGINT) AS CustomerKey
			, NULL
			, NULL
			, src.CustomerID
			, src.FirstName
			, src.LastName
			, src.FullName
			, src.HomePhone
			, src.CellPhone
			, src.WorkPhone
			, src.WorkPhoneExt
			, src.EmailAddress
			, src.Address1
			, src.Address2
			, src.City
			, src.State
			, src.PostalCode
			, src.CustomerClass
			, src.StoreID
			, src.OpenDate
			, src.IsRetail
			, src.MembershipActive
			, src.MembershipCancellationDate
			, src.MembershipCard
			, src.MembershipFee
			, src.MembershipLinkedCustomerID
			, src.MembershipPaymentTypeID
			, src.MembershipProductID
			, src.MembershipRenewal
			, src.MembershipRenewDate
			, src.MembershipReviewDate
			, src.MembershipStartDate
			, src.MembershipStoreID
			, src.MembershipTerms
			, src.DateChanged
			, src.DateCreated
		FROM [$(Retail_Warehouse)].[MasterData_Ent].[CustomerInfo] AS src
		WHERE src.CustomerID NOT IN
		(
			SELECT CustomerID 
			FROM [Retail_DW_Core].[DimCustomerMaster]
		)
		ORDER BY src.OpenDate;

		SET @MaxID = (SELECT ISNULL(MAX(CustomerKey),0) FROM [Retail_DW_Core].[DimCustomerMaster]);

		WITH UniqueCustomersBTA AS
		(
			SELECT DISTINCT 
				CustomerID
				, GETDATE() AS DateChanged
				, GETDATE() AS DateCreated
			FROM [$(Retail_Warehouse)].[Retail_Sales].[SalesOrderLineHistory] bta 
			WHERE NOT EXISTS 
			(
				SELECT 1
				FROM [Retail_DW_Core].[DimCustomerMaster] cm 
				WHERE cm.CustomerID = bta.CustomerID
			)
		)

		INSERT INTO [Retail_DW_Core].[DimCustomerMaster]
		(
			CustomerKey
			, ParentKey
			, SFCurrentKey
			, CustomerID
			, OpenDate
			, DateChanged
			, DateCreated
		)

		SELECT DISTINCT 
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY CustomerID) AS BIGINT) AS CustomerKey
			, NULL
			, NULL
			, CustomerID
			, GETDATE()
			, DateChanged
			, DateCreated
		FROM UniqueCustomersBTA;

		SET @MaxID = (SELECT ISNULL(MAX(CustomerKey),0) FROM [Retail_DW_Core].[DimCustomerMaster]);

		WITH UniqueCustomersSOH AS
		(
			SELECT DISTINCT 
				SourceCustomerID AS CustomerID
				, GETDATE() AS DateChanged
				, GETDATE() AS DateCreated
			FROM [$(Retail_Warehouse)].[Retail_Sales].[SalesOrderHeader] oh
			WHERE NOT EXISTS 
			(
				SELECT 1
				FROM [Retail_DW_Core].[DimCustomerMaster] cm
				WHERE cm.CustomerID = oh.SourceCustomerID
			)
		)

		INSERT INTO [Retail_DW_Core].[DimCustomerMaster]
		(
			CustomerKey
			, ParentKey
			, SFCurrentKey
			, CustomerID
			, OpenDate
			, DateChanged
			, DateCreated
		)

		SELECT DISTINCT 
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY CustomerID) AS BIGINT) AS CustomerKey
			, NULL
			, NULL
			, CustomerID
			, GETDATE()
			, DateChanged
			, DateCreated
		FROM UniqueCustomersSOH;

		/*Remove invalid Emails*/
		UPDATE cm
		SET cm.EmailAddress = NULL
			, ProcessStatus = 0
		FROM [Retail_DW_Core].[DimCustomerMaster] cm
		INNER JOIN [$(Source_Data)].[Retail_External].[InvalidEmailAddresses] e 
		ON cm.EmailAddress = e.Email;

		/*Set Process Status to 0 for all related Customers*/
		WITH pkey AS 
		(
			SELECT DISTINCT ParentKey
			FROM [Retail_DW_Core].[DimCustomerMaster]
			WHERE ProcessStatus = 0
		)

		UPDATE cm
		SET ProcessStatus = 0
		FROM [Retail_DW_Core].[DimCustomerMaster] cm
		INNER JOIN pkey
		ON pkey.ParentKey = cm.ParentKey;

		/*Update Parent and SF Keys*/
		UPDATE [Retail_DW_Core].[DimCustomerMaster]
		SET ParentKey = CustomerKey
			, SFCurrentKey = CustomerKey
		WHERE ProcessStatus = 0;

		/*Group Customer with Same Email Address*/
		WITH email AS 
		(
			SELECT
				MIN(cm.CustomerKey) AS ParentKey
				, cm.EmailAddress
				, COUNT(*) AS EmailCount
			FROM [Retail_DW_Core].[DimCustomerMaster] AS cm
			WHERE cm.ProcessStatus = 0
			GROUP BY cm.EmailAddress
		)

		UPDATE cm
		SET ParentKey = email.ParentKey
			, SFCurrentKey = email.ParentKey
			, ProcessStatus = 0
		FROM [Retail_DW_Core].[DimCustomerMaster] AS cm
		INNER JOIN email
		ON email.EmailAddress = cm.EmailAddress;

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