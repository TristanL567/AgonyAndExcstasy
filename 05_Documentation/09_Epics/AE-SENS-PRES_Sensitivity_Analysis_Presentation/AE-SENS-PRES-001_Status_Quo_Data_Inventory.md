# AE-SENS-PRES-001 Status-Quo Data Inventory

## Scope

This read-only inventory documents the temporary-CSI sensitivity-analysis data currently available locally for presentation follow-up work.

The only writes made by this ticket are this report and companion inventory CSVs under:

`05_Documentation/09_Epics/AE-SENS-PRES_Sensitivity_Analysis_Presentation/`

No model training, sensitivity scripts, index construction, presentation editing, code editing, SSH, or Vast.ai access was performed.

## Branch And HEAD

- Branch: `Development`
- HEAD: `cfda8cf`
- Ticket: `AE-SENS-PRES-001`

## Data Locations Inspected

- `03_Data_Output/5_SensitivityAnalysis/`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/`
- `07_CloudComputing/Validation/AE-SENS/`
- `05_Documentation/09_Epics/AE-SENS_CMT_Sensitivity_Grid/`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`

## File Inventory Summary

Total local files under `03_Data_Output/5_SensitivityAnalysis/`: 748.

Top-level folder counts:

| Folder | Files |
|---|---:|
| `00_manifest` | 19 |
| `01_labels` | 79 |
| `02_model_training` | 259 |
| `03_predictions` | 129 |
| `04_index_construction` | 168 |
| `05_comparisons` | 9 |
| `06_logs` | 83 |
| `99_reports` | 2 |

Detailed file path, size, timestamp, run ID, extension, and SHA256 inventory is in `AE-SENS-PRES-001_file_inventory.csv`.

## Run Coverage Summary

Expected CMT grid: 27 temporary-CSI run IDs from `C060/C080/C090 x M000/M020/M030 x T012/T018/T028`.

Observed run status classes from `00_manifest/run_registry.csv`:

| Status class | Count |
|---|---:|
| `complete` | 14 |
| `reused_complete` | 10 |
| `blocked_partial` | 3 |
| `missing` | 0 |

Blocked partial runs from `00_manifest/blocked_runs.csv`:

- `C080_M000_T012`
- `C080_M000_T018`
- `C060_M020_T028`

The expected status is supported by local files: 27 run IDs represented, 24 complete or reused complete, and 3 blocked partial. Detailed coverage is in `AE-SENS-PRES-001_run_coverage.csv`.

## Available Model Metrics

The sensitivity comparison file `05_comparisons/full_grid_model_metric_ranking.csv` contains model metrics for CV, test, and OOS splits.

Available model metrics:

- AP
- AUC
- recall at FPR 1%
- recall at FPR 3%
- recall at FPR 5%
- Brier

The companion CSV `AE-SENS-PRES-001_available_metrics.csv` lists availability and best observed run by split and metric.

Presentation-relevant findings supported by existing files:

- `C060_M000_T012` is the AP winner for CV, test, and OOS AP.
- `C090_M000_T012` is the strongest overall composite and leads many fixed-FPR recall metrics.

## Available Index Outputs

The sensitivity CMT-grid includes 11C index-construction artifacts and comparison summaries under:

- `04_index_construction/`
- `00_manifest/11c_coverage_check.csv`
- `05_comparisons/full_grid_11c_index_ranking.csv`

Available sensitivity-grid index evidence includes:

- geometric return fields
- Sharpe ratio fields
- max drawdown fields
- benchmark-relative delta fields
- detailed per-run 11C CSV/RDS files for thresholds, returns, performance, weights, exclusion summaries, and error-cost decomposition where retained

The sensitivity CMT-grid is distinct from the later full AE-INDEX-SUITE threshold/lockout/transaction-cost grid under `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/`.

Transaction-cost variants and turnover outputs belong to that full index-suite output family, not the original CMT sensitivity-grid comparison claim set. Detailed index-output availability is in `AE-SENS-PRES-001_available_index_outputs.csv`.

## Presentation-Claim Source Map

| Claim | Source | Support |
|---|---|---|
| 27 run IDs represented | `00_manifest/run_registry.csv` | Registry has 27 rows. |
| 24 complete/reused | `00_manifest/run_registry.csv` | 14 `completed_full_storage_pruned`; 10 `skipped_complete_storage_pruned`. |
| 3 blocked_partial | `00_manifest/blocked_runs.csv` | `C080_M000_T012`, `C080_M000_T018`, `C060_M020_T028`. |
| `C090_M000_T012` strongest overall composite | `05_comparisons/full_grid_best_configs_by_objective.csv` | `most_defensible_overall_composite` row selects `C090_M000_T012`. |
| `C060_M000_T012` AP winner | `05_comparisons/full_grid_best_configs_by_objective.csv` | AP objective rows select `C060_M000_T012` for CV, test, and OOS AP. |
| `C090_M020_T018` strongest 11C total-market benchmark-relative config | `05_comparisons/full_grid_best_configs_by_objective.csv`; `05_comparisons/full_grid_11c_index_ranking.csv` | `highest_11c_total_market_difference_vs_benchmark` row selects `C090_M020_T018`; ranking file shows total-market rank 1. |
| `C080_M020_T018` defensible continuity baseline but not top-ranked | `05_comparisons/full_grid_11c_index_ranking.csv`; `05_comparisons/full_grid_label_count_ranking.csv` | Present as `skipped_complete_storage_pruned`; total-market benchmark-relative rank 18; label counts match the revised temporary baseline. |

The existing `SLIDE_DATA_SOURCES.md` maps the sensitivity status and result slides to these source files:

- Frame 8: `run_registry.csv`, `blocked_runs.csv`, and sensitivity manifest files for 27/24/3 status.
- Frame 10: `full_grid_best_configs_by_objective.csv`, `full_grid_label_count_ranking.csv`, `full_grid_model_metric_ranking.csv`, and `full_grid_11c_index_ranking.csv` for selected CMT claims.
- Frame 28: detailed appendix sensitivity sources, including threshold summaries and reports.

## Separation Of Output Families

- Sensitivity CMT-grid outputs: `03_Data_Output/5_SensitivityAnalysis/**`. These support the temporary-CSI C/M/T sensitivity claims and local presentation sensitivity slides.
- Full index-suite outputs: `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/**`. These support model-family index comparisons, transaction-cost overlays, turnover, and the full threshold/lockout grid.
- Final-presentation source-map references: `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/SLIDE_DATA_SOURCES.md`. This file was inspected read-only and not modified.

## Blockers Or Gaps For AE-SENS-PRES-002

- Three CMT configurations are blocked partial locally: `C080_M000_T012`, `C080_M000_T018`, and `C060_M020_T028`.
- The CMT sensitivity grid is temporary-CSI only; permanent-CSI sensitivity remains future work unless a separate run exists elsewhere.
- Transaction-cost/turnover claims should use AE-INDEX-SUITE outputs, not the sensitivity CMT-grid, unless AE-SENS-PRES-002 explicitly scopes a bridge table.
- The status quo is sufficient for AE-SENS-PRES-002 to build presentation-ready sensitivity tables without rerunning computation.
