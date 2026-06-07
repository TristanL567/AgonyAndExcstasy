# AE-FEAT-IMPORT-005R Worker Completion Report

## Status

status: complete

## Summary

Computed individual point-in-time/base ratio log-odds perturbation importance for the six applicable bounded GBM-only predictor combinations: raw, fund, and raw_plus_latent crossed with dynamic_csi and permanent_csi.

The worker audited latent_raw for both tracks and recorded it as not applicable because those predictors contain no point-in-time/base ratio features.

## Artifacts

Committed/evidence-scope artifacts created:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_PIT_Ratio_Log_Odds_Importance_Report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_pit_ratio_importance_summary.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_pit_ratio_coverage_audit.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_build_pit_ratio_importance.py`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_validation_report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

Local-only ignored outputs:

- `03_Data_Output/10_FeatureImportance/pit_ratio_importance/AE-FEAT-IMPORT-005R_pit_ratio_importance_summary.csv`
- `03_Data_Output/10_FeatureImportance/pit_ratio_importance/AE-FEAT-IMPORT-005R_pit_ratio_coverage_audit.csv`
- `03_Data_Output/10_FeatureImportance/pit_ratio_importance/AE-FEAT-IMPORT-005R_run_metadata.json`
- `03_Data_Output/10_FeatureImportance/pit_ratio_importance/row_deltas/*.parquet`

## Findings

- 246 individual PIT-ratio perturbation rows were computed: 41 present ratios times 6 applicable model-track combinations.
- Every applicable bounded predictor had 41 of 44 expected PIT ratios.
- `altman_z1`, `altman_z3`, and `altman_z5` were absent from every applicable predictor and recorded in the coverage audit.
- `latent_raw` was not applicable for both dynamic_csi and permanent_csi because no PIT ratio features were present.
- `earn_yld` was the most recurrent high-impact PIT ratio, ranking in the top ten for every applicable combination and ranking first for all permanent CSI models.
- `ocf_per_share`, `altman_z2`, and `roa` also appeared in the top ten for all six applicable combinations.
- Evidence is bounded GBM-only predictor workspace evidence, not final full model-suite feature importance.

## Next Recommended Role

next_recommended_role: ds-validator

Recommended validation focus:

- Confirm PIT-ratio scope excludes macro controls as intended.
- Confirm local `03_Data_Output/10_FeatureImportance/pit_ratio_importance/**` outputs remain ignored and unstaged.
- Confirm summary/coverage counts match script output.

## Changed Files

Ticket-owned files changed or created:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_PIT_Ratio_Log_Odds_Importance_Report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_pit_ratio_importance_summary.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_pit_ratio_coverage_audit.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_build_pit_ratio_importance.py`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_validation_report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

Ignored local outputs generated:

- `03_Data_Output/10_FeatureImportance/pit_ratio_importance/**`

Pre-existing unrelated dirty files in protected presentation/cloud paths were not touched.

## Verification

Commands run:

```powershell
git status --short --branch
py -3.10 05_Documentation\09_Epics\AE-FEAT-IMPORT_Feature_Importance\AE-FEAT-IMPORT-005R_build_pit_ratio_importance.py
git check-ignore -v 03_Data_Output/10_FeatureImportance/pit_ratio_importance/AE-FEAT-IMPORT-005R_pit_ratio_importance_summary.csv 03_Data_Output/10_FeatureImportance/pit_ratio_importance/row_deltas/raw_dynamic_csi_earn_yld_row_deltas.parquet
Import-Csv 05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-005R_pit_ratio_importance_summary.csv | Measure-Object
```

Verification results:

- Script exited with code 0.
- Summary rows: 246.
- Coverage rows: 8.
- Row-delta parquet files: 246.
- Local generated outputs are ignored by `.gitignore`.
- New compact `05_Documentation/**` ticket artifacts are also ignored by the repository-wide documentation ignore rule and will require explicit force-add by the committer role.
- No staging, commit, push, merge, training, evaluation, index construction, sensitivity run, pipeline regeneration, or presentation compile was performed.

## Human Readability

The main report includes compact top-ratio tables for temporary CSI, permanent CSI, and each applicable feature set, plus a coverage audit summary and a short interpretation of recurring ratio signals.
