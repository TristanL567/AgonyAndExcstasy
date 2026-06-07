# AE-FEAT-IMPORT-004R Worker Completion Report

## Status

status: complete

role: AEGIS worker only. No self-approval, staging, commit, push, merge, or future-ticket work performed.

## Summary

Computed model-based family-level log-odds perturbation feature importance for all eight requested model-track combinations using the complete bounded GBM-only predictor workspace from AE-FEAT-IMPORT-003S.

The computation used training/CV-analysis rows only and deterministic within-CV-block permutation with fixed seeds. It did not compute point-in-time ratio importance or individual-feature importance.

## Artifacts

Documentation/evidence artifacts:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-004R_build_family_importance.py`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-004R_family_importance_summary.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-004R_unmapped_feature_audit.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-004R_Family_Log_Odds_Importance_Report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-004R_validation_report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-004R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

Local-only generated outputs:

- `03_Data_Output/10_FeatureImportance/family_importance/AE-FEAT-IMPORT-004R_family_importance_summary.csv`
- `03_Data_Output/10_FeatureImportance/family_importance/AE-FEAT-IMPORT-004R_unmapped_feature_audit.csv`
- `03_Data_Output/10_FeatureImportance/family_importance/AE-FEAT-IMPORT-004R_run_metadata.json`
- `03_Data_Output/10_FeatureImportance/family_importance/row_deltas/*.parquet`

## Findings

All eight model-track combinations were completed with 143,173 training/CV-analysis rows each.

Temporary CSI:

- `fund`: point-in-time ratios and rolling-window statistics dominate.
- `raw`: price momentum, volatility, and macro interactions dominate, followed by point-in-time ratios and rolling-window statistics.
- `latent_raw`: the VAE latent block has large perturbation response.
- `raw_plus_latent`: raw price/macro, point-in-time, and rolling families dominate; the latent block has very small marginal response.

Permanent CSI:

- `fund`: point-in-time ratios and rolling-window statistics dominate.
- `raw`: price momentum, volatility, and macro interactions dominate, followed by point-in-time ratios and rolling-window statistics.
- `latent_raw`: the VAE latent block has large perturbation response.
- `raw_plus_latent`: raw price/macro, point-in-time, and rolling families dominate; the latent block remains much smaller than raw/engineered families.

Unmapped required predictor features were audited and computed as non-canonical blocks where applicable: `siccd`, `fyear`, and VAE latent dimensions.

## Verification

Commands run:

- `git branch --show-current`: returned `Development-FE`.
- `git status --short`: showed pre-existing protected dirty files plus ticket-owned/untracked artifacts; no staging.
- `py -3.10 05_Documentation\09_Epics\AE-FEAT-IMPORT_Feature_Importance\AE-FEAT-IMPORT-004R_build_family_importance.py`: rerun exited with code 0 after processing all eight combinations.
- CSV coverage inspection: 98 summary rows, 88 canonical attempts, 76 computed rows, 108 audit rows.
- Row-delta inspection: 76 local parquet files under `03_Data_Output/10_FeatureImportance/family_importance/row_deltas/`.

No protected files were edited and no `03_Data_Output/**` files were staged or committed.

## Changed Files

Ticket-owned files changed or created:

- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-004R_build_family_importance.py`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-004R_family_importance_summary.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-004R_unmapped_feature_audit.csv`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-004R_Family_Log_Odds_Importance_Report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-004R_validation_report.md`
- `05_Documentation/09_Epics/AE-FEAT-IMPORT_Feature_Importance/AE-FEAT-IMPORT-004R_worker_completion_report.md`
- `epics/AE-FEAT-IMPORT/ledger.md`

Local-only generated outputs:

- `03_Data_Output/10_FeatureImportance/family_importance/**`

Pre-existing unrelated dirty paths in `06_Presentations/**` and `07_CloudComputing/**` were not touched.

## Next Recommended Role

next_recommended_role: ds-validator

Recommended validation focus:

- Confirm the latent block treatment outside the canonical 11 raw/engineered families.
- Confirm that within-CV-block permutation is acceptable as the family perturbation design.
- Confirm that bounded GBM-only caveats are sufficient for downstream interpretation.

## Human Readability

The main report is written for interpretation planning and includes the ranked family summary plus short temporary/permanent CSI interpretation. The compact CSV contains the full evidence table for validator review.
