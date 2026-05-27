# AE-SENS-001 Refresh Sensitivity Epic Report

## status

completed

## summary

Refreshed the AE-SENS C/M/T sensitivity epic against the current repository and AE-CLOUD readiness package. This was a documentation-only ticket.

Confirmed decisions:

- Grid: `C` in `-0.60`, `-0.80`, `-0.90`; `M` in `0.00`, `-0.20`, `-0.30`; `T` in `12`, `18`, `28`.
- Baseline run ID: `C080_M020_T018`.
- AE-CLOUD manifest bundle: `07_CloudComputing/Validation/AE-CLOUD/manifest_sensitivity.tsv`.
- Sensitivity output root: `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/`, with per-run subdirectories keyed by run ID.

## artifacts

- Updated plan: `05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/AE-SENS_Epic.md`
- This completion report: `07_CloudComputing/Validation/AE-SENS/AE-SENS-001_Refresh_Sensitivity_Epic_Report.md`

## findings

- Existing AE-SENS source docs already identified the correct 27-run grid and baseline `C080_M020_T018`; no inspected document superseded that baseline.
- AE-CLOUD-003 and AE-CLOUD-004 identify and validate `manifest_sensitivity.tsv` as the sensitivity bundle, with 11 concrete existing local rows: 8 `required` and 3 `optional_fallback`.
- AE-CLOUD-006 uploaded the validation bundle only. Sensitivity upload/preflight remains required before AE-SENS model work.
- AE-CLOUD evidence records `/root/AgonyAndExcstasy` as the remote project root used by prior upload verification. The refreshed plan uses repository-relative paths under that root and records no secrets.
- The current AE-VALIDATE state includes raw AutoGluon rerun evidence under `raw_rerun_20260527_230749`, but the later evaluation rerun report is blocked by unavailable SSH endpoint. AE-SENS should not assume fresh evaluation/index outputs are available from AE-VALIDATE-005.
- `05_Documentation/**` is ignored by `.gitignore`; the refreshed epic file exists and was updated on disk, but normal `git status --short` does not list it.

## next_recommended_role

validator

## changed_files

Created:

- `07_CloudComputing/Validation/AE-SENS/AE-SENS-001_Refresh_Sensitivity_Epic_Report.md`

Modified:

- `05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/AE-SENS_Epic.md`

## verification

Commands and inspections performed:

```text
Get-Content -Raw 05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/Tickets/AE-SENS-001_Refresh_Sensitivity_Epic.md
Get-Content -Raw 05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/AE-SENS_Epic.md
Get-Content -Raw 05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/Tickets/AE-SENS-004_Cloud_Upload_And_Preflight.md
Get-Content -Raw 07_CloudComputing/Validation/AE-CLOUD/AE-CLOUD-003_Upload_Strategy_And_Code_Sync.md
Get-Content -Raw 07_CloudComputing/Validation/AE-CLOUD/AE-CLOUD-004_Readiness_Gate_Report.md
Get-Content -Raw 07_CloudComputing/Validation/AE-CLOUD/AE-CLOUD-006_Upload_Verification_Report.md
Get-Content -Raw 07_CloudComputing/AE-SENS_Epic_CMT_Sensitivity_Grid.md
Get-Content -Raw 07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-004_Raw_AutoGluon_Rerun_Report.md
Get-Content -Raw 07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md
Import-Csv -Delimiter "`t" 07_CloudComputing/Validation/AE-CLOUD/manifest_sensitivity.tsv
git branch --show-current
git rev-parse --short HEAD
git status --short
git status --short --untracked-files=all --ignored 05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/AE-SENS_Epic.md
```

Verification results:

- Local branch confirmed as `development-sensitivity`.
- Local HEAD confirmed as `5d706ef`.
- `manifest_sensitivity.tsv` row counts confirmed: 8 `required`, 3 `optional_fallback`.
- No SSH command was run.
- No cloud host was contacted.
- No upload was attempted.
- No model, evaluation, index-construction, pipeline, or sensitivity script was run.
- No code, data, model output, or cloud host was touched.
- No files outside the AE-SENS allowed documentation and validation areas were edited.

## git_status_summary

Observed before edits:

```text
?? 07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md
```

Expected after this ticket:

```text
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-001_Refresh_Sensitivity_Epic_Report.md
?? 07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md
```

Ignored documentation status for the refreshed epic:

```text
!! 05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/AE-SENS_Epic.md
```

The AE-VALIDATE untracked report is unrelated and was not edited, staged, or included in this ticket.

## human_readability

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: The ticket refreshed the AE-SENS planning document with current AE-CLOUD manifest, baseline, output layout, and execution sequence, then added this scoped completion report.
- layer_touched: documentation
- layer_separation_preserved: true
