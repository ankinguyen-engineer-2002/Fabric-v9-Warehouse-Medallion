CREATE VIEW CostAccounting_DW_Wrk.v_DimItemDetail AS
SELECT	 
				 [ItemDetailKey]							= CAST(ROW_NUMBER() OVER( ORDER BY (SELECT 1))  AS Bigint) 
				 , [Item Number]								
 				,[Quantity Unit of Measure]					
				,[Item Class]								
				,[Item Class Description]					
				,[Item Description]							
				,[Item Type]								
				,[Financial Division]						
				,[Financial Division Description]			
				,[Sales Division]							
				,[Sales Division Description]				
				,[Freight Sales Class]						
				,[Commission Sales Class]					
				,[Series]									
				,[Discount Sales Class]						
				,[Manufacturing Status Code]				
				,[Manufacturing Status Description]			
 
FROM
     (SELECT DISTINCT
				 [Item Number]								= cast(TRIM(SHCD.SHCITEMNUMBER) as varchar(25))
 				,[Quantity Unit of Measure]					= cast(TRIM(SHCD.SHCQUANTITYUNITOFMEASURE) as char(2)) 
				,[Item Class]								= cast(TRIM(SHCITEMCLASS) as char(4))  
				,[Item Class Description]					= TRIM(SHCD.SHCITEMCLASSDESCRIPTION)
				,[Item Description]							= TRIM(SHCD.SHCITEMDESCRIPTION)
				,[Item Type]								= cast(TRIM(SHCD.SHCITEMTYPE) as char(1)) 
				,[Financial Division]						= cast(TRIM(SHCD.SHCFINANCIALDIVISION) as char(1))
				,[Financial Division Description]			= TRIM(SHCD.SHCFINANCIALDIVISIONDESC)
				,[Sales Division]							= cast(TRIM(SHCD.SHCSALESDIVISION)  as char(1))
				,[Sales Division Description]				= TRIM(SHCD.SHCSALESDIVISIONDESCRIPTION) 
				,[Freight Sales Class]						= cast(TRIM(SHCD.SHCFREIGHTSALESCLASS) as char(2)) 
				,[Commission Sales Class]					= cast(TRIM(SHCD.SHCCOMMISSIONSALESCLASS) as char(2)) 
				,[Series]									= TRIM(SHCD.SHCSERIES) 
				,[Discount Sales Class]						= cast(TRIM(SHCD.SHCDISCOUNTSALESCLASS) as char(2))  
				,[Manufacturing Status Code]				= cast(TRIM(SHCD.SHCMANUFACTURINGSTATUSCODE) as char(1))
				,[Manufacturing Status Description]			= CASE WHEN Im.ManufacturingStatus='Discontinued' THEN 'Deleted' ELSE ISNULL (SC2.Description,'N/A') END 
				--,[Manufacturing Status Description]			= CASE WHEN Im.acrec='D' THEN 'Deleted' ELSE ISNULL (SC2.Description,'N/A') END 
 
		FROM	[$(Databricks)].costaccounting.[fif244] SHCD
				LEFT OUTER JOIN [$(MasterData_Warehouse)].[MasterData_DW].[DimItemMaster] Im
				ON SHCD.SHCITEMNUMBER = Im.ItemSKU
				LEFT OUTER JOIN [$(MasterData_Warehouse)].ProductKnowledge.[ItemStatusCode] SC2  
				ON SC2.Code = Im.AFIItemStatus
				 )
				 ITEMS
				 
				 
				 