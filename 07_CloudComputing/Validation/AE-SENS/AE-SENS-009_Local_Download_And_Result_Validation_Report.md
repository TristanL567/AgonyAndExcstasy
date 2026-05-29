# AE-SENS-009 Local Download And Result Validation Report

## Status

AE-SENS-009 local download and validation passed. The remote AE-SENS final state was validated, compact/reporting-critical results were downloaded into the ignored local output folder, the local copy was structured by workflow area, and checksum validation passed.

## AEGIS Reference

AEGIS-CORE was cross-referenced read-only before execution. Loaded references included:

- `AEGIS.md`
- `contracts/swarm-contract.md`
- `contracts/ticket-contract.md`
- `skills/roles/master/SKILL.md`
- `execution/runbooks/shared-orchestration-loop.md`
- `execution/runbooks/apply-to-project.md`
- `execution/prompts/validate-ticket.md`

The ticket was executed as a single bounded ticket. Validator approval remains blocking before commit/merge completion.

## Branch And Base

- Working branch: `development-sensitivity`
- Required base: `0f77a7d` or descendant
- Observed starting HEAD: `0f77a7d AE-SENS-008: compare full CMT sensitivity grid`

## Remote Validation

Remote checks used `[authorized endpoint]` and `[authorized SSH key path]`; endpoint, port, key path, tokens, and credential contents are not recorded in this report.

Remote validation results:

- Remote root existed: `/root/AgonyAndExcstasy`
- Remote sensitivity root existed: `/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity`
- Final AE-SENS status represented all 27 configured run IDs.
- Final classification was 24 complete/reused result sets and 3 `blocked_partial` result sets.
- Blocked partial run IDs:
  - `C080_M000_T012`
  - `C080_M000_T018`
  - `C060_M020_T028`
- No AE-SENS runner, AutoGluon, evaluation, or 11C process was active during the final remote check.
- Remote disk was stable for read-only download: 100G total, 66G used, 35G available.
- Remote canonical non-sensitivity output check returned no recent files outside the sensitivity root under `03_Data_Output/3_Modelling_Results/Necessary`.

## Local Download

Local download root:

`03_Data_Output/5_SensitivityAnalysis/`

The local structure was created as requested:

- `00_manifest/`
- `01_labels/`
- `02_model_training/`
- `03_predictions/`
- `04_index_construction/`
- `05_comparisons/`
- `06_logs/`
- `99_reports/`

Downloaded and structured local copy:

- Local files: 746
- Local bytes: 140,447,901
- Remote-manifested files: 669
- Checksum pass: 669
- Checksum fail: 0

The prediction parquet files explicitly required for final reporting were downloaded under `03_predictions/by_run/<run_id>/`. Heavy model artifacts were not downloaded.

## Validation Artifacts

Tracked AE-SENS-009 evidence:

- `AE-SENS-009_download_manifest_summary.csv`
- `AE-SENS-009_checksum_summary.csv`
- `AE-SENS-009_local_structure_validation.csv`
- `AE-SENS-009_gitignore_validation.txt`
- `AE-SENS-009_merge_hygiene_report.txt`
- this report

Ignored local-use reports:

- `03_Data_Output/5_SensitivityAnalysis/99_reports/sensitivity_download_validation_report.md`
- `03_Data_Output/5_SensitivityAnalysis/99_reports/sensitivity_results_readme.md`

## Gitignore And Commit Scope

`git check-ignore` confirmed that `03_Data_Output/5_SensitivityAnalysis/**` is ignored by the repository’s `03_Data_Output/**` rule. `git status --short -- 03_Data_Output/5_SensitivityAnalysis` returned no entries.

The generated local output data under `03_Data_Output/5_SensitivityAnalysis/**` must not be staged or committed. The AE-SENS-009 commit scope is limited to tracked evidence under `07_CloudComputing/Validation/AE-SENS/**`.

Known unrelated untracked files remain outside AE-SENS scope and must not be staged:

- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005R_Model_Evaluation_Rerun_Report.md`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md`

## Branch Merge Hygiene

Pre-merge hygiene passed:

- Development branch: `development-sensitivity`
- Generated output data ignored and unstaged
- No code, canonical data, canonical outputs, presentations, or unrelated AE-VALIDATE blocker reports are in the AE-SENS-009 commit scope

After validator approval, the required branch sequence is:

1. Commit only AE-SENS-009 tracked evidence on `development-sensitivity`.
2. Push `development-sensitivity`.
3. Switch to `main`.
4. Pull or confirm `origin/main`.
5. Merge `development-sensitivity` into `main`.
6. Confirm generated output data remains unstaged/uncommitted.
7. Push `main`.

Final merge/push status is recorded in the completion response after the validator gate.

## Conclusion

AE-SENS-009 download validation is ready for validator review. No generated output data should be committed; the ignored local output folder is for local analysis and reporting only.
