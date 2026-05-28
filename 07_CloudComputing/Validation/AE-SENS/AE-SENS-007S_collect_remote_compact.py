#!/usr/bin/env python3
import csv
import sys
from pathlib import Path

SENS = Path("/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity")
RUN_IDS = [
    "C060_M000_T012", "C060_M000_T018", "C060_M000_T028",
    "C060_M020_T012", "C060_M020_T018", "C060_M020_T028",
    "C060_M030_T012", "C060_M030_T018", "C060_M030_T028",
    "C080_M000_T012",
]

MODE = sys.argv[1]


def read_csv(path):
    if not path.exists() or path.stat().st_size == 0:
        return []
    with path.open(newline="", encoding="utf-8", errors="replace") as f:
        return list(csv.DictReader(f))


def emit(rows):
    fields = []
    for row in rows:
        for key in row:
            if key not in fields:
                fields.append(key)
    writer = csv.DictWriter(sys.stdout, fieldnames=fields, extrasaction="ignore")
    writer.writeheader()
    writer.writerows(rows)


if MODE == "11c":
    rows = []
    include = {
        "index_thresholds_by_crsp_universe.csv",
        "index_performance_by_crsp_universe.csv",
        "index_exclusion_summary_by_crsp_universe.csv",
        "error_cost_decomposition_by_crsp_universe.csv",
        "run_status.csv",
    }
    for run_id in RUN_IDS:
        base = SENS / "index_construction" / run_id
        for name in sorted(include):
            for row in read_csv(base / name):
                rows.append({"run_id": run_id, "source_file": name, **row})
    emit(rows or [{"run_id": "NA", "source_file": "NA", "status": "no_11c_rows"}])
elif MODE == "optional":
    rows = []
    checks = {
        "LightGBM": "LightGBM",
        "CatBoost": "CatBoost",
        "FastAI": "NeuralNetFastAI",
        "XGBoost": "XGBoost",
    }
    for run_id in RUN_IDS:
        model_root = SENS / "raw_models" / run_id
        stderr_path = SENS / "logs" / run_id / "02_raw_autogluon.stderr.log"
        text = stderr_path.read_text(encoding="utf-8", errors="replace") if stderr_path.exists() else ""
        for label, pattern in checks.items():
            rows.append({
                "run_id": run_id,
                "check": label,
                "observed": str(any(model_root.glob(f"**/models/{pattern}/*"))),
            })
        rows.append({
            "run_id": run_id,
            "check": "missing_import_skip",
            "observed": str(any(x in text for x in ["ImportError", "not installed", "Failed to import"])),
        })
    emit(rows)
else:
    raise SystemExit(f"Unknown mode: {MODE}")
