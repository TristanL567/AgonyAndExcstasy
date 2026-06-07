# AE-SENS-007R 11C Stabilization And Resume Report

## Status

`completed_pending_validator`

AE-SENS-007R stabilized the AE-SENS sensitivity-mode 11C failure path and proved safe resume on one previously failed configuration, `C060_M000_T012`, without restarting the full grid.

## AEGIS Reference

The AEGIS reference at `C:\Users\Tristan Leiter\Documents\aegis-core` was cross-referenced read-only before execution. Relevant role/contract material was found for Master-Agent/Master-Planner/Master-Validator behavior, ticket scope, one-ticket execution, validator blocking, and completion reporting.

## Branch And Scope

- Branch: `development-sensitivity`
- Required base: `00d545f` or descendant
- Observed base before edits: `00d545f AE-SENS-007: record full grid blocker evidence`
- SSH/SCP: explicit OpenSSH/SCP with `[authorized endpoint]` and `[authorized SSH key path]`
- Remote root: `/root/AgonyAndExcstasy`
- Sensitivity root: `/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity`
- Endpoint, port, key path, key contents, credentials, and tokens are intentionally omitted from this report and evidence.

## Failure Reproduction Context

AE-SENS-007 showed five consecutive new configurations completed:

1. `01_prepare_raw_inputs`
2. `02_raw_autogluon`
3. `03_raw_evaluation`

and then failed in:

4. `04_raw_11c_index`

The shared failure signature included:

- R segfault
- `double free or corruption`
- `stack smashing`
- `forderv(x, by = xcols) : bad value`
- call path through `merge.data.table` / `bmerge`
- merge keys around `index_id`, `qdate`, `permno`

The failed configurations are summarized in:

- `AE-SENS-007R_failed_11c_diagnostics.csv`

## Upstream Completeness

Before the resume test, `C060_M000_T012` had complete upstream artifacts for:

- labels
- raw features / split labels
- raw predictions
- raw evaluation

No model training, feature preparation, label generation, or evaluation step was rerun in AE-SENS-007R.

## Fix Applied

Changed file:

- `01_Code/pipeline/11C_IndexConstruction_Revised.R`

The fix is gated to AE-SENS mode where behavior could affect canonical runs:

- `data.table::setDTthreads(1L)` in AE-SENS mode;
- `OMP_NUM_THREADS`, `OPENBLAS_NUM_THREADS`, and `MKL_NUM_THREADS` set to `1` in AE-SENS mode;
- AE-SENS-only join helper for the two 11C sensitivity joins that were implicated by the crash;
- stable join-key coercion before those joins:
  - `index_id` as character
  - `qdate` as `IDate`/Date
  - `permno` as integer
- explicit drop of rows with missing join keys before those AE-SENS joins;
- compact per-join key diagnostics written to `ae_sens_11c_merge_diagnostics.csv`.

Canonical non-sensitivity behavior is preserved: outside AE-SENS mode, the helper delegates to the original `merge(..., all.x = TRUE)` behavior.

## Resume Test

Only the 11C step was rerun for:

- `C060_M000_T012`

Environment:

- `MT_ROOT=/root/AgonyAndExcstasy`
- `AE_SENS_OUTPUT_ROOT=/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity`
- `AE_SENS_RUN_ID=C060_M000_T012`
- `MODEL=raw`
- `RESPONSE_TRACK=dynamic_csi`

Command class:

- `Rscript 11C_IndexConstruction_Revised.R`

Forbidden commands were not run:

- no `09C_AutoGluon.py`
- no `ae_sens_prepare_raw_inputs.R`
- no `ae_sens_eval_raw.R`
- no full-grid driver
- no permanent-CSI sensitivity
- no non-raw model family
- no pipeline regeneration

## Resume Result

The 11C-only resume exited `0` for `C060_M000_T012`.

Summary from `AE-SENS-007R_single_run_resume_status.csv`:

| run_id | resumed_step | upstream_steps_rerun | exit_code | status | required_outputs_present | elapsed_minutes | n_weight_rows | n_return_rows | n_exclusion_rows | n_decomposition_rows |
|---|---|---|---:|---|---|---:|---:|---:|---:|---:|
| C060_M000_T012 | 04_raw_11c_index_only | none | 0 | completed | True | 3.8628 | 6,865,721 | 13,728 | 4,224 | 768 |

Required outputs are present:

- `index_thresholds_by_crsp_universe.csv`
- `index_returns_by_crsp_universe.csv`
- `index_performance_by_crsp_universe.csv`
- `index_exclusion_summary_by_crsp_universe.csv`
- `error_cost_decomposition_by_crsp_universe.csv`
- `run_status.csv`

Output inventory:

- `AE-SENS-007R_11c_output_inventory.csv`

## Merge-Key Diagnostics

Diagnostics file:

- `AE-SENS-007R_merge_key_diagnostics.csv`

Observed diagnostics:

- 192 diagnostic rows
- 96 exclusion-summary join diagnostics
- 96 error-cost-decomposition join diagnostics
- dropped NA-key rows: `0`
- exclusion-summary duplicate key count: `0`
- error-cost decomposition duplicate keys occur only on the monthly left side, which is expected because each `(index_id, qdate, permno)` can map to multiple holding months.

This supports a runtime/threading and key-normalization stabilization fix rather than a malformed-key data issue.

## Guardrails

- Canonical-output check: no canonical `temporary_csi` or `permanent_csi` files were modified during AE-SENS-007R.
- Remote process guard: no forbidden AE-SENS/AutoGluon/evaluation/11C process remained after the resume test.
- No full-grid restart occurred.
- The known unrelated AE-VALIDATE blocker reports remain unrelated and must not be staged with this ticket.

Guardrail files:

- `AE-SENS-007R_canonical_modification_check.txt`
- `AE-SENS-007R_remote_process_guard.txt`

## Verification

Local:

- Parsed `01_Code/pipeline/11C_IndexConstruction_Revised.R` with local R.

Remote:

- Confirmed no forbidden remote process before resume.
- Confirmed upstream artifacts for `C060_M000_T012` existed before rerunning 11C.
- Synced only the scoped changed 11C script to remote code.
- Reran only `11C_IndexConstruction_Revised.R` for `C060_M000_T012`.
- Verified all required 11C outputs exist.
- Verified canonical-output guard.
- Verified no forbidden remote processes remained.

## Readiness For Follow-Up

AE-SENS-007R is ready for validator review. If validator approves, the next ticket should be `AE-SENS-007S`: resume the full grid from the existing state, reusing completed pilots and the now-fixed `C060_M000_T012`, while handling incomplete run directories with explicit safe-resume semantics.

