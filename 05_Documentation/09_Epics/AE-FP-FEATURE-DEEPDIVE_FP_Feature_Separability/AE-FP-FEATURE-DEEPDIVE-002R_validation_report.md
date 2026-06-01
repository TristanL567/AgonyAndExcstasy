# AE-FP-FEATURE-DEEPDIVE-002R Validation Report

## Validation Summary

Status: worker validation passed, pending independent AEGIS validator review.

The ticket rebuilt CV/training-only feature evidence from approved local model input artifacts, joined it to existing AE-FP-DIAG CV cohorts, and wrote local contrast outputs. No protected input, source code, presentation, or cloud-computing paths were modified.

## Scope Checks

| check | result | evidence |
|---|---|---|
| Branch is `Development` | pass | `git status --short --branch` showed `## Development`. |
| AEGIS materials loaded | pass | Loaded AEGIS anchor, swarm/ticket/epic contracts, model-interpreter worker, shared orchestration, apply-to-project, multi-master dispatch, and clean-commit materials from `C:/Users/Tristan Leiter/Documents/aegis-core`. |
| Exactly one ticket | pass | Work was limited to `AE-FP-FEATURE-DEEPDIVE-002R`. |
| `01_Code/**` untouched | pass | No files under `01_Code/**` were modified. |
| `02_Data_Input/**` not modified | pass | Inputs were read only. |
| `06_Presentations/**` untouched by this ticket | pass | Pre-existing dirty presentation files were left untouched. |
| `07_CloudComputing/**` untouched by this ticket | pass | Pre-existing untracked cloud-validation folder was left untouched. |
| `03_Data_Output/**` not staged/committed | pass for worker stage | Local CSV outputs were generated but not staged or committed. |

## Data Leakage Checks

| check | result | evidence |
|---|---|---|
| AE-FP-DIAG cohorts are CV-only | pass | Cohort join source requires `split_source = cv`; validation CSV reports pass. |
| RDS feature rows are training-only | pass | `features_raw.rds` and `features_fund.rds` filtered with `splits.rds` `oot$train_idx`. |
| Parquet feature rows are training-only | pass | `features_latent_raw.parquet` and `features_raw_plus_latent.parquet` filtered with `split == train`. |
| Test/OOS rows excluded | pass | No `split == test` or `split == oos` feature rows retained; schema manifest max year is 2015 for every source table. |
| Feature keys unique | pass | All eight CV/training source matrices have zero duplicate `permno/year` keys. |

## Output Checks

| output | result |
|---|---|
| source/schema manifest | created locally under `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/` |
| CV feature key matrix | created locally under `03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/` |
| FP/TP feature contrasts | created locally with 23,440 rows |
| top separating features | created locally |
| feature group summary | created locally |
| FP/TP/FN/TN coverage | created locally; min and max coverage are both 1.0 |
| validation checks CSV | created locally; all checks pass |

## Verification Commands

- `git status --short --branch`
- `Get-ChildItem -Recurse -File 02_Data_Input/05_PipelineResults/Necessary`
- `Rscript 05_Documentation/09_Epics/AE-FP-FEATURE-DEEPDIVE_FP_Feature_Separability/AE-FP-FEATURE-DEEPDIVE-002R_build_feature_separability.R`
- `Import-Csv 03_Data_Output/8_FalsePositiveDiagnostics/feature_matrices/AE-FP-FEATURE-DEEPDIVE-002R_validation_checks.csv`
- Python/Pandas spot checks for threshold-specific FP/TP counts and coverage minima.

The full Rscript run completed successfully after correcting a data.table scoping bug in the first provisional pass.

## Residual Risks

- Standalone `fund` and `latent_raw` AE-FP-DIAG FP/TP cohorts are unavailable. Their reported contrasts are cross-family or component profiles against existing raw/raw-plus-latent cohorts.
- The analysis uses observational CV cohort membership and must not be interpreted causally.
- Generated `03_Data_Output/**` files must remain local and unstaged.
