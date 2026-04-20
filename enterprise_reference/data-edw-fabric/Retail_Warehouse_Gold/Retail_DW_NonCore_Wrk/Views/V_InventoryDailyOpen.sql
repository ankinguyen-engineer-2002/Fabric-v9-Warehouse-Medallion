CREATE VIEW [Retail_DW_NonCore_Wrk].[V_InventoryDailyOpen]
AS
	SELECT	dm.FiscalDate AS TransDate,
			pm.ProductKey,
			ido.SerialNbrID,
			ido.LocationID,
			ido.StoreBrandID,
			ido.StorageID,
			ido.MaterialCost,
			ido.LandedFreight,
			ido.Addon1Cost,
			ido.Addon2Cost,
			ido.Addon3Cost,
			ido.Addon4Cost,
			ido.TotalCost,
			ido.Qty,
			ido.QtyCommitted,
			ido.QtySoftCommitted,
			ido.DateAsIs,
			ido.AsIsReasonCodeID,
			ido.InvSubBucketID,
			ido.PieceStatusID,
			ido.TransDateKey,
			ido.InvBucketID,
			pm.SKU AS ProductID, 
			ido.DateInStorageID, 
			ido.DateInReasonCodeID
		FROM	[Retail_DW_NonCore].[FactInventoryDailyOpen] AS ido 
			INNER JOIN [Retail_DW_Core].[DimProductMaster] AS pm  ON pm.SKU = ido.ProductID
			INNER JOIN [Retail_DW_Core].[DimGroupMaster] AS gm  ON gm.GroupID = pm.GroupID
			INNER JOIN [Retail_DW_Core].[DimDate] AS dm  ON dm.DateKey = ido.TransDateKey
			---INNER JOIN tdsg.InventorySubBuckets AS isb ON isb.InvSubBucketID = ido.InvSubBucketID
		WHERE	pm.IsMaster = 1;