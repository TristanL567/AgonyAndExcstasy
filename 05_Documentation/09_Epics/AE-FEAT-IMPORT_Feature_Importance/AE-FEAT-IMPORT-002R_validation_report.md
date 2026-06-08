# AE-FEAT-IMPORT-002R Validation Report

## Scope Validation

Allowed edit areas:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/**`
- `epics/AE-FEAT-IMPORT/**`

Read-only paths inspected:

- `03_Data_Output/6_ModelSuite/**`
- `03_Data_Output/10_FeatureImportance/**`
- `07_CloudComputing/Validation/AE-MODEL-SUITE/**`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/**`
- `01_Code/pipeline/09C_AutoGluon.py`
- `01_Code/pipeline/config.R`

Protected paths were not edited by this worker.

## Artifact Validation

Required artifacts created:

- `AE-FEAT-IMPORT-002R_Predictor_Availability_Report.md`
- `AE-FEAT-IMPORT-002R_predictor_inventory.csv`
- `AE-FEAT-IMPORT-002R_recovery_or_retrain_plan.csv`
- `AE-FEAT-IMPORT-002R_validation_report.md`
- `AE-FEAT-IMPORT-002R_worker_completion_report.md`

Ledger updated:

- `epics/AE-FEAT-IMPORT/ledger.md`

Prior ledger entries were preserved.

## Predictor Availability Validation

Checks performed:

- Confirmed local compact model-suite folders for all eight feature-set and track combinations.
- Confirmed local `03_Data_Output/10_FeatureImportance` had no predictor staging contents.
- Confirmed the training script writes fitted predictors to an `ag_predictor` directory.
- Confirmed local model-suite README and validation summary state heavy AutoGluon predictor artifacts were excluded.
- Inspected raw remote-derived inventory evidence showing `ag_raw/ag_predictor` files existed in the raw validation root for both tracks.
- Inspected nonraw storage-retention evidence showing `ag_fund/ag_predictor`, `ag_latent_raw/ag_predictor`, and `ag_raw_plus_latent/ag_predictor` were deleted for both tracks.

Finding:

- Local fitted predictors are absent for all eight combinations.
- Raw predictors are classified as available remotely based on remote-derived inventory evidence, pending later live restore verification.
- Fund, latent_raw, and raw_plus_latent predictors are classified as pruned/unavailable and require retraining/rebuild unless a separate backup is supplied.

## Remote Inspection Validation

OpenSSH client availability was checked using the explicit Windows OpenSSH binary path. No live SSH listing was run. The ticket context included a connection note, but it was a port-forward/tunnel template rather than a safe non-interactive read-only listing command for this worker context. Remote availability is therefore inferred only from existing local evidence. No endpoint details, ports, key paths, tokens, credential material, or raw SSH command strings are written in the reports.

## Verification Commands

Ticket verification commands run after artifact creation:

```powershell
git branch --show-current
git status --short
git diff --name-only
git diff --cached --name-only
```

Observed state:

- Current branch: `Development-FE`.
- `git diff --cached --name-only` returned no files.
- `git status --short` includes unrelated pre-existing dirty presentation/cloud files outside this ticket, the ticket envelope, and modified `epics/AE-FEAT-IMPORT/ledger.md`.
- The required documentation artifacts exist under `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/`; this documentation tree is ignored by the repository and therefore may not appear in `git status`.

## No Protected Output Mutation

No files were created, modified, staged, committed, or pushed under:

- `01_Code/**`
- `02_Data_Input/**`
- `03_Data_Output/**`
- `06_Presentations/**`
- `07_CloudComputing/**`
- `C:/Users/Tristan Leiter/Documents/aegis-core/**`

No model training, model evaluation, index construction, sensitivity script, pipeline regeneration, feature-importance computation, predictor download, commit, or push was run.

## Human Readability

human_readability: pass

The inventory and plan CSVs cover all eight required feature-set and track combinations. The report states the direct-readiness decision for AE-FEAT-IMPORT-003R.
