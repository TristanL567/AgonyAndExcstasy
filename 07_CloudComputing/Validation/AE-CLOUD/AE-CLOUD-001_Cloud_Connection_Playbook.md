# AE-CLOUD-001 Cloud Connection Playbook

Date prepared: 2026-05-27

Ticket scope: local-readiness only. This playbook records local context and command templates for a future credentialed Vast.ai/cloud worker. It does not validate a live SSH connection, does not upload files, does not install packages, and does not run any model, sensitivity, robustness, validation, or index-construction script.

## 1. Local Git Snapshot

Discovered facts:

- Expected branch from ticket: `Development`.
- Observed local branch: `main`.
- Branch action taken: none. The ticket explicitly said not to switch branches if the repo is not on `Development`.
- HEAD: `9d06b6f Update AE-PANEL docs and final presentation`.
- Remote: `origin https://github.com/TristanL567/AgonyAndExcstasy.git` for fetch and push.
- Pre-edit git status summary from `git status --short --branch`: `## main...origin/main`; no pre-existing short-status file changes were reported by that command.

## 2. Existing Cloud/Vast.ai Context Found Locally

Discovered facts from allowed local context:

- `05_Documentation/09_Epics/AE-CLOUD_Local_Cloud_Readiness/AE-CLOUD_Epic.md` defines AE-CLOUD as a standalone local readiness package for Vast.ai/cloud execution, including SSH playbook, minimum data manifests, upload strategy, code-sync strategy, and preflight checklist.
- `05_Documentation/09_Epics/AE-CLOUD_Local_Cloud_Readiness/README.md` states the primary rule: AE-CLOUD does not prove a live Vast.ai connection unless credentials are provided.
- `05_Documentation/09_Epics/AE-CLOUD_Local_Cloud_Readiness/Tickets/AE-CLOUD-001_SSH_And_Context_Readiness.md` requires SSH placeholder templates, required Master-provided credentials, and the remote branch workflow.
- `05_Documentation/09_Epics/AE-CLOUD_Local_Cloud_Readiness/Tickets/AE-CLOUD-002_Minimal_Data_Manifest_By_Epic.md` defines the next ticket's manifest bundles: `bundle_validate`, `bundle_sensitivity`, and `bundle_minor`.
- `05_Documentation/09_Epics/AE-CLOUD_Local_Cloud_Readiness/Tickets/AE-CLOUD-003_Upload_Strategy_And_Code_Sync.md` plans separate code and data syncs, `rsync --dry-run` and real-run templates, exclusion of generated outputs/docs/presentations/research/model artifacts by default, resume/checksum verification, and remote layout for code, data, logs, and outputs.
- `05_Documentation/09_Epics/AE-CLOUD_Local_Cloud_Readiness/Tickets/AE-CLOUD-004_Manifest_Validation_Gate.md` requires the readiness gate to confirm manifest files, upload sizes, excluded directories, hashes, and documented-but-not-executed remote preflight commands.
- `07_CloudComputing/AE-SENS_Epic_CMT_Sensitivity_Grid.md` expects cloud work to establish a Vast.ai connection, record environment details, create or switch the cloud worktree to `Development_CC`, build and validate an upload manifest, upload only minimum data and code, and run preflight checks before model work.
- `07_CloudComputing/AE-SENS_Epic_CMT_Sensitivity_Grid.md` says generated outputs must not be committed and gives a repository-relative sensitivity output layout under `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/`.
- `07_CloudComputing/AE-SENS_Epic_CMT_Sensitivity_Grid.md` provides placeholder remote command forms using `<PORT>`, `<USER>`, `<HOST>`, and `<REMOTE_PROJECT>`, including SSH checks and an `rsync --dry-run` template.
- `05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/Tickets/AE-SENS-004_Cloud_Upload_And_Preflight.md` says the future credentialed cloud upload ticket depends on AE-CLOUD completion, Master-provided credentials, and upload authorization, and must not train models.
- Vast-oriented shell wrappers exist under `01_Code/shell/`:
  - `run_05A_dynamic_csi_vast.sh`
  - `run_dynamic_csi_03b_to_autoencoder_vast.sh`
  - `run_13_dynamic_csi_vast.sh`
  - `run_13_revised_temporary_csi_572_574_vast.sh`
  - `run_13c_old_csi_recovery_buckets_all_grid_vast.sh`
- Those shell wrappers default `MT_ROOT` to `/workspace/AgonyAndExcstasy`, set `RESPONSE_TRACK=dynamic_csi`, set thread-count environment variables, use `Rscript` and/or `python3`, and write logs below the remote output tree. They were inspected only; none were executed.
- `.gitignore` ignores `03_Data_Output/**`, matching the cloud docs' instruction not to commit generated output artifacts.

No real SSH host, SSH port, username, SSH private key path, password, token, or confirmed remote project root was found in the inspected allowed context.

## 3. Required Credential Fields For Master

Master must provide these fields before AE-CLOUD or AE-SENS can run a live remote command:

| Field | Status | Notes |
|---|---:|---|
| SSH host | missing | Vast.ai host or IP address. |
| SSH port | missing | Vast.ai commonly provides a non-default forwarded port; do not assume `22`. |
| Username | missing | Example placeholder: `<USER>`. |
| SSH key path or authentication method | missing | Example placeholder: `<SSH_KEY_PATH>` or a named SSH config alias/auth method. |
| Intended remote project root | missing | Existing scripts default to `/workspace/AgonyAndExcstasy`, but this is a convention, not a confirmed live path. |
| Remote branch name | missing | Existing cloud plan expects `Development_CC` for cloud implementation work. Master should confirm whether AE-CLOUD uses `Development_CC` or a different remote branch. |

Optional but useful fields:

- Remote data root.
- Remote validation output root.
- Remote logs root.
- Whether code arrives by `git clone`, `rsync`, or an existing remote worktree.
- Whether `origin` should be configured or pushes are prohibited.

## 4. SSH Command Templates

Placeholders only; no real credentials are embedded.

With explicit key path:

```bash
ssh -i <SSH_KEY_PATH> -p <PORT> <USER>@<HOST>
```

With SSH config alias:

```bash
ssh <SSH_ALIAS>
```

Single read-only remote command:

```bash
ssh -i <SSH_KEY_PATH> -p <PORT> <USER>@<HOST> "pwd"
```

Check remote git state after the remote project root is known:

```bash
ssh -i <SSH_KEY_PATH> -p <PORT> <USER>@<HOST> "cd <REMOTE_PROJECT> && git status --short --branch && git log -1 --oneline"
```

Template for later dry-run upload planning only, not executed in this ticket:

```bash
rsync --dry-run -av --files-from=<MANIFEST_FILE> -e "ssh -i <SSH_KEY_PATH> -p <PORT>" ./ <USER>@<HOST>:<REMOTE_PROJECT>/
```

## 5. Remote Bootstrap Command Checklist

Run only after Master supplies credentials and authorizes live remote inspection. These commands are intended to be read-only environment checks.

```bash
pwd
uname -a
df -h
free -h
command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi || echo "nvidia-smi not available"
Rscript --version
python --version
cd <REMOTE_PROJECT> && git status --short --branch
```

One-shot SSH form:

```bash
ssh -i <SSH_KEY_PATH> -p <PORT> <USER>@<HOST> 'pwd; uname -a; df -h; free -h; command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi || echo "nvidia-smi not available"; Rscript --version; python --version; cd <REMOTE_PROJECT> && git status --short --branch'
```

## 6. Recommended Remote Directory Layout

Use Master-provided paths if they differ. The following layout follows the local cloud docs and existing Vast shell wrapper conventions.

| Purpose | Recommended path | Basis |
|---|---|---|
| Code root | `/workspace/AgonyAndExcstasy` | Existing `01_Code/shell/*_vast.sh` wrappers default `MT_ROOT` to this path. |
| Data root | `/workspace/AgonyAndExcstasy/02_Data_Input` | Repository input-data convention; AE-CLOUD-002 should narrow to manifest-selected files only. |
| Validation output root | `/workspace/AgonyAndExcstasy/07_CloudComputing/Validation` | AE-CLOUD and AE-SENS validation reports live under `07_CloudComputing/Validation/<EPIC>/`. |
| Logs root | `/workspace/AgonyAndExcstasy/03_Data_Output/logs` or ticket-specific output logs under `03_Data_Output/**/logs` | Existing shell wrappers write logs under `03_Data_Output/2_Robustness_Checks/Additional/logs`, `03_Data_Output/3_Modelling_Results/Additional/run_logs`, or ticket-specific robustness directories. |
| Sensitivity output root | `/workspace/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity` | Documented in the AE-SENS cloud epic. |

Do not commit files under `03_Data_Output/**`; `.gitignore` excludes that tree.

## 7. Remote Branch Workflow Placeholder

Discovered cloud plan expects implementation work on remote branch `Development_CC`. A future credentialed worker should confirm the remote state before changing branches:

```bash
cd <REMOTE_PROJECT>
git status --short --branch
git branch --show-current
git branch --list Development_CC
```

If Master confirms `Development_CC` and no such branch exists remotely:

```bash
git switch -c Development_CC
```

If `Development_CC` already exists:

```bash
git switch Development_CC
```

Do not push `Development_CC` unless Master authorizes it.

## 8. AE-CLOUD-002 Handoff

Recommended follow-up list for AE-CLOUD-002:

1. Build manifest templates for `bundle_validate`, `bundle_sensitivity`, and `bundle_minor`.
2. Populate each row with `bundle | required_status | local_path | remote_path | size_bytes | sha256 | reason | consuming_script`.
3. Use remote paths rooted at the Master-confirmed `<REMOTE_PROJECT>`, defaulting only provisionally to `/workspace/AgonyAndExcstasy`.
4. Include only minimal required input files and explicitly mark optional fallbacks.
5. Exclude full `03_Data_Output/**`, full docs, presentations, research folders, existing model artifacts, figures, PDFs, DOCX, PPTX, and archives by default.
6. Hash local files and record byte sizes without moving, copying, uploading, or modifying data.
7. Tie each manifest row to the downstream consuming script or epic.
8. Leave missing credential fields as placeholders; they are not blockers for local manifest preparation.

## 9. Verification Performed For This Playbook

Local read-only commands used for context:

```bash
git status --short --branch
git log -1 --oneline
git remote -v
rg -n "vast|ssh|rsync|scp|cloud|remote|Development_CC|Validation|manifest|upload" 07_CloudComputing 05_Documentation 01_Code/shell
rg -n "host|port|user|username|key|ssh|rsync|scp|remote|Vast|vast|cloud|Development_CC|REMOTE_PROJECT|workspace|manifest|upload|preflight|branch" 05_Documentation/09_Epics/AE-CLOUD_Local_Cloud_Readiness 05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid 07_CloudComputing 01_Code/shell
```

No SSH command, upload command, package installation, model run, pipeline run, sensitivity run, or index-construction command was executed.
