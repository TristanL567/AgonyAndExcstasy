# AE-FEAT-IMPORT-006R Worker Completion Report

## Status

status: complete

## Summary

Computed model-based individual-feature log-odds perturbation importance for all predictor-required features across all eight bounded GBM-only model-track combinations.

## Artifacts

Ticket evidence artifacts created:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_Individual_Feature_Log_Odds_Importance_Report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_individual_feature_importance_summary.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_feature_mapping_coverage_audit.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_build_individual_feature_importance.py`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_validation_report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

Local-only ignored outputs:

- `03_Data_Output/10_FeatureImportance/individual_feature_importance/AE-FEAT-IMPORT-006R_individual_feature_importance_summary.csv`
- `03_Data_Output/10_FeatureImportance/individual_feature_importance/AE-FEAT-IMPORT-006R_feature_mapping_coverage_audit.csv`
- `03_Data_Output/10_FeatureImportance/individual_feature_importance/AE-FEAT-IMPORT-006R_run_metadata.json`
- `03_Data_Output/10_FeatureImportance/individual_feature_importance/per_model_track/*.csv`

## Findings

- `2,824` individual feature perturbation rows were computed.
- All eight model-track combinations were completed.
- `2,716` rows mapped to the canonical 11-family taxonomy.
- `100` rows were latent/VAE features.
- `8` rows were required predictor features outside the canonical family rules and were retained in the audit.
- Evidence is bounded GBM-only predictor workspace evidence, not final full model-suite feature importance.

## Next Recommended Role

next_recommended_role: ds-validator

Recommended validation focus:

- Confirm all eight combinations are represented in the summary and audit.
- Confirm individual-feature perturbation uses training/CV rows only and fixed within-CV permutation.
- Confirm local `03_Data_Output/10_FeatureImportance/individual_feature_importance/**` outputs remain ignored and unstaged.
- Confirm bounded GBM-only caveat is present.

## Changed Files

Ticket-owned files changed or created:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_Individual_Feature_Log_Odds_Importance_Report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_individual_feature_importance_summary.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_feature_mapping_coverage_audit.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_build_individual_feature_importance.py`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_validation_report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-006R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

Ignored local outputs generated:

- `03_Data_Output/10_FeatureImportance/individual_feature_importance/**`

Pre-existing unrelated dirty files in protected presentation/cloud paths were not touched.

## Verification

Commands run:

```powershell
git status --short --branch
py -3.10 05_Documentation\09_Epics\AE-FEAT-IMPORT_Feature_Importance\AE-FEAT-IMPORT-006R_build_individual_feature_importance.py
```

Verification results:

- Script completed all eight model-track combinations.
- The command wrapper returned a timeout after final metadata was printed; completion was validated from written metadata and output artifacts.
- Summary rows: `2,824`.
- Coverage rows: `2,824`.
- Local generated outputs were written under `03_Data_Output/10_FeatureImportance/individual_feature_importance/`.
- Documentation artifacts are present under repository-ignored `05_Documentation/**`; no staging was performed by this worker.
- No staging, commit, push, merge, training, evaluation, index construction, sensitivity run, pipeline regeneration, or presentation compile was performed.

## Human Readability

The main report includes ranked top-feature tables for temporary CSI by model, permanent CSI by model, repeated top features across model-track combinations, mapping coverage counts, and interpretation of PIT/family alignment and latent/VAE materiality.
