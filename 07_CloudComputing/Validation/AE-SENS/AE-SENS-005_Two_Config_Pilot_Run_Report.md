# AE-SENS-005 Two-Config Pilot Run Report

## Status

AE-SENS-005 completed. The two temporary-CSI C/M/T pilot configurations ran on the authorized Vast.ai instance with raw model only, and all generated outputs were isolated under the sensitivity output root.

## AEGIS Reference

Before execution, the worker cross-referenced `C:\Users\Tristan Leiter\Documents\aegis-core` as read-only material. The relevant AEGIS master/worker/validator rules were found and applied: one ticket at a time, scoped execution, validator blocking by default, and no protected-path edits.

## Branch and Base

- Local branch: `development-sensitivity`
- Required base: `768f27d` or descendant
- Observed HEAD at ticket start: `768f27d`
- Remote endpoint in reports: `[authorized endpoint]`
- SSH key in reports: `[authorized SSH key path]`
- Remote root: `/root/AgonyAndExcstasy`
- Sensitivity root: `/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity`

## Runner Decision

AE-SENS-003 had found no safe single-run C/M/T sensitivity runner. Inspection for AE-SENS-005 found no existing dedicated single-run runner, so this ticket added the narrow runner path needed for the two pilot configurations.

The new runner path is raw-only and temporary-CSI-only:

- `01_Code/pipeline/ae_sens_prepare_raw_inputs.R`
- `01_Code/pipeline/ae_sens_eval_raw.R`
- `01_Code/shell/run_ae_sens_raw_one.sh`
- AE-SENS routing additions in `01_Code/pipeline/09C_AutoGluon.py`
- AE-SENS routing additions in `01_Code/pipeline/11C_IndexConstruction_Revised.R`

The runner requires `AE_SENS_RUN_ID`, `AE_SENS_C`, `AE_SENS_M`, `AE_SENS_T`, `AE_SENS_OUTPUT_ROOT`, `MODEL=raw`, and `RESPONSE_TRACK=dynamic_csi`. It validates the approved run-id pattern and fails closed when any run-specific destination directory is already non-empty. The first pilot used documented resume semantics after isolated raw outputs already existed from the initial driver attempt; no canonical output directories were used as destinations.

## Pilot Configurations

| Run ID | C | M | T | Status |
|---|---:|---:|---:|---|
| `C080_M020_T018` | -0.80 | -0.20 | 18 | completed |
| `C090_M020_T028` | -0.90 | -0.20 | 28 | completed |

## Step Status

| Run ID | Step | Status | Start UTC | End UTC |
|---|---|---|---|---|
| `C080_M020_T018` | prepare raw inputs | completed | 2026-05-28T13:10:27+00:00 | 2026-05-28T13:13:53+00:00 |
| `C080_M020_T018` | raw AutoGluon | completed | 2026-05-28T13:13:53+00:00 | 2026-05-28T13:35:17+00:00 |
| `C080_M020_T018` | raw evaluation | completed | 2026-05-28T13:43:26+00:00 | 2026-05-28T13:43:28+00:00 |
| `C080_M020_T018` | 11C index construction | completed | 2026-05-28T13:59:37+00:00 | 2026-05-28T14:03:07+00:00 |
| `C090_M020_T028` | prepare raw inputs | completed | 2026-05-28T14:05:35+00:00 | 2026-05-28T14:08:01+00:00 |
| `C090_M020_T028` | raw AutoGluon | completed | 2026-05-28T14:08:01+00:00 | 2026-05-28T14:29:52+00:00 |
| `C090_M020_T028` | raw evaluation | completed | 2026-05-28T14:29:52+00:00 | 2026-05-28T14:29:53+00:00 |
| `C090_M020_T028` | 11C index construction | completed | 2026-05-28T14:29:53+00:00 | 2026-05-28T14:33:16+00:00 |

## Label Counts

| Run ID | Rows | Labelled | CSI positives | Clean negatives | NA | Prevalence |
|---|---:|---:|---:|---:|---:|---:|
| `C080_M020_T018` | 188,460 | 179,786 | 8,517 | 171,269 | 8,674 | 4.7373% |
| `C090_M020_T028` | 188,460 | 179,735 | 5,013 | 174,722 | 8,725 | 2.7891% |

## Raw Model Metrics

| Run ID | Set | Rows | Positives | AP | AUC |
|---|---|---:|---:|---:|---:|
| `C080_M020_T018` | test_eval | 18,111 | 804 | 0.1978 | 0.8766 |
| `C080_M020_T018` | oos_eval | 18,502 | 1,170 | 0.3077 | 0.8961 |
| `C080_M020_T018` | cv | 72,223 | 3,119 | 0.2027 | 0.8620 |
| `C090_M020_T028` | test_eval | 18,111 | 518 | 0.1559 | 0.8952 |
| `C090_M020_T028` | oos_eval | 18,451 | 535 | 0.1578 | 0.9050 |
| `C090_M020_T028` | cv | 72,223 | 1,907 | 0.1626 | 0.8938 |

The AutoGluon logs show LightGBM, CatBoost, FastAI, and XGBoost were fit for both run IDs. The compact optional-family evidence records no missing-import skips for those families.

## 11C Summary

Best OOS Sharpe model-filtered strategy by index:

| Run ID | Index | Threshold | Rule | Annualized return | Annualized SD | Sharpe | Max drawdown | Difference vs benchmark |
|---|---|---|---|---:|---:|---:|---:|---:|
| `C080_M020_T018` | large_cap | youden | 5yr lockout | 0.1446 | 0.1801 | 0.6786 | -0.2352 | 0.0018 |
| `C080_M020_T018` | mid_cap | fpr3 | 5yr lockout | 0.1003 | 0.2072 | 0.4233 | -0.2447 | 0.0038 |
| `C080_M020_T018` | small_cap | youden | 5yr lockout | 0.0841 | 0.2278 | 0.3397 | -0.2942 | 0.0075 |
| `C080_M020_T018` | total_market | youden | 5yr lockout | 0.1377 | 0.1833 | 0.6366 | -0.2349 | 0.0048 |
| `C090_M020_T028` | large_cap | youden | 5yr lockout | 0.1433 | 0.1805 | 0.6709 | -0.2408 | 0.0005 |
| `C090_M020_T028` | mid_cap | fpr3 | 5yr lockout | 0.0982 | 0.2058 | 0.4154 | -0.2435 | 0.0017 |
| `C090_M020_T028` | small_cap | youden | 5yr lockout | 0.0776 | 0.2283 | 0.3134 | -0.2943 | 0.0011 |
| `C090_M020_T028` | total_market | youden | 5yr lockout | 0.1355 | 0.1837 | 0.6251 | -0.2414 | 0.0026 |

## Output Isolation

Per-run outputs were written under:

- `logs/<run_id>/`
- `labels/<run_id>/`
- `raw_features/by_config/<run_id>/`
- `raw_models/<run_id>/`
- `raw_predictions/<run_id>/`
- `evaluation/<run_id>/`
- `index_construction/<run_id>/`

The compact output inventory is in `AE-SENS-005_output_inventory.csv`. The full generated model binaries, prediction parquet files, and large index CSV/RDS files remain remote and were not downloaded.

## Canonical Modification Check

Remote canonical fingerprints matched before and after the pilot:

- before: `cf23594cfa2f63ee319ebd556b25008265d1432e54ac9606998a3c69947c1c55`
- resume-before: `cf23594cfa2f63ee319ebd556b25008265d1432e54ac9606998a3c69947c1c55`
- after: `cf23594cfa2f63ee319ebd556b25008265d1432e54ac9606998a3c69947c1c55`

Scope checked: remote temporary-CSI canonical modelling outputs, temporary-CSI 4_IndexConstruction outputs, and temporary-CSI pipeline-result files. Local git status also shows no local data or canonical output modifications.

## Forbidden Work Check

No full 27-grid execution was started. No permanent-CSI sensitivity run was started. No latent, fund, bucket, structural, VAE, or autoencoder model-family run was started. `10_Evaluation.R`, merge/split/feature regeneration, presentation cleanup, and unrelated AE-VALIDATE files were not run or staged.

The final remote process guard found no remaining project processes beyond the diagnostic shell and grep commands themselves.

## Compact Evidence Files

- `AE-SENS-005_pilot_status.csv`
- `AE-SENS-005_pilot_step_status.csv`
- `AE-SENS-005_pilot_label_counts.csv`
- `AE-SENS-005_pilot_model_metrics.csv`
- `AE-SENS-005_pilot_prediction_row_counts.csv`
- `AE-SENS-005_pilot_11c_summary.csv`
- `AE-SENS-005_output_inventory.csv`
- `AE-SENS-005_optional_family_evidence.csv`
- `AE-SENS-005_remote_process_guard.txt`
- `AE-SENS-005_canonical_modification_check.txt`

## Verification

- Local branch/base check: `development-sensitivity`, HEAD `768f27d`, required base satisfied.
- Local Python parse check for `09C_AutoGluon.py`: passed with the bundled Python runtime.
- Local R parse check for `ae_sens_prepare_raw_inputs.R`, `ae_sens_eval_raw.R`, and `11C_IndexConstruction_Revised.R`: passed with local R 4.5.2.
- Remote runner parse/load check before execution: passed for R scripts and `09C_AutoGluon.py`.
- Local Bash syntax check could not run because available Windows Bash/Git Bash failed with access-denied signal-pipe errors. The shell wrapper executed remotely for `C090_M020_T028` and completed all four steps.

## Blockers

No remaining blocker for AE-SENS-005. Validator review is required before staging, committing, and pushing.
