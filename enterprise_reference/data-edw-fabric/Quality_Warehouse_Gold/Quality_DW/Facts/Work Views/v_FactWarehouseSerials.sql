	CREATE VIEW [Quality_DW_Wrk].[v_FactWarehouseSerials] 
as
select    sna.wh_id as Warehouse
,       sna.serial_number as SerialNumber
,       sna.item_number as ItemNumber
,       isNull(sna.serial_no_status,'') as  SerialStatus
,isNull(sna.master_status,'') as  MasterStatus
,CASE WHEN sna.po_number = sna.master_po THEN '' ELSE sna.po_number END as TransferTripNumber
,COALESCE(sna.master_po, '') as [Master MO/PO]
,COALESCE(pom.pomvendornum, CASE WHEN LEN(sna.serial_number) = 9 THEN 'Ashley' ELSE 'Unknown' END) as VendorNumber
,COALESCE(v.VNAME, CASE WHEN LEN(sna.serial_number) = 9 THEN 'ASHLEY FURNITURE IND.' ELSE 'Unknown' END) as VendorName
,sna.location_id as [Location]
,COALESCE(sna.hu_id, '') as LicensePlate
,sna.received_date as ReceivedDate
,COALESCE(sna.trip_number, '') as TripNumber
,'' as ShipDate
,'' as CarbLevel
,'' as RotationSequence
,sna.born_on_date as BornOnDate
,con.conreceipttostock as [POReceiptToStockDate]

FROM
       [$(Databricks)].[distribution_warehouse_wholesale].[t_serial_active] sna 
	   left join [$(Databricks)].[wholesale_productsourcing_afi].[pomaster] pom on pom.pomordernum = sna.master_po 
       left join [$(Source_Data)].[Wholesale_Purchasing_AFI].[VENNAM] v on pom.pomvendornum = v.VNDNR 
       LEFT JOIN [$(Databricks)].[manufacturing_inventory_afi].[taginvd] tg on sna.serial_number =  tg.[TDTAG#]
       LEFT JOIN [$(Databricks)].[wholesale_productsourcing_afi].[container] con ON pom.pomcontainerseq = con.conID

       WHERE sna.item_number <> 'RP ORDER'

