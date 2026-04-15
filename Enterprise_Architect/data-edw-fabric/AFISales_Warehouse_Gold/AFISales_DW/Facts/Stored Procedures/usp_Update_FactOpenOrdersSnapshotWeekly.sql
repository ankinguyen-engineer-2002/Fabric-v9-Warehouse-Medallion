
CREATE PROC [AFISales_DW].[usp_Update_FactOpenOrdersSnapshotWeekly] AS


BEGIN
/* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [AFISales_DW].[usp_Update_FactOpenOrdersSnapshotWeekly]
* Description: This procedure is created as per request from amanda and Mike ward to capture openorder snapshot only on Saturday aftr 10 PM
* created by - Indumathi  
* created date - 14/06/2024
* 11/03/2025 Dhivya Pichaimani converted to Fabric
---------------------------------------------------------------------------------------------------------------------------*/

DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME,
            @User      VARCHAR(500);
       
        SET @String =  'AFISales_DW.AFISales_DW.usp_Update_FactOpenOrdersSnapshotWeekly';
        SET @User = SYSTEM_USER;
        SET @DateValue = GETDATE();
        SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

		INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

BEGIN TRY

DECLARE @WeekDay VARCHAR(10) ,@CurrentDate DATE  

SET @CurrentDate= CAST(@DateValue AS DATE)
SET @WeekDay = DATENAME(dw, @CurrentDate)

IF @WeekDay='Saturday'
BEGIN

INSERT INTO [AFISales_DW].[FactOpenOrdersSnapshotWeekly]
      (
	   [Order Taken Date]
      ,[Order Number]
      ,[Item Sequence Number]
      ,[Account And ShipTo Number]
      ,[Customer Account Number]
      ,[Customer Shipto Number]
      ,[SalesTerritoryID]
      ,[Territory]
      ,[Item Key]
      ,[Item Sku]
      ,[Sales Division Code]
      ,[Billto Address ID]
      ,[Shipto Address ID]
      ,[Warehouse]
      ,[Item Status]
      ,[Sales Category Code]
      ,[Open Order Amount]
      ,[Open Order Quantity]
      ,[Back Order Amount]
      ,[Order Arrival Mode]
      ,[Back Order Quantity]
      ,[Original Promise Date]
      ,[Current Promise Date]
      ,[Estimated Delivery Date]
      ,[Initial Promise Date]
      ,[Original Request Date]
      ,[Current Request Date]
      ,[Primary Order Type]
      ,[Secondary Order Type]
      ,[3rd Order Type]
      ,[4th Order Type]
      ,[Inventory Allocated Flag]
      ,[Current Load Date]
      ,[Count of Load Date Changes]
      ,[Load Lead Time]
      ,[Shipping Instructions]
      ,[RegionCode_RepID_Cat]
      ,[Sales Region Code]
      ,[Sales Rep ID]
      ,[Customer SKU/Package]
      ,[Customer Shipto Division Number]
      ,[Open Order Discounts]
      ,[Open Order Freight]
      ,[Trip Numbers]
      ,[Customer PO]
	  ,[SnapshotDate]
       )

SELECT orders.[Order Taken Date],
       CAST(orders.[Order Number] as VARCHAR(10)) as [Order Number],
       orders.[Item Sequence Number],
       [Account And ShipTo Number] = CAST(CASE
                                         WHEN idsShipNum IS NULL
                                              OR idsShipNum = '' THEN
                                             idsAccountNum
                                         ELSE
                                             RTRIM(idsAccountNum) + '-' + LTRIM(idsShipNum)
                                     END as VARCHAR(13)) ,
       [Customer Account Number] = idsAccountNum,
       [Customer Shipto Number] = idsShipNum,
       [SalesTerritoryID],
       [Territory] = Territory,
       [Item Key] = 'ASHLEY_' + ISNULL(idsItemNum, ''),
       [Item SKU] = ISNULL(idsItemNum, ''),
       [Sales Division Code] = idsDivision,
       [Billto Address ID] = idsStoreAddressID,
       [Shipto Address ID] = idsRouteAddressID,
       [Warehouse] = ISNULL(idsWarehouse, ''),
       [Item Status] = CAST(idsItemStatus as CHAR(3)),
       [Sales Category Code] = CAST(imaSlscat as char(3)),
       [Open Order Amount] = CAST(idsOpenOrderAmt * ISNULL(CommissionSplitPercent, 1) AS DECIMAL(19, 2)),
       [Open Order Quantity] = CAST(idsOpenOrderQty * ISNULL(CommissionSplitPercent, 1) AS DECIMAL(13, 3)),
       [Back Order Amount] = CAST(idsBackOrderAmt * ISNULL(CommissionSplitPercent, 1) AS MONEY),
       [Order Arrival Mode] = idsOrderArrival,
       [Back Order Quantity] = CAST(idsBackOrderQty * ISNULL(CommissionSplitPercent, 1) AS DECIMAL(13, 3)),
       [Original Promise Date],
       [Current Promise Date],
       [Estimated Delivery Date],
       COALESCE([Initial Promise Date],[Original Promise Date]) as [Initial Promise Date],
       [Original Request Date],
       [Current Request Date],
       [Primary Order Type],
       [Secondary Order Type],
       [3rd Order Type],
       [4th Order Type],
       [Inventory Allocated Flag],
       [Current Load Date],
       [Count of Load Date Changes],
       [Load Lead Time],
       [Shipping Instructions],
       [RegionCode_RepID_Cat] = ST.[RegionCode_RepID_Category],
       [Sales Region Code] = ST.[AFI Sales Region Code],
       [Sales Rep ID] = ST.[AFI Sales RepID],
       [Customer SKU/Package] = skuNo,
       [Customer Shipto Division Number] = RTRIM(   CASE
                                                        WHEN idsShipNum IS NULL
                                                             OR idsShipNum = '' THEN
                                                            RTRIM(idsAccountNum) + '-'
                                                        ELSE
                                                            RTRIM(idsAccountNum) + '-' + LTRIM(idsShipNum)
                                                    END
                                                ) + '-' + idsDivision,
       [Open Order Discounts] = CAST((Orders.[Order Discount] ) * ISNULL(CommissionSplitPercent, 1) AS DECIMAL(13, 3)), -- Rev 10
       [Open Order Freight] = CAST((Orders.[Order Freight] * idsOpenOrderQty) * ISNULL(CommissionSplitPercent, 1) AS DECIMAL(13, 3)),    -- Rev 10      
       [Trip Numbers] = cast(TripNo as varchar(650)),
       [Customer PO] = Cuspo,
	   [SnapshotDate] = SnapshotDate
FROM
(
    SELECT CAST(STR(   CASE
                           WHEN T3.ORDTE = 0 THEN
                               19990101
                           ELSE
                               T3.ORDTE
                       END
                   ) AS DATE) AS [Order Taken Date],
           T1.[ORDNO] AS [Order Number],
           T1.[ITMSQ] AS [Item Sequence Number],
           T1.CCUSNO AS idsAccountNum,
           T1.CSHPNO AS idsShipNum,
           T2.IDSCNT+T2.IDFIDC as [Order Discount],
           T2.IFRGHT as [Order Freight],
           C.[Store Address ID] AS idsStoreAddressID,
           C.[Shipto AddressID] AS idsRouteAddressID,
           T1.ITNBR AS idsItemNum,
           AFISalesDivisionCode AS idsDivision,
           M.[Msa Fips Code] AS idsMsaFips,
           T1.HOUSE AS idsWarehouse,
           AFIItemStatus AS idsItemStatus,
           CASE
               WHEN CAST([Shipto Sales Territory] AS INT) = 0 THEN
                   [Primary Sales Territory]
               ELSE
                   [Primary Sales Territory] + [Shipto Sales Territory]
           END AS Territory,
           CASE
               WHEN CAST([Shipto Sales Territory] AS INT) = 0 THEN
                   [Primary Sales Territory]
               ELSE
                   [Shipto Sales Territory]
           END AS DefaultTerritory,
           T1.COQTY - T1.QTYSH AS idsOpenOrderQty,
           T1.QTYBO AS idsBackOrderQty,
           AFISalesCategoryCode AS imaSlscat,
           ((ISNULL(T1.INSAM, 0) / CASE
                                       WHEN ISNULL(T1.QTYBO, 0) > 0 THEN
                                           ISNULL(T1.QTYBO, 0)
                                       ELSE
           (CASE
                WHEN ISNULL(T1.COQTY, 0) > 0 THEN
                    ISNULL(T1.COQTY, 0)
                ELSE
                    1
            END
           )
                                   END
            ) - ISNULL(T2.IFRGHT, 0)
           ) * CASE
                   WHEN ISNULL(T1.QTYBO, 0) > 0 THEN
                       ISNULL(T1.QTYBO, 0)
                   ELSE
           (CASE
                WHEN ISNULL(T1.COQTY, 0) > 0 THEN
                    ISNULL(T1.COQTY, 0)
                ELSE
                    1
            END
           )
               END AS idsOpenOrderAmt, 
           CASE
               WHEN ISNULL(T1.QTYBO, 0) > 0 THEN
           ((ISNULL(T1.INSAM, 0) / ISNULL(T1.QTYBO, 0)) - ISNULL(T2.IFRGHT, 0)) * ISNULL(T1.QTYBO, 0)
               ELSE
                   0
           END AS idsBackOrderAmt,
           T4.ORDARR AS idsOrderArrival,
           0 AS idsStandardCost,
           CAST(STR(   CASE
                           WHEN T2.IPRMDT = 0 THEN
                               NULL
                           ELSE
                               T2.IPRMDT
                       END
                   ) AS DATE) AS [Original Promise Date],
           CAST(STR(   CASE
                           WHEN T1.RQIDT = 0 THEN
                               NULL
                           ELSE
                               T1.RQIDT
                       END
                   ) AS DATE) AS [Current Promise Date],
           CAST(STR(   CASE
                           WHEN T1.RQIDT = 0 THEN
                               NULL
                           ELSE
                               T1.RQIDT
                       END
                   ) AS DATE) AS [Estimated Delivery Date],
           CAST(STR(   CASE
                           WHEN T6.RequestDate = 0 THEN
                               NULL
                           ELSE
                               T6.RequestDate
                       END
                   ) AS DATE) AS [Initial Promise Date],    
           CAST(STR(   CASE
                           WHEN T4.FRZDAT = 0 THEN
                               NULL
                           ELSE
                               T4.FRZDAT
                       END
                   ) AS DATE) AS [Original Request Date],
           CAST(STR(   CASE
                           WHEN T4.RQSDAT = 0 THEN
                               NULL
                           ELSE
                               T4.RQSDAT
                       END
                   ) AS DATE) AS [Current Request Date],
           [Primary Order Type] = ot1.OTDES1,
           [Secondary Order Type] = ot2.OTDES1,
           [3rd Order Type] = ot3.OTDES1,
           [4th Order Type] = ot4.OTDES1,
           T1.[IAFLG] AS [Inventory Allocated Flag],
           CAST(STR(   CASE
                           WHEN T1.MFIDT = 0 THEN
                               NULL
                           ELSE
                               T1.MFIDT
                       END
                   ) AS DATE) AS [Current Load Date],
           T1.[NUMLDDTCHG] AS [Count of Load Date Changes],
           T3.[SHLTC] AS [Load Lead Time],
           T3.[SHINS] AS [Shipping Instructions],
           CASE ITDSI
               WHEN ITDSC THEN
                   ''
               ELSE
                   ITDSI
           END AS skuNo,
           T5.BDTRP AS TripNo,
           T3.CUSPO,
		   @CurrentDate as SnapshotDate
    FROM [$(Source_Data)].[Wholesale_Codis_AFI].[codatan] T1
        INNER JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[EXTORIT] T2
            ON (
                   T1.ORDNO = T2.IORD
                   AND T1.ITMSQ = T2.ISEQ
               )
        INNER JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[COMAST] T3
            ON (T1.ORDNO = T3.ORDNO)
        JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[EXTORD] T4
            ON (T1.ORDNO = T4.XORDNO)
        LEFT JOIN
        (
            SELECT BDCUS#,
                   BDORD#,
                   BDITM#,
                   BDISEQ,
                   STRING_AGG(BDTRP#, ', ') AS BDTRP
            FROM [$(Databricks)].[wholesale_codis].[bttripd] 
            GROUP BY BDCUS#,
                     BDORD#,
                     BDITM#,
                     BDISEQ
        ) T5
            ON (
                   T1.CCUSNO = T5.BDCUS#
                   AND T1.ORDNO = T5.BDORD#
                   AND T1.ITNBR = T5.BDITM#
                   AND T1.ITMSQ = T5.BDISEQ
               )
        LEFT JOIN
        (
            SELECT CustomerNumber,
                   OrderNumber,
                   ItemSKU,
                   ItemSequence,
                   Min(RequestDate) as RequestDate
            FROM [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
            GROUP BY CustomerNumber,
                   OrderNumber,
                   ItemSKU,
                   ItemSequence
        ) T6
            ON (
                   T1.CCUSNO = T6.CustomerNumber
                   AND T1.ORDNO = T6.OrderNumber
                   AND T1.ITNBR = T6.ItemSKU
                   AND T1.ITMSQ = T6.ItemSequence
               )
        LEFT JOIN AFISales_DW.DimCustomers C
            ON C.[Customer Account Number] = T1.CCUSNO
               AND C.[Customer Shipto Number] = T1.CSHPNO
        LEFT JOIN AFISales_DW.DimGeographicLocations M
            ON [Shipto AddressID] = [Address ID]
        JOIN [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster IM
            ON IM.ItemSKU = T1.ITNBR
        LEFT JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[AAORDTYP] ot1
            ON ot1.OTCODE = T4.[OTTYP1]
        LEFT JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[AAORDTYP] ot2
            ON ot2.OTCODE = T4.[OTTYP2]
        LEFT JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[AAORDTYP] ot3
            ON ot3.OTCODE = T4.[OTTYP3]
        LEFT JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[AAORDTYP] ot4
            ON ot4.OTCODE = T4.[OTTYP4]
    WHERE (
              T1.QTYBO <> 0
              OR T1.COQTY <> 0
          )
          AND PRICE <> 0
          AND T3.ACREC <> 'X'
          AND T1.COQTY >= 0
) orders
    LEFT JOIN AFISales_Enh.TerritoryAllocationStatic
        ON DefaultTerritory = TerritoryCode
           AND imaSlscat = SalesCategory
    LEFT JOIN AFISales_DW.[DimSalesTerritories] ST
        ON [AFI Sales Region Code] = ISNULL(RegionCode, CAST('Z' AS CHAR(3)))
           AND [AFI Sales RepID] = ISNULL(RepID, CAST('ZZZZZ' AS CHAR(5)))
           AND [AFI Sales Category] = ISNULL(imaSlscat, CAST('ZZ' AS CHAR(3)))
           AND [Active Record] = 1;

END


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


        INSERT INTO [$(ETL_Framework)].DW_Developer.TableDictionary_UpdateLog
        VALUES
            (
                'AFISales_DW', 'AFISales_DW', 'FactOpenOrdersSnapshotWeekly', @DateValue
            );

        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog -- (aloDesc,aloDateTime,aloUser,aloCommand) 
        VALUES
            (
                @String, @DateValue, @User, 'Process Complete'
            );

    END;
GO