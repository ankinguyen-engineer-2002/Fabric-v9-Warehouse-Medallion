CREATE PROCEDURE [Retail_DW_NonCore].[usp_FactInvActivitySummary_Insert]
AS
BEGIN
    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_DW_NonCore.usp_FactInvActivitySummary_Insert';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_DW_NonCore';
    SET @DestinationTable = 'usp_FactInvActivitySummary_Insert';

    SELECT @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    --// AUDIT LOGGING END //--

    BEGIN TRY

		DELETE dst
		FROM Retail_DW_NonCore.[FactInvActivitySummary] dst
		WHERE TransDateKey IN
		(
          SELECT DISTINCT
                 CONVERT(VARCHAR(8), TransDate, 112)
          FROM [$(Retail_Warehouse)].[Retail_OOM_Enh].[InvActivitySummary]
		)
		AND dst.ActivityCodeID NOT IN ('RPR-INL', 'RPR-INS', 'RPR-OUT');

		INSERT INTO Retail_DW_NonCore.[FactInvActivitySummary]
		(
			LocationKey
			, LocationID
			, ActivityCodeID
			, StaffID
			, TransDateKey
			, ActivityQty
		)

		SELECT 
			lm.LocationKey
			, invs.LocationID
			, ActivityCodeID
			, StaffID
			, CONVERT(VARCHAR(8), TransDate, 112)
			, ActivityQty
		FROM [$(Retail_Warehouse)].[Retail_OOM_Enh].[InvActivitySummary] invs
		LEFT JOIN [Retail_DW_Core].[DimStoreLocation] lm
		ON lm.StoreID = invs.LocationID


        SET @DateValue = GETDATE();

        SELECT @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES
        (
            @String, @DateValue, @User, 'Process Complete'
        );

        --- Update last modified in Table Dictionary
        EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable;

        --// AUDIT LOGGING END //--

    END TRY

    BEGIN CATCH

        --// ERROR LOGGING START //--

        DECLARE @ErrorMessage VARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
        SET @ErrorState = ISNULL(ERROR_STATE(), 0);
        SET @DateValue = GETDATE();

        SELECT @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES
        (
            @String, @DateValue, @User, @ErrorMessage
        );

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

        --// ERROR LOGGING END //--

    END CATCH

END