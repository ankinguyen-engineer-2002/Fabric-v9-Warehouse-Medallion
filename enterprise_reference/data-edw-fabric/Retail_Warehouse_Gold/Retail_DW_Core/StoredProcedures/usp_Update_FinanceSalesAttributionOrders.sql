-- =============================================
--  Matches DSG Red Logic 
-- =============================================
CREATE   PROCEDURE [Retail_DW_Core].[usp_Update_FinanceSalesAttributionOrders]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @String VARCHAR(5000),
        @DateValue DATETIME,
        @User VARCHAR(500),
        @DestinationDatabase VARCHAR(150),
        @DestinationSchema VARCHAR(150),
        @DestinationTable VARCHAR(150),
        @LookbackDays INT,
        @CurrentDate DATE;

    SET @String = 'Retail_DW_Core.usp_Update_FinanceSalesAttributionOrders';
    SET @User = SYSTEM_USER;
    SET @DateValue = GETDATE();
    SET @DestinationDatabase = 'Retail_Warehouse';
    SET @DestinationSchema = 'Retail_DW_Core';
    SET @DestinationTable = 'FinanceSalesAttributionorders';
    SET @LookbackDays = 30;
    SET @CurrentDate = CAST(GETDATE() AS DATE);

    SELECT
        @DateValue = CSTDateValue
    FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

    INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
    VALUES (@String, @DateValue, @User, 'Process Start');

    BEGIN TRY

        DROP TABLE IF EXISTS #OHeader;
        DROP TABLE IF EXISTS #Credit_Temp;
        DROP TABLE IF EXISTS #Credit;
        DROP TABLE IF EXISTS #CreditWithNoSales;
        DROP TABLE IF EXISTS #CreditWithNoSalesCustomerDate;

        /********************* Sales Order Header Data ***********************/
        
        SELECT 
            foh.OrderDate,
            foh.SourceOrderID AS OrderID,
            foh.CustomerID,
            foh.TotalSales + foh.TotalTaxes + foh.TotalCharges AS TotalSales,
            fp.Payments AS FinancedAmount,
            fp.PaymentTypeID AS FinPaymentTypeID,
            foh.SFMCFulfillmentStatus,
            foh.TransCodeID
        INTO #OHeader
        FROM [Retail_DW_Core].[FactSalesOrderHeader] foh
        LEFT JOIN [Retail_DW_Core].[FactPayments] fp 
            ON fp.OrderID = foh.SourceOrderID 
            AND fp.CustomerID = foh.CustomerID
        WHERE foh.OrderDate > '2024-07-01'
          AND foh.TotalSales > 0;

        /********************* Credit Reviews with Order Matching ***********************/
        
        -- Aggregate credit data with order matching
        SELECT 
            RequestDate,
            CustomerID,
            EmailAddress,
            StoreID,
            Region,
            Division,
            MIN(SalesPersonID) AS SalesPersonID,
            MIN(FinanceProviderID) AS FinanceProviderID,
            MIN(ApprovedByLendor) AS ApprovedByLendor,
            SUM(AmountApproved) AS AmountApproved,
            MIN(OrderID) AS OrderID,
            MAX(OrderID2) AS OrderID2
        INTO #Credit_Temp
        FROM (
            
            SELECT 
                CAST(fcr.RequestDateTime AS DATE) AS RequestDate,
                fcr.AmountApproved,
                fcr.CustomerID,
                dcm.EmailAddress,
                fcr.FinanceProviderID,
                fp.Name AS ApprovedByLendor,
                fcr.SalesPersonID,
                fcr.StoreID,
                -- Find first order within 30 days
                (SELECT MIN(oh1.OrderID) 
                 FROM #OHeader AS oh1 
                 WHERE oh1.CustomerID = fcr.CustomerID 
                   AND oh1.OrderDate BETWEEN CAST(fcr.RequestDateTime AS DATE) 
                       AND DATEADD(DAY, @LookbackDays, fcr.RequestDateTime) 
                   AND oh1.TotalSales <> 0) AS OrderID,
                -- Find second order (2-30 days later)
                (SELECT MAX(oh1.OrderID) 
                 FROM #OHeader AS oh1 
                 WHERE oh1.CustomerID = fcr.CustomerID 
                   AND oh1.OrderDate BETWEEN DATEADD(DAY, 2, CAST(fcr.RequestDateTime AS DATE)) 
                       AND DATEADD(DAY, @LookbackDays, fcr.RequestDateTime) 
                   AND oh1.TotalSales <> 0) AS OrderID2,
                -- Get Region from DimRollUps
                (SELECT MIN(r.RollUp)
                 FROM [Retail_DW_Core].[DimRollUps] r
                 WHERE r.RollUpFilter = 'Region'
                   AND r.StoreID = fcr.StoreID) AS Region,
                -- Get Division from DimRollUps
                (SELECT MIN(r.RollUp)
                 FROM [Retail_DW_Core].[DimRollUps] r
                 WHERE r.RollUpFilter = 'Division'
                   AND r.StoreID = fcr.StoreID) AS Division
            FROM [Retail_DW_Core].[FactCreditReview] fcr
            LEFT JOIN [Retail_DW_Core].[FinanceProvider] fp 
                ON fcr.FinanceProviderID = fp.FinanceProviderID
            LEFT JOIN [Retail_DW_Core].[DimCustomerMaster] dcm 
                ON dcm.CustomerID = fcr.CustomerID
            WHERE fcr.RequestDateTime >= '2024-07-01'
              AND fcr.CreditRequestStatusCodeID = 7
              
        ) Dat
        GROUP BY 
            RequestDate,
            CustomerID,
            EmailAddress,
            StoreID,
            Region,
            Division;

        /********************* Combine Same-Day and Later Purchases ***********************/
        
        SELECT * 
        INTO #Credit 
        FROM (
            -- Same day purchases (Yes)
            SELECT  
                'Yes' AS BuySameDay,
                cr.AmountApproved,
                cr.CustomerID,
                cr.EmailAddress,
                cr.ApprovedByLendor,
                cr.RequestDate,
                cr.SalesPersonID,
                cr.StoreID,
                oh2.OrderID,
                oh2.OrderDate,
                LEFT(oh2.OrderID, 10) AS BaseOrder,
                oh2.FinancedAmount,
                oh2.FinPaymentTypeID,
                oh2.SFMCFulfillmentStatus,
                dpt.FinanceUseFee,
                oh2.TotalSales,
                tcm.Description AS OrderType,
                cr.Region,
                cr.Division,
                cr.OrderID AS OrderSameDay,
                COALESCE(oh.FinancedAmount, 0) AS FinancedSameDay
            FROM #Credit_Temp cr
            INNER JOIN [Retail_DW_Core].[FinanceProvider] fp 
                ON cr.FinanceProviderID = fp.FinanceProviderID
            INNER JOIN [Retail_DW_Core].[DimCustomerMaster] dcm 
                ON dcm.CustomerID = cr.CustomerID
            LEFT JOIN #OHeader oh 
                ON oh.OrderID = cr.OrderID
            LEFT JOIN [Retail_DW_Core].[DimPaymentType] dpt 
                ON dpt.PaymentTypeID = oh.FinPaymentTypeID
            LEFT JOIN [Retail_DW_Core].[DimTransCodeMap] tcm 
                ON oh.TransCodeID = tcm.TransCodeID
            LEFT JOIN #OHeader oh2 
                ON oh2.OrderID = cr.OrderID2
            WHERE COALESCE(oh.OrderDate, '2050-12-31') 
                BETWEEN cr.RequestDate AND DATEADD(DAY, 1, cr.RequestDate)

            UNION

            -- Later purchases (No)
            SELECT 
                'No' AS BuySameDay,
                cr.AmountApproved,
                cr.CustomerID,
                cr.EmailAddress,
                cr.ApprovedByLendor,
                cr.RequestDate,
                cr.SalesPersonID,
                cr.StoreID,
                cr.OrderID,
                oh.OrderDate,
                LEFT(oh.OrderID, 10) AS BaseOrder,
                COALESCE(oh.FinancedAmount, 0) AS FinancedAmount,
                oh.FinPaymentTypeID,
                oh.SFMCFulfillmentStatus,
                dpt.FinanceUseFee,
                oh.TotalSales,
                tcm.Description AS OrderType,
                cr.Region,
                cr.Division,
                NULL AS OrderSameDay,
                0 AS FinancedSameDay
            FROM #Credit_Temp cr
            INNER JOIN [Retail_DW_Core].[FinanceProvider] fp 
                ON cr.FinanceProviderID = fp.FinanceProviderID
            INNER JOIN [Retail_DW_Core].[DimCustomerMaster] dcm 
                ON dcm.CustomerID = cr.CustomerID
            LEFT JOIN #OHeader oh 
                ON oh.OrderID = cr.OrderID
            LEFT JOIN [Retail_DW_Core].[DimPaymentType] dpt 
                ON dpt.PaymentTypeID = oh.FinPaymentTypeID
            LEFT JOIN [Retail_DW_Core].[DimTransCodeMap] tcm 
                ON oh.TransCodeID = tcm.TransCodeID
            WHERE COALESCE(oh.OrderDate, '2050-12-31') > DATEADD(DAY, 1, cr.RequestDate)
        ) Dat;

        /********************* Calculate Sales Summaries ***********************/
        
        SELECT 
            BaseOrder,
            SUM(TotalSales) AS sales
        INTO #CreditWithNoSales
        FROM #Credit
        GROUP BY BaseOrder
        HAVING SUM(TotalSales) = 0;

        SELECT 
            CustomerID,
            OrderDate,
            SUM(TotalSales) AS sales
        INTO #CreditWithNoSalesCustomerDate
        FROM #Credit
        GROUP BY CustomerID, OrderDate
        HAVING SUM(TotalSales) = 0;

        /********************* TRUNCATE AND INSERT INTO DESTINATION TABLE ***********************/


        TRUNCATE TABLE [Retail_DW_Core].[FinanceSalesAttributionorders];


        INSERT INTO [Retail_DW_Core].[FinanceSalesAttributionorders]
        (
            BuySameDay,
            AmountApproved,
            CustomerID,
            EmailAddress,
            ApprovedByLendor,
            RequestDate,
            SalespersonID,
            StoreID,
            OrderID,
            OrderDate,
            BaseOrder,
            FinancedAmount,
            FinPaymentTypeID,
            SFMCFulfillmentStatus,
            FinanceUseFee,
            TotalSales,
            OrderType,
            Region,
            Division,
            OrderSameDay,
            FinancedSameDay,
            TotSalesOrder,
            TotSalesCustomerDate,
            Sends,
            SendForOTB,
            [Recheck or Approve No Buy - 1000]
        )
        SELECT 
            c.BuySameDay,
            c.AmountApproved,
            c.CustomerID,
            c.EmailAddress,
            c.ApprovedByLendor,
            c.RequestDate,
            c.SalesPersonID,
            c.StoreID,
            c.OrderID,
            c.OrderDate,
            c.BaseOrder,
            c.FinancedAmount,
            c.FinPaymentTypeID,
            c.SFMCFulfillmentStatus,
            c.FinanceUseFee,
            c.TotalSales,
            c.OrderType,
            c.Region,
            c.Division,
            c.OrderSameDay,
            c.FinancedSameDay,
            -- TotSalesOrder: Categorize sales by base order
            (SELECT 
                CASE 
                    WHEN SUM(sales) = 0 THEN 'Order - No Sales'
                    WHEN SUM(sales) < 0 THEN 'Order - Negative Sales'
                    WHEN SUM(sales) > 0 THEN 'Order - Positive Sales'
                END
             FROM #CreditWithNoSales cws 
             WHERE cws.BaseOrder = c.BaseOrder) AS TotSalesOrder,
            -- TotSalesCustomerDate: Categorize sales by customer and date
            (SELECT 
                CASE 
                    WHEN SUM(sales) = 0 THEN 'Order - No Sales'
                    WHEN SUM(sales) < 0 THEN 'Order - Negative Sales'
                    WHEN SUM(sales) > 0 THEN 'Order - Positive Sales'
                END
             FROM #CreditWithNoSalesCustomerDate cws 
             WHERE cws.CustomerID = c.CustomerID 
               AND cws.OrderDate = c.OrderDate) AS TotSalesCustomerDate,
            -- Sends: Check for Finance_OTB emails within 30 days
            (SELECT 
                CASE WHEN COUNT(1) > 0 THEN 'Y' ELSE 'N' END
             FROM [Retail_DW_Core].[FinanceSalesAttributionSends] fsas 
             WHERE fsas.EmailAddress = c.EmailAddress 
               AND fsas.EventDate BETWEEN c.RequestDate AND DATEADD(DAY, @LookbackDays, c.RequestDate) 
               AND fsas.EmailName LIKE 'Finance_OTB%') AS Sends,
            -- SendForOTB: Check for emails between request and order date
            (SELECT 
                CASE WHEN COUNT(1) > 0 THEN 'Y' ELSE 'N' END
             FROM [Retail_DW_Core].[FinanceSalesAttributionSends] fsas 
             WHERE fsas.EmailAddress = c.EmailAddress 
               AND fsas.EventDate BETWEEN c.RequestDate AND c.OrderDate 
               AND fsas.EmailName LIKE 'Finance_OTB%') AS SendForOTB,
            -- ✅ ADDED: Classification column for Power BI
            CASE 
                WHEN c.BuySameDay = 'Yes' THEN 'Recheck'
                WHEN c.BuySameDay = 'No' THEN 'Approved No Buys'
                ELSE NULL
            END AS [Recheck or Approve No Buy - 1000]
        FROM #Credit c;

        -- Cleanup temp tables
        DROP TABLE IF EXISTS #OHeader;
        DROP TABLE IF EXISTS #Credit_Temp;
        DROP TABLE IF EXISTS #Credit;
        DROP TABLE IF EXISTS #CreditWithNoSales;
        DROP TABLE IF EXISTS #CreditWithNoSalesCustomerDate;

        SET @DateValue = GETDATE();

        SELECT @DateValue = CSTDateValue
        FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

        INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
        VALUES (@String, @DateValue, @User, 'Process Complete');

        EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] 
            @DestinationDatabase, @DestinationSchema, @DestinationTable;
    
    END TRY
    BEGIN CATCH
        
        DECLARE
            @ErrorMessage VARCHAR(4000),
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

        DROP TABLE IF EXISTS #OHeader;
        DROP TABLE IF EXISTS #Credit_Temp;
        DROP TABLE IF EXISTS #Credit;
        DROP TABLE IF EXISTS #CreditWithNoSales;
        DROP TABLE IF EXISTS #CreditWithNoSalesCustomerDate;

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

    END CATCH
END;