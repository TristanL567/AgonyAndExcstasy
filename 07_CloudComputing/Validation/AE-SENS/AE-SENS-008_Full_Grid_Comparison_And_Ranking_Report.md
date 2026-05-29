# AE-SENS-008 Full Grid Comparison And Ranking Report

## Ticket Status

AE-SENS-008 is complete for the available full-grid evidence. Compact results were downloaded into:

`07_CloudComputing/Validation/AE-SENS/results/`

The comparison represents all 27 configured C/M/T run IDs. Twenty-four run IDs have complete or safely reused outputs. Three run IDs remain `blocked_partial` because non-empty partial remote output directories lacked documented safe overwrite/resume semantics:

| Run ID | Status | Reason |
|---|---|---|
| `C080_M000_T012` | `blocked_partial` | non-empty partial outputs lack documented safe overwrite resume |
| `C080_M000_T018` | `blocked_partial` | non-empty partial outputs lack documented safe overwrite resume |
| `C060_M020_T028` | `blocked_partial` | non-empty partial outputs lack documented safe overwrite resume |

No model training, evaluation, index construction, sensitivity grid execution, or pipeline regeneration was run in this ticket. Remote interaction was limited to compact result retrieval and compact score-distribution summarization from already-produced prediction files. Reports use `[authorized endpoint]` and `[authorized SSH key path]`; no endpoint, credential, token, or key contents are recorded.

## AEGIS Reference

Read-only AEGIS reference material was cross-referenced before execution. The ticket contract and validation prompt were found and followed. A top-level `skills/master/SKILL.md` path was not present in the reference tree inspected, so no separate master skill file was loaded from that path.

## Downloaded Compact Evidence

The local result tree contains compact/reporting-critical files only:

- label diagnostics and prevalence summaries
- raw model metrics, row counts, leaderboards, optional-family evidence, compact model metadata, and compact hyperparameter metadata
- remote-derived prediction score distribution summaries
- 11C thresholds, performance summaries, exclusion summaries, error-cost summaries, return summaries, run status, and merge diagnostics
- retained/deleted file inventories and storage-retention manifests

Compactness checks found no files larger than 50 MB and no downloaded `.rds`, `.parquet`, `.pkl`, `.model`, or `.bin` artifacts under `07_CloudComputing/Validation/AE-SENS/results/`. Heavy AutoGluon model binaries, full prediction parquet files, model cache directories, and multi-GB index-weight CSVs were not downloaded.

## Required Comparison Artifacts

Created under `07_CloudComputing/Validation/AE-SENS/results/comparisons/`:

- `full_grid_label_count_ranking.csv`
- `full_grid_model_metric_ranking.csv`
- `full_grid_prediction_distribution_summary.csv`
- `full_grid_11c_index_ranking.csv`
- `full_grid_error_cost_summary.csv`
- `full_grid_threshold_summary.csv`
- `full_grid_best_configs_by_objective.csv`
- `full_grid_factor_summary.csv`
- `full_grid_comparison_manifest.json`

## Best Configurations By Objective

| Objective | Best run ID | C | M | T | Value |
|---|---:|---:|---:|---:|---:|
| Highest test AP | `C060_M000_T012` | -0.60 | 0.00 | 12 | 0.476406 |
| Highest test AUC | `C090_M030_T012` | -0.90 | -0.30 | 12 | 0.918395 |
| Best test recall at FPR 1% | `C090_M000_T012` | -0.90 | 0.00 | 12 | 0.137559 |
| Best test recall at FPR 3% | `C090_M000_T012` | -0.90 | 0.00 | 12 | 0.347269 |
| Best test recall at FPR 5% | `C090_M030_T012` | -0.90 | -0.30 | 12 | 0.500000 |
| Lowest test Brier | `C090_M030_T028` | -0.90 | -0.30 | 28 | 0.021356 |
| Highest OOS AP | `C060_M000_T012` | -0.60 | 0.00 | 12 | 0.566382 |
| Highest OOS AUC | `C090_M030_T028` | -0.90 | -0.30 | 28 | 0.921983 |
| Highest OOS recall at FPR 1% | `C090_M000_T012` | -0.90 | 0.00 | 12 | 0.189279 |
| Highest OOS recall at FPR 3% | `C090_M000_T012` | -0.90 | 0.00 | 12 | 0.406546 |
| Highest OOS recall at FPR 5% | `C090_M000_T012` | -0.90 | 0.00 | 12 | 0.555028 |
| Lowest OOS Brier | `C090_M030_T028` | -0.90 | -0.30 | 28 | 0.017710 |
| Strongest 11C total-market benchmark-relative result | `C090_M020_T018` | -0.90 | -0.20 | 18 | 0.002259 |
| Most defensible overall composite | `C090_M000_T012` | -0.90 | 0.00 | 12 | 0.869565 |

The overall composite is a compact ranking summary over available complete-run test/OOS AP, AUC, low-FPR recall, Brier, and 11C total-market benchmark-relative performance. It is a decision aid, not a replacement for objective-specific rankings.

## Baseline Assessment

The baseline `C080_M020_T018` remains defensible as a stable middle-grid specification, but it is not the best-performing configuration in the pilot/grid evidence:

| Metric | Baseline value | Baseline rank |
|---|---:|---:|
| Test AP | 0.198512 | 14 |
| Test AUC | 0.876562 | 15 |
| Test recall at FPR 1% | 0.082090 | 12 |
| Test recall at FPR 3% | 0.200249 | 14 |
| Test recall at FPR 5% | 0.299751 | 14 |
| Test Brier | 0.038856 | 14 |
| OOS AP | 0.308381 | 10 |
| OOS AUC | 0.896108 | 13 |
| Best total-market 11C difference vs benchmark | 0.000647 | 18 |
| Best any-index 11C difference vs benchmark | 0.003796 | 4 |

The baseline is most defensible as a conservative continuity point for comparison with prior methodology, not as the empirically strongest sensitivity configuration.

## Sensitivity Interpretation

The grid materially changes model and index conclusions:

- Looser definitions with `C=-0.60`, especially `M=0.00` and `T=12`, produce much higher positive-label prevalence and the strongest AP. `C060_M000_T012` has 31,596 positives and 17.49% prevalence versus the baseline 8,517 positives and 4.74% prevalence.
- Stricter `C=-0.90` definitions generally improve AUC, low-FPR recall, and calibration. `C090_M000_T012` is the strongest overall model-composite choice, while `C090_M030_T028` is best for Brier and OOS AUC.
- Shorter `T=12` improves average AP and low-FPR recall, while `T=18` is strongest on average for 11C total-market benchmark-relative performance.
- The strongest 11C total-market result is `C090_M020_T018`, not the baseline. Its best total-market benchmark-relative annualized return difference is 0.002259.

Interpretation: stricter/looser definitions do materially change the thesis interpretation. If the objective is ranking distressed firms by predictive discrimination and low-FPR recall, strict `C=-0.90` configurations dominate. If the objective is broader event capture and AP under a high-prevalence label, loose `C=-0.60` configurations dominate. If the objective is index-construction improvement, `C090_M020_T018` is the strongest total-market specification among completed runs.

## Answers To Required Questions

1. Highest AP: `C060_M000_T012` for both test AP (0.476406) and OOS AP (0.566382).
2. Highest AUC: `C090_M030_T012` on test (0.918395); `C090_M030_T028` on OOS (0.921983).
3. Best recall at FPR 1%, 3%, and 5%: `C090_M000_T012` at FPR 1% and 3%; `C090_M030_T012` at test FPR 5%, while `C090_M000_T012` is best at OOS FPR 5%.
4. Best Brier/calibration: `C090_M030_T028` on CV, test, and OOS.
5. Strongest 11C benchmark-relative index outcome: `C090_M020_T018` for total-market benchmark-relative annualized return difference.
6. Most defensible overall: `C090_M000_T012`, balancing discrimination, low-FPR recall, OOS performance, and 11C evidence. If the primary objective is 11C total-market return, use `C090_M020_T018`; if the primary objective is AP, use `C060_M000_T012`.
7. Sensitivity to C/M/T: conclusions are sensitive. `C` changes the AP-versus-discrimination tradeoff sharply; `M=0.00` raises AP by increasing prevalence; `T=12` improves model metrics, while `T=18` is more favorable for average 11C total-market performance.
8. Baseline defensibility: `C080_M020_T018` remains defensible as a continuity baseline but is not the top-ranked model or 11C configuration.
9. Thesis interpretation: stricter and looser definitions materially affect the interpretation. The thesis should report both a predictive-discrimination winner and an index-construction winner rather than treating the baseline as uniquely final.

## No Canonical Output Modification

Local git checks found no dirty files under:

- `01_Code/`
- `02_Data_Input/`
- `03_Data_Output/`

Canonical local outputs were not modified. Local writes for this ticket were limited to compact AE-SENS validation results and this report under `07_CloudComputing/Validation/AE-SENS/`.

## Readiness

AE-SENS-008 provides sufficient compact evidence for final sensitivity reporting. No further full-grid rerun is required unless the three `blocked_partial` configurations become necessary for a complete balanced grid or the methodology changes.
