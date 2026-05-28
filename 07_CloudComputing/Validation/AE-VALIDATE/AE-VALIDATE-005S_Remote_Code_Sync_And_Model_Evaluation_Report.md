# AE-VALIDATE-005S Remote Code Sync And Model Evaluation Report

## status

completed

## summary

AE-VALIDATE-005S fixed the remote code drift that blocked AE-VALIDATE-005R. Local `validation` branch code already supported `MT_OUTPUT_DIR`; the remote `01_Code/pipeline/config.R` did not. I synced only `01_Code/**` to the authorized remote workspace, confirmed remote `MT_OUTPUT_DIR` support, and reran only `01_Code/pipeline/10_Evaluation.R` for the optional raw AutoGluon outputs.

Both requested evaluation tracks exited 0:

| RESPONSE_TRACK | MODEL | exit_code |
|---|---:|---:|
| dynamic_csi | raw | 0 |
| permanent_csi | raw | 0 |

No blockers remain for this ticket.

## artifacts

Report artifact:

- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005S_Remote_Code_Sync_And_Model_Evaluation_Report.md`

Remote validation run root:

- `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models`

Evaluation outputs created or refreshed under:

- `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models/3_Modelling_Results/Necessary/temporary_csi/evaluation`
- `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models/3_Modelling_Results/Necessary/permanent_csi/evaluation`

## findings

- Local branch was `validation`.
- Local HEAD was `db61acf1ad9f1c3e3b6e9eec0f190a3ca5106920`, exactly the required base commit and therefore a valid descendant.
- Local `01_Code/pipeline/config.R` contained `MT_OUTPUT_DIR` support at lines 190-192.
- Remote SSH smoke test succeeded against `[authorized endpoint]`.
- Remote root `/root/AgonyAndExcstasy` existed.
- Remote `config.R` initially had no `MT_OUTPUT_DIR` match.
- After scoped sync, remote `grep -n MT_OUTPUT_DIR /root/AgonyAndExcstasy/01_Code/pipeline/config.R` returned:

```text
190:MT_OUTPUT_DIR <- Sys.getenv("MT_OUTPUT_DIR", unset = "")
191:DIR_DATA_OUTPUT <- if (nzchar(MT_OUTPUT_DIR) && fn_is_absolute_path(MT_OUTPUT_DIR)) {
192:  MT_OUTPUT_DIR
```

This confirms the issue was remote code drift, not a local code-change ticket.

## next_recommended_role

validator

## changed_files

Local files intentionally changed:

- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005S_Remote_Code_Sync_And_Model_Evaluation_Report.md`

Unrelated local files listed in the ticket were not edited. No staging, commit, or push was performed.

## verification

Preflight:

| check | result |
|---|---|
| local branch | `validation` |
| local HEAD | `db61acf1ad9f1c3e3b6e9eec0f190a3ca5106920` |
| `db61acf` ancestor of HEAD | yes |
| local `MT_OUTPUT_DIR` support | present |
| remote SSH smoke | succeeded |
| remote root | exists |
| remote config before sync | `MT_OUTPUT_DIR` absent |
| remote config after sync | `MT_OUTPUT_DIR` present |

Confinement checks:

| check | result |
|---|---|
| files modified outside validation run root after evaluation start | none found |
| canonical outputs modified after evaluation start, excluding `/03_Data_Output/validation/**` | none found |
| forbidden process check after runs | no matching active forbidden process found |

Forbidden scripts were not invoked by this worker:

- `09C_AutoGluon.py`
- `11C_IndexConstruction_Revised.R`
- sensitivity scripts
- merge, split, feature, label, or index regeneration scripts

## human_readability

The remote lacked the local `MT_OUTPUT_DIR` override, so the prior evaluation reroute could not be trusted. Syncing only `01_Code/**` corrected the remote config without uploading data, canonical outputs, presentations, or secrets. The subsequent evaluation runs wrote to the requested validation output root and did not touch canonical outputs.

## sanitized_commands

Endpoint details are intentionally replaced with `[authorized endpoint]`.

```text
ssh.exe [authorized endpoint] "printf 'ssh_smoke=ok'"
ssh.exe [authorized endpoint] "test -d /root/AgonyAndExcstasy ..."
ssh.exe [authorized endpoint] "grep -n MT_OUTPUT_DIR /root/AgonyAndExcstasy/01_Code/pipeline/config.R"
scp.exe 01_Code/** [authorized endpoint]:/root/AgonyAndExcstasy/
ssh.exe [authorized endpoint] "cd /root/AgonyAndExcstasy/01_Code/pipeline && env MT_ROOT=/root/AgonyAndExcstasy MT_OUTPUT_DIR=/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models MODEL=raw RESPONSE_TRACK=dynamic_csi Rscript 10_Evaluation.R"
ssh.exe [authorized endpoint] "cd /root/AgonyAndExcstasy/01_Code/pipeline && env MT_ROOT=/root/AgonyAndExcstasy MT_OUTPUT_DIR=/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models MODEL=raw RESPONSE_TRACK=permanent_csi Rscript 10_Evaluation.R"
```

## synced_code_scope

Uploaded scope:

- `01_Code/**`

Excluded by scope:

- data
- canonical outputs
- presentations
- secrets
- reports
- AEGIS core references

## exit_codes

| operation | exit_code |
|---|---:|
| remote SSH smoke | 0 |
| remote root check | 0 |
| remote config grep before sync | no match |
| scoped `01_Code/**` upload | 0 |
| remote config grep after sync | 0 |
| `10_Evaluation.R` with `RESPONSE_TRACK=dynamic_csi` | 0 |
| `10_Evaluation.R` with `RESPONSE_TRACK=permanent_csi` | 0 |

## paths

Input/output root used for both evaluation runs:

- `/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260528_optional_models`

Executed script:

- `/root/AgonyAndExcstasy/01_Code/pipeline/10_Evaluation.R`

Evaluation output inventory:

| track folder | evaluation tables | figures |
|---|---:|---:|
| `temporary_csi` | 3 RDS files | 10 PNG files |
| `permanent_csi` | 3 RDS files | 10 PNG files |

Per track, the table outputs were:

- `eval_performance_all.rds`
- `eval_by_year_all.rds`
- `eval_threshold_all.rds`

Per track, the figure outputs were:

- `figures/comparison/compare_ap_bar.png`
- `figures/comparison/compare_auc_bar.png`
- `figures/comparison/compare_fpr_bar.png`
- `figures/comparison/compare_heatmap.png`
- `figures/csi/m3/M3_calibration.png`
- `figures/csi/csi_pr_curves.png`
- `figures/csi/csi_roc_curves.png`
- `figures/csi/csi_calibration.png`
- `figures/csi/csi_score_dist.png`
- `figures/csi/csi_year_ap.png`

## row_counts

Input prediction rows loaded by `10_Evaluation.R`:

| RESPONSE_TRACK | model | test rows | oos rows |
|---|---|---:|---:|
| dynamic_csi | raw | 18,111 | 18,502 |
| permanent_csi | raw | 18,053 | 26,400 |

Evaluation RDS row counts:

| RESPONSE_TRACK | eval_performance_all | eval_by_year_all | eval_threshold_all |
|---|---:|---:|---:|
| dynamic_csi | 2 | 8 | 0 |
| permanent_csi | 2 | 9 | 0 |

Metric row observation counts:

| RESPONSE_TRACK | set | n_obs | n_pos | prevalence |
|---|---|---:|---:|---:|
| dynamic_csi | test | 18,111 | 804 | 0.0444 |
| dynamic_csi | oos_2020_2022 | 14,799 | 1,154 | 0.0780 |
| permanent_csi | test | 18,053 | 542 | 0.0300 |
| permanent_csi | oos_2020_2022 | 15,465 | 337 | 0.0218 |

## metrics

Metric snapshot for `model=raw`:

| RESPONSE_TRACK | set | AP | AUC | R@FPR1 | R@FPR3 | R@FPR5 | Brier |
|---|---|---:|---:|---:|---:|---:|---:|
| dynamic_csi | test | 0.1978 | 0.8766 | 0.0821 | 0.2002 | 0.2998 | 0.0389 |
| dynamic_csi | oos_2020_2022 | 0.3784 | 0.8958 | 0.1161 | 0.2738 | 0.4116 | 0.0601 |
| permanent_csi | test | 0.1405 | 0.8810 | 0.0664 | 0.1808 | 0.3007 | 0.0284 |
| permanent_csi | oos_2020_2022 | 0.1387 | 0.8769 | 0.1217 | 0.2908 | 0.3858 | 0.0214 |

## blockers

None.
