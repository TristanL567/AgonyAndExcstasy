# AE-VALIDATE-007 Canonical vs Validation Comparison Report

## Status
completed - ready for validator review.

## AEGIS Reference Check
Before execution, I cross-referenced the read-only AEGIS material under `C:/Users/Tristan Leiter/Documents/aegis-core`: `AEGIS.md`, `contracts/swarm-contract.md`, `contracts/ticket-contract.md`, `skills/roles/master/SKILL.md`, `skills/roles/ds-validator/SKILL.md`, `skills/procedures/ticket-scope-validation/SKILL.md`, `execution/runbooks/shared-orchestration-loop.md`, `execution/runbooks/apply-to-project.md`, and `skills/discipline/operating-discipline.md`. Relevant AEGIS role contracts and validator blocking rules were found. No `aegis-core` files were edited.

## Scope And Inputs
- Ticket executed: `AE-VALIDATE-007` only.
- Branch preflight: `validation`; HEAD `f9c66355f681ad0e84bcbdbac68e584faf938bd2`, satisfying `f9c6635` exactly and therefore descendant requirement.
- No model, evaluation, index, sensitivity, regeneration, staging, commit, or push commands were run.
- Local compact evidence was used. No remote output root access was needed.

Primary comparison caveat: canonical 11C evidence contains older `11d_index_optimal03b_ag_raw_20260517_203745` scopes and shared bundle scopes, while exact canonical `11c_index_revised` directories are missing. The 11C metric comparison therefore uses the older 11d optimal03b raw scope as the closest canonical comparator, not an exact same-path 11C rerun baseline.

## Artifacts
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_model_metric_comparison.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_model_row_count_comparison.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_11c_metric_comparison.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_11c_row_count_comparison.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_difference_classification.csv`

## Difference Classification Summary
| Domain | Rows | none | numeric-only | interpretation-changing | Overall |
|---|---:|---:|---:|---:|---|
| model_row_counts | 22 | 2 | 0 | 20 | interpretation-changing |
| model_metrics | 44 | 2 | 2 | 40 | interpretation-changing |
| 11c_row_counts | 14 | 12 | 0 | 2 | interpretation-changing |
| 11c_metrics | 11182 | 3327 | 5502 | 2353 | interpretation-changing |

Classification rule used for this report: exact equality is `none`; small nonzero movement is `numeric-only`; row-count changes above 1%, or metric movement above 0.005 absolute and 2% relative is `interpretation-changing`. Unavailable metrics are reported as comparability caveats rather than counted as differences.

## Model Row Counts
Raw prediction/CV row counts are materially smaller after the revised dataset. The mapped `temporary_csi -> dynamic_csi` comparison shows about 75% fewer rows for test, OOS, train-boundary, and CV prediction artifacts. Leaderboard row counts remain 12 rows for both tracks. Evaluation rerun tables also have fewer rows than canonical evaluation tables because AE-VALIDATE-005S evaluated only the raw model output, not the broader canonical evaluation set.

- dynamic_csi `ag_cv_results.parquet`: canonical 273910, validation 72223, delta -201687 (-73.6%), interpretation-changing.
- dynamic_csi `ag_preds_oos.parquet`: canonical 74847, validation 18502, delta -56345 (-75.3%), interpretation-changing.
- dynamic_csi `ag_preds_test.parquet`: canonical 78260, validation 18111, delta -60149 (-76.9%), interpretation-changing.
- permanent_csi `ag_cv_results.parquet`: canonical 273910, validation 72223, delta -201687 (-73.6%), interpretation-changing.
- permanent_csi `ag_preds_oos.parquet`: canonical 77459, validation 26400, delta -51059 (-65.9%), interpretation-changing.
- permanent_csi `ag_preds_test.parquet`: canonical 78202, validation 18053, delta -60149 (-76.9%), interpretation-changing.

## Model Metrics
The revised dataset changed model metric levels materially. Raw AutoGluon AP is broadly similar in the compact training summaries, but AUC and recall at FPR thresholds are much lower. Evaluation-table AP/AUC/recall/Brier values from AE-VALIDATE-005S also differ materially from the canonical raw evaluation snapshot. The CSV includes available FPR1/FPR3/FPR5 evaluation recall comparisons; raw-summary Brier/FPR1/FPR5/FPR10 were not present in AE-VALIDATE-004R compact metrics and are not classified as differences.

| Source | Track | Set | Metric | Canonical | Validation | Delta | Class |
|---|---|---|---|---:|---:|---:|---|
| raw_autogluon_summary | dynamic_csi | cv | cv_ap | 0.2197 | 0.2166 | -0.0031 | numeric-only |
| raw_autogluon_summary | dynamic_csi | cv | cv_auc | 0.9647 | 0.8732 | -0.0915 | interpretation-changing |
| raw_autogluon_summary | dynamic_csi | cv | cv_r3 | 0.6127 | 0.2471 | -0.3656 | interpretation-changing |
| raw_autogluon_summary | dynamic_csi | test | avg_precision | 0.2114 | 0.1985 | -0.0129 | interpretation-changing |
| raw_autogluon_summary | dynamic_csi | test | auc_roc | 0.9692 | 0.8766 | -0.0926 | interpretation-changing |
| raw_autogluon_summary | dynamic_csi | test | recall_fpr3 | 0.6551 | 0.2002 | -0.4549 | interpretation-changing |
| raw_autogluon_summary | dynamic_csi | oos | avg_precision | 0.2911 | 0.3084 | 0.0173 | interpretation-changing |
| raw_autogluon_summary | dynamic_csi | oos | auc_roc | 0.9552 | 0.8961 | -0.0591 | interpretation-changing |
| raw_autogluon_summary | dynamic_csi | oos | recall_fpr3 | 0.7169 | 0.2547 | -0.4622 | interpretation-changing |
| evaluation_rerun | dynamic_csi | oos_2020_2022 | ap | 0.8509 | 0.3784 | -0.4725 | interpretation-changing |
| evaluation_rerun | dynamic_csi | oos_2020_2022 | auc | 0.965 | 0.8958 | -0.0692 | interpretation-changing |
| evaluation_rerun | dynamic_csi | oos_2020_2022 | r_fpr3 | 0.7178 | 0.2738 | -0.444 | interpretation-changing |
| evaluation_rerun | dynamic_csi | oos_2020_2022 | brier | 0.0636 | 0.0601 | -0.0035 | numeric-only |
| evaluation_rerun | dynamic_csi | test | ap | 0.8495 | 0.1978 | -0.6517 | interpretation-changing |
| evaluation_rerun | dynamic_csi | test | auc | 0.969 | 0.8766 | -0.0924 | interpretation-changing |
| evaluation_rerun | dynamic_csi | test | r_fpr3 | 0.7522 | 0.2002 | -0.552 | interpretation-changing |
| evaluation_rerun | dynamic_csi | test | brier | 0.0572 | 0.0389 | -0.0183 | interpretation-changing |
| raw_autogluon_summary | permanent_csi | cv | cv_ap | 0.2016 | 0.1929 | -0.0087 | interpretation-changing |
| raw_autogluon_summary | permanent_csi | cv | cv_auc | 0.965 | 0.8789 | -0.0861 | interpretation-changing |
| raw_autogluon_summary | permanent_csi | cv | cv_r3 | 0.6216 | 0.2658 | -0.3558 | interpretation-changing |
| raw_autogluon_summary | permanent_csi | test | avg_precision | 0.148 | 0.1416 | -0.0064 | interpretation-changing |
| raw_autogluon_summary | permanent_csi | test | auc_roc | 0.9674 | 0.881 | -0.0864 | interpretation-changing |
| raw_autogluon_summary | permanent_csi | test | recall_fpr3 | 0.6621 | 0.1808 | -0.4813 | interpretation-changing |
| raw_autogluon_summary | permanent_csi | oos | avg_precision | 0.0587 | 0.0323 | -0.0264 | interpretation-changing |
| raw_autogluon_summary | permanent_csi | oos | auc_roc | 0.9495 | 0.8081 | -0.1414 | interpretation-changing |
| raw_autogluon_summary | permanent_csi | oos | recall_fpr3 | 0.4456 | 0.0119 | -0.4337 | interpretation-changing |
| evaluation_rerun | permanent_csi | oos_2020_2022 | ap | 0.1223 | 0.1387 | 0.0164 | interpretation-changing |
| evaluation_rerun | permanent_csi | oos_2020_2022 | auc | 0.9558 | 0.8769 | -0.0789 | interpretation-changing |
| evaluation_rerun | permanent_csi | oos_2020_2022 | r_fpr3 | 0.6129 | 0.2908 | -0.3221 | interpretation-changing |
| evaluation_rerun | permanent_csi | oos_2020_2022 | brier | 0.006 | 0.0214 | 0.0154 | interpretation-changing |
| evaluation_rerun | permanent_csi | test | ap | 0.1344 | 0.1405 | 0.0061 | interpretation-changing |
| evaluation_rerun | permanent_csi | test | auc | 0.9661 | 0.881 | -0.0851 | interpretation-changing |
| evaluation_rerun | permanent_csi | test | r_fpr3 | 0.6648 | 0.1808 | -0.484 | interpretation-changing |
| evaluation_rerun | permanent_csi | test | brier | 0.0067 | 0.0284 | 0.0217 | interpretation-changing |

Headline model conclusion: yes, the revised dataset changed the headline metric interpretation materially if the prior conclusion relied on high AUC/high recall. It does not reverse the broad track ranking in the compact raw summaries: dynamic/temporary still has stronger AP than permanent on most AP views, but the margin and recall profile are materially different.

## 11C Row Counts
Most 11C output row counts match exactly between the canonical older 11d comparator and validation rerun: thresholds, returns, performance, exclusion summary, error-cost decomposition, and run-status rows are unchanged. Weight rows increased materially, with the caveat that canonical row evidence is from RDS files while validation row evidence is from CSV files.

- permanent_csi `error_cost_decomposition_by_crsp_universe`: canonical 192, validation 192, delta 0 (0.0%), none.
- permanent_csi `index_exclusion_summary_by_crsp_universe`: canonical 1056, validation 1056, delta 0 (0.0%), none.
- permanent_csi `index_performance_by_crsp_universe`: canonical 64, validation 64, delta 0 (0.0%), none.
- permanent_csi `index_weights_by_crsp_universe`: canonical 1926660, validation 2199308, delta 272648 (14.2%), interpretation-changing.
- dynamic_csi `error_cost_decomposition_by_crsp_universe`: canonical 768, validation 768, delta 0 (0.0%), none.
- dynamic_csi `index_exclusion_summary_by_crsp_universe`: canonical 4224, validation 4224, delta 0 (0.0%), none.
- dynamic_csi `index_performance_by_crsp_universe`: canonical 208, validation 208, delta 0 (0.0%), none.
- dynamic_csi `index_weights_by_crsp_universe`: canonical 6492662, validation 7379966, delta 887304 (13.7%), interpretation-changing.

## 11C Metrics
Threshold and error-cost internals move materially, consistent with the revised model scores and row universe. The main index-construction result is more stable: best OOS filtered strategies remain close to benchmark and generally differ by only a few basis points to roughly 60 basis points annualized, depending on track/index.

| Track | Index | Canonical best OOS | Validation best OOS | Canonical Sharpe | Validation Sharpe | Canonical diff vs bench | Validation diff vs bench |
|---|---|---|---|---:|---:|---:|---:|
| dynamic_csi | large_cap | fpr3/5yr lockout | youden/5yr lockout | 0.664226 | 0.678362 | -0.000573697 | 0.00175368 |
| dynamic_csi | mid_cap | youden/1yr lockout | fpr3/5yr lockout | 0.414113 | 0.423284 | 0.000298679 | 0.00380772 |
| dynamic_csi | small_cap | youden/3yr lockout | youden/3yr lockout | 0.369998 | 0.333038 | 0.0137189 | 0.00583269 |
| dynamic_csi | total_market | fpr3/5yr lockout | youden/5yr lockout | 0.61516 | 0.636608 | 0.001189 | 0.00463659 |
| permanent_csi | large_cap | fpr3/Permanent removal | fpr3/Permanent removal | 0.678286 | 0.664601 | 0.00344827 | 0.00155701 |
| permanent_csi | mid_cap | fpr1/Permanent removal | fpr3/Permanent removal | 0.427045 | 0.42719 | 0.00425825 | 0.00456909 |
| permanent_csi | small_cap | fpr3/Permanent removal | fpr1/Permanent removal | 0.306 | 0.310134 | -0.000416321 | 0.000989196 |
| permanent_csi | total_market | fpr3/Permanent removal | fpr3/Permanent removal | 0.628598 | 0.607712 | 0.00472173 | 0.00173356 |

Headline index-construction conclusion: no reversal of the broad conclusion was observed. The revised dataset changes thresholds, exclusion/error-cost details, and some best-strategy selections, but the OOS filtered-index effects remain economically small and close to benchmark rather than becoming a large, robust outperformance result. This statement is subject to the canonical-scope caveat above.

## Missing Canonical Files And Comparability
AE-VALIDATE-003 missing-file inventory summary: 11c_index_revised_exact: 28; raw_autogluon_ag_raw: 2.

- Missing `ag_feature_importance.csv` for both canonical raw model tracks does not affect row-count, AP, AUC, recall, Brier, or CV metric comparability.
- Missing exact canonical `11c_index_revised` paths do affect 11C comparability. The report therefore compares validation 11C outputs to the available older 11d optimal03b raw canonical scope and explicitly does not claim an exact same-path canonical-vs-validation 11C comparison.

## Completion Report Envelope

status: completed

summary: AE-VALIDATE-007 compared canonical raw model and 11C index evidence against the validation rerun evidence. The dataset revision materially changed model row counts and many model metrics; it changed 11C internals and weight-row counts, but did not reverse the broad index-construction conclusion that filtered strategies are close to benchmark with small OOS differences.

artifacts:
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_Canonical_vs_Validation_Comparison_Report.md`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_model_metric_comparison.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_model_row_count_comparison.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_11c_metric_comparison.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_11c_row_count_comparison.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_difference_classification.csv`

findings:
- Model results changed materially in row universe, AUC, recall, and evaluation-table metrics; dynamic/temporary remains generally stronger than permanent on AP-oriented views.
- Index construction did not show a headline conclusion reversal; strategy selection and internals changed, while OOS return differences versus benchmark remain small.
- Exact canonical `11c_index_revised` outputs are missing, so 11C comparison is against the older 11d optimal03b canonical scope.

next_recommended_role: validator

changed_files:
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_Canonical_vs_Validation_Comparison_Report.md`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_model_metric_comparison.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_model_row_count_comparison.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_11c_metric_comparison.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_11c_row_count_comparison.csv`
- `07_CloudComputing/Validation/AE-VALIDATE/AE-VALIDATE-007_difference_classification.csv`

verification:
- Preflight checked branch `validation` and HEAD descendant requirement.
- Read-only AEGIS reference material was loaded before execution.
- Comparison artifacts were generated from local compact evidence plus read-only canonical 11d CSVs where needed for volatility/threshold/exclusion/error-cost fields.
- Forbidden model, evaluation, index, sensitivity, and regeneration scripts were not run.
- No staging, commit, or push was performed.

human_readability:
- concise: true
- unnecessary_elements_removed: true
- abstraction_added: false
- abstraction_rationale: null
- diff_summary: Created one compact Markdown comparison report and five CSV comparison artifacts under the allowed AE-VALIDATE validation directory.
- layer_touched: procedure
- layer_separation_preserved: true
