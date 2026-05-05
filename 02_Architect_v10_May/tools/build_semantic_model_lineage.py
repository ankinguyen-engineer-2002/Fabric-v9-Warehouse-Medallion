#!/usr/bin/env python3
"""
build_semantic_model_lineage.py

Discover all semantic models in the v10 workspace, parse their TMDL via Fabric API,
identify which ones consume Gold WH tables (Direct Lake), and populate:
  - Meta.SemanticModelContract (one row per gold_table × semantic_model pair)
  - Meta.LineageEdge (edges with edge_type='semantic')

Idempotent: deletes existing semantic-typed rows in both tables before re-inserting.

Run:
  python build_semantic_model_lineage.py [--dry-run]

Auth: uses `az account get-access-token` (must `az login` first).

References:
  - Plan: 02_Architect_v10_May/30_runbook/18_lineage_extension_to_semantic_models.md
  - ADR-007: docs/decisions/ADR-007-v10-semantic-model-deployment.md
"""
import argparse, base64, json, re, struct, subprocess, sys, time, urllib.error, urllib.request
from datetime import datetime, timezone

# ── Configuration ─────────────────────────────────────────────────────────────
WORKSPACE_ID = "c8d9fc83-18b6-4e1d-8264-0b49eed36fe0"  # DEV
GOLD_WH_ID = "98e2a911-5af9-442e-9cc8-5d8dadb8b762"     # SupplyChain_Gold_Warehouse
PROCESSING_WH_DB = "SupplyChain_Processing_Warehouse"
SQL_SERVER = "7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com"


def az_token(resource: str) -> str:
    return subprocess.check_output(
        ["az", "account", "get-access-token", "--resource", resource, "--query", "accessToken", "-o", "tsv"]
    ).decode().strip()


def fabric_get(path: str, fabric_token: str) -> dict:
    url = f"https://api.fabric.microsoft.com{path}"
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {fabric_token}"})
    return json.loads(urllib.request.urlopen(req).read())


def fabric_post(path: str, fabric_token: str, body: bytes = b"") -> tuple:
    url = f"https://api.fabric.microsoft.com{path}"
    headers = {"Authorization": f"Bearer {fabric_token}"}
    if body:
        headers["Content-Type"] = "application/json"
    else:
        headers["Content-Length"] = "0"
    req = urllib.request.Request(url, data=body if body else None, method="POST", headers=headers)
    resp = urllib.request.urlopen(req)
    return resp.status, resp


def get_tmdl(model_id: str, fabric_token: str) -> dict | None:
    """Long-running operation: POST getDefinition, poll until Succeeded, fetch result."""
    status, resp = fabric_post(
        f"/v1/workspaces/{WORKSPACE_ID}/semanticModels/{model_id}/getDefinition?format=TMDL",
        fabric_token,
    )
    if status != 202:
        return None
    op_id = resp.headers.get("x-ms-operation-id")
    for _ in range(30):
        time.sleep(2)
        d = fabric_get(f"/v1/operations/{op_id}", fabric_token)
        if d.get("status") == "Succeeded":
            return fabric_get(f"/v1/operations/{op_id}/result", fabric_token)
        if d.get("status") == "Failed":
            return None
    return None


def parse_tmdl_partitions(parts: list) -> tuple:
    """Extract: list of (entity, schema, mode) per partition + the DirectLake source URL."""
    partitions = []
    direct_lake_urls = []
    for p in parts:
        path = p.get("path", "")
        payload = p.get("payload", "")
        ptype = p.get("payloadType", "")
        if ptype == "InlineBase64":
            content = base64.b64decode(payload).decode("utf-8", errors="replace")
        else:
            content = payload

        # Extract Direct Lake URLs from expressions.tmdl
        if path.endswith("expressions.tmdl"):
            for m in re.finditer(r'AzureStorage\.DataLake\("([^"]+)"', content):
                direct_lake_urls.append(m.group(1))

        # Extract partitions from table .tmdl files
        if path.endswith(".tmdl") and "/tables/" in path:
            table_match = re.search(r"^table (\S+)", content, re.MULTILINE)
            if not table_match:
                continue
            table_name = table_match.group(1)
            for pm in re.finditer(r"partition\s+\S+\s+=\s+entity\s*\n((?:\s+.+\n)+)", content, re.MULTILINE):
                body = pm.group(1)
                mode_m = re.search(r"mode:\s*(\S+)", body)
                entity_m = re.search(r"entityName:\s*(\S+)", body)
                schema_m = re.search(r"schemaName:\s*(\S+)", body)
                if entity_m:
                    partitions.append({
                        "table": table_name,
                        "entity": entity_m.group(1),
                        "schema": schema_m.group(1) if schema_m else None,
                        "mode": mode_m.group(1) if mode_m else "unknown",
                    })
    return partitions, direct_lake_urls


def now_utc() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")


def discover() -> list:
    """Discover all semantic models in workspace + their Gold WH consumption."""
    fabric_token = az_token("https://api.fabric.microsoft.com")
    models = fabric_get(f"/v1/workspaces/{WORKSPACE_ID}/semanticModels", fabric_token).get("value", [])
    print(f"Found {len(models)} semantic models in workspace")

    discovered = []
    for sm in models:
        sm_id, sm_name = sm["id"], sm["displayName"]
        print(f"\n  Scanning: {sm_name} ({sm_id})")
        tmdl = get_tmdl(sm_id, fabric_token)
        if not tmdl:
            print(f"    ⚠️  Could not fetch TMDL — skipping")
            continue
        parts = tmdl.get("definition", {}).get("parts", [])
        partitions, urls = parse_tmdl_partitions(parts)
        is_gold_consumer = any(GOLD_WH_ID in u for u in urls)
        if not is_gold_consumer:
            print(f"    Skipping — not a Gold WH consumer (URLs: {urls})")
            continue
        for p in partitions:
            discovered.append({**p, "model_id": sm_id, "model_name": sm_name})
            print(f"    + {p['schema']}.{p['entity']} (mode={p['mode']})")
    return discovered


def write_to_meta(discovered: list, dry_run: bool):
    """UPSERT to Meta.SemanticModelContract + Meta.LineageEdge (replace edge_type='semantic')."""
    if not discovered:
        print("\n  Nothing to write.")
        return

    import pyodbc
    sql_token = az_token("https://database.windows.net/")
    tb = bytes(sql_token, "UTF-8")
    ex = b"".join(bytes({i}) + bytes(1) for i in tb)
    ts = struct.pack("=i", len(ex)) + ex

    conn = pyodbc.connect(
        f"DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={SQL_SERVER};DATABASE={PROCESSING_WH_DB};"
        "Encrypt=yes;TrustServerCertificate=no",
        attrs_before={1256: ts},
    )
    conn.autocommit = True
    cur = conn.cursor()

    print(f"\n  Writing {len(discovered)} discovered (gold_table × semantic_model) pairs...")
    if dry_run:
        for d in discovered:
            print(f"    [DRY] {d['schema']}.{d['entity']} ↔ {d['model_name']} ({d['mode']})")
        return

    # Step 1: Replace existing semantic edges
    cur.execute("DELETE FROM Meta.LineageEdge WHERE edge_type='semantic'")
    print(f"    Deleted prior semantic edges from Meta.LineageEdge")

    # Step 2: Insert new edges + contracts
    now = now_utc()
    edge_inserts = 0
    contract_inserts = 0
    for d in discovered:
        gold_asset = f"{d['schema']}.{d['entity']}"
        sm_target = f"SemanticModel.{d['model_name']}"
        edge_id = f"semantic::{d['model_name']}::{d['entity']}"
        contract_id = f"semantic::{d['model_name']}::{d['entity']}"

        # LineageEdge insert
        cur.execute(
            "INSERT INTO Meta.LineageEdge (edge_id, source_asset, target_asset, edge_type, transform_type, is_synthetic, created_at_utc, notes) "
            "VALUES (?, ?, ?, 'semantic', ?, 0, SYSUTCDATETIME(), ?)",
            edge_id, gold_asset, sm_target, d["mode"],
            f"Auto-discovered via Fabric API getDefinition — model_id={d['model_id']}",
        )
        edge_inserts += 1

        # SemanticModelContract upsert (delete then insert)
        cur.execute("DELETE FROM Meta.SemanticModelContract WHERE contract_id=?", contract_id)
        cur.execute(
            "INSERT INTO Meta.SemanticModelContract "
            "(contract_id, gold_asset_id, semantic_model_name, source_mode, direct_lake_required, fallback_allowed, validation_status, last_validated_utc, notes) "
            "VALUES (?, ?, ?, ?, ?, 0, 'discovered', SYSUTCDATETIME(), ?)",
            contract_id, gold_asset, d["model_name"], d["mode"], 1 if d["mode"] == "directLake" else 0,
            f"Auto-discovered via Fabric API — model_id={d['model_id']}",
        )
        contract_inserts += 1

    print(f"    ✅ Inserted {edge_inserts} edges into Meta.LineageEdge")
    print(f"    ✅ Upserted {contract_inserts} contracts into Meta.SemanticModelContract")

    # Verify
    cur.execute("SELECT COUNT(*) FROM Meta.LineageEdge WHERE edge_type='semantic'")
    print(f"\n    Meta.LineageEdge edge_type='semantic' count: {cur.fetchone()[0]}")
    cur.execute("SELECT COUNT(*) FROM Meta.SemanticModelContract WHERE validation_status='discovered'")
    print(f"    Meta.SemanticModelContract validation_status='discovered' count: {cur.fetchone()[0]}")

    cur.close()
    conn.close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="Discover only, no DB writes")
    args = parser.parse_args()

    print("=" * 70)
    print("Build Semantic Model Lineage — v10 Workspace")
    print("=" * 70)
    discovered = discover()
    write_to_meta(discovered, dry_run=args.dry_run)
    print("\n  Done." + (" (DRY RUN — no writes)" if args.dry_run else ""))


if __name__ == "__main__":
    main()
