# AE-PRES-INDEX-REV-006 Robustness, Turnover, Sensitivity Update Report

## Scope

Ticket `AE-PRES-INDEX-REV-006` revises the June final presentation robustness block for intuitive OOS interpretation. The edit is limited to:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`
- ticket evidence under `05_Documentation/09_Epics/AE-PRES-INDEX-REV_Index_Presentation_Revisions/`
- `epics/AE-PRES-INDEX-REV/ledger.md`

No data, code, input, cloud, model, evaluation, index-construction, sensitivity, pipeline, or full-deck compile commands were run.

## Changed Slides

The following slides were revised in place:

1. `Transaction-Cost Robustness`
2. `Turnover Effect`
3. `Threshold Families and Turnover`
4. `Sensitivity: Temporary CSI Main Run Versus C/M/T Grid`
5. `Appendix A19: Temporary CSI Sensitivity Detail`

No frames were inserted or removed.

## Implementation Summary

- Transaction-cost robustness now shows OOS temporary and permanent CSI winners across 5, 10, and 20 bps rather than only a 0-to-20 bps comparison.
- Turnover effect now displays annualized gross buy+sell turnover and source-provided transaction-cost drag at 5, 10, and 20 bps for both OOS tracks.
- Threshold-family slide now focuses on final selected rule families rather than an exhaustive grid: temporary CSI uses finite Youden/FPR5 lockouts, while permanent CSI uses stricter FPR3/FPR5 permanent rules.
- Sensitivity slides now state explicitly that sensitivity evidence is temporary CSI only, identify the accepted main run as the continuity baseline, summarize completed-run stability, and disclose the blocked partial configurations.
- `SLIDE_DATA_SOURCES.md` rows 28, 29, 30, 31, and 52 were updated for the changed claims and sources.

## Source Files Used

Transaction-cost robustness and turnover:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/transaction_cost_robustness_summary.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/transaction_cost_impact.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/turnover_summary.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/winner_turnover_summary_20bps.csv`
- `05_Documentation/09_Epics/AE-TC-AUDIT_Transaction_Cost_Audit/AE-TC-AUDIT-001_best_strategy_cost_drag_summary.csv`

Threshold-family interpretation:

- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/threshold_family_summary_20bps.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/final_tables/winner_turnover_summary_20bps.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/turnover_summary.csv`

Sensitivity:

- `05_Documentation/09_Epics/AE-SENS-CHART_Sensitivity_Index_Charts/charts/chart1_sensitivity_stability_distribution.png`
- `05_Documentation/09_Epics/AE-SENS-CHART_Sensitivity_Index_Charts/tables/universe_stability_summary.csv`
- `05_Documentation/09_Epics/AE-SENS-CHART_Sensitivity_Index_Charts/tables/sensitivity_index_stability_table.csv`
- `05_Documentation/09_Epics/AE-SENS-CHART_Sensitivity_Index_Charts/AE-SENS-CHART-001R_Chart_Interpretation.md`
- `03_Data_Output/5_SensitivityAnalysis/presentation_ready/sensitivity_cmt_model_summary.csv`
- `03_Data_Output/5_SensitivityAnalysis/presentation_ready/sensitivity_cmt_index_summary.csv`
- `03_Data_Output/5_SensitivityAnalysis/presentation_ready/temporary_index_transaction_cost_lines.csv`
- `03_Data_Output/5_SensitivityAnalysis/presentation_ready/temporary_blocked_config_disclosure.csv`

Detailed slide-to-source traceability is in `AE-PRES-INDEX-REV-006_source_traceability.csv`.

## Key Interpretation

- OOS temporary and permanent CSI winner rankings do not change from 5 to 20 bps in the displayed universes.
- Transaction-cost drag scales with annualized gross turnover; the largest drag appears in Mid and Small Cap winners because turnover is much higher there.
- Temporary CSI sensitivity is supportive robustness evidence only. It does not replace the accepted main run, and it does not support permanent-CSI sensitivity claims.

## Notes For Validator

- The transaction-cost and turnover slides are OOS-only and use `response_track in (dynamic_csi, permanent_csi)`.
- The turnover slide covers 5, 10, and 20 bps for both OOS tracks.
- The sensitivity claims are restricted to temporary CSI because the available sensitivity evidence is temporary-CSI-only.
- `SLIDE_DATA_SOURCES.md` rows 28, 29, 30, 31, and 52 were updated.
