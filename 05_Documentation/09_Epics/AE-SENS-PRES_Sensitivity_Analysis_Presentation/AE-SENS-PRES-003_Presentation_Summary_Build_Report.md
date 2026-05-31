# AE-SENS-PRES-003 Presentation Summary Build Report

## Scope

Created presentation-ready temporary-CSI sensitivity summary tables from existing local outputs. This ticket combines:

- AE-SENS CMT sensitivity results
- AE-INDEX-SUITE full temporary-CSI threshold/lockout/transaction-cost grid
- benchmark-relative index performance
- blocked-config disclosure

No model training, AutoGluon, sensitivity-grid scripts, index construction, code edits, presentation edits, SSH, or Vast.ai access was performed.

The `03_Data_Output` writes are limited to derived summary CSVs under:

`03_Data_Output/5_SensitivityAnalysis/presentation_ready/`

## Branch And HEAD

- Branch: `Development`
- HEAD at build time: `d04bc02`

## Source Files Used

- `03_Data_Output/5_SensitivityAnalysis/00_manifest/run_registry.csv`
- `03_Data_Output/5_SensitivityAnalysis/00_manifest/blocked_runs.csv`
- `03_Data_Output/5_SensitivityAnalysis/05_comparisons/full_grid_model_metric_ranking.csv`
- `03_Data_Output/5_SensitivityAnalysis/05_comparisons/full_grid_best_configs_by_objective.csv`
- `03_Data_Output/5_SensitivityAnalysis/05_comparisons/full_grid_11c_index_ranking.csv`
- `03_Data_Output/5_SensitivityAnalysis/05_comparisons/full_grid_label_count_ranking.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/full_grid_manifest.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`
- AE-INDEX-SUITE per-model temporary `index_performance_gross_and_net_by_tc.csv` files discovered through `full_grid_manifest.csv`

See `AE-SENS-PRES-003_source_file_map.csv` for output-to-source mapping.

## Output Files Created

Derived summaries under `03_Data_Output/5_SensitivityAnalysis/presentation_ready/`:

- `sensitivity_cmt_model_summary.csv`
- `sensitivity_cmt_index_summary.csv`
- `temporary_index_threshold_lockout_cost_summary.csv`
- `temporary_index_best_by_universe_cost.csv`
- `temporary_index_distribution_for_boxplots.csv`
- `temporary_index_transaction_cost_lines.csv`
- `temporary_blocked_config_disclosure.csv`
- `temporary_presentation_key_findings.csv`

Evidence under `05_Documentation/09_Epics/AE-SENS-PRES_Sensitivity_Analysis_Presentation/`:

- `AE-SENS-PRES-003_Presentation_Summary_Build_Report.md`
- `AE-SENS-PRES-003_source_file_map.csv`
- `AE-SENS-PRES-003_validation_checks.csv`

## Row Counts

| Output | Rows |
|---|---:|
| `sensitivity_cmt_model_summary.csv` | 81 |
| `sensitivity_cmt_index_summary.csv` | 27 |
| `temporary_index_threshold_lockout_cost_summary.csv` | 1024 |
| `temporary_index_best_by_universe_cost.csv` | 16 |
| `temporary_index_distribution_for_boxplots.csv` | 1024 |
| `temporary_index_transaction_cost_lines.csv` | 16 |
| `temporary_blocked_config_disclosure.csv` | 3 |
| `temporary_presentation_key_findings.csv` | 6 |

## Presentation-Ready Findings

- CMT sensitivity status: 27 temporary-CSI run IDs represented; 14 complete; 10 reused complete; 3 blocked partial.
- Blocked partial configs: `C080_M000_T012`, `C080_M000_T018`, `C060_M020_T028`.
- Strongest overall composite config: `C090_M000_T012`.
- AP winner: `C060_M000_T012`.
- Strongest 11C total-market benchmark-relative config: `C090_M020_T018`.
- Continuity baseline: `C080_M020_T018`, defensible but not top-ranked.
- Full threshold/lockout/transaction-cost temporary index grid is presentation-ready through AE-INDEX-SUITE outputs; this is separate from the CMT sensitivity output family.

## Limitations

- AE-SENS CMT outputs are temporary-CSI sensitivity runs and do not natively contain `fpr5` or transaction-cost overlays.
- AE-INDEX-SUITE supplies `fpr5`, turnover, and 0/5/10/20 bps transaction-cost outputs for the temporary index grid.
- The three blocked CMT configs should be disclosed rather than imputed.
- The output source families should remain separate in slides: CMT sensitivity results versus AE-INDEX-SUITE index robustness grid.

## Recommendation For AE-SENS-PRES-004

AE-SENS-PRES-004 can update the sensitivity/robustness slides without additional computation.

Recommended table usage:

- `temporary_presentation_key_findings.csv` for headline claims.
- `sensitivity_cmt_model_summary.csv` and `sensitivity_cmt_index_summary.csv` for CMT sensitivity tables.
- `temporary_index_distribution_for_boxplots.csv` for distribution plots.
- `temporary_index_transaction_cost_lines.csv` for transaction-cost line plots.
- `temporary_blocked_config_disclosure.csv` for the blocked-config caveat.
