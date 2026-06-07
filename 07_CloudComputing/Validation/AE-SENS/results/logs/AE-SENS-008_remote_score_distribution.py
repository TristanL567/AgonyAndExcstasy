#!/usr/bin/env python3
from pathlib import Path

import pandas as pd

BASE = Path("/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity")
OUT = BASE / "logs" / "AE-SENS-008_prediction_distribution_summary.csv"

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

FILES = {
    "test": "ag_preds_test_eval.parquet",
    "oos": "ag_preds_oos_eval.parquet",
    "train_boundary": "ag_preds_train_boundary.parquet",
    "cv": "ag_cv_results.parquet",
}


def score_column(df: pd.DataFrame) -> str | None:
    candidates = [
        "pred_score",
        "score",
        "prediction_score",
        "y_score",
        "p1",
        "proba_1",
        "CSI_probability",
        "pred_proba",
    ]
    for col in candidates:
        if col in df.columns and pd.api.types.is_numeric_dtype(df[col]):
            return col
    numeric_cols = [
        col
        for col in df.columns
        if pd.api.types.is_numeric_dtype(df[col]) and col.lower() not in {"y", "label", "permno", "year"}
    ]
    return numeric_cols[-1] if numeric_cols else None


rows = []
for run_id in RUN_IDS:
    run_dir = BASE / "raw_predictions" / run_id
    for split, name in FILES.items():
        path = run_dir / name
        row = {
            "run_id": run_id,
            "split": split,
            "file": f"raw_predictions/{run_id}/{name}",
            "status": "missing",
            "score_column": "",
            "rows": "",
            "mean": "",
            "sd": "",
            "min": "",
            "p01": "",
            "p05": "",
            "p10": "",
            "p25": "",
            "p50": "",
            "p75": "",
            "p90": "",
            "p95": "",
            "p99": "",
            "max": "",
        }
        if path.exists():
            df = pd.read_parquet(path)
            col = score_column(df)
            if col is None:
                row["status"] = "no_numeric_score_column"
            else:
                s = pd.to_numeric(df[col], errors="coerce").dropna()
                row.update({
                    "status": "ok",
                    "score_column": col,
                    "rows": int(s.shape[0]),
                    "mean": float(s.mean()),
                    "sd": float(s.std(ddof=0)),
                    "min": float(s.min()),
                    "p01": float(s.quantile(0.01)),
                    "p05": float(s.quantile(0.05)),
                    "p10": float(s.quantile(0.10)),
                    "p25": float(s.quantile(0.25)),
                    "p50": float(s.quantile(0.50)),
                    "p75": float(s.quantile(0.75)),
                    "p90": float(s.quantile(0.90)),
                    "p95": float(s.quantile(0.95)),
                    "p99": float(s.quantile(0.99)),
                    "max": float(s.max()),
                })
        rows.append(row)

OUT.parent.mkdir(parents=True, exist_ok=True)
pd.DataFrame(rows).to_csv(OUT, index=False)
print(f"WROTE {OUT} ROWS={len(rows)}")
