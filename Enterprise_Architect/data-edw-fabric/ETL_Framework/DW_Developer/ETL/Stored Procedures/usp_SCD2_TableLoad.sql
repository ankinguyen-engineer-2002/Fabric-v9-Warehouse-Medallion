CREATE   PROC [DW_Developer].[usp_SCD2_TableLoad]
    @DestinationDatabase VARCHAR(150),
    @DestinationSchema   VARCHAR(150),
    @DestinationTable    VARCHAR(150),
    @OperationName       VARCHAR(100) = NULL
AS

/*----------------   Procedure:  [DW_Developer].[usp_SCD2_TableLoad] ---------------------------------------

 Description: Implements Slowly Changing Dimension Type 2 (SCD2) logic for tracking historical changes
 
 SCD Type 2 maintains historical data by:
 - Creating new rows for changed records
 - Maintaining effective date ranges (EffectiveStartDate, EffectiveEndDate)
 - Using IsCurrent flag to identify active records
 - Closing out old records when changes occur
 
 Requirements:
 - Destination table must have these columns:
   * EffectiveStartDate DATETIME2(6) - When this version became effective
   * EffectiveEndDate DATETIME2(6) - When this version expired (9999-12-31 for current)
   * IsCurrent BIT - 1 for current record, 0 for historical
   * RowVersion INT - Version number for the record (optional but recommended)
 
 - The columns order and types in the Source tables must match the Destination tables
   (excluding the SCD2 tracking columns: EffectiveStartDate, EffectiveEndDate, IsCurrent, RowVersion)
 
 - The primary key (business key) is used to identify the same logical entity across versions
   The PrimaryKey values for both Source and Destination tables must be populated in table dictionary
 
 - UpdateMethod in TableDictionary must be set to 'SCD2'
 
 Process Flow:
 1. Identify changed records by comparing source to current destination records
 2. Close out existing current records (set EffectiveEndDate, IsCurrent = 0)
 3. Insert new versions of changed records
 4. Insert completely new records (not previously in destination)

---------------------------------------------------------------------------------------------------------------------------*/
BEGIN

SET @OperationName = CASE WHEN @OperationName='NULL' THEN NULL ELSE @OperationName END

DECLARE @String VARCHAR(5000), @DateValue DATETIME2(6), @User VARCHAR(500)
SET @String = @DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable + CASE WHEN @OperationName IS NOT NULL THEN  ' ('+@OperationName+')' ELSE '' END
SET @User = SYSTEM_USER;
SET @DateValue = GETDATE();
SELECT
    @DateValue = CSTDateValue
FROM
    DW_Developer.fn_GetDate(@DateValue);

INSERT INTO DW_Developer.AuditLog
    VALUES
    (
      @String, @DateValue, @User, 'SCD2 Process Start'
    );

  
BEGIN TRY

-- Declare Variables
DECLARE @SqlStr VARCHAR(MAX), 
        @ErrSqlStr VARCHAR(300), 
        @DestinationPrimaryKey VARCHAR(800), 
        @DestinationAlternateKey VARCHAR(800), 
        @SourceSchemaName VARCHAR(200), 
        @SourceTableName VARCHAR(200),
        @SourceSchema VARCHAR(200),
        @SourceTable VARCHAR(200), 
        @SourcePrimaryKey VARCHAR(800),
        @SourceAlternateKey VARCHAR(800),
        @UpdateMethod VARCHAR(20),
        @SourceStartPos INT,
        @SourceStopPos INT,
        @DestinationStartPos INT,
        @DestinationStopPos INT,
        @DestinationFirstColumn VARCHAR(100),
        @SourceFirstColumn VARCHAR(100),
        @SourcePlatform VARCHAR(25),
        @SelectColumns VARCHAR(MAX),
        @InsertColumns VARCHAR(MAX),
        @DataLakeObject VARCHAR(100),
        @SelectColumnList VARCHAR(MAX),
        @SourceOperationKey VARCHAR(100),
        @DestinationOperationKey VARCHAR(100),
        @SourceDistributionkey VARCHAR(500),
        @CompareColumns VARCHAR(MAX),
        @EffectiveDate DATETIME2(6)

-- Set the effective date for this load
SET @EffectiveDate = @DateValue

--- lookup the source table name and metadata
SELECT
       @SourceTable             = T1.ReplicatedSource,
       @DestinationPrimaryKey   = COALESCE(T1.AlternateKey,T1.PrimaryKey), 
       @DestinationAlternateKey = T1.AlternateKey,
       @SourcePrimaryKey        = COALESCE(T2.AlternateKey,T2.PrimaryKey),
       @SourceAlternateKey      = T2.AlternateKey,
       @UpdateMethod            = T1.UpdateMethod,
       @SourceSchema            = T2.SchemaName,
       @SourcePlatform          = T2.SourcePlatform,
       @DataLakeObject          = T2.SourceObject,
       @SelectColumnList        = T2.SelectColumn,
       @SourceOperationKey      = T1.OperationKey,
       @DestinationOperationKey = T2.OperationKey,
       @SourceDistributionkey   = T2.DistributionKey

  FROM DW_Developer.TableDictionary T1
  JOIN DW_Developer.TableDictionary T2 ON T2.DatabaseName+'.'+ T2.SchemaName+'.'+T2.TableName=T1.DatabaseName+'.'+T1.ReplicatedSource
 WHERE T1.DatabaseName=@DestinationDatabase AND T1.SchemaName=@DestinationSchema AND T1.TableName=@DestinationTable

-- Validate that UpdateMethod is SCD2
IF @UpdateMethod <> 'SCD2'
BEGIN
    SET @ErrSqlStr='UpdateMethod must be set to SCD2 in TableDictionary for table '+@DestinationTable
    RAISERROR(@ErrSqlStr,16,1)
END

 -- Getting Source Schema and table name
SET @SourceSchemaName = SUBSTRING(@SourceTable,1,CHARINDEX('.',@SourceTable)-1)
SET @SourceTableName  = SUBSTRING(@SourceTable,CHARINDEX('.',@SourceTable)+1 ,200)
SET @SourceTable = @DestinationDatabase+'.'+@SourceTable

-- Build column lists
IF OBJECT_ID('tempdb..#SelectColumns') IS NOT NULL
DROP TABLE #SelectColumns

CREATE Table #SelectColumns (ColumnNames VARCHAR(MAX))

-- Get source columns (excluding SCD2 tracking columns)
IF @SelectColumnList IS NOT NULL
BEGIN
    SET @SelectColumns = @SelectColumnList
END
ELSE
BEGIN
    SET @SqlStr = '
    INSERT INTO #SelectColumns
    SELECT STRING_AGG(CONCAT(''['', CAST(c.name AS VARCHAR(MAX)), '']''), '','') WITHIN GROUP (ORDER BY column_id)
    FROM ' + QUOTENAME(@DestinationDatabase) + '.sys.tables u
    JOIN ' + QUOTENAME(@DestinationDatabase) + '.sys.schemas s ON s.schema_id = u.schema_id
    JOIN ' + QUOTENAME(@DestinationDatabase) + '.sys.columns c ON u.object_id = c.object_id
    WHERE u.name = '''+@DestinationTable+''' AND s.name = '''+@SourceSchema+'''
    AND c.name NOT IN (''EffectiveStartDate'',''EffectiveEndDate'',''IsCurrent'',''RowVersion'')'

    EXECUTE (@SqlStr)
    SET @SelectColumns = (SELECT ColumnNames FROM #SelectColumns)
    DELETE FROM #SelectColumns
END

-- Get destination insert columns (excluding SCD2 tracking columns which we'll add explicitly)
IF OBJECT_ID('tempdb..#InsertColumns') IS NOT NULL
DROP TABLE #InsertColumns

CREATE Table #InsertColumns (InsertColumns VARCHAR(MAX))

SET @SqlStr = '
INSERT INTO #InsertColumns
SELECT STRING_AGG(CONCAT(''['', CAST(c.name AS VARCHAR(MAX)), '']''), '','') WITHIN GROUP (ORDER BY column_id)
FROM ' + QUOTENAME(@DestinationDatabase) + '.sys.tables u
JOIN ' + QUOTENAME(@DestinationDatabase) + '.sys.schemas s ON s.schema_id = u.schema_id
JOIN ' + QUOTENAME(@DestinationDatabase) + '.sys.columns c ON u.object_id = c.object_id
WHERE u.name = '''+@DestinationTable+''' AND s.name = '''+@DestinationSchema+'''
AND c.name NOT IN (''EffectiveStartDate'',''EffectiveEndDate'',''IsCurrent'',''RowVersion'')'

EXECUTE (@SqlStr)
SET @InsertColumns = (SELECT InsertColumns FROM #InsertColumns)

-- Build comparison columns for detecting changes (all columns except PK and SCD2 tracking columns)
-- Use BINARY_CHECKSUM to avoid STRING_AGG 8000 byte limit
-- Note: Fabric Warehouse doesn't support table variables, so we use temp tables

DECLARE @ChecksumColumns NVARCHAR(MAX)

-- Create temp table for checksum columns (Fabric compatible)
IF OBJECT_ID('tempdb..#ChecksumColumns') IS NOT NULL
DROP TABLE #ChecksumColumns

CREATE TABLE #ChecksumColumns (ChecksumCols NVARCHAR(MAX))

SET @SqlStr = '
INSERT INTO #ChecksumColumns
SELECT STRING_AGG(CONCAT(''['', c.name, '']''), '','') WITHIN GROUP (ORDER BY column_id)
FROM ' + QUOTENAME(@DestinationDatabase) + '.sys.tables u
JOIN ' + QUOTENAME(@DestinationDatabase) + '.sys.schemas s ON s.schema_id = u.schema_id
JOIN ' + QUOTENAME(@DestinationDatabase) + '.sys.columns c ON u.object_id = c.object_id
WHERE u.name = '''+@DestinationTable+''' AND s.name = '''+@DestinationSchema+'''
AND c.name NOT IN (''EffectiveStartDate'',''EffectiveEndDate'',''IsCurrent'',''RowVersion'')'

EXECUTE (@SqlStr)

SET @ChecksumColumns = (SELECT TOP 1 ChecksumCols FROM #ChecksumColumns)
SET @CompareColumns = @ChecksumColumns

-- Create temp staging table
DECLARE @TempHoldingTable VARCHAR(250)
DECLARE @SQLHoldingTable NVARCHAR(MAX)

SET @TempHoldingTable = @DestinationDatabase + '.' + @DestinationSchema + '.' + @DestinationTable + '_SCD2_Temp'

SET @SQLHoldingTable = '
IF OBJECT_ID(''' + @TempHoldingTable + ''') IS NOT NULL
    DROP TABLE ' + @TempHoldingTable

EXEC (@SQLHoldingTable)

-- Load source data into temp table
DECLARE @SQLtempSource NVARCHAR(MAX)

IF (NULLIF(@SourceDistributionkey,'') IS NOT NULL OR @SourceDistributionkey <> '')
BEGIN
    SET @SQLtempSource = 'CREATE TABLE ' + @TempHoldingTable + ' AS SELECT '+@SelectColumns+' FROM '+@SourceTable
END
ELSE
BEGIN
    SET @SQLtempSource = 'CREATE TABLE ' + @TempHoldingTable + ' AS SELECT '+@SelectColumns+' FROM '+@SourceTable
END

IF @OperationName IS NOT NULL
BEGIN
    SET @SQLtempSource = @SQLtempSource + ' WHERE ' + @SourceOperationKey + '=''' + @OperationName + ''''
END

EXEC (@SQLtempSource)

-- Redirect queries to use temp table
SET @SourceTable = @TempHoldingTable

BEGIN TRANSACTION

-- Step 1: Close out existing current records that have changed
-- Set EffectiveEndDate to current date and IsCurrent to 0
DECLARE @SourceColumn VARCHAR(250)
DECLARE @DestinationColumn VARCHAR(250)

SET @SqlStr = '
UPDATE T2
SET EffectiveEndDate = ''' + CONVERT(VARCHAR(30), @EffectiveDate, 121) + ''',
    IsCurrent = 0
FROM ' + @SourceTable + ' AS T1
JOIN ' + @DestinationDatabase + '.' + @DestinationSchema + '.' + @DestinationTable + ' AS T2 ON '

-- Build the join condition on primary key
SET @DestinationStartPos = 1
SET @DestinationStopPos = CHARINDEX(',', @DestinationPrimaryKey, @DestinationStartPos)
SET @DestinationFirstColumn = LTRIM(SUBSTRING(@DestinationPrimaryKey, @DestinationStartPos,
    CASE WHEN @DestinationStopPos = 0 THEN LEN(@DestinationPrimaryKey) - @DestinationStartPos + 1
    ELSE @DestinationStopPos - @DestinationStartPos END))

SET @SourceStartPos = 1
SET @SourceStopPos = CHARINDEX(',', @SourcePrimaryKey, @SourceStartPos)
SET @SourceFirstColumn = LTRIM(SUBSTRING(@SourcePrimaryKey, @SourceStartPos,
    CASE WHEN @SourceStopPos = 0 THEN LEN(@SourcePrimaryKey) - @SourceStartPos + 1
    ELSE @SourceStopPos - @SourceStartPos END))

SET @SqlStr = @SqlStr + 'T1.' + @SourceFirstColumn + ' = T2.' + @DestinationFirstColumn

WHILE @SourceStopPos > 0 AND @DestinationStopPos > 0
BEGIN
    -- Move to next column in both lists
    SET @SourceStartPos = @SourceStopPos + 1
    SET @SourceStopPos = CHARINDEX(',', @SourcePrimaryKey, @SourceStartPos)
    
    SET @DestinationStartPos = @DestinationStopPos + 1
    SET @DestinationStopPos = CHARINDEX(',', @DestinationPrimaryKey, @DestinationStartPos)
    
    -- Extract column names
    SET @SourceColumn = LTRIM(SUBSTRING(@SourcePrimaryKey, @SourceStartPos,
        CASE WHEN @SourceStopPos = 0 THEN LEN(@SourcePrimaryKey) - @SourceStartPos + 1
        ELSE @SourceStopPos - @SourceStartPos END))
    
    SET @DestinationColumn = LTRIM(SUBSTRING(@DestinationPrimaryKey, @DestinationStartPos,
        CASE WHEN @DestinationStopPos = 0 THEN LEN(@DestinationPrimaryKey) - @DestinationStartPos + 1
        ELSE @DestinationStopPos - @DestinationStartPos END))
    
    -- Add to JOIN condition
    SET @SqlStr = @SqlStr + ' AND T1.' + @SourceColumn + ' = T2.' + @DestinationColumn
END
-- Add WHERE clause to only update current records that have changed
-- Use BINARY_CHECKSUM to detect changes efficiently (avoids STRING_AGG 8000 byte limit)
SET @SqlStr = @SqlStr + '
WHERE T2.IsCurrent = 1
AND BINARY_CHECKSUM(T1.' + REPLACE(@CompareColumns, ',', ', T1.') + ') <> BINARY_CHECKSUM(T2.' + REPLACE(@CompareColumns, ',', ', T2.') + ')'

IF @SqlStr IS NOT NULL
BEGIN
    EXEC (@SqlStr)
END

-- Step 2: Insert new versions of changed records
SET @SqlStr = '
INSERT INTO ' + @DestinationDatabase + '.' + @DestinationSchema + '.' + @DestinationTable +
' (' + @InsertColumns + ', EffectiveStartDate, EffectiveEndDate, IsCurrent, RowVersion)
SELECT T1.' + REPLACE(@SelectColumns, ',', ', T1.') + ',
       ''' + CONVERT(VARCHAR(30), @EffectiveDate, 121) + ''' AS EffectiveStartDate,
       ''9999-12-31 23:59:59.999999'' AS EffectiveEndDate,
       1 AS IsCurrent,
       ISNULL(T2.RowVersion, 0) + 1 AS RowVersion
FROM ' + @SourceTable + ' AS T1
JOIN ' + @DestinationDatabase + '.' + @DestinationSchema + '.' + @DestinationTable + ' AS T2 ON '

-- Build the join condition on primary key
SET @DestinationStartPos = 1
SET @DestinationStopPos = CHARINDEX(',', @DestinationPrimaryKey, @DestinationStartPos) - 1
SET @DestinationFirstColumn = LTRIM(SUBSTRING(@DestinationPrimaryKey, @DestinationStartPos,
    CASE WHEN @DestinationStopPos = -1 THEN LEN(@DestinationPrimaryKey) - @DestinationStartPos + 1
    ELSE @DestinationStopPos - @DestinationStartPos + 1 END))

SET @SourceStartPos = 1
SET @SourceStopPos = CHARINDEX(',', @SourcePrimaryKey, @SourceStartPos) - 1
SET @SourceFirstColumn = LTRIM(SUBSTRING(@SourcePrimaryKey, @SourceStartPos,
    CASE WHEN @SourceStopPos = -1 THEN LEN(@SourcePrimaryKey) - @SourceStartPos + 1
    ELSE @SourceStopPos - @SourceStartPos + 1 END))

SET @SqlStr = @SqlStr + 'T1.' + @SourceFirstColumn + ' = T2.' + @DestinationFirstColumn

WHILE @SourceStopPos <> -1
BEGIN
    SET @DestinationStartPos = @DestinationStopPos + 2
    SET @DestinationStopPos = CHARINDEX(',', @DestinationPrimaryKey, @DestinationStartPos) - 1

    SET @SourceStartPos = @SourceStopPos + 2
    SET @SourceStopPos = CHARINDEX(',', @SourcePrimaryKey, @SourceStartPos) - 1

    SET @SqlStr = @SqlStr + ' AND T1.' + LTRIM(SUBSTRING(@SourcePrimaryKey, @SourceStartPos,
        CASE WHEN @SourceStopPos = -1 THEN LEN(@SourcePrimaryKey) - @SourceStartPos + 1
        ELSE @SourceStopPos - @SourceStartPos + 1 END))
    SET @SqlStr = @SqlStr + ' = T2.' + LTRIM(SUBSTRING(@DestinationPrimaryKey, @DestinationStartPos,
        CASE WHEN @DestinationStopPos = -1 THEN LEN(@DestinationPrimaryKey) - @DestinationStartPos + 1
        ELSE @DestinationStopPos - @DestinationStartPos + 1 END))
END

-- Add WHERE clause to only insert changed records
-- Use BINARY_CHECKSUM to detect changes efficiently
SET @SqlStr = @SqlStr + '
WHERE T2.IsCurrent = 0
AND T2.EffectiveEndDate = ''' + CONVERT(VARCHAR(30), @EffectiveDate, 121) + '''
AND BINARY_CHECKSUM(T1.' + REPLACE(@CompareColumns, ',', ', T1.') + ') <> BINARY_CHECKSUM(T2.' + REPLACE(@CompareColumns, ',', ', T2.') + ')'

IF @SqlStr IS NOT NULL
BEGIN
    EXEC (@SqlStr)
END

-- Step 3: Insert completely new records (not in destination at all)
SET @SqlStr = '
INSERT INTO ' + @DestinationDatabase + '.' + @DestinationSchema + '.' + @DestinationTable +
' (' + @InsertColumns + ', EffectiveStartDate, EffectiveEndDate, IsCurrent, RowVersion)
SELECT DISTINCT T1.' + REPLACE(@SelectColumns, ',', ', T1.') + ',
       ''' + CONVERT(VARCHAR(30), @EffectiveDate, 121) + ''' AS EffectiveStartDate,
       ''9999-12-31 23:59:59.999999'' AS EffectiveEndDate,
       1 AS IsCurrent,
       1 AS RowVersion
FROM ' + @SourceTable + ' AS T1
LEFT JOIN ' + @DestinationDatabase + '.' + @DestinationSchema + '.' + @DestinationTable + ' AS T2 ON '

-- Build the join condition on primary key
SET @DestinationStartPos = 1
SET @DestinationStopPos = CHARINDEX(',', @DestinationPrimaryKey, @DestinationStartPos) - 1
SET @DestinationFirstColumn = LTRIM(SUBSTRING(@DestinationPrimaryKey, @DestinationStartPos,
    CASE WHEN @DestinationStopPos = -1 THEN LEN(@DestinationPrimaryKey) - @DestinationStartPos + 1
    ELSE @DestinationStopPos - @DestinationStartPos + 1 END))

SET @SourceStartPos = 1
SET @SourceStopPos = CHARINDEX(',', @SourcePrimaryKey, @SourceStartPos) - 1
SET @SourceFirstColumn = LTRIM(SUBSTRING(@SourcePrimaryKey, @SourceStartPos,
    CASE WHEN @SourceStopPos = -1 THEN LEN(@SourcePrimaryKey) - @SourceStartPos + 1
    ELSE @SourceStopPos - @SourceStartPos + 1 END))

SET @SqlStr = @SqlStr + 'T1.' + @SourceFirstColumn + ' = T2.' + @DestinationFirstColumn

WHILE @SourceStopPos <> -1
BEGIN
    SET @DestinationStartPos = @DestinationStopPos + 2
    SET @DestinationStopPos = CHARINDEX(',', @DestinationPrimaryKey, @DestinationStartPos) - 1

    SET @SourceStartPos = @SourceStopPos + 2
    SET @SourceStopPos = CHARINDEX(',', @SourcePrimaryKey, @SourceStartPos) - 1

    SET @SqlStr = @SqlStr + ' AND T1.' + LTRIM(SUBSTRING(@SourcePrimaryKey, @SourceStartPos,
        CASE WHEN @SourceStopPos = -1 THEN LEN(@SourcePrimaryKey) - @SourceStartPos + 1
        ELSE @SourceStopPos - @SourceStartPos + 1 END))
    SET @SqlStr = @SqlStr + ' = T2.' + LTRIM(SUBSTRING(@DestinationPrimaryKey, @DestinationStartPos,
        CASE WHEN @DestinationStopPos = -1 THEN LEN(@DestinationPrimaryKey) - @DestinationStartPos + 1
        ELSE @DestinationStopPos - @DestinationStartPos + 1 END))
END

SET @SqlStr = @SqlStr + '
WHERE T2.' + @DestinationFirstColumn + ' IS NULL'

IF @SqlStr IS NOT NULL
BEGIN
    EXEC (@SqlStr)
END

COMMIT TRANSACTION

-- Clean up temp table
EXEC DW_Developer.usp_DropWorkTable @TempHoldingTable

-- Clean up temp objects
IF OBJECT_ID('tempdb..#SelectColumns') IS NOT NULL
DROP TABLE #SelectColumns

IF OBJECT_ID('tempdb..#InsertColumns') IS NOT NULL
DROP TABLE #InsertColumns

IF OBJECT_ID('tempdb..#ChecksumColumns') IS NOT NULL
DROP TABLE #ChecksumColumns

SET @DateValue = GETDATE();
SELECT
    @DateValue = CSTDateValue
FROM
    DW_Developer.fn_GetDate(@DateValue);

INSERT INTO DW_Developer.AuditLog
    VALUES
    (
      @String, @DateValue, @User, 'SCD2 Process Complete'
    );

INSERT INTO DW_Developer.TableDictionary_UpdateLog
    VALUES (@DestinationDatabase, @DestinationSchema, @DestinationTable, @DateValue)

END TRY

BEGIN CATCH

    DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
    SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(),16)
    SET @ErrorState = ISNULL(ERROR_STATE(),1)

    SET @DateValue = GETDATE();
    SELECT
        @DateValue = CSTDateValue
    FROM
        DW_Developer.fn_GetDate(@DateValue);

    INSERT INTO DW_Developer.AuditLog
        VALUES (@String, @DateValue, @User, @ErrorMessage)
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)

    IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION

END CATCH

END
GO


