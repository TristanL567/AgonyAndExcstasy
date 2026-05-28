# AE-SENS-007S Full Grid Resume Report

## Status

AE-SENS-007S is **blocked with validated partial progress**.

The resumed full-grid driver respected run-id isolation and stopped after a shared resource blocker was identified. It did not restart the full grid from scratch, did not overwrite completed pilot or AE-SENS-007R outputs, and did not run non-raw or permanent-CSI sensitivity work.

## Branch And Base

- Local branch: `development-sensitivity`
- Local HEAD at execution: `876b40e AE-SENS-007R: stabilize sensitivity 11C resume path`
- Required base: `876b40e` or descendant
- SSH/SCP contract followed with explicit OpenSSH and the authorized SSH key path.
- Reports and local evidence sanitize the endpoint and key path as `[authorized endpoint]` and `[authorized SSH key path]`.

## Execution Scope

Remote environment used:

- `MT_ROOT=/root/AgonyAndExcstasy`
- `AE_SENS_OUTPUT_ROOT=/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity`
- `MODEL=raw`
- `RESPONSE_TRACK=dynamic_csi`

Allowed remote writes were confined to the sensitivity root. No canonical local or remote outputs were targeted.

## Resume Driver

Created and uploaded a ticket-local resume driver:

- Local evidence copy: `AE-SENS-007S_resume_driver.sh`
- Remote execution location: sensitivity log folder for `AE-SENS-007S_full_grid_resume`

The first driver attempt exposed a ticket-local working-directory bug for resumed R-only steps: `11C_IndexConstruction_Revised.R` sources `config.R` relative to the pipeline directory. The driver was corrected to run resumed R steps from `MT_ROOT/01_Code/pipeline`. No project source code was changed for this fix.

## Progress Summary

Status rows recorded: 10 of 27 run IDs.

| Status | Count | Meaning |
|---|---:|---|
| `skipped_complete` | 1 | Existing complete run reused |
| `completed_resume_11c` | 4 | Previously failed runs resumed from 11C only |
| `completed_full` | 3 | Previously not-started runs completed all four steps |
| `blocked_partial` | 1 | Partial non-empty output state lacked documented safe resume semantics |
| `failed_full` | 1 | Full run failed after shared disk exhaustion |

Completed/reused/resumed run IDs:

- `C060_M000_T012` reused complete from AE-SENS-007R.
- `C060_M000_T018` resumed 11C only.
- `C060_M000_T028` resumed 11C only.
- `C060_M020_T012` resumed 11C only.
- `C060_M020_T018` resumed 11C only.
- `C060_M030_T012` completed full raw-only run.
- `C060_M030_T018` completed full raw-only run.
- `C060_M030_T028` completed full raw-only run.

Incomplete/actionable run IDs:

- `C060_M020_T028`: `blocked_partial`; it had non-empty partial raw outputs but missing required AutoGluon summary/evaluation/11C outputs. No documented safe overwrite/resume point exists for that state.
- `C080_M000_T012`: `failed_full`; failed during AutoGluon CV output writing with `OSError: [Errno 28] No space left on device`.

## Shared Blocker

The remote filesystem filled during `C080_M000_T012`.

Evidence:

- `df -h` showed `/`, `/root/AgonyAndExcstasy`, and `/tmp` at `100%`.
- `df -B1` showed `107,374,182,400` bytes used and `0` bytes available on the overlay filesystem.
- The failing log for `C080_M000_T012` showed:
  - Stage 1 AutoGluon training completed.
  - Prediction files were generated.
  - Failure occurred during CV training output persistence.
  - Error: `OSError: [Errno 28] No space left on device`.

Because disk exhaustion is a shared resource blocker, the remote driver and remaining child process were stopped before creating repeated partial failures.

## Safety Checks

- No `09C_AutoGluon.py`, `ae_sens_eval_raw.R`, `11C_IndexConstruction_Revised.R`, `run_ae_sens_raw_one.sh`, or resume-driver process remained after stopping.
- Canonical-output check found no recent non-sensitivity output writes.
- No permanent-CSI sensitivity runs were started.
- No non-raw model families were requested beyond AutoGluon's raw model family set.
- No full grid restart occurred over existing complete directories.
- No endpoint, port, key contents, tokens, or credentials are recorded in this report.

## Evidence Files

Local compact evidence created under `07_CloudComputing/Validation/AE-SENS/`:

- `AE-SENS-007S_full_grid_status.csv`
- `AE-SENS-007S_full_grid_step_status.csv`
- `AE-SENS-007S_resume_decisions.csv`
- `AE-SENS-007S_failed_runs.csv`
- `AE-SENS-007S_full_grid_label_counts.csv`
- `AE-SENS-007S_full_grid_model_metrics.csv`
- `AE-SENS-007S_full_grid_prediction_row_counts.csv`
- `AE-SENS-007S_full_grid_11c_summary.csv`
- `AE-SENS-007S_full_grid_optional_family_evidence.csv`
- `AE-SENS-007S_full_grid_output_inventory.csv`
- `AE-SENS-007S_remote_process_guard.txt`
- `AE-SENS-007S_canonical_modification_check.txt`
- `AE-SENS-007S_resume_driver.sh`
- `AE-SENS-007S_collect_remote_compact.py`

## Readiness Decision

AE-SENS-007S should not continue on the current remote filesystem state.

Recommended next ticket:

- Free or provision sufficient remote disk capacity without deleting completed sensitivity evidence unless explicitly scoped.
- Document the disk cleanup/provisioning action.
- Resume from the current state with the same safe semantics:
  - reuse completed runs;
  - keep `C060_M020_T028` blocked until a scoped partial-output policy is approved;
  - rerun or safely resume `C080_M000_T012` only after its disk-full partial outputs are classified;
  - continue remaining not-started configs without overwriting complete outputs.

## Conclusion

AE-SENS-007S made valid progress and then stopped on a real shared resource blocker. The correct outcome is **blocked_validated: remote disk full**, not a pipeline redesign or unsafe restart.
