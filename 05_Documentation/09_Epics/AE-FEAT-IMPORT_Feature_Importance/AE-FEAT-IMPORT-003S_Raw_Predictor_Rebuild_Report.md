# AE-FEAT-IMPORT-003S Raw Predictor Rebuild Report

## Status

status: complete

role: AEGIS worker only; no self-approval, staging, commit, push, merge, or future-ticket work performed.

## Scope

This ticket resolved the raw predictor blocker left by AE-FEAT-IMPORT-003R by rebuilding the two missing raw AutoGluon predictors under the existing ignored feature-importance workspace:

- `raw/dynamic_csi`
- `raw/permanent_csi`

The six non-raw predictors from AE-FEAT-IMPORT-003R were reused in place. No feature-importance computation, evaluation script, index-construction script, sensitivity script, pipeline regeneration, presentation compile, branch merge, commit, or push was run.

## Workspace

Local ignored predictor workspace:

`03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm`

Raw predictor outputs:

- `03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm/3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw/ag_predictor`
- `03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm/3_Modelling_Results/Necessary/permanent_csi/AutoGluon/ag_raw/ag_predictor`

These paths are local-only ignored artifacts and must not be staged or committed.

## Raw Restore Decision

No safe local raw predictor restore artifact was present at the start of this ticket. The existing workspace did not contain either raw predictor directory. The ticket envelope explicitly allowed running `09C_AutoGluon.py` only for `MODEL=raw` with `RESPONSE_TRACK=dynamic_csi` and `RESPONSE_TRACK=permanent_csi`; therefore the raw blocker was resolved through bounded local rebuilds rather than remote restore.

No endpoint details, ports, key paths, tokens, credentials, private key material, or raw SSH commands are recorded in this report.

## Rebuild Configuration

Both raw predictors were rebuilt with `09C_AutoGluon.py` using a bounded GBM-only configuration:

- `MODEL=raw`
- `RESPONSE_TRACK=dynamic_csi` or `RESPONSE_TRACK=permanent_csi`
- `MT_OUTPUT_DIR=03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm`
- `AG_FEATURE_IMPORTANCE=0`
- `AG_PRESET=medium_quality`
- `AG_CV_PRESET=medium_quality`
- `AG_TIME_LIMIT=300`
- `AG_CV_TIME_LIMIT=180`
- `AG_NUM_BAG_FOLDS=0`
- `AG_NUM_STACK_LEVELS=0`
- `AG_CV_NUM_BAG_FOLDS=0`
- `AG_CV_NUM_STACK_LEVELS=0`
- `AG_EXCLUDED_MODEL_TYPES=CAT,NN_TORCH,FASTAI,RF,XT,XGB,KNN`

The 300/180 second raw budget was used after two bounded failed starts on `raw/dynamic_csi`: first a Windows console encoding failure before training, then a 90-second run where raw preprocessing consumed the budget and no base model trained. No feature importance ran in either failed start.

## Raw Rebuild Results

| feature_set | track | loadable | smoke_probability | best_model | approx_size_mb | n_required_features |
|---|---|---:|---:|---|---:|---:|
| raw | dynamic_csi | yes | yes | WeightedEnsemble_L2 | 502.9 | 460 |
| raw | permanent_csi | yes | yes | WeightedEnsemble_L2 | 504.7 | 460 |

Stage-1 summary from `ag_eval_summary.json`:

| track | test_ap | test_auc | test_recall_fpr3 | cv_ap | cv_auc | cv_recall_fpr3 |
|---|---:|---:|---:|---:|---:|---:|
| dynamic_csi | 0.1815 | 0.8739 | 0.1667 | 0.2082 | 0.8693 | 0.2369 |
| permanent_csi | 0.1531 | 0.8864 | 0.2159 | 0.1861 | 0.8747 | 0.2581 |

These metrics are recorded only as rebuild run evidence. This bounded GBM-only workspace is for later perturbation interpretation plumbing and is not a replacement for the final model-suite performance results.

## Commands Run And Results

| command purpose | result |
|---|---|
| `git status --short --branch` | Confirmed branch `Development-FE`; pre-existing dirty files exist in protected presentation/cloud paths and were not touched. |
| Read ticket envelope and AE-FEAT-IMPORT-003R report | Confirmed ticket scope, allowed write areas, and six existing non-raw predictors. |
| Raw predictor existence check | Both raw predictor directories were absent before rebuild. |
| `09C_AutoGluon.py` for `MODEL=raw`, `RESPONSE_TRACK=dynamic_csi`, 90-second raw budget | First failed before training due to console encoding; rerun with UTF-8 reached AutoGluon but trained no model because raw preprocessing consumed the time budget. |
| `09C_AutoGluon.py` for `MODEL=raw`, `RESPONSE_TRACK=dynamic_csi`, 300/180-second raw budget | Completed; feature importance skipped; predictor saved and later load/smoke passed. |
| `09C_AutoGluon.py` for `MODEL=raw`, `RESPONSE_TRACK=permanent_csi`, 300/180-second raw budget | Completed; feature importance skipped; predictor saved and later load/smoke passed. |
| Search for `ag_feature_importance.csv` under the workspace | No feature-importance output files found. |

## Findings

- Raw predictor blocker is resolved locally for both tracks.
- All eight model-track predictors are now present under the ignored workspace.
- The raw rebuilds are bounded GBM-only predictors, not restored full-fidelity original predictors.
- Low-memory warnings appeared during raw AutoGluon fitting, but both raw runs completed and produced loadable predictors.
- AE-FEAT-IMPORT-004R can proceed to true bounded log-odds perturbation only if the validator/master accepts this bounded predictor workspace for interpretation.
