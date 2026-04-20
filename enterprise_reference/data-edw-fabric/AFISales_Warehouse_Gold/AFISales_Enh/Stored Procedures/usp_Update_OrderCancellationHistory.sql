CREATE PROC [AFISales_Enh].[usp_Update_OrderCancellationHistory]
AS

    /* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure:[AFISales_Enh].[usp_Update_OrderCancellationHistory]
* Description: Process updates [AFISales_Enh].[OrderCancellationHistory]
* 21/07/2020 Srinath:Created the sproc based on the script shared by SCP Team,SR 920054
* Ragavan V 02/16/2021 -* Ragavan V (02/16/2021) -Changed Afisales_Enh to AFISales_Enh 
*  Bob Horton 10/24/2023 converted to Fabric
---------------------------------------------------------------------------------------------------------------------------*/

    BEGIN

        DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME2(6),
            @User      VARCHAR(500);

        SET @String = 'AFISales_DW.AFISales_Enh.usp_Update_OrderCancellationHistory';
        SET @User = SYSTEM_USER;

        SET @DateValue = Getdate()
         SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

        BEGIN TRY

            ---MaintainRolling 12 months ----
            DELETE FROM
            [AFISales_Enh].[OrderCancellationHistory]
            WHERE
                CAST([Change Date] AS DATE) < DATEADD(DAY, -365, CAST(@DateValue AS DATE))

            ---------------------------------------------------------------------------

            IF EXISTS
                (
                    SELECT DISTINCT
                           1
                    FROM
                           [AFISales_Enh].[OrderCancellationHistory]
                    WHERE
                           CAST([Change Date] AS DATE) = DATEADD(DAY, -1, CAST(@DateValue AS DATE))
                )
                BEGIN
                    DELETE FROM
                           [AFISales_Enh].[OrderCancellationHistory]
                    WHERE
                            CAST([Change Date] AS DATE) =DATEADD(DAY, -1, CAST(@DateValue AS DATE))
                END;

            INSERT INTO [AFISales_Enh].[OrderCancellationHistory]
                (
                    [Order Taken Date],
                    [Order Number],
                    [Account And Shipto Number],
                    [Customer Account Number],
                    [Customer Shipto Number],
                    [Item SKU],
                    [Item Sequence Number],
                    [Warehouse],
                    [Open Order Quantity],
                    [Back Order Quantity],
                    [Cancelled Quantity],
                    [Open Order Amount],
                    [Back Order Amount],
                    [Cancelled Amount],
                    [OrigReqWkEnded],
                    [Original Promise Date],
                    [Current Promise Date],
                    [Original Request Date],
                    [Current Request Date],
                    [Cancel Reason Code],
                    [Cancel Reason Description],
                    [Primary Order Type],
                    [Secondary Order Type],
                    [3rd Order Type],
                    [4th Order Type],
                    [Inserted Date],
                    [Inventory Allocated Flag],
                    [Current Load Date],
                    [Count of Load Date Changes],
                    [Load Lead Time],
                    [Change Date]
                )
                        SELECT
                                OO.[Order Taken Date],
                                OO.[Order Number],
                                OO.[Account And Shipto Number],
                                OO.[Customer Account Number],
                                OO.[Customer Shipto Number],
                                OO.[Item SKU],
                                OO.[Item Sequence Number],
                                OO.[Warehouse],
                                SUM(OO.[Open Order Quantity])           AS [Open Order Quantity],
                                SUM(OO.[Back Order Quantity])           AS [Back Order Quantity],
                                [OH].[ADQNTY]                           AS [Cancelled Quantity],
                                SUM(OO.[Open Order Amount])             AS [Open Order Amount],
                                SUM(OO.[Back Order Amount])             AS [Back Order Amount],
                                [OH].[ADNETA]                           AS [Cancelled Amount],
                                CONVERT(DATE, [D].[Fiscal Week Ended])  AS [OrigReqWkEnded],
                                OO.[Original Promise Date],
                                OO.[Current Promise Date],
                                OO.[Original Request Date],
                                OO.[Current Request Date],
                                [OH].[ReasonCode]                       AS [Cancel Reason Code],
                                [OH].[ReasonDescription]                AS [Cancel Reason Description],
                                OO.[Primary Order Type],
                                OO.[Secondary Order Type],
                                OO.[3rd Order Type],
                                OO.[4th Order Type],
                                OO.[Inserted Date],
                                OO.[Inventory Allocated Flag],
                                OO.[Current Load Date],
                                OO.[Count of Load Date Changes],
                                OO.[Load Lead Time],
                                [OH].[ADCHGD_Date]                      AS [Change Date]
                        FROM
                                [AFISales_DW].[FactOpenOrdersSnapshot]              AS OO
                            INNER JOIN
                                (
                                    SELECT
                                            OH.[OrderNumber],
                                            OH.[CustomerNumber],
                                            OH.[ShiptoNumber],
                                            OH.[Warehouse],
                                            OH.[ItemSKU],
                                            OH.[ItemSequence],
                                            [R].[ReasonCode],
                                            [R].[ReasonDescription],
                                            SUM(OH.[Quantity])                       AS [ADQNTY],
                                            SUM(OH.[NetAmount])                      AS [ADNETA],
                                            CONVERT(DATE, OH.[OrderChangeDate])      AS [ADCHGD_Date]
                                    FROM
                                            [$(Wholesale_Warehouse)].SalesHistory_AFI.[OrderHistory]         AS OH
                                        LEFT JOIN
                                            [$(Wholesale_Warehouse)].CustomerOrders_AFI.[OrderCancellationReasonCode] AS R
                                                ON [OH].[ReasonCode] = [R].[ReasonCode]
                                    WHERE
                                            OH.[OrderChangeDate] = CONVERT(
                                                                                                  DATE,
                                                                                                  DATEADD(
                                                                                                             DAY, -1,
                                                                                                             GETDATE()
                                                                                                         )
                                                                                              )
                                            AND [OH].[Warehouse] IN (
                                                                        '1', '12', '15', '16', '17', '19', '28', '3',
                                                                        '335', '42', '5', 'ECR'
                                                                    )
                                            AND [OH].[Quantity] < 0
                                    GROUP BY
                                            CONVERT(DATE, OH.[OrderChangeDate]),
                                            [OH].[OrderNumber],
                                            [OH].[CustomerNumber],
                                            [OH].[ShiptoNumber],
                                            [OH].[Warehouse],
                                            [OH].[ItemSKU],
                                            [OH].[ItemSequence],
                                            [R].[ReasonCode],
                                            [R].[ReasonDescription]
                                )                                                   AS OH
                                    ON [OH].[OrderNumber] = [OO].[Order Number]
                                       AND [OH].[CustomerNumber] = [OO].[Customer Account Number]
                                       AND [OH].[ShiptoNumber] = [OO].[Customer Shipto Number]
                                       AND [OH].[Warehouse] = [OO].[Warehouse]
                                       AND [OH].[ItemSKU] = [OO].[Item SKU]
                                       AND [OH].[ItemSequence] = [OO].[Item Sequence Number]
                                       AND [OH].[ADCHGD_Date] = CONVERT(DATE, [OO].[Inserted Date])
                            LEFT JOIN
                                AFISales_DW.DimDateFile AS D
                                    ON DATEADD(DAY, -ISNULL([OO].[Load Lead Time], 0), [OO].[Original Request Date]) = [D].[Transaction Date]
                        WHERE
                                [OO].[Inserted Date] < CONVERT(DATE, @DateValue)
                                AND [OO].[Warehouse] IN (
                                                            '1', '12', '15', '16', '17', '19', '28', '3', '335', '42', '5',
                                                            'ECR'
                                                        )
                        GROUP BY
                                CONVERT(DATE, [D].[Fiscal Week Ended]),
                                [OO].[Order Taken Date],
                                [OO].[Order Number],
                                [OO].[Item Sequence Number],
                                [OO].[Account And Shipto Number],
                                [OO].[Customer Account Number],
                                [OO].[Customer Shipto Number],
                                [OO].[Item SKU],
                                [OO].[Warehouse],
                                [OH].[ADQNTY],
                                [OH].[ADNETA],
                                [OH].[ReasonCode],
                                [OH].[ReasonDescription],
                                [OO].[Original Promise Date],
                                [OO].[Current Promise Date],
                                [OO].[Original Request Date],
                                [OO].[Current Request Date],
                                [OO].[Primary Order Type],
                                [OO].[Secondary Order Type],
                                [OO].[3rd Order Type],
                                [OO].[4th Order Type],
                                [OO].[Inserted Date],
                                [OO].[Inventory Allocated Flag],
                                [OO].[Current Load Date],
                                [OO].[Count of Load Date Changes],
                                [OO].[Load Lead Time],
                                [OH].[ADCHGD_Date];

        END TRY
        BEGIN CATCH

            DECLARE
                @ErrorMessage  VARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState    INT;
            SET @ErrorMessage = ERROR_MESSAGE();
            SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
            SET @ErrorState = ISNULL(ERROR_STATE(), 0);

            SET @DateValue = Getdate()
             SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

            INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
            VALUES
                (
                    @String, @DateValue, @User, @ErrorMessage
                );

            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);


        END CATCH;

          SET @DateValue = Getdate()
            SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

        EXEC [$(ETL_Framework)].DW_Developer.usp_UpdateTableDictionary_ModifiedDate 
            'AFISales_DW','AFISales_Enh', 'OrderCancellationHistory', @String, @DateValue;

    END;