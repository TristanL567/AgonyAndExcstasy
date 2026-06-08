# AE-PRES-INDEX-REV-003 Test Attribution Caveat

The temporary-CSI test result slide uses isolated test-set output from:

- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_grid_summary.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_validation_checks.csv`

The diagnostic/contribution slide does not have a standalone isolated diagnostic source under `03_Data_Output/9_TestIndexConstruction`. This is the known `AE-PRES-INDEX-REV-001` gap for block D.

For that reason, the diagnostic/contribution slide uses existing reconciled main-suite attribution rows from:

- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_config_level_attribution.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_reconciliation_checks.csv`
- model-specific `error_cost_decomposition_by_crsp_universe.csv` files under `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/.../temporary_csi/...`

The slide text states this caveat directly:

> The result table above is from isolated test-output files. This diagnostic view is not a standalone AE-FP-DIAG-006 test diagnostic build; it uses reconciled main-suite `period=test` attribution rows for the same temporary-CSI strategies.

Interpretation boundary:

- The diagnostic slide is evidence for a reconciled contribution decomposition of the selected main-suite `period=test` temporary-CSI strategy rows.
- It is not presented as a standalone AE-FP-DIAG-006 diagnostic artifact.
- It does not use OOS values as test values.
- It avoids causal event-avoidance claims and frames gains as retained-stock reweighting plus geometric effects after false-positive costs, with Small Cap showing the clearest TP exclusion gain.
