# AE-VALIDATE-001 Base State Report

Date prepared: 2026-05-27

Ticket scope: initialize the AE-VALIDATE raw model/index validation epic by creating or switching to branch `validation`, recording local and remote base state, and documenting the split validation workflow. No model training, evaluation, index construction, sensitivity analysis, pipeline regeneration, upload, or download command was run.

## Local Branch And Git State

- Local branch before ticket: `Development`.
- Active branch after ticket: `validation`.
- Branch action: created local branch `validation` from `Development` at `789645bde736ba650400508a06cde387694c6cc1`.
- Local HEAD: `789645bde736ba650400508a06cde387694c6cc1`.
- AE-CLOUD-006 ancestry check: `789645b` is an ancestor of `HEAD`.
- `git status --short --branch` after branch creation: `## validation`.

Recent history recorded:

```text
789645b (HEAD -> validation, Development) AE-CLOUD-006: add upload verification report
3ea55fa AE-CLOUD-005: add live connection environment report
95477a1 AE-CLOUD-004: add readiness gate report
7b9cd2c AE-CLOUD-003: add upload strategy templates
7112eca AE-CLOUD-002: add minimal data manifests
```

Remotes recorded:

```text
origin  https://github.com/TristanL567/AgonyAndExcstasy.git (fetch)
origin  https://github.com/TristanL567/AgonyAndExcstasy.git (push)
```

## Local AE-CLOUD Readiness Artifacts

Required local readiness artifacts exist:

- `07_CloudComputing/Validation/AE-CLOUD/AE-CLOUD-005_Live_Connection_And_Environment_Report.md`
- `07_CloudComputing/Validation/AE-CLOUD/AE-CLOUD-006_Upload_Verification_Report.md`
- `07_CloudComputing/Validation/AE-CLOUD/manifest_validate.tsv`

High-level canonical output tree existence check:

- `03_Data_Output/3_Modelling_Results/Necessary`: exists.

## Remote Read-Only Readiness Check

- Remote root: `/root/AgonyAndExcstasy`.
- SSH tool used: `C:\Windows\System32\OpenSSH\ssh.exe`.
- Connection endpoint details are intentionally omitted from this report.
- Remote root check: passed; `cd /root/AgonyAndExcstasy && pwd` returned `/root/AgonyAndExcstasy`.
- Required script checks: passed.
  - `01_Code/pipeline/09C_AutoGluon.py`
  - `01_Code/pipeline/10_Evaluation.R`
  - `01_Code/pipeline/11C_IndexConstruction_Revised.R`
- Remote `02_Data_Input` file count: `10`.
- No remote model, evaluation, index construction, sensitivity, pipeline, upload, or download command was run.

## Validation Execution Model

This epic uses a split local/remote workflow:

- Vast.ai remote: run validation model training, raw-only evaluation, and `11C_IndexConstruction_Revised.R` index construction in later scoped tickets.
- Local repo: keep canonical outputs read-only, create canonical snapshots, receive compact validation summaries/logs, and perform final comparison.
- Remote root: `/root/AgonyAndExcstasy`.
- Future remote commands must set `MT_ROOT=/root/AgonyAndExcstasy`.
- Validation reruns must use an absolute `MT_OUTPUT_DIR` under:

```text
/root/AgonyAndExcstasy/03_Data_Output/validation/AE-VALIDATE/raw_rerun_<timestamp>/
```

## Canonical Output Policy

- Canonical model/index output trees stay local and read-only.
- Canonical output artifacts are not overwritten by validation work.
- Canonical snapshotting occurs in AE-VALIDATE-003.
- Canonical model/index output trees are not uploaded to Vast.ai unless a later ticket explicitly scopes that transfer.
- Remote validation summaries/logs are downloaded later for local comparison.
- Canonical comparison is local unless superseded by a later approved ticket.

## Blockers

None identified for this initialization ticket.

## Prohibited Script Confirmation

Confirmed: no model training, `10_Evaluation.R`, `11C_IndexConstruction_Revised.R`, sensitivity script, pipeline regeneration script, project script, upload, or download was run for AE-VALIDATE-001.
