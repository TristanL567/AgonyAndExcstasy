# AE-VALIDATE-004R Optional Model Environment And Rerun Report

## status

completed

## summary

AE-VALIDATE-004R reran AE-VALIDATE-004 raw AutoGluon training after the optional model-family libraries were installed. The run used branch `validation` at HEAD `5d706ef`, which is the AE-VALIDATE-004 commit and therefore satisfies the required HEAD preflight.

SSH was performed through `[authorized endpoint]` using the mandated non-interactive command shape. Primary smoke test passed with `CONNECTION_OK`, `/root/AgonyAndExcstasy`, and `root`; fallback was not used. No `-L` tunnel was used.

Remote optional model import verification passed:

- `OPTIONAL_MODEL_IMPORTS_OK`
- `lightgbm 4.6.0`
- `catboost 1.2.10`
- `xgboost 3.2.0`
- `fastai 2.8.7`
- `autogluon.tabular 1.5.0` was pre-confirmed installed by the human dependency state and `TabularPredictor` imported successfully in the remote check.

## artifacts

Run ID: `raw_rerun_20260528_optional_models`

Remote output root:

`/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models`

Local compact evidence:

- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/summary.json`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/status_summary.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/inventory.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/row_counts.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/metric_snapshot.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/dynamic_csi_leaderboard_compact.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/permanent_csi_leaderboard_compact.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/leaderboard_model_family_rows.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/dynamic_csi_09C_tail.txt`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/permanent_csi_09C_tail.txt`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/model_family_log_excerpt.txt`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/canonical_modification_check.txt`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/forbidden_process_check.txt`

Heavy model binaries and full prediction parquet files were not downloaded locally.

## verification

Preflight:

- Local branch: `validation`
- Local HEAD: `5d706ef`
- HEAD ancestry: `HEAD_DESCENDANT_OF_5d706ef`
- Required smoke test: passed on `[authorized endpoint]`
- Pre-run remote process check for `09C_AutoGluon.py`, `10_Evaluation.R`, and `11C_IndexConstruction_Revised.R`: no matching process found
- Remote import verification: passed
- Run ID distinct from prior run `raw_rerun_20260527_230749`: yes

Rerun commands executed:

- `09C_AutoGluon.py` with `MODEL=raw`, `RESPONSE_TRACK=dynamic_csi`, `MT_ROOT=/root/AgonyAndExcstasy`, and `MT_OUTPUT_DIR` set to the new validation run root
- `09C_AutoGluon.py` with `MODEL=raw`, `RESPONSE_TRACK=permanent_csi`, `MT_ROOT=/root/AgonyAndExcstasy`, and `MT_OUTPUT_DIR` set to the new validation run root

Runtimes and exit codes:

| track | start UTC | end UTC | runtime | exit |
| --- | --- | --- | ---: | ---: |
| dynamic_csi | 2026-05-28T06:06:37Z | 2026-05-28T06:30:24Z | 23m47s | 0 |
| permanent_csi | 2026-05-28T06:30:36Z | 2026-05-28T06:53:41Z | 23m05s | 0 |

Produced file summary:

| track | ag_raw exists | file count | remote bytes | leaderboard rows |
| --- | ---: | ---: | ---: | ---: |
| dynamic_csi | yes | 152 | 4,427,514,740 | 12 |
| permanent_csi | yes | 152 | 4,138,271,351 | 12 |

Required `ag_raw` outputs present for both tracks:

- `ag_eval_summary.json`
- `ag_leaderboard.csv`
- `ag_preds_test.parquet`
- `ag_preds_test_eval.parquet`
- `ag_preds_oos.parquet`
- `ag_preds_oos_eval.parquet`
- `ag_preds_train_boundary.parquet`
- `ag_cv_results.parquet`

Row counts:

| track | file | rows | columns |
| --- | --- | ---: | ---: |
| dynamic_csi | ag_preds_test.parquet | 18,111 | 4 |
| dynamic_csi | ag_preds_test_eval.parquet | 18,111 | 4 |
| dynamic_csi | ag_preds_oos.parquet | 18,502 | 4 |
| dynamic_csi | ag_preds_oos_eval.parquet | 18,502 | 4 |
| dynamic_csi | ag_preds_train_boundary.parquet | 4,663 | 4 |
| dynamic_csi | ag_cv_results.parquet | 72,223 | 5 |
| permanent_csi | ag_preds_test.parquet | 18,053 | 4 |
| permanent_csi | ag_preds_test_eval.parquet | 18,053 | 4 |
| permanent_csi | ag_preds_oos.parquet | 26,400 | 4 |
| permanent_csi | ag_preds_oos_eval.parquet | 26,400 | 4 |
| permanent_csi | ag_preds_train_boundary.parquet | 4,663 | 4 |
| permanent_csi | ag_cv_results.parquet | 72,223 | 5 |

Key metric snapshot:

| track | CV AP | CV AUC | CV R@FPR3 | test AP | test AUC | test R@FPR3 | OOS AP | OOS AUC | OOS R@FPR3 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| dynamic_csi | 0.2166 | 0.8732 | 0.2471 | 0.1985 | 0.8766 | 0.2002 | 0.3084 | 0.8961 | 0.2547 |
| permanent_csi | 0.1929 | 0.8789 | 0.2658 | 0.1416 | 0.8810 | 0.1808 | 0.0323 | 0.8081 | 0.0119 |

Optional model-family availability:

- `excluded_model_types` is empty for both tracks.
- Compact leaderboard evidence includes `LightGBMXT`, `LightGBM`, `LightGBMLarge`, `CatBoost`, `XGBoost`, and `NeuralNetFastAI` rows for both tracks.
- Missing-import log scan found zero hits for LightGBM, CatBoost, FastAI, or XGBoost skip/import-failure patterns.

Negative-scope checks:

- `10_Evaluation.R` was not run.
- `11C_IndexConstruction_Revised.R` was not run.
- Sensitivity scripts were not run.
- Pipeline regeneration scripts were not run.
- Final forbidden-process check was empty.
- Canonical-output modification check found zero files outside the allowed validation run root modified after the rerun start.

## findings

The methodological caveat from the prior raw AutoGluon rerun is resolved for this ticket: the optional model-family libraries imported successfully and AutoGluon trained/considered the LightGBM, CatBoost, XGBoost, and FastAI families in both raw rerun tracks.

No evaluation or index-construction outputs were produced in this ticket.

## changed_files

Created compact local evidence only under `07_CloudComputing/Validation/AE-VALIDATE/`:

- `AE-VALIDATE-004R_Optional_Model_Environment_And_Rerun_Report.md`
- `raw_rerun_20260528_optional_models/status_summary.csv`
- `raw_rerun_20260528_optional_models/summary.json`
- `raw_rerun_20260528_optional_models/inventory.csv`
- `raw_rerun_20260528_optional_models/row_counts.csv`
- `raw_rerun_20260528_optional_models/metric_snapshot.csv`
- `raw_rerun_20260528_optional_models/*_leaderboard_compact.csv`
- `raw_rerun_20260528_optional_models/*_09C_tail.txt`
- `raw_rerun_20260528_optional_models/model_family_log_excerpt.txt`
- `raw_rerun_20260528_optional_models/leaderboard_model_family_rows.csv`
- `raw_rerun_20260528_optional_models/canonical_modification_check.txt`
- `raw_rerun_20260528_optional_models/forbidden_process_check.txt`

Unrelated local files listed in the ticket were not edited.

## next_recommended_role

validator

## human_readability

The optional AutoGluon model libraries are now active in the raw validation rerun. Both dynamic and permanent CSI tracks completed successfully into a new validation-only run folder. The compact evidence shows the optional model families in the leaderboards, no missing-import skips, and no evidence that evaluation, index construction, sensitivity, pipeline regeneration, canonical outputs, or unrelated local files were touched.
