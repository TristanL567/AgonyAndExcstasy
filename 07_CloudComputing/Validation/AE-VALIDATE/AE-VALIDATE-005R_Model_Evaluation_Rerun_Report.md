# AE-VALIDATE-005R Model Evaluation Rerun Report

## Completion Report

- status: blocked
- summary: Local branch/HEAD and remote input preflight passed, but the required model evaluation could not be completed without changing remote code or using a wrapper. The remote `01_Code/pipeline/config.R` does not support `MT_OUTPUT_DIR`, so `10_Evaluation.R` routes to canonical `/root/AgonyAndExcstasy/03_Data_Output` even when the required validation `MT_OUTPUT_DIR` is present in the remote environment. A valid dynamic-track invocation from the pipeline directory exited 1 after finding zero predictions in canonical output. Permanent-track evaluation was not run after this blocker to avoid further canonical-output writes.
- artifacts: This report only.
- findings: The validated optional-library raw AutoGluon prediction artifacts exist under the validation run root for both tracks, but no `10_Evaluation.R` evaluation outputs were produced under that run root during AE-VALIDATE-005R.
- next_recommended_role: master
- changed_files: `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005R_Model_Evaluation_Rerun_Report.md`
- verification: local git branch/HEAD checked; SSH smoke test passed; remote input root exists; forbidden-process scans were empty; canonical-output post-check returned no paths newer than the baseline outside the validation run root; evaluation output inventory under the validation run root was empty.
- human_readability: The rerun is not validated. The blocker is remote-code capability drift: local branch config supports `MT_OUTPUT_DIR`, but the remote script tree does not.

## Scope

- Ticket: AE-VALIDATE-005R
- Local workspace: `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy`
- Local branch: `validation`
- Local HEAD: `db61acf1ad9f1c3e3b6e9eec0f190a3ca5106920`
- Required base check: `db61acf` is an ancestor of HEAD.
- SSH usage: explicit OpenSSH binary was used for every remote command with the authorized endpoint sanitized as `[authorized endpoint]`.
- Remote root: `/root/AgonyAndExcstasy`
- Input run root / required `MT_OUTPUT_DIR`: `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models`
- Allowed remote script attempted: `01_Code/pipeline/10_Evaluation.R`

## Preflight Evidence

- SSH smoke test: passed (`smoke-ok`).
- Remote input root: exists.
- Input root top-level directories observed:
  - `3_Modelling_Results`
  - `3_Modelling_Results/Necessary`
  - `evidence_compact`
  - `logs`
- Pre-run forbidden-process check: no matching process output.
- Baseline timestamp for canonical modification check: `2026-05-28T07:06:44Z`.

## Evaluation Runs

### dynamic_csi

- Required environment used in the valid invocation:
  - `MT_ROOT=/root/AgonyAndExcstasy`
  - `MT_OUTPUT_DIR=/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models`
  - `MODEL=raw`
  - `RESPONSE_TRACK=dynamic_csi`
- Start: `2026-05-28T07:07:31Z`
- End: `2026-05-28T07:07:33Z`
- Runtime: 2 seconds
- Exit code: 1
- Result: failed before producing evaluation outputs.
- Failure: `config.R` reported `Output : /root/AgonyAndExcstasy/03_Data_Output`; `10_Evaluation.R` then skipped all models because canonical prediction files were not present and errored with `some columns are not in the data.table: track,model,set`.

### permanent_csi

- Exit code: not run.
- Reason: the dynamic run proved the remote script cannot honor the required validation `MT_OUTPUT_DIR`; running permanent would repeat canonical routing and risk additional out-of-scope writes.

## Blocker Detail

Remote `config.R` evidence:

- `grep -n MT_OUTPUT_DIR /root/AgonyAndExcstasy/01_Code/pipeline/config.R` returned no hits.
- Remote config contains `DIR_DATA_OUTPUT <- file.path(DIR_ROOT, "03_Data_Output")`.
- Remote config reads `MT_ROOT` but not `MT_OUTPUT_DIR`.

Local branch evidence:

- Local `01_Code/pipeline/config.R` does support `MT_OUTPUT_DIR`.
- This indicates the remote execution tree is behind the local validation branch for the specific feature required by this ticket.

I did not edit remote code or data, did not create a wrapper, and did not substitute a run-local config file because the ticket explicitly restricted execution to the existing remote script and prohibited code/data edits.

## Expected Evaluation Output Paths

No `10_Evaluation.R` outputs were found under the validation run root. Expected paths, if the remote script honored `MT_OUTPUT_DIR`, would be:

- `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models/3_Modelling_Results/Necessary/temporary_csi/evaluation/eval_performance_all.rds`
- `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models/3_Modelling_Results/Necessary/temporary_csi/evaluation/eval_by_year_all.rds`
- `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models/3_Modelling_Results/Necessary/temporary_csi/evaluation/eval_threshold_all.rds`
- `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models/3_Modelling_Results/Necessary/permanent_csi/evaluation/eval_performance_all.rds`
- `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models/3_Modelling_Results/Necessary/permanent_csi/evaluation/eval_by_year_all.rds`
- `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models/3_Modelling_Results/Necessary/permanent_csi/evaluation/eval_threshold_all.rds`

## Validation Run Root Inventory Snapshot

Existing compact evidence and prediction artifacts from AE-VALIDATE-004R were present under the validation run root.

Prediction artifacts observed:

- `temporary_csi/AutoGluon/ag_raw/ag_preds_test_eval.parquet`
- `temporary_csi/AutoGluon/ag_raw/ag_preds_oos.parquet`
- `temporary_csi/AutoGluon/ag_raw/ag_eval_summary.json`
- `permanent_csi/AutoGluon/ag_raw/ag_preds_test_eval.parquet`
- `permanent_csi/AutoGluon/ag_raw/ag_preds_oos.parquet`
- `permanent_csi/AutoGluon/ag_raw/ag_eval_summary.json`

Existing compact evidence files observed:

- `evidence_compact/inventory.csv`
- `evidence_compact/row_counts.csv`
- `evidence_compact/metric_snapshot.csv`
- `evidence_compact/leaderboard_model_family_rows.csv`
- `evidence_compact/summary.json`
- `evidence_compact/canonical_modification_check.txt`
- `evidence_compact/forbidden_process_check.txt`

## Row Counts

Existing row-count snapshot from the validation run root:

| track | file | rows | columns |
|---|---:|---:|---:|
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

## Metric Snapshot

These metrics are from existing compact evidence under the validation run root, not from a successful AE-VALIDATE-005R `10_Evaluation.R` run.

| track | set | AP | AUC | Recall FPR1 | Recall FPR3 | Recall FPR5 | Recall FPR10 | Brier | n_obs | n_pos |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| dynamic_csi | test_2016_2019 | 0.1985 | 0.8766 | 0.0821 | 0.2002 | 0.2998 | 0.5124 | 0.0389 | 18,111 | 804 |
| dynamic_csi | oos_2020_2024 | 0.3084 | 0.8961 | 0.0915 | 0.2547 | 0.4000 | 0.6556 | 0.0498 | 18,502 | 1,170 |
| permanent_csi | test_2016_2019 | 0.1416 | 0.8810 | 0.0664 | 0.1808 | 0.3007 | 0.5517 | 0.0284 | 18,053 | 542 |
| permanent_csi | oos_2020_2024 | 0.0323 | 0.8081 | 0.0000 | 0.0119 | 0.0623 | 0.2760 | 0.0211 | 26,400 | 337 |

By-year metrics were not available because `10_Evaluation.R` did not complete and no `eval_by_year_all.rds` was produced under the validation run root.

## Forbidden-Script Confirmation

I did not run:

- `09C_AutoGluon.py`
- `11C_IndexConstruction_Revised.R`
- sensitivity scripts
- merge, split, feature, or index-construction pipeline regeneration

Post-run forbidden-process scan returned no matching running processes for:

- `09C_AutoGluon.py`
- `10_Evaluation.R`
- `11C_IndexConstruction_Revised.R`
- sensitivity scripts
- merge/split/feature/index-construction patterns

## Canonical Output Modification Check

The post-check command searched `/root/AgonyAndExcstasy/03_Data_Output` for paths newer than the `2026-05-28T07:06:44Z` baseline while pruning the validation run root. It returned no paths.

Important caveat: the failed dynamic invocation showed `config.R` routing to canonical output and `10_Evaluation.R` printed that figure subdirectories were created under `03_Data_Output`. The post-check did not find paths newer than the baseline, so there is no file-system evidence of new canonical paths from this worker, but the command output confirms the remote script would not safely route evaluation into the validation run root.

## Blockers

1. Remote `config.R` lacks `MT_OUTPUT_DIR` support required by this ticket.
2. A successful validation-routed `10_Evaluation.R` run would require changing remote code, copying a validation-local config, or wrapping the script, all of which were outside the ticket constraints.
3. Because dynamic evaluation failed due to canonical routing, permanent evaluation was intentionally not run.

