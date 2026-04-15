CREATE PROC [AFISales_Enh].[usp_Rebuild_CustomerAccountRating]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [AFISales_Enh].[usp_Rebuild_CustomerAccountRating]
* Amy Morina 10/18/2018 create based on usp_BuildCustomerAccountRating on AFI Batch
* Amy Morina 06/18/2019 calulate ratings based on Account Exception Flag; requested by Brian Menard
* 02/26/2020 Changed insert to "Values" syntax to avoid exclusive locks
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN

        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME2(6),
            @User      VARCHAR(500);

        SET @String = 'AFISales_DW.AFISales_Enh.usp_Rebuild_CustomerAccountRating';
        SET @User = SYSTEM_USER;
        SET @DateValue = GETDATE();
        SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)


        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

        BEGIN TRY


            DECLARE @CURYEAR VARCHAR(4);
            DECLARE @PRVYEAR VARCHAR(4);
            DECLARE @3rdYEAR VARCHAR(4);
            DECLARE @4thYEAR VARCHAR(4);
            DECLARE @cols AS VARCHAR(8000);
            DECLARE @colHeaders AS VARCHAR(8000);
            DECLARE @query AS VARCHAR(8000);
            DECLARE @query2 AS VARCHAR(8000);


            DROP TABLE IF EXISTS #custAmountOrdered;

            CREATE TABLE #custAmountOrdered
                (
                    Customer                 VARCHAR(13),
                    CUR_AMT                  DECIMAL(13, 3),
                    PRV_AMT                  DECIMAL(13, 3),
                    THD_AMT                  DECIMAL(13, 3),
                    FRT_AMT                  DECIMAL(13, 3),
                    [Account Exception Flag] BIT
                );

            SET @CURYEAR = DATEPART(YYYY, GETDATE());
            SET @PRVYEAR = @CURYEAR - 1;
            SET @3rdYEAR = @CURYEAR - 2;
            SET @4thYEAR = @CURYEAR - 3;
            SET @cols = '[' + @CURYEAR + '], [' + @PRVYEAR + '], [' + @3rdYEAR + '], [' + @4thYEAR + ']';
            SET @colHeaders
                = 'ISNULL([' + @CURYEAR + '],0) AS [CurrentAmt], ISNULL([' + @PRVYEAR + '],0) AS [PrevYrAmt], ISNULL(['
                  + @3rdYEAR + '],0) AS [3rdYrAmt], ISNULL([' + @4thYEAR + '],0) AS [4thYrAmt]';

            /*SELECT @CURYEAR
SELECT @PRVYEAR
SELECT @3rdYEAR 
SELECT @4thYEAR 
SELECT @cols
SELECT @colHeaders*/

            SET @query
                = 'INSERT INTO #custAmountOrdered SELECT [Account And Shipto Number] AS [Customer], ' + @colHeaders
                  + ' , [Account Exception Flag]
FROM (
SELECT CASE WHEN CHARINDEX(''-'',fact.[Account And Shipto Number]) =  0 THEN fact.[Account And Shipto Number]
ELSE LEFT(fact.[Account And Shipto Number], CHARINDEX(''-'',fact.[Account And Shipto Number]) -1) END AS [Account And Shipto Number], [Fiscal Year], [Amount Ordered], [Account Exception Flag]
FROM AFISales_DW.FactOrderHistory fact
INNER JOIN AFISales_DW.DimDateFile
ON [Transaction Date] = [Order Change Date] 
INNER JOIN AFISales_DW.DimCustomers dim
ON fact.[Account And Shipto Number]      = dim.[Account And Shipto Number]
WHERE dim.[Account Exception Flag] = 0) A 
PIVOT(SUM([Amount Ordered]) FOR [Fiscal Year] IN (' + @cols + ' )) AS [Amount Ordered]';

            EXEC (@query);

            SET @query2
                = 'INSERT INTO #custAmountOrdered SELECT [Account And Shipto Number] AS [Customer], ' + @colHeaders
                  + ' , [Account Exception Flag]
FROM (
SELECT fact.[Account And Shipto Number], [Fiscal Year], [Amount Ordered], [Account Exception Flag]
FROM AFISales_DW.FactOrderHistory fact
INNER JOIN AFISales_DW.DimDateFile
ON [Transaction Date] = [Order Change Date] 
INNER JOIN AFISales_DW.DimCustomers dim
ON  fact.[Account And Shipto Number] = dim.[Account And Shipto Number]
WHERE dim.[Account Exception Flag] = 1) A 
PIVOT(SUM([Amount Ordered]) FOR [Fiscal Year] IN (' + @cols + ' )) AS [Amount Ordered]';


            EXEC (@query2);


            DROP TABLE IF EXISTS AFISales_Enh.CustomerAccountRating_LOAD;

            CREATE TABLE AFISales_Enh.CustomerAccountRating_LOAD
                (
                    [CustomerNumber]         CHAR(13) NOT NULL,
                    [CurrentYearRating]      CHAR(1)  NULL,
                    [PreviousYearRating]     CHAR(1)  NULL,
                    [SecondYearRating]       CHAR(1)  NULL,
                    [Account Exception Flag] BIT      NOT NULL
                );

            INSERT INTO AFISales_Enh.CustomerAccountRating_LOAD
                (
                    [CustomerNumber],
                    [CurrentYearRating],
                    [PreviousYearRating],
                    [SecondYearRating],
                    [Account Exception Flag]
                )
                        SELECT
                            Customer AS 'CustomerNumber',
                            CASE
                                WHEN (
                                         PRV_AMT = 0
                                         AND THD_AMT = 0
                                         AND FRT_AMT = 0
                                         AND CUR_AMT >= 10000000
                                     )
                                     OR PRV_AMT >= 10000000
                                    THEN
                                    'A'
                                WHEN (
                                         PRV_AMT = 0
                                         AND THD_AMT = 0
                                         AND FRT_AMT = 0
                                         AND CUR_AMT >= 1000000
                                     )
                                     OR
                                         (
                                             PRV_AMT < 10000000
                                             AND PRV_AMT >= 1000000
                                         )
                                    THEN
                                    'B'
                                WHEN (
                                         PRV_AMT = 0
                                         AND THD_AMT = 0
                                         AND FRT_AMT = 0
                                         AND CUR_AMT >= 500000
                                     )
                                     OR
                                         (
                                             PRV_AMT < 1000000
                                             AND PRV_AMT >= 500000
                                         )
                                    THEN
                                    'C'
                                WHEN (
                                         PRV_AMT = 0
                                         AND THD_AMT = 0
                                         AND FRT_AMT = 0
                                         AND CUR_AMT >= 100000
                                     )
                                     OR
                                         (
                                             PRV_AMT < 500000
                                             AND PRV_AMT >= 100000
                                         )
                                    THEN
                                    'D'
                                ELSE
                                    'E'
                            END      AS 'CurrentYearRating',
                            CASE
                                WHEN THD_AMT >= 10000000
                                    THEN
                                    'A'
                                WHEN THD_AMT < 10000000
                                     AND THD_AMT >= 1000000
                                    THEN
                                    'B'
                                WHEN THD_AMT < 1000000
                                     AND THD_AMT >= 500000
                                    THEN
                                    'C'
                                WHEN THD_AMT < 500000
                                     AND THD_AMT >= 100000
                                    THEN
                                    'D'
                                ELSE
                                    'E'
                            END      AS 'PreviousYearRating',
                            CASE
                                WHEN FRT_AMT >= 10000000
                                    THEN
                                    'A'
                                WHEN FRT_AMT < 10000000
                                     AND FRT_AMT >= 1000000
                                    THEN
                                    'B'
                                WHEN FRT_AMT < 1000000
                                     AND FRT_AMT >= 500000
                                    THEN
                                    'C'
                                WHEN FRT_AMT < 500000
                                     AND FRT_AMT >= 100000
                                    THEN
                                    'D'
                                ELSE
                                    'E'
                            END      AS 'SecondYearRating',
                            [Account Exception Flag]
                        FROM
                            #custAmountOrdered;

    
            CREATE STATISTICS Stat_CustomerAccountRating_CurrentYearRating
                ON AFISales_Enh.CustomerAccountRating_LOAD
                (
                    [CurrentYearRating]
                );
            CREATE STATISTICS Stat_CustomerAccountRating_Account_Exception_Flag
                ON AFISales_Enh.CustomerAccountRating_LOAD
                (
                    [Account Exception Flag]
                );
            CREATE STATISTICS Stat_CustomerAccountRating_SecondYearRating
                ON AFISales_Enh.CustomerAccountRating_LOAD
                (
                    [SecondYearRating]
                );
            CREATE STATISTICS Stat_CustomerAccountRating_PreviousYearRating
                ON AFISales_Enh.CustomerAccountRating_LOAD
                (
                    [PreviousYearRating]
                );

            DROP TABLE IF EXISTS AFISales_Enh.CustomerAccountRating;


    
            EXECUTE sp_rename 'AFISales_Enh.CustomerAccountRating_LOAD','CustomerAccountRating'

            DROP TABLE IF EXISTS #custAmountOrdered;


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
            SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

            INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
            VALUES
                (
                    @String, @DateValue, @User, @ErrorMessage
                );

            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        END CATCH;

        SET @DateValue = GETDATE();
        SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

        EXEC [$(ETL_Framework)].DW_Developer.usp_UpdateTableDictionary_ModifiedDate 
            'AFISales_DW', 'AFISales_Enh', 'CustomerAccountRating', @String, @DateValue;

    END;