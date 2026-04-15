CREATE     PROCEDURE [MasterData_HR_UKG_Enh].[usp_Update_PersonDetails]
AS

BEGIN

	DECLARE
            @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
    SET @String = 'MasterData_HR_UKG_Enh.usp_Update_PersonDetails' ;
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE()
	SET @DestinationDatabase = 'Retail_Warehouse'
	SET @DestinationSchema = 'MasterData_HR_UKG_Enh'
	SET @DestinationTable = 'PersonDetails';

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    BEGIN TRY

		--update existing records (if changed)

		--get UPDATED records

		IF OBJECT_ID('tempdb..#modified') IS NOT NULL 
		DROP TABLE #modified;

		SELECT pd.EmployeeID
		INTO #modified
		FROM [MasterData_HR_UKG_Enh].[PersonDetails] pd
		INNER JOIN [$(Source_Data)].[MasterData_HR_UKG_DSG].[PersonDetails] wpd 
		ON wpd.employeeId = pd.EmployeeID
		WHERE ISNULL(pd.Username, '') <> ISNULL(wpd.userName, '')
		OR ISNULL(pd.FirstName, '') <> ISNULL(wpd.firstName, '')
		OR ISNULL(pd.MiddleName, '') <> ISNULL(wpd.middleName, '')
		OR ISNULL(pd.LastName, '') <> ISNULL(wpd.lastName, '')
		OR ISNULL(pd.PreferredName, '') <> ISNULL(wpd.preferredName, '')
		OR ISNULL(pd.FormerName, '') <> ISNULL(wpd.formerName, '')
		OR ISNULL(pd.EmailAddress, '') <> ISNULL(wpd.emailAddress, '')
		OR ISNULL(pd.EmailAddressAlternate, '') <> ISNULL(wpd.emailAddressAlternate, '')
		OR ISNULL(pd.NamePrefix, '') <> ISNULL(wpd.namePrefix, '')
		OR ISNULL(pd.NameSuffix, '') <> ISNULL(wpd.nameSuffix, '');
		

		UPDATE pd
		SET pd.Username = wpd.userName
			, pd.FirstName = wpd.firstName
			, pd.MiddleName = NULLIF(wpd.middleName,'')
			, pd.LastName = wpd.lastName
			, pd.PreferredName = NULLIF(wpd.preferredName,'')
			, pd.FormerName = NULLIF(wpd.formerName,'')
			, pd.NamePrefix = NULLIF(wpd.namePrefix,'')
			, pd.NameSuffix = NULLIF(wpd.nameSuffix,'')
			, pd.Generation = NULLIF(wpd.Generation,'')
			, pd.EmailAddress = wpd.emailAddress
			, pd.EmailAddressAlternate = wpd.emailAddressAlternate
			, pd.DateChanged = wpd.dateChanged
		FROM [MasterData_HR_UKG_Enh].[PersonDetails] pd
		INNER JOIN [$(Source_Data)].[MasterData_HR_UKG_DSG].[PersonDetails] wpd 
		ON wpd.employeeId = pd.EmployeeID
		INNER JOIN #modified m
		ON m.EmployeeID = pd.EmployeeID;

		--NEW

		IF OBJECT_ID('tempdb..#new') IS NOT NULL 
		DROP TABLE #new;

		SELECT wpd.employeeId AS EmployeeID
		INTO #new
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[PersonDetails] wpd
		LEFT JOIN [MasterData_HR_UKG_Enh].[PersonDetails] pd 
		ON pd.EmployeeID = wpd.employeeId
		WHERE pd.EmployeeID IS NULL;


		INSERT INTO [MasterData_HR_UKG_Enh].[PersonDetails] 
		(
			PersonDetailKey
			, DataSource
			, EmployeeID
			, Username
			, FirstName
			, MiddleName
			, LastName
			, PreferredName
			, FormerName
			, NamePrefix
			, NameSuffix
			, Generation
			, EmailAddress
			, EmailAddressAlternate
			, DateChanged
			, DateCreated
		)
	
		SELECT	
			wpd.[key]
			, wpd.dataSource
			, wpd.employeeId
			, wpd.userName
			, wpd.firstName
			, NULLIF(wpd.middleName,'')
			, wpd.lastName
			, NULLIF(wpd.preferredName,'')
			, NULLIF(wpd.formerName,'')
			, NULLIF(wpd.namePrefix,'')
			, NULLIF(wpd.nameSuffix,'')
			, NULLIF(Generation, '')
			, wpd.emailAddress
			, wpd.emailAddressAlternate
			, wpd.dateChanged
			, wpd.dateCreated
		FROM [$(Source_Data)].[MasterData_HR_UKG_DSG].[PersonDetails] wpd
		INNER JOIN #new n 
		ON n.EmployeeID = wpd.employeeId
		ORDER BY wpd.employeeId;

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