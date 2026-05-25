# Data Paths Reference

**Repository root:** `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy`

This document maps every data artifact referenced in the FinalPresentation (and the broader thesis pipeline) to its exact location in the AgonyAndExcstasy repository. Use this as a lookup table when writing slides, the thesis chapter, or any new analysis script.

**Layout convention:**
- `01_Code/` — pipeline scripts (R + Python)
- `02_Data_Input/` — external inputs + derived pipeline data
- `03_Data_Output/` — results, organised by analysis category (Descriptive / Robustness / Modelling / IndexConstruction)
- `04_Research/`, `05_Documentation/`, `06_Presentations/` — references, docs, deliverables

**Track-folder naming:**
The code variable `RESPONSE_TRACK = "dynamic_csi"` maps to the on-disk folder `temporary_csi/`. `permanent_csi` is the same name in both. Everywhere below, `{track}` = `temporary_csi` or `permanent_csi`.

---

## 1. Raw inputs (Methodology section: Dataset slide)

Pulled live by scripts 01–04 from WRDS (CRSP, Compustat) and FRED. Cached on disk for re-runs without re-querying.

### CRSP

| Variable | Path | Necessity |
|---|---|---|
| Universe (security info, share types) | `02_Data_Input/01_CRSP/Necessary/universe.rds` | Necessary — read by 05A, 05B, 05_CSI_Label, 06_Merge, 13_*, 14c |
| Universe (raw WRDS pull) | `02_Data_Input/01_CRSP/Additional/universe_raw.rds` | Additional — needed only to re-run 01_Universe |
| Monthly prices (processed) | `02_Data_Input/01_CRSP/Necessary/prices_monthly.rds` | Necessary — read by 05*, 06*, 11*, 13* (returns, market cap, wealth paths) |
| Daily prices (raw) | `02_Data_Input/01_CRSP/Additional/prices_daily_raw.rds` | Additional (694 MB) — intermediate to derive monthly/weekly |
| Monthly prices (raw) | `02_Data_Input/01_CRSP/Additional/prices_monthly_raw.rds` | Additional — internal to 02_Prices |
| Weekly prices | `02_Data_Input/01_CRSP/Additional/prices_weekly.rds` | Additional — not currently consumed by scripts 05+ |
| Delisting (raw) | `02_Data_Input/01_CRSP/Necessary/delisting_raw.rds` | Necessary — used directly by 05A (terminal-failure path, codes 572/573/574), 05B (tier i), 13b |
| CRSP field dictionary | `02_Data_Input/01_CRSP/Additional/Fields_Abbreviations.xlsx` | Reference only |

### Compustat

| Variable | Path | Necessity |
|---|---|---|
| Annual fundamentals (processed) | `02_Data_Input/02_Compustat/Necessary/fundamentals.rds` | Necessary — read by 06_Merge, 11B_IndexConstruction_Quality |
| Annual fundamentals (raw) | `02_Data_Input/02_Compustat/Additional/fundamentals_raw.rds` | Additional — intermediate to 03_Fundamentals |
| CCM link (permno↔gvkey) | `02_Data_Input/02_Compustat/Additional/ccm_link_raw.rds` | Additional — internal to 03 (link baked into fundamentals.rds) |
| Compustat field abbreviations | `02_Data_Input/02_Compustat/Additional/Fields_Abbreviations.xlsx` | Reference |
| Compustat field documentation | `02_Data_Input/02_Compustat/Additional/Fields_Documentation.xlsx` | Reference |

### Macro (FRED)

| Variable | Path | Necessity |
|---|---|---|
| Monthly macro panel | `02_Data_Input/03_FRED/Necessary/macro_monthly.rds` | Necessary — read by 06_Merge, 06B_Features (term spread, HY spread, VIX, recession, unemployment) |
| Macro (raw pull) | `02_Data_Input/03_FRED/Additional/macro_raw.rds` | Additional — internal to 04_Macro |

### CRSP-like Index Replication (Dataset slide: "Total Market / Large / Mid / Small")

Produced by `01_Code/index_construction_crsp/01_construct_crsp_like_four_indices.R`. Consumed by `11C_IndexConstruction_Revised.R` and `11D_IndexConstruction_Optimal03b.R` via `PATH_CRSP_INDEX_DIR <- DIR_IDXREP_NEC`.

| Variable | Path | Necessity |
|---|---|---|
| Quarterly constituents (RDS) | `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds` | Necessary — read by 11C/11D |
| Monthly index returns (RDS) | `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_returns_monthly.rds` | Necessary — read by 11C/11D |
| Quarterly summary (CSV) | `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_summary_quarterly.csv` | Necessary — read by 11C/11D |
| CSV mirrors + company assignments + top10 weights + diagnostics | `02_Data_Input/04_Index_Replication/Additional/` | Additional — for human inspection, not consumed by code |

---

## 2. Pipeline checkpoints (derived data, written by 05A/05B/06/06B/08/08B)

### CSI labels — Temporary-CSI (Methodology I + II slides)

All under `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/`.

| File | What it is | Slide reference |
|---|---|---|
| `csi_events_base.rds` (9.6 MB) | Monthly C/M/T trigger events for the BASE parameter combination (C=-80%, M=-20%, T=18). Includes the 572–574 terminal-failure path when `CSI_USE_TERMINAL_FAILURE_INDICATORS=TRUE`. | The "8,369 confirmed event rows" cited on the "Applying the classification to CRSP" slide |
| `csi_events_all_grid.rds` (264 MB) | Monthly events for the full 27-point C×M×T grid (C ∈ {-60%, -80%, -90%}, M ∈ {0%, -20%, -30%}, T ∈ {12, 18, 24}) | Robustness II slide "Do CSI-firms recover?" bar chart |
| `csi_state_monthly_base.rds` (525 KB) | Monthly resolved-state vector for the base parameters | — |
| `labels_base.rds` (100 KB) | Annual labels y_{i,t} for the base parameter set | — |
| `labels_all_grid.rds` (3 MB) | Annual labels for every grid point (compact aggregated form) | — |
| `csi_diagnostics.rds`, `csi_event_diagnostics.rds` | Self-checks / diagnostics | — |

### CSI labels — Permanent-CSI (Methodology III slide)

All under `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Labels/`.

| File | What it is | Slide reference |
|---|---|---|
| `permanent_loss_events_base.rds` (10 MB) | Monthly PCL events (tier i delisting within 36 months + tier ii non-recovery within 5 years), base parameters | "Permanent-CSI" methodology flowchart |
| `permanent_loss_events_all_grid.rds` (288 MB) | PCL events across the full grid | — |
| `labels_permanent_loss.rds` (727 KB) | Annual PCL labels y^{perm}_{i,t} | "6,344 positives across 626,080 firm-years (1.01%)" cited on the Methodology III slide |
| `labels_model_ready.rds` (727 KB) | Model-ready PCL labels (same content, aliased target name) | Consumed by 09C for permanent-csi training |
| `permanent_loss_diagnostics.rds` | Diagnostics | — |

### Features (Modelling I slide — Base / Expanded / VAE / Expanded+VAE)

All under `02_Data_Input/05_PipelineResults/Necessary/{track}/Features/`.

| File | What it is | Maps to slide feature-set key |
|---|---|---|
| `features_fund.rds` (~346 MB) | Fundamentals + macro panel (no price-derived features) | "Base Dataset" |
| `features_raw.rds` (~317 MB temp / ~367 MB perm) | Full engineered feature set: ~463 features (fund + macro + price-derived + roll/accel/momentum) | "Expanded Dataset" |
| `features_latent_fund.parquet` (~50 MB) | VAE β-VAE latent space of `features_fund`, 24 dims | Source for "Latent Dataset (VAE)" rows trained on fund |
| `features_latent_raw.parquet` (~51 MB) | VAE latent space of `features_raw`, 24 dims | "Latent Dataset (VAE)" |
| `features_raw_plus_latent.parquet` (~437 MB temp / ~506 MB perm) | `features_raw` ⊕ `features_latent_raw` concatenated | "Expanded Dataset + VAE" |
| `splits.rds` (12 MB) | Train/test/OOS row assignment + cross-validation fold IDs | Drives the temporal-split chart |
| `split_labels_oos.parquet`, `split_labels_oot.parquet` | Boundary label labels for evaluation | — |

### Panel

`02_Data_Input/05_PipelineResults/Necessary/{track}/Panel/panel_raw.rds`
- **Temporary** track: **empty in MT — flagged with `README_EMPTY.md`** (run `06_Merge.R` with `RESPONSE_TRACK=dynamic_csi` to produce)
- **Permanent** track: present (41 MB) — output of 06_Merge

### Legacy archives (Additional)

- `02_Data_Input/05_PipelineResults/Additional/legacy_flat_pre_track_split/` — March 2026 pre-track-split snapshots of Labels, Features, Panel (~660 MB)
- `02_Data_Input/05_PipelineResults/Additional/_archive_pre_03b_snapshot/` — May 2026 pre-fork snapshot of the temporary-CSI tree (1.3 GB)
- `02_Data_Input/05_PipelineResults/Additional/legacy_flat_pre_track_split/Labels/labels_bucket.rds`, `labels_structural.rds` — legacy experimental targets (1.2 MB, 0.9 MB)

---

## 3. Modelling results (Modelling II + III slides)

Per-track AutoGluon and XGBoost outputs under `03_Data_Output/3_Modelling_Results/Necessary/{track}/`.

### AutoGluon predictions, leaderboards, CV results

Under `03_Data_Output/3_Modelling_Results/Necessary/{track}/AutoGluon/{model_key}/`.

Active model variants per track (4):
- `ag_fund` — "Base Dataset" model (M1 legacy alias)
- `ag_raw` — "Expanded Dataset" model (M3 legacy alias) → **the best current temporary-CSI model**
- `ag_latent_raw` — "Latent Dataset (VAE)" model (M4 legacy alias)
- `ag_raw_plus_latent` — "Expanded Dataset + VAE" model

Per model directory, 8 files:

| File | Contents | Slide use |
|---|---|---|
| `ag_preds_test.parquet` | Predictions on the 2016–2019 test set | Modelling II/III tables: Test AP/AUC/R3 |
| `ag_preds_test_eval.parquet` | Test predictions with eval flags | Used to compute test metrics |
| `ag_preds_oos.parquet` | Predictions on 2020–2024 OOS | Index construction tables |
| `ag_preds_oos_eval.parquet` | OOS predictions with eval flags | — |
| `ag_preds_train_boundary.parquet` | Boundary-year predictions (excluded from AUC/AP per CSI label-shift rule) | — |
| `ag_cv_results.parquet` | Cross-validation results (3 expanding folds) | Modelling II/III tables: CV AP/AUC/R3 |
| `ag_leaderboard.csv` | AutoGluon ensemble leaderboard (which inner models won) | LightGBMLarge dominance discussion |
| `ag_eval_summary.json` | Compact eval summary JSON | — |

### XGBoost models + eval tables

Under `03_Data_Output/3_Modelling_Results/Necessary/{track}/XGBoost/`.

| File | Contents |
|---|---|
| `xgb_fund.rds`, `xgb_raw.rds`, `xgb_latent_raw.rds`, `xgb_raw_plus_latent.rds` | Trained XGBoost models per feature set |
| `xgb_eval_table.csv`, `xgb_raw_eval_table.csv` | CV + test evaluation tables (the XGB rows in the Modelling II/III tables) |

### VAE configs

Under `03_Data_Output/3_Modelling_Results/Necessary/{track}/VAE/{fund,raw}/vae_config.json` — architecture + hyperparameters used to train the β-VAE.

### Evaluation metrics

Under `03_Data_Output/3_Modelling_Results/Necessary/{track}/evaluation/`:

| File | Contents | Slide use |
|---|---|---|
| `evaluation_results.rds` | Headline eval table | — |
| `eval_performance_all.rds` | Per-model AP / AUC / R3 / Brier across CV / test / OOS | The Modelling II + III result tables |
| `eval_threshold_all.rds` | Calibrated thresholds (FPR1, FPR3, Youden J) per model from CV | Index Construction I slide: "FPR 1%, FPR 3%, Youden J" |
| `eval_by_year_all.rds` | Year-level AP/AUC breakdown | OOS year-level breakdown chapter in ML_Performance report |

### Shared modelling metadata

Under `03_Data_Output/3_Modelling_Results/Necessary/shared/`:

| Path | Contents |
|---|---|
| `settings/autogluon_model_hyperparameters_summary.csv` | Hyperparameters of every fitted AutoGluon child model (M1/M3/M4/Expanded+VAE × 2 tracks) |
| `settings/autogluon_weighted_ensemble_weights.csv` | Ensemble weights (LightGBMLarge, XGBoost, etc.) used by each AG predictor |
| `settings/{track}_ag_{model}_predictor_info_compact.json` | Compact `predictor.info()` dump per (track, model) |
| `settings/xgboost_model_hyperparameters_summary.csv` | XGB hyperparameters summary |
| `settings/{track}_xgb_{model}_settings.json` | XGB per-(track,model) hyperparameters |
| `ag_predictor_metadata/{track}/{model}/ag_predictor_metadata.json` | Predictor-level metadata for ag_fund/ag_raw/ag_latent_raw/ag_raw_plus_latent |
| `ag_artifact_summaries/{track}__ag_{model}__{ag_cv_fold2,3,4 / ag_predictor}/` | Per-fold `best_model.txt` + `artifact_manifest.tsv` (32 subdirs total) |
| `feature_importance/{M1_fund, M3_raw, … 12 models}/ag_feature_importance.csv` | Per-model SHAP-derived feature importance |
| `cross_model_comparison_figures/` | 8 PNGs: agreement and AP/AUC/FPR bar comparisons across tracks |

### Modelling figures

Per-track under `03_Data_Output/3_Modelling_Results/Necessary/{track}/figures/`:
- `comparison/` — within-track AP/AUC/agreement (6 PNGs)
- `csi/` — CSI-track summary (calibration, PR curves, ROC, score distribution, year-level AP) + per-model dirs `m1/`, `m3/`, `m4/` with calibration plots

### Modelling Additional / legacy

`03_Data_Output/3_Modelling_Results/Additional/`:
- `legacy_12_model_runs/` — March-era 12-model VastAI runs (M1–M4, B1–B4, S1–S4 across CSI / bucket / structural targets)
- `autoencoder_diagnostics/` — VAE training curves + latent-space plots (6 PNGs)
- `run_logs/` — VastAI training run audit trail

**Note:** Trained AutoGluon `predictor.pkl` binaries (44.7 GB total in MT) were intentionally NOT transferred. They are regenerable by running `09C_AutoGluon.py`.

---

## 4. Robustness results (Robustness I + II slides)

Per-track under `03_Data_Output/2_Robustness_Checks/Necessary/{track}/`.

### Temporary-CSI robustness (Robustness I + II)

`03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/`:

| File | Contents | Slide reference |
|---|---|---|
| `E_delisting_detection_by_grid.{csv,rds}` | Detection rate of CRSP 572–574 delistings by each C×M×T grid point | "Robustness I: Do CSI-firms go bankrupt?" — the 24.0% confirmed-CSI-only baseline |
| `E_adverse_delisting_code_distribution.{csv,rds}` | Distribution of CRSP delisting codes within CSI events | — |
| `E_adverse_delisting_detection_firm_detail.{csv,rds}` | Per-firm detail of missed/detected adverse delistings | — |
| `F_bankruptcy_detection_by_grid.{csv,rds}` | Historical bankruptcy-detection summary per grid point before the revised overlap audit | Historical Methodology II audit only; not the current revised overlap source |
| `F_bankruptcy_detection_firm_detail.{csv,rds}` | Per-firm bankruptcy detection detail | — |
| `G_old_csi_base_recovery_bucket_event_summary.csv` | 5-year recovery bucket breakdown for the base C/M/T parameters (no_recovery / recovery_to_M / recovery_to_C / full_recovery) | "Robustness II: Do CSI-firms recover?" base-row bar |
| `G_old_csi_base_recovery_bucket_firm_summary.csv` | Same at firm level (deduplicated) | "Robustness II" firm counts column |
| `G_old_csi_recovery_buckets_all_grid_event_summary.csv` | Recovery-bucket breakdown across all 27 grid points | The full 5-row Robustness II bar chart |
| `G_old_csi_recovery_buckets_all_grid_firm_summary.csv` | Same at firm level (the "5,642 firms" base row, "3,129", "4,231", "7,505", "10,253" alternate rows) | — |
| `G_old_csi_recovery_buckets_all_grid_detail.{rds,csv}` | Full firm-level long-form detail | — |
| `G_revised_csi_event_counts_by_grid.csv` | Revised methodology event counts (with 572–574 path) | "Methodology II" event counts |
| `terminal_failure_additive_summary_labels.csv`, `_events.csv` | Annual / event summaries of how many positives the 572–574 path adds | — |
| `terminal_failure_*_by_label_year.csv`, `_by_event_year.csv`, `_panel.csv` (6 files total) | Yearly granularity of the additive vs override comparison | — |

`03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/figures/` (26 PNGs):
- `csi_validity/` — base trigger-month, terminal-vs-peak, late-recovery heatmap (4 PNGs)
- `partA/` — crisis timing, Jaccard heatmap, AP per param, AP heatmap (4 PNGs)
- `partB/` — structural quadrants, bucket terminal-loser vs phoenix distributions, feature importance, trees (6 PNGs)
- `partD/` — bucket score distribution (1 PNG)
- `partE/` — concentrated portfolio cumulative/drawdown/annual returns (5 PNGs)
- `partF/` — threshold sensitivity, label stability, switch rate by year (3 PNGs)
- `partG/` — CSI phoenix CAGR distribution, variant prevalence (2 PNGs)

### Permanent-CSI extensions (14c, 14d, 14e)

Under `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/`:

| Subfolder | Contents |
|---|---|
| `14c_permanent_capital_loss/` | 2 PNGs (PCL response event count heatmap, survival heatmap) + 1 RDS (response_feature_alignment) |
| `14d_dead_firm_characteristics/` | 2 PNGs (core characteristics, top features) + 1 CSV + 1 RDS (dead_firm_group_counts) |
| `14e_price_distress_response_labels/` | 2 PNGs (label-count heatmap, non-survival heatmap) + CSVs including `temporary_csi_crsp_default_overlap_summary.csv` | Current Methodology II revised overlap source: 629 CRSP 572-574 firms, 545 detected, 84 missed, 86.65% detection; `temporary_csi_missed_574_*` diagnose only the narrower 574 subset |

### Cross-track shared robustness summaries

`03_Data_Output/2_Robustness_Checks/Necessary/shared/` — 7 RDS files:
- `robust_grid_performance.rds` — grid-level AP performance aggregated
- `robust_recovery_classifier.rds` — recovery-classifier validation
- `robust_tiered_results.rds` — tiered-strategy robustness
- `robust_index_returns.rds`, `robust_conc_returns.rds`, `robust_conc_performance.rds` — robustness portfolio results
- `robust_bucket_sensitivity.rds` — sensitivity to bucket-definition parameters

### Robustness Additional / logs

`03_Data_Output/2_Robustness_Checks/Additional/logs/` — VastAI run logs for the 13c old-methodology recovery-bucket grid scan.

---

## 5. Index construction results (Index Construction slides + Results tables)

Per-track under `03_Data_Output/4_IndexConstruction_Results/Necessary/{track}/`.

### Per-track 11d optimal-03b run

`03_Data_Output/4_IndexConstruction_Results/Necessary/{track}/11d_index_optimal03b_ag_raw_20260517_203745/` — 12 files per track:

| File | Contents | Slide reference |
|---|---|---|
| `error_cost_decomposition_by_crsp_universe.{csv,rds}` | FP / FN / TP / TN cost decomposition per universe | "Index Construction Results: Temp CSI — Error Costs" + perm equivalent |
| `index_exclusion_summary_by_crsp_universe.{csv,rds}` | How many firms got excluded by universe + year | — |
| `index_performance_by_crsp_universe.{csv,rds}` | Geo ret / Sharpe / Max DD / ES per universe per strategy | "Index Construction Results: Temp/Perm CSI Performance" tables |
| `index_returns_by_crsp_universe.{csv,rds}` | Monthly return time series per strategy | Source for cumulative-return chart |
| `index_thresholds_by_crsp_universe.{csv,rds}` | Calibrated FPR1 / FPR3 / Youden-J thresholds used per universe | Index Construction I slide |
| `index_weights_by_crsp_universe.rds` | Time-varying portfolio weights per strategy | — |
| `run_status.csv` | Run audit metadata | — |

### Per-track legacy 11 / 11C outputs

`03_Data_Output/4_IndexConstruction_Results/Necessary/{track}/11_index/`:
- `index_opt_thresholds.rds`, `index_thresholds.csv` — earlier-run threshold tables (pre-11d)
- **Temporary track also has** `index_performance_train_test_oos_wide.csv`
- **Permanent track also has** `index_exclusion_summary.rds`

### Per-track index figures

`03_Data_Output/4_IndexConstruction_Results/Necessary/{track}/figures/` — 2 PNGs each:
- `ag_raw_lockout_mw_cumulative.png` — cumulative market-weighted return of the lockout strategy
- `ag_raw_lockout_oos_sharpe.png` — OOS Sharpe ratio

### Shared index outputs (cross-track)

`03_Data_Output/4_IndexConstruction_Results/Necessary/shared/`:

| Path | Contents | Slide reference |
|---|---|---|
| `11c_index_revised_by_track_index/eight_bundles_20260516_152954/{permanent_csi,temporary_csi}/{total_market,large_cap,mid_cap,small_cap}/` | **The 8 bundles** the Index Construction II slide refers to. Each has `index_thresholds_raw_model.csv`, `oos_performance_summary.csv`, `README.txt`. | "Same exclusion rule, four universes" slide |
| `general_figures/general/` | Cross-strategy benchmark figures (benchmark_ew_cumulative) | — |
| `general_figures/{csi_track,bucket_track,structural_track,concentrated}/` | Per-track-style figures (exclusion-rate plots, etc.) | — |
| `benchmark_summaries/index_weights.rds` (11 MB) | Benchmark equal-weight weight matrix | — |
| `benchmark_summaries/index_returns.rds`, `index_performance.rds`, `index_exclusion_summary.rds`, `index_csi_avoidance.rds` | Benchmark monthly returns, performance metrics, CSI-avoidance counts | "Index Construction Results: Temp CSI Performance" benchmark rows |
| `final_strategy_summary/test_oos_best_strategy_by_index.csv` | The winning rule per universe (FPR3 / 5yr for Total, FPR1 / 1yr for Large, etc.) | "Test-OOS best rules by universe" table |
| `final_strategy_summary/test_oos_best_strategy_error_cost_decomposition.csv` | Same as 11d error-cost decomposition but for the chosen best rule per universe | "Temp CSI — Error Costs" table |
| `final_strategy_summary/test_oos_best_strategy_performance_and_error_cost_summary.csv` | Wide table combining performance + error-cost decomposition | Both Index Construction Results slides |
| `final_strategy_summary/validation_summary.csv` | Validation metadata | — |
| `final_strategy_summary/combined_thresholds_summary.csv` | Threshold summary from the permanent-CSI codex rerun | — |

### Index Additional

`03_Data_Output/4_IndexConstruction_Results/Additional/`:
- `quality_exclusion_summary.rds` — legacy quality-comparison strategy
- `intermediate_run_logs/11d_*/` — VastAI 11d run audit trails (descriptive stats, syntax check, stdout/stderr logs)

---

## 6. Descriptive statistics (Dataset slide: "Descriptive Statistics")

Per-track under `03_Data_Output/1_Descriptive_Statistics/Necessary/{track}/`.

### Temporary-CSI track

`03_Data_Output/1_Descriptive_Statistics/Necessary/temporary_csi/`:

| Path | Contents | Slide reference |
|---|---|---|
| `csi_response_stats/all_descriptives_by_track_response.csv` | Full descriptive stats by track × response (the source for the descriptive-stats table on the "Dataset: Descriptive Statistics" slide) | The "Sample × CSI × y × Obs. × Share × Firms × Median mcap × Ann. ret. × ROA" table |
| `csi_response_stats/market_cap_by_track_response.csv` | Market-cap deciles | — |
| `csi_response_stats/other_descriptives_by_track_response.csv` | Sales, assets, etc. | — |
| `csi_response_stats/overview_by_track_response.csv` | Compact track × response overview | — |
| `csi_prediction_response_stats/{descriptives,overview}_by_track_split_response.csv` | Descriptives split by train/test/OOS as well | The train/test/OOS-split counts on the "Applying the classification to CRSP" slide |
| `csi_prediction_response_stats_with_cv/{...}` | Same with CV-fold breakdown | — |
| `csi_revised_label_scaffold_stats/marketcap_usd_millions_cv_and_full.csv`, `other_median_descriptives_cv_and_full.csv`, `overview_counts_cv_and_full.csv`, `validation_positive_counts.csv`, `fiscal_mkvalt_usd_millions_diagnostic_cv_and_full.csv` | Diagnostic stats for the revised label scaffold | Verify the 8,341 / 8,647 / 626,080 figures |
| `csi_events_per_year.png` | CSI events per year bar chart | Companion to the classification-counts table |
| `csi_diagnostics.rds`, `csi_event_diagnostics.rds` | Self-check diagnostics | — |

### Permanent-CSI track

`03_Data_Output/1_Descriptive_Statistics/Necessary/permanent_csi/`:
- `pcl_events_per_year.png`
- `permanent_loss_diagnostics.rds`

### Shared descriptive figures

`03_Data_Output/1_Descriptive_Statistics/Necessary/shared/`:
- `05_labels_figures/` — bucket_*, structural_*, distribution + overlap (8 PNGs)
- `06_features_split_prevalence.png` — feature-set split prevalence

### Descriptive Additional

`03_Data_Output/1_Descriptive_Statistics/Additional/04_Charts_descriptive_statistics/` — 10 pre-pipeline PNGs from March 2026 (defaults_over_time, top_sectors, outcome_sample variants, failure_rate_over_time).

---

## 7. Code, documentation, and references

### Pipeline scripts

`01_Code/pipeline/` — the active R + Python pipeline (38 files), config.R, Paths.py, 00_Master.R. Entry point: `00_Master.R` (R) or `Paths.py` (Python self-check).

Subdirs:
- `01_Code/functions/` — R helpers (ComputeDrawdowns.R, getCatastrophicImplosions.R)
- `01_Code/subfunctions/` — additional R/Python helpers (filterFunds.R, getSector.R, 08B_Autoencoder.py callable module)
- `01_Code/shell/` — 6 VastAI / local launcher scripts (run_*.sh, run_*.ps1)
- `01_Code/index_construction_crsp/` — CRSP-MI replication scripts that produce the `02_Data_Input/04_Index_Replication/` content
- `01_Code/indices_spx/` — single S&P 500 constituents download script

### Documentation (this folder + siblings)

`05_Documentation/`:
- `01_Methodology/01_General/Necessary/General_Documentation.{md,pdf}` — overall methodology overview
- `01_Methodology/02_Input_Output/Necessary/Input_Output_Data_Methodology.{md,pdf}` — data lineage explainer
- `01_Methodology/03_Classification/Necessary/CSI_Classification_{Permanent,Temporary}_CSI_Methodology.{md,pdf}` + `Temporary_CSI_CRSP_Bankruptcy_Delisting_Insights.md` + `Temporary_CSI_Methodology_Change_Log_2026-05-17.md` — the canonical CSI classification methodology docs (companion text for the Methodology I / II / III slides)
- `01_Methodology/04_Feature_Engineering/Necessary/FeatureEngineering_Methodology.md` — feature engineering write-up
- `01_Methodology/05_Index_Construction/Necessary/index_construction_csi_error_costs.md` — index error-cost methodology (companion to the "Error Costs" slides)
- `02_Code_Pipeline/Necessary/Code_Pipeline_Documentation.{md,pdf}` — how to run the pipeline
- `02_Code_Pipeline/Necessary/ML_Performance_TristanLeiter_h11815352.{Rnw,tex,pdf}` — **mid-thesis methodology+diagnostics report** covering data prep / look-ahead bias fixes / VAE behaviour / XGBoost HPO / AutoGluon ensemble post-mortem
- `03_Results/01_General/Necessary/{code_validation_alignment_report,index_construction_error_cost_results,training_run_results}.md` — results write-ups
- `03_Results/02_Dynamic_CSI/Necessary/AutoGluon_Dynamic_CSI_Result_Manifest.{md,pdf}` + `Temporary_CSI_Paper_Benchmark_Comparison.{md,pdf}` + `Temporary_CSI_CRSP_Bankruptcy_Delisting_Insights.md` — the canonical references for the Modelling II "AG Expanded Dataset" results
- `03_Results/03_Index_Construction/{Necessary,Additional}/` — 11c source CSVs and 11d run manifests
- `03_Results/04_VastAI/Additional/` — VastAI transfer manifests
- `04_Robustness/01_Dynamic_CSI/Necessary/` — robustness reports (companion to Robustness I + II slides)
- `04_Robustness/02_Revised_Temporary_CSI_572_574/Necessary/` — revised methodology robustness reports
- `05_Strategy_Sheets/Necessary/Doc{1,2}_*.xlsx` — strategy-summary spreadsheets
- `06_Planning/Additional/` + `07_Thesis_Admin/Additional/` — planning notes and admin material

### Research / external sources

`04_Research/`:
- `01_CRSP/Necessary/CRSP_Market_Indexes_Methodology_Guide.pdf` + `CRSP_Index_Options_Review.md`
- `02_Index_Construction/Necessary/Russell3000/` — Russell 3000 construction methodology references
- `03_Label_Construction/Necessary/Label_Construction.docx` — label-construction working doc
- `04_Modelling/Necessary/Structural_Model_AutoGluon_Results.docx`
- `05_Papers/Necessary/ssrn-4951291.{pdf,txt}` — Tewari et al. (2024) CSI paper
- `06_Infrastructure/Additional/VastAI_Deployment_Guide.docx`

---

## 8. Known gaps and follow-ups

### Pre-existing pipeline gaps (require pipeline re-run, NOT a code fix)

These three files are referenced by `config.R` PATHs but were never produced under the temporary-CSI track in MT:

1. `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/labels_dynamic_csi.rds`
2. `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/labels_model_ready.rds`
3. `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Panel/panel_raw.rds` (folder contains `README_EMPTY.md`)

Fix: run `00_Master.R` with `RESPONSE_TRACK=dynamic_csi` and `RUN_05A_DYNAMIC_CSI=TRUE`, `RUN_05C_LABEL_PREP=TRUE`, `RUN_06_MERGE=TRUE`.

### Presentation graphics path (`FinalPresentation.Rnw`)

Line 72 still has the legacy MT path:
```
\graphicspath{{../../../03_Output/Figures/}}
```
This won't resolve in the AAE layout. Update to point at the appropriate `03_Data_Output/` figure subtree(s) before knitting — likely:
```
\graphicspath{
  {../../../03_Data_Output/3_Modelling_Results/Necessary/temporary_csi/figures/}
  {../../../03_Data_Output/3_Modelling_Results/Necessary/permanent_csi/figures/}
  {../../../03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/figures/}
  {../../../03_Data_Output/4_IndexConstruction_Results/Necessary/shared/general_figures/}
  {../../../03_Data_Output/1_Descriptive_Statistics/Necessary/shared/05_labels_figures/}
}
```

### Trained model binaries (44.7 GB)

AutoGluon `predictor.pkl` / `learner.pkl` binaries were NOT transferred from MT. They are regenerable by running `09C_AutoGluon.py`. The compact `ag_predictor_metadata.json` files ARE transferred (under `shared/ag_predictor_metadata/`) so you can still cite hyperparameters and ensemble composition without re-running.

---

*Document generated as part of the AgonyAndExcstasy cleanup. Last sync: 2026-05-25.*
