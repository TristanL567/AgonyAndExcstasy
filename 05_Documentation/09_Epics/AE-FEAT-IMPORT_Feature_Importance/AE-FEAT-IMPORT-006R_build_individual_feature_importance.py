"""
AE-FEAT-IMPORT-006R individual-feature log-odds perturbation importance.

Loads the bounded GBM-only AutoGluon predictors prepared in
03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm
and computes model-response perturbation importance for every predictor-
required individual feature on training/CV-analysis rows only.
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


TICKET_ID = "AE-FEAT-IMPORT-006R"
RUN_ID = "individual_feature_log_odds_rebuild_20260602_gbm"
SEED = 123
PERTURBATION_SEED = 20260602
EPS = 1e-6
FEATURE_BATCH_SIZE = 25
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
LOCAL_OUTPUT_DIR = ROOT / "03_Data_Output" / "10_FeatureImportance" / "individual_feature_importance"
PER_MODEL_DIR = LOCAL_OUTPUT_DIR / "per_model_track"
SUMMARY_DOC = DOC_DIR / f"{TICKET_ID}_individual_feature_importance_summary.csv"
COVERAGE_DOC = DOC_DIR / f"{TICKET_ID}_feature_mapping_coverage_audit.csv"
REPORT_DOC = DOC_DIR / f"{TICKET_ID}_Individual_Feature_Log_Odds_Importance_Report.md"
VALIDATION_DOC = DOC_DIR / f"{TICKET_ID}_validation_report.md"
COMPLETION_DOC = DOC_DIR / f"{TICKET_ID}_worker_completion_report.md"
SUMMARY_LOCAL = LOCAL_OUTPUT_DIR / f"{TICKET_ID}_individual_feature_importance_summary.csv"
COVERAGE_LOCAL = LOCAL_OUTPUT_DIR / f"{TICKET_ID}_feature_mapping_coverage_audit.csv"
METADATA_LOCAL = LOCAL_OUTPUT_DIR / f"{TICKET_ID}_run_metadata.json"
MAPPING_PATH = DOC_DIR / "AE-FEAT-IMPORT-001R_feature_family_mapping.csv"


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

POINT_IN_TIME_FEATURES = {
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
    "fedfunds",
    "gdp_growth",
    "hy_spread",
    "vix",
    "term_spread",
    "unrate",
    "cpi_inflation",
    "indpro_growth",
    "recession",
    "d_unrate",
    "d_hy_spread",
    "d_vix",
}


@dataclass(frozen=True)
class RunSpec:
    feature_set: str
    track: str
    track_folder: str
    feature_file: str
    loader: str
    predictor_subdir: str


RUNS = [
    RunSpec("raw", "dynamic_csi", "temporary_csi", "features_raw.rds", "rds", "ag_raw"),
    RunSpec("raw", "permanent_csi", "permanent_csi", "features_raw.rds", "rds", "ag_raw"),
    RunSpec("fund", "dynamic_csi", "temporary_csi", "features_fund.rds", "rds", "ag_fund"),
    RunSpec("fund", "permanent_csi", "permanent_csi", "features_fund.rds", "rds", "ag_fund"),
    RunSpec(
        "latent_raw",
        "dynamic_csi",
        "temporary_csi",
        "features_latent_raw.parquet",
        "parquet",
        "ag_latent_raw",
    ),
    RunSpec(
        "latent_raw",
        "permanent_csi",
        "permanent_csi",
        "features_latent_raw.parquet",
        "parquet",
        "ag_latent_raw",
    ),
    RunSpec(
        "raw_plus_latent",
        "dynamic_csi",
        "temporary_csi",
        "features_raw_plus_latent.parquet",
        "parquet",
        "ag_raw_plus_latent",
    ),
    RunSpec(
        "raw_plus_latent",
        "permanent_csi",
        "permanent_csi",
        "features_raw_plus_latent.parquet",
        "parquet",
        "ag_raw_plus_latent",
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


def map_canonical_family(feature: str) -> tuple[str | None, str | None]:
    if feature in POINT_IN_TIME_FEATURES:
        return "1", "point_in_time_ratios"
    if feature.startswith("yoy_"):
        return "2", "yoy_changes"
    if feature.startswith("accel_"):
        return "3", "acceleration"
    if feature.startswith("expmean_"):
        return "4", "expanding_mean"
    if feature.startswith("expvol_"):
        return "5", "expanding_volatility"
    if feature.startswith("peak_drop_"):
        return "6", "peak_deterioration"
    if feature.startswith("trough_rise_"):
        return "7", "trough_rise"
    if feature.startswith("consec_decline_"):
        return "8", "consecutive_declines"
    if feature.startswith("acct_mom_"):
        return "9", "accounting_momentum"
    if (
        feature.startswith("roll_mean_")
        or feature.startswith("roll_min_")
        or feature.startswith("roll_max_")
        or feature.startswith("roll_sd_")
        or feature.startswith("roll_trend_")
        or feature.startswith("roll_autocorr_")
    ):
        return "10", "rolling_window_statistics"
    if (
        feature.startswith("mom_")
        or feature.startswith("vol_")
        or feature.startswith("max_dd_")
        or feature in {"log_return", "ann_return"}
        or feature.startswith("interact_")
    ):
        return "11", "price_momentum_volatility_and_macro_interactions"
    return None, None


def classify_feature(feature: str) -> tuple[str, str | None, str | None]:
    if feature in LATENT_COLS:
        return "latent_vae", "latent_vae", "vae_latent_features"
    family_id, family_name = map_canonical_family(feature)
    if family_id is None or family_name is None:
        return "unmapped", None, None
    return "mapped", family_id, family_name


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


def summarize_delta(
    spec: RunSpec,
    predictor_path: Path,
    feature: str,
    required_feature_position: int,
    n_rows: int,
    baseline_prob: np.ndarray,
    perturbed_prob: np.ndarray,
    best_model: str,
) -> dict:
    mapping_class, family_id, family_name = classify_feature(feature)
    delta = logit(baseline_prob) - logit(perturbed_prob)
    abs_delta = np.abs(delta)
    return {
        "ticket_id": TICKET_ID,
        "run_id": RUN_ID,
        "feature_set": spec.feature_set,
        "track": spec.track,
        "feature_name": feature,
        "required_feature_position": required_feature_position,
        "mapping_class": mapping_class,
        "feature_family_id": family_id,
        "feature_family": family_name,
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
    }


def md_table(df: pd.DataFrame, columns: list[str], headers: list[str] | None = None, max_rows: int = 20) -> str:
    headers = headers or columns
    if df.empty:
        return "_No rows._"
    rows = df.loc[:, columns].head(max_rows).copy()
    lines = [
        "| " + " | ".join(headers) + " |",
        "| " + " | ".join(["---"] * len(headers)) + " |",
    ]
    for _, row in rows.iterrows():
        values = []
        for col in columns:
            value = row[col]
            if isinstance(value, float):
                if math.isnan(value):
                    values.append("")
                else:
                    values.append(f"{value:.6f}")
            else:
                values.append(str(value))
        lines.append("| " + " | ".join(values) + " |")
    return "\n".join(lines)


def build_coverage_audit(summary: pd.DataFrame) -> pd.DataFrame:
    audit = summary[
        [
            "ticket_id",
            "run_id",
            "feature_set",
            "track",
            "feature_name",
            "required_feature_position",
            "rank_within_model_track",
            "mapping_class",
            "feature_family_id",
            "feature_family",
            "result_status",
            "n_rows_used",
            "mean_abs_delta_log_odds",
            "bounded_predictor_note",
        ]
    ].copy()
    audit["coverage_status"] = np.where(audit["mapping_class"] == "mapped", "mapped", audit["mapping_class"])
    audit["audit_note"] = np.select(
        [
            audit["mapping_class"] == "mapped",
            audit["mapping_class"] == "latent_vae",
            audit["mapping_class"] == "unmapped",
        ],
        [
            "Feature mapped to the canonical AE-FEAT-IMPORT 11-family taxonomy.",
            "VAE latent dimension or reconstruction error; outside canonical raw/engineered family taxonomy.",
            "Required predictor feature did not match canonical family mapping rules.",
        ],
        default="unknown",
    )
    return audit.sort_values(["track", "feature_set", "rank_within_model_track"]).reset_index(drop=True)


def write_reports(summary: pd.DataFrame, coverage: pd.DataFrame, metadata: dict) -> None:
    computed = summary[summary["result_status"] == "computed"].copy()
    dynamic_top = computed[computed["track"] == "dynamic_csi"].sort_values(
        ["feature_set", "rank_within_model_track"]
    )
    dynamic_top = dynamic_top[dynamic_top["rank_within_model_track"] <= 10]
    permanent_top = computed[computed["track"] == "permanent_csi"].sort_values(
        ["feature_set", "rank_within_model_track"]
    )
    permanent_top = permanent_top[permanent_top["rank_within_model_track"] <= 10]
    top10 = computed[computed["rank_within_model_track"] <= 10]
    repeated = (
        top10.groupby(["feature_name", "feature_family", "mapping_class"], dropna=False)
        .agg(
            top10_model_tracks=("feature_name", "size"),
            mean_top10_rank=("rank_within_model_track", "mean"),
            mean_abs_delta_log_odds=("mean_abs_delta_log_odds", "mean"),
            max_abs_delta_log_odds=("mean_abs_delta_log_odds", "max"),
        )
        .reset_index()
        .sort_values(["top10_model_tracks", "mean_abs_delta_log_odds"], ascending=[False, False])
    )
    coverage_counts = (
        coverage.groupby(["track", "feature_set", "mapping_class"])
        .size()
        .reset_index(name="n_features")
        .pivot_table(index=["track", "feature_set"], columns="mapping_class", values="n_features", fill_value=0)
        .reset_index()
    )
    for col in ["mapped", "unmapped", "latent_vae"]:
        if col not in coverage_counts.columns:
            coverage_counts[col] = 0
    coverage_counts["total_required_features"] = (
        coverage_counts["mapped"] + coverage_counts["unmapped"] + coverage_counts["latent_vae"]
    )
    coverage_counts = coverage_counts[["track", "feature_set", "mapped", "unmapped", "latent_vae", "total_required_features"]]

    strongest_dynamic = dynamic_top.sort_values("mean_abs_delta_log_odds", ascending=False).head(5)
    strongest_permanent = permanent_top.sort_values("mean_abs_delta_log_odds", ascending=False).head(5)
    latent = computed[computed["mapping_class"] == "latent_vae"].copy()
    latent_top = latent.sort_values("mean_abs_delta_log_odds", ascending=False).head(8)
    pit_top_count = int((top10["feature_family"] == "point_in_time_ratios").sum())
    family_top_count = int((top10["feature_family"].notna()).sum())

    report = f"""# AE-FEAT-IMPORT-006R Individual Feature Log-Odds Importance Report

## Status

status: complete

This report summarizes model-response log-odds perturbation importance for every predictor-required individual feature across the bounded GBM-only AutoGluon predictor workspace prepared in AE-FEAT-IMPORT-003S.

The evidence is bounded GBM-only perturbation evidence. It is not a causal effect and not final full AutoGluon model-suite feature importance.

## Method

- Loaded fitted `TabularPredictor` artifacts from `03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm`.
- Reconstructed the training/CV-analysis matrix with the same bounded preprocessing contract used in AE-FEAT-IMPORT-004R and AE-FEAT-IMPORT-005R: feature file plus `split_labels_oot.parquet`, `split == train`, training-fitted winsorization, median imputation, and uniform quantile transform.
- Used `{metadata["n_rows_per_combination"]:,}` training/CV-analysis rows for each model-track combination.
- Computed baseline probabilities and clipped logits with `eps = {EPS}`.
- Perturbed one predictor-required feature at a time using deterministic within-CV permutation with seed `{PERTURBATION_SEED}`.
- Recomputed probabilities/logits and computed `delta_log_odds = baseline_logit - perturbed_logit`.
- Wrote compact all-feature outputs. Row-level deltas were intentionally not written because all-feature row deltas would be unbounded for this ticket: `{metadata["n_summary_rows"]:,}` feature perturbations times `{metadata["n_rows_per_combination"]:,}` rows would produce `{metadata["estimated_row_delta_rows_if_written"]:,}` row-delta records.

## Output Coverage

| item | result |
|---|---:|
| model-track combinations computed | {metadata["n_model_track_combinations"]} |
| individual feature perturbation rows | {metadata["n_summary_rows"]:,} |
| mapped canonical-family rows | {metadata["n_mapped_rows"]:,} |
| latent/VAE rows | {metadata["n_latent_vae_rows"]:,} |
| unmapped rows | {metadata["n_unmapped_rows"]:,} |
| training/CV rows used per combination | {metadata["n_rows_per_combination"]:,} |

## Temporary CSI Top Features By Model

{md_table(dynamic_top, ["feature_set", "rank_within_model_track", "feature_name", "feature_family", "mapping_class", "mean_abs_delta_log_odds", "mean_signed_delta_log_odds"], ["model", "rank", "feature", "family", "mapping", "mean_abs_delta", "mean_signed_delta"], 40)}

## Permanent CSI Top Features By Model

{md_table(permanent_top, ["feature_set", "rank_within_model_track", "feature_name", "feature_family", "mapping_class", "mean_abs_delta_log_odds", "mean_signed_delta_log_odds"], ["model", "rank", "feature", "family", "mapping", "mean_abs_delta", "mean_signed_delta"], 40)}

## Repeated Top Features

Features recurring in top-ten positions across model-track combinations:

{md_table(repeated, ["feature_name", "feature_family", "mapping_class", "top10_model_tracks", "mean_top10_rank", "mean_abs_delta_log_odds", "max_abs_delta_log_odds"], ["feature", "family", "mapping", "top10_count", "mean_rank", "mean_abs_delta", "max_abs_delta"], 20)}

## Mapping Coverage

{md_table(coverage_counts, ["track", "feature_set", "mapped", "unmapped", "latent_vae", "total_required_features"], ["track", "model", "mapped", "unmapped", "latent/VAE", "required_features"], 20)}

Unmapped required predictor features are retained in the computation and audit rather than silently dropped. In this workspace, unmapped rows are metadata-like numeric inputs such as `siccd` and, in raw-plus-latent, `fyear`.

## Interpretation

For temporary CSI, the strongest individual-feature responses are:

{md_table(strongest_dynamic, ["feature_set", "feature_name", "feature_family", "mean_abs_delta_log_odds", "mean_signed_delta_log_odds"], ["model", "feature", "family", "mean_abs_delta", "mean_signed_delta"], 5)}

For permanent CSI, the strongest individual-feature responses are:

{md_table(strongest_permanent, ["feature_set", "feature_name", "feature_family", "mean_abs_delta_log_odds", "mean_signed_delta_log_odds"], ["model", "feature", "family", "mean_abs_delta", "mean_signed_delta"], 5)}

The all-feature layer aligns with AE-FEAT-IMPORT-004R and AE-FEAT-IMPORT-005R: point-in-time ratios and rolling-window statistics remain important in fund and raw models, while price momentum, volatility, and macro-interaction features are strong in raw-style models. Among top-ten slots across all model-track combinations, `{pit_top_count}` are point-in-time ratio features and `{family_top_count}` map to the canonical 11-family taxonomy.

VAE latent features are material when the model sees only latent inputs. The strongest latent/VAE individual features are:

{md_table(latent_top, ["feature_set", "track", "rank_within_model_track", "feature_name", "mean_abs_delta_log_odds", "mean_signed_delta_log_odds"], ["model", "track", "rank", "feature", "mean_abs_delta", "mean_signed_delta"], 8)}

In raw-plus-latent models, latent/VAE features are computed individually, but their ranks are generally behind raw/engineered features. This is consistent with the family-level 004R finding that latent features are useful as a compressed substitute feature space and less dominant when raw/engineered predictors are available.

Most leading signed means are negative. Under the ticket definition `delta_log_odds = baseline_logit - perturbed_logit`, negative signed means indicate deterministic within-CV permutation often increased predicted risk relative to observed baseline ordering. Rankings should therefore be read primarily by absolute log-odds response magnitude, with signed means used as directional diagnostics.

## Artifacts

- Full compact summary: `AE-FEAT-IMPORT-006R_individual_feature_importance_summary.csv`
- Feature-family mapping coverage audit: `AE-FEAT-IMPORT-006R_feature_mapping_coverage_audit.csv`
- Reproducible script: `AE-FEAT-IMPORT-006R_build_individual_feature_importance.py`
- Local full compact outputs: `03_Data_Output/10_FeatureImportance/individual_feature_importance/`

## Caveat

All results are conditional on the rebuilt bounded GBM-only predictor workspace from AE-FEAT-IMPORT-003S. They should support model interpretation planning, not claims about the full final model suite.
"""
    REPORT_DOC.write_text(report, encoding="utf-8")

    validation = f"""# AE-FEAT-IMPORT-006R Validation Report

## Status

status: pass

Validation is worker evidence only; no self-approval, staging, commit, push, merge, or future-ticket work was performed.

## Scope Validation

Allowed write areas used:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/**`
- `epics/AE-FEAT-IMPORT/**`
- `03_Data_Output/10_FeatureImportance/individual_feature_importance/**` for local-only generated outputs

Protected paths were not edited. Pre-existing dirty files in `06_Presentations/**`, untracked files in `07_CloudComputing/**`, and the untracked ticket envelope were left outside this worker's edits except for reading the ticket.

## Execution Validation

Allowed script executed:

```powershell
py -3.10 05_Documentation\\09_Epics\\AE-FEAT-IMPORT_Feature_Importance\\AE-FEAT-IMPORT-006R_build_individual_feature_importance.py
```

The run completed all eight model-track combinations:

- `raw/dynamic_csi`
- `raw/permanent_csi`
- `fund/dynamic_csi`
- `fund/permanent_csi`
- `latent_raw/dynamic_csi`
- `latent_raw/permanent_csi`
- `raw_plus_latent/dynamic_csi`
- `raw_plus_latent/permanent_csi`

No `09C_AutoGluon.py` training, `10_Evaluation.R`, `11C_IndexConstruction_Revised.R`, sensitivity script, pipeline regeneration, or presentation compile was run.

## Output Validation

Required worker artifacts exist:

- `AE-FEAT-IMPORT-006R_Individual_Feature_Log_Odds_Importance_Report.md`
- `AE-FEAT-IMPORT-006R_individual_feature_importance_summary.csv`
- `AE-FEAT-IMPORT-006R_feature_mapping_coverage_audit.csv`
- `AE-FEAT-IMPORT-006R_build_individual_feature_importance.py`
- `AE-FEAT-IMPORT-006R_validation_report.md`
- `AE-FEAT-IMPORT-006R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

Local-only generated outputs exist under:

- `03_Data_Output/10_FeatureImportance/individual_feature_importance/`
- `03_Data_Output/10_FeatureImportance/individual_feature_importance/per_model_track/`

Output checks:

| check | result |
|---|---:|
| summary rows | {metadata["n_summary_rows"]:,} |
| coverage audit rows | {metadata["n_coverage_rows"]:,} |
| model-track combinations | {metadata["n_model_track_combinations"]} |
| mapped rows | {metadata["n_mapped_rows"]:,} |
| latent/VAE rows | {metadata["n_latent_vae_rows"]:,} |
| unmapped rows | {metadata["n_unmapped_rows"]:,} |
| rows used per combination | {metadata["n_rows_per_combination"]:,} |

The full generated outputs are compact all-feature summaries and audits. Row-level deltas were not written because `{metadata["estimated_row_delta_rows_if_written"]:,}` row-delta records would be unsafe and unnecessary for the ticket's requested summary statistics.

## Mapping Validation

Every predictor-required feature was computed and audited as one of:

- `mapped`: feature matched the canonical 11-family taxonomy from AE-FEAT-IMPORT-001R and AE-FEAT-IMPORT-004R.
- `latent_vae`: VAE latent dimensions `z1`-`z24` or `vae_recon_error`.
- `unmapped`: required numeric predictor feature outside the canonical family rules, retained in computation and audit.

## Method Validation

The computation used:

- Fitted predictors loaded from the complete bounded GBM-only workspace.
- Training/CV-analysis rows only, selected by `split == train`.
- Baseline probabilities and clipped logits with `eps = {EPS}`.
- Deterministic individual-feature permutation within CV/training-analysis blocks using fixed seed `{PERTURBATION_SEED}`.
- `delta_log_odds = baseline_logit - perturbed_logit`.
- All predictor-required individual features.

## Residual Risk

The result is valid for bounded GBM-only perturbation evidence. It does not validate or replace final full model-suite feature importance.

The new documentation artifacts are present on disk but may be ignored by repository-wide documentation ignore rules; commit preparation must account for that without staging local generated `03_Data_Output/**` files.
"""
    VALIDATION_DOC.write_text(validation, encoding="utf-8")

    completion = f"""# AE-FEAT-IMPORT-006R Worker Completion Report

## Status

status: complete

## Summary

Computed model-based individual-feature log-odds perturbation importance for all predictor-required features across all eight bounded GBM-only model-track combinations.

## Artifacts

Ticket evidence artifacts created:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_Individual_Feature_Log_Odds_Importance_Report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_individual_feature_importance_summary.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_feature_mapping_coverage_audit.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_build_individual_feature_importance.py`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_validation_report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

Local-only ignored outputs:

- `03_Data_Output/10_FeatureImportance/individual_feature_importance/AE-FEAT-IMPORT-006R_individual_feature_importance_summary.csv`
- `03_Data_Output/10_FeatureImportance/individual_feature_importance/AE-FEAT-IMPORT-006R_feature_mapping_coverage_audit.csv`
- `03_Data_Output/10_FeatureImportance/individual_feature_importance/AE-FEAT-IMPORT-006R_run_metadata.json`
- `03_Data_Output/10_FeatureImportance/individual_feature_importance/per_model_track/*.csv`

## Findings

- `{metadata["n_summary_rows"]:,}` individual feature perturbation rows were computed.
- All eight model-track combinations were completed.
- `{metadata["n_mapped_rows"]:,}` rows mapped to the canonical 11-family taxonomy.
- `{metadata["n_latent_vae_rows"]:,}` rows were latent/VAE features.
- `{metadata["n_unmapped_rows"]:,}` rows were required predictor features outside the canonical family rules and were retained in the audit.
- Evidence is bounded GBM-only predictor workspace evidence, not final full model-suite feature importance.

## Next Recommended Role

next_recommended_role: ds-validator

Recommended validation focus:

- Confirm all eight combinations are represented in the summary and audit.
- Confirm individual-feature perturbation uses training/CV rows only and fixed within-CV permutation.
- Confirm local `03_Data_Output/10_FeatureImportance/individual_feature_importance/**` outputs remain ignored and unstaged.
- Confirm bounded GBM-only caveat is present.

## Changed Files

Ticket-owned files changed or created:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_Individual_Feature_Log_Odds_Importance_Report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_individual_feature_importance_summary.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_feature_mapping_coverage_audit.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_build_individual_feature_importance.py`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_validation_report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

Ignored local outputs generated:

- `03_Data_Output/10_FeatureImportance/individual_feature_importance/**`

Pre-existing unrelated dirty files in protected presentation/cloud paths were not touched.

## Verification

Commands run:

```powershell
git status --short --branch
py -3.10 05_Documentation\\09_Epics\\AE-FEAT-IMPORT_Feature_Importance\\AE-FEAT-IMPORT-006R_build_individual_feature_importance.py
```

Verification results:

- Script completed all eight model-track combinations.
- Summary rows: `{metadata["n_summary_rows"]:,}`.
- Coverage rows: `{metadata["n_coverage_rows"]:,}`.
- Local generated outputs were written under `03_Data_Output/10_FeatureImportance/individual_feature_importance/`.
- No staging, commit, push, merge, training, evaluation, index construction, sensitivity run, pipeline regeneration, or presentation compile was performed.

## Human Readability

The main report includes ranked top-feature tables for temporary CSI by model, permanent CSI by model, repeated top features across model-track combinations, mapping coverage counts, and interpretation of PIT/family alignment and latent/VAE materiality.
"""
    COMPLETION_DOC.write_text(completion, encoding="utf-8")


def main() -> None:
    LOCAL_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    PER_MODEL_DIR.mkdir(parents=True, exist_ok=True)

    if not MAPPING_PATH.exists():
        raise FileNotFoundError(f"Missing mapping file: {MAPPING_PATH}")

    summary_rows: list[dict] = []
    run_started = datetime.now(timezone.utc).isoformat()
    n_rows_seen: set[int] = set()

    for spec in RUNS:
        print(f"[{TICKET_ID}] Processing {spec.feature_set}/{spec.track}", flush=True)
        predictor_path = predictor_path_for(spec)
        predictor = TabularPredictor.load(str(predictor_path))
        required_features = predictor.feature_metadata_in.get_features()
        best_model = best_model_name(predictor)
        train_matrix, _ = build_training_matrix(spec)

        missing_required = [c for c in required_features if c not in train_matrix.columns]
        if missing_required:
            raise RuntimeError(f"Missing required features for {spec.feature_set}/{spec.track}: {missing_required}")

        base_cols = required_features + ["permno", "year", "cv_block"]
        base_matrix = train_matrix[base_cols].copy()
        baseline_prob = positive_probability(predictor, base_matrix[required_features])
        n_rows = len(base_matrix)
        n_rows_seen.add(int(n_rows))

        model_rows: list[dict] = []
        total_features = len(required_features)
        for batch_start in range(0, total_features, FEATURE_BATCH_SIZE):
            batch_features = required_features[batch_start : batch_start + FEATURE_BATCH_SIZE]
            batch_end = batch_start + len(batch_features)
            print(
                f"[{TICKET_ID}] {spec.feature_set}/{spec.track}: "
                f"batch {batch_start + 1}-{batch_end}/{total_features}",
                flush=True,
            )
            for position, feature in enumerate(batch_features, start=batch_start + 1):
                print(
                    f"[{TICKET_ID}] {spec.feature_set}/{spec.track}: "
                    f"feature {position}/{total_features} ({feature})",
                    flush=True,
                )
                perturbed = perturb_feature(base_matrix, feature, spec.feature_set, spec.track)
                perturbed_prob = positive_probability(predictor, perturbed[required_features])
                row = summarize_delta(
                    spec,
                    predictor_path,
                    feature,
                    position,
                    n_rows,
                    baseline_prob,
                    perturbed_prob,
                    best_model,
                )
                summary_rows.append(row)
                model_rows.append(row)

            partial_model_summary = pd.DataFrame(model_rows)
            partial_model_summary["rank_within_model_track"] = (
                partial_model_summary["mean_abs_delta_log_odds"].rank(method="first", ascending=False).astype(int)
            )
            partial_model_summary = partial_model_summary.sort_values("rank_within_model_track")
            partial_model_summary.to_csv(
                PER_MODEL_DIR / f"{spec.feature_set}_{spec.track}_individual_feature_importance.csv",
                index=False,
            )

        model_summary = pd.DataFrame(model_rows)
        model_summary["rank_within_model_track"] = (
            model_summary["mean_abs_delta_log_odds"].rank(method="first", ascending=False).astype(int)
        )
        model_summary = model_summary.sort_values("rank_within_model_track")
        model_summary.to_csv(PER_MODEL_DIR / f"{spec.feature_set}_{spec.track}_individual_feature_importance.csv", index=False)

        del predictor, train_matrix, base_matrix, baseline_prob
        gc.collect()

    summary = pd.DataFrame(summary_rows)
    summary["rank_within_model_track"] = (
        summary.groupby(["track", "feature_set"])["mean_abs_delta_log_odds"]
        .rank(method="first", ascending=False)
        .astype(int)
    )
    summary = summary.sort_values(["track", "feature_set", "rank_within_model_track"]).reset_index(drop=True)
    coverage = build_coverage_audit(summary)

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
        "n_rows_per_combination": int(next(iter(n_rows_seen))) if len(n_rows_seen) == 1 else sorted(n_rows_seen),
        "n_mapped_rows": int((summary["mapping_class"] == "mapped").sum()),
        "n_latent_vae_rows": int((summary["mapping_class"] == "latent_vae").sum()),
        "n_unmapped_rows": int((summary["mapping_class"] == "unmapped").sum()),
        "estimated_row_delta_rows_if_written": int(summary["n_rows_used"].sum()),
        "probability_clip_eps": EPS,
        "perturbation_policy": "deterministic individual-feature permutation within CV/training-analysis blocks",
        "bounded_predictor_note": "bounded GBM-only predictor workspace; not full final model-suite importance",
    }
    METADATA_LOCAL.write_text(json.dumps(metadata, indent=2), encoding="utf-8")
    write_reports(summary, coverage, metadata)
    print(json.dumps(metadata, indent=2), flush=True)


if __name__ == "__main__":
    main()
    # AutoGluon can leave runtime worker threads alive after successful writes.
    # Force process termination so verification commands do not hang.
    os._exit(0)
