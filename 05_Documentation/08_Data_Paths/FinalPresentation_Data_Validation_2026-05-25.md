# Final Presentation Data Validation - 2026-05-25

## Scope

Draft checked:

- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.Rnw`
- `06_Presentations/02_FinalPresentation/Necessary/FinalPresentation/FinalPresentation_TristanLeiter_h11815352.pdf`

Reference checked:

- `05_Documentation/08_Data_Paths/Data_Paths.md`

The validation below treats the Rnw source as the canonical draft content because it contains the authored slide values directly.

## Ticket 1 - Data Shown In The Draft

The draft shows the following data-bearing content:

| Slide area | Data shown |
|---|---|
| Dataset | CRSP, Compustat, FRED sources; USD 100M market-cap screen; CRSP-like Total/Large/Mid/Small universes; Jan 1993-Dec 2024 coverage; Train 1993-2015, Test 2016-2019, OOS 2020-2024 |
| Methodology I | CSI parameters C = -80%, M = -20%, T = 18 months, h = 12 months |
| Applying classification | 8,369 confirmed event rows; split row/label table with total 626,080 rows and 8,341 strict positives |
| Robustness I | 629 CRSP 572-574 firms; 151 detected, 478 missed, 24.0% detection under confirmed CSI only |
| Methodology II | Revised bankruptcy-overlap table: 629 CRSP 572-574 firms; 545 detected; 84 missed; 86.65% detection |
| Robustness II | Recovery-bucket grid and base row: C080_M020_T018, 5,642 firms, 85.0% stayed below M |
| Methodology III | Permanent CSI claim: 6,344 positives across 626,080 firm-years, 1.01% |
| Descriptive statistics | Temporary/Permanent full-sample y=0/y=1 rows, shares, firms, median market cap, annual return, ROA |
| Modelling | Feature-set keys, VAE architecture, AutoGluon and XGBoost CV/Test/OOS AP, AUC, R@FPR3, R@FPR5 |
| Index construction | Test and Test-OOS best rules, benchmark and screened performance, and error-cost decomposition |

## Ticket 2 - Local Source Map

| Claim area | Data_Paths reference | Local source status |
|---|---|---|
| Confirmed CSI events | `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/csi_events_base.rds` | Present |
| Temporary annual base labels | `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/labels_base.rds` | Present |
| Permanent annual labels | `02_Data_Input/05_PipelineResults/Necessary/permanent_csi/Labels/labels_permanent_loss.rds` | Present |
| Revised descriptive counts | `03_Data_Output/1_Descriptive_Statistics/Necessary/temporary_csi/csi_revised_label_scaffold_stats/*.csv` | Present |
| Bankruptcy and recovery robustness | Historical grid checks: `03_Data_Output/2_Robustness_Checks/Necessary/temporary_csi/csi_parameter_grid_results/*.csv`; current revised overlap source: `03_Data_Output/2_Robustness_Checks/Necessary/permanent_csi/14e_price_distress_response_labels/temporary_csi_crsp_default_overlap_summary.csv` | Present |
| Current AutoGluon metrics | `03_Data_Output/3_Modelling_Results/Necessary/{track}/AutoGluon/{model}/ag_eval_summary.json` | Present |
| XGBoost metrics | `03_Data_Output/3_Modelling_Results/Necessary/{track}/XGBoost/xgb_eval_table.csv` | Present |
| Index best-rule summaries | `03_Data_Output/4_IndexConstruction_Results/Necessary/shared/final_strategy_summary/*.csv` | Present |

I checked 78 local paths referenced in `Data_Paths.md`. The only real missing files are already listed as known gaps in that document:

- `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/labels_dynamic_csi.rds`
- `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Labels/labels_model_ready.rds`
- `02_Data_Input/05_PipelineResults/Necessary/temporary_csi/Panel/panel_raw.rds`

Other apparent misses were unexpanded placeholders such as `{model_key}` and `{fund,raw}`; the concrete AutoGluon model folders and VAE config files are present.

## Ticket 3 - Validation Results

| Item | Status | Evidence | Action |
|---|---|---|---|
| Total dataset row count 626,080 | PASS, with caveat | `labels_base.rds` and `labels_permanent_loss.rds` both have 626,080 rows. Split rows are Train 449,995, Test 78,260, OOS 97,825. | Keep 626,080 only if described as split rows / firm-year rows including rows with missing/censored labels. |
| Strict confirmed event rows 8,369 | PASS | `csi_events_base.rds`: `event_status == confirmed_csi` is 8,369; base confirmed firms are 5,642. | No change needed for event-row claim. |
| Strict annual positives 8,341 and y=0 617,739 | FAIL | Current `labels_base.rds`: y=1 is 8,440, y=0 is 614,227, NA is 3,413. By split: Train y=1 6,479; Test 781; OOS 1,180; OOS NA 3,413. | Replace the table or locate the older artifact that produced 8,341. Do not present 617,739 as current y=0. |
| Revised temporary positives 8,647 | PASS | `overview_counts_cv_and_full.csv` and `validation_positive_counts.csv`: Temporary Full y=1 is 8,647, share 1.43%, firms 5,677. | Valid for revised temporary-CSI/descriptive slides. |
| Robustness I 24.0% before detection | PASS | `F_bankruptcy_detection_by_grid.csv`, base row C080_M020_T018: 629 firms, 151 detected after confirmation, 478 missed, 24.006%. | No change needed. |
| Methodology II revised overlap | PASS / refreshed | `temporary_csi_crsp_default_overlap_summary.csv`: 629 CRSP 572-574 firms, 545 detected by revised temporary CSI, 84 missed, 86.65%. | Treat the remaining misses as methodological exclusions under the retained CSI-trigger rule unless a separate diagnostic proves a pipeline error. |
| Recovery bucket base row | PASS | `G_old_csi_base_recovery_bucket_firm_summary.csv`: 5,642 firms; stayed below M = 4,793, 84.952%; M to 0 = 182; 0 to abs(C) = 354; >abs(C) = 260; no follow-up = 53. | No change needed, aside from rounding consistency. |
| Permanent 6,344 across 626,080 | PARTIAL | `labels_permanent_loss.rds`: 626,080 rows, y=1 6,344, y=0 599,312, NA 20,424. Descriptive scaffold instead reports Permanent Full y=1 6,650 and y=0 599,006 over nonmissing rows. | Choose one denominator and artifact. If using 6,344, disclose that 20,424 label rows are NA/censored. If using descriptive stats, use 6,650 over nonmissing rows. |
| Descriptive statistics table | PASS, with denominator caveat | Counts and medians match `overview_counts_cv_and_full.csv`, `marketcap_usd_millions_cv_and_full.csv`, and `other_median_descriptives_cv_and_full.csv`. | Keep values, but avoid mixing with the 626,080 full-row denominator unless NA handling is stated. |
| Feature-set key diagram | FAIL | `Data_Paths.md` maps `features_latent_raw.parquet` to "Latent Dataset (VAE)" and `features_raw_plus_latent.parquet` to "Expanded Dataset + VAE". The Modelling I diagram labels these rows in the opposite way. | Swap the labels/rows in the diagram. |
| VAE architecture | PASS | VAE configs show z_dim 24, encoder 256/128/64, decoder 64/128/256, beta 1.0, gamma 0.1, patience 15. | No change needed. |
| AutoGluon model metrics | PASS for shown values, WARN for Data_Paths source | The shown AG values match `ag_eval_summary.json` files. They do not match `eval_performance_all.rds`, although `Data_Paths.md` says that RDS is the source for Modelling II/III result tables. | Update `Data_Paths.md` or use `eval_performance_all.rds` consistently. Current slide source is JSON, not that RDS. |
| XGBoost model metrics | PASS | The shown XGB values match each track's `XGBoost/xgb_eval_table.csv`. | No change needed. |
| Index performance tables | PASS | The shown Test/Test-OOS performance values match `final_strategy_summary/test_oos_best_strategy_by_index.csv` and the wide summary CSV after rounding. | No change needed. |
| Main error-cost slides | FAIL / inconsistent convention | Appendix tables use raw `tn_gain_pp` from the summary CSV, e.g. Temporary Total Market OOS TN = 0.782. Main slides use balancing TN terms, e.g. Temporary Total Market OOS TN = 1.028 so FP+FN+TP+TN equals Net. The balancing calculation is not stored in the cited summary CSV and differs from Appendix A16/A18. | Use one convention in main and appendix, or add a documented calculation source for the balancing term. |

## Direct Answer On 626,080

Yes, 626,080 rows exist locally as the full split-row count in both the temporary and permanent label files. It should not be read as 626,080 fully observed binary labels. Current files contain missing/censored label rows:

| File | Rows | y=1 | y=0 | NA |
|---|---:|---:|---:|---:|
| `temporary_csi/Labels/labels_base.rds` | 626,080 | 8,440 | 614,227 | 3,413 |
| `permanent_csi/Labels/labels_permanent_loss.rds` | 626,080 | 6,344 | 599,312 | 20,424 |

The draft's "Total 626,080 / y=1 8,341 / y=0 617,739" table does not match the current local data.

## Highest Priority Fixes

1. Fix the "Applying the classification" table: current local labels do not support 8,341 positives or 617,739 negatives.
2. Keep the Methodology II detection table aligned with `temporary_csi_crsp_default_overlap_summary.csv`: 545 detected, 84 missed, and 86.65% detection.
3. Reconcile permanent-CSI positive counts: 6,344 in `labels_permanent_loss.rds` versus 6,650 in descriptive scaffold outputs.
4. Swap/fix the Modelling I feature-set labels for latent-only versus raw-plus-latent.
5. Standardize the error-cost decomposition convention between main slides and appendix/source CSVs.
