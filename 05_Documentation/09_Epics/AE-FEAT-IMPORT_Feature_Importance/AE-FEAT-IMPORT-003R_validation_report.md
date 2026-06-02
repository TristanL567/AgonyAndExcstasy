# AE-FEAT-IMPORT-003R Validation Report

## Status

status: blocked

role: AEGIS worker only; no self-approval performed.

## Validation Performed

Validated ticket constraints and artifacts:

- confirmed branch: `Development-FE`
- inspected ticket envelope
- preserved unrelated dirty files
- avoided protected edit paths
- used only ignored local predictor workspace for generated AutoGluon artifacts
- did not run feature importance
- did not run `10_Evaluation.R`
- did not run `11C_IndexConstruction_Revised.R`
- did not run sensitivity scripts
- did not stage, commit, or push

Validated predictor loadability:

- loaded each rebuilt non-raw predictor with `TabularPredictor.load`
- generated one-row smoke probabilities with `predict_proba`
- recorded file count, approximate size, best model, loadability, and smoke status
- recorded raw predictor absence as blocker evidence

## Predictor Validation Result

| feature_set | track | loadable | smoke_probability | smoke_row_count | result |
|---|---|---|---|---:|---|
| raw | dynamic_csi | no | no | 0 | blocker: raw predictor not restored |
| raw | permanent_csi | no | no | 0 | blocker: raw predictor not restored |
| fund | dynamic_csi | yes | yes | 1 | pass |
| fund | permanent_csi | yes | yes | 1 | pass |
| latent_raw | dynamic_csi | yes | yes | 1 | pass |
| latent_raw | permanent_csi | yes | yes | 1 | pass |
| raw_plus_latent | dynamic_csi | yes | yes | 1 | pass |
| raw_plus_latent | permanent_csi | yes | yes | 1 | pass |

## Blocker Validation

The blocker is specific and validated:

- local raw predictor directories are absent from the ignored workspace;
- existing local evidence says raw is recoverable remotely, but live raw restore was not performed because the provided connection note was a tunnel template rather than a bounded non-interactive listing/transfer command for predictor restore;
- no authorized raw predictor artifact was already available locally;
- the worker did not fabricate raw loadability;
- the inventory marks both raw combinations as non-loadable with zero smoke rows.

## Artifact Checks

Created or updated evidence files:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-003R_Predictor_Workspace_Report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-003R_predictor_load_inventory.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-003R_validation_report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-003R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

Generated ignored local-only predictor artifacts:

- `03_Data_Output/10_FeatureImportance/predictor_workspace/rebuild_20260602_gbm/**`

## Human-Readable Result

Six missing non-raw predictors were rebuilt as bounded GBM-only predictors, not restored full-fidelity model-suite predictors, and smoke-tested successfully. The two raw predictors could not be restored in this worker context, so the ticket must return as a blocker rather than a complete predictor workspace. Raw remains blocked pending a follow-up ticket that supplies or approves a bounded restore command, or authorizes a raw rebuild path.
