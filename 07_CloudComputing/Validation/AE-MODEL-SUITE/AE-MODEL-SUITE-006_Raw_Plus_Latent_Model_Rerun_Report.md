# AE-MODEL-SUITE-006 Raw Plus Latent Model Rerun Report

## Status

Decision: PASS - `MODEL=raw_plus_latent` AutoGluon rerun completed for both CSI tracks.

Branch: validation-model-suite  
Base HEAD: 3d125ad AE-MODEL-SUITE-005: rerun latent raw models  
Remote endpoint: [authorized endpoint]  
SSH authentication: [authorized SSH key path]  
Remote root: `/root/AgonyAndExcstasy`  
Isolated output root: `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-MODEL-SUITE/nonraw_rerun_20260529_105911`

AEGIS reference material was cross-referenced from `C:\Users\Tristan Leiter\Documents\aegis-core` before execution. Relevant Master-Agent, ticket execution, validator-blocking, cloud execution, storage hygiene, and branch-hygiene guidance was available and followed.

## Preflight

Remote regenerated `features_raw_plus_latent.parquet` inputs passed the required checks before training.

| Track | Folder | Feature rows | Unique keys | Duplicate keys | Split rows | Label rows | Missing keys | Extra keys | Pass |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| dynamic_csi | temporary_csi | 188,460 | 188,460 | 0 | 188,460 | 188,460 | 0 | 0 | true |
| permanent_csi | permanent_csi | 188,460 | 188,460 | 0 | 188,460 | 188,460 | 0 | 0 | true |

Feature keys aligned exactly with `split_labels_oot.parquet` and `labels_model_ready.rds`. Duplicate key count was zero for both tracks, and feature-vs-label `y` mismatch count was zero.

## Runs

Exactly two `09C_AutoGluon.py` runs were executed:

| Track | Folder | MODEL | Exit code | Required outputs |
|---|---|---:|---:|---|
| dynamic_csi | temporary_csi | raw_plus_latent | 0 | complete |
| permanent_csi | permanent_csi | raw_plus_latent | 0 | complete |

No `MODEL=raw`, `MODEL=fund`, or `MODEL=latent_raw` run was executed. `10_Evaluation.R`, `11C_IndexConstruction_Revised.R`, sensitivity scripts, index construction, and pipeline regeneration scripts were not run.

## Metrics

| Track | CV AP | CV AUC | CV R@FPR3 | Test AP | Test AUC | Test R@FPR1 | Test R@FPR3 | Test R@FPR5 | OOS AP | OOS AUC | OOS R@FPR1 | OOS R@FPR3 | OOS R@FPR5 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| dynamic_csi | 0.2171 | 0.8744 | 0.2513 | 0.1864 | 0.8741 | 0.0634 | 0.1779 | 0.2749 | 0.3152 | 0.8950 | 0.1051 | 0.2632 | 0.4128 |
| permanent_csi | 0.1983 | 0.8793 | 0.2664 | 0.1415 | 0.8838 | 0.0609 | 0.2011 | 0.3155 | 0.0311 | 0.8032 | 0.0000 | 0.0208 | 0.0653 |

Brier scores and row/positive counts by split were retained in `AE-MODEL-SUITE-006_raw_plus_latent_model_metrics.csv` and `AE-MODEL-SUITE-006_raw_plus_latent_prediction_row_counts.csv`.

## Model-Family Insight

All requested AutoGluon model families were trained or considered for both tracks: LightGBM, CatBoost, XGBoost, RandomForest, ExtraTrees, NeuralNetFastAI, NeuralNetTorch, and WeightedEnsemble.

| Track | Top family | Top rank | Notes |
|---|---|---:|---|
| dynamic_csi | WeightedEnsemble | 1 | Ensemble dominated; LightGBMXT rank 2, ExtraTrees rank 3, CatBoost rank 4, RandomForest rank 5. |
| permanent_csi | WeightedEnsemble | 1 | Ensemble dominated; LightGBMXT rank 2, CatBoost rank 3, LightGBMLarge rank 4, RandomForest rank 5. |

Warnings retained:

- LightGBM GPU mode was unavailable and fell back to CPU.
- CatBoost GPU mode was marked experimental.
- NeuralNetFastAI used log loss internally where average precision was unsupported.

Compact family and model-selection evidence:

- `AE-MODEL-SUITE-006_raw_plus_latent_model_family_metadata.csv`
- `AE-MODEL-SUITE-006_raw_plus_latent_hyperparameters.json`
- `AE-MODEL-SUITE-006_raw_plus_latent_ensemble_weights.json`
- `AE-MODEL-SUITE-006_raw_plus_latent_warnings.txt`
- `AE-MODEL-SUITE-006_raw_plus_latent_leaderboards.csv`

## Storage Retention

Heavy AutoGluon predictor and CV-fold directories were pruned only after compact metadata extraction. Retained outputs include prediction parquet files, CV parquet, eval summaries, leaderboards, compact family metadata, hyperparameters, ensemble weights, warnings, status, preflight, and row-count summaries.

Pruned heavy artifact bytes: 8,645,595,230 bytes.

Storage evidence:

- `AE-MODEL-SUITE-006_raw_plus_latent_storage_retention_preprune.csv`
- `AE-MODEL-SUITE-006_raw_plus_latent_storage_retention.csv`

## Scope And Hygiene

Canonical local outputs remained read-only. Local `01_Code/**`, `02_Data_Input/**`, and canonical `03_Data_Output/**` had no diffs after this ticket’s work. Remote raw-plus-latent outputs were written only under the isolated AE-MODEL-SUITE validation run root.

The pre-existing untracked AE-VALIDATE blocker reports remain unrelated and were not staged.

## Evidence

- `AE-MODEL-SUITE-006_raw_plus_latent_preflight.csv`
- `AE-MODEL-SUITE-006_raw_plus_latent_status.csv`
- `AE-MODEL-SUITE-006_raw_plus_latent_model_metrics.csv`
- `AE-MODEL-SUITE-006_raw_plus_latent_prediction_row_counts.csv`
- `AE-MODEL-SUITE-006_raw_plus_latent_leaderboards.csv`
- `AE-MODEL-SUITE-006_raw_plus_latent_model_family_metadata.csv`
- `AE-MODEL-SUITE-006_raw_plus_latent_hyperparameters.json`
- `AE-MODEL-SUITE-006_raw_plus_latent_ensemble_weights.json`
- `AE-MODEL-SUITE-006_raw_plus_latent_warnings.txt`
- `AE-MODEL-SUITE-006_raw_plus_latent_storage_retention.csv`
- `AE-MODEL-SUITE-006_canonical_output_check.csv`
- `AE-MODEL-SUITE-006_process_check.csv`

## Readiness

AE-MODEL-SUITE-006 is ready for validator review. If approved, the next ticket should compare `raw`, `fund`, `latent_raw`, and `raw_plus_latent` across both CSI tracks.
