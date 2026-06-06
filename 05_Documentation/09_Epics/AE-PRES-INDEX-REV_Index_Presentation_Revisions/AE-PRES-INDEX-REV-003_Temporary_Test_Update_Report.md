# AE-PRES-INDEX-REV-003 Temporary Test Update Report

## Scope

Ticket `AE-PRES-INDEX-REV-003` revises the temporary-CSI test-set index-result block in the June final presentation. The edit is limited to:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`
- ticket evidence under `05_Documentation/09_Epics/AE-PRES-INDEX-REV_Index_Presentation_Revisions/`
- `epics/AE-PRES-INDEX-REV/ledger.md`

No data, code, input, cloud, model, index-construction, evaluation, sensitivity, or pipeline files were modified or regenerated.

## Changed Slides

The prior mixed temporary/permanent test-set slide was replaced with a temporary-only two-slide block:

1. `Temporary CSI Test-Set Index Results at 10 bps`
2. `Temporary CSI Test-Set Diagnostic and Active Contribution`

The second slide is inserted immediately after the result slide, before the temporary OOS block. Permanent CSI, transaction-cost robustness, turnover, threshold-family, and sensitivity slide content was not intentionally revised.

## Source Files Used

Result slide:

- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_grid_summary.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_validation_checks.csv`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-006_Test_Set_Index_Construction_Report.md`

Diagnostic/contribution slide:

- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_config_level_attribution.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_reconciliation_checks.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised/error_cost_decomposition_by_crsp_universe.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/temporary_csi/11c_index_revised_raw_plus_latent/error_cost_decomposition_by_crsp_universe.csv`

Detailed row-level traceability is in `AE-PRES-INDEX-REV-003_source_traceability.csv`.

## Key Interpretation Added

The result slide is explicitly a 2016--2019 isolated test-set check at 10 bps, not a 2020+ OOS result. The diagnostic slide explicitly states that its contribution rows use main-suite `period=test` attribution, because standalone isolated test-only diagnostic/contribution files are missing under `03_Data_Output/9_TestIndexConstruction`.

The interpretation avoids overclaiming event avoidance. It states that test-window gains mostly come from retained-stock reweighting and geometric effects after false-positive costs, with Small Cap showing the clearest TP exclusion contribution.

## Notes For Validator

- Strategy rows are temporary CSI, `period=test`, and `transaction_cost_bps=10`.
- Result-slide values use isolated test-output files.
- Diagnostic/contribution rows use main-suite `period=test` attribution and carry the visible source caveat.
- No OOS values are used in the test slides.
- `SLIDE_DATA_SOURCES.md` rows 20 and 21 were updated for the changed slides, and later source-map frame numbers were mechanically renumbered by one because a new diagnostic frame was inserted.
