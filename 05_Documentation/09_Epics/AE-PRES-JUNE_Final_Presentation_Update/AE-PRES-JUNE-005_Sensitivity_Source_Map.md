# AE-PRES-JUNE-005 Sensitivity Source Map

## Edited June Presentation File

`06_Presentations/02_FinalPresentation/Necessary/FinalPresentation_June/FinalPresentation_TristanLeiter_h11815352.Rnw`

## Slide-Level Sources

| Frame | Claim/Table | Source files |
|---|---|---|
| Robustness I: Temporary CSI Sensitivity Grid | Temporary-CSI C/M/T sensitivity is complete locally; all 27 run IDs are represented; 24 are complete/reused; 3 are `blocked_partial`; blocked IDs are `C080_M000_T012`, `C080_M000_T018`, and `C060_M020_T028`. | `03_Data_Output/5_SensitivityAnalysis/00_manifest/run_registry.csv`; `03_Data_Output/5_SensitivityAnalysis/00_manifest/blocked_runs.csv`; `03_Data_Output/5_SensitivityAnalysis/00_manifest/download_summary.json`; `03_Data_Output/5_SensitivityAnalysis/00_manifest/checksum_verification.csv` |
| Robustness II: Sensitivity Results and Limits | `C090_M000_T012` is the strongest overall composite configuration; `C060_M000_T012` is the AP winner; `C090_M020_T018` is strongest for 11C total-market benchmark-relative performance; baseline `C080_M020_T018` remains defensible but is not top-ranked. | `03_Data_Output/5_SensitivityAnalysis/05_comparisons/full_grid_best_configs_by_objective.csv`; `03_Data_Output/5_SensitivityAnalysis/05_comparisons/full_grid_model_metric_ranking.csv`; `03_Data_Output/5_SensitivityAnalysis/05_comparisons/full_grid_11c_index_ranking.csv`; `03_Data_Output/5_SensitivityAnalysis/05_comparisons/full_grid_label_count_ranking.csv` |
| Remaining Robustness Work | Permanent-CSI sensitivity grid, minimum-volatility benchmark, quality/risk-scaling benchmark, active CSI-probability weighting, and recovered bankrupt/insolvent diagnostic are future/not-yet-completed work. | `03_Data_Output/5_SensitivityAnalysis/99_reports/sensitivity_results_readme.md`; `07_CloudComputing/Validation/AE-SENS/**`; AE-PRES-JUNE-005 ticket scope |
| Appendix A1: Temporary CSI Sensitivity Detail | Selected sensitivity configurations and blocked cases, including prevalence, OOS AP/AUC, 11C total-market alpha, and completion status. | `03_Data_Output/5_SensitivityAnalysis/05_comparisons/full_grid_label_count_ranking.csv`; `03_Data_Output/5_SensitivityAnalysis/05_comparisons/full_grid_model_metric_ranking.csv`; `03_Data_Output/5_SensitivityAnalysis/05_comparisons/full_grid_11c_index_ranking.csv`; `03_Data_Output/5_SensitivityAnalysis/00_manifest/run_registry.csv`; `03_Data_Output/5_SensitivityAnalysis/00_manifest/blocked_runs.csv` |

## Scope Boundary

The sensitivity section uses temporary-CSI C/M/T sensitivity only. Permanent-CSI sensitivity and benchmark extensions are marked as future work. Sensitivity results are conceptually separate from AE-INDEX-SUITE final index results.
