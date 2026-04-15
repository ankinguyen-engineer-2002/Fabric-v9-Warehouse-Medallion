CREATE     PROCEDURE [Retail_OOM_Enh].[usp_GLHist]
AS
BEGIN
    SET NOCOUNT ON;
    --// AUDIT LOGGING START //--

    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);

    SET @String = 'Retail_OOM_Enh.usp_GLHist';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_OOM_Enh';
    SET @DestinationTable = 'GLHist';

    SELECT @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES
    (
        @String, @DateValue, @User, 'Process Start'
    );

    --// AUDIT LOGGING END //--

    BEGIN TRY
 
    DECLARE @AccountId INT = 1;
    DECLARE @Year INT = YEAR(GETDATE())
    DECLARE @FromDate DATE = GETDATE()-1,
    @ToDate DATE = GETDATE();
 
    DECLARE @CurrentDate DATETIME = GETDATE();
    DECLARE @SQL VARCHAR(MAX);
 
    DECLARE @STODATE DATETIME;
    SET @STODATE = DATEADD(DAY, 1, @ToDate);
 
 
    -- DELETE PREVIUS DATE INFO FROM WORKING TABLE
 
    DELETE FROM [Retail_OOM_Wrk].[GLHist]
    WHERE PostDate
          BETWEEN @FromDate AND @STODATE
          AND AccountId = @AccountId;
 
    IF @AccountId = 1 --TDG
    BEGIN
        --INSERT INFO FROM DW
        INSERT INTO [Retail_OOM_Wrk].[GLHist]
        (
            [Id],
            [ItemId],
            [ReferenceNumber],
            [Period],
            [YearId],
            [PostDate],
            [PostTime],
            [Operator],
            [HeaderComment],
            [CustomerKey],
            [CustomerType],
            [Source],
            [TransDate],
            [AccountNumber],
            [Debit],
            [Credit],
            [Remark],
            [AccountId],
            [DateCreated]
        )
        SELECT gld.GLPostID Id,
               gld.GLPostID + '*' + CAST(gld.DetailID AS VARCHAR(5)) ItemId,
               (
                   SELECT TOP 1
                          ReferenceKey
                   FROM [$(Source_Data)].[MasterData_Retail].[GLPost_References] glr
                   WHERE glr.GLPostID = gl.GLPostID
               ) referencenumber,
               gl.FisPeriod Period,
               gl.FisYear yearid,
               CAST(gl.StorisCreateDateTime AS DATE) postdate,
               CAST(gl.StorisCreateDateTime AS TIME) postime,
               SUBSTRING(gl.StaffID, 1, 10) operator,
               SUBSTRING(gl.Comment, 1, 200) headercomments,
               SUBSTRING(gl.ReferenceSourceID, 1, 50) customerkey,
               SUBSTRING(gl.ReferenceSourceType, 1, 10) customertype,
               SUBSTRING(gl.GLSourceID, 1, 10) source,
               gld.TransDate,
               SUBSTRING(gl.CompanyID + '-' + gld.GLAccountID, 1, 50) AccountNumber,
               gld.Debit,
               gld.Credit,
               SUBSTRING(gld.Remark, 1, 3100),
               1 accountId,
               GETDATE()
        FROM [$(Source_Data)].[MasterData_Retail].[GLPostDetail] gld
            INNER JOIN [$(Source_Data)].[MasterData_Retail].[GLPost] gl
                ON gl.GLPostID = gld.GLPostID
        WHERE gl.StorisCreateDateTime
        BETWEEN @FromDate AND @STODATE;
 
    END;
    ELSE IF @AccountId = 2 --DSG
    BEGIN
        --INSERT INFO FROM DW
        INSERT INTO [Retail_OOM_Wrk].[GLHist]
        (
            [Id],
            [ItemId],
            [ReferenceNumber],
            [Period],
            [YearId],
            [PostDate],
            [PostTime],
            [Operator],
            [HeaderComment],
            [CustomerKey],
            [CustomerType],
            [Source],
            [TransDate],
            [AccountNumber],
            [Debit],
            [Credit],
            [Remark],
            [AccountId],
            [DateCreated]
        )
        SELECT gld.GLPostID Id,
               gld.GLPostID + '*' + CAST(gld.DetailID AS VARCHAR(5)) ItemId,
               (
                   SELECT TOP 1
                          ReferenceKey
                   FROM [$(Source_Data)].[MasterData_Retail].[GLPost_References] glr
                   WHERE glr.GLPostID = gl.GLPostID
               ) referencenumber,
               gl.FisPeriod Period,
               gl.FisYear yearid,
               CAST(gl.StorisCreateDateTime AS DATE) postdate,
               CAST(gl.StorisCreateDateTime AS TIME) postime,
               SUBSTRING(gl.StaffID, 1, 10) operator,
               SUBSTRING(gl.Comment, 1, 200) headercomments,
               SUBSTRING(gl.ReferenceSourceID, 1, 50) customerkey,
               SUBSTRING(gl.ReferenceSourceType, 1, 10) customertype,
               SUBSTRING(gl.GLSourceID, 1, 10) source,
               gld.TransDate,
               SUBSTRING(gl.CompanyID + '-' + gld.GLAccountID, 1, 50) AccountNumber,
               gld.Debit,
               gld.Credit,
               SUBSTRING(gld.Remark, 1, 3100),
               2 accountId,
               GETDATE()
        FROM [$(Source_Data)].[MasterData_Retail].[GLPostDetail] gld
            INNER JOIN [$(Source_Data)].[MasterData_Retail].[GLPost] gl
                ON gl.GLPostID = gld.GLPostID
        WHERE gl.StorisCreateDateTime
              BETWEEN @FromDate AND @STODATE
              AND gl.CompanyID NOT IN ( '11', '47' );
    END;
 
    DELETE [Retail_OOM_Enh].[GLHist]
    WHERE AccountId = @AccountId
          AND PostDate
          BETWEEN @FromDate AND @STODATE;
 
    INSERT INTO [Retail_OOM_Enh].[GLHist]
    (
        Id,
        ItemId,
        ReferenceNumber,
        Period,
        YearId,
        PostDate,
        PostTime,
        Operator,
        HeaderComment,
        CustomerKey,
        CustomerType,
        Source,
        TransDate,
        AccountNumber,
        Debit,
        Credit,
        Remark,
        AccountId,
        DateCreated
    )
    SELECT Id,
           ItemId,
           ReferenceNumber,
           Period,
           YearId,
           PostDate,
           PostTime,
           SUBSTRING(COALESCE(Operator, ''), 1, 10) AS Operator,
           REPLACE(HeaderComment, '|', ' '),
           CustomerKey,
           CustomerType,
           Source,
           TransDate,
           AccountNumber,
           Debit,
           Credit,
           REPLACE(Remark, '|', ' '),
           AccountId,
           @CurrentDate AS DateCreated
    FROM [Retail_OOM_Wrk].[GLHist] AS w
    WHERE AccountId = @AccountId
          AND PostDate
          BETWEEN @FromDate AND @STODATE;

        --// AUDIT LOGGING START //--

        SET @DateValue = GETDATE();

        SELECT @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES
        (
            @String, @DateValue, @User, 'Process Complete'
        );

        --- Update last modified in Table Dictionary
        DECLARE @Exists INT;
        SET @Exists =
        (
            SELECT COUNT(*)
            FROM [$(ETL_Framework)].[DW_Developer].[TableDictionary]
            WHERE DatabaseName = @DestinationDatabase
                  AND SchemaName = @DestinationSchema
                  AND TableName = @DestinationTable
        );

        IF @Exists = 0
        BEGIN
            INSERT INTO [$(ETL_Framework)].[DW_Developer].[TableDictionary]
            (
                ServerName,
                DatabaseName,
                SchemaName,
                TableName,
                ObjectType,
                StorageType,
                UpdateQuery
            )
            VALUES
            (
                'EDW-Fabric', @DestinationDatabase, @DestinationSchema, @DestinationTable, 'Table', 'Delta', @String
            );
        END;

        UPDATE [$(ETL_Framework)].[DW_Developer].[TableDictionary]
        SET Modified = @DateValue
        WHERE DatabaseName = @DestinationDatabase
              AND SchemaName = @DestinationSchema
              AND TableName = @DestinationTable;

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[TableDictionary_UpdateLog]
        VALUES
        (
            @DestinationDatabase, @DestinationSchema, @DestinationTable, @DateValue
        );

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

    END CATCH;
 
END;