#!/usr/bin/env python3
import csv
import os
import subprocess
from pathlib import Path

ROOT = Path("/root/AgonyAndExcstasy")
SENS = ROOT / "03_Data_Output/3_Modelling_Results/Necessary/sensitivity"
OUT = SENS / "logs/AE-SENS-007_full_grid"

RUN_IDS = [
    "C060_M000_T012", "C060_M000_T018", "C060_M000_T028",
    "C060_M020_T012", "C060_M020_T018", "C060_M020_T028",
    "C060_M030_T012", "C060_M030_T018", "C060_M030_T028",
    "C080_M000_T012", "C080_M000_T018", "C080_M000_T028",
    "C080_M020_T012", "C080_M020_T018", "C080_M020_T028",
    "C080_M030_T012", "C080_M030_T018", "C080_M030_T028",
    "C090_M000_T012", "C090_M000_T018", "C090_M000_T028",
    "C090_M020_T012", "C090_M020_T018", "C090_M020_T028",
    "C090_M030_T012", "C090_M030_T018", "C090_M030_T028",
]


def read_csv(path):
    if not path.exists() or path.stat().st_size == 0:
        return []
    with path.open(newline="", encoding="utf-8", errors="replace") as f:
        return list(csv.DictReader(f))


def write_csv(path, fieldnames, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def file_size(path):
    try:
        return path.stat().st_size
    except FileNotFoundError:
        return None


def copy_file(src, dst):
    if src.exists():
        dst.write_text(src.read_text(encoding="utf-8", errors="replace"), encoding="utf-8")


def collect_label_counts():
    rows = []
    for run_id in RUN_IDS:
        diag = SENS / "labels" / run_id / "label_diagnostics.csv"
        event_diag = SENS / "labels" / run_id / "event_diagnostics.csv"
        vals = read_csv(diag)[0] if read_csv(diag) else {}
        event_vals = {
            f"event_{k}": v
            for k, v in (read_csv(event_diag)[0] if read_csv(event_diag) else {}).items()
            if k != "param_id"
        }
        labels = SENS / "labels" / run_id / "labels_model_ready.rds"
        rows.append({
            "run_id": run_id,
            "label_diagnostics_present": str(diag.exists()),
            "labels_model_ready_size_bytes": file_size(labels) or "NA",
            **vals,
            **event_vals,
        })
    fieldnames = sorted({k for row in rows for k in row.keys()})
    if "run_id" in fieldnames:
        fieldnames.remove("run_id")
    write_csv(OUT / "AE-SENS-007_full_grid_label_counts.csv", ["run_id"] + fieldnames, rows)


def collect_concat(rel, out_name, include_files=None):
    rows = []
    fields = set()
    for run_id in RUN_IDS:
        path = SENS / rel / run_id
        if path.is_dir():
            for file in sorted(path.glob("*.csv")):
                if include_files is not None and file.name not in include_files:
                    continue
                for row in read_csv(file):
                    row = {"run_id": run_id, "source_file": file.name, **row}
                    rows.append(row)
                    fields.update(row.keys())
    fieldnames = ["run_id", "source_file"] + sorted(fields - {"run_id", "source_file"})
    write_csv(OUT / out_name, fieldnames, rows)


def collect_inventory():
    rows = []
    areas = [
        "logs", "labels", "raw_features/by_config", "raw_models",
        "raw_predictions", "evaluation", "index_construction",
    ]
    for run_id in RUN_IDS:
        for area in areas:
            base = SENS / area / run_id
            if not base.exists():
                rows.append({
                    "run_id": run_id,
                    "area": area,
                    "relative_path": str(Path(area) / run_id).replace("\\", "/"),
                    "type": "missing",
                    "size_bytes": "NA",
                })
                continue
            for path in sorted(base.rglob("*")):
                if path.is_file():
                    rows.append({
                        "run_id": run_id,
                        "area": area,
                        "relative_path": str(path.relative_to(SENS)).replace("\\", "/"),
                        "type": "file",
                        "size_bytes": path.stat().st_size,
                    })
    write_csv(
        OUT / "AE-SENS-007_full_grid_output_inventory.csv",
        ["run_id", "area", "relative_path", "type", "size_bytes"],
        rows,
    )


def collect_optional_family_evidence():
    families = {
        "LightGBM": "LightGBM",
        "CatBoost": "CatBoost",
        "FastAI": "NeuralNetFastAI",
        "XGBoost": "XGBoost",
    }
    rows = []
    for run_id in RUN_IDS:
        model_root = SENS / "raw_models" / run_id
        for label, pattern in families.items():
            found = any(model_root.glob(f"**/models/{pattern}/*"))
            rows.append({"run_id": run_id, "check": label, "observed": str(found)})
        stderr = SENS / "logs" / run_id / "02_raw_autogluon.stderr.log"
        text = stderr.read_text(encoding="utf-8", errors="replace") if stderr.exists() else ""
        missing_skip = any(x in text for x in ["ImportError", "not installed", "Failed to import"])
        rows.append({"run_id": run_id, "check": "missing_import_skip", "observed": str(missing_skip)})
    write_csv(OUT / "AE-SENS-007_full_grid_optional_family_evidence.csv",
              ["run_id", "check", "observed"], rows)


def collect_failed_stderr():
    with (OUT / "AE-SENS-007_failed_11c_stderr_tail.txt").open("w", encoding="utf-8") as f:
        for run_id in RUN_IDS:
            path = SENS / "logs" / run_id / "04_raw_11c_index.stderr.log"
            if path.exists():
                lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
                f.write(f"==== {run_id} ====\n")
                f.write("\n".join(lines[-120:]))
                f.write("\n")


def collect_process_guard():
    cmd = "ps -eo pid,ppid,cmd | grep -E 'full_grid_driver|run_ae_sens_raw_one|09C_AutoGluon.py|ae_sens_eval_raw|11C_IndexConstruction_Revised' | grep -v grep || true"
    result = subprocess.run(cmd, shell=True, text=True, capture_output=True)
    (OUT / "AE-SENS-007_remote_process_guard.txt").write_text(result.stdout, encoding="utf-8")


def collect_canonical_check():
    cmd = (
        "find "
        "/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/temporary_csi "
        "/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/permanent_csi "
        "-type f -newermt '2026-05-28 15:04:00 UTC' -printf '%p\t%s\t%TY-%Tm-%TdT%TH:%TM:%TSZ\n' 2>/dev/null || true"
    )
    result = subprocess.run(cmd, shell=True, text=True, capture_output=True)
    (OUT / "AE-SENS-007_canonical_modification_check.txt").write_text(
        result.stdout if result.stdout else "No canonical temporary_csi/permanent_csi files modified after AE-SENS-007 start.\n",
        encoding="utf-8",
    )


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    copy_file(OUT / "full_grid_status.csv", OUT / "AE-SENS-007_full_grid_status.csv")
    copy_file(OUT / "full_grid_step_status.csv", OUT / "AE-SENS-007_full_grid_step_status.csv")
    copy_file(OUT / "full_grid_driver.stdout.log", OUT / "AE-SENS-007_full_grid_driver_stdout.log")
    copy_file(OUT / "full_grid_driver.stderr.log", OUT / "AE-SENS-007_full_grid_driver_stderr.log")
    collect_label_counts()
    collect_concat("evaluation", "AE-SENS-007_full_grid_model_metrics.csv")
    collect_concat("raw_predictions", "AE-SENS-007_full_grid_prediction_row_counts.csv")
    collect_concat(
        "index_construction",
        "AE-SENS-007_full_grid_11c_summary.csv",
        include_files={
            "index_thresholds_by_crsp_universe.csv",
            "index_performance_by_crsp_universe.csv",
            "index_exclusion_summary_by_crsp_universe.csv",
            "error_cost_decomposition_by_crsp_universe.csv",
            "run_status.csv",
        },
    )
    collect_inventory()
    collect_optional_family_evidence()
    collect_failed_stderr()
    collect_process_guard()
    collect_canonical_check()


if __name__ == "__main__":
    main()
