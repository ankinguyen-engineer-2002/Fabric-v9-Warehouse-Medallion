-- =============================================================================
-- 05_usp_BuildLineage_guard.sql
-- Purpose: Modify Meta.usp_BuildLineage to preserve edges with edge_type='semantic'
--          (managed by tools/build_semantic_model_lineage.py)
-- Target:  Meta.usp_BuildLineage in SupplyChain_Processing_Warehouse
--
-- Status:  APPLIED 2026-05-05 (sc_forecast_control_tower branch).
-- Risk:    LOW — only changes DELETE filter; INSERT logic unchanged.
-- =============================================================================

CREATE OR ALTER PROCEDURE Meta.usp_BuildLineage
AS
BEGIN
    -- ───────────────────────────────────────────────────────────────────────
    -- Preserve edges with edge_type='semantic' (Gold → SemanticModel mappings)
    -- These are managed by tools/build_semantic_model_lineage.py
    -- ───────────────────────────────────────────────────────────────────────
    DELETE FROM Meta.LineageEdge WHERE edge_type IN ('direct','derived');

    INSERT INTO Meta.LineageEdge (edge_id, source_asset, target_asset, edge_type, transform_type, is_synthetic, created_at_utc)
    SELECT
        CONCAT('lineage::', ROW_NUMBER() OVER (ORDER BY r.asset_id, src.value)),
        TRIM(REPLACE(REPLACE(REPLACE(src.value, '"', ''), '''', ''), ' ', '')),
        r.asset_id,
        'direct',
        r.load_type,
        0,
        SYSUTCDATETIME()
    FROM Meta.AssetRegistry r
    CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(r.source_objects, '[', ''), ']', ''), ',') src
    WHERE r.source_objects IS NOT NULL AND LEN(TRIM(src.value)) > 0;
END
