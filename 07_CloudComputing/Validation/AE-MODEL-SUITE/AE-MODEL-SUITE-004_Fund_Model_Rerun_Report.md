# AE-MODEL-SUITE-004 Fund Model Rerun Report

## Status

Decision: PASS - fundamentals-only AutoGluon rerun completed for both CSI tracks.

Branch: validation-model-suite  
Base HEAD: 757e8fc AE-MODEL-SUITE-003: prepare remote non-raw model inputs  
Remote endpoint: [authorized endpoint]  
SSH authentication: [authorized SSH key path]  
Remote root: `/root/AgonyAndExcstasy`  
Isolated output root: `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-MODEL-SUITE/nonraw_rerun_20260529_105911`

AEGIS reference material was cross-referenced from `C:\Users\Tristan Leiter\Documents\aegis-core` before execution. Relevant Master-Agent, ticket execution, validator-blocking, cloud execution, storage hygiene, and branch-hygiene guidance was available and followed.

## Runs

Exactly two `09C_AutoGluon.py` runs were executed:

| Track | Folder | MODEL | Exit code | Required outputs |
|---|---|---:|---:|---|
| dynamic_csi | temporary_csi | fund | 0 | complete |
| permanent_csi | permanent_csi | fund | 0 | complete |

No `MODEL=raw`, `MODEL=latent_raw`, or `MODEL=raw_plus_latent` run was executed. `10_Evaluation.R`, `11C_IndexConstruction_Revised.R`, sensitivity scripts, and pipeline regeneration scripts were not run.

## Metrics

| Track | CV AP | CV AUC | CV R@FPR3 | Test AP | Test AUC | Test R@FPR1 | Test R@FPR3 | Test R@FPR5 | OOS AP | OOS AUC | OOS R@FPR1 | OOS R@FPR3 | OOS R@FPR5 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| dynamic_csi | 0.2101 | 0.8663 | 0.2371 | 0.1656 | 0.8538 | 0.0585 | 0.1517 | 0.2413 | 0.2526 | 0.8686 | 0.0598 | 0.1795 | 0.3017 |
| permanent_csi | 0.1892 | 0.8723 | 0.2527 | 0.1289 | 0.8627 | 0.0627 | 0.1697 | 0.2620 | 0.0281 | 0.7798 | 0.0000 | 0.0030 | 0.0297 |

Brier scores were retained in `AE-MODEL-SUITE-004_fund_model_metrics.csv`.

## Model-Family Insight

All requested AutoGluon model families were trained or considered for both tracks:

| Track | Top family | Top rank | Notes |
|---|---|---:|---|
| dynamic_csi | WeightedEnsemble | 1 | Ensemble dominated; NeuralNetTorch rank 2, LightGBM rank 3, RandomForest rank 4. |
| permanent_csi | WeightedEnsemble | 1 | Ensemble dominated; LightGBM rank 2, CatBoost rank 3, NeuralNetTorch rank 5. |

Families present in compact metadata: LightGBM, CatBoost, XGBoost, RandomForest, ExtraTrees, NeuralNetFastAI, NeuralNetTorch, and WeightedEnsemble.

Warnings retained:

- LightGBM GPU mode was unavailable and fell back to CPU.
- CatBoost GPU mode was marked experimental.
- NeuralNetFastAI used log loss internally where average precision was unsupported.

Compact family, hyperparameter, and ensemble evidence files:

- `AE-MODEL-SUITE-004_fund_model_family_metadata.csv`
- `AE-MODEL-SUITE-004_fund_model_family_hyperparameters.json`
- `AE-MODEL-SUITE-004_fund_weighted_ensemble_weights.json`
- `AE-MODEL-SUITE-004_fund_model_family_warnings.txt`
- `AE-MODEL-SUITE-004_fund_leaderboards.csv`

## Storage Retention

Heavy AutoGluon predictor and CV-fold directories were pruned only after compact metadata extraction. Retained outputs include prediction parquet files, CV parquet, eval summaries, leaderboards, compact family metadata, hyperparameters, ensemble weights, warnings, status, and row-count summaries.

Pruned heavy artifact bytes: 8,531,790,919 bytes.  
Final isolated run root size: approximately 3.2 MB.

Storage evidence:

- `AE-MODEL-SUITE-004_fund_storage_retention.csv`
- `AE-MODEL-SUITE-004_remote_process_guard.txt`

## Evidence Files

- `AE-MODEL-SUITE-004_fund_status.csv`
- `AE-MODEL-SUITE-004_fund_model_metrics.csv`
- `AE-MODEL-SUITE-004_fund_prediction_row_counts.csv`
- `AE-MODEL-SUITE-004_fund_leaderboards.csv`
- `AE-MODEL-SUITE-004_fund_optional_family_evidence.csv`
- `AE-MODEL-SUITE-004_fund_model_family_metadata.csv`
- `AE-MODEL-SUITE-004_fund_model_family_hyperparameters.json`
- `AE-MODEL-SUITE-004_fund_weighted_ensemble_weights.json`
- `AE-MODEL-SUITE-004_fund_model_family_warnings.txt`
- `AE-MODEL-SUITE-004_fund_storage_retention.csv`
- `AE-MODEL-SUITE-004_canonical_modification_check.txt`
- `AE-MODEL-SUITE-004_remote_process_guard.txt`

## Scope And Hygiene

Canonical local outputs were not modified. Local `03_Data_Output/**`, `02_Data_Input/**`, and `01_Code/**` have no git diffs after the ticket. Remote retained files are confined to the isolated AE-MODEL-SUITE output root.

No endpoint, port, credential, or secret material is recorded in the committed evidence. Two unrelated untracked AE-VALIDATE blocker reports remain uncommitted and outside this ticket scope.

## Readiness

AE-MODEL-SUITE-004 is ready for validator review. If approved, the next ticket should reuse the same isolated output root for `MODEL=latent_raw` if practical.
