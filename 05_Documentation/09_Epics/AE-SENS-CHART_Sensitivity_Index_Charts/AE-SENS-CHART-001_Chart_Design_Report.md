# AE-SENS-CHART-001 Chart Design Report

## Scope

Created presentation-draft sensitivity tables and two chart candidates under the scoped AE-SENS-CHART evidence folder. This ticket did not edit the final presentation and did not compile the deck.

## Source Data

- `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\5_SensitivityAnalysis\presentation_ready\sensitivity_cmt_model_summary.csv`
- `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\5_SensitivityAnalysis\presentation_ready\sensitivity_cmt_index_summary.csv`
- `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\5_SensitivityAnalysis\presentation_ready\temporary_blocked_config_disclosure.csv`
- `C:\Users\Tristan Leiter\Documents\AgonyAndExcstasy\03_Data_Output\5_SensitivityAnalysis\04_index_construction\combined_11c_performance.csv`

## Draft Tables

- `tables/sensitivity_run_status_table.csv`
- `tables/sensitivity_index_stability_table.csv`
- `tables/universe_stability_summary.csv`
- `tables/universe_best_strategy_distribution.csv`

## Chart Candidates

### Revision Note

Chart 2 was refined in AE-SENS-CHART-001R after human feedback that the original scatter plot did not make the core message clear enough: better model AP does not mechanically imply better index alpha, and the paper's main run is within the observed sensitivity distribution rather than an outlier.

### Chart 1: Sensitivity Stability Distribution

Path: `charts/chart1_sensitivity_stability_distribution.png`

This chart shows the distribution of each completed/reused C/M/T run's best benchmark-relative geometric-return delta by universe. The main run `C080_M020_T018` is highlighted with a red diamond. Recommended for a slide because it shows robustness across all four universes without overloading the viewer.

### Chart 2: Model-vs-Index Sensitivity Scatter

Path: `charts/chart2_model_vs_index_sensitivity_scatter.png`

This chart plots OOS AP against total-market benchmark-relative alpha for the 24 completed/reused C/M/T runs. It highlights the main run, AP winner, strongest composite, and strongest 11C total-market run. Recommended as an appendix or secondary slide because it explains that model AP and index alpha are related but not identical objectives.

Refined path: `charts/chart2_model_vs_index_sensitivity_scatter_refined.png`

The refined chart adds a linear trend line, Pearson and Spearman correlation annotation, and an explicit caption: "High AP and high index alpha are related but not identical objectives."

## Alternatives Considered

- A full threshold/lockout heatmap was not used for this draft because it would duplicate AE-INDEX-SUITE grid material rather than focus on C/M/T sensitivity.
- A line plot by transaction-cost bps was not selected because the sensitivity C/M/T runs are primarily no-cost/raw sensitivity outputs; transaction-cost robustness is already represented by the accepted-label AE-INDEX-SUITE grid.

## Human Approval Request

Please review the two chart drafts and choose one of:

1. approve both charts for final slide integration;
2. approve only one chart;
3. request edits to labels, colors, metrics, or layout;
4. reject the chart design and request a different visual.
