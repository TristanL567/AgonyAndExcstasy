# AE-PRES-INDEX-REV-005 Permanent Test Update Report

## Scope

Ticket `AE-PRES-INDEX-REV-005` revises the Permanent CSI test-set index-results block in the June final presentation. The edit is limited to:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`
- ticket evidence under `05_Documentation/09_Epics/AE-PRES-INDEX-REV_Index_Presentation_Revisions/`
- `epics/AE-PRES-INDEX-REV/ledger.md`

No data, code, input, cloud, research, model, index-construction, evaluation, sensitivity, pipeline, or deck-compile files were modified or regenerated.

## Changed Slides

Two slides were added immediately after the Permanent CSI OOS diagnostic/contribution slide and before transaction-cost robustness:

1. `Permanent CSI Test-Set Index Results at 10 bps`
2. `Permanent CSI Test-Set Diagnostic and Active Contribution`

The result slide shows benchmark and best-strategy rows for Total, Large, Mid, and Small universes. The selected Permanent CSI test-set strategy is AG Exp. Dataset + VAE with the permanent Youden rule for all four universes.

## Source Files Used

Result slide:

- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_grid_summary.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_validation_checks.csv`
- `05_Documentation/09_Epics/AE-FP-DIAG_False_Positive_Diagnostics/AE-FP-DIAG-006_Test_Set_Index_Construction_Report.md`

Diagnostic/contribution slide:

- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_config_level_attribution.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_reconciliation_checks.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_raw_plus_latent/error_cost_decomposition_by_crsp_universe.csv`

Detailed row-level traceability is in `AE-PRES-INDEX-REV-005_source_traceability.csv`.

## Attribution Caveat

The result table uses isolated test-output files from `03_Data_Output/9_TestIndexConstruction/`. The diagnostic/contribution slide uses reconciled main-suite `period=test` rows from `AE-ATTRIB-001_config_level_attribution.csv`, because no standalone isolated test diagnostic/contribution file exists in the `9_TestIndexConstruction` package.

This caveat is stated on-slide and in `AE-PRES-INDEX-REV-005_test_attribution_caveat.md`.

## Key Interpretation Added

The diagnostic slide avoids causal overclaiming. It frames the test-set gain as a contribution decomposition:

```text
TP exclusion gain + FP exclusion cost + retained-stock reweighting effect + transaction-cost effect + compounding/geometric adjustment = realized alpha
```

For the Permanent CSI test-set rows, direct TP event-avoidance gain is small. The positive active contribution is mostly retained-stock reweighting plus geometric portfolio effects, partly offset by broad-exclusion FP cost and small transaction-cost drag.

## Notes For Validator

- Result rows are `track=permanent_csi`, `period=test`, and `transaction_cost_bps=10`.
- The isolated test package has `oos_rows=0`.
- All four universes are represented: `total_market`, `large_cap`, `mid_cap`, and `small_cap`.
- Contribution rows use `track=permanent CSI`, `response_track=permanent_csi`, `period=test`, `transaction_cost_bps=10`, `model=raw_plus_latent`, `threshold_method=youden`, and `strategy_id=youden_permanent`.
- `SLIDE_DATA_SOURCES.md` rows 26 and 27 map the new slides; later rows were renumbered by +2, with Bibliography now row 56.
