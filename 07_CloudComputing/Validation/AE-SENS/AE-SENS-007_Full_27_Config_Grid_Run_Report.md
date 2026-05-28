# AE-SENS-007 Full 27-Config Grid Run Report

## Status

`blocked_validated`

AE-SENS-007 was started on branch `development-sensitivity` from HEAD `25a2a27` or descendant. The ticket did not complete the full grid because the first five newly executed configurations all failed in the same `04_raw_11c_index` step with R/data.table memory-corruption symptoms. After the fifth consecutive shared 11C failure, the driver was stopped to avoid converting a shared runner/index issue into 27 repeated failures.

No validation, AE-VALIDATE, permanent-CSI sensitivity, non-raw model, presentation, documentation cleanup, pipeline regeneration, or canonical-output work was run.

## AEGIS Reference

The AEGIS reference at `C:\Users\Tristan Leiter\Documents\aegis-core` was cross-referenced read-only before execution. Relevant role/contract material was found for Master-Agent/Master-Planner/Master-Validator behavior, one-ticket execution, ticket scope rules, validator blocking, and completion reporting.

## Branch And Scope

- Local branch: `development-sensitivity`
- Required base: `25a2a27` or descendant
- Observed start HEAD: `25a2a27 AE-SENS-006: compare pilot configs and recommend go no-go`
- Remote root: `/root/AgonyAndExcstasy`
- Remote sensitivity root: `/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity`
- SSH/SCP: explicit OpenSSH/SCP with `[authorized endpoint]` and `[authorized SSH key path]`
- Endpoint, port, key contents, credentials, and tokens are intentionally omitted from this report.

## Execution Summary

A ticket-local full-grid driver was created and uploaded under the remote sensitivity logs area. The driver:

- covered the approved 27 run IDs;
- used `MT_ROOT=/root/AgonyAndExcstasy`;
- used `AE_SENS_OUTPUT_ROOT=/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity`;
- used `MODEL=raw`;
- used `RESPONSE_TRACK=dynamic_csi`;
- reused completed run IDs only if required output families and status markers were complete;
- did not delete or overwrite existing run directories;
- marked partial directories as blocked rather than overwriting;
- continued across isolated per-run failures until a shared failure pattern was detected.

The driver began at `2026-05-28T15:04:04+00:00`. It was stopped after repeated shared 11C failures. No AE-SENS process remained after termination.

## Grid Status

The expanded 27-row status is in:

- `AE-SENS-007_full_grid_status.csv`

Status counts:

| status | count |
|---|---:|
| failed | 5 |
| interrupted_after_shared_11c_block | 1 |
| not_started_due_shared_11c_block | 19 |
| reusable_completed_pilot_not_reprocessed | 2 |

The completed AE-SENS-005 pilots were not overwritten:

- `C080_M020_T018`
- `C090_M020_T028`

They are marked reusable, but the AE-SENS-007 driver stopped before reaching their reuse checks.

## Shared Failure Evidence

The first five newly executed configurations completed:

1. labels/features
2. raw AutoGluon
3. raw evaluation

All five failed in:

4. `04_raw_11c_index`

Failed configurations:

| run_id | exit_code | failed step |
|---|---:|---|
| C060_M000_T012 | 139 | 04_raw_11c_index |
| C060_M000_T018 | 134 | 04_raw_11c_index |
| C060_M000_T028 | 139 | 04_raw_11c_index |
| C060_M020_T012 | 134 | 04_raw_11c_index |
| C060_M020_T018 | 134 | 04_raw_11c_index |

The stderr tails show repeated R process crashes around `data.table` merge/forder operations, including:

- `caught segfault`
- `memory not mapped`
- `Error in forderv(x, by = xcols) : bad value`
- `double free or corruption (!prev)`
- `stack smashing detected`

This is a shared 11C stability/path issue, not five independent modeling failures. Evidence is in:

- `AE-SENS-007_failed_11c_stderr_tail.txt`
- `AE-SENS-007_full_grid_step_status.csv`
- `AE-SENS-007_remote_driver_status.csv`
- `AE-SENS-007_full_grid_driver_stdout.log`
- `AE-SENS-007_full_grid_driver_stderr.log`

## Partial Outputs

Compact evidence was collected for the reached configurations:

- label diagnostics for six runs that reached label generation;
- raw AutoGluon optional-family evidence for reached model runs;
- raw model/evaluation metrics for the five runs that completed evaluation;
- output inventory across all 27 run IDs;
- 11C partial summaries where files existed before the R crash.

Evidence files:

- `AE-SENS-007_full_grid_label_counts.csv`
- `AE-SENS-007_full_grid_model_metrics.csv`
- `AE-SENS-007_full_grid_prediction_row_counts.csv`
- `AE-SENS-007_full_grid_11c_summary.csv`
- `AE-SENS-007_full_grid_optional_family_evidence.csv`
- `AE-SENS-007_full_grid_output_inventory.csv`

The interrupted sixth run was:

- `C060_M020_T028`

It was stopped during `02_raw_autogluon` after the repeated 11C failure pattern had already been established.

## Guardrails

- Canonical-output check: no canonical `temporary_csi` or `permanent_csi` files under the remote canonical modelling output tree were modified after AE-SENS-007 started.
- Remote process guard: no `full_grid_driver`, `run_ae_sens_raw_one`, `09C_AutoGluon.py`, `ae_sens_eval_raw`, or `11C_IndexConstruction_Revised` process remained after stopping.
- No endpoint, port, key contents, credentials, or tokens are present in the local evidence.
- The two known unrelated AE-VALIDATE blocker reports remain unrelated and must not be staged with this ticket.

Guardrail files:

- `AE-SENS-007_canonical_modification_check.txt`
- `AE-SENS-007_remote_process_guard.txt`

## Blocker

The full grid cannot safely continue within AE-SENS-007 as originally scoped because several run-specific output directories are now non-empty and incomplete, and the validated runner intentionally fails closed on non-empty destinations.

Continuing without a scoped fix would require either overwriting partial run outputs or improvising resume behavior, both outside the safe execution rules of this ticket.

## Recommended Follow-Up

Create a scoped AE-SENS-007R blocker-resolution ticket to:

1. diagnose the `11C_IndexConstruction_Revised.R` crash on high-positive C/M/T sensitivity outputs;
2. test the smallest safe mitigation, likely starting with single-threaded `data.table`/OpenMP execution for the 11C step;
3. define explicit safe-resume semantics for failed sensitivity run IDs without deleting or overwriting existing run directories;
4. retry only the failed/interrupted/not-started grid configurations under the same approved sensitivity root;
5. preserve the completed AE-SENS-005 pilots and any completed labels/raw-model/evaluation outputs where validator-approved.

## Readiness Decision

AE-SENS-007 is not ready for AE-SENS-008 ranking/comparison. The correct next step is a focused AE-SENS-007R shared-11C stability and safe-resume ticket.

