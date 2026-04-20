--EXEC [MasterData_Retail].[usp_DynamicTableCreateAndLoadDirect] @ExecuteMode = 0, @ConfigID = 1
CREATE PROCEDURE [MasterData_Retail_Ent].[usp_DynamicTableCreateAndLoadDirect]
(
    @ConfigID INT = Null,
    @ExecuteMode BIT = 0
)
AS

BEGIN

    SET NOCOUNT ON;
    
    -- Create temp table for configurations
    TRUNCATE TABLE [MasterData_Retail_Ent_Wrk].[Config] 
    DECLARE @MaxID BIGINT = 0
 
	---SELECT @MaxID + CAST(ROW_NUMBER() OVER (ORDER BY ii.SourceOrderID, ii.LineNumber) AS BIGINT) AS OrderDetailKey
    -- Load configurations
    INSERT INTO [MasterData_Retail_Ent_Wrk].[Config] (RowNum, ConfigID, SourceDB, SourceSchema, TargetDB, TargetSchema, TableName, JoinColumn, Filter1, Filter2, Frequency)
    SELECT @MaxID + CAST(ROW_NUMBER() OVER (ORDER BY ID) AS BIGINT), ID, SourceDataBase, SourceSchema, TargetDataBase, TargetSchema, TableName, JoinColumn, Filter1, Filter2, Frequency
    FROM [MasterData_Retail_Ent].[ETLTableLoad]  --Your config table
    WHERE (@ConfigID IS NULL OR ID = @ConfigID)
    AND IsActive = 1;

    DECLARE @CurrentRow INT = 1;
    DECLARE @TotalRows INT;
    SELECT @TotalRows = COUNT(*) FROM [MasterData_Retail_Ent_Wrk].[Config];
    
    WHILE @CurrentRow <= @TotalRows
    BEGIN
        DECLARE @ConfigurationID INT, @SourceDB VARCHAR(128), @SourceSchema VARCHAR(128);
        DECLARE @TargetDB VARCHAR(128), @TargetSchema VARCHAR(128), @TableName VARCHAR(128);
        DECLARE @JoinColumn VARCHAR(128), @Filter1 VARCHAR(500), @Filter2 VARCHAR(500), @Frequency INT;
        DECLARE @SQL NVARCHAR(MAX), @WhereClause NVARCHAR(1000) = '';
        
        -- Get current configuration
        SELECT @ConfigurationID = ConfigID, @SourceDB = SourceDB, @SourceSchema = SourceSchema,
               @TargetDB = TargetDB, @TargetSchema = TargetSchema, @TableName = TableName,
               @JoinColumn = JoinColumn, @Filter1 = Filter1, @Filter2 = Filter2, @Frequency = Frequency
        FROM [MasterData_Retail_Ent_Wrk].[Config] WHERE RowNum = @CurrentRow;
        
        BEGIN TRY
            PRINT 'Processing Config ID: ' + CAST(@ConfigurationID AS VARCHAR(10)) + ' - Table: ' + @TableName;
            

            SET @WhereClause = '';
            
            IF @JoinColumn IS NOT NULL AND @JoinColumn <> ''
            BEGIN
                SET @WhereClause = 'WHERE ' + @JoinColumn + ' BETWEEN';
            END;
            
            IF @Filter1 IS NOT NULL AND @Filter1 <> '' AND @Filter1 <> '1'
            BEGIN
                IF @WhereClause = ''
                    SET @WhereClause = 'WHERE ' + @Filter1;
                ELSE
                    SET @WhereClause = @WhereClause + ' ' + REPLACE(@Filter1,'{d}',@Frequency) + '';
            END;
            
            IF @Filter2 IS NOT NULL AND @Filter2 <> '' AND @Filter2 <> '1'
            BEGIN
                IF @WhereClause = ''
                    SET @WhereClause = 'WHERE ' + @Filter2;
                ELSE
                    SET @WhereClause = @WhereClause + ' AND ' + @Filter2 + '';
            END;
            

            SET @SQL = N'
            -- Drop table if exists
            IF OBJECT_ID(''[' + @TargetDB + '].[' + @TargetSchema + '].[' + @TableName + ']'') IS NOT NULL
            BEGIN
                DROP TABLE [' + @TargetDB + '].[' + @TargetSchema + '].[' + @TableName + '];
                PRINT ''Dropped table: [' + @TargetDB + '].[' + @TargetSchema + '].[' + @TableName + ']'';
            END;
            
            -- Create table structure
            SELECT *
            INTO [' + @TargetDB + '].[' + @TargetSchema + '].[' + @TableName + ']
            FROM [' + @SourceDB + '].[' + @SourceSchema + '].[' + @TableName + ']
            WHERE 1 = 0;
            
            PRINT ''Created table: [' + @TargetDB + '].[' + @TargetSchema + '].[' + @TableName + ']'';';
            
            IF @ExecuteMode = 1
                EXEC sp_executesql @SQL;
            ELSE
                PRINT @SQL;
            
            -- Step 2: Load Data
            SET @SQL = N'
            INSERT INTO [' + @TargetDB + '].[' + @TargetSchema + '].[' + @TableName + ']
            SELECT *
            FROM [' + @SourceDB + '].[' + @SourceSchema + '].[' + @TableName + ']
            ' + @WhereClause + ';
            
            SELECT ''Loaded '' + CAST(@@ROWCOUNT AS VARCHAR(20)) + '' rows into [' + @TargetDB + '].[' + @TargetSchema + '].[' + @TableName + ']'' AS Result;';
            
            IF @ExecuteMode = 1
                EXEC sp_executesql @SQL;
            ELSE
                PRINT @SQL;
            
            PRINT 'Successfully processed Config ID: ' + CAST(@ConfigurationID AS VARCHAR(10));
            
        END TRY
        BEGIN CATCH
            PRINT 'Error in Config ID ' + CAST(@ConfigurationID AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
        END CATCH;
        
        SET @CurrentRow = @CurrentRow + 1;
        PRINT '---------------------------------------------------';
    END;
    

    PRINT 'Processing complete. Total configurations processed: ' + CAST(@TotalRows AS VARCHAR(10));
END;