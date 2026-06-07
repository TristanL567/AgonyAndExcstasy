#!/usr/bin/env python3
"""AE-SENS-007S remote storage-retention utility.

This script is intended to run on the Vast.ai instance. It only touches the
AE-SENS sensitivity output root and prunes heavy raw AutoGluon model folders
after retained prediction, metric, metadata, and 11C evidence is verified.
"""

from __future__ import annotations

import csv
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
from sklearn.metrics import (
    average_precision_score,
    brier_score_loss,
    roc_auc_score,
    roc_curve,
)


SENS_ROOT = Path(
    "/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity"
)
EVIDENCE_DIR = SENS_ROOT / "logs" / "AE-SENS-007S_storage_retention"

GRID_RUN_IDS = [
    "C060_M000_T012",
    "C060_M000_T018",
    "C060_M000_T028",
    "C060_M020_T012",
    "C060_M020_T018",
    "C060_M020_T028",
    "C060_M030_T012",
    "C060_M030_T018",
    "C060_M030_T028",
    "C080_M000_T012",
    "C080_M000_T018",
    "C080_M000_T028",
    "C080_M020_T012",
    "C080_M020_T018",
    "C080_M020_T028",
    "C080_M030_T012",
    "C080_M030_T018",
    "C080_M030_T028",
    "C090_M000_T012",
    "C090_M000_T018",
    "C090_M000_T028",
    "C090_M020_T012",
    "C090_M020_T018",
    "C090_M020_T028",
    "C090_M030_T012",
    "C090_M030_T018",
    "C090_M030_T028",
]

PREDICTION_FILES = [
    "ag_eval_summary.json",
    "ag_leaderboard.csv",
    "ag_cv_results.parquet",
    "ag_preds_test.parquet",
    "ag_preds_test_eval.parquet",
    "ag_preds_oos.parquet",
    "ag_preds_oos_eval.parquet",
]

EVALUATION_FILES = [
    "raw_model_metrics.csv",
    "raw_prediction_row_counts.csv",
]

INDEX_REQUIREMENTS = {
    "index_thresholds_by_crsp_universe": [".rds", ".csv"],
    "index_weights_by_crsp_universe": [".rds"],
    "index_returns_by_crsp_universe": [".rds"],
    "index_performance_by_crsp_universe": [".rds", ".csv"],
    "index_exclusion_summary_by_crsp_universe": [".rds", ".csv"],
    "error_cost_decomposition_by_crsp_universe": [".rds", ".csv"],
    "run_status": [".csv"],
}

OPTIONAL_FAMILIES = {
    "LightGBM": ["LightGBM", "LightGBMXT", "LightGBMLarge"],
    "CatBoost": ["CatBoost"],
    "XGBoost": ["XGBoost"],
    "FastAI": ["NeuralNetFastAI"],
}


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def in_scope(path: Path) -> bool:
    try:
        path.resolve().relative_to(SENS_ROOT.resolve())
        return True
    except ValueError:
        return False


def file_size(path: Path) -> int:
    return path.stat().st_size if path.exists() and path.is_file() else 0


def dir_size(path: Path) -> int:
    if not path.exists():
        return 0
    total = 0
    for child in path.rglob("*"):
        if child.is_file():
            total += child.stat().st_size
    return total


def list_files(path: Path) -> list[Path]:
    if not path.exists():
        return []
    if path.is_file():
        return [path]
    return [p for p in path.rglob("*") if p.is_file()]


def rel(path: Path) -> str:
    return str(path.relative_to(SENS_ROOT))


def recall_at_fpr(y_true, y_score, threshold: float) -> float | None:
    fpr, tpr, _ = roc_curve(y_true, y_score)
    valid = tpr[fpr <= threshold]
    if len(valid) == 0:
        return None
    return float(valid.max())


def compute_metrics(run_id: str, pred_dir: Path) -> list[dict[str, object]]:
    specs = [
        ("cv", pred_dir / "ag_cv_results.parquet"),
        ("test", pred_dir / "ag_preds_test_eval.parquet"),
        ("oos", pred_dir / "ag_preds_oos_eval.parquet"),
    ]
    rows: list[dict[str, object]] = []
    for split, path in specs:
        if not path.exists():
            rows.append(
                {
                    "run_id": run_id,
                    "split": split,
                    "status": "missing",
                    "path": rel(path),
                }
            )
            continue
        df = pd.read_parquet(path)
        df = df[["y", "p_csi"]].dropna()
        y = df["y"].astype(int)
        score = df["p_csi"].astype(float)
        n_pos = int(y.sum())
        n_obs = int(len(y))
        n_neg = n_obs - n_pos
        row: dict[str, object] = {
            "run_id": run_id,
            "split": split,
            "status": "ok" if n_pos > 0 and n_neg > 0 else "single_class",
            "path": rel(path),
            "n_obs": n_obs,
            "n_pos": n_pos,
            "n_neg": n_neg,
            "prevalence": float(n_pos / n_obs) if n_obs else None,
        }
        if n_pos > 0 and n_neg > 0:
            row.update(
                {
                    "auc": float(roc_auc_score(y, score)),
                    "ap": float(average_precision_score(y, score)),
                    "recall_fpr_1pct": recall_at_fpr(y, score, 0.01),
                    "recall_fpr_3pct": recall_at_fpr(y, score, 0.03),
                    "recall_fpr_5pct": recall_at_fpr(y, score, 0.05),
                    "brier": float(brier_score_loss(y, score)),
                }
            )
        rows.append(row)
    return rows


def read_json(path: Path) -> dict[str, object]:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:  # pragma: no cover - evidence capture path
        return {"read_error": str(exc)}


def read_leaderboard(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open(newline="", encoding="utf-8") as fh:
        return list(csv.DictReader(fh))


def optional_family_rows(run_id: str, leaderboard: list[dict[str, str]]) -> list[dict[str, object]]:
    models = [row.get("model", "") for row in leaderboard]
    rows: list[dict[str, object]] = []
    for family, aliases in OPTIONAL_FAMILIES.items():
        matched = [model for model in models if any(alias in model for alias in aliases)]
        rows.append(
            {
                "run_id": run_id,
                "family": family,
                "available": bool(matched),
                "matching_models": ";".join(matched),
            }
        )
    return rows


def write_json(path: Path, data: dict[str, object]) -> None:
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    with path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    if not SENS_ROOT.exists():
        raise SystemExit(f"Sensitivity root missing: {SENS_ROOT}")
    EVIDENCE_DIR.mkdir(parents=True, exist_ok=True)

    storage_rows: list[dict[str, object]] = []
    retained_rows: list[dict[str, object]] = []
    deleted_rows: list[dict[str, object]] = []
    metric_rows: list[dict[str, object]] = []
    coverage_rows: list[dict[str, object]] = []
    index_rows: list[dict[str, object]] = []

    run_ids = GRID_RUN_IDS

    for run_id in run_ids:
        pred_dir = SENS_ROOT / "raw_predictions" / run_id
        eval_dir = SENS_ROOT / "evaluation" / run_id
        index_dir = SENS_ROOT / "index_construction" / run_id
        model_dir = SENS_ROOT / "raw_models" / run_id

        if not all(in_scope(p) for p in [pred_dir, eval_dir, index_dir, model_dir]):
            raise SystemExit(f"Out-of-scope path derived for {run_id}")

        before_bytes = (
            dir_size(pred_dir) + dir_size(eval_dir) + dir_size(index_dir) + dir_size(model_dir)
        )

        if not pred_dir.exists():
            coverage_rows.append(
                {
                    "run_id": run_id,
                    "prediction_files_ok": False,
                    "evaluation_files_ok": False,
                    "metric_coverage_ok": False,
                    "optional_families_ok": False,
                    "raw_model_metadata_compact": "",
                    "hyperparameters_compact": "",
                    "optional_family_evidence": "",
                    "metric_coverage_file": "",
                }
            )
            storage_rows.append(
                {
                    "run_id": run_id,
                    "bytes_before": before_bytes,
                    "bytes_after": before_bytes,
                    "bytes_deleted": 0,
                    "raw_model_deleted": False,
                    "prediction_files_ok": False,
                    "evaluation_files_ok": False,
                    "metric_coverage_ok": False,
                    "index_coverage_ok": False,
                    "note": "not_started_or_no_predictions",
                }
            )
            continue

        prediction_ok = all((pred_dir / name).is_file() for name in PREDICTION_FILES)
        evaluation_ok = all((eval_dir / name).is_file() for name in EVALUATION_FILES)

        metric_compact_rows = compute_metrics(run_id, pred_dir)
        metric_path = pred_dir / "ag_metric_coverage_compact.csv"
        metric_fields = [
            "run_id",
            "split",
            "status",
            "path",
            "n_obs",
            "n_pos",
            "n_neg",
            "prevalence",
            "auc",
            "ap",
            "recall_fpr_1pct",
            "recall_fpr_3pct",
            "recall_fpr_5pct",
            "brier",
        ]
        write_csv(metric_path, metric_compact_rows, metric_fields)
        metric_rows.extend(metric_compact_rows)

        leaderboard = read_leaderboard(pred_dir / "ag_leaderboard.csv")
        summary = read_json(pred_dir / "ag_eval_summary.json")
        metadata = read_json(model_dir / "ag_predictor" / "metadata.json")
        model_names = [row.get("model", "") for row in leaderboard if row.get("model")]
        best_model = model_names[0] if model_names else None
        family_rows = optional_family_rows(run_id, leaderboard)

        optional_path = pred_dir / "ag_optional_family_evidence.csv"
        write_csv(
            optional_path,
            family_rows,
            ["run_id", "family", "available", "matching_models"],
        )

        model_metadata = {
            "run_id": run_id,
            "created_at_utc": utc_now(),
            "best_model": best_model,
            "model_names": model_names,
            "leaderboard_path": rel(pred_dir / "ag_leaderboard.csv"),
            "metric_coverage_path": rel(metric_path),
            "autogluon_version": metadata.get("version") or summary.get("autogluon_version"),
            "python_version": metadata.get("py_version"),
            "package_versions": metadata.get("packages", {}),
            "optional_family_availability": family_rows,
            "source_metadata_path": rel(model_dir / "ag_predictor" / "metadata.json")
            if (model_dir / "ag_predictor" / "metadata.json").exists()
            else None,
        }
        write_json(pred_dir / "ag_model_metadata_compact.json", model_metadata)

        hyperparameters = {
            "run_id": run_id,
            "created_at_utc": utc_now(),
            "status": "compact_best_model_metadata_only",
            "note": "Detailed per-model hyperparameters were not reliably exposed as a compact JSON artifact without loading full heavy predictor state. Leaderboard, model names, package versions, and retained prediction metrics are preserved.",
            "best_model": best_model,
            "model_names": model_names,
            "leaderboard_rows": leaderboard,
        }
        write_json(pred_dir / "ag_hyperparameters_compact.json", hyperparameters)

        required_metric_splits = {"cv", "test", "oos"}
        metric_ok = {
            row["split"]
            for row in metric_compact_rows
            if row.get("status") == "ok"
            and all(
                row.get(col) is not None
                for col in [
                    "auc",
                    "ap",
                    "recall_fpr_1pct",
                    "recall_fpr_3pct",
                    "recall_fpr_5pct",
                    "brier",
                ]
            )
        }
        metric_coverage_ok = required_metric_splits.issubset(metric_ok)

        idx_ok = True
        for family, suffixes in INDEX_REQUIREMENTS.items():
            for suffix in suffixes:
                path = index_dir / f"{family}{suffix}"
                exists = path.is_file() and path.stat().st_size > 0
                idx_ok = idx_ok and exists
                index_rows.append(
                    {
                        "run_id": run_id,
                        "file_family": family,
                        "suffix": suffix,
                        "path": rel(path),
                        "exists": exists,
                        "size_bytes": file_size(path),
                    }
                )

        coverage_rows.append(
            {
                "run_id": run_id,
                "prediction_files_ok": prediction_ok,
                "evaluation_files_ok": evaluation_ok,
                "metric_coverage_ok": metric_coverage_ok,
                "optional_families_ok": all(row["available"] for row in family_rows),
                "raw_model_metadata_compact": rel(pred_dir / "ag_model_metadata_compact.json"),
                "hyperparameters_compact": rel(pred_dir / "ag_hyperparameters_compact.json"),
                "optional_family_evidence": rel(optional_path),
                "metric_coverage_file": rel(metric_path),
            }
        )

        delete_model_dir = prediction_ok and evaluation_ok and metric_coverage_ok and idx_ok
        raw_model_size = dir_size(model_dir)
        if delete_model_dir and model_dir.exists():
            shutil.rmtree(model_dir)
            deleted_rows.append(
                {
                    "run_id": run_id,
                    "deleted_path": rel(model_dir),
                    "size_bytes": raw_model_size,
                    "reason": "heavy_raw_autogluon_predictor_pruned_after_compact_evidence",
                }
            )
        else:
            deleted_rows.append(
                {
                    "run_id": run_id,
                    "deleted_path": rel(model_dir),
                    "size_bytes": 0,
                    "reason": "not_deleted_retained_coverage_incomplete",
                }
            )

        for f in list_files(pred_dir) + list_files(eval_dir) + list_files(index_dir):
            retained_rows.append(
                {
                    "run_id": run_id,
                    "path": rel(f),
                    "size_bytes": file_size(f),
                    "category": f.relative_to(SENS_ROOT).parts[0],
                }
            )

        after_bytes = dir_size(pred_dir) + dir_size(eval_dir) + dir_size(index_dir) + dir_size(model_dir)
        storage_rows.append(
            {
                "run_id": run_id,
                "bytes_before": before_bytes,
                "bytes_after": after_bytes,
                "bytes_deleted": before_bytes - after_bytes,
                "raw_model_deleted": delete_model_dir and raw_model_size > 0,
                "prediction_files_ok": prediction_ok,
                "evaluation_files_ok": evaluation_ok,
                "metric_coverage_ok": metric_coverage_ok,
                "index_coverage_ok": idx_ok,
                "note": "completed_run_pruned" if delete_model_dir else "not_pruned",
            }
        )

    write_csv(
        EVIDENCE_DIR / "AE-SENS-007S_storage_retention_report.csv",
        storage_rows,
        [
            "run_id",
            "bytes_before",
            "bytes_after",
            "bytes_deleted",
            "raw_model_deleted",
            "prediction_files_ok",
            "evaluation_files_ok",
            "metric_coverage_ok",
            "index_coverage_ok",
            "note",
        ],
    )
    write_csv(
        EVIDENCE_DIR / "AE-SENS-007S_retained_file_inventory.csv",
        retained_rows,
        ["run_id", "path", "size_bytes", "category"],
    )
    write_csv(
        EVIDENCE_DIR / "AE-SENS-007S_deleted_file_inventory.csv",
        deleted_rows,
        ["run_id", "deleted_path", "size_bytes", "reason"],
    )
    write_csv(
        EVIDENCE_DIR / "AE-SENS-007S_metric_coverage_check.csv",
        metric_rows,
        [
            "run_id",
            "split",
            "status",
            "path",
            "n_obs",
            "n_pos",
            "n_neg",
            "prevalence",
            "auc",
            "ap",
            "recall_fpr_1pct",
            "recall_fpr_3pct",
            "recall_fpr_5pct",
            "brier",
        ],
    )
    write_csv(
        EVIDENCE_DIR / "AE-SENS-007S_metric_artifact_coverage.csv",
        coverage_rows,
        [
            "run_id",
            "prediction_files_ok",
            "evaluation_files_ok",
            "metric_coverage_ok",
            "optional_families_ok",
            "raw_model_metadata_compact",
            "hyperparameters_compact",
            "optional_family_evidence",
            "metric_coverage_file",
        ],
    )
    write_csv(
        EVIDENCE_DIR / "AE-SENS-007S_11c_coverage_check.csv",
        index_rows,
        ["run_id", "file_family", "suffix", "path", "exists", "size_bytes"],
    )

    print(f"EVIDENCE_DIR={EVIDENCE_DIR}")
    print(f"RUNS_PROCESSED={len(run_ids)}")
    print(f"BYTES_DELETED={sum(int(row['bytes_deleted']) for row in storage_rows)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
