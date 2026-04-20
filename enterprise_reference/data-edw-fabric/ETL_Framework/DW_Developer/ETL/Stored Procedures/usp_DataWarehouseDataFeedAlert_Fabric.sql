CREATE   PROC [DW_Developer].[usp_DataWarehouseDataFeedAlert_Fabric]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @msgTitle       NVARCHAR(400) = N'FABRIC Table Dictionary Objects that are behind schedule',
       @msgSubject     NVARCHAR(4000),
       @tableHTML      NVARCHAR(MAX),
       @TablesBehind   INT,
       @TotalTables    INT,
       @PercentBehind  DECIMAL(10,4),
       @CurrentTime    DATETIME2(3) = SYSUTCDATETIME(),
       @Recipients     NVARCHAR(MAX) = N'RSteinke@Ashleyfurniture.com;DL_AFI_Analytics_AG_DataWarehouse@Ashleyfurniture.com';
   -------------------------------------------------------------------------
   -- Identify all monitored tables and the ones that are behind
   -------------------------------------------------------------------------
   -- Total monitored tables
   SELECT @TotalTables = COUNT(*)
   FROM DW_Developer.TableDictionary
   WHERE SchemaName NOT LIKE '%Wrk'
     AND ISNULL(RefreshRate,0) > 0;
	 --select @TotalTables
   -- Put "behind" tables into a temp table
   declare @cstDate datetime2(6) = SYSDATETIMEOFFSET() AT TIME ZONE 'Central Standard Time';
   IF OBJECT_ID('tempdb..#behind') IS NOT NULL DROP TABLE #behind;
   SELECT
       HoursLate   = DATEDIFF(HOUR, Modified, @cstDate) - ISNULL(RefreshRate,0),
       LastUpdated = Modified,
       RefreshRate = ISNULL(RefreshRate,0),
       SchemaName  = SchemaName,
       TableName   = TableName,
       JobServer   = JobServer,
       JobName     = JobName
   INTO #behind
   FROM DW_Developer.TableDictionary
   WHERE SchemaName NOT LIKE '%Wrk'
     AND ISNULL(RefreshRate,0) > 0
     AND DATEDIFF(HOUR, Modified, @cstDate) > ISNULL(RefreshRate,0);
	-- select * from #behind
   SELECT @TablesBehind = COUNT(*) FROM #behind;
   SET @PercentBehind = CASE WHEN @TotalTables > 0
                             THEN CAST(@TablesBehind AS DECIMAL(10,4)) / @TotalTables * 100
                             ELSE 0 END;
   -- Subject line (Fabric Warehouse doesn't have @@SERVERNAME; include DB name instead)
   DECLARE @DbName SYSNAME = DB_NAME();
   SET @msgSubject = CONCAT(@DbName, N' DataWarehouse Data Feed Alert: ',
                            @PercentBehind, N'% behind (',
                            @TablesBehind, N' of ', @TotalTables, N')');
   -------------------------------------------------------------------------
   -- Logging: summary + detail
   -------------------------------------------------------------------------
   INSERT INTO Performance_Logs.tblFabricDataFeedAlertLog (AuditTime, TablesBehind, TotalTables, PercentBehind)
   VALUES (@CurrentTime, @TablesBehind, @TotalTables, @PercentBehind);
   IF @TablesBehind > 0
   BEGIN
       INSERT INTO Performance_Logs.tblFabricDataFeedAlertLogDetail
           (AuditTime, SchemaName, TableName, HoursLate, RefreshRate, LastUpdated, JobServer, JobName)
       SELECT @CurrentTime, SchemaName, TableName, HoursLate, RefreshRate, LastUpdated, JobServer, JobName
       FROM #behind;
   END;

   --select * from Performance_Logs.tblFabricDataFeedAlertLogDetail
   -------------------------------------------------------------------------
   -- Build the HTML for email
   -------------------------------------------------------------------------
   IF @TablesBehind > 0
   BEGIN
       DECLARE @Rows NVARCHAR(MAX) = N'';
       DECLARE @i INT = 1;
       DECLARE @MaxRows INT;
       DECLARE @HoursLate INT, @LastUpdated DATETIME2, @RefreshRate INT,
               @SchemaName NVARCHAR(128), @TableName NVARCHAR(128),
               @JobServer NVARCHAR(128), @JobName NVARCHAR(128);

       -- Create temp table with row numbers (Fabric SQL Warehouse compatible)
       IF OBJECT_ID('tempdb..#behind_ordered') IS NOT NULL DROP TABLE #behind_ordered;
       SELECT
           ROW_NUMBER() OVER (ORDER BY HoursLate DESC) AS RowNum,
           HoursLate, LastUpdated, RefreshRate, SchemaName, TableName, JobServer, JobName
       INTO #behind_ordered
       FROM #behind
       ORDER BY HoursLate DESC;

       SELECT @MaxRows = COUNT(*) FROM #behind_ordered;

       -- Loop through rows using row number
       WHILE @i <= @MaxRows
       BEGIN
           SELECT
               @HoursLate = HoursLate,
               @LastUpdated = LastUpdated,
               @RefreshRate = RefreshRate,
               @SchemaName = SchemaName,
               @TableName = TableName,
               @JobServer = JobServer,
               @JobName = JobName
           FROM #behind_ordered
           WHERE RowNum = @i;

           SET @Rows = @Rows +
               N'<tr>' +
                   N'<td>' + CAST(@HoursLate AS NVARCHAR(50)) + N'</td>' +
                   N'<td>' + COALESCE(CONVERT(NVARCHAR(30), @LastUpdated, 120), N'') + N'</td>' +
                   N'<td>' + CAST(@RefreshRate AS NVARCHAR(50)) + N'</td>' +
                   N'<td>' + COALESCE(@SchemaName, N'') + N'</td>' +
                   N'<td>' + COALESCE(@TableName, N'') + N'</td>' +
                   N'<td>' + COALESCE(@JobServer, N'') + N'</td>' +
                   N'<td>' + COALESCE(@JobName, N'') + N'</td>' +
               N'</tr>';

           SET @i = @i + 1;
       END;

       DROP TABLE #behind_ordered;

       SET @tableHTML =
           N'<h2>' + @msgTitle + N'</h2>' +
           N'<p><b>As of:</b> ' + CONVERT(NVARCHAR(30), @CurrentTime, 120) + N'</p>' +
           N'<p><b>Behind:</b> ' + CAST(@TablesBehind AS NVARCHAR(50)) + N' of ' + CAST(@TotalTables AS NVARCHAR(50)) +
           N' (' + CAST(@PercentBehind AS NVARCHAR(50)) + N'%)</p>' +
           N'<table border="1" cellspacing="0" cellpadding="4">' +
           N'<thead><tr style="font-weight:bold;">' +
               N'<td>Hours Late</td>' +
               N'<td>Last Updated (UTC)</td>' +
               N'<td>Refresh Rate (hours)</td>' +
               N'<td>Schema Name</td>' +
               N'<td>Table Name</td>' +
               N'<td>Job Server</td>' +
               N'<td>Job Name</td>' +
           N'</tr></thead>' +
           N'<tbody>' + COALESCE(@Rows, N'') + N'</tbody>' +
           N'</table>';
   END
   ELSE
   BEGIN
       SET @tableHTML =
           CONCAT(
               N'<h2>No tables are behind schedule</h2>',
               N'<p><b>As of:</b> ', CONVERT(NVARCHAR(30), @CurrentTime, 120), N'</p>'
           );
   END;

   DECLARE @MaxID AS BIGINT;
   IF EXISTS(SELECT * FROM Performance_Logs.EmailQueue)
		SET @MaxID = (SELECT MAX(EmailId)+1 FROM Performance_Logs.EmailQueue);
   ELSE
		SET @MaxID=0;

   -------------------------------------------------------------------------
   -- Enqueue email for the pipeline/flow to send
   -------------------------------------------------------------------------
   INSERT INTO Performance_Logs.EmailQueue (EmailId,CreatedAt,Recipients, Subject, BodyHtml)
   VALUES (@MaxID,@CurrentTime,@Recipients, @msgSubject, @tableHTML);
   -- Return something useful to pipeline if needed
   --SELECT
   --    EmailId = @MaxID,
	  -- Createdt = @CurrentTime,
   --    AuditTime     = @CurrentTime,
   --    TablesBehind  = @TablesBehind,
   --    TotalTables   = @TotalTables,
   --    PercentBehind = @PercentBehind,
   --    Subject       = @msgSubject;
END;