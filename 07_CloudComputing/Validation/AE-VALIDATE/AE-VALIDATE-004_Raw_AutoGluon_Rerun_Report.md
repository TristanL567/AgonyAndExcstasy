# AE-VALIDATE-004 Raw AutoGluon Rerun Report

## status

completed

## summary

Reran raw AutoGluon training remotely for both requested response tracks using `RUN_ID=raw_rerun_20260527_230749` and the isolated validation output root:

`/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260527_230749`

Both tracks produced the required validation `ag_raw` outputs: predictions, CV results, leaderboard, and eval summary under the isolated validation root. No evaluation, index construction, sensitivity, or pipeline regeneration scripts were run.

## preflight

- Local branch: `validation`
- Local HEAD recorded before execution: `8ebda0e`
- Confirmed `50318c8` is an ancestor of local HEAD.
- Ticket dependency `AE-VALIDATE-003` was present as local HEAD `8ebda0e`.
- Remote root `/root/AgonyAndExcstasy` exists.
- Remote worktree is not a git checkout, so remote commit identity could not be recorded from git metadata.
- Remote `01_Code/pipeline/09C_AutoGluon.py` was inspected only enough to confirm:
  - `MT_ROOT` is honored for `DATA_ROOT`.
  - absolute `MT_OUTPUT_DIR` overrides `DIR_DATA_OUTPUT`.
  - model outputs route through `DIR_OUTPUT / "3_Modelling_Results" / "Necessary" / TRACK_FOLDER / "AutoGluon" / f"ag_{MODEL}"`.
  - `MODEL` and `RESPONSE_TRACK` are environment-driven.

## commands_run_sanitized

Remote preflight and code inspection used explicit OpenSSH with `[authorized endpoint]`:

```text
C:\Windows\System32\OpenSSH\ssh.exe [authorized endpoint] "test -d /root/AgonyAndExcstasy; inspect 09C_AutoGluon.py MT_OUTPUT_DIR routing"
```

Dynamic CSI raw training:

```text
C:\Windows\System32\OpenSSH\ssh.exe [authorized endpoint] "cd /root/AgonyAndExcstasy && env MT_ROOT=/root/AgonyAndExcstasy MT_OUTPUT_DIR=/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260527_230749 MODEL=raw RESPONSE_TRACK=dynamic_csi python3 01_Code/pipeline/09C_AutoGluon.py > .../logs/09C_raw_dynamic_csi.log 2>&1"
```

Permanent CSI raw training:

```text
C:\Windows\System32\OpenSSH\ssh.exe [authorized endpoint] "cd /root/AgonyAndExcstasy && env MT_ROOT=/root/AgonyAndExcstasy MT_OUTPUT_DIR=/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260527_230749 MODEL=raw RESPONSE_TRACK=permanent_csi python3 01_Code/pipeline/09C_AutoGluon.py > .../logs/09C_raw_permanent_csi.log 2>&1"
```

Remote compact summary generation:

```text
C:\Windows\System32\OpenSSH\ssh.exe [authorized endpoint] "read validation ag_raw outputs and write compact CSV summaries under .../summaries"
```

Downloads used explicit SCP with `[authorized endpoint]` and copied only logs, compact summaries, per-track eval summaries, and per-track leaderboards.

## runtimes

| track_folder | response_track | log_created_utc | log_modified_utc | stage1_autogluon_runtime_s | approximate_script_window |
|---|---:|---:|---:|---:|---:|
| `temporary_csi` | `dynamic_csi` | `2026-05-27 21:13:14Z` | `2026-05-27 21:27:53Z` | `213.72` | about 14m 39s |
| `permanent_csi` | `permanent_csi` | `2026-05-27 21:29:18Z` | `2026-05-27 21:43:36Z` | `205.44` | about 14m 18s |

## remote_outputs

Required outputs exist for both tracks under:

- `3_Modelling_Results/Necessary/temporary_csi/AutoGluon/ag_raw/`
- `3_Modelling_Results/Necessary/permanent_csi/AutoGluon/ag_raw/`

Required files confirmed for both tracks:

- `ag_cv_results.parquet`
- `ag_eval_summary.json`
- `ag_leaderboard.csv`
- `ag_preds_oos.parquet`
- `ag_preds_oos_eval.parquet`
- `ag_preds_test.parquet`
- `ag_preds_test_eval.parquet`
- `ag_preds_train_boundary.parquet`

## metrics_summary

| track_folder | set | metric | value |
|---|---|---:|---:|
| `temporary_csi` | cv | `cv_ap` | `0.2078` |
| `temporary_csi` | cv | `cv_auc` | `0.8699` |
| `temporary_csi` | cv | `cv_r3` | `0.2329` |
| `temporary_csi` | test | `avg_precision` | `0.1888` |
| `temporary_csi` | test | `auc_roc` | `0.8727` |
| `temporary_csi` | test | `recall_fpr3` | `0.1828` |
| `temporary_csi` | oos | `avg_precision` | `0.3063` |
| `temporary_csi` | oos | `auc_roc` | `0.8950` |
| `temporary_csi` | oos | `recall_fpr3` | `0.2624` |
| `permanent_csi` | cv | `cv_ap` | `0.1861` |
| `permanent_csi` | cv | `cv_auc` | `0.8774` |
| `permanent_csi` | cv | `cv_r3` | `0.2485` |
| `permanent_csi` | test | `avg_precision` | `0.1417` |
| `permanent_csi` | test | `auc_roc` | `0.8818` |
| `permanent_csi` | test | `recall_fpr3` | `0.1974` |
| `permanent_csi` | oos | `avg_precision` | `0.0343` |
| `permanent_csi` | oos | `auc_roc` | `0.8153` |
| `permanent_csi` | oos | `recall_fpr3` | `0.0356` |

## row_counts

| track_folder | file | rows | columns | status |
|---|---|---:|---:|---|
| `temporary_csi` | `ag_cv_results.parquet` | `72223` | `5` | ok |
| `temporary_csi` | `ag_eval_summary.json` | `1` | `32` | ok |
| `temporary_csi` | `ag_leaderboard.csv` | `6` | `13` | ok |
| `temporary_csi` | `ag_preds_oos.parquet` | `18502` | `4` | ok |
| `temporary_csi` | `ag_preds_test.parquet` | `18111` | `4` | ok |
| `permanent_csi` | `ag_cv_results.parquet` | `72223` | `5` | ok |
| `permanent_csi` | `ag_eval_summary.json` | `1` | `32` | ok |
| `permanent_csi` | `ag_leaderboard.csv` | `6` | `13` | ok |
| `permanent_csi` | `ag_preds_oos.parquet` | `26400` | `4` | ok |
| `permanent_csi` | `ag_preds_test.parquet` | `18053` | `4` | ok |

Full compact row counts are in `raw_rerun_20260527_230749/summaries/raw_row_counts.csv`.

## artifacts

Local downloaded compact artifacts:

- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/logs/09C_raw_dynamic_csi.log`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/logs/09C_raw_permanent_csi.log`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/summaries/raw_expected_outputs.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/summaries/raw_file_inventory.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/summaries/raw_leaderboards.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/summaries/raw_metric_summary.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/summaries/raw_row_counts.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/track_summaries/temporary_csi_ag_eval_summary.json`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/track_summaries/temporary_csi_ag_leaderboard.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/track_summaries/permanent_csi_ag_eval_summary.json`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/track_summaries/permanent_csi_ag_leaderboard.csv`

Heavy model binaries and full prediction/CV parquet outputs were not downloaded.

## findings

- Both tracks completed and produced required validation `ag_raw` outputs.
- Remote AutoGluon was available, but optional model extras were missing. Logs show LightGBM, CatBoost, FastAI, and XGBoost model families skipped due import errors. AutoGluon still trained RandomForest, ExtraTrees, NeuralNetTorch, and WeightedEnsemble models and wrote required outputs.
- The permanent-track log labels the non-bucket branch as `Dynamic CSI annual target loaded`; this is inherited script wording while `RESPONSE_TRACK=permanent_csi`, track folder, output path, and metrics are permanent-track specific.
- Remote directory is not a git checkout, so only local audited HEAD is recorded for source identity.

## changed_files

Created local evidence files only under `07_CloudComputing/Validation/AE-VALIDATE/**`:

- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-004_Raw_AutoGluon_Rerun_Report.md`
- `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/**`

No local `03_Data_Output/**` files were written. No canonical local modeling or index-construction output files were modified.

## verification

- Confirmed local branch and HEAD:
  - branch `validation`
  - HEAD `8ebda0e`
  - `50318c8` is an ancestor of HEAD.
- Confirmed remote root exists.
- Confirmed remote output isolation in `09C_AutoGluon.py` before running.
- Confirmed required output files exist for both tracks via `raw_expected_outputs.csv`.
- Confirmed row counts and compact metadata via `raw_row_counts.csv` and `raw_file_inventory.csv`.
- Confirmed no remote `python3 01_Code/pipeline/09C_AutoGluon.py` process remained after completion.
- Confirmed local `git diff --name-only` is empty.
- Confirmed local `git status --short --untracked-files=all` shows only the new untracked AE-VALIDATE-004 report and non-ignored compact evidence files.
- Did not run `10_Evaluation.R`, `11C_IndexConstruction_Revised.R`, sensitivity scripts, or pipeline regeneration scripts.
- Did not commit or push.

## git_status_summary

```text
?? 07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-004_Raw_AutoGluon_Rerun_Report.md
?? 07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/summaries/raw_expected_outputs.csv
?? 07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/summaries/raw_file_inventory.csv
?? 07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/summaries/raw_leaderboards.csv
?? 07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/summaries/raw_metric_summary.csv
?? 07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/summaries/raw_row_counts.csv
?? 07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/track_summaries/permanent_csi_ag_eval_summary.json
?? 07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/track_summaries/permanent_csi_ag_leaderboard.csv
?? 07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/track_summaries/temporary_csi_ag_eval_summary.json
?? 07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/track_summaries/temporary_csi_ag_leaderboard.csv
```

No tracked files are modified.

## next_recommended_role

validator

## human_readability

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: This ticket created only local validation evidence and report files under the allowed AE-VALIDATE documentation area, while remote raw AutoGluon outputs were written under the isolated validation output root. No local canonical outputs, code, data, evaluation scripts, index construction scripts, or pipeline regeneration scripts were changed or run.
- layer_touched: infrastructure
- layer_separation_preserved: true
