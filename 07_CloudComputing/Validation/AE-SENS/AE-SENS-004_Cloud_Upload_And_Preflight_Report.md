# AE-SENS-004 Cloud Upload And Preflight Report

Date: 2026-05-28

## status

Completed. The approved sensitivity manifest files were uploaded to Vast.ai under `/root/AgonyAndExcstasy`, and cloud preflight checks passed. No model training, evaluation, index construction, sensitivity grid execution, pipeline regeneration, merge/split/feature/label pipeline script, or robustness script was run.

## summary

- Branch: `development-sensitivity`
- HEAD: `d727e3edfc058a5eb29ba8eb06225024e9d91af1`
- Base check: `d727e3e` is an ancestor of `HEAD`
- Required AE-SENS history: `AE-SENS-001`, `AE-SENS-002`, and `AE-SENS-003` are present in git history
- AEGIS cross-reference: loaded canonical master, ticket, orchestration, code-validator, DS-validator, and ticket-scope rules from `aegis-core`; no literal `Master-Agent` or `Master-Validator` file names were found, so the canonical `master`, `code-validator`, and `ds-validator` role contracts were used
- Manifest source: `07_CloudComputing/Validation/AE-CLOUD/manifest_sensitivity.tsv`
- Manifest rows: `11` total, `8` required, `3` optional_fallback
- Uploaded files: `11`
- Uploaded bytes: `571,279,143`
- Remote verification: `11` files checked; all remote sizes and SHA256 hashes match
- Package checks: R `requireNamespace` and Python `import` checks passed; no installs attempted
- Remote sensitivity path checks: `12` expected parent directories exist and are writable

## sanitized_ssh_scp_usage

The ticket used explicit OpenSSH binaries and the authorized key path, with no port forwarding and no bare `ssh` or `scp`.

```text
C:\Windows\System32\OpenSSH\ssh.exe -i [authorized SSH key path] [authorized endpoint] "<remote preflight command>"
C:\Windows\System32\OpenSSH\scp.exe -i [authorized SSH key path] <local_manifest_file> [authorized endpoint]:<remote_manifest_path>
```

The required smoke test returned:

| Field | Result |
|---|---|
| Connection marker | `CONNECTION_OK` |
| Initial remote directory | `/root` |
| Remote user | `root` |

OpenSSH printed a non-blocking local `known_hosts` update warning, but each SSH/SCP command used for this ticket exited successfully.

## upload_scope

Only concrete local files listed in `manifest_sensitivity.tsv` were uploaded. Both existing `required` and existing `optional_fallback` rows were included. Validation manifests, minor manifests, full data trees, model output trees, and unrelated files were not uploaded.

| required_status | rows | uploaded_files | bytes |
|---|---:|---:|---:|
| required | 8 | 8 | 505,447,758 |
| optional_fallback | 3 | 3 | 65,831,385 |
| total | 11 | 11 | 571,279,143 |

Artifacts:

- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_manifest_local_preflight.csv`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_upload_manifest.csv`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_verification.csv`

## remote_verification

Full verification evidence is in `AE-SENS-004_remote_verification.csv`.

| path | expected_size | remote_size | size_status | hash_status |
|---|---:|---:|---|---|
| `02_Data_Input/01_CRSP/Necessary/prices_monthly.rds` | 48,869,889 | 48,869,889 | match | match |
| `02_Data_Input/01_CRSP/Necessary/delisting_raw.rds` | 366,661 | 366,661 | match | match |
| `02_Data_Input/01_CRSP/Necessary/universe.rds` | 535,157 | 535,157 | match | match |
| `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/features_raw.rds` | 419,892,918 | 419,892,918 | match | match |
| `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Features/split_labels_oot.parquet` | 302,281 | 302,281 | match | match |
| `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_constituents_quarterly.rds` | 35,362,592 | 35,362,592 | match | match |
| `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_returns_monthly.rds` | 43,081 | 43,081 | match | match |
| `02_Data_Input/04_Index_Replication/Necessary/crsp_like_index_summary_quarterly.csv` | 75,179 | 75,179 | match | match |
| `02_Data_Input/02_Compustat/Necessary/fundamentals.rds` | 29,859,924 | 29,859,924 | match | match |
| `02_Data_Input/03_FRED/Necessary/macro_monthly.rds` | 27,110 | 27,110 | match | match |
| `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Panel/panel_raw.rds` | 35,944,351 | 35,944,351 | match | match |

Remote SHA256 checks covered all uploaded files, including the largest files and representative index files, without downloading the files.

## code_script_existence

Remote script existence checks passed. These scripts were checked with file tests only and were not run.

| path | status |
|---|---|
| `01_Code/pipeline/05A_Dynamic_CSI_Label.R` | present |
| `01_Code/pipeline/06_Merge.R` | present |
| `01_Code/pipeline/06B_FeatureEngineering.R` | present |
| `01_Code/pipeline/08_Split.R` | present |
| `01_Code/pipeline/09C_AutoGluon.py` | present |
| `01_Code/pipeline/10_Evaluation.R` | present |
| `01_Code/pipeline/11C_IndexConstruction_Revised.R` | present |

Runner candidates found read-only:

- `01_Code/pipeline/13_Robustness_Checks.R`
- `01_Code/pipeline/13_Robustness_Checks_Revised_Temporary_CSI_572_574.R`
- `01_Code/pipeline/14c_RobustnessChecks_PermanentCapitalLoss_Response.R`

Artifact:

- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_script_checks.csv`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_runner_candidates.txt`

## package_load_checks

R packages were checked with `requireNamespace(..., quietly = TRUE)` only. Python packages were checked with `import` only. No package installation was attempted.

| language | packages | result |
|---|---|---|
| R | `data.table`, `ggplot2`, `scales`, `lubridate`, `dplyr`, `slider`, `arrow`, `tidyr`, `pROC`, `PRROC`, `jsonlite`, `viridis` | all OK |
| Python | `numpy`, `pandas`, `pyreadr`, `sklearn`, `autogluon.tabular`, `torch`, `pyarrow` | all OK |

Artifacts:

- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_r_package_checks.csv`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_python_package_checks.csv`

## remote_path_checks

The expected sensitivity output parent layout exists and is writable under `/root/AgonyAndExcstasy/03_Data_Output/3_Modelling_Results/Necessary/sensitivity`.

| path | status |
|---|---|
| `03_Data_Output/3_Modelling_Results/Necessary/sensitivity` | ok |
| `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/manifest` | ok |
| `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/logs` | ok |
| `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/labels` | ok |
| `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/raw_features` | ok |
| `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/raw_features/shared` | ok |
| `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/raw_features/by_config` | ok |
| `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/raw_models` | ok |
| `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/raw_predictions` | ok |
| `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/evaluation` | ok |
| `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/index_construction` | ok |
| `03_Data_Output/3_Modelling_Results/Necessary/sensitivity/comparisons` | ok |

Artifact:

- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_path_checks.csv`

## script_execution_guardrail

Confirmed not run:

- model training
- evaluation
- index construction
- sensitivity grid execution
- pipeline regeneration
- `09C_AutoGluon.py`
- `10_Evaluation.R`
- `11C_IndexConstruction_Revised.R`
- `13_Robustness_Checks*.R`
- `05A_Dynamic_CSI_Label.R`
- `06_Merge.R`
- `06B_FeatureEngineering.R`
- `08_Split.R`

A remote process guard check found no matching forbidden script process after preflight.

Artifact:

- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_process_guard.txt`

## blockers

None.

## verification

Commands and checks performed:

- Loaded AEGIS reference files read-only from `C:\Users\Tristan Leiter\Documents\aegis-core`.
- `git status --short --branch`
- `git log --oneline --decorate -n 30`
- `git merge-base --is-ancestor d727e3e HEAD`
- `git log --oneline --grep='AE-SENS-00[123]' --all`
- Parsed `07_CloudComputing/Validation/AE-CLOUD/manifest_sensitivity.tsv`.
- Generated local manifest preflight CSV with existence, size, and SHA256 checks.
- Ran required explicit OpenSSH smoke test.
- Uploaded exactly the 11 approved manifest rows with explicit SCP.
- Verified remote sizes and SHA256 hashes for all uploaded files.
- Checked remote script existence and runner candidates read-only.
- Checked package loadability with R `requireNamespace` and Python `import`.
- Created/checked expected remote sensitivity output parent paths.
- Confirmed no forbidden model/evaluation/index/sensitivity/pipeline process was active.
- Confirmed local changed-file scope: `10` AE-SENS-004 evidence files under `07_CloudComputing/Validation/AE-SENS/**`, `0` local scope violations.
- Sanitizer check found no endpoint, port, private-key path, or credential strings in AE-SENS-004 evidence files.

## git_status_summary

Post-ticket local status contains only allowed AE-SENS-004 evidence plus the pre-existing unrelated AE-VALIDATE blocker reports, which were preserved and not edited:

```text
## development-sensitivity
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-004_Cloud_Upload_And_Preflight_Report.md
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-004_manifest_local_preflight.csv
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_path_checks.csv
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_process_guard.txt
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_python_package_checks.csv
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_r_package_checks.csv
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_runner_candidates.txt
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_script_checks.csv
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_verification.csv
?? 07_CloudComputing/Validation/AE-SENS/AE-SENS-004_upload_manifest.csv
?? 07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005R_Model_Evaluation_Rerun_Report.md
?? 07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-005_Model_Evaluation_Rerun_Report.md
```

## changed_files

- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_Cloud_Upload_And_Preflight_Report.md`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_manifest_local_preflight.csv`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_upload_manifest.csv`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_verification.csv`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_script_checks.csv`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_runner_candidates.txt`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_r_package_checks.csv`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_python_package_checks.csv`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_path_checks.csv`
- `07_CloudComputing/Validation/AE-SENS/AE-SENS-004_remote_process_guard.txt`

## next_recommended_role

validator

## human_readability

- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: This ticket replaced the previous blocked AE-SENS-004 report with pass evidence and added compact CSV/TXT evidence for local manifest preflight, upload scope, remote file verification, remote script checks, package checks, sensitivity path checks, and process guard status. Remote writes were limited to the approved manifest upload paths and the expected empty sensitivity output parent directories.
- layer_touched: infrastructure
- layer_separation_preserved: true
