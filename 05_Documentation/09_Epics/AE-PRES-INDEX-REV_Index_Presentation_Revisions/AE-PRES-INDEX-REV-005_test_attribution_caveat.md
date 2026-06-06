# AE-PRES-INDEX-REV-005 Test Attribution Caveat

## Caveat

The `Permanent CSI Test-Set Index Results at 10 bps` slide uses the isolated test-index package:

- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_performance_gross_and_net_by_tc.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_test_index_grid_summary.csv`
- `03_Data_Output/9_TestIndexConstruction/AE-FP-DIAG-006_validation_checks.csv`

Those files provide test-set performance rows for `track=permanent_csi`, including the 10 bps best-strategy rows used on the slide.

The adjacent diagnostic/contribution slide does not come from a standalone isolated test diagnostic file in `03_Data_Output/9_TestIndexConstruction/`. It uses the accepted main-suite attribution source:

- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_config_level_attribution.csv`
- `05_Documentation/09_Epics/AE-ATTRIB_Main_Index_Attribution/AE-ATTRIB-001_reconciliation_checks.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/raw_plus_latent/3_Modelling_Results/Necessary/permanent_csi/11c_index_revised_raw_plus_latent/error_cost_decomposition_by_crsp_universe.csv`

## Matching Keys

The attribution rows match the displayed Permanent CSI test strategy by:

- `track=permanent CSI`
- `response_track=permanent_csi`
- `period=test`
- `transaction_cost_bps=10`
- `model=raw_plus_latent`
- `threshold_method=youden`
- `strategy_id=youden_permanent`
- universes `total_market`, `large_cap`, `mid_cap`, and `small_cap`

## On-Slide Disclosure

The diagnostic slide includes this caveat in the alert block:

```text
The result table above uses isolated test-output files. This diagnostic view uses reconciled main-suite period=test attribution rows for the same Permanent CSI strategy, because no standalone isolated test diagnostic/contribution file exists in the 9_TestIndexConstruction package.
```

## Interpretation Boundary

The contribution slide is framed as an accounting decomposition, not a causal event-avoidance claim. The slide states that test-set gains are mostly retained-stock reweighting plus geometric portfolio effects, partly offset by FP exclusion cost and small transaction-cost drag. Direct TP event-avoidance gain is not presented as the main channel.
