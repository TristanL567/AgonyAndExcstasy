# AE-MODEL-INDEX-LINK-002 Correlation Analysis

## Scope

This ticket computes compact correlation diagnostics from existing local evidence. It does not rerun model training, model evaluation, index construction, sensitivity scripts, Vast.ai, or SSH. It writes only documentation/evidence under the AE-MODEL-INDEX-LINK epic folder.

## Branch And HEAD

- Branch: `Development`
- Starting HEAD: `ecc4b55`
- Ticket: `AE-MODEL-INDEX-LINK-002`

## Inputs And Join Methods

### CMT Sensitivity Linkage

Primary inputs:

- `05_Documentation/09_Epics/AE-SENS-CHART_Sensitivity_Index_Charts/tables/sensitivity_index_stability_table.csv`
- `03_Data_Output/5_SensitivityAnalysis/presentation_ready/sensitivity_cmt_index_summary.csv`

Join keys:

- `run_id`
- CMT parameters `C`, `M`, and `T` are retained as descriptors.

This is the cleanest model-index linkage because each completed/reused temporary-CSI CMT run has model metrics and total-market index alpha.

### Model-Suite Linkage

Primary inputs:

- `03_Data_Output/6_ModelSuite/comparison/AE-MODEL-SUITE-007_model_suite_metrics_long.csv`
- `03_Data_Output/7_IndexConstructionValidation/nonraw_index_suite/comparison/best_by_track_index_cost.csv`

Join keys:

- `track` / `response_track`
- `feature_set` / `model_key`

This linkage compares raw, fund, latent_raw, and raw_plus_latent model families by track. It is useful but less clean statistically because the same model metrics repeat across universes and transaction-cost rows.

## Outputs Created

- `AE-MODEL-INDEX-LINK-002_joined_metric_index_dataset.csv`
- `AE-MODEL-INDEX-LINK-002_metric_alpha_correlations.csv`
- `AE-MODEL-INDEX-LINK-002_missingness_summary.csv`
- `AE-MODEL-INDEX-LINK-002_validation_checks.csv`

## Brief Result Summary

For the 24 completed/reused temporary-CSI CMT runs, model metrics do not map cleanly to total-market alpha:

| Metric vs total-market alpha | Pearson r | Spearman rho | Interpretation |
|---|---:|---:|---|
| OOS AP | -0.042425 | -0.100870 | Weak to moderate at best; AP winner is not alpha winner. |
| OOS AUC | 0.278420 | 0.297391 | Mixed relationship. |
| OOS R@FPR3 | 0.336036 | 0.320870 | More aligned than AP here, but still not deterministic. |

The status-quo chart evidence remains correct: the AP winner `C060_M000_T012` is not the strongest total-market index-alpha configuration. The strongest total-market index-alpha configuration is `C090_M020_T018`, while the main run `C080_M020_T018` sits inside the distribution rather than as an outlier.

## Why The Correlations Are Imperfect

AP, AUC, and fixed-FPR recall are label-ranking metrics. They reward correctly ranking labelled CSI events. Index alpha is different: it is return-, timing-, universe-, threshold-, and market-cap-weighted. A run can have high AP because it ranks many future CSI positives well, but still deliver lower alpha if the flagged firms have small portfolio weights, if losses occur before exclusion, or if false-positive exclusions remove firms with strong returns.

## Missingness And Caveats

- Native CMT sensitivity summaries provide AP/AUC/R@FPR3 and total-market alpha cleanly for the 24 completed/reused runs.
- Native CMT summaries do not carry transaction-cost or turnover fields in the same run-level AP-to-alpha table.
- Model-suite correlations include alpha, Sharpe, max drawdown, turnover, and transaction-cost drag, but they repeat model metrics across universes and transaction-cost levels. Treat these as descriptive diagnostics, not independent statistical tests.
- Permanent-CSI CMT sensitivity remains unavailable.

## Recommendation For Ticket 003

Ticket 003 should focus on mechanism diagnostics rather than more headline correlations. The most useful next step is to explain which mechanics break the AP-alpha link:

- market-cap weighting;
- threshold crossing;
- timing of exclusions;
- false-positive opportunity cost;
- universe dependence;
- turnover and cost drag where available in model-suite/index-suite outputs.

## Scope Hygiene

No files under these must-not-touch areas were modified:

- `03_Data_Output/**`
- `06_Presentations/**`
- `01_Code/**`
- `02_Data_Input/**`
- `07_CloudComputing/**`

No model training, model evaluation, index construction, sensitivity scripts, Vast.ai access, or SSH commands were used.
