CREATE   PROCEDURE [Retail_OOM_Enh].[usp_InvActivitySummary]
AS
BEGIN
    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Enh.usp_InvActivitySummary';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_OOM_Enh';
    SET @DestinationTable = 'usp_InvActivitySummary';

    SELECT @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES (@String, @DateValue, @User, 'Process Start');

    BEGIN TRY
        DECLARE @TransDate DATE;
        SET @TransDate = CAST(GETDATE() - 1 AS DATE);

        DELETE FROM [Retail_OOM_Enh].[InvActivitySummary] 
        WHERE CAST(TransDate AS DATE) = @TransDate;

        DROP TABLE IF EXISTS #t1, #t2, #RuleMatches;

      
        SELECT  iar.UniqueID,
                iar.StaffID,
                iar.StoreID,
                iar.AdjQty,
                iar.InStorageID,
                iar.OutStorageID,
                iar.ProductID,
                iar.InvTransTypeID,
                iar.TransDate
        INTO #t1
        FROM [$(Source_Data)].[Retail_Corporate].[InvactivityRaw] AS iar
        INNER JOIN [$(Source_Data)].[Retail_External].[LocationGroups] ON LocationID = iar.StoreID
        WHERE LocationGroupID = 'DC'
            AND iar.GroupID NOT IN ('ADVTRK', 'AUCPRM', 'DON', 'DONOWH', 'ISI', 'LABOR', 'MSI', 'PRCARD', 'RESTCK', 'SVC', 'XFI')
            AND  CAST(TransDate AS DATE) >= @TransDate
            AND iar.StaffID IS NOT NULL;

    
        SELECT  i.UniqueID,
                i.StaffID,
                i.StoreID,
                i.AdjQty,
                i.InStorageID,
                i.OutStorageID,
                i.ProductID,
                i.InvTransTypeID,
                i.TransDate,
                tr.RuleID,
                r.FieldName
        INTO #RuleMatches
        FROM #t1 AS i
        CROSS JOIN (
            SELECT DISTINCT RuleID 
            FROM [$(Source_Data)].[Retail_External].[InvActivityRuleDetails]
        ) AS tr
        INNER JOIN [$(Source_Data)].[Retail_External].[InvActivityRuleDetails] AS r
            ON r.RuleID = tr.RuleID
        WHERE 
       
            (r.FieldName = 'StoreID' AND (
                r.Operator IS NULL
                OR (r.Operator = 'EQ' AND r.FieldValue = i.StoreID)
                OR (r.Operator = 'LT' AND i.StoreID < r.FieldValue)
                OR (r.Operator = 'LTE' AND i.StoreID <= r.FieldValue)
                OR (r.Operator = 'GT' AND i.StoreID > r.FieldValue)
                OR (r.Operator = 'GTE' AND i.StoreID >= r.FieldValue)
                OR (r.Operator = 'LIKE' AND i.StoreID LIKE '%' + r.FieldValue + '%')
                OR (r.Operator = 'RAN' 
                    AND i.StoreID >= r.RangeLoValue
                    AND i.StoreID <= r.RangeHiValue)
            ))
            OR
       
            (r.FieldName = 'InvTransTypeID' AND (
                r.Operator IS NULL
                OR (r.Operator = 'EQ' AND r.FieldValue = CAST(i.InvTransTypeID AS VARCHAR(40)))
                OR (r.Operator = 'LT' AND CAST(i.InvTransTypeID AS VARCHAR(40)) < r.FieldValue)
                OR (r.Operator = 'LTE' AND CAST(i.InvTransTypeID AS VARCHAR(40)) <= r.FieldValue)
                OR (r.Operator = 'GT' AND CAST(i.InvTransTypeID AS VARCHAR(40)) > r.FieldValue)
                OR (r.Operator = 'GTE' AND CAST(i.InvTransTypeID AS VARCHAR(40)) >= r.FieldValue)
                OR (r.Operator = 'LIKE' AND CAST(i.InvTransTypeID AS VARCHAR(40)) LIKE '%' + r.FieldValue + '%')
                OR (r.Operator = 'RAN' 
                    AND CAST(i.InvTransTypeID AS VARCHAR(40)) >= r.RangeLoValue
                    AND CAST(i.InvTransTypeID AS VARCHAR(40)) <= r.RangeHiValue)
            ))
            OR
     
            (r.FieldName = 'InStorageID' AND (
                r.Operator IS NULL
                OR (r.Operator = 'EQ' AND r.FieldValue = i.InStorageID)
                OR (r.Operator = 'LT' AND i.InStorageID < r.FieldValue)
                OR (r.Operator = 'LTE' AND i.InStorageID <= r.FieldValue)
                OR (r.Operator = 'GT' AND i.InStorageID > r.FieldValue)
                OR (r.Operator = 'GTE' AND i.InStorageID >= r.FieldValue)
                OR (r.Operator = 'LIKE' AND i.InStorageID LIKE '%' + r.FieldValue + '%')
                OR (r.Operator = 'RAN' 
                    AND i.InStorageID >= RIGHT('00' + r.RangeLoValue, 8)
                    AND i.InStorageID <= RIGHT('00' + r.RangeHiValue, 8)
                    AND NOT (
                    
                        LTRIM(RTRIM(CASE WHEN LEFT(i.InStorageID, 1) = '>' 
                                         THEN RIGHT(i.InStorageID, LEN(i.InStorageID) - 1) 
                                         ELSE i.InStorageID END))
                        LIKE '[0-9][0-9]-[A-Z]-[0-9][0-9]'
                        OR LTRIM(RTRIM(CASE WHEN LEFT(i.InStorageID, 1) = '>' 
                                            THEN RIGHT(i.InStorageID, LEN(i.InStorageID) - 1) 
                                            ELSE i.InStorageID END))
                        LIKE '[0-9][0-9][0-9]-[A-Z]-[0-9][0-9]'
                    )
                )
                OR (r.Operator = 'BRAN' 
                    AND i.InStorageID >= RIGHT('00' + r.RangeLoValue, 8)
                    AND i.InStorageID <= RIGHT('00' + r.RangeHiValue, 8)
                    AND (
                    
                        LTRIM(RTRIM(CASE WHEN LEFT(i.InStorageID, 1) = '>' 
                                         THEN RIGHT(i.InStorageID, LEN(i.InStorageID) - 1) 
                                         ELSE i.InStorageID END))
                        LIKE '[0-9][0-9]-[A-Z]-[0-9][0-9]'
                        OR LTRIM(RTRIM(CASE WHEN LEFT(i.InStorageID, 1) = '>' 
                                            THEN RIGHT(i.InStorageID, LEN(i.InStorageID) - 1) 
                                            ELSE i.InStorageID END))
                        LIKE '[0-9][0-9][0-9]-[A-Z]-[0-9][0-9]'
                    )
                )
            ))
            OR
     
            (r.FieldName = 'OutStorageID' AND (
                r.Operator IS NULL
                OR (r.Operator = 'EQ' AND r.FieldValue = i.OutStorageID)
                OR (r.Operator = 'LT' AND i.OutStorageID < r.FieldValue)
                OR (r.Operator = 'LTE' AND i.OutStorageID <= r.FieldValue)
                OR (r.Operator = 'GT' AND i.OutStorageID > r.FieldValue)
                OR (r.Operator = 'GTE' AND i.OutStorageID >= r.FieldValue)
                OR (r.Operator = 'LIKE' AND i.OutStorageID LIKE '%' + r.FieldValue + '%')
                OR (r.Operator = 'RAN' 
                    AND i.OutStorageID >= RIGHT('00' + r.RangeLoValue, 8)
                    AND i.OutStorageID <= RIGHT('00' + r.RangeHiValue, 8)
                    AND NOT (
                
                        LTRIM(RTRIM(CASE WHEN LEFT(i.OutStorageID, 1) = '>' 
                                         THEN RIGHT(i.OutStorageID, LEN(i.OutStorageID) - 1) 
                                         ELSE i.OutStorageID END))
                        LIKE '[0-9][0-9]-[A-Z]-[0-9][0-9]'
                        OR LTRIM(RTRIM(CASE WHEN LEFT(i.OutStorageID, 1) = '>' 
                                            THEN RIGHT(i.OutStorageID, LEN(i.OutStorageID) - 1) 
                                            ELSE i.OutStorageID END))
                        LIKE '[0-9][0-9][0-9]-[A-Z]-[0-9][0-9]'
                    )
                )
                OR (r.Operator = 'BRAN' 
                    AND i.OutStorageID >= RIGHT('00' + r.RangeLoValue, 8)
                    AND i.OutStorageID <= RIGHT('00' + r.RangeHiValue, 8)
                    AND (
          
                        LTRIM(RTRIM(CASE WHEN LEFT(i.OutStorageID, 1) = '>' 
                                         THEN RIGHT(i.OutStorageID, LEN(i.OutStorageID) - 1) 
                                         ELSE i.OutStorageID END))
                        LIKE '[0-9][0-9]-[A-Z]-[0-9][0-9]'
                        OR LTRIM(RTRIM(CASE WHEN LEFT(i.OutStorageID, 1) = '>' 
                                            THEN RIGHT(i.OutStorageID, LEN(i.OutStorageID) - 1) 
                                            ELSE i.OutStorageID END))
                        LIKE '[0-9][0-9][0-9]-[A-Z]-[0-9][0-9]'
                    )
                )
            ))
            OR

            (r.FieldName = 'AdjQty' AND (
                r.Operator IS NULL
                OR (r.Operator = 'EQ' AND r.FieldValue = CAST(i.AdjQty AS VARCHAR(40)))
                OR (r.Operator = 'LT' AND CAST(i.AdjQty AS VARCHAR(40)) < r.FieldValue)
                OR (r.Operator = 'LTE' AND CAST(i.AdjQty AS VARCHAR(40)) <= r.FieldValue)
                OR (r.Operator = 'GT' AND CAST(i.AdjQty AS VARCHAR(40)) > r.FieldValue)
                OR (r.Operator = 'GTE' AND CAST(i.AdjQty AS VARCHAR(40)) >= r.FieldValue)
                OR (r.Operator = 'LIKE' AND CAST(i.AdjQty AS VARCHAR(40)) LIKE '%' + r.FieldValue + '%')
                OR (r.Operator = 'RAN' 
                    AND CAST(i.AdjQty AS VARCHAR(40)) >= r.RangeLoValue
                    AND CAST(i.AdjQty AS VARCHAR(40)) <= r.RangeHiValue)
            ));


        SELECT  rm.UniqueID,
                rm.StaffID,
                rm.StoreID,
                rm.AdjQty,
                rm.InStorageID,
                rm.OutStorageID,
                rm.ProductID,
                rm.InvTransTypeID,
                rm.TransDate,
                rm.RuleID
        INTO #t2
        FROM #RuleMatches rm
        INNER JOIN (

            SELECT  UniqueID,
                    RuleID,
                    COUNT(DISTINCT FieldName) AS MatchedFieldCount
            FROM #RuleMatches
            GROUP BY UniqueID, RuleID
        ) AS MatchCount
            ON rm.UniqueID = MatchCount.UniqueID
            AND rm.RuleID = MatchCount.RuleID
        INNER JOIN (

            SELECT  RuleID,
                    COUNT(DISTINCT FieldName) AS RequiredFieldCount
            FROM [$(Source_Data)].[Retail_External].[InvActivityRuleDetails]
            GROUP BY RuleID
        ) AS RequiredCount
            ON rm.RuleID = RequiredCount.RuleID
        WHERE MatchCount.MatchedFieldCount = RequiredCount.RequiredFieldCount
        GROUP BY 
            rm.UniqueID,
            rm.StaffID,
            rm.StoreID,
            rm.AdjQty,
            rm.InStorageID,
            rm.OutStorageID,
            rm.ProductID,
            rm.InvTransTypeID,
            rm.TransDate,
            rm.RuleID;


        INSERT INTO [Retail_OOM_Enh].[InvActivitySummary] (LocationID, ActivityCodeID, StaffID, TransDate, ActivityQty)
        SELECT  i.StoreID,
                r.ActivityCodeID,
                i.StaffID,
                i.TransDate,
                COUNT(*) AS Qty
        FROM [$(Source_Data)].[Retail_External].[InvActivityRules] r
        INNER JOIN #t2 i ON r.RuleID = i.RuleID
        GROUP BY 
            i.StoreID,
            r.ActivityCodeID,
            i.StaffID,
            i.TransDate;

        DROP TABLE IF EXISTS #t1, #t2, #RuleMatches;

        -- Audit logging
        SET @DateValue = GETDATE();
        SELECT @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES (@String, @DateValue, @User, 'Process Complete');

        -- Update table dictionary
        DECLARE @Exists INT;
        SET @Exists = (
            SELECT COUNT(*)
            FROM [$(ETL_Framework)].[DW_Developer].[TableDictionary]
            WHERE DatabaseName = @DestinationDatabase
                AND SchemaName = @DestinationSchema
                AND TableName = @DestinationTable
        );

        IF @Exists = 0
        BEGIN
            INSERT INTO [$(ETL_Framework)].[DW_Developer].[TableDictionary]
            (ServerName, DatabaseName, SchemaName, TableName, ObjectType, StorageType, UpdateQuery)
            VALUES ('EDW-Fabric', @DestinationDatabase, @DestinationSchema, @DestinationTable, 'Table', 'Delta', @String);
        END;

        UPDATE [$(ETL_Framework)].[DW_Developer].[TableDictionary]
        SET Modified = @DateValue
        WHERE DatabaseName = @DestinationDatabase
            AND SchemaName = @DestinationSchema
            AND TableName = @DestinationTable;

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[TableDictionary_UpdateLog]
        VALUES (@DestinationDatabase, @DestinationSchema, @DestinationTable, @DateValue);

    END TRY
    BEGIN CATCH
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
        VALUES (@String, @DateValue, @User, @ErrorMessage);

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;