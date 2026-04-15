CREATE PROC [AFISales_DW].[usp_Update_FactOpenOrdersSnapshot] 
AS

BEGIN

/* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [AFISales_DW].[usp_Update_FactOpenOrdersSnapshot]
* 11/03/2025 Dhivya Pichaimani converted to Fabric
---------------------------------------------------------------------------------------------------------------------------*/


DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME,
            @User      VARCHAR(500);
       
        SET @String =  'AFISales_DW.AFISales_DW.usp_Update_FactOpenOrdersSnapshot';
        SET @User = SYSTEM_USER;
        SET @DateValue = GETDATE();
        SELECT @DateValue=CSTDateValue from [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue)

		INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            );

BEGIN TRY
	
		
		DECLARE @MaxSnapShotDate DATE
        SELECT @MaxSnapShotDate =  ISNULL(MAX(CONVERT(DATE,[Inserted Date])),'1900-01-01') FROM [AFISales_DW].[FactOpenOrdersSnapshot]

IF @MaxSnapShotDate != CONVERT(DATE,@DateValue)

BEGIN


INSERT INTO [AFISales_DW].[FactOpenOrdersSnapshot]
           (
            [Order Taken Date]
           ,[Order Number]
           ,[Item Sequence Number]
           ,[Account And Shipto Number]
           ,[Customer Account Number]
           ,[Customer Shipto Number]
           ,[SalesTerritoryID]
           ,[Territory]
           ,[Item Key]
           ,[Item SKU]
           ,[Billto Address ID]
           ,[Shipto Address ID]
           ,[Warehouse]
           ,[Open Order Amount]
           ,[Open Order Quantity]
           ,[Back Order Amount]
           ,[Back Order Quantity]
           ,[Original Promise Date]
           ,[Current Promise Date]
           ,[Original Request Date]
           ,[Current Request Date]
		       ,[Estimated Delivery Date]
		       ,[Initial Request Date]
           ,[Primary Order Type]
           ,[Secondary Order Type]
           ,[3rd Order Type]
           ,[4th Order Type]
           ,[Inserted Date]
		   ,[Inventory Allocated Flag]
		   ,[Current Load Date]
		   ,[Count of Load Date Changes]
		   ,[Load Lead Time]
		   ,[Shipping Instructions]
		   ,[Order Arrival Mode])

SELECT  [Order Taken Date],
        [Order Number],
        [Item Sequence Number],
	    [Account And ShipTo Number]=  Case When idsShipNum is Null or idsShipNum = ''	Then idsAccountNum	Else RTRIM(idsAccountNum) + '-' + LTRIM(idsShipNum) End ,
		[Customer Account Number]=idsAccountNum	,
		[Customer Shipto Number]=idsShipNum,
	    [SalesTerritoryID],
		[Territory] = Territory,
		[Item Key]='ASHLEY_'+isnull(idsItemNum, ''),
		[Item SKU]= isnull(idsItemNum, ''),
		[Billto Address ID] = idsStoreAddressID, 
		[Shipto Address ID] = idsRouteAddressID,
		[Warehouse]= isnull(idsWarehouse, ''),
		[Open Order Amount] = cast(idsOpenOrderAmt * isnull(CommissionSplitPercent,1) as money),
		[Open Order Quantity] = cast(idsOpenOrderQty * isnull(CommissionSplitPercent,1) as decimal(13,3)) ,
		[Back Order Amount] = cast(idsBackOrderAmt * isnull(CommissionSplitPercent,1) as money),
		[Back Order Quantity] = cast(idsBackOrderQty * isnull(CommissionSplitPercent,1) as decimal(13,3)) ,
		[Original Promise Date],
		[Current Promise Date],
		[Original Request Date],
		[Current Request Date],
		[Estimated Delivery Date],
       COALESCE([Initial Request Date],[Original Promise Date]) as [Initial Request Date],
		[Primary Order Type],
		[Secondary Order Type],
		[3rd Order Type],
		[4th Order Type],
		@DateValue AS [Inserted Date],
		[Inventory Allocated Flag], 
		[Current Load Date],
		[Count of Load Date Changes],
		[Load Lead Time],
		[Shipping Instructions],
		[Order Arrival Mode] =idsOrderArrival

 FROM	
(
SELECT cast(str(CASE WHEN T3.ORDTE=0 Then 19990101 Else T3.ORDTE End) AS date)  as [Order Taken Date],
        T1.[ORDNO] AS [Order Number], 
        T1.[ITMSQ] AS [Item Sequence Number],
        T1.CCUSNO as idsAccountNum, 
        T1.CSHPNO as  idsShipNum, 
        C.[Store Address ID] as idsStoreAddressID,
        C.[Shipto AddressID] as idsRouteAddressID, 
	    T1.ITNBR as idsItemNum, 
		AFISalesDivisionCode as  idsDivision, 
		M.[Msa Fips Code] as idsMsaFips,
		 T1.HOUSE as idsWarehouse	,	
        CASE WHEN CAST([Shipto Sales Territory] AS Int) = 0  Then [Primary Sales Territory] Else [Primary Sales Territory]+[Shipto Sales Territory] end as Territory,
		CASE WHEN CAST([Shipto Sales Territory] AS Int) = 0 THEN [Primary Sales Territory] ELSE [Shipto Sales Territory] END AS DefaultTerritory,
		 T1.COQTY - T1.QTYSH as idsOpenOrderQty,
		 T1.QTYBO as idsBackOrderQty,
		AFISalesCategoryCode AS imaSlscat,
		--((T1.INSAM/case when T1.QTYBO > 0 then T1.QTYBO else T1.COQTY end) - T2.IFRGHT) * case when T1.QTYBO > 0 then T1.QTYBO else T1.COQTY end as idsOpenOrderAmt, 
		((ISNULL(T1.INSAM,0)/case when ISNULL(T1.QTYBO,0) > 0 then ISNULL(T1.QTYBO,0) else (case when ISNULL(T1.COQTY,0) > 0 then  ISNULL(T1.COQTY,0) else 1 end)end) - ISNULL(T2.IFRGHT,0)) * case when ISNULL(T1.QTYBO,0) > 0 then ISNULL(T1.QTYBO,0) else (case when ISNULL(T1.COQTY,0) > 0 then  ISNULL(T1.COQTY,0) else 1 end) end
  as idsOpenOrderAmt,--Modified by saravanan date 05-18-19 
		Case when ISNULL(T1.QTYBO,0) > 0 Then ((ISNULL(T1.INSAM,0)/ISNULL(T1.QTYBO,0)) - ISNULL(T2.IFRGHT,0)) * ISNULL(T1.QTYBO,0) else 0 end as idsBackOrderAmt, 
		 T4.ORDARR as idsOrderArrival,
		 0 as idsStandardCost,
		 cast(str(CASE WHEN T2.IPRMDT=0 Then NULL Else T2.IPRMDT End) AS date) as [Original Promise Date],
		 cast(str(CASE WHEN T1.RQIDT=0  Then NULL Else T1.RQIDT  End) AS date) as [Current Promise Date],
		 cast(str(CASE WHEN T4.FRZDAT=0 Then NULL Else T4.FRZDAT End) AS date) as [Original Request Date],
		 cast(str(CASE WHEN T4.RQSDAT=0 Then NULL Else T4.RQSDAT End) AS date) as [Current Request Date],
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
                   ) AS DATE) AS [Initial Request Date],    
[Primary Order Type]=  OT1.OTDES1,
		[Secondary Order Type]= OT2.OTDES1,
		[3rd Order Type]=OT3.OTDES1,
		[4th Order Type]=OT4.OTDES1,
			T1.[IAFLG] AS [Inventory Allocated Flag],
		cast(str(CASE WHEN T1.MFIDT=0  Then NULL Else T1.MFIDT  End) AS date) AS [Current Load Date],
		T1.[NUMLDDTCHG] AS [Count of Load Date Changes],
		T3.[SHLTC] AS [Load Lead Time],
		T3.[SHINS] AS [Shipping Instructions]	 
  FROM  [$(Source_Data)].[Wholesale_Codis_AFI].[codatan] T1 
        LEFT JOIN  [$(Source_Data)].[Wholesale_Codis_AFI].[EXTORIT] T2  ON (T1.ORDNO = T2.IORD AND T1.ITMSQ = T2.ISEQ)
		JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[COMAST] T3   ON (T1.ORDNO = T3.ORDNO)
		JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[EXTORD] T4  ON (T1.ORDNO = T4.XORDNO)
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
		LEFT Join AFISales_DW.DimCustomers C  on C.[Customer Account Number] = T1.CCUSNO AND  C.[Customer Shipto Number]=T1.CSHPNO		
        LEFT JOIN AFISales_DW.DimGeographicLocations M ON [Shipto AddressID] = [Address ID]
        JOIN [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster IM on IM.ItemSKU=T1.ITNBR
	    Left Join [$(Source_Data)].[Wholesale_Codis_AFI].[AAORDTYP] ot1  on ot1.OTCODE=T4.[OTTYP1]
	    Left Join [$(Source_Data)].[Wholesale_Codis_AFI].[AAORDTYP] ot2  on ot2.OTCODE=T4.[OTTYP2]
		Left Join [$(Source_Data)].[Wholesale_Codis_AFI].[AAORDTYP] ot3  on ot3.OTCODE=T4.[OTTYP3]
		Left JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[AAORDTYP] ot4  on ot4.OTCODE=T4.[OTTYP4]
  where (T1.QTYBO <> 0 or T1.COQTY <> 0) and PRICE <> 0 and T3.ACREC <> 'X' AND T1.COQTY >= 0
    	) orders
	left join AFISales_Enh.TerritoryAllocationStatic  on DefaultTerritory = TerritoryCode	and imaSlscat = SalesCategory
	Left Join AFISales_DW.[DimSalesTerritories] 
	         on [AFI Sales Region Code]= isnull(RegionCode,CAST('Z' AS CHAR(3))) 
		    and [AFI Sales RepID]=       isnull(RepID,  CAST('ZZZZZ' AS CHAR(5)))
		    and [AFI Sales Category]=    isnull(imaSlscat, CAST('ZZ' AS CHAR(3))) 
			and [Active Record] = 1

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
                'AFISales_DW', 'AFISales_DW', 'FactOpenOrdersSnapshot', @DateValue
            );

        INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog -- (aloDesc,aloDateTime,aloUser,aloCommand) 
        VALUES
            (
                @String, @DateValue, @User, 'Process Complete'
            );

    END;
GO


