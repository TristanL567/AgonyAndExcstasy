# AE-VALIDATE-005 Model Evaluation Rerun Report

## status

blocked

## summary

Remote evaluation could not be started because no locally discoverable authorized SSH endpoint was reachable from this worker session. The local ticket preflight passed: the workspace is on branch `validation` at `5d706ef`, and `5d706ef` is the current HEAD. The evaluation script was inspected read-only and appears safe to invoke for this ticket when a live endpoint is available: it reads existing AutoGluon prediction/evaluation files from `MT_OUTPUT_DIR`, routes outputs through the active `RESPONSE_TRACK`, skips missing non-raw model inputs, and does not invoke training, 11C index construction, sensitivity scripts, or pipeline regeneration scripts.

No remote evaluation command was run. No model training command was run. No remote writes were confirmed. No local `03_Data_Output/**` files were written.

## artifacts

- This blocker report: `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md`
- Existing AE-VALIDATE-004 local compact evidence remains available under `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/**`.
- No AE-VALIDATE-005 metric summaries or logs were downloaded because the remote evaluation did not start.

## findings

- Blocking issue: all locally discoverable direct SSH endpoints failed before remote preflight could verify `/root/AgonyAndExcstasy` or the validation output root.
- Observed failure classes were SSH banner exchange connection refusals and connection timeout. Endpoint details are intentionally omitted.
- Because remote preflight could not complete, validation evaluation outputs for `dynamic_csi` and `permanent_csi` were not produced or verified during this ticket run.
- Missing non-raw model rows remain expected for this epic's raw-only scope, but this could not be validated against fresh AE-VALIDATE-005 evaluation outputs because evaluation did not run.

## next_recommended_role

master

## preflight

- AEGIS reference material was loaded read-only from `C:\Users\Tristan Leiter\Documents\aegis-core`, including `AEGIS.md`, the ticket and swarm contracts, master role, shared orchestration loop, project application runbook, operating discipline, model-interpreter worker, DS validator, and ticket-scope validation procedure.
- Ticket scope was treated as one-ticket-only execution. No adjacent AE-VALIDATE ticket was started.
- Local branch: `validation`
- Local HEAD: `5d706ef AE-VALIDATE-004: add raw AutoGluon rerun evidence`
- Local status before creating this report: clean.
- Existing local AE-VALIDATE-004 compact evidence path exists:
  - `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749/`
- Local validation output root under `03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260527_230749` does not exist and was not created.

## script_inspection

Inspected `01_Code/pipeline/10_Evaluation.R` and `01_Code/pipeline/config.R` only enough to determine safe invocation.

Relevant behavior:

- `config.R` reads `MT_ROOT` through `Sys.getenv("MT_ROOT", unset = here::here())`.
- `config.R` uses an absolute `MT_OUTPUT_DIR` as `DIR_DATA_OUTPUT`.
- `config.R` reads `RESPONSE_TRACK` and maps `dynamic_csi` to the `temporary_csi` folder while leaving `permanent_csi` as `permanent_csi`.
- `10_Evaluation.R` reads `ag_{model}/ag_preds_test_eval.parquet`, `ag_{model}/ag_preds_oos.parquet`, and optional SHAP/PDP files from `DIR_TABLES_AUTOGLUON_TRACK`.
- Missing model prediction files are skipped with a log message.
- Evaluation outputs are written under the active validation `MT_OUTPUT_DIR`, including `3_Modelling_Results/Necessary/<track>/evaluation/` and track-aware model figure folders.
- The script does not call `09C_AutoGluon.py`, `11C_IndexConstruction_Revised.R`, sensitivity scripts, or pipeline regeneration scripts.
- The script does not use `MODEL`, so setting `MODEL=raw` is harmless but raw-only behavior is controlled by the existing validation output root containing only `ag_raw` inputs.

## commands_run_sanitized

Local preflight:

```text
git branch --show-current
git rev-parse --short HEAD
git status --short --untracked-files=all
git log --oneline -5
```

Script inspection:

```text
read-only inspection of 01_Code/pipeline/10_Evaluation.R
read-only inspection of 01_Code/pipeline/config.R
```

Remote connection attempts used the required explicit OpenSSH binary and required SSH options:

```text
<SSH_BINARY> -p <PORT> -o ConnectTimeout=15 -o ServerAliveInterval=30 -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL <USER>@<HOST> "pwd"
<SSH_BINARY> -p <PORT> -o ConnectTimeout=15 -o ServerAliveInterval=30 -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL <USER>@<HOST> "test remote root and validation output root"
```

No host, port, private key path, token, notebook token, or credential value is recorded in this report.

## intended_remote_invocation_not_run

These are the sanitized evaluation commands that should be run only after a reachable authorized endpoint is provided:

```text
<SSH_BINARY> [authorized endpoint] "cd /root/AgonyAndExcstasy && env MT_ROOT=/root/AgonyAndExcstasy MT_OUTPUT_DIR=/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260527_230749 MODEL=raw RESPONSE_TRACK=dynamic_csi Rscript 01_Code/pipeline/10_Evaluation.R > .../logs/10_Evaluation_dynamic_csi.log 2>&1"
```

```text
<SSH_BINARY> [authorized endpoint] "cd /root/AgonyAndExcstasy && env MT_ROOT=/root/AgonyAndExcstasy MT_OUTPUT_DIR=/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260527_230749 MODEL=raw RESPONSE_TRACK=permanent_csi Rscript 01_Code/pipeline/10_Evaluation.R > .../logs/10_Evaluation_permanent_csi.log 2>&1"
```

## runtimes

No evaluation runtimes are available because the remote evaluation did not start.

## remote_output_paths

Expected output root for a successful rerun:

```text
/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260527_230749
```

Expected track-specific evaluation output folders:

```text
3_Modelling_Results/Necessary/temporary_csi/evaluation/
3_Modelling_Results/Necessary/permanent_csi/evaluation/
```

Remote existence of these AE-VALIDATE-005 outputs could not be verified because SSH preflight was blocked.

## metrics_presence_summary

| track | AP | AUC | recall at FPR | Brier | by-year metrics |
|---|---|---|---|---|---|
| `dynamic_csi` | not rerun | not rerun | not rerun | not rerun | not rerun |
| `permanent_csi` | not rerun | not rerun | not rerun | not rerun | not rerun |

## skipped_non_raw_model_classification

Expected, not blocking, once evaluation can run. The script logs skipped models when their `ag_{model}` prediction files are absent. For this epic, the validation rerun intentionally produced only `MODEL=raw`; therefore non-raw rows such as fund, latent, bucket, and structural variants should be treated as expected skips rather than missing evidence.

This classification is based on read-only script inspection and the AE-VALIDATE-004 report. It was not validated against fresh AE-VALIDATE-005 logs because no remote evaluation ran.

## changed_files

Created:

- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md`

No local code, data, canonical evaluation output, canonical modeling output, canonical index-construction output, or remote code was edited.

## verification

- Confirmed local branch and HEAD:
  - branch `validation`
  - HEAD `5d706ef`
- Confirmed `git status --short --untracked-files=all` was clean before creating this report.
- Confirmed no local changes under:
  - `01_Code/**`
  - `03_Data_Output/**`
- Confirmed `git diff --name-only` for canonical output paths was empty before this report was created.
- Confirmed local `03_Data_Output/validation/AE-VALIDATE/raw_rerun_20260527_230749` does not exist.
- Confirmed existing local compact AE-VALIDATE-004 evidence under `07_CloudComputing/Validation/AE-VALIDATE/raw_rerun_20260527_230749`.
- Remote root existence and raw output existence could not be confirmed in this ticket run due unreachable SSH endpoints.
- Did not run `09C_AutoGluon.py`.
- Did not run `10_Evaluation.R`.
- Did not run `11C_IndexConstruction_Revised.R`.
- Did not run sensitivity scripts.
- Did not run pipeline regeneration scripts.
- Did not commit or push.

## git_status_summary

Expected after this report is created:

```text
?? 07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md
```

No tracked files should be modified.

## human_readability

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: This ticket added a single scoped blocker report under the allowed AE-VALIDATE validation documentation path. No code, data, canonical outputs, remote code, or remote data were changed.
- layer_touched: infrastructure
- layer_separation_preserved: true
