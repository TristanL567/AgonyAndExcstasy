# AE-PRES-QA-FIX-008 Model-Index CV Metric Chart Report

## Scope

This ticket rebuilds the appendix model-index scatter chart so the machine-learning side uses CV-only metrics: AP, AUC, R@FPR3, and R@FPR5. The portfolio side compares those metrics with total-market index alpha in the available `insample` and `test` periods.

No model predictions, model metrics, index-construction outputs, sensitivity outputs, code, or input data were recomputed or modified.

## Source Data

- `03_Data_Output/5_SensitivityAnalysis/presentation_ready/sensitivity_cmt_model_summary.csv`
- `03_Data_Output/5_SensitivityAnalysis/04_index_construction/combined_11c_performance.csv`

The 11C source uses `period = insample`, not an explicit `cv` label. The chart therefore labels that alpha outcome as **in-sample/CV-proxy alpha**.

## Output Artifacts

- `charts/slide48_cv_metrics_vs_cv_test_alpha.png`
- `charts/slide48_cv_metrics_vs_cv_test_alpha.pdf`
- `AE-PRES-QA-FIX-008_cv_metric_alpha_joined_data.csv`
- `AE-PRES-QA-FIX-008_cv_metric_alpha_correlations.csv`
- `AE-PRES-QA-FIX-008_source_map.csv`

## Chart Construction

The chart uses 24 completed/reused temporary-CSI C/M/T runs. For each run, CV AP, CV AUC, CV R@FPR3, and CV R@FPR5 are joined to the best non-benchmark total-market 11C alpha in each available alpha period:

- `insample`, labelled as in-sample/CV-proxy alpha;
- `test`, labelled as test alpha.

The chart highlights the main run, the CV AP winner, the total-market index-alpha winner, and the composite winner.

## Finding

The CV-only ML metrics do not provide a clean positive connection to total-market alpha in this sensitivity slice. The strongest relationship is not AP. CV AP is weakly negative against in-sample/CV-proxy alpha and near zero against test alpha. CV AUC and fixed-FPR recall are more negative against test alpha.

This supports the interpretation that index performance is not a generic ML metric. It is the realized result after thresholding, timing, universe weights, and returns.

## Correlation Summary

| Alpha period | Metric | Pearson r | Spearman rho |
|---|---:|---:|---:|
| In-sample/CV-proxy | CV AP | -0.283 | -0.152 |
| In-sample/CV-proxy | CV AUC | -0.145 | -0.144 |
| In-sample/CV-proxy | CV R@FPR3 | -0.025 | -0.103 |
| In-sample/CV-proxy | CV R@FPR5 | -0.016 | -0.062 |
| Test | CV AP | 0.069 | -0.037 |
| Test | CV AUC | -0.432 | -0.382 |
| Test | CV R@FPR3 | -0.315 | -0.291 |
| Test | CV R@FPR5 | -0.342 | -0.298 |

## Presentation Update

Slide 48 was replaced with `Appendix A19: CV Metrics Versus Index Alpha`. The slide now shows all four CV-only ML metrics against in-sample/CV-proxy alpha and test alpha, and includes the period-label limitation directly in the interpretation.

`SLIDE_DATA_SOURCES.md` was updated for the new slide source mapping.
