"""
AE-FEAT-IMPORT-005R individual PIT-ratio log-odds perturbation importance.

Loads the bounded GBM-only AutoGluon predictors prepared in
03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm
and computes model-response perturbation importance for individual
point-in-time/base ratio features only on training/CV-analysis rows.
"""

from __future__ import annotations

import gc
import hashlib
import json
import math
import os
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import pandas as pd
import pyreadr
from autogluon.tabular import TabularPredictor
from sklearn.preprocessing import QuantileTransformer


TICKET_ID = "AE-FEAT-IMPORT-005R"
RUN_ID = "pit_ratio_log_odds_rebuild_20260602_gbm"
SEED = 123
PERTURBATION_SEED = 20260602
EPS = 1e-6
TRAIN_END_YEAR = 2015
HOLDOUT_START = 2011
HOLDOUT_END = 2015

ROOT = Path(__file__).resolve().parents[3]
DOC_DIR = ROOT / "05_Documentation" / "09_Epics" / "AE-FEAT-IMPORT_Feature_Importance"
PREDICTOR_ROOT = (
    ROOT
    / "03_Data_Output"
    / "10_FeatureImportance"
    / "predictor_workspace"
    / "rebuild_20260602_gbm"
)
LOCAL_OUTPUT_DIR = ROOT / "03_Data_Output" / "10_FeatureImportance" / "pit_ratio_importance"
ROW_DELTA_DIR = LOCAL_OUTPUT_DIR / "row_deltas"
SUMMARY_DOC = DOC_DIR / f"{TICKET_ID}_pit_ratio_importance_summary.csv"
COVERAGE_DOC = DOC_DIR / f"{TICKET_ID}_pit_ratio_coverage_audit.csv"
SUMMARY_LOCAL = LOCAL_OUTPUT_DIR / f"{TICKET_ID}_pit_ratio_importance_summary.csv"
COVERAGE_LOCAL = LOCAL_OUTPUT_DIR / f"{TICKET_ID}_pit_ratio_coverage_audit.csv"
METADATA_LOCAL = LOCAL_OUTPUT_DIR / f"{TICKET_ID}_run_metadata.json"


ID_COLS = {
    "permno",
    "year",
    "y",
    "censored",
    "param_id",
    "gvkey",
    "datadate",
    "lifetime_years",
    "fiscal_year_end_month",
    "split",
    "eval_split",
    "vae_split",
    "split_oot",
    "y_loser",
    "y_structural",
    "y_dynamic_csi",
    "y_permanent_csi",
    "fwd_cagr",
    "n_months",
    "bucket",
    "event_date",
    "confirmation_date",
    "event_year",
    "label_year",
    "dynamic_event_date",
    "dynamic_confirmation_date",
    "dynamic_event_year",
    "dynamic_label_year",
    "dynamic_label_censored",
    "permanent_event_date",
    "permanent_confirmation_date",
    "permanent_event_year",
    "permanent_label_year",
    "permanent_label_censored",
    "has_adverse_delist",
    "pcl_delisting_date",
    "pcl_delisting_code",
    "months_to_late_recovery",
    "months_observed",
    "year_cat",
}

LATENT_COLS = [f"z{i}" for i in range(1, 25)] + ["vae_recon_error"]

# Narrow individual-feature scope: base accounting, valuation, liquidity,
# leverage, quality, size, Altman, and zombie-precursor ratios only.
# Macro level controls from 004R's broader family block are intentionally
# excluded because 001R says they are point-in-time controls, not accounting
# ratios, unless a later ticket requests a broader point-in-time block.
PIT_RATIO_FEATURES = [
    "earn_yld",
    "ocf_per_share",
    "roa",
    "roe",
    "roic",
    "ebit_roa",
    "gross_margin",
    "ebitda_margin",
    "ocf_margin",
    "leverage",
    "net_debt_ebitda",
    "std_debt_pct",
    "eff_int_rate",
    "interest_cov",
    "dd1_ratio",
    "current_ratio",
    "quick_ratio",
    "cash_pct_act",
    "wcap_ratio",
    "bp_ratio",
    "ev_to_sales",
    "div_yield",
    "cash_div_cf",
    "mkt_to_book",
    "accruals_ratio",
    "asset_turnover",
    "capex_intensity",
    "rd_intensity",
    "reinvest_rate",
    "log_at",
    "log_mkvalt",
    "log_emp",
    "rental_ratio",
    "assets_per_emp",
    "ni_per_emp",
    "min_int_tcap",
    "compr_inc_ratio",
    "altman_z1",
    "altman_z2",
    "altman_z3",
    "altman_z4",
    "altman_z5",
    "altman_z",
    "invest_st_ratio",
]


@dataclass(frozen=True)
class RunSpec:
    feature_set: str
    track: str
    track_folder: str
    feature_file: str
    loader: str
    predictor_subdir: str
    applicable: bool


RUNS = [
    RunSpec("raw", "dynamic_csi", "temporary_csi", "features_raw.rds", "rds", "ag_raw", True),
    RunSpec("raw", "permanent_csi", "permanent_csi", "features_raw.rds", "rds", "ag_raw", True),
    RunSpec("fund", "dynamic_csi", "temporary_csi", "features_fund.rds", "rds", "ag_fund", True),
    RunSpec("fund", "permanent_csi", "permanent_csi", "features_fund.rds", "rds", "ag_fund", True),
    RunSpec(
        "latent_raw",
        "dynamic_csi",
        "temporary_csi",
        "features_latent_raw.parquet",
        "parquet",
        "ag_latent_raw",
        False,
    ),
    RunSpec(
        "latent_raw",
        "permanent_csi",
        "permanent_csi",
        "features_latent_raw.parquet",
        "parquet",
        "ag_latent_raw",
        False,
    ),
    RunSpec(
        "raw_plus_latent",
        "dynamic_csi",
        "temporary_csi",
        "features_raw_plus_latent.parquet",
        "parquet",
        "ag_raw_plus_latent",
        True,
    ),
    RunSpec(
        "raw_plus_latent",
        "permanent_csi",
        "permanent_csi",
        "features_raw_plus_latent.parquet",
        "parquet",
        "ag_raw_plus_latent",
        True,
    ),
]


def stable_seed(*parts: str) -> int:
    raw = "|".join(parts).encode("utf-8")
    digest = hashlib.sha256(raw).hexdigest()
    return (PERTURBATION_SEED + int(digest[:12], 16)) % (2**32 - 1)


def load_rds(path: Path) -> pd.DataFrame:
    return pyreadr.read_r(str(path))[None]


def load_features(spec: RunSpec) -> pd.DataFrame:
    feature_path = (
        ROOT
        / "02_Data_Input"
        / "05_PipelineResults"
        / "Necessary"
        / spec.track_folder
        / "Features"
        / spec.feature_file
    )
    if spec.loader == "rds":
        return load_rds(feature_path)
    df = pd.read_parquet(feature_path)
    if "split" in df.columns:
        df = df.rename(columns={"split": "vae_split"})
    return df


def cv_block(year: int) -> str:
    if year <= 2001:
        return "initial_train_1993_2001"
    if 2002 <= year <= 2006:
        return "cv_fold2_validation_2002_2006"
    if 2007 <= year <= 2010:
        return "cv_fold3_validation_2007_2010"
    if HOLDOUT_START <= year <= HOLDOUT_END:
        return "cv_fold4_holdout_2011_2015"
    return "training_analysis_other"


def build_training_matrix(spec: RunSpec) -> tuple[pd.DataFrame, list[str]]:
    features_input = load_features(spec)
    split_labels_path = (
        ROOT
        / "02_Data_Input"
        / "05_PipelineResults"
        / "Necessary"
        / spec.track_folder
        / "Features"
        / "split_labels_oot.parquet"
    )
    split_labels = pd.read_parquet(split_labels_path)
    if "eval_split" not in split_labels.columns:
        split_labels["eval_split"] = np.where(
            (split_labels["split"] == "train") & (split_labels["year"] == TRAIN_END_YEAR),
            "train_boundary",
            np.where(
                (split_labels["split"] == "test") & (split_labels["year"] == 2019),
                "test_boundary",
                split_labels["split"],
            ),
        )

    df = (
        features_input.merge(split_labels, on=["permno", "year"], how="left")
        .query("split.notna()")
        .sort_values(["permno", "year"])
        .reset_index(drop=True)
    )
    df_with_label = df[df["y"].notna()].copy()
    df_with_label["y"] = df_with_label["y"].astype(int)
    train_df = df_with_label[df_with_label["split"] == "train"].copy()

    if spec.feature_set == "latent_raw":
        feature_cols = [c for c in LATENT_COLS if c in train_df.columns]
    else:
        feature_cols = [
            c
            for c in train_df.columns
            if c not in ID_COLS
            and c not in {"y_next", "y", "y_loser", "y_structural", "y_dynamic_csi", "y_permanent_csi"}
            and pd.api.types.is_numeric_dtype(train_df[c])
        ]

    x_train = train_df[feature_cols].values.astype(np.float64)
    x_train[np.isinf(x_train)] = np.nan
    lo = np.nanpercentile(x_train, 0.1, axis=0)
    hi = np.nanpercentile(x_train, 99.9, axis=0)
    x_clipped = np.clip(x_train, lo, hi)
    medians = np.nanmedian(x_clipped, axis=0)
    medians = np.where(np.isnan(medians), 0.0, medians)

    for j in range(x_clipped.shape[1]):
        mask = np.isnan(x_clipped[:, j])
        if mask.any():
            x_clipped[mask, j] = medians[j]

    qt = QuantileTransformer(
        output_distribution="uniform",
        n_quantiles=min(1000, len(x_clipped)),
        random_state=SEED,
    )
    qt.fit(x_clipped)
    x_qt = qt.transform(x_clipped)

    out = pd.DataFrame(x_qt, columns=feature_cols, index=train_df.index)
    out["y"] = train_df["y"].values
    out["year"] = train_df["year"].values
    out["permno"] = train_df["permno"].values
    out["cv_block"] = out["year"].map(cv_block)
    return out.reset_index(drop=True), feature_cols


def positive_probability(predictor: TabularPredictor, data: pd.DataFrame) -> np.ndarray:
    proba = predictor.predict_proba(data, as_pandas=True)
    if isinstance(proba, pd.DataFrame):
        if 1 in proba.columns:
            return proba[1].to_numpy(dtype=float)
        if "1" in proba.columns:
            return proba["1"].to_numpy(dtype=float)
        return proba.iloc[:, -1].to_numpy(dtype=float)
    return np.asarray(proba, dtype=float)


def logit(prob: np.ndarray) -> np.ndarray:
    clipped = np.clip(prob, EPS, 1.0 - EPS)
    return np.log(clipped / (1.0 - clipped))


def perturb_feature(base: pd.DataFrame, feature: str, feature_set: str, track: str) -> pd.DataFrame:
    perturbed = base.copy()
    values = perturbed[feature].to_numpy(copy=True)
    blocks = perturbed["cv_block"].to_numpy()
    for block in np.unique(blocks):
        idx = np.flatnonzero(blocks == block)
        if len(idx) <= 1:
            continue
        rng = np.random.default_rng(stable_seed(feature_set, track, feature, str(block)))
        values[idx] = values[idx][rng.permutation(len(idx))]
    perturbed[feature] = values
    return perturbed


def best_model_name(predictor: TabularPredictor) -> str:
    try:
        return str(predictor.model_best)
    except Exception:
        return "unknown"


def summarize_delta(
    spec: RunSpec,
    predictor_path: Path,
    feature: str,
    n_rows: int,
    baseline_prob: np.ndarray,
    perturbed_prob: np.ndarray,
    best_model: str,
) -> dict:
    delta = logit(baseline_prob) - logit(perturbed_prob)
    abs_delta = np.abs(delta)
    return {
        "ticket_id": TICKET_ID,
        "run_id": RUN_ID,
        "feature_set": spec.feature_set,
        "track": spec.track,
        "feature_name": feature,
        "feature_family": "point_in_time_ratios",
        "result_status": "computed",
        "n_rows_used": n_rows,
        "baseline_mean_probability": float(np.mean(baseline_prob)),
        "perturbed_mean_probability": float(np.mean(perturbed_prob)),
        "mean_abs_delta_log_odds": float(np.mean(abs_delta)),
        "mean_signed_delta_log_odds": float(np.mean(delta)),
        "median_abs_delta_log_odds": float(np.median(abs_delta)),
        "p90_abs_delta_log_odds": float(np.quantile(abs_delta, 0.9)),
        "probability_clip_eps": EPS,
        "perturbation_policy": "deterministic_individual_feature_permutation_within_cv_block",
        "permutation_strata": (
            "initial_train_1993_2001;cv_fold2_2002_2006;"
            "cv_fold3_2007_2010;cv_fold4_holdout_2011_2015"
        ),
        "perturbation_seed": PERTURBATION_SEED,
        "predictor_path": str(predictor_path.relative_to(ROOT)),
        "best_model": best_model,
        "bounded_predictor_note": "bounded GBM-only predictor workspace; not full final model-suite importance",
        "pit_ratio_source": (
            "AE-FEAT-IMPORT-001R base ratio subset plus 06B/004R evidence for cash_div_cf; "
            "macro point-in-time controls excluded"
        ),
    }


def write_row_deltas(
    spec: RunSpec,
    feature: str,
    matrix: pd.DataFrame,
    baseline_prob: np.ndarray,
    perturbed_prob: np.ndarray,
) -> None:
    delta = logit(baseline_prob) - logit(perturbed_prob)
    out = pd.DataFrame(
        {
            "ticket_id": TICKET_ID,
            "run_id": RUN_ID,
            "feature_set": spec.feature_set,
            "track": spec.track,
            "feature_name": feature,
            "feature_family": "point_in_time_ratios",
            "permno": matrix["permno"].to_numpy(),
            "year": matrix["year"].to_numpy(),
            "cv_block": matrix["cv_block"].to_numpy(),
            "baseline_probability": baseline_prob,
            "perturbed_probability": perturbed_prob,
            "delta_log_odds": delta,
            "abs_delta_log_odds": np.abs(delta),
        }
    )
    out_path = ROW_DELTA_DIR / f"{spec.feature_set}_{spec.track}_{feature}_row_deltas.parquet"
    out.to_parquet(out_path, index=False)


def predictor_path_for(spec: RunSpec) -> Path:
    return (
        PREDICTOR_ROOT
        / "3_Modelling_Results"
        / "Necessary"
        / spec.track_folder
        / "AutoGluon"
        / spec.predictor_subdir
        / "ag_predictor"
    )


def main() -> None:
    LOCAL_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    ROW_DELTA_DIR.mkdir(parents=True, exist_ok=True)

    summary_rows: list[dict] = []
    coverage_rows: list[dict] = []
    run_started = datetime.now(timezone.utc).isoformat()

    for spec in RUNS:
        print(f"[{TICKET_ID}] Processing {spec.feature_set}/{spec.track}", flush=True)
        predictor_path = predictor_path_for(spec)
        predictor = TabularPredictor.load(str(predictor_path))
        required_features = predictor.feature_metadata_in.get_features()
        best_model = best_model_name(predictor)
        train_matrix, _ = build_training_matrix(spec)

        present_pit_features = [f for f in PIT_RATIO_FEATURES if f in required_features]
        missing_pit_features = [f for f in PIT_RATIO_FEATURES if f not in required_features]
        unexpected_required_pit_like = [
            f
            for f in required_features
            if f in {"fedfunds", "gdp_growth", "hy_spread", "vix", "term_spread", "unrate",
                     "cpi_inflation", "indpro_growth", "recession", "d_unrate", "d_hy_spread", "d_vix"}
        ]

        if spec.applicable and present_pit_features:
            result_status = "computed"
        elif spec.applicable:
            result_status = "missing_pit_features"
        else:
            result_status = "not_applicable_no_point_in_time_ratio_features"

        coverage_rows.append(
            {
                "ticket_id": TICKET_ID,
                "run_id": RUN_ID,
                "feature_set": spec.feature_set,
                "track": spec.track,
                "applicability": "applicable" if spec.applicable else "not_applicable",
                "result_status": result_status,
                "predictor_available": True,
                "n_rows_used": int(len(train_matrix)),
                "n_required_predictor_features": int(len(required_features)),
                "n_expected_pit_ratio_features": int(len(PIT_RATIO_FEATURES)),
                "n_present_pit_ratio_features": int(len(present_pit_features)),
                "n_missing_pit_ratio_features": int(len(missing_pit_features)),
                "present_pit_ratio_features": ";".join(present_pit_features),
                "missing_pit_ratio_features": ";".join(missing_pit_features),
                "macro_point_in_time_controls_excluded": ";".join(unexpected_required_pit_like),
                "predictor_path": str(predictor_path.relative_to(ROOT)),
                "best_model": best_model,
                "bounded_predictor_note": "bounded GBM-only predictor workspace; not full final model-suite importance",
            }
        )

        if not spec.applicable or not present_pit_features:
            del predictor, train_matrix
            gc.collect()
            continue

        missing_required = [c for c in required_features if c not in train_matrix.columns]
        if missing_required:
            raise RuntimeError(f"Missing required features for {spec.feature_set}/{spec.track}: {missing_required}")

        base_cols = required_features + ["permno", "year", "cv_block"]
        base_matrix = train_matrix[base_cols].copy()
        prediction_base = base_matrix[required_features]
        baseline_prob = positive_probability(predictor, prediction_base)
        n_rows = len(base_matrix)

        for feature in present_pit_features:
            perturbed = perturb_feature(base_matrix, feature, spec.feature_set, spec.track)
            perturbed_prob = positive_probability(predictor, perturbed[required_features])
            summary_rows.append(
                summarize_delta(
                    spec,
                    predictor_path,
                    feature,
                    n_rows,
                    baseline_prob,
                    perturbed_prob,
                    best_model,
                )
            )
            write_row_deltas(spec, feature, base_matrix, baseline_prob, perturbed_prob)

        del predictor, train_matrix, base_matrix
        gc.collect()

    summary = pd.DataFrame(summary_rows)
    coverage = pd.DataFrame(coverage_rows)

    if not summary.empty:
        summary["rank_within_model_track"] = (
            summary.groupby(["track", "feature_set"])["mean_abs_delta_log_odds"]
            .rank(method="first", ascending=False)
            .astype(int)
        )
        summary = summary.sort_values(
            ["track", "feature_set", "rank_within_model_track"],
            ascending=[True, True, True],
        )
    coverage = coverage.sort_values(["track", "feature_set"]).reset_index(drop=True)

    summary.to_csv(SUMMARY_DOC, index=False)
    summary.to_csv(SUMMARY_LOCAL, index=False)
    coverage.to_csv(COVERAGE_DOC, index=False)
    coverage.to_csv(COVERAGE_LOCAL, index=False)

    metadata = {
        "ticket_id": TICKET_ID,
        "run_id": RUN_ID,
        "started_utc": run_started,
        "completed_utc": datetime.now(timezone.utc).isoformat(),
        "root": str(ROOT),
        "predictor_root": str(PREDICTOR_ROOT.relative_to(ROOT)),
        "local_output_dir": str(LOCAL_OUTPUT_DIR.relative_to(ROOT)),
        "n_summary_rows": int(len(summary)),
        "n_coverage_rows": int(len(coverage)),
        "n_model_track_combinations": len(RUNS),
        "n_applicable_model_track_combinations": int(sum(spec.applicable for spec in RUNS)),
        "n_not_applicable_model_track_combinations": int(sum(not spec.applicable for spec in RUNS)),
        "n_expected_pit_ratio_features": int(len(PIT_RATIO_FEATURES)),
        "probability_clip_eps": EPS,
        "perturbation_policy": "deterministic individual-feature permutation within CV/training-analysis blocks",
        "bounded_predictor_note": "bounded GBM-only predictor workspace; not full final model-suite importance",
    }
    METADATA_LOCAL.write_text(json.dumps(metadata, indent=2), encoding="utf-8")
    print(json.dumps(metadata, indent=2), flush=True)


if __name__ == "__main__":
    main()
    # AutoGluon can leave runtime worker threads alive after successful writes.
    # Force process termination so verification commands do not hang.
    os._exit(0)
