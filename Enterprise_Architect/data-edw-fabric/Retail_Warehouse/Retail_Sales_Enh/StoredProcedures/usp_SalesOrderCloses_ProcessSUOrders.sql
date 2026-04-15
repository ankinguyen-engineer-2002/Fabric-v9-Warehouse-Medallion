CREATE PROCEDURE Retail_Sales_Enh.[usp_SalesOrderCloses_ProcessSUOrders]
AS
BEGIN

    DECLARE @SUOrderID VARCHAR(50),
            @TransDateKey INT, 
            @PID UNIQUEIDENTIFIER = NEWID();

    
    DECLARE @String VARCHAR(5000),
            @DateValue DATETIME,
            @User VARCHAR(500),
            @DestinationDatabase VARCHAR(150),
            @DestinationSchema VARCHAR(150),
            @DestinationTable VARCHAR(150);
                  
    SET @String = 'Retail_Sales_Enh.usp_SalesOrderCloses_ProcessSUOrders';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_Sales_Enh';
    SET @DestinationTable = 'SalesOrderCloses'; 

    SELECT @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES (@String, @DateValue, @User, 'Process Start');

    BEGIN TRY

        SET @SUOrderID = '';
        WHILE @SUOrderID IS NOT NULL
        BEGIN

            EXEC [Retail_Sales_Wrk].[usp_SUOrder_LoadQueue_GetOrderID] @PID, @SUOrderID OUTPUT
            SELECT @PID, @SUOrderID
            IF @SUOrderID IS NOT NULL
            BEGIN
                
                SELECT @TransDateKey = td.TransDateKey
                FROM (
                    SELECT TOP(1) sudq.TransDateKey
                    FROM Retail_Sales_Wrk.[SUOrderDateQueue] AS sudq
                    WHERE SUOrderID = @SUOrderID
                    ORDER BY sudq.TransDateKey
                ) td
                SELECT @TransDateKey
                WHILE ISNULL(@TransDateKey,0) <> 0
                BEGIN
                    EXEC Retail_Sales_Wrk.[usp_SalesOrderCloses_ProcessSUOrder] @SUOrderID = @SUOrderID,
                                                                    @TransDateKey = @TransDateKey;
                     SELECT    @SUOrderID
                    DELETE FROM Retail_Sales_Wrk.[SUOrderDateQueue]
                    WHERE SUOrderID = @SUOrderID 
                        AND TransDateKey = @TransDateKey;

                    SET @TransDateKey = 0;

                    SELECT @TransDateKey = td.TransDateKey
                    FROM (
                        SELECT TOP(1) sudq.TransDateKey
                        FROM Retail_Sales_Wrk.[SUOrderDateQueue] AS sudq
                        WHERE SUOrderID = @SUOrderID
                        ORDER BY sudq.TransDateKey
                    ) td

                END;

                DELETE FROM  Retail_Sales_Wrk.[SUOrderLoadQueue]
                WHERE SUOrderID = @SUOrderID;

            END
        END

        
        SET @DateValue = GETDATE();

        SELECT @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES (@String, @DateValue, @User, 'Process Complete');

        --- Update last modified in Table Dictionary 
        Exec [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase,@DestinationSchema,@DestinationTable

    END TRY

    BEGIN CATCH
            
        DECLARE @ErrorMessage  VARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState    INT;

        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
        SET @ErrorState = ISNULL(ERROR_STATE(), 0);
        SET @DateValue = GETDATE();

        SELECT @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES (@String, @DateValue, @User, @ErrorMessage);

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

    END CATCH
    
END;