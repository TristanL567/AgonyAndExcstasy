"""
AE-FEAT-IMPORT-004R family-level log-odds perturbation importance.

Loads the bounded GBM-only AutoGluon predictors prepared in
03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm
and computes model-response perturbation importance on training/CV-analysis
rows only.
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


TICKET_ID = "AE-FEAT-IMPORT-004R"
RUN_ID = "family_log_odds_rebuild_20260602_gbm"
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
LOCAL_OUTPUT_DIR = ROOT / "03_Data_Output" / "10_FeatureImportance" / "family_importance"
ROW_DELTA_DIR = LOCAL_OUTPUT_DIR / "row_deltas"
SUMMARY_DOC = DOC_DIR / f"{TICKET_ID}_family_importance_summary.csv"
UNMAPPED_DOC = DOC_DIR / f"{TICKET_ID}_unmapped_feature_audit.csv"
SUMMARY_LOCAL = LOCAL_OUTPUT_DIR / f"{TICKET_ID}_family_importance_summary.csv"
UNMAPPED_LOCAL = LOCAL_OUTPUT_DIR / f"{TICKET_ID}_unmapped_feature_audit.csv"
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


def permute_family(
    base: pd.DataFrame,
    family_features: list[str],
    feature_set: str,
    track: str,
    family: str,
) -> pd.DataFrame:
    perturbed = base.copy()
    blocks = perturbed["cv_block"].to_numpy()
    for feature in family_features:
        values = perturbed[feature].to_numpy(copy=True)
        for block in np.unique(blocks):
            idx = np.flatnonzero(blocks == block)
            if len(idx) <= 1:
                continue
            rng = np.random.default_rng(stable_seed(feature_set, track, family, feature, str(block)))
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
    family_id: str,
    family_name: str,
    is_canonical_11: bool,
    result_status: str,
    family_features: list[str],
    n_rows: int,
    baseline_prob: np.ndarray,
    perturbed_prob: np.ndarray | None,
    best_model: str,
) -> dict:
    if perturbed_prob is None:
        return {
            "ticket_id": TICKET_ID,
            "run_id": RUN_ID,
            "feature_set": spec.feature_set,
            "track": spec.track,
            "feature_family_id": family_id,
            "feature_family": family_name,
            "is_canonical_11": is_canonical_11,
            "result_status": result_status,
            "n_features_in_family": len(family_features),
            "n_rows_used": n_rows,
            "baseline_mean_probability": float(np.mean(baseline_prob)) if len(baseline_prob) else math.nan,
            "perturbed_mean_probability": math.nan,
            "mean_abs_delta_log_odds": math.nan,
            "mean_signed_delta_log_odds": math.nan,
            "median_abs_delta_log_odds": math.nan,
            "p90_abs_delta_log_odds": math.nan,
            "probability_clip_eps": EPS,
            "perturbation_policy": "deterministic_per_feature_permutation_within_cv_block",
            "permutation_strata": "initial_train_1993_2001;cv_fold2_2002_2006;cv_fold3_2007_2010;cv_fold4_holdout_2011_2015",
            "perturbation_seed": PERTURBATION_SEED,
            "predictor_path": str(predictor_path.relative_to(ROOT)),
            "best_model": best_model,
            "bounded_predictor_note": "bounded GBM-only predictor workspace; not full final model-suite importance",
            "group_members": ";".join(family_features),
        }

    delta = logit(baseline_prob) - logit(perturbed_prob)
    abs_delta = np.abs(delta)
    return {
        "ticket_id": TICKET_ID,
        "run_id": RUN_ID,
        "feature_set": spec.feature_set,
        "track": spec.track,
        "feature_family_id": family_id,
        "feature_family": family_name,
        "is_canonical_11": is_canonical_11,
        "result_status": result_status,
        "n_features_in_family": len(family_features),
        "n_rows_used": n_rows,
        "baseline_mean_probability": float(np.mean(baseline_prob)),
        "perturbed_mean_probability": float(np.mean(perturbed_prob)),
        "mean_abs_delta_log_odds": float(np.mean(abs_delta)),
        "mean_signed_delta_log_odds": float(np.mean(delta)),
        "median_abs_delta_log_odds": float(np.median(abs_delta)),
        "p90_abs_delta_log_odds": float(np.quantile(abs_delta, 0.9)),
        "probability_clip_eps": EPS,
        "perturbation_policy": "deterministic_per_feature_permutation_within_cv_block",
        "permutation_strata": "initial_train_1993_2001;cv_fold2_2002_2006;cv_fold3_2007_2010;cv_fold4_holdout_2011_2015",
        "perturbation_seed": PERTURBATION_SEED,
        "predictor_path": str(predictor_path.relative_to(ROOT)),
        "best_model": best_model,
        "bounded_predictor_note": "bounded GBM-only predictor workspace; not full final model-suite importance",
        "group_members": ";".join(family_features),
    }


def write_row_deltas(
    spec: RunSpec,
    family_id: str,
    family_name: str,
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
            "feature_family_id": family_id,
            "feature_family": family_name,
            "permno": matrix["permno"].to_numpy(),
            "year": matrix["year"].to_numpy(),
            "cv_block": matrix["cv_block"].to_numpy(),
            "baseline_probability": baseline_prob,
            "perturbed_probability": perturbed_prob,
            "delta_log_odds": delta,
            "abs_delta_log_odds": np.abs(delta),
        }
    )
    out_path = ROW_DELTA_DIR / f"{spec.feature_set}_{spec.track}_{family_id}_{family_name}_row_deltas.parquet"
    out.to_parquet(out_path, index=False)


def main() -> None:
    LOCAL_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    ROW_DELTA_DIR.mkdir(parents=True, exist_ok=True)

    mapping = pd.read_csv(MAPPING_PATH)
    canonical = [
        (str(row.family_id), row.feature_family)
        for row in mapping.sort_values("family_id").itertuples(index=False)
    ]

    summary_rows: list[dict] = []
    unmapped_rows: list[dict] = []
    run_started = datetime.now(timezone.utc).isoformat()

    for spec in RUNS:
        print(f"[{TICKET_ID}] Processing {spec.feature_set}/{spec.track}", flush=True)
        predictor_path = (
            PREDICTOR_ROOT
            / "3_Modelling_Results"
            / "Necessary"
            / spec.track_folder
            / "AutoGluon"
            / spec.predictor_subdir
            / "ag_predictor"
        )
        predictor = TabularPredictor.load(str(predictor_path))
        required_features = predictor.feature_metadata_in.get_features()
        best_model = best_model_name(predictor)

        train_matrix, _ = build_training_matrix(spec)
        missing_required = [c for c in required_features if c not in train_matrix.columns]
        if missing_required:
            raise RuntimeError(f"Missing required features for {spec.feature_set}/{spec.track}: {missing_required}")

        canonical_groups: dict[tuple[str, str], list[str]] = {(fid, fam): [] for fid, fam in canonical}
        latent_features: list[str] = []
        unmapped_features: list[str] = []

        for feature in required_features:
            if feature in LATENT_COLS:
                latent_features.append(feature)
                continue
            family_id, family_name = map_canonical_family(feature)
            if family_id is None or family_name is None:
                unmapped_features.append(feature)
                continue
            canonical_groups[(family_id, family_name)].append(feature)

        for feature in latent_features:
            unmapped_rows.append(
                {
                    "ticket_id": TICKET_ID,
                    "run_id": RUN_ID,
                    "feature_set": spec.feature_set,
                    "track": spec.track,
                    "feature_name": feature,
                    "audit_class": "latent_feature_outside_canonical_11",
                    "action": "computed_as_vae_latent_features_block",
                    "note": "VAE latent dimensions do not map to the 11 raw/engineered families.",
                }
            )
        for feature in unmapped_features:
            unmapped_rows.append(
                {
                    "ticket_id": TICKET_ID,
                    "run_id": RUN_ID,
                    "feature_set": spec.feature_set,
                    "track": spec.track,
                    "feature_name": feature,
                    "audit_class": "unmapped_required_predictor_feature",
                    "action": "computed_as_unmapped_features_block",
                    "note": "Required predictor feature did not match the canonical 11-family mapping rules.",
                }
            )

        base_cols = required_features + ["permno", "year", "cv_block"]
        base_matrix = train_matrix[base_cols].copy()
        prediction_base = base_matrix[required_features]
        baseline_prob = positive_probability(predictor, prediction_base)
        n_rows = len(base_matrix)

        for family_id, family_name in canonical:
            family_features = canonical_groups[(family_id, family_name)]
            if not family_features:
                summary_rows.append(
                    summarize_delta(
                        spec,
                        predictor_path,
                        family_id,
                        family_name,
                        True,
                        "no_features_in_predictor",
                        family_features,
                        n_rows,
                        baseline_prob,
                        None,
                        best_model,
                    )
                )
                continue
            perturbed = permute_family(base_matrix, family_features, spec.feature_set, spec.track, family_name)
            perturbed_prob = positive_probability(predictor, perturbed[required_features])
            summary_rows.append(
                summarize_delta(
                    spec,
                    predictor_path,
                    family_id,
                    family_name,
                    True,
                    "computed",
                    family_features,
                    n_rows,
                    baseline_prob,
                    perturbed_prob,
                    best_model,
                )
            )
            write_row_deltas(spec, family_id, family_name, base_matrix, baseline_prob, perturbed_prob)

        if latent_features:
            family_id = "latent_block"
            family_name = "vae_latent_features"
            perturbed = permute_family(base_matrix, latent_features, spec.feature_set, spec.track, family_name)
            perturbed_prob = positive_probability(predictor, perturbed[required_features])
            summary_rows.append(
                summarize_delta(
                    spec,
                    predictor_path,
                    family_id,
                    family_name,
                    False,
                    "computed",
                    latent_features,
                    n_rows,
                    baseline_prob,
                    perturbed_prob,
                    best_model,
                )
            )
            write_row_deltas(spec, family_id, family_name, base_matrix, baseline_prob, perturbed_prob)

        if unmapped_features:
            family_id = "unmapped"
            family_name = "unmapped_features"
            perturbed = permute_family(base_matrix, unmapped_features, spec.feature_set, spec.track, family_name)
            perturbed_prob = positive_probability(predictor, perturbed[required_features])
            summary_rows.append(
                summarize_delta(
                    spec,
                    predictor_path,
                    family_id,
                    family_name,
                    False,
                    "computed",
                    unmapped_features,
                    n_rows,
                    baseline_prob,
                    perturbed_prob,
                    best_model,
                )
            )
            write_row_deltas(spec, family_id, family_name, base_matrix, baseline_prob, perturbed_prob)

        del predictor, train_matrix, base_matrix
        gc.collect()

    summary = pd.DataFrame(summary_rows)
    unmapped = pd.DataFrame(unmapped_rows)

    sort_cols = ["track", "feature_set", "is_canonical_11", "mean_abs_delta_log_odds"]
    summary = summary.sort_values(sort_cols, ascending=[True, True, False, False], na_position="last")
    summary.to_csv(SUMMARY_DOC, index=False)
    summary.to_csv(SUMMARY_LOCAL, index=False)
    unmapped.to_csv(UNMAPPED_DOC, index=False)
    unmapped.to_csv(UNMAPPED_LOCAL, index=False)

    metadata = {
        "ticket_id": TICKET_ID,
        "run_id": RUN_ID,
        "started_utc": run_started,
        "completed_utc": datetime.now(timezone.utc).isoformat(),
        "root": str(ROOT),
        "predictor_root": str(PREDICTOR_ROOT.relative_to(ROOT)),
        "local_output_dir": str(LOCAL_OUTPUT_DIR.relative_to(ROOT)),
        "n_summary_rows": int(len(summary)),
        "n_unmapped_audit_rows": int(len(unmapped)),
        "n_model_track_combinations": len(RUNS),
        "canonical_family_rows_attempted": int(len(RUNS) * len(canonical)),
        "probability_clip_eps": EPS,
        "perturbation_policy": "deterministic per-feature permutation within CV/training-analysis blocks",
        "bounded_predictor_note": "bounded GBM-only predictor workspace; not full final model-suite importance",
    }
    METADATA_LOCAL.write_text(json.dumps(metadata, indent=2), encoding="utf-8")
    print(json.dumps(metadata, indent=2), flush=True)


if __name__ == "__main__":
    main()
    # AutoGluon can leave runtime worker threads alive after successful writes.
    # Force process termination so verification commands do not hang.
    os._exit(0)
