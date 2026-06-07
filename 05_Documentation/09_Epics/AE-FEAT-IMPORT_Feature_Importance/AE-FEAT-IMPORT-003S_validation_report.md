# AE-FEAT-IMPORT-003S Validation Report

## Status

status: pass

role: AEGIS worker validation evidence only; no self-approval performed.

## Validation Scope

Validated all eight bounded GBM-only AutoGluon predictors in:

`03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm`

Validation covered:

- AutoGluon predictor load for each model-track combination.
- One-row `predict_proba` smoke test for each predictor.
- All-8 inventory generation.
- Confirmation that feature-importance output was not produced.
- Confirmation that no staging, commit, push, protected-file edit, evaluation script, index-construction script, sensitivity script, pipeline regeneration, or presentation compile was performed.

## Load And Smoke Results

Detailed inventory:

`05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-003S_all_predictor_load_inventory.csv`

| feature_set | track | loadable | smoke_probability | best_model | n_required_features | smoke_probability_value |
|---|---|---:|---:|---|---:|---:|
| raw | dynamic_csi | yes | yes | WeightedEnsemble_L2 | 460 | 0.26187917590141296 |
| raw | permanent_csi | yes | yes | WeightedEnsemble_L2 | 460 | 0.47003358602523804 |
| fund | dynamic_csi | yes | yes | WeightedEnsemble_L2 | 441 | 0.29631659388542175 |
| fund | permanent_csi | yes | yes | WeightedEnsemble_L2 | 441 | 0.34861427545547485 |
| latent_raw | dynamic_csi | yes | yes | WeightedEnsemble_L2 | 25 | 0.17198877036571503 |
| latent_raw | permanent_csi | yes | yes | WeightedEnsemble_L2 | 25 | 0.2254527509212494 |
| raw_plus_latent | dynamic_csi | yes | yes | WeightedEnsemble_L2 | 486 | 0.11403075605630875 |
| raw_plus_latent | permanent_csi | yes | yes | WeightedEnsemble_L2 | 486 | 0.1861044466495514 |

The smoke input used one row containing the required predictor feature set from `predictor.feature_metadata_in`, with zero-valued feature values. The check validates load and probability prediction plumbing only; it does not validate model performance or feature-importance semantics.

## Acceptance Criteria Check

| criterion | result | evidence |
|---|---|---|
| Raw dynamic and permanent predictors resolved or blocker documented | pass | Both raw predictors rebuilt and smoke-tested. |
| All eight predictors loadable | pass | Inventory rows all `loadable=yes`. |
| Small probability smoke test for all eight | pass | Inventory rows all `smoke_probability=yes` with one returned probability. |
| Updated all-8 predictor inventory | pass | `AE-FEAT-IMPORT-003S_all_predictor_load_inventory.csv`. |
| Bounded GBM-only interpretation caveat documented | pass | Raw rebuild and completion reports state this is not a final performance replacement. |
| No feature-importance computation | pass | `AG_FEATURE_IMPORTANCE=0`; no `ag_feature_importance.csv` found under workspace. |
| No evaluation/index/sensitivity/pipeline/presentation scripts | pass | Only allowed `09C_AutoGluon.py` raw runs and validation checks were run. |
| No protected files edited | pass | Worker edits are limited to allowed documentation/epic paths; ignored predictor artifacts are under the allowed feature-importance workspace. |
| No `03_Data_Output/**` staged or committed | pass | No staging or commit performed. |
| No endpoint, port, key path, token, credential, or raw SSH leakage | pass | Reports contain no such details. |
| AE-FEAT-IMPORT-004R readiness explicit | pass | Completion report recommends DS validation/master acceptance before next perturbation ticket. |

## Commands Run And Results

| command purpose | result |
|---|---|
| Branch/status checks | Branch was `Development-FE`; dirty protected files were pre-existing and left untouched. |
| Ticket and prior report reads | Scope confirmed from `AE-FEAT-IMPORT-003S.yaml` and `AE-FEAT-IMPORT-003R_Predictor_Workspace_Report.md`. |
| Raw rebuilds through `09C_AutoGluon.py` | Both raw tracks completed after increasing bounded raw time budget to 300/180 seconds. |
| AutoGluon load/smoke inventory script | All eight predictors loaded and returned one probability. |
| Feature-importance output search | No `ag_feature_importance.csv` files found. |

## Residual Risk

This validation confirms predictor availability and probability-prediction plumbing. It does not claim that the bounded GBM-only rebuilds reproduce the final model-suite predictors or their published performance. Treat the workspace as an interpretation workspace for later bounded log-odds perturbation only.
