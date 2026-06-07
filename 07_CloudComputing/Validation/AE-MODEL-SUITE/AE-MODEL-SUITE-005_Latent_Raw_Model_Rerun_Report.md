# AE-MODEL-SUITE-005 Latent Raw Model Rerun Report

## Status

Decision: PASS - VAE-only `latent_raw` AutoGluon rerun completed for both CSI tracks.

Branch: validation-model-suite  
Base HEAD: 63d70f2 AE-MODEL-SUITE-004: rerun fund models  
Remote endpoint: [authorized endpoint]  
SSH authentication: [authorized SSH key path]  
Remote root: `/root/AgonyAndExcstasy`  
Isolated output root: `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-MODEL-SUITE/nonraw_rerun_20260529_105911`

AEGIS reference material was cross-referenced from `C:\Users\Tristan Leiter\Documents\aegis-core` before execution. Relevant Master-Agent, ticket execution, validator-blocking, cloud execution, storage hygiene, and branch-hygiene guidance was available and followed.

## Preflight

Remote regenerated VAE-derived features passed the required checks before training.

| Track | Folder | Latent rows | Unique keys | Duplicate keys | Split rows | Missing keys | Extra keys | Pass |
|---|---|---:|---:|---:|---:|---:|---:|---|
| dynamic_csi | temporary_csi | 188,460 | 188,460 | 0 | 188,460 | 0 | 0 | true |
| permanent_csi | permanent_csi | 188,460 | 188,460 | 0 | 188,460 | 0 | 0 | true |

`split_labels_oot.parquet` and `labels_model_ready.rds` existed for both tracks.

## Runs

Exactly two `09C_AutoGluon.py` runs were executed:

| Track | Folder | MODEL | Exit code | Required outputs |
|---|---|---:|---:|---|
| dynamic_csi | temporary_csi | latent_raw | 0 | complete |
| permanent_csi | permanent_csi | latent_raw | 0 | complete |

No `MODEL=raw`, `MODEL=fund`, or `MODEL=raw_plus_latent` run was executed. `10_Evaluation.R`, `11C_IndexConstruction_Revised.R`, sensitivity scripts, and pipeline regeneration scripts were not run.

## Metrics

| Track | CV AP | CV AUC | CV R@FPR3 | Test AP | Test AUC | Test R@FPR1 | Test R@FPR3 | Test R@FPR5 | OOS AP | OOS AUC | OOS R@FPR1 | OOS R@FPR3 | OOS R@FPR5 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| dynamic_csi | 0.1759 | 0.8448 | 0.1872 | 0.1501 | 0.8438 | 0.0410 | 0.1294 | 0.2264 | 0.2813 | 0.8626 | 0.1009 | 0.2274 | 0.3556 |
| permanent_csi | 0.1468 | 0.8467 | 0.2012 | 0.1115 | 0.8496 | 0.0424 | 0.1513 | 0.2546 | 0.0482 | 0.8337 | 0.0504 | 0.1484 | 0.2226 |

Brier scores and row/positive counts by split were retained in `AE-MODEL-SUITE-005_latent_raw_model_metrics.csv` and `AE-MODEL-SUITE-005_latent_raw_prediction_row_counts.csv`.

## Model-Family Insight

All requested AutoGluon model families were trained or considered for both tracks:

| Track | Top family | Top rank | Notes |
|---|---|---:|---|
| dynamic_csi | WeightedEnsemble | 1 | Ensemble dominated; NeuralNetFastAI rank 2, XGBoost rank 3, CatBoost rank 4, ExtraTrees rank 5. |
| permanent_csi | WeightedEnsemble | 1 | Ensemble dominated; RandomForest rank 2, CatBoost rank 3, ExtraTrees rank 4, NeuralNetFastAI rank 5. |

Families present in compact metadata: LightGBM, CatBoost, XGBoost, RandomForest, ExtraTrees, NeuralNetFastAI, NeuralNetTorch, and WeightedEnsemble.

Warnings retained:

- LightGBM GPU mode was unavailable and fell back to CPU.
- CatBoost GPU mode was marked experimental.
- NeuralNetFastAI used log loss internally where average precision was unsupported.

Compact family, hyperparameter, and ensemble evidence files:

- `AE-MODEL-SUITE-005_latent_raw_model_family_metadata.csv`
- `AE-MODEL-SUITE-005_latent_raw_hyperparameters.json`
- `AE-MODEL-SUITE-005_latent_raw_ensemble_weights.json`
- `AE-MODEL-SUITE-005_latent_raw_warnings.txt`
- `AE-MODEL-SUITE-005_latent_raw_leaderboards.csv`

## Storage Retention

Heavy AutoGluon predictor and CV-fold directories were pruned only after compact metadata extraction. Retained outputs include prediction parquet files, CV parquet, eval summaries, leaderboards, compact family metadata, hyperparameters, ensemble weights, warnings, status, preflight, and row-count summaries.

Pruned heavy artifact bytes: 6,789,856,253 bytes.  
Final shared isolated run root size after latent_raw pruning: approximately 6.2 MB.

Storage evidence:

- `AE-MODEL-SUITE-005_latent_raw_storage_retention.csv`
- `AE-MODEL-SUITE-005_remote_process_guard.txt`

## Evidence Files

- `AE-MODEL-SUITE-005_latent_raw_preflight.csv`
- `AE-MODEL-SUITE-005_latent_raw_status.csv`
- `AE-MODEL-SUITE-005_latent_raw_model_metrics.csv`
- `AE-MODEL-SUITE-005_latent_raw_prediction_row_counts.csv`
- `AE-MODEL-SUITE-005_latent_raw_leaderboards.csv`
- `AE-MODEL-SUITE-005_latent_raw_optional_family_evidence.csv`
- `AE-MODEL-SUITE-005_latent_raw_model_family_metadata.csv`
- `AE-MODEL-SUITE-005_latent_raw_hyperparameters.json`
- `AE-MODEL-SUITE-005_latent_raw_ensemble_weights.json`
- `AE-MODEL-SUITE-005_latent_raw_warnings.txt`
- `AE-MODEL-SUITE-005_latent_raw_storage_retention.csv`
- `AE-MODEL-SUITE-005_canonical_modification_check.txt`
- `AE-MODEL-SUITE-005_remote_process_guard.txt`

## Scope And Hygiene

Canonical local outputs were not modified. Local `03_Data_Output/**`, `02_Data_Input/**`, and `01_Code/**` have no git diffs after the ticket. Remote retained files are confined to the isolated AE-MODEL-SUITE output root.

No endpoint, port, credential, or secret material is recorded in the committed evidence. Two unrelated untracked AE-VALIDATE blocker reports remain uncommitted and outside this ticket scope.

## Readiness

AE-MODEL-SUITE-005 is ready for validator review. If approved, the next ticket should reuse the same isolated output root for `MODEL=raw_plus_latent`.
