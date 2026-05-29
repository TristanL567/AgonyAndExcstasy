from __future__ import annotations

import csv
import json
import math
from pathlib import Path
from statistics import mean


ROOT = Path(__file__).resolve().parents[1]
COMPARISONS = ROOT / "comparisons"
COMPARISONS.mkdir(parents=True, exist_ok=True)

RUN_IDS = [
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


def parse_run_id(run_id: str) -> dict[str, object]:
    c_part, m_part, t_part = run_id.split("_")
    c = -int(c_part[1:]) / 100
    m = -int(m_part[1:]) / 100
    t = int(t_part[1:])
    return {"run_id": run_id, "C": f"{c:.2f}", "M": f"{m:.2f}", "T": str(t)}


def read_csv(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open(newline="", encoding="utf-8") as fh:
        return list(csv.DictReader(fh))


def write_csv(path: Path, rows: list[dict[str, object]], fields: list[str]) -> None:
    with path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow({field: row.get(field, "") for field in fields})


def fnum(value: object) -> float | None:
    if value is None:
        return None
    text = str(value).strip()
    if not text or text.upper() == "NA":
        return None
    try:
        out = float(text)
    except ValueError:
        return None
    if math.isnan(out):
        return None
    return out


def ffmt(value: float | None, digits: int = 10) -> str:
    if value is None or math.isnan(value):
        return ""
    return f"{value:.{digits}g}"


def add_desc_ranks(rows: list[dict[str, object]], group_key: str, value_key: str, rank_key: str) -> None:
    for group in sorted({str(row.get(group_key, "")) for row in rows}):
        group_rows = [row for row in rows if str(row.get(group_key, "")) == group and fnum(row.get(value_key)) is not None]
        group_rows.sort(key=lambda row: fnum(row.get(value_key)) or -math.inf, reverse=True)
        for idx, row in enumerate(group_rows, 1):
            row[rank_key] = idx


def add_asc_ranks(rows: list[dict[str, object]], group_key: str, value_key: str, rank_key: str) -> None:
    for group in sorted({str(row.get(group_key, "")) for row in rows}):
        group_rows = [row for row in rows if str(row.get(group_key, "")) == group and fnum(row.get(value_key)) is not None]
        group_rows.sort(key=lambda row: fnum(row.get(value_key)) or math.inf)
        for idx, row in enumerate(group_rows, 1):
            row[rank_key] = idx


status_rows = read_csv(ROOT / "manifests" / "full_grid_status.csv")
status_by_run = {row["run_id"]: row for row in status_rows}
failed_by_run = {row.get("run_id", ""): row for row in read_csv(ROOT / "manifests" / "failed_runs.csv")}

run_meta = {}
for run_id in RUN_IDS:
    meta = parse_run_id(run_id)
    status = status_by_run.get(run_id, {})
    meta["run_status"] = status.get("status", "missing")
    meta["run_note"] = status.get("note") or failed_by_run.get(run_id, {}).get("failure_reason", "")
    run_meta[run_id] = meta


label_rows: list[dict[str, object]] = []
for run_id in RUN_IDS:
    rows = read_csv(ROOT / "labels" / run_id / "label_diagnostics.csv")
    if rows:
        row = rows[0]
        n_labelled = fnum(row.get("n_labelled"))
        n_csi = fnum(row.get("n_csi"))
        n_clean = fnum(row.get("n_clean"))
        n_na = fnum(row.get("n_na"))
        prevalence = n_csi / n_labelled if n_csi is not None and n_labelled else None
        out = {
            **run_meta[run_id],
            "observable_rows": row.get("n_rows", ""),
            "y_0": row.get("n_clean", ""),
            "y_1": row.get("n_csi", ""),
            "y_NA": row.get("n_na", ""),
            "labelled_rows": row.get("n_labelled", ""),
            "prevalence": ffmt(prevalence, 8),
        }
    else:
        out = {
            **run_meta[run_id],
            "observable_rows": "",
            "y_0": "",
            "y_1": "",
            "y_NA": "",
            "labelled_rows": "",
            "prevalence": "",
        }
    label_rows.append(out)

baseline_label = next((row for row in label_rows if row["run_id"] == "C080_M020_T018"), {})
baseline_y1 = fnum(baseline_label.get("y_1"))
baseline_prev = fnum(baseline_label.get("prevalence"))
for row in label_rows:
    y1 = fnum(row.get("y_1"))
    prev = fnum(row.get("prevalence"))
    row["delta_y_1_vs_baseline"] = "" if y1 is None or baseline_y1 is None else int(y1 - baseline_y1)
    row["delta_prevalence_vs_baseline"] = ffmt(None if prev is None or baseline_prev is None else prev - baseline_prev, 8)
label_rows.sort(key=lambda row: (fnum(row.get("prevalence")) is None, -(fnum(row.get("prevalence")) or -1), row["run_id"]))
write_csv(
    COMPARISONS / "full_grid_label_count_ranking.csv",
    label_rows,
    [
        "run_id",
        "C",
        "M",
        "T",
        "run_status",
        "observable_rows",
        "y_0",
        "y_1",
        "y_NA",
        "labelled_rows",
        "prevalence",
        "delta_y_1_vs_baseline",
        "delta_prevalence_vs_baseline",
        "run_note",
    ],
)


metric_rows: list[dict[str, object]] = []
for run_id in RUN_IDS:
    rows = read_csv(ROOT / "predictions" / run_id / "ag_metric_coverage_compact.csv")
    if not rows:
        metric_rows.append({**run_meta[run_id], "split": "", "metric_status": "missing"})
        continue
    for row in rows:
        metric_rows.append(
            {
                **run_meta[run_id],
                "split": row.get("split", ""),
                "metric_status": row.get("status", ""),
                "n_obs": row.get("n_obs", ""),
                "n_pos": row.get("n_pos", ""),
                "prevalence": row.get("prevalence", ""),
                "auc": row.get("auc", ""),
                "ap": row.get("ap", ""),
                "recall_fpr_1pct": row.get("recall_fpr_1pct", ""),
                "recall_fpr_3pct": row.get("recall_fpr_3pct", ""),
                "recall_fpr_5pct": row.get("recall_fpr_5pct", ""),
                "brier": row.get("brier", ""),
            }
        )
for key in ("ap", "auc", "recall_fpr_1pct", "recall_fpr_3pct", "recall_fpr_5pct"):
    add_desc_ranks(metric_rows, "split", key, f"rank_{key}_desc")
add_asc_ranks(metric_rows, "split", "brier", "rank_brier_asc")
metric_rows.sort(key=lambda row: (row.get("split", ""), fnum(row.get("rank_ap_desc")) or 999, row["run_id"]))
write_csv(
    COMPARISONS / "full_grid_model_metric_ranking.csv",
    metric_rows,
    [
        "run_id",
        "C",
        "M",
        "T",
        "run_status",
        "split",
        "metric_status",
        "n_obs",
        "n_pos",
        "prevalence",
        "auc",
        "ap",
        "recall_fpr_1pct",
        "recall_fpr_3pct",
        "recall_fpr_5pct",
        "brier",
        "rank_ap_desc",
        "rank_auc_desc",
        "rank_recall_fpr_1pct_desc",
        "rank_recall_fpr_3pct_desc",
        "rank_recall_fpr_5pct_desc",
        "rank_brier_asc",
        "run_note",
    ],
)


dist_rows: list[dict[str, object]] = []
for row in read_csv(ROOT / "predictions" / "prediction_distribution_summary.csv"):
    run_id = row.get("run_id", "")
    dist_rows.append({**run_meta.get(run_id, parse_run_id(run_id)), **row})
write_csv(
    COMPARISONS / "full_grid_prediction_distribution_summary.csv",
    dist_rows,
    [
        "run_id",
        "C",
        "M",
        "T",
        "run_status",
        "split",
        "file",
        "status",
        "score_column",
        "rows",
        "mean",
        "sd",
        "min",
        "p01",
        "p05",
        "p10",
        "p25",
        "p50",
        "p75",
        "p90",
        "p95",
        "p99",
        "max",
    ],
)


index_rows: list[dict[str, object]] = []
threshold_summary_rows: list[dict[str, object]] = []
error_rows: list[dict[str, object]] = []
for run_id in RUN_IDS:
    perf = read_csv(ROOT / "index_construction" / run_id / "index_performance_by_crsp_universe.csv")
    raw_full = [row for row in perf if row.get("model_key") == "raw" and row.get("period") == "full"]
    if raw_full:
        def best(rows: list[dict[str, str]], index_id: str | None = None) -> dict[str, str] | None:
            candidates = [row for row in rows if index_id is None or row.get("index_id") == index_id]
            candidates = [row for row in candidates if fnum(row.get("difference_versus_benchmark")) is not None]
            if not candidates:
                return None
            return max(candidates, key=lambda row: fnum(row.get("difference_versus_benchmark")) or -math.inf)

        best_any = best(raw_full)
        best_large = best(raw_full, "large_cap")
        best_total = best(raw_full, "total_market")
        diffs = [fnum(row.get("difference_versus_benchmark")) for row in raw_full]
        diffs = [val for val in diffs if val is not None]
        row_out = {
            **run_meta[run_id],
            "n_full_raw_strategies": len(raw_full),
            "n_positive_full_strategies": sum(1 for val in diffs if val > 0),
            "mean_full_difference_vs_benchmark": ffmt(mean(diffs) if diffs else None, 10),
            "best_any_index_id": (best_any or {}).get("index_id", ""),
            "best_any_strategy_id": (best_any or {}).get("strategy_id", ""),
            "best_any_threshold_method": (best_any or {}).get("threshold_method", ""),
            "best_any_lockout_years": (best_any or {}).get("lockout_years", ""),
            "best_any_return": (best_any or {}).get("annualized_geometric_return", ""),
            "best_any_sharpe": (best_any or {}).get("sharpe_ratio", ""),
            "best_any_max_drawdown": (best_any or {}).get("max_drawdown", ""),
            "best_any_difference_vs_benchmark": (best_any or {}).get("difference_versus_benchmark", ""),
            "best_total_market_strategy_id": (best_total or {}).get("strategy_id", ""),
            "best_total_market_difference_vs_benchmark": (best_total or {}).get("difference_versus_benchmark", ""),
            "best_total_market_return": (best_total or {}).get("annualized_geometric_return", ""),
            "best_total_market_sharpe": (best_total or {}).get("sharpe_ratio", ""),
            "best_large_cap_strategy_id": (best_large or {}).get("strategy_id", ""),
            "best_large_cap_difference_vs_benchmark": (best_large or {}).get("difference_versus_benchmark", ""),
            "best_large_cap_return": (best_large or {}).get("annualized_geometric_return", ""),
            "best_large_cap_sharpe": (best_large or {}).get("sharpe_ratio", ""),
        }
    else:
        row_out = {
            **run_meta[run_id],
            "n_full_raw_strategies": 0,
            "n_positive_full_strategies": 0,
        }
    index_rows.append(row_out)

    thresholds = read_csv(ROOT / "index_construction" / run_id / "index_thresholds_by_crsp_universe.csv")
    for row in thresholds:
        threshold_summary_rows.append({**run_meta[run_id], **row})

    err = read_csv(ROOT / "index_construction" / run_id / "error_cost_decomposition_by_crsp_universe.csv")
    groups: dict[tuple[str, str, str, str], dict[str, object]] = {}
    for row in err:
        if row.get("period") != "full" or row.get("model_key") != "raw":
            continue
        key = (
            row.get("index_id", ""),
            row.get("threshold_method", ""),
            row.get("exclusion_rule", ""),
            row.get("confusion_category", ""),
        )
        target = groups.setdefault(
            key,
            {
                **run_meta[run_id],
                "index_id": key[0],
                "threshold_method": key[1],
                "exclusion_rule": key[2],
                "confusion_category": key[3],
                "n_rows": 0,
                "n_firm_months": 0.0,
                "portfolio_weight_affected": 0.0,
                "annualized_geometric_return_contribution": 0.0,
            },
        )
        target["n_rows"] = int(target["n_rows"]) + 1
        target["n_firm_months"] = float(target["n_firm_months"]) + (fnum(row.get("n_firm_months")) or 0.0)
        target["portfolio_weight_affected"] = float(target["portfolio_weight_affected"]) + (fnum(row.get("portfolio_weight_affected")) or 0.0)
        target["annualized_geometric_return_contribution"] = float(target["annualized_geometric_return_contribution"]) + (fnum(row.get("annualized_geometric_return_contribution")) or 0.0)
    error_rows.extend(groups.values())

index_rows.sort(key=lambda row: fnum(row.get("best_total_market_difference_vs_benchmark")) or -math.inf, reverse=True)
for idx, row in enumerate(index_rows, 1):
    if fnum(row.get("best_total_market_difference_vs_benchmark")) is not None:
        row["rank_total_market_diff_desc"] = idx
index_rows.sort(key=lambda row: fnum(row.get("best_any_difference_vs_benchmark")) or -math.inf, reverse=True)
for idx, row in enumerate(index_rows, 1):
    if fnum(row.get("best_any_difference_vs_benchmark")) is not None:
        row["rank_any_diff_desc"] = idx
index_rows.sort(key=lambda row: (fnum(row.get("rank_total_market_diff_desc")) is None, fnum(row.get("rank_total_market_diff_desc")) or 999, row["run_id"]))
write_csv(
    COMPARISONS / "full_grid_11c_index_ranking.csv",
    index_rows,
    [
        "run_id",
        "C",
        "M",
        "T",
        "run_status",
        "n_full_raw_strategies",
        "n_positive_full_strategies",
        "mean_full_difference_vs_benchmark",
        "best_any_index_id",
        "best_any_strategy_id",
        "best_any_threshold_method",
        "best_any_lockout_years",
        "best_any_return",
        "best_any_sharpe",
        "best_any_max_drawdown",
        "best_any_difference_vs_benchmark",
        "rank_any_diff_desc",
        "best_total_market_strategy_id",
        "best_total_market_difference_vs_benchmark",
        "best_total_market_return",
        "best_total_market_sharpe",
        "rank_total_market_diff_desc",
        "best_large_cap_strategy_id",
        "best_large_cap_difference_vs_benchmark",
        "best_large_cap_return",
        "best_large_cap_sharpe",
        "run_note",
    ],
)

write_csv(
    COMPARISONS / "full_grid_threshold_summary.csv",
    threshold_summary_rows,
    [
        "run_id",
        "C",
        "M",
        "T",
        "run_status",
        "track",
        "model_key",
        "model_label",
        "threshold_method",
        "threshold_label",
        "threshold",
        "cv_fpr",
        "cv_recall",
        "cv_precision",
        "cv_youden",
        "cv_flag_rate",
        "cv_n_flagged",
    ],
)

write_csv(
    COMPARISONS / "full_grid_error_cost_summary.csv",
    error_rows,
    [
        "run_id",
        "C",
        "M",
        "T",
        "run_status",
        "index_id",
        "threshold_method",
        "exclusion_rule",
        "confusion_category",
        "n_rows",
        "n_firm_months",
        "portfolio_weight_affected",
        "annualized_geometric_return_contribution",
    ],
)


def best_metric(split: str, metric: str, reverse: bool = True) -> dict[str, object] | None:
    rows = [
        row
        for row in metric_rows
        if row.get("split") == split
        and row.get("run_status") not in {"blocked_partial", "missing"}
        and fnum(row.get(metric)) is not None
    ]
    if not rows:
        return None
    return sorted(rows, key=lambda row: fnum(row.get(metric)) or (math.inf if not reverse else -math.inf), reverse=reverse)[0]


def add_objective(rows: list[dict[str, object]], objective: str, row: dict[str, object] | None, metric: str, direction: str) -> None:
    if row is None:
        rows.append({"objective": objective, "direction": direction})
        return
    rows.append(
        {
            "objective": objective,
            "direction": direction,
            "run_id": row.get("run_id", ""),
            "C": row.get("C", ""),
            "M": row.get("M", ""),
            "T": row.get("T", ""),
            "split": row.get("split", ""),
            "metric": metric,
            "value": row.get(metric, ""),
            "run_status": row.get("run_status", ""),
            "note": row.get("run_note", ""),
        }
    )


best_rows: list[dict[str, object]] = []
for split in ("cv", "test", "oos"):
    for metric in ("ap", "auc", "recall_fpr_1pct", "recall_fpr_3pct", "recall_fpr_5pct"):
        add_objective(best_rows, f"highest_{split}_{metric}", best_metric(split, metric, True), metric, "max")
    add_objective(best_rows, f"lowest_{split}_brier", best_metric(split, "brier", False), "brier", "min")

best_total_11c = next((row for row in index_rows if fnum(row.get("best_total_market_difference_vs_benchmark")) is not None), None)
if best_total_11c:
    best_rows.append(
        {
            "objective": "highest_11c_total_market_difference_vs_benchmark",
            "direction": "max",
            "run_id": best_total_11c.get("run_id", ""),
            "C": best_total_11c.get("C", ""),
            "M": best_total_11c.get("M", ""),
            "T": best_total_11c.get("T", ""),
            "metric": "best_total_market_difference_vs_benchmark",
            "value": best_total_11c.get("best_total_market_difference_vs_benchmark", ""),
            "run_status": best_total_11c.get("run_status", ""),
            "note": best_total_11c.get("run_note", ""),
        }
    )

score_by_run: dict[str, list[float]] = {}
for split, metric, reverse in [
    ("test", "ap", True),
    ("test", "auc", True),
    ("test", "recall_fpr_1pct", True),
    ("test", "recall_fpr_3pct", True),
    ("test", "recall_fpr_5pct", True),
    ("test", "brier", False),
    ("oos", "ap", True),
    ("oos", "auc", True),
]:
    rows = [
        row
        for row in metric_rows
        if row.get("split") == split
        and row.get("run_status") not in {"blocked_partial", "missing"}
        and fnum(row.get(metric)) is not None
    ]
    rows.sort(key=lambda row: fnum(row.get(metric)) or (math.inf if not reverse else -math.inf), reverse=reverse)
    n = max(len(rows) - 1, 1)
    for idx, row in enumerate(rows):
        pct = 1 - idx / n
        score_by_run.setdefault(str(row["run_id"]), []).append(pct)

index_ranked = [row for row in index_rows if row.get("run_status") not in {"blocked_partial", "missing"} and fnum(row.get("best_total_market_difference_vs_benchmark")) is not None]
index_ranked.sort(key=lambda row: fnum(row.get("best_total_market_difference_vs_benchmark")) or -math.inf, reverse=True)
n = max(len(index_ranked) - 1, 1)
for idx, row in enumerate(index_ranked):
    score_by_run.setdefault(str(row["run_id"]), []).append(1 - idx / n)

overall = []
for run_id, values in score_by_run.items():
    if len(values) >= 6:
        overall.append({"run_id": run_id, "overall_score": mean(values), "n_components": len(values), **run_meta[run_id]})
overall.sort(key=lambda row: row["overall_score"], reverse=True)
if overall:
    top = overall[0]
    best_rows.append(
        {
            "objective": "most_defensible_overall_composite",
            "direction": "max",
            "run_id": top["run_id"],
            "C": top["C"],
            "M": top["M"],
            "T": top["T"],
            "metric": "mean percentile rank across test/oos model metrics and 11C total-market difference",
            "value": ffmt(top["overall_score"], 8),
            "run_status": top["run_status"],
            "note": f"{top['n_components']} components",
        }
    )

write_csv(
    COMPARISONS / "full_grid_best_configs_by_objective.csv",
    best_rows,
    ["objective", "direction", "run_id", "C", "M", "T", "split", "metric", "value", "run_status", "note"],
)

factor_rows: list[dict[str, object]] = []
complete_runs = {
    row["run_id"]
    for row in status_rows
    if row.get("status") in {"completed_full_storage_pruned", "skipped_complete_storage_pruned"}
}
for factor in ("C", "M", "T"):
    levels = sorted({run_meta[run_id][factor] for run_id in RUN_IDS})
    for level in levels:
        factor_run_ids = [run_id for run_id in complete_runs if run_meta[run_id][factor] == level]
        for split in ("test", "oos"):
            split_rows = [
                row
                for row in metric_rows
                if row.get("run_id") in factor_run_ids
                and row.get("split") == split
                and fnum(row.get("ap")) is not None
            ]
            factor_rows.append(
                {
                    "factor": factor,
                    "level": level,
                    "metric_group": f"{split}_model",
                    "n_runs": len(split_rows),
                    "mean_ap": ffmt(mean([fnum(row.get("ap")) or 0 for row in split_rows]) if split_rows else None, 8),
                    "mean_auc": ffmt(mean([fnum(row.get("auc")) or 0 for row in split_rows]) if split_rows else None, 8),
                    "mean_recall_fpr_1pct": ffmt(mean([fnum(row.get("recall_fpr_1pct")) or 0 for row in split_rows]) if split_rows else None, 8),
                    "mean_recall_fpr_3pct": ffmt(mean([fnum(row.get("recall_fpr_3pct")) or 0 for row in split_rows]) if split_rows else None, 8),
                    "mean_recall_fpr_5pct": ffmt(mean([fnum(row.get("recall_fpr_5pct")) or 0 for row in split_rows]) if split_rows else None, 8),
                    "mean_brier": ffmt(mean([fnum(row.get("brier")) or 0 for row in split_rows]) if split_rows else None, 8),
                }
            )
        idx_rows = [
            row
            for row in index_rows
            if row.get("run_id") in factor_run_ids
            and fnum(row.get("best_total_market_difference_vs_benchmark")) is not None
        ]
        factor_rows.append(
            {
                "factor": factor,
                "level": level,
                "metric_group": "full_11c_total_market",
                "n_runs": len(idx_rows),
                "mean_best_total_market_difference_vs_benchmark": ffmt(
                    mean([fnum(row.get("best_total_market_difference_vs_benchmark")) or 0 for row in idx_rows])
                    if idx_rows
                    else None,
                    10,
                ),
                "mean_positive_strategy_count": ffmt(
                    mean([fnum(row.get("n_positive_full_strategies")) or 0 for row in idx_rows]) if idx_rows else None,
                    8,
                ),
            }
        )

write_csv(
    COMPARISONS / "full_grid_factor_summary.csv",
    factor_rows,
    [
        "factor",
        "level",
        "metric_group",
        "n_runs",
        "mean_ap",
        "mean_auc",
        "mean_recall_fpr_1pct",
        "mean_recall_fpr_3pct",
        "mean_recall_fpr_5pct",
        "mean_brier",
        "mean_best_total_market_difference_vs_benchmark",
        "mean_positive_strategy_count",
    ],
)

manifest = {
    "run_ids_expected": len(RUN_IDS),
    "run_ids_in_status": len(status_by_run),
    "completed_or_reused": sum(1 for row in status_rows if "complete" in row.get("status", "")),
    "blocked_partial": sum(1 for row in status_rows if row.get("status") == "blocked_partial"),
    "comparison_files": sorted(path.name for path in COMPARISONS.glob("*.csv")),
}
(COMPARISONS / "full_grid_comparison_manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")

print(json.dumps(manifest, indent=2))
