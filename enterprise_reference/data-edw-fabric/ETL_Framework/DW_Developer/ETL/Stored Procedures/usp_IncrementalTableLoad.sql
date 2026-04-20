
CREATE PROC [DW_Developer].[usp_IncrementalTableLoad]
    @DestinationDatabase VARCHAR(150),
    @DestinationSchema   VARCHAR(150),
    @DestinationTable    VARCHAR(150),
	@OperationName    VARCHAR(100)
    AS

/*----------------   Procedure:  [DW_Developer].[usp_IncrementalTableLoadTable] ---------------------------------------

 Description: To upsert the recent data to Gold Layer tables from an Source tables using primary key values and such
 

 
 - The columns order and types in the Source tables must match the Destination tables... with no additional or missing columns
   but the column names can be different
 
 - The primary key is used to test if the Source table row exists in the Destination table
   The tbkPrimaryKey values for both the Source and Destination tables must be populated in table dictionary
   Both tables need the same PK combinations in the same order (names can be different)
 
   - For UPSERT/INSERT/DELINSERT/CDC we need matching distribution keys in both the source and destination with at least 
   one common column within the primary key.
   If Alternate key is used to override the primary key, then it needs to have a common column with it instead
   This will avoid data shuffles on the source and destination tables.

 - The Source Source table reference is pulled from ReplicatedSource in table Dictionary
 
 - DateKey values must be populated in the dictionary for both the Source and Destination tables for the date based ETL methods.
   This can be left blank for all other methods 
 
 - One of the following ETL Methods must be populated in the Destination table's dictionary row for UpdateMethod

      'Upsert' - Using the Primary Key values, Update matching, then insert missing rows into the Enhanced table
	  
	  'Insert' - using the primary Key values, insert what's missing

	  'Append' - Just append the data from the Source table  (Probably shouldn't be used for Gold Layer feeds)

	  'DateKey' - Needs the primary key and an inline date column which is used to compare the Destination table to the 
	             extended table to delete any rows that changed, then append any that are missing

				 This method assumes rows can not be deleted and all updates trigger an update to a datekey value in 
				 an in-line audit field

	 'DateRange' - Only needs date columns to identify rows that fall within the range to delete then insert 
	        
			    This is the only type that uses the DateRangeDays value basing the date range on the number of days from 
				current date... or if a 0 is passed, the min-max dates from the Source table will determine the date range 
				
				This method assumes rows can be updatd or deleted within a recent time frame and the range covers any changes
				that could occur.... this also is a method to use when there is no primary key to do insert or upsert logic

     'Identity' - Using an auto-incrimenting identity key from the source, this method will only append rows with a 
	             key value greater than the current max value that already exists in the Destination table.  This method assumes
				 rows can not be updated or deleted at the source
				 Identity will pass back to the calling program the new Max(Identity) value

     'CDC'      - Currently coded for DB2 journals only.
	               applies change data capture journal using Upsert like logic.   It first deletes based on PK values and then inserts
	               any after images from Inserts and Updates 'UP' - Update After image,'PX','PT' - Inserts         
     
	 'DelInsert' - Using the Primary Key values, Delete matching, then append the data from the Source table into Enhanced table.


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
      @String, @DateValue, @User, 'Process Start'
    );

  
BEGIN TRY

-- Declare Variables
DECLARE @SqlStr VARCHAR(MAX), 
		@ErrSqlStr VARCHAR(300), 
		@DestinationPrimaryKey VARCHAR(800), 
		@DestinationAlternateKey VARCHAR(800), 
 		@SourceSchemaName VARCHAR(200), 
		@SourceTableName VARCHAR(200),
		@DestinationDateKey VARCHAR(100),
		@SourceSchema VARCHAR(200),
		@SourceTable VARCHAR(200), 
 		@SourceDateKey VARCHAR(200),
		@SourcePrimaryKey VARCHAR(800),
		@SourceAlternateKey VARCHAR(800),
		@DateRangeDays [INT],
		@UpdateMethod VARCHAR(20),
		@SourceStartPos INT,
		@SourceStopPos Int,
		@SourceKeyStartPos INT,
		@SourceKeyStopPos Int,
		@DestinationStartPos INT,
		@DestinationStopPos Int,
		@DestinationKeyStartPos INT,
		@DestinationKeyStopPos Int,
		@DestinationFirstColumn Varchar(100),
		@SourceFirstColumn Varchar(100),
		@DestinationKeyFirstColumn Varchar(100),
		@SourceKeyFirstColumn Varchar(100),
		@SourcePlatform VARCHAR(25),
		@SelectColumns Varchar(MAX),
		@InsertColumns varchar(MAX),
		@DataLakeObject VARCHAR(100),
		@SelectColumnList VARCHAR(MAX),
		@SourceOperationKey VARCHAR(100),
		@DestinationOperationKey VARCHAR(100),
		/* Change by Padmanabhan 28/10/2025 for CDC Logic */
		/* Begin */
		@CDCDeleteSource NVARCHAR(MAX),
		@CDCDeleteSourceTable VARCHAR(200),
		@SourceDistributionkey  VARCHAR(500)
		/* End */
		

--- lookup the source table name and the date columns for managing the updates
SELECT
       @SourceTable             = T1.ReplicatedSource,    --fully qualified (database,schema,table/view)
       @DestinationPrimaryKey   = COALESCE(T1.AlternateKey,T1.PrimaryKey), 
	   @DestinationAlternateKey = T1.AlternateKey,
   	   @DestinationDateKey      = T1.DateKey,
       @SourcePrimaryKey        = COALESCE(T2.AlternateKey,T2.PrimaryKey),
	   @SourceAlternateKey      = T2.AlternateKey,
	   @SourceDateKey           = T2.DateKey,
	   @DateRangeDays           = ISNULL(T1.DateRangeDays,0),
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


 -- Getting Source Schema and table name

SET @SourceSchemaName = SUBSTRING(@SourceTable,1,CHARINDEX('.',@SourceTable)-1)
SET @SourceTableName  = SUBSTRING(@SourceTable,CHARINDEX('.',@SourceTable)+1 ,200)
SET @SourceTable = @DestinationDatabase+'.'+@SourceTable --Resetting Source Table name with three part nameing

DECLARE @IncrementalDateFrom AS DATETIME2(6),
	    @IncrementalDateTo   AS DATETIME2(6)
    SET @IncrementalDateFrom = DATEADD(DAY,-1 * @DateRangeDays,@DateValue)
    SET @IncrementalDateTo   = DATEADD(DAY,1, @DateValue)

IF OBJECT_ID('tempdb..#SelectColumns') IS NOT NULL
DROP TABLE #SelectColumns

    CREATE  Table #SelectColumns  ( ColumnNames VARCHAR(MAX) )

   --- If no select column list defined in Tabledictionary, use the source structure 
IF @SelectColumnList is not Null
	BEGIN
		SET @SelectColumns = @SelectColumnList
	END
ELSE

	/* Change by Padmanabhan 28/10/2025 for CDC Logic*/
	/* Begin */
	--- grab the source    (filter out any AS400 standard journal columns)
	IF  @SourcePlatform='DB2' AND @UpdateMethod IN ('CDC')
	BEGIN
		
		/*
		SELECT  @SelectColumns =STRING_AGG(Concat('[',CAST(c.name as varchar(max)),']'),',')  within group (Order by column_id) 
		 FROM sys.tables u
		 join sys.schemas s on s.schema_id = u.schema_id
		 join sys.columns c on  u.object_id = c.object_id
			where u.name = SUBSTRING(@SourceTable,CHARINDEX('.',@SourceTable)+1 ,200)
			and s.name =@SourceSchema
			and c.name not IN ('JOENTL','JOSEQN','JOCODE','JOENTT','JODATE','JOTIME','JOJOB','JOUSER','JONBR','JOPGM','JOOBJ','JOLIB','JOMBR','JOCTRR','JOFLAG','JOCCID','JOUSPF','JOSYNM','JOINCDAT','JOMINESD','JORES')
		*/

		IF OBJECT_ID('tempdb..#ExculedColumns') IS NOT NULL
			DROP TABLE #ExculedColumns
			
		CREATE  Table  #ExculedColumns (ColumnNames VARCHAR(25))

		INSERT INTO #ExculedColumns (ColumnNames) VALUES
		('JOENTL'),('JOSEQN'),('JOCODE'),('JOENTT'),('JODATE'),('JOTIME'),('JOJOB'),('JOUSER'),('JONBR'),('JOPGM'),
		('JOOBJ'),('JOLIB'),('JOMBR'),('JOCTRR'),('JOFLAG'),('JOCCID'),('JOUSPF'),('JOSYNM'),('JOINCDAT'),('JOMINESD'),('JORES')

		SET @SqlStr =  '
         INSERT INTO #SelectColumns 
         SELECT  STRING_AGG(Concat(''['',CAST(c.name as varchar(max)),'']''),'','')  within group (Order by column_id) 
		 FROM ' + QUOTENAME(@DestinationDatabase) + '.sys.tables u
		 join ' + QUOTENAME(@DestinationDatabase) + '.sys.schemas s on s.schema_id = u.schema_id
		 join ' + QUOTENAME(@DestinationDatabase) + '.sys.columns c on  u.object_id = c.object_id
			where u.name = '''+@DestinationTable+''' and s.name = '''+@SourceSchema+'''
			and c.name not IN (SELECT ColumnNames COLLATE SQL_Latin1_General_CP1_CI_AS FROM tempdb..#ExculedColumns)'
		
		EXECUTE (@SqlStr)
		SET @SelectColumns=(SELECT ColumnNames FROM #SelectColumns)
		DROP TABLE  #SelectColumns
		DROP TABLE  #ExculedColumns


	END
	/* End */
	ELSE
    BEGIN

		--SELECT  @SelectColumns =STRING_AGG(Concat('[',CAST(c.name as varchar(max)),']'),',')  within group (Order by column_id) 
		--	 FROM sys.tables u
		--	 join sys.schemas s on s.schema_id = u.schema_id
		--	 join sys.columns c on  u.object_id = c.object_id
		--		where u.name = @DestinationTable
		--		--where u.name = SUBSTRING(@SourceTable,CHARINDEX('.',@SourceTable)+1 ,200)
		--		and s.name =@SourceSchema

				SET @SqlStr = 
				'
							INSERT INTO #SelectColumns 
							SELECT STRING_AGG(CONCAT(''['', CAST(c.name AS VARCHAR(MAX)), '']''), '','') WITHIN GROUP (ORDER BY column_id)  AS SelectColumns
							FROM ' + QUOTENAME(@DestinationDatabase) + '.sys.tables u
							JOIN ' + QUOTENAME(@DestinationDatabase) + '.sys.schemas s ON s.schema_id = u.schema_id
							JOIN ' + QUOTENAME(@DestinationDatabase) + '.sys.columns c ON u.object_id = c.object_id
							WHERE u.name = '''+@DestinationTable+''' AND s.name = '''+@SourceSchema+'''
				'

				EXECUTE (@SqlStr)
				SET @SelectColumns=(SELECT ColumnNames FROM #SelectColumns)
				DROP TABLE  #SelectColumns
    
	END


-- grab destination columns

--SELECT  @InsertColumns =STRING_AGG(Concat('[',CAST(c.name as varchar(max)),']'),',')  within group (Order by column_id) 
-- FROM sys.tables u
-- join sys.schemas s on s.schema_id = u.schema_id
-- join sys.columns c on  u.object_id = c.object_id
--    where u.name = @DestinationTable and s.name =@DestinationSchema
--	and is_identity <> 1
    
     IF OBJECT_ID('tempdb..#InsertColumns') IS NOT NULL
		DROP TABLE #InsertColumns

			 CREATE  Table #InsertColumns  ( InsertColumns VARCHAR(MAX) )
				SET @SqlStr = 
				'
				INSERT INTO #InsertColumns
				SELECT  STRING_AGG(CONCAT(''['', CAST(c.name AS VARCHAR(MAX)), '']''), '','') WITHIN GROUP (ORDER BY column_id)  AS InsertColumns
				FROM ' + QUOTENAME(@DestinationDatabase) + '.sys.tables u
				JOIN ' + QUOTENAME(@DestinationDatabase) + '.sys.schemas s ON s.schema_id = u.schema_id
				JOIN ' + QUOTENAME(@DestinationDatabase) + '.sys.columns c ON u.object_id = c.object_id
				WHERE u.name = '''+@DestinationTable+''' AND s.name = '''+@DestinationSchema+'''
				'
				EXECUTE (@SqlStr)
				SET @InsertColumns=(SELECT InsertColumns FROM #InsertColumns)
				--DROP TABLE #InsertColumns
					
/* Change by Padmanabhan 28/10/2025 for CDC Logic*/
/* Begin */
-- load a Temp Table from the external table
DECLARE @TempHoldingTable VARCHAR(250)
DECLARE @SQLHoldingTable NVARCHAR(MAX)

SET @TempHoldingTable = @DestinationDatabase + '.' + @DestinationSchema + '.' + @DestinationTable + '_Temp'

SET @SQLHoldingTable = 
'
IF OBJECT_ID(''' + @TempHoldingTable + ''') IS NOT NULL
	DROP TABLE ' + @TempHoldingTable + '
'

EXEC (@SQLHoldingTable)


DECLARE @SQLtempSource NVARCHAR(MAX),
        @TempSourceTable VARCHAR(200),
	    @TempDestinationTable VARCHAR(200)

IF  @SourcePlatform='DB2' AND @UpdateMethod IN ('CDC')
       
	BEGIN
	
	 --Create tempSource table based on the Distribution Key to Define the HASH key from TableDictionary Metdata or Default it to JOENTT if not Specified.

	IF (NULLIF(@SourceDistributionkey,'') IS NOT NULL OR @SourceDistributionkey <> '')
	   BEGIN
        -- Removed with clause in the below two blocks
	   SET @SQLtempSource = 'CREATE TABLE ' + @TempHoldingTable + ' AS SELECT [JOENTT],[JOTIME],[JOSEQN], '+@SelectColumns+'
	   FROM '+@SourceTable+' WHERE JOENTT IN (''UP'',''PT'',''DL'',''PX'',''UB'');'
	   END
	   ELSE
	   BEGIN
       SET @SQLtempSource = 'CREATE TABLE ' + @TempHoldingTable + ' AS SELECT [JOENTT],[JOTIME],[JOSEQN], '+@SelectColumns+' 
	   FROM '+@SourceTable+' WHERE JOENTT IN (''UP'',''PT'',''DL'',''PX'',''UB'');'
       END

	SET @TempSourceTable      = @TempHoldingTable
	SET @TempDestinationTable = @TempHoldingTable

	---Delete from the #tempSource any PT and UP rows with matching AlternateKeys and time stamps prior to any DEL rows

	SET @SQLtempSource =@SQLtempSource +' DELETE FROM '+@TempDestinationTable+ ' WHERE EXISTS '				
		
	   SET @DestinationStartPos = 1
	   SET @DestinationStopPos = CHARINDEX(',',@DestinationPrimaryKey,@DestinationStartPos)-1
	   SET @DestinationFirstColumn = LTRIM(SUBSTRING(@DestinationPrimaryKey,@DestinationStartPos, CASE WHEN @DestinationStopPos= -1 THEN LEN(@DestinationPrimaryKey)-@DestinationStartPos+1 ELSE @DestinationStopPos-@DestinationStartPos+1 END))
	   
	   SET @SourceStartPos = 1
	   SET @SourceStopPos = CHARINDEX(',',@SourcePrimaryKey,@SourceStartPos)-1
	   SET @SourceFirstColumn = LTRIM(SUBSTRING(@SourcePrimaryKey,@SourceStartPos, CASE WHEN @SourceStopPos= -1 THEN LEN(@SourcePrimaryKey)-@SourceStartPos+1 ELSE @SourceStopPos-@SourceStartPos+1 END))
	   
	   SET @SQLtempSource = @SQLtempSource+ '(SELECT '+@DestinationFirstColumn+' FROM '+@TempSourceTable +' T1 '+ 'WHERE '+@TempDestinationTable+'.'+@DestinationFirstColumn+'= T1.'+@SourceFirstColumn

	   WHILE @SourceStopPos <> - 1
		BEGIN 

			SET @DestinationStartPos=@DestinationStopPos+2
			SET @DestinationStopPos=  CHARINDEX(',',@DestinationPrimaryKey,@DestinationStartPos)-1
			SET @SQLtempSource = @SQLtempSource+' AND '+@TempDestinationTable+'.'+ LTRIM(SUBSTRING(@DestinationPrimaryKey,@DestinationStartPos, CASE WHEN @DestinationStopPos = -1 THEN LEN(@DestinationPrimaryKey)-@DestinationStartPos+1 ELSE @DestinationStopPos-@DestinationStartPos+1 END))

			SET @SourceStartPos=@SourceStopPos+2
			SET @SourceStopPos=  CHARINDEX(',',@SourcePrimaryKey,@SourceStartPos)-1
			SET @SQLtempSource = @SQLtempSource+' = T1.'+ LTRIM(SUBSTRING(@SourcePrimaryKey,@SourceStartPos, CASE WHEN @SourceStopPos = -1 THEN LEN(@SourcePrimaryKey)-@SourceStartPos+1 ELSE @SourceStopPos-@SourceStartPos+1 END))

	    END
		
    SET @SQLtempSource=@SQLtempSource +' AND T1.JOENTT IN (''DL'',''UB'') AND '+ @TempDestinationTable + '.JOSEQN < T1.JOSEQN'+ ')' + 'AND '+ @TempDestinationTable + '.JOENTT IN (''UP'',''PT'',''PX'');'

	---Delete from the #tempSource any remaining PT and UP rows that have duplicate Alternatekeys amongst themselves retaining the last one based on timestamp

	SET @SQLtempSource =@SQLtempSource +'WITH DeleteRows AS (
		SELECT row_number() OVER (PARTITION BY '+@SourcePrimaryKey+' ORDER BY JOSEQN DESC) as RowID,JOENTT,JOTIME,'+@SelectColumns +'
		FROM '+@TempSourceTable +' WHERE JOENTT IN (''UP'',''PT'',''PX''))
				 
	    DELETE FROM DeleteRows WHERE rowID <> 1;'

END

ELSE
       --Create tempSource table based on the Distribution Key to Define Either  HASH or ROUND_ROBIN

BEGIN
	   IF (NULLIF(@SourceDistributionkey,'') IS NOT NULL OR @SourceDistributionkey <> '')
	   BEGIN
       --Removed with clause (  WITH ( DISTRIBUTION = HASH('+@SourceDistributionkey+'), HEAP) ) in below two blocks
	   SET @SQLtempSource = 'CREATE TABLE ' + @TempHoldingTable + ' AS SELECT '+@SelectColumns+' FROM '+@SourceTable
	   END
	   ELSE
	   BEGIN
       SET @SQLtempSource = 'CREATE TABLE ' + @TempHoldingTable + ' AS SELECT '+@SelectColumns+' FROM '+@SourceTable
       END
END

EXEC (@SQLtempSource)

-- redirect queries to use new Temp Table instead of the external table
SET @SourceTable = @TempHoldingTable

/* End */






BEGIN TRANSACTION


/* Change by Padmanabhan 28/10/2025 for CDC Logic*/
/* Begin */
IF @UpdateMethod IN ('CDC', 'DELINSERT')
BEGIN

     IF @UpdateMethod IN ('DELINSERT')
	 BEGIN
     
		SET @SourcePrimaryKey      = @SourceAlternateKey
		SET @DestinationPrimaryKey = @DestinationAlternateKey
	END

	SET @SqlStr = ' DELETE FROM '+@DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable+ ' WHERE EXISTS '				
		
    SET @DestinationStartPos = 1
    SET @DestinationStopPos = CHARINDEX(',',@DestinationPrimaryKey,@DestinationStartPos)-1
	SET @DestinationFirstColumn = LTRIM(SUBSTRING(@DestinationPrimaryKey,@DestinationStartPos, CASE WHEN @DestinationStopPos= -1 THEN LEN(@DestinationPrimaryKey)-@DestinationStartPos+1 ELSE @DestinationStopPos-@DestinationStartPos+1 END))
	   
	SET @SourceStartPos = 1
	SET @SourceStopPos = CHARINDEX(',',@SourcePrimaryKey,@SourceStartPos)-1
	SET @SourceFirstColumn = LTRIM(SUBSTRING(@SourcePrimaryKey,@SourceStartPos, CASE WHEN @SourceStopPos= -1 THEN LEN(@SourcePrimaryKey)-@SourceStartPos+1 ELSE @SourceStopPos-@SourceStartPos+1 END))
	   
	SET @SqlStr = @SqlStr+ '(SELECT '+@DestinationFirstColumn+' FROM '+@SourceTable +' T1 '+ 'WHERE '+@DestinationTable+'.'+@DestinationFirstColumn+'= T1.'+@SourceFirstColumn 

	WHILE @SourceStopPos <> - 1
		BEGIN 

			SET @DestinationStartPos=@DestinationStopPos+2
			SET @DestinationStopPos=  CHARINDEX(',',@DestinationPrimaryKey,@DestinationStartPos)-1
			SET @SqlStr = @SqlStr+' AND '+@DestinationTable+'.'+ LTRIM(SUBSTRING(@DestinationPrimaryKey,@DestinationStartPos, CASE WHEN @DestinationStopPos = -1 THEN LEN(@DestinationPrimaryKey)-@DestinationStartPos+1 ELSE @DestinationStopPos-@DestinationStartPos+1 END))

			SET @SourceStartPos=@SourceStopPos+2
			SET @SourceStopPos=  CHARINDEX(',',@SourcePrimaryKey,@SourceStartPos)-1
			SET @SqlStr = @SqlStr+' = T1.'+ LTRIM(SUBSTRING(@SourcePrimaryKey,@SourceStartPos, CASE WHEN @SourceStopPos = -1 THEN LEN(@SourcePrimaryKey)-@SourceStartPos+1 ELSE @SourceStopPos-@SourceStartPos+1 END))

		END

     IF @UpdateMethod IN ('DELINSERT')
	   BEGIN		
			SET   @SqlStr = @SqlStr + ' )'   
	   END
	 ELSE
	   BEGIN
	        SET @SqlStr = @SqlStr + ' AND T1.JOENTT IN (''DL''))'
	 END


	IF @SqlStr IS NOT NULL
		BEGIN
			EXEC (@SqlStr)
		END
	ELSE
		BEGIN
			SET @ErrSqlStr='Missing values in Metadata for data feed to '+@DestinationTable
			RAISERROR(@ErrSqlStr,16,1)
		END 
END
/* End */

IF @UpdateMethod IN ('DateRange')

BEGIN

SET @SqlStr = ' DELETE FROM '+@DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable+ ' WHERE NOT EXISTS '				
		
	   SET @DestinationStartPos = 1
	   SET @DestinationStopPos = CHARINDEX(',',@DestinationPrimaryKey,@DestinationStartPos)-1
	   SET @DestinationFirstColumn = LTRIM(SUBSTRING(@DestinationPrimaryKey,@DestinationStartPos, CASE WHEN @DestinationStopPos= -1 THEN LEN(@DestinationPrimaryKey)-@DestinationStartPos+1 ELSE @DestinationStopPos-@DestinationStartPos+1 END))
	   
	   SET @SourceStartPos = 1
	   SET @SourceStopPos = CHARINDEX(',',@SourcePrimaryKey,@SourceStartPos)-1
	   SET @SourceFirstColumn = LTRIM(SUBSTRING(@SourcePrimaryKey,@SourceStartPos, CASE WHEN @SourceStopPos= -1 THEN LEN(@SourcePrimaryKey)-@SourceStartPos+1 ELSE @SourceStopPos-@SourceStartPos+1 END))
	   
	   SET @SqlStr = @SqlStr+ '(SELECT '+@DestinationFirstColumn+' FROM '+@SourceTable +' T1 '+ 'WHERE '+@DestinationTable+'.'+@DestinationFirstColumn+'= T1.'+@SourceFirstColumn

	   WHILE @SourceStopPos <> - 1
		BEGIN 

			SET @DestinationStartPos=@DestinationStopPos+2
			SET @DestinationStopPos=  CHARINDEX(',',@DestinationPrimaryKey,@DestinationStartPos)-1
			SET @SqlStr = @SqlStr+' AND '+@DestinationTable+'.'+ LTRIM(SUBSTRING(@DestinationPrimaryKey,@DestinationStartPos, CASE WHEN @DestinationStopPos = -1 THEN LEN(@DestinationPrimaryKey)-@DestinationStartPos+1 ELSE @DestinationStopPos-@DestinationStartPos+1 END))

			SET @SourceStartPos=@SourceStopPos+2
			SET @SourceStopPos=  CHARINDEX(',',@SourcePrimaryKey,@SourceStartPos)-1
			SET @SqlStr = @SqlStr+' = T1.'+ LTRIM(SUBSTRING(@SourcePrimaryKey,@SourceStartPos, CASE WHEN @SourceStopPos = -1 THEN LEN(@SourcePrimaryKey)-@SourceStartPos+1 ELSE @SourceStopPos-@SourceStartPos+1 END))

		END

		SET @SqlStr=@SqlStr + ')'
	

		IF @OperationName IS NOT NULL 
		BEGIN
		SET @SqlStr=@SqlStr + ' AND '+@SourceOperationKey+'='''+@OperationName+''''
		END

			   
		IF  @DateRangeDays > 0
		
		BEGIN
		SET @SqlStr = @SqlStr+
		' AND ('+@DestinationTable+'.'+@DestinationDateKey+ ' BETWEEN ''' +CONVERT(VARCHAR(20),@IncrementalDateFrom,110)+''' and '''+CONVERT(VARCHAR(20),@IncrementalDateTo,110)+''''+')'
		END

		ELSE
		
		BEGIN
		SET @SqlStr = @SqlStr+
		'AND ('+@DestinationTable+'.'+ @DestinationDateKey+ ' >= (SELECT MIN('+@SourceDateKey+') FROM '+@SourceTable+') 
		  AND '+@DestinationTable+'.'+ @DestinationDateKey+ ' <= (SELECT MAX('+@SourceDateKey+') FROM '+@SourceTable+'))'
			
		END

IF @SqlStr IS NOT NULL
		BEGIN
		  EXEC (@SqlStr)
		END
	  ELSE
	   BEGIN
		 SET @ErrSqlStr='Missing values in Metadata for data feed to '+@DestinationTable
		 RAISERROR(@ErrSqlStr,16,1)
	   END 

END


/* Change by Padmanabhan 28/10/2025 for CDC Logic*/
/* Begin */
-- Delete Rows in Destination table for rows that have been changed
IF @UpdateMethod in ('Upsert','DateKey','DateRange','CDC')
/* End */
BEGIN
	    SET @SqlStr = 'UPDATE T2 SET '

		SET @DestinationStartPos = 1
		SET @DestinationStopPos  = CHARINDEX(',',@InsertColumns,@DestinationStartPos)-1
		SET @DestinationFirstColumn = 'T2.'+LTRIM(SUBSTRING(@InsertColumns,@DestinationStartPos, CASE WHEN @DestinationStopPos= -1 THEN LEN(@InsertColumns)-@DestinationStartPos+1 ELSE @DestinationStopPos-@DestinationStartPos+1 END))

		SET @SourceStartPos = 1
		SET @SelectColumns = REPLACE (@SelectColumns,'DISTINCT','')
		SET @SourceStopPos = CHARINDEX(',',@SelectColumns,@SourceStartPos)-1
		SET @SourceFirstColumn = 'T1.'+LTRIM(SUBSTRING(@SelectColumns,@SourceStartPos, CASE WHEN @SourceStopPos= -1 THEN LEN(@SelectColumns)-@SourceStartPos+1 ELSE @SourceStopPos-@SourceStartPos+1 END))
		
		SET @SqlStr = @SqlStr + @DestinationFirstColumn + ' = ' + @SourceFirstColumn

		WHILE @SourceStopPos <> - 1
		
		BEGIN 

			SET @DestinationStartPos=@DestinationStopPos+2
			SET @DestinationStopPos=  CHARINDEX(',',@InsertColumns,@DestinationStartPos)-1
			SET @SqlStr = @SqlStr+' , T2.'+ LTRIM(SUBSTRING(@InsertColumns,@DestinationStartPos, CASE WHEN @DestinationStopPos = -1 THEN LEN(@InsertColumns)-@DestinationStartPos+1 ELSE @DestinationStopPos-@DestinationStartPos+1 END))

			SET @SourceStartPos=@SourceStopPos+2
			SET @SourceStopPos=  CHARINDEX(',',@SelectColumns,@SourceStartPos)-1
			SET @SqlStr = @SqlStr+' = T1.'+ LTRIM(SUBSTRING(@SelectColumns,@SourceStartPos, CASE WHEN @SourceStopPos = -1 THEN LEN(@SelectColumns)-@SourceStartPos+1 ELSE @SourceStopPos-@SourceStartPos+1 END))

		END

		SET @SqlStr = @SqlStr +' FROM '+ @SourceTable +' AS T1 JOIN ' + @DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable + ' AS T2 ON '

		SET @DestinationKeyStartPos = 1
		SET @DestinationKeyStopPos = CHARINDEX(',',@DestinationPrimaryKey,@DestinationKeyStartPos)-1
		SET @DestinationKeyFirstColumn = 'T1.'+LTRIM(SUBSTRING(@DestinationPrimaryKey,@DestinationKeyStartPos, CASE WHEN @DestinationKeyStopPos= -1 THEN LEN(@DestinationPrimaryKey)-@DestinationKeyStartPos+1 ELSE @DestinationKeyStopPos-@DestinationKeyStartPos+1 END))

		SET @SourceKeyStartPos = 1
		SET @SourceKeyStopPos = CHARINDEX(',',@SourcePrimaryKey,@SourceKeyStartPos)-1
		SET @SourceKeyFirstColumn = 'T2.'+LTRIM(SUBSTRING(@SourcePrimaryKey,@SourceKeyStartPos, CASE WHEN @SourceKeyStopPos= -1 THEN LEN(@SourcePrimaryKey)-@SourceKeyStartPos+1 ELSE @SourceKeyStopPos-@SourceKeyStartPos+1 END))
		
		SET @SqlStr = @SqlStr + @SourceKeyFirstColumn +' = ' + @DestinationKeyFirstColumn

	    WHILE @SourceKeyStopPos <> - 1
		
		BEGIN 

			SET @DestinationKeyStartPos=@DestinationKeyStopPos+2
			SET @DestinationKeyStopPos=  CHARINDEX(',',@DestinationPrimaryKey,@DestinationKeyStartPos)-1
			SET @SqlStr = @SqlStr+' AND T2.'+ LTRIM(SUBSTRING(@DestinationPrimaryKey,@DestinationKeyStartPos, CASE WHEN @DestinationKeyStopPos = -1 THEN LEN(@DestinationPrimaryKey)-@DestinationKeyStartPos+1 ELSE @DestinationKeyStopPos-@DestinationKeyStartPos+1 END))

			SET @SourceKeyStartPos=@SourceKeyStopPos+2
			SET @SourceKeyStopPos=  CHARINDEX(',',@SourcePrimaryKey,@SourceKeyStartPos)-1
			SET @SqlStr = @SqlStr+' = T1.'+ LTRIM(SUBSTRING(@SourcePrimaryKey,@SourceKeyStartPos, CASE WHEN @SourceKeyStopPos = -1 THEN LEN(@SourcePrimaryKey)-@SourceKeyStartPos+1 ELSE @SourceKeyStopPos-@SourceKeyStartPos+1 END))

		END

	/* Change by Padmanabhan 28/10/2025 for CDC Logic*/
	/* Begin */
	IF @UpdateMethod = 'CDC'
	BEGIN
		SET @SqlStr = @SqlStr + ' WHERE T1.JOENTT IN (''UP'',''PT'',''PX'')'
	END
	/* End */
	
	IF @UpdateMethod = 'DateKey' 
  	  BEGIN
		   SET @SqlStr = @SqlStr+ ' WHERE T2.'+ @DestinationDateKey+'<> T1.'+@SourceDateKey
	  END

	IF @UpdateMethod ='DateRange'
	  BEGIN
		 
		 IF @DateRangeDays > 0
		  BEGIN		
				SET @SqlStr = @SqlStr +
				' WHERE T1.'+@SourceDateKey+ ' BETWEEN ''' +CONVERT(VARCHAR(20),@IncrementalDateFrom,110)+''' and '''+CONVERT(VARCHAR(20),@IncrementalDateTo,110)+''''
          END
		  
		  ELSE
			
		  BEGIN
		  SET @SqlStr = @SqlStr 
		  END
	  END

IF @OperationName IS NOT NULL 
   BEGIN
	    SET @SqlStr=@SqlStr + ' AND T1.'+@SourceOperationKey+'='''+@OperationName+''''
   END

 
	 /* --- Execute the Delete --- */

	  IF @SqlStr IS NOT NULL
		BEGIN
            EXEC (@SqlStr)
		END
	  ELSE
	   BEGIN
		 SET @ErrSqlStr='Missing values in Metadata for data feed to '+@DestinationTable
		 RAISERROR(@ErrSqlStr,16,1)
	   END 
	
 END

--- Insert new rows based on any PK values greater than what already exists in the Destination table
IF @UpdateMethod = 'Identity' AND @OperationName IS null
	BEGIN
		SET @SqlStr = 
		' INSERT INTO '+@DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable +'('+@InsertColumns+') 
		  SELECT '+	@SelectColumns+' FROM '+@SourceTable +
		' WHERE '+@SourcePrimaryKey+  ' > (SELECT ISNULL(MAX('+ @DestinationPrimaryKey +'),0) FROM '+@DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable +')'
	END

IF @UpdateMethod = 'Identity' AND @OperationName IS NOT null
	BEGIN

	--- grab the first column in the primary key (which must be the identity column in both source and destination)
	SET @DestinationStartPos = 1
	SET @DestinationStopPos = CHARINDEX(',',@DestinationPrimaryKey,@DestinationStartPos)-1
	SET @DestinationFirstColumn = LTRIM(SUBSTRING(@DestinationPrimaryKey,@DestinationStartPos, CASE WHEN @DestinationStopPos= -1 THEN LEN(@DestinationPrimaryKey)-@DestinationStartPos+1 ELSE @DestinationStopPos-@DestinationStartPos+1 END))

	SET @SourceStartPos = 1
	SET @SourceStopPos = CHARINDEX(',',@SourcePrimaryKey,@SourceStartPos)-1
	SET @SourceFirstColumn = LTRIM(SUBSTRING(@SourcePrimaryKey,@SourceStartPos, CASE WHEN @SourceStopPos= -1 THEN LEN(@SourcePrimaryKey)-@SourceStartPos+1 ELSE @SourceStopPos-@SourceStartPos+1 END))

	SET @SqlStr = 
		' INSERT INTO '+@DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable  +'('+@InsertColumns+')
		  SELECT '+	@SelectColumns+' FROM '+@SourceTable +
		' WHERE '+@SourceFirstColumn+  ' > (SELECT ISNULL(MAX('+ @DestinationFirstColumn +'),0) FROM '+@DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable 
		                                  +' WHERE '+@DestinationOperationKey+'='''+@OperationName+''') '
	  
	END

--- Insert missing rows based on existance of Primary Key values
/* Change by Padmanabhan 28/10/2025 for CDC Logic*/
/* Begin */
IF @UpdateMethod IN ('CDC','Upsert','Insert','DateKey','DateRange')
/* End */
BEGIN
     
		SET @SqlStr = 
		'INSERT INTO '+@DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable  +'('+@InsertColumns+') 
		  SELECT DISTINCT T1.'+REPLACE(@SelectColumns,',',',T1.')+' FROM '+@SourceTable + ' t1 
		  LEFT JOIN '+@DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable +' t2 ON '
	
		SET @SourceStartPos = 1
		SET @SourceStopPos = CHARINDEX(',',@SourcePrimaryKey,@SourceStartPos)-1
		SET @SqlStr=@SqlStr+'T1.'+ LTRIM(SUBSTRING(@SourcePrimaryKey,@SourceStartPos, CASE WHEN @SourceStopPos= -1 THEN LEN(@SourcePrimaryKey)-@SourceStartPos+1 ELSE @SourceStopPos-@SourceStartPos+1 END))
				
		SET @DestinationStartPos = 1
		SET @DestinationStopPos = CHARINDEX(',',@DestinationPrimaryKey,@DestinationStartPos)-1
		SET @DestinationFirstColumn = LTRIM(SUBSTRING(@DestinationPrimaryKey,@DestinationStartPos, CASE WHEN @DestinationStopPos= -1 THEN LEN(@DestinationPrimaryKey)-@DestinationStartPos+1 ELSE @DestinationStopPos-@DestinationStartPos+1 END))
		
		SET @SqlStr=@SqlStr+'=T2.'+ @DestinationFirstColumn


		WHILE @SourceStopPos <> - 1
		BEGIN 
			SET @SourceStartPos=@SourceStopPos+2
			SET @SourceStopPos=  CHARINDEX(',',@SourcePrimaryKey,@SourceStartPos)-1
			SET @SqlStr = @SqlStr+' AND T1.'+ LTRIM(SUBSTRING(@SourcePrimaryKey,@SourceStartPos, CASE WHEN @SourceStopPos = -1 THEN LEN(@SourcePrimaryKey)-@SourceStartPos+1 ELSE @SourceStopPos-@SourceStartPos+1 END))

			SET @DestinationStartPos=@DestinationStopPos+2
			SET @DestinationStopPos=  CHARINDEX(',',@DestinationPrimaryKey,@DestinationStartPos)-1
			SET @SqlStr = @SqlStr+' = T2.'+ LTRIM(SUBSTRING(@DestinationPrimaryKey,@DestinationStartPos, CASE WHEN @DestinationStopPos = -1 THEN LEN(@DestinationPrimaryKey)-@DestinationStartPos+1 ELSE @DestinationStopPos-@DestinationStartPos+1 END))

		END

	    SET @SqlStr = @SqlStr+' WHERE T2.'+@DestinationFirstColumn +' IS NULL '

		/* Change by Padmanabhan 28/10/2025 for CDC Logic*/
		/* Begin */
		IF @UpdateMethod = 'CDC' 
	    BEGIN
			SET @SqlStr = @SqlStr + 'AND T1.JOENTT IN (''UP'',''PT'',''PX'')'
	    END
		/* End */

		IF @UpdateMethod = 'DateRange' and @DateRangeDays > 0
	    BEGIN
            SET @SqlStr = @SqlStr +' AND T1.'+@SourceDateKey+ ' BETWEEN ''' +CONVERT(VARCHAR(20),@IncrementalDateFrom,110)+''' and '''+ CONVERT(VARCHAR(20),@IncrementalDateTo,110)+''''
	    END

		IF @OperationName IS NOT NULL 
        BEGIN
	    SET @SqlStr = @SqlStr + ' AND T1.'+@SourceOperationKey+'='''+@OperationName+''''
        END

END
--- Insert Rows into Destination table from Source table for the same date range

IF @UpdateMethod IN ('DelInsert','Append')
	BEGIN 
       --Change by Padmanabhan, 28/10/2025, Added Distinct to remove duplicate entries   
	   SET @SqlStr = 
		'INSERT INTO '+@DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable +'('+@InsertColumns+') 
		  SELECT DISTINCT '+@SelectColumns+' FROM '+@SourceTable 
    END

/* --- Execute the Insert --- */

IF @SqlStr IS NOT NULL
  BEGIN
    EXEC (@SqlStr)
  END
  ELSE
   BEGIN
	 SET @ErrSqlStr='Missing values in Metadata for data feed to '+@DestinationTable
     RAISERROR(@ErrSqlStr,16,1)
   END 

Commit Transaction

/* Change by Padmanabhan 28/10/2025 for CDC Logic*/
/* Begin */
EXEC DW_Developer.usp_DropWorkTable @TempHoldingTable

EXEC DW_Developer.usp_DropWorkTable 'Tempdb..#CDCDeleteSource'
/* End */

--- return new max value
IF @UpdateMethod = ('Identity') AND @OperationName IS NULL
  BEGIN
    SET @SqlStr='SELECT ISNULL(MAX('+ @DestinationPrimaryKey +'),0) FROM '+@DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable 
    EXEC(@SqlStr)
  END

  IF @UpdateMethod = ('Identity') AND @OperationName IS NOT NULL
  BEGIN
    SET @SqlStr='SELECT ISNULL(MAX('+ @DestinationFirstColumn +'),0) FROM '+@DestinationDatabase+'.'+@DestinationSchema+'.'+ @DestinationTable 
	 + ' WHERE '+@DestinationOperationKey+'='''+@OperationName+''''
    EXEC(@SqlStr)
  END


SET @DateValue = GETDATE();
SELECT
    @DateValue = CSTDateValue
FROM
    DW_Developer.fn_GetDate(@DateValue);

INSERT INTO DW_Developer.AuditLog
    VALUES
    (
      @String, @DateValue, @User, 'Process Complete'
    );
INSERT INTO DW_Developer.TableDictionary_UpdateLog 
	  VALUES (@DestinationDatabase, @DestinationSchema, @DestinationTable, @DateValue ) 

-- UPDATE  DW_Developer.TableDictionary
--            SET Modified = @DateValue
--             WHERE DatabaseName= @DestinationDatabase
--               AND SchemaName=  @DestinationSchema  
--               AND TableName=  @DestinationTable

END TRY

BEGIN CATCH
	
    DECLARE @ErrorMessage NVARCHAR(4000),  @ErrorSeverity INT,  @ErrorState INT
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(),16)
	SET @ErrorState = ISNULL(ERROR_STATE(),1)

	SET @DateValue = GETDATE();
	SELECT
		@DateValue = CSTDateValue
	FROM
		DW_Developer.fn_GetDate(@DateValue);

	INSERT INTO DW_Developer.AuditLog --(aloDesc,aloDateTime,aloUser,aloCommand) 
		VALUES (@String,@DateValue, @User,@ErrorMessage)
	RAISERROR (@ErrorMessage,  @ErrorSeverity, @ErrorState )

	IF @@TRANCOUNT > 0 
	Rollback transaction

END CATCH

END