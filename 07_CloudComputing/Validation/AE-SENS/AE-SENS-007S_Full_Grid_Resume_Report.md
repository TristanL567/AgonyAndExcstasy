# AE-SENS-007S Full Grid Resume Report

## Status

AE-SENS-007S completed the storage-aware continuation with **validated partial completion**.

The storage-aware driver covered all 27 temporary-CSI C/M/T run IDs. It completed or reused 24 run IDs and marked 3 run IDs as `blocked_partial` because their non-empty partial directories lacked documented safe overwrite/resume semantics. It did not overwrite completed pilot, AE-SENS-007R, or earlier resumed outputs.

## AEGIS Reference

Before continuing the ticket, the worker cross-referenced `C:\Users\Tristan Leiter\Documents\aegis-core` as read-only reference material. Relevant AEGIS role and ticket-scope rules were found and followed: one ticket at a time, validator blockers are blocking by default, scope boundaries are binding, and unrelated files must not be staged or committed.

## Branch And Base

- Local branch: `development-sensitivity`
- Local HEAD at storage-aware continuation start: `c34cf3a AE-SENS-007S: resume full CMT sensitivity grid`
- Required base: `876b40e` or descendant
- Endpoint recorded in evidence as: `[authorized endpoint]`
- SSH key recorded in evidence as: `[authorized SSH key path]`

## Execution Scope

Remote environment used:

- `MT_ROOT=/root/AgonyAndExcstasy`
- `AE_SENS_OUTPUT_ROOT=/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity`
- `MODEL=raw`
- `RESPONSE_TRACK=dynamic_csi`

Allowed remote writes were confined to the sensitivity root. No canonical local or remote outputs were targeted.

## Storage-Aware Amendment

The storage policy was applied before launching more configurations:

- Heavy AutoGluon predictor/model directories were pruned only after retained prediction, evaluation, compact metadata, optional-family, and 11C coverage checks passed.
- Predictions, evaluation metrics, compact model metadata, compact hyperparameter metadata, optional-family evidence, and 11C outputs were retained.
- Duplicate multi-GB `index_weights_by_crsp_universe.csv` files were removed where `index_weights_by_crsp_universe.rds` existed and compact checks were retained.
- Completed runs were rechecked after pruning; final retention coverage was written to local compact CSV evidence.

The remote filesystem had previously reached 100% usage during AE-SENS-007S. After storage-aware pruning and continuation, the final sensitivity-root disk state was:

- Size: 100G
- Used: 66G
- Available: 35G
- Use: 66%

The final retention script pass reported no further deletions because the heavy artifacts had already been pruned before the final all-run coverage snapshot. The authoritative coverage files are:

- `AE-SENS-007S_storage_retention_report.csv`
- `AE-SENS-007S_disk_after.txt`
- `AE-SENS-007S_retained_file_inventory.csv`
- `AE-SENS-007S_deleted_file_inventory.csv`
- `AE-SENS-007S_metric_coverage_check.csv`
- `AE-SENS-007S_metric_artifact_coverage.csv`
- `AE-SENS-007S_11c_coverage_check.csv`

## Final Grid Status

Status rows recorded: 27 of 27 run IDs.

| Status | Count | Meaning |
|---|---:|---|
| `completed_full_storage_pruned` | 14 | Full isolated raw-only run completed and storage policy applied |
| `skipped_complete_storage_pruned` | 10 | Existing complete run reused and retention coverage verified |
| `blocked_partial` | 3 | Non-empty partial outputs lacked documented safe overwrite/resume semantics |

Completed or reused run IDs:

- `C090_M000_T012`, `C090_M000_T018`, `C090_M000_T028`
- `C090_M020_T012`, `C090_M020_T018`, `C090_M020_T028`
- `C090_M030_T012`, `C090_M030_T018`, `C090_M030_T028`
- `C080_M000_T028`
- `C080_M020_T012`, `C080_M020_T018`, `C080_M020_T028`
- `C080_M030_T012`, `C080_M030_T018`, `C080_M030_T028`
- `C060_M000_T012`, `C060_M000_T018`, `C060_M000_T028`
- `C060_M020_T012`, `C060_M020_T018`
- `C060_M030_T012`, `C060_M030_T018`, `C060_M030_T028`

Blocked partial run IDs:

- `C080_M000_T012`
- `C080_M000_T018`
- `C060_M020_T028`

These were intentionally not overwritten. Each has an actionable `blocked_partial` row in `AE-SENS-007S_failed_runs.csv`.

## Coverage Checks

Metric coverage:

- 76 split-level metric rows passed coverage checks.
- 5 split-level metric rows were missing, all tied to blocked partial runs.
- 24 run IDs had complete prediction, evaluation, metric, and optional-family compact artifact coverage.
- 3 run IDs were incomplete because they are blocked partials.

11C coverage:

- 264 11C output-family rows existed.
- 33 11C output-family rows were missing, corresponding to the 3 blocked partial runs across 11 required 11C families each.

Required metric coverage retained for completed/reused runs includes AP, AUC, recall at FPR 1%, 3%, and 5%, Brier where available, row counts, and positive counts by split.

## Safety Checks

- No AE-SENS storage-aware resume driver process remained after completion.
- No `run_ae_sens_raw_one.sh`, `09C_AutoGluon.py`, `ae_sens_eval_raw.R`, or `11C_IndexConstruction_Revised.R` process remained after completion.
- No recent non-sensitivity output writes were found under remote `03_Data_Output`.
- No canonical local outputs were modified.
- No permanent-CSI sensitivity runs were started.
- No non-raw model families were requested beyond AutoGluon's raw model family set.
- No endpoint, port, private key contents, tokens, or credentials are recorded in this report.

## Evidence Files

Local compact evidence under `07_CloudComputing/Validation/AE-SENS/`:

- `AE-SENS-007S_full_grid_status.csv`
- `AE-SENS-007S_full_grid_step_status.csv`
- `AE-SENS-007S_resume_decisions.csv`
- `AE-SENS-007S_failed_runs.csv`
- `AE-SENS-007S_storage_aware_status.csv`
- `AE-SENS-007S_storage_aware_step_status.csv`
- `AE-SENS-007S_storage_aware_resume_decisions.csv`
- `AE-SENS-007S_storage_retention_report.csv`
- `AE-SENS-007S_retained_file_inventory.csv`
- `AE-SENS-007S_deleted_file_inventory.csv`
- `AE-SENS-007S_metric_coverage_check.csv`
- `AE-SENS-007S_metric_artifact_coverage.csv`
- `AE-SENS-007S_11c_coverage_check.csv`
- `AE-SENS-007S_remote_process_guard.txt`
- `AE-SENS-007S_canonical_modification_check.txt`
- `AE-SENS-007S_storage_aware_resume_driver.sh`
- `AE-SENS-007S_storage_retention_remote.py`

The earlier compact full-grid metric, prediction-row-count, label-count, optional-family, 11C-summary, and output-inventory files remain as previously collected evidence, while the storage-aware status and retention files are the authoritative continuation evidence for this amendment.

## Readiness Decision

AE-SENS-007S is ready for validator review as **completed with validated partials**.

Recommended follow-up:

- A narrow ticket should decide whether to clear and rerun the 3 blocked partial run IDs, or leave them excluded from AE-SENS-008 ranking with explicit caveats.
- AE-SENS-008 can rank and compare the 24 complete/reused run IDs immediately if the validator accepts partial-grid analysis.

## Conclusion

The storage-aware continuation materially reduced storage pressure, completed the remaining safe C090/C080/C060 work, preserved required reporting evidence for completed runs, and avoided unsafe overwrites of partial directories. No further broad grid restart should be attempted without an explicit partial-run cleanup policy.
