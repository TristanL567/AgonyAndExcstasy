# AE-VALIDATE-006 11C Index Rerun Report

## Status

PASS - ready for validator review.

## AEGIS Reference Check

Before execution, the workflow cross-referenced the read-only AEGIS reference material under `C:\Users\Tristan Leiter\Documents\aegis-core`, including the master role, ticket contract, and validator blocking rules. No edits were made to `aegis-core`.

## Local State

- Branch: `validation`
- Required base: `705e136` or descendant
- Observed HEAD before execution: `705e136`
- Run root: `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models`
- Remote access: `[authorized endpoint]` through explicit OpenSSH only

## Scope Control

Only the allowed remote script was run:

- `01_Code/pipeline/11C_IndexConstruction_Revised.R`

The following scripts were not run:

- `09C_AutoGluon.py`
- `10_Evaluation.R`
- sensitivity scripts
- merge, split, feature, or pipeline regeneration scripts

No local code, data, canonical output, presentation, or model files were edited. Remote 11C outputs were written only under the isolated validation run root.

## Command Results

| Track | Folder | Command status | Evidence |
|---|---|---:|---|
| dynamic_csi | temporary_csi | Complete after controlled retry | `run_status.csv`, `dynamic_csi_11c.log` |
| permanent_csi | permanent_csi | Complete | `run_status.csv`, `permanent_csi_11c.log` |

Operational note: the first dynamic run with default threading exited before producing final outputs with a native R error, `double free or corruption (!prev)`. The successful retry used single-threaded runtime settings (`OMP_NUM_THREADS=1`, `OPENBLAS_NUM_THREADS=1`, `MKL_NUM_THREADS=1`, `R_DATATABLE_NUM_THREADS=1`) and completed normally. This did not change code or methodology.

Because the successful runs were launched as background remote processes, the shell `$?` value was not persisted. Completion status is evidenced by `run_status.csv`, `COMPLETE` markers in logs, completed PIDs, and all expected output files.

## Run Status

| Track | Started | Ended | Elapsed minutes | Threshold rows | Weight rows | Return rows | Performance rows | Exclusion rows | Decomposition rows |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| dynamic_csi | 2026-05-28 08:15:47 | 2026-05-28 08:19:16 | 3.49 | 3 | 7,379,966 | 13,728 | 208 | 4,224 | 768 |
| permanent_csi | 2026-05-28 08:21:11 | 2026-05-28 08:22:29 | 1.30 | 3 | 2,199,308 | 4,224 | 64 | 1,056 | 192 |

## Expected Output Check

All expected 11C output families exist for both tracks:

- `index_thresholds_by_crsp_universe`
- `index_weights_by_crsp_universe`
- `index_returns_by_crsp_universe`
- `index_performance_by_crsp_universe`
- `index_exclusion_summary_by_crsp_universe`
- `error_cost_decomposition_by_crsp_universe`
- `run_status.csv`

Compact inventory and row-count evidence:

- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/11c_index/output_inventory.tsv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/11c_index/row_counts.tsv`

Heavy model/index files were not downloaded locally.

## OOS Performance Snapshot

Best model-filtered OOS Sharpe strategy by index:

| Track | Index | Threshold | Rule | Annualized geometric return | Annualized SD | Sharpe | Max drawdown | Difference vs benchmark |
|---|---|---|---|---:|---:|---:|---:|---:|
| dynamic_csi | large_cap | youden | 5yr lockout | 0.1445 | 0.1800 | 0.6784 | -0.2359 | 0.0018 |
| dynamic_csi | mid_cap | fpr3 | 5yr lockout | 0.1003 | 0.2072 | 0.4233 | -0.2447 | 0.0038 |
| dynamic_csi | small_cap | youden | 3yr lockout | 0.0824 | 0.2273 | 0.3330 | -0.2934 | 0.0058 |
| dynamic_csi | total_market | youden | 5yr lockout | 0.1375 | 0.1830 | 0.6366 | -0.2352 | 0.0046 |
| permanent_csi | large_cap | fpr3 | Permanent removal | 0.1443 | 0.1848 | 0.6646 | -0.2464 | 0.0016 |
| permanent_csi | mid_cap | fpr3 | Permanent removal | 0.1011 | 0.2067 | 0.4272 | -0.2444 | 0.0046 |
| permanent_csi | small_cap | fpr1 | Permanent removal | 0.0775 | 0.2354 | 0.3101 | -0.2912 | 0.0010 |
| permanent_csi | total_market | fpr3 | Permanent removal | 0.1346 | 0.1894 | 0.6077 | -0.2482 | 0.0017 |

Metric snapshot files:

- `temporary_csi_index_performance_by_crsp_universe.csv`
- `permanent_csi_index_performance_by_crsp_universe.csv`

## Exclusion And Error-Cost Evidence

Compact snapshots were downloaded for both tracks:

- `temporary_csi_index_exclusion_summary_by_crsp_universe.csv`
- `permanent_csi_index_exclusion_summary_by_crsp_universe.csv`
- `temporary_csi_error_cost_decomposition_by_crsp_universe.csv`
- `permanent_csi_error_cost_decomposition_by_crsp_universe.csv`

OOS error-cost decomposition contains the expected confusion categories for both tracks:

- `false_negative`
- `false_positive`
- `true_negative`
- `true_positive`

## Canonical Output Check

Remote canonical-output recent-write check found no files modified under:

- `03_Data_Output/3_Modelling_Results/Necessary`
- `03_Data_Output/4_IndexConstruction_Results/Necessary`

Evidence:

- `canonical_recent_write_check.txt`

Local git status after evidence collection showed no modified local `03_Data_Output/**` files.

## Forbidden Process Check

Final remote process check found no forbidden project scripts running after 11C completion.

Evidence:

- `process_check_final.txt`

## Evidence Files

Primary report:

- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-006_11C_Index_Rerun_Report.md`

Compact evidence directory:

- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260528_optional_models/11c_index/`

Downloaded compact evidence includes:

- run logs for both tracks
- the initial failed dynamic log
- run-status CSVs
- output inventory
- row counts
- threshold CSVs
- performance CSVs
- exclusion summary CSVs
- error-cost decomposition CSVs
- canonical recent-write check
- forbidden-process check

## Blockers

No remaining blocker for AE-VALIDATE-006.

## Readiness

AE-VALIDATE-006 is ready for validator review. If validator passes, proceed to AE-VALIDATE-007 canonical-versus-validation comparison.
